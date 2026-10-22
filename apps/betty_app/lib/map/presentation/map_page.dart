import 'dart:convert';

import 'package:betty_app/core/config/app_config.dart';
import 'package:betty_app/core/navigation/presentation/routes.dart';
import 'package:betty_app/home/application/home_page_bloc/home_page_bloc.dart';
import 'package:betty_app/home/application/home_page_bloc/home_page_state.dart';
import 'package:betty_app/home/presentation/helpers/home_routes_to_index_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapboxMap? _mapboxMap;

  @override
  void initState() {
    super.initState();

    MapboxOptions.setAccessToken(AppConfig.instance.mapBoxApiKey);
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    await mapboxMap.addSource(
      RasterDemSource(id: 'terrain-dem', url: 'mapbox://mapbox.mapbox-terrain-dem-v1', tileSize: 514, maxzoom: 14),
    );

    await mapboxMap.setStyleTerrain(jsonEncode({'source': 'terrain-dem', 'exaggeration': 1.3}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E4D8),
      body: BlocSelector<HomePageBloc, HomePageState, bool>(
        selector: (state) => state.activePage == HomeRoutesToIndexMapper.getIndexFromRoute(Routes.map),
        builder: (context, isActive) {
          return isActive
              ? MapWidget(key: const ValueKey('mapWidget'), styleUri: MapboxStyles.OUTDOORS, onMapCreated: _onMapCreated)
              : const SizedBox.expand();
        },
      ),
    );
  }
}
