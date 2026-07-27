import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';
import 'package:ultra_ui_example/routes/example_catalog.dart';

import 'example_test_helpers.dart';

void main() {
  testWidgets('dropdown page selects the source distance option',
      (tester) async {
    await tester.pumpWidget(
      buildRouteUnderTest('componentsB/dropdown/dropdown'),
    );

    await tester.tap(find.text('距离'));
    await tester.pumpAndSettle();
    expect(find.text('距离优先'), findsOneWidget);

    await tester.tap(find.text('距离优先'));
    await tester.pump();
    expect(find.text('当前选择：2'), findsOneWidget);
  });

  testWidgets('action sheet page opens the source cancel preset',
      (tester) async {
    await tester.pumpWidget(
      buildRouteUnderTest('componentsB/actionSheet/actionSheet'),
    );

    await tester.tap(find.text('显示取消按钮'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('选项3'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
  });

  testWidgets('action sheet page explains the WeChat-only source preset',
      (tester) async {
    await tester.pumpWidget(
      buildRouteUnderTest('componentsB/actionSheet/actionSheet'),
    );

    await tester.tap(find.text('微信开放能力'));
    await tester.pump();
    expect(find.text('请在微信内预览'), findsOneWidget);
    UPToast.hide();
  });

  testWidgets('parse page renders source content and opens its internal route',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => pushExampleRoute(
              context,
              findExampleRoute('componentsB/parse/parse'),
            ),
            child: const Text('打开解析器'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开解析器'));
    await tester.pumpAndSettle();
    expect(find.textContaining('表格'), findsWidgets);
    expect(find.text('内部链接'), findsWidgets);

    final internalLink = find.text('内部链接');
    await tester.ensureVisible(internalLink);
    await tester.pumpAndSettle();
    await tester.tap(internalLink);
    await tester.pumpAndSettle();
    expect(find.text('内部链接'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('example-page-componentsB/parse/jump')),
      findsOneWidget,
    );
  });

  testWidgets('parse page renders its source image without a network source',
      (tester) async {
    await tester.pumpWidget(
      buildRouteUnderTest('componentsB/parse/parse'),
    );

    final image = tester.widget<UPImage>(find.byType(UPImage));
    expect(image.src.startsWith('http://'), isFalse);
    expect(image.src.startsWith('https://'), isFalse);
  });
}
