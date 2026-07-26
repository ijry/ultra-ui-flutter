import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';
import 'package:ultra_ui_example/app/example_app.dart';
import 'package:ultra_ui_example/routes/example_catalog.dart';

Future<void> pumpExampleApp(WidgetTester tester) {
  return tester.pumpWidget(const UltraUiExampleApp());
}

Widget buildRouteUnderTest(String id) {
  final route = findExampleRoute(id);
  return MaterialApp(
    theme: UP.themeData(),
    home: Builder(builder: route.builder),
  );
}
