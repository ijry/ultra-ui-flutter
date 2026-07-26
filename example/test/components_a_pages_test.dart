import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';
import 'package:ultra_ui_example/routes/example_catalog.dart';

import 'example_test_helpers.dart';

void main() {
  testWidgets('Component A display routes render their source titles',
      (tester) async {
    for (final id in <String>[
      'componentsA/icon/icon',
      'componentsA/cell/cell',
      'componentsA/line/line',
      'componentsA/image/image',
      'componentsA/link/link',
      'componentsA/loading-icon/loading-icon',
      'componentsA/divider/divider',
      'componentsA/gap/gap',
      'componentsA/grid/grid',
    ]) {
      await tester.pumpWidget(buildRouteUnderTest(id));

      expect(find.byKey(ValueKey('example-page-$id')), findsOneWidget);
      expect(find.text(findExampleRoute(id).title).first, findsOneWidget);
    }
  });

  testWidgets('grid item tap reports source-style feedback', (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsA/grid/grid'));

    expect(find.byType(UPGrid), findsWidgets);
    expect(find.byType(UPGridItem), findsWidgets);
    await tester.tap(find.text('宫格1').first);
    await tester.pump();

    expect(find.text('点击了宫格1'), findsOneWidget);
    UPToast.hide();
    await tester.pump();
  });
}
