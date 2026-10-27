import 'dart:convert';

import 'package:betty_app/core/config/app_config.dart';
import 'package:betty_app/core/navigation/presentation/routes.dart';
import 'package:betty_app/home/application/home_page_bloc/home_page_bloc.dart';
import 'package:betty_app/home/application/home_page_bloc/home_page_state.dart';
import 'package:betty_app/home/presentation/helpers/home_routes_to_index_mapper.dart';
import 'package:betty_app/map/application/map_bloc/map_bloc.dart';
import 'package:betty_app/map/application/map_bloc/map_event.dart';
import 'package:betty_app/map/application/map_bloc/map_state.dart';
import 'package:betty_app/map/domain/entities/map_location.dart';
import 'package:betty_app/map/domain/ports/device_location_port.dart';
import 'package:betty_app/map/domain/ports/server_gps_port.dart';
import 'package:betty_app/map/presentation/widgets/map_error_banner.dart';
import 'package:betty_app/map/presentation/widgets/map_location_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

const _deviceMarkerColor = Color(0xFF2563EB);
const _serverMarkerColor = Color(0xFF43e97b);
const _defaultZoom = 15.0;
const _defaultPitch = 50.0;
const _terrainSourceId = 'terrain-dem';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapBloc(
        deviceLocationPort: context.read<DeviceLocationPort>(),
        serverGpsPort: context.read<ServerGpsPort>(),
      )..add(const WatchMapLocations()),
      child: const MapPageView(),
    );
  }
}

class MapPageView extends StatefulWidget {
  const MapPageView({super.key});

  @override
  State<MapPageView> createState() => _MapPageViewState();
}

