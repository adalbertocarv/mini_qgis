// lib/main.dart
import 'package:flutter/material.dart';
import 'controllers/polyline_controller.dart';
import 'models/polyline_model.dart';
import 'views/polyline_drawer_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final PolylineModel model = PolylineModel();
    final PolylineController controller = PolylineController(model);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PolylineDrawerPage(controller: controller),
    );
  }
}