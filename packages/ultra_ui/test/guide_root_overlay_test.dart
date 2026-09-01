import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

void main() {
  testWidgets('UPGuide escapes local bounds and fills the root overlay',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
      UPGuide.clearRemembered('guide-root-overlay-test');
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: ClipRect(
              child: SizedBox(
                width: 360,
                height: 500,
                child: UPGuide(
                  show: true,
                  once: false,
                  storageKey: 'guide-root-overlay-test',
                  bgColor: '#123456',
                  list: const <Map<String, String>>[
                    <String, String>{'title': 'Root overlay guide'},
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final guideMaterial = find.byWidgetPredicate(
      (widget) => widget is Material && widget.color == const Color(0xFF123456),
    );
    expect(guideMaterial, findsOneWidget);
    expect(tester.getSize(guideMaterial), const Size(390, 844));
  });

  testWidgets('UPGuide follows controlled show changes in one frame',
      (tester) async {
    const storageKey = 'guide-controlled-show-test';
    final show = ValueNotifier<bool>(false);
    var underlyingTaps = 0;
    addTearDown(() {
      show.dispose();
      UPGuide.clearRemembered(storageKey);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: <Widget>[
              Center(
                child: ElevatedButton(
                  key: const ValueKey('guide-underlying-button'),
                  onPressed: () => underlyingTaps += 1,
                  child: const Text('Underlying action'),
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: show,
                builder: (context, value, _) => UPGuide(
                  show: value,
                  once: false,
                  storageKey: storageKey,
                  list: const <Map<String, String>>[
                    <String, String>{'title': 'Controlled guide'},
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Controlled guide'), findsNothing);

    show.value = true;
    await tester.pump();
    expect(find.text('Controlled guide'), findsOneWidget);

    show.value = false;
    await tester.pump();
    expect(find.text('Controlled guide'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('guide-underlying-button')));
    await tester.pump();
    expect(underlyingTaps, 1);
  });
}
