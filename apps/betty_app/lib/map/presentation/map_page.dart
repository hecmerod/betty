import 'dart:convert';

import 'package:betty_app/core/config/app_config.dart';
import 'package:flutter/material.dart';
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
      body: MapWidget(key: const ValueKey('mapWidget'), styleUri: MapboxStyles.OUTDOORS, onMapCreated: _onMapCreated),
    );
  }
}
