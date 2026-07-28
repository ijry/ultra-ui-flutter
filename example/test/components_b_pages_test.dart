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

  testWidgets('toast page opens the source success preset', (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsB/toast/toast'));

    await tester.tap(find.text('成功主题(带图标)'));
    await tester.pump();
    expect(find.text('庄生晓梦迷蝴蝶'), findsOneWidget);
    UPToast.hide();
  });

  testWidgets('toast page loading preset closes after the source duration',
      (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsB/toast/toast'));

    await tester.tap(find.text('正在加载'));
    await tester.pump();
    expect(find.byType(UPLoadingIcon), findsOneWidget);
    expect(find.text('正在加载'), findsWidgets);

    await tester.pump(const Duration(milliseconds: 2100));
    expect(find.byType(UPLoadingIcon), findsNothing);
    expect(find.text('正在加载'), findsOneWidget);
  });

  testWidgets('keyboard page opens the source car keyboard preset',
      (tester) async {
    await tester
        .pumpWidget(buildRouteUnderTest('componentsB/keyboard/keyboard'));

    await tester.tap(find.text('车牌号键盘'));
    await tester.pumpAndSettle();
    expect(find.text('车牌号键盘'), findsWidgets);
    expect(find.text('京'), findsOneWidget);
  });

  testWidgets('slider page advances the basic source slider', (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsB/slider/slider'));

    expect(find.text('当前值：30'), findsOneWidget);
    await tester.tap(find.text('前进'));
    await tester.pump();
    expect(find.text('当前值：31'), findsOneWidget);
  });

  testWidgets('upload page adds a source basic file', (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsB/upload/upload'));

    expect(find.text('基础用法：0'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('upload-page-basic')),
        matching: find.byWidgetPredicate(
          (widget) => widget is UPIcon && widget.name == 'camera-fill',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('基础用法：1'), findsOneWidget);
  });

  testWidgets('notify page opens the source success preset', (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsB/notify/notify'));

    await tester.tap(find.text('成功通知'));
    await tester.pump();
    expect(find.text('notify顶部提示'), findsOneWidget);
    expect(find.byType(UPNotify), findsOneWidget);
  });

  testWidgets('countDown page starts and pauses the manual source timer',
      (tester) async {
    await tester
        .pumpWidget(buildRouteUnderTest('componentsB/countDown/countDown'));

    expect(find.text('手动状态：未开始'), findsOneWidget);
    await tester.ensureVisible(find.text('开始'));
    await tester.pump();
    await tester.tap(find.text('开始'));
    await tester.pump();
    expect(find.text('手动状态：运行中'), findsOneWidget);

    await tester.ensureVisible(find.text('暂停'));
    await tester.pump();
    await tester.tap(find.text('暂停'));
    await tester.pump();
    expect(find.text('手动状态：已暂停'), findsOneWidget);
  });

  testWidgets('color page renders the source primary swatch', (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsB/color/color'));

    expect(find.text('主色调'), findsOneWidget);
    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('#3c9cff'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('example-page-componentsB/color/color')),
      findsOneWidget,
    );
  });

  testWidgets(
      'numberBox page increments source basic value and hides custom minus',
      (tester) async {
    await tester
        .pumpWidget(buildRouteUnderTest('componentsB/numberBox/numberBox'));

    expect(find.text('基础用法'), findsOneWidget);
    expect(find.text('基础值：3'), findsOneWidget);

    final basicPlus = find.descendant(
      of: find.byKey(const ValueKey('number-box-page-basic')),
      matching: find.byWidgetPredicate(
        (widget) => widget is UPIcon && widget.name == 'plus',
      ),
    );
    await tester.tap(basicPlus);
    await tester.pumpAndSettle();
    expect(find.text('基础值：4'), findsOneWidget);

    await tester
        .ensureVisible(find.byKey(const ValueKey('number-box-page-custom')));
    await tester.pump();
    final customMinus = find.byKey(const ValueKey('number-box-custom-minus'));
    expect(customMinus, findsOneWidget);
    await tester.tap(customMinus);
    await tester.pumpAndSettle();
    await tester.tap(customMinus);
    await tester.pumpAndSettle();
    await tester.tap(customMinus);
    await tester.pumpAndSettle();
    expect(customMinus, findsNothing);
    expect(find.text('自定义值：0'), findsOneWidget);
  });

  testWidgets(
      'countTo page starts pauses and resumes the manual source counter',
      (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsB/countTo/countTo'));

    expect(find.text('自定义控制'), findsOneWidget);
    expect(find.text('计数状态：未开始'), findsOneWidget);

    await tester.ensureVisible(find.text('开始'));
    await tester.pump();
    await tester.tap(find.text('开始'));
    await tester.pump();
    expect(find.text('计数状态：运行中'), findsOneWidget);

    await tester.tap(find.text('暂停'));
    await tester.pump();
    expect(find.text('计数状态：已暂停'), findsOneWidget);

    await tester.tap(find.text('继续'));
    await tester.pump();
    expect(find.text('计数状态：继续中'), findsOneWidget);
  });
}