class _MapPageViewState extends State<MapPageView>
    with AutomaticKeepAliveClientMixin<MapPageView> {
  MapboxMap? _mapboxMap;
  CircleAnnotationManager? _circleManager;
  PointAnnotationManager? _pointManager;
  bool _hasInitialCamera = false;
  bool _styleLoaded = false;
  Future<void>? _terrainSetup;
  int _annotationSync = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    MapboxOptions.setAccessToken(AppConfig.instance.mapBoxApiKey);
  }

  double _navClearance(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return height / 20 + height / 12;
  }

  Point _pointFrom(MapLocation location) {
    return Point(coordinates: Position(location.longitude, location.latitude));
  }

  CameraOptions _cameraFor(
    MapLocation location, {
    double? pitch,
    double? bearing,
  }) {
    return CameraOptions(
      center: _pointFrom(location),
      zoom: _defaultZoom,
      pitch: pitch ?? _defaultPitch,
      bearing: bearing,
      padding: MbxEdgeInsets(
        top: 0,
        left: 0,
        right: 0,
        bottom: _navClearance(context),
      ),
    );
  }

  Future<void> _enableTerrain(MapboxMap mapboxMap) {
    final pending = _terrainSetup;
    if (pending != null) return pending;

    final setup = _applyTerrain(mapboxMap);
    _terrainSetup = setup;
    return setup.whenComplete(() {
      if (identical(_terrainSetup, setup)) _terrainSetup = null;
    });
  }

  Future<void> _applyTerrain(MapboxMap mapboxMap) async {
    if (_mapboxMap != mapboxMap) return;
    if (!await mapboxMap.styleSourceExists(_terrainSourceId)) {
      if (_mapboxMap != mapboxMap) return;
      await mapboxMap.addSource(
        RasterDemSource(
          id: _terrainSourceId,
          url: 'mapbox://mapbox.mapbox-terrain-dem-v1',
          tileSize: 514,
          maxzoom: 14,
        ),
      );
    }
    if (_mapboxMap != mapboxMap) return;
    await mapboxMap.setStyleTerrain(
      jsonEncode({'source': _terrainSourceId, 'exaggeration': 1.3}),
    );
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    if (_styleLoaded) await _enableTerrain(mapboxMap);

    await mapboxMap.logo.updateSettings(
      LogoSettings(position: OrnamentPosition.BOTTOM_LEFT, marginBottom: 8),
    );
    await mapboxMap.attribution.updateSettings(
      AttributionSettings(marginBottom: 8),
    );

    _circleManager = await mapboxMap.annotations
        .createCircleAnnotationManager();
    _pointManager = await mapboxMap.annotations.createPointAnnotationManager();

    if (!mounted || _mapboxMap != mapboxMap) return;
    final state = context.read<MapBloc>().state;
    await _syncAnnotations(state);
    if (!mounted || _mapboxMap != mapboxMap) return;
    _positionCamera(state, force: true);
  }

  void _releaseMap() {
    _mapboxMap = null;
    _circleManager = null;
    _pointManager = null;
    _styleLoaded = false;
    _terrainSetup = null;
  }

  Future<void> _syncAnnotations(MapState state) async {
    final sync = ++_annotationSync;
    final circles = _circleManager;
    final points = _pointManager;
    if (circles == null || points == null) return;

    await circles.deleteAll();
    await points.deleteAll();
    if (sync != _annotationSync || !mounted) return;

    if (state.deviceLocation != null) {
      await _addMarker(
        location: state.deviceLocation!,
        color: _deviceMarkerColor,
        label: 'Tú',
        radius: 10,
      );
    }
    if (sync != _annotationSync || !mounted) return;

    if (state.serverLocation != null) {
      await _addMarker(
        location: state.serverLocation!,
        color: _serverMarkerColor,
        label: 'Betty',
        radius: 12,
      );
    }
  }

  Future<void> _addMarker({
    required MapLocation location,
    required Color color,
    required String label,
    required double radius,
  }) async {
    final point = _pointFrom(location);
    await _circleManager?.create(
      CircleAnnotationOptions(
        geometry: point,
        circleColor: color.toARGB32(),
        circleRadius: radius,
        circleStrokeColor: Colors.white.toARGB32(),
        circleStrokeWidth: 2.5,
      ),
    );
    await _pointManager?.create(
      PointAnnotationOptions(
        geometry: point,
        textField: label,
        textSize: 13,
        textColor: const Color(0xFF1E1E1E).toARGB32(),
        textHaloColor: Colors.white.toARGB32(),
        textHaloWidth: 1.4,
        textOffset: const [0, 1.5],
      ),
    );
  }

  void _positionCamera(MapState state, {bool force = false}) {
    if (!force && _hasInitialCamera) return;

    final location = state.serverLocation ?? state.deviceLocation;
    if (location == null) return;

    _hasInitialCamera = true;
    _mapboxMap?.setCamera(_cameraFor(location));
  }

  Future<void> _flyTo(MapLocation location) async {
    final map = _mapboxMap;
    if (map == null) return;

    final current = await map.getCameraState();
    await map.flyTo(
      _cameraFor(
        location,
        pitch: current.pitch > 0 ? current.pitch : _defaultPitch,
        bearing: current.bearing,
      ),
      MapAnimationOptions(duration: 1000),
    );
  }

  void _goToDevice() {
    final location = context.read<MapBloc>().state.deviceLocation;
    if (location != null) {
      _flyTo(location);
      return;
    }
    context.read<MapBloc>().add(const WatchMapLocations());
  }

  void _goToServer() {
    final location = context.read<MapBloc>().state.serverLocation;
    if (location != null) {
      _flyTo(location);
      return;
    }
    context.read<MapBloc>().add(const WatchMapLocations());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final height = MediaQuery.sizeOf(context).height;
    final inset = height / 40;
    final navClearance = _navClearance(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE8E4D8),
      body: MultiBlocListener(
        listeners: [
          BlocListener<HomePageBloc, HomePageState>(
            listenWhen: (previous, current) =>
                previous.activePage != current.activePage,
            listener: (context, state) {
              final isActive =
                  state.activePage ==
                  HomeRoutesToIndexMapper.getIndexFromRoute(Routes.map);
              if (!isActive) _releaseMap();
            },
          ),
          BlocListener<MapBloc, MapState>(
            listenWhen: (previous, current) =>
                previous.deviceLocation != current.deviceLocation ||
                previous.serverLocation != current.serverLocation,
            listener: (context, state) {
              _syncAnnotations(state);
              _positionCamera(state);
            },
          ),
        ],
        child: Stack(
          children: [
            BlocSelector<HomePageBloc, HomePageState, bool>(
              selector: (state) =>
                  state.activePage ==
                  HomeRoutesToIndexMapper.getIndexFromRoute(Routes.map),
              builder: (context, isActive) {
                return isActive
                    ? MapWidget(
                        key: const ValueKey('mapWidget'),
                        styleUri: MapboxStyles.OUTDOORS,
                        viewport: CameraViewportState(
                          zoom: _defaultZoom,
                          pitch: _defaultPitch,
                        ),
                        onMapCreated: _onMapCreated,
                        onStyleLoadedListener: (_) {
                          _styleLoaded = true;
                          final map = _mapboxMap;
                          if (map != null) _enableTerrain(map);
                        },
                      )
                    : const SizedBox.expand();
              },
            ),
            const Align(
              alignment: Alignment.topCenter,
              child: MapErrorBanner(),
            ),
            Positioned(
              right: inset,
              bottom: navClearance + inset,
              child: MapLocationButtons(
                onGoToDevice: _goToDevice,
                onGoToServer: _goToServer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
