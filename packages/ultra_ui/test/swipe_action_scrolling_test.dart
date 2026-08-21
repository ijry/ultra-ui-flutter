// UPSwipeActionItem `scrolling` tests.
//
// The source exposes the in-progress swipe as a `v-model:scrolling` flag so a
// page can pause its own scrolling while a row is being dragged. The value is
// deduped, so one gesture cannot emit the same state twice.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

Widget _host({
  bool disabled = false,
  bool scrolling = false,
  ValueChanged<bool>? onScrolling,
  ValueChanged<bool>? onUpdateScrolling,
  Key? itemKey,
}) {
  return MaterialApp(
    theme: UP.themeData(),
    home: Scaffold(
      body: UPSwipeAction(
        children: <Widget>[
          UPSwipeActionItem(
            key: itemKey,
            disabled: disabled,
            scrolling: scrolling,
            onScrolling: onScrolling,
            onUpdateScrolling: onUpdateScrolling,
            options: const <Map<String, dynamic>>[
              <String, dynamic>{'text': '删除'},
            ],
            child: const SizedBox(height: 60, child: Text('row')),
          ),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('a drag reports scrolling true then false', (tester) async {
    final scrolling = <bool>[];
    final updates = <bool>[];
    await tester.pumpWidget(_host(
      onScrolling: scrolling.add,
      onUpdateScrolling: updates.add,
    ));
    await tester.pumpAndSettle();

    final gesture =
        await tester.startGesture(tester.getCenter(find.text('row')));
    await tester.pump();
    await gesture.moveBy(const Offset(-40, 0));
    await tester.pump();
    expect(scrolling, <bool>[true]);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(scrolling, <bool>[true, false]);
    // Both source emits fire together, in the same order.
    expect(updates, scrolling);
  });

  testWidgets('repeated drag updates do not re-emit the same state',
      (tester) async {
    final scrolling = <bool>[];
    await tester.pumpWidget(_host(onScrolling: scrolling.add));
    await tester.pumpAndSettle();

    final gesture =
        await tester.startGesture(tester.getCenter(find.text('row')));
    for (var i = 0; i < 4; i++) {
      await gesture.moveBy(const Offset(-10, 0));
      await tester.pump();
    }
    expect(scrolling, <bool>[true], reason: 'the source dedupes on value');

    await gesture.up();
    await tester.pumpAndSettle();
    expect(scrolling, <bool>[true, false]);
  });

  testWidgets('a disabled row never reports scrolling', (tester) async {
    final scrolling = <bool>[];
    await tester.pumpWidget(_host(disabled: true, onScrolling: scrolling.add));
    await tester.pumpAndSettle();

    await tester.drag(find.text('row'), const Offset(-60, 0));
    await tester.pumpAndSettle();
    expect(scrolling, isEmpty);
  });

  testWidgets('becoming disabled mid-swipe clears the flag', (tester) async {
    final scrolling = <bool>[];
    await tester.pumpWidget(_host(onScrolling: scrolling.add));
    await tester.pumpAndSettle();

    final gesture =
        await tester.startGesture(tester.getCenter(find.text('row')));
    await gesture.moveBy(const Offset(-40, 0));
    await tester.pump();
    expect(scrolling, <bool>[true]);

    // The source watcher calls setScrolling(false) when disabled turns on.
    await tester.pumpWidget(_host(disabled: true, onScrolling: scrolling.add));
    await tester.pump();
    expect(scrolling, <bool>[true, false]);

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('an external scrolling value updates state without emitting',
      (tester) async {
    final scrolling = <bool>[];
    await tester.pumpWidget(_host(onScrolling: scrolling.add));
    await tester.pumpAndSettle();

    await tester.pumpWidget(_host(scrolling: true, onScrolling: scrolling.add));
    await tester.pumpAndSettle();
    expect(scrolling, isEmpty,
        reason: 'the source watcher assigns innerScrolling without emitting');
  });

  testWidgets('the default button colors follow the source theme values',
      (tester) async {
    final key = GlobalKey<UPSwipeActionItemState>();
    await tester.pumpWidget(_host(itemKey: key));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(UPSwipeActionItem));
    expect(key.currentState!.defaultButtonBgColor(context),
        const Color(0xFFC7C6CD));
    expect(
        key.currentState!.defaultButtonColor(context), const Color(0xFFFFFFFF));
  });

  testWidgets('wxsInit reports the source re-measure dependency list',
      (tester) async {
    final key = GlobalKey<UPSwipeActionItemState>();
    await tester.pumpWidget(_host(itemKey: key));
    await tester.pumpAndSettle();

    final deps = key.currentState!.wxsInit;
    expect(deps.length, 5);
    expect(deps[0], isFalse); // disabled
    expect(deps[1], isTrue); // autoClose
    expect(deps[2], 20); // threshold
    expect(deps[4], 300); // duration
  });
}
