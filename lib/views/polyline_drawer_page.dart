import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/polyline_controller.dart';

class PolylineDrawerPage extends StatefulWidget {
  final PolylineController controller;

  const PolylineDrawerPage({Key? key, required this.controller}) : super(key: key);

  @override
  _PolylineDrawerPageState createState() => _PolylineDrawerPageState();
}

class _PolylineDrawerPageState extends State<PolylineDrawerPage> {
  final MapController _mapController = MapController();
  bool isDrawingMode = false;

  void _handleTap(LatLng latlng) {
    if (isDrawingMode) {
      setState(() {
        widget.controller.addPoint(latlng.latitude, latlng.longitude);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini QGIS'),
        actions: [
          IconButton(
            icon: Icon(isDrawingMode ? Icons.edit_off : Icons.edit),
            onPressed: () {
              setState(() {
                isDrawingMode = !isDrawingMode;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              String message = await widget.controller.exportToGeoJSON();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                widget.controller.clearPolyline();
              });
            },
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: widget.controller.model.points.isNotEmpty
              ? widget.controller.model.points[0]
              : const LatLng(-15.794091, -47.882742),
          zoom: 13.0,
          onTap: (_, latlng) => _handleTap(latlng),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: widget.controller.model.points,
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),
          MarkerLayer(
            markers: widget.controller.model.points.map((point) => Marker(
              point: point,
              width: 80,
              height: 80,
              child: const Icon(Icons.location_on, color: Colors.red),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
