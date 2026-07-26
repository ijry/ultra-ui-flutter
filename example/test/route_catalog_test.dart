import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui_example/routes/example_catalog.dart';

void main() {
  test('source main catalog contains exactly four available routes', () {
    expect(exampleRoutes, hasLength(4));
    expect(exampleRoutes.every((route) => route.available), isTrue);
  });

  test('route ids resolve to their registered catalog entries', () {
    for (final route in exampleRoutes) {
      expect(findExampleRoute(route.id), same(route));
      expect(route.builder, isA<WidgetBuilder>());
    }
  });
}
