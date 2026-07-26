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

  testWidgets('radio page changes the source group value', (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsA/radio/radio'));
    await tester.tap(find.text('苹果').first);
    await tester.pump();
    expect(find.text('当前选择：apple'), findsOneWidget);
  });

  testWidgets('checkbox page programmatic toggle changes standalone state',
      (tester) async {
    await tester
        .pumpWidget(buildRouteUnderTest('componentsA/checkbox/checkbox'));
    await tester.tap(find.text('切换').first);
    await tester.pump();
    expect(find.text('true'), findsWidgets);
  });

  testWidgets('rate page emits an editable half rating', (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsA/rate/rate'));

    final halfRate = find.byKey(const ValueKey('rate-half-mode'));
    await tester.ensureVisible(halfRate);
    await tester.pumpAndSettle();
    await tester.tapAt(tester.getTopLeft(halfRate) + const Offset(5, 10));
    await tester.pump();

    expect(tester.state<UPRateState>(halfRate).value, 0.5);
    expect(find.text('当前评分：0.5'), findsOneWidget);
  });
}
