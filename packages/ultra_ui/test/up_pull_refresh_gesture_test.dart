import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

void main() {
  testWidgets('UPPullRefresh receives a real downward drag over scroll content',
      (tester) async {
    var refreshes = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: SizedBox(
            height: 180,
            child: UPPullRefresh(
              key: const ValueKey('pull-refresh-gesture'),
              threshold: 50,
              onRefresh: () {
                refreshes += 1;
              },
              child: const SizedBox(
                height: 400,
                child: Text('scroll content'),
              ),
            ),
          ),
        ),
      ),
    );

    final refresh = find.byKey(const ValueKey('pull-refresh-gesture'));
    final gesture = await tester.startGesture(tester.getCenter(refresh));
    await gesture.moveBy(const Offset(0, 160));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(refreshes, 1);
  });
}
