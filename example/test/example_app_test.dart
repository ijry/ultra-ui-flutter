import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui_example/app/example_app.dart';
import 'package:ultra_ui_example/pages/home/ad_page.dart';
import 'package:ultra_ui_example/pages/shared/example_page_scaffold.dart';
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

  testWidgets('bottom navigation preserves mine theme selection state',
      (tester) async {
    await pumpExampleApp(tester);

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('深色模式'));
    await tester.pumpAndSettle();
    expect(find.text('当前主题：浅色（手动深色）'), findsOneWidget);

    await tester.tap(find.text('组件'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();

    expect(find.text('当前主题：浅色（手动深色）'), findsOneWidget);
    expect(find.text('当前'), findsOneWidget);
  });

  testWidgets('ad, route push, and shared scaffold follow mobile contracts',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => pushExampleRoute(
              context,
              findExampleRoute('example/ad'),
            ),
            child: const Text('打开广告页'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开广告页'));
    await tester.pumpAndSettle();
    expect(find.byType(AdPage), findsOneWidget);
    expect(
      find.text('激励广告仅适用于微信小程序，Flutter 示例不提供广告播放'),
      findsOneWidget,
    );
    expect(
        find.byKey(const ValueKey('example-page-safe-area')), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('打开广告页'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: ExamplePageScaffold(
          title: '独立页面',
          child: Text('页面内容'),
        ),
      ),
    );
    expect(
        find.byKey(const ValueKey('example-page-safe-area')), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
  });

  test('completed catalog ids and source paths are unique', () {
    expect(exampleRoutes.map((route) => route.id).toSet().length,
        exampleRoutes.length);
    expect(exampleRoutes.map((route) => route.sourcePath).toSet().length,
        exampleRoutes.length);
  });
}
