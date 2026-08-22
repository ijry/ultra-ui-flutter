// Layout regression test for every demo page.
//
// Two failure modes this catches, both of which shipped before it existed:
//   - A demo card shrink-wrapping its child instead of spanning the page, so a
//     demo holding narrow content rendered a sliver of a card.
//   - A RenderFlex overflow, which only appears on a narrow viewport and is
//     invisible in a normal-width screenshot.
//
// Every registered route is checked at three widths, so a page that only breaks
// on a small phone still fails here.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../lib/pages/shared/example_demo_block.dart';
import '../lib/routes/example_catalog.dart';

/// Narrow phone, common phone, tablet.
const List<double> _widths = <double>[320, 390, 768];

/// ExampleDemoBlock's own horizontal padding.
const double _blockPadding = 12 * 2;

void main() {
  for (final width in _widths) {
    for (final route in exampleRoutes) {
      testWidgets('${route.id} lays out at ${width.toInt()}px', (tester) async {
        tester.view.physicalSize = Size(width * 3, 844 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.reset);

        final overflows = <String>[];
        final previous = FlutterError.onError;
        FlutterError.onError = (details) {
          final text = details.exceptionAsString();
          if (text.contains('overflowed')) {
            overflows.add(text.split('\n').first);
          } else {
            previous?.call(details);
          }
        };

        await tester.pumpWidget(
          MaterialApp(
            theme: UP.themeData(),
            home: Builder(builder: route.builder),
          ),
        );
        // pump rather than pumpAndSettle: several pages animate indefinitely.
        await tester.pump(const Duration(milliseconds: 300));
        FlutterError.onError = previous;

        expect(overflows.toSet(), isEmpty,
            reason: '${route.id} overflows at ${width.toInt()}px');

        final narrow = <String>[];
        for (final block in find.byType(ExampleDemoBlock).evaluate()) {
          final cards = find
              .descendant(
                of: find.byWidget(block.widget),
                matching: find.byType(DecoratedBox),
              )
              .evaluate();
          if (cards.isEmpty) continue;
          final card = cards.first.renderObject as RenderBox;
          if (!card.hasSize) continue;
          // Allow a few px of slack for pages that intentionally inset a card.
          if (card.size.width < width - _blockPadding - 6) {
            narrow.add('${(block.widget as ExampleDemoBlock).title}'
                '=${card.size.width.toStringAsFixed(0)}');
          }
        }
        expect(narrow, isEmpty,
            reason: '${route.id} has shrink-wrapped cards at '
                '${width.toInt()}px: ${narrow.join(', ')}');
      });
    }
  }
}
