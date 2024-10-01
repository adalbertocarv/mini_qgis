// lib/models/polyline_model.dart
import 'package:latlong2/latlong.dart';

class PolylineModel {
  List<LatLng> points = [];

  void addPoint(LatLng point) {
    points.add(point);
  }

  void clearPoints() {
    points.clear();
  }

  List<List<double>> toCoordinates() {
    return points.map((p) => [p.longitude, p.latitude]).toList();
  }

  bool isEmpty() {
    return points.isEmpty;
  }
}