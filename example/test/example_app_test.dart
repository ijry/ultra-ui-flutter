import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui_example/app/example_app.dart';
import 'package:ultra_ui_example/routes/example_catalog.dart';

Future<void> pumpExampleApp(WidgetTester tester) {
  return tester.pumpWidget(const UltraUiExampleApp());
}

void main() {
  testWidgets('example app opens the source component destination',
      (tester) async {
    await pumpExampleApp(tester);

    expect(find.text('组件'), findsWidgets);
    expect(find.text('模板'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
    expect(find.text('uview-plus'), findsOneWidget);
  });

  testWidgets('bottom navigation preserves all three source destinations',
      (tester) async {
    await pumpExampleApp(tester);

    await tester.tap(find.text('模板'));
    await tester.pumpAndSettle();
    expect(find.text('模板'), findsWidgets);
    expect(find.text('部件'), findsOneWidget);

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    expect(find.text('演示用户'), findsOneWidget);
  });

  test('completed catalog ids and source paths are unique', () {
    expect(exampleRoutes.map((route) => route.id).toSet().length,
        exampleRoutes.length);
    expect(exampleRoutes.map((route) => route.sourcePath).toSet().length,
        exampleRoutes.length);
  });
}
