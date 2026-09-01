import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

const _options = <Map<String, dynamic>>[
  <String, dynamic>{'id': 1, 'name': 'A'},
  <String, dynamic>{'id': 2, 'name': 'B'},
];

Color _barrierColor(WidgetTester tester) {
  final box = tester.widget<ColoredBox>(
    find.descendant(
      of: find.byKey(const ValueKey('up-select-overlay-barrier')),
      matching: find.byType(ColoredBox),
    ),
  );
  return box.color;
}

void main() {
  testWidgets('UPSelect overlay defaults to the source visible opacity',
      (tester) async {
    final key = GlobalKey<UPSelectState>();
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(body: UPSelect(key: key, options: _options)),
      ),
    );
    key.currentState!.open();
    await tester.pump();
    await tester.pump();

    expect(_barrierColor(tester).a, closeTo(0.3, 0.001));
  });

  testWidgets('UPSelect accepts a string overlayOpacity', (tester) async {
    final key = GlobalKey<UPSelectState>();
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPSelect(
            key: key,
            options: _options,
            overlayOpacity: '0.6',
          ),
        ),
      ),
    );
    key.currentState!.open();
    await tester.pump();
    await tester.pump();

    expect(_barrierColor(tester).a, closeTo(0.6, 0.001));
  });

  testWidgets('UPSelect closeOnClickOverlay false keeps the panel open',
      (tester) async {
    final key = GlobalKey<UPSelectState>();
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPSelect(
            key: key,
            options: _options,
            closeOnClickOverlay: false,
          ),
        ),
      ),
    );
    key.currentState!.open();
    await tester.pump();
    await tester.pump();
    expect(key.currentState!.isOpen, isTrue);

    await tester.tap(find.byKey(const ValueKey('up-select-overlay-barrier')));
    await tester.pump();

    expect(key.currentState!.isOpen, isTrue);
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('UPSelect closeOnClickOverlay true closes on a barrier tap',
      (tester) async {
    final key = GlobalKey<UPSelectState>();
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(body: UPSelect(key: key, options: _options)),
      ),
    );
    key.currentState!.open();
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('up-select-overlay-barrier')));
    await tester.pump();

    expect(key.currentState!.isOpen, isFalse);
  });

  testWidgets('UPSelect labelClick toggles the panel like the source',
      (tester) async {
    final key = GlobalKey<UPSelectState>();
    final shows = <bool>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPSelect(
            key: key,
            options: _options,
            onUpdateShow: shows.add,
          ),
        ),
      ),
    );

    key.currentState!.labelClick();
    await tester.pump();
    await tester.pump();
    expect(key.currentState!.isOpen, isTrue);

    key.currentState!.labelClick();
    await tester.pump();
    expect(key.currentState!.isOpen, isFalse);
    expect(shows, <bool>[true, false]);
  });

  testWidgets('UPSelect trigger stays tappable above a visible overlay',
      (tester) async {
    final key = GlobalKey<UPSelectState>();
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: Center(
            child: UPSelect(key: key, options: _options, label: '选项'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('选项'));
    await tester.pump();
    await tester.pump();
    expect(key.currentState!.isOpen, isTrue);

    // The trigger is lifted above the barrier, so tapping it collapses the
    // panel instead of the barrier swallowing the gesture.
    await tester.tap(find.text('选项'));
    await tester.pump();
    expect(key.currentState!.isOpen, isFalse);
  });
}
