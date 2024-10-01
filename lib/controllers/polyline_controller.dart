import 'dart:convert';
import 'package:latlong2/latlong.dart';
import '../models/polyline_model.dart';
import '../services/geojson_to_shapefile_service.dart';

class PolylineController {
  final PolylineModel model;
  final GeoJsonToShapefileService service = GeoJsonToShapefileService();

  PolylineController(this.model);

  void addPoint(double latitude, double longitude) {
    model.addPoint(LatLng(latitude, longitude));
  }

  Future<String> exportToGeoJSON() async {
    if (model.isEmpty()) {
      return 'No points to export';
    }

    final Map<String, dynamic> geoJson = {
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'geometry': {
            'type': 'LineString',
            'coordinates': model.toCoordinates(),
          },
          'properties': {},
        },
      ],
    };

    try {
      final geoJsonString = jsonEncode(geoJson);

      // Enviar GeoJSON ao serviço Python para conversão
      await service.convertGeoJsonToShapefile(geoJsonString);

      return 'GeoJSON enviado para conversão com sucesso';
    } catch (e) {
      return 'Erro ao exportar e converter GeoJSON: $e';
    }
  }

  void clearPolyline() {
    model.clearPoints();
  }
}
