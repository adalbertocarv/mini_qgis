// lib/config/map_config.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';

class MapConfig {
  static const String tileLayerUrl = 'https://{s}.basemaps.cartocdn.com/{style}/{z}/{x}/{y}{r}.png';
  static const String userAgentPackageName = 'rastertiles/voyager_nolabels';

  static MapOptions getMapOptions({LatLng? center, double zoom = 13.0}) {
    return MapOptions(
      center: center ?? LatLng(0, 0),
      zoom: zoom,
    );
  }

  static TileLayer getTileLayer(BuildContext context) {
    final bool isHighDensity = MediaQuery.of(context).devicePixelRatio > 1.0;

    return TileLayer(
      urlTemplate: tileLayerUrl,
      subdomains: const ['a', 'b', 'c'],
      additionalOptions: const {
        'style': userAgentPackageName,
      },
      tileProvider: CancellableNetworkTileProvider(),
      retinaMode: isHighDensity,
    );
  }
}