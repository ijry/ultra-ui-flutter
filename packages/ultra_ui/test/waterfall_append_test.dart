// UPWaterfall append-vs-redistribute tests, and UPVirtualList visibleCount.
//
// The source only takes its cheap append path when the new list starts with the
// old one. Any other change means items were reordered or replaced, and the
// columns must be rebuilt — otherwise stale entries linger.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

List<Map<String, dynamic>> _items(List<int> ids) => <Map<String, dynamic>>[
      for (final id in ids) <String, dynamic>{'id': id, 'label': 'item $id'},
    ];

Widget _waterfall(
  List<Map<String, dynamic>> value,
  GlobalKey<UPWaterfallState> key,
) =>
    MaterialApp(
      theme: UP.themeData(),
      home: Scaffold(
        body: SizedBox(
          width: 360,
          height: 600,
          child: UPWaterfall(
            key: key,
            value: value,
            itemBuilder: (context, item, index, column) => SizedBox(
              height: 40,
              child: Text('${item['label']}'),
            ),
          ),
        ),
      ),
    );

void main() {
  group('UPWaterfall.isPureAppend', () {
    final key = GlobalKey<UPWaterfallState>();

    testWidgets('an empty previous list is always a pure append',
        (tester) async {
      await tester.pumpWidget(_waterfall(_items(<int>[1]), key));
      await tester.pumpAndSettle();
      final state = key.currentState!;

      expect(state.isPureAppend(_items(<int>[1, 2]), <dynamic>[]), isTrue);
      expect(state.isPureAppend(<dynamic>[], <dynamic>[]), isTrue);
    });

    testWidgets('extending the list is a pure append', (tester) async {
      await tester.pumpWidget(_waterfall(_items(<int>[1]), key));
      await tester.pumpAndSettle();
      final state = key.currentState!;

      expect(
        state.isPureAppend(_items(<int>[1, 2, 3]), _items(<int>[1, 2])),
        isTrue,
      );
    });

    testWidgets('shrinking, reordering or replacing is not', (tester) async {
      await tester.pumpWidget(_waterfall(_items(<int>[1]), key));
      await tester.pumpAndSettle();
      final state = key.currentState!;

      // Shorter than before.
      expect(
        state.isPureAppend(_items(<int>[1]), _items(<int>[1, 2])),
        isFalse,
      );
      // Same length, different order.
      expect(
        state.isPureAppend(_items(<int>[2, 1]), _items(<int>[1, 2])),
        isFalse,
      );
      // A leading item was replaced.
      expect(
        state.isPureAppend(_items(<int>[9, 2, 3]), _items(<int>[1, 2])),
        isFalse,
      );
    });
  });

  testWidgets('replacing the list drops the old items', (tester) async {
    final key = GlobalKey<UPWaterfallState>();
    await tester.pumpWidget(_waterfall(_items(<int>[1, 2]), key));
    await tester.pumpAndSettle();
    expect(find.text('item 1'), findsOneWidget);

    // Not an append: the previous entries must not survive.
    await tester.pumpWidget(_waterfall(_items(<int>[7, 8]), key));
    await tester.pumpAndSettle();
    expect(find.text('item 7'), findsOneWidget);
    expect(find.text('item 1'), findsNothing,
        reason: 'a replaced list must be redistributed, not appended to');
  });

  testWidgets('appending keeps the existing items', (tester) async {
    final key = GlobalKey<UPWaterfallState>();
    await tester.pumpWidget(_waterfall(_items(<int>[1, 2]), key));
    await tester.pumpAndSettle();

    await tester.pumpWidget(_waterfall(_items(<int>[1, 2, 3]), key));
    await tester.pumpAndSettle();
    expect(find.text('item 1'), findsOneWidget);
    expect(find.text('item 3'), findsOneWidget);
  });

  testWidgets('UPVirtualList.visibleCount includes the buffer', (tester) async {
    final key = GlobalKey<UPVirtualListState>();
    await tester.pumpWidget(MaterialApp(
      theme: UP.themeData(),
      home: Scaffold(
        body: SizedBox(
          width: 300,
          height: 200,
          child: UPVirtualList(
            key: key,
            itemHeight: 40,
            buffer: 4,
            listData: List<int>.generate(100, (i) => i),
            itemBuilder: (context, item, index) =>
                SizedBox(height: 40, child: Text('row $item')),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // 200px of viewport at 40px rows is 5 visible, plus the 4-row buffer.
    expect(key.currentState!.visibleCount, 9);
  });
}
