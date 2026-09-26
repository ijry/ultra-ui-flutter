import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) =>
      tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));

  testWidgets('defaults: horizontal Flex, start main, stretch cross', (tester) async {
    await pump(tester, const UPFlex(children: [Text('a'), Text('b')]));
    final flex = tester.widget<Flex>(find.byType(Flex));
    expect(flex.direction, Axis.horizontal);
    expect(flex.mainAxisAlignment, MainAxisAlignment.start);
    expect(flex.crossAxisAlignment, CrossAxisAlignment.stretch);
  });

  testWidgets('column + space-between + center maps correctly', (tester) async {
    await pump(tester, const UPFlex(
      direction: 'column', justify: 'space-between', align: 'center',
      children: [Text('a'), Text('b')],
    ));
    final flex = tester.widget<Flex>(find.byType(Flex));
    expect(flex.direction, Axis.vertical);
    expect(flex.mainAxisAlignment, MainAxisAlignment.spaceBetween);
    expect(flex.crossAxisAlignment, CrossAxisAlignment.center);
  });

  testWidgets('end alias + gap inserts a SizedBox between children', (tester) async {
    await pump(tester, const UPFlex(
      justify: 'end', gap: 16, children: [Text('a'), Text('b')],
    ));
    final flex = tester.widget<Flex>(find.byType(Flex));
    expect(flex.mainAxisAlignment, MainAxisAlignment.end);
    expect(flex.children.length, 3);
    expect(flex.children[1], isA<SizedBox>());
    expect((flex.children[1] as SizedBox).width, 16);
  });

  testWidgets('wrap renders a Wrap with spacing', (tester) async {
    await pump(tester, const UPFlex(
      wrap: true, gap: 8, children: [Text('a'), Text('b')],
    ));
    final w = tester.widget<Wrap>(find.byType(Wrap));
    expect(w.direction, Axis.horizontal);
    expect(w.spacing, 8);
    expect(w.runSpacing, 8);
  });

  testWidgets('glass prop is accepted as a no-op', (tester) async {
    await pump(tester, const UPFlex(
      glass: UPFlexGlass(enabled: true, tint: '#ffffff'),
      children: [Text('a')],
    ));
    expect(find.byType(Flex), findsOneWidget);
  });
}
