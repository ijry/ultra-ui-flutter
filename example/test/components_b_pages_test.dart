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

  testWidgets('search page edits basic source input and opens icon toast',
      (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsB/search/search'));

    expect(find.text('基础功能'), findsOneWidget);
    final basicInput = find.descendant(
      of: find.byKey(const ValueKey('search-page-basic')),
      matching: find.byType(TextField),
    );
    await tester.enterText(basicInput, '关键词');
    await tester.pump();
    expect(find.text('关键词'), findsOneWidget);

    await tester
        .ensureVisible(find.byKey(const ValueKey('search-page-click-icon')));
    await tester.pump();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('search-page-click-icon')),
        matching: find.byWidgetPredicate(
          (widget) => widget is UPIcon && widget.name == 'search',
        ),
      ),
    );
    await tester.pump();
    expect(find.text('点击了左侧图标'), findsOneWidget);
    UPToast.hide();
  });

  testWidgets('badge page renders source limit number formats', (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsB/badge/badge'));

    expect(find.text('徽标数显示方式'), findsOneWidget);
    expect(find.text('1.5k'), findsOneWidget);
    expect(find.text('4.51w'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('example-page-componentsB/badge/badge')),
      findsOneWidget,
    );
  });

  testWidgets('tag page closes and toggles source selectable tags',
      (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsB/tag/tag'));

    expect(find.text('可关闭标签'), findsOneWidget);
    expect(find.text('关闭状态：true,true,true'), findsOneWidget);
    await tester
        .ensureVisible(find.byKey(const ValueKey('tag-page-closeable')));
    await tester.pump();
    await tester.tap(
      find
          .descendant(
            of: find.byKey(const ValueKey('tag-page-closeable')),
            matching: find.byWidgetPredicate(
              (widget) => widget is UPIcon && widget.name == 'close',
            ),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(find.text('关闭状态：false,true,true'), findsOneWidget);

    await tester.ensureVisible(find.text('单选标签'));
    await tester.pump();
    await tester.tap(find.text('选项2').first);
    await tester.pumpAndSettle();
    expect(find.text('单选：2'), findsOneWidget);

    await tester.ensureVisible(find.text('多选标签'));
    await tester.pump();
    await tester.tap(find.text('选项3').last);
    await tester.pumpAndSettle();
    expect(find.text('多选：1,3'), findsOneWidget);
  });

  testWidgets('alert page closes source alert and records close callback',
      (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsB/alert/alert'));

    expect(find.text('基础功能'), findsOneWidget);
    expect(find.text('关闭事件：0'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const ValueKey('alert-page-close-callback')),
    );
    await tester.pump();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('alert-page-close-callback')),
        matching: find.byWidgetPredicate(
          (widget) => widget is UPIcon && widget.name == 'close',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('关闭事件：1'), findsOneWidget);
  });

  testWidgets('switch page toggles basic and confirms async source switch',
      (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsB/switch/switch'));

    expect(find.text('基础功能'), findsOneWidget);
    expect(find.text('异步值：true'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('switch-page-basic-1')),
        matching: find.byType(UPSwitch),
      ),
    );
    await tester.pump(const Duration(milliseconds: 450));
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('switch-page-basic-1')),
        matching: find.text('true'),
      ),
      findsOneWidget,
    );

    await tester.ensureVisible(find.byKey(const ValueKey('switch-page-async')));
    await tester.pump();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('switch-page-async')),
        matching: find.byType(UPSwitch),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('确定要关闭吗'), findsOneWidget);
    await tester.tap(find.text('确定'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('异步值：false'), findsOneWidget);
  });

  testWidgets('collapse page opens source panels and renders custom slots',
      (tester) async {
    await tester.pumpWidget(
      buildRouteUnderTest('componentsB/collapse/collapse'),
    );

    expect(find.text('基础功能'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('collapse-page-basic')),
        matching: find.text('文档指南'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('方向指导和设计理念'), findsWidgets);
    expect(find.textContaining('变更：'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('collapse-page-expanded-disabled')),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('collapse-page-expanded-disabled')),
        matching: find.textContaining('贴心小工具'),
      ),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.byKey(const ValueKey('collapse-page-custom-slots')),
    );
    await tester.pumpAndSettle();
    expect(find.text('10'), findsOneWidget);
  });

  testWidgets('code page starts the source countdown and disables the button',
      (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsB/code/code'));

    expect(find.text('基础功能'), findsOneWidget);
    await tester.tap(find.text('获取验证码').first);
    await tester.pump();
    expect(find.text('验证码已发送'), findsOneWidget);
    expect(find.textContaining('S获取'), findsOneWidget);

    final button = tester.widget<UPButton>(
      find.widgetWithText(UPButton, '20S获取'),
    );
    expect(button.disabled, isTrue);
    UPToast.hide();
  });

  testWidgets('noticeBar page closes the source closable notice',
      (tester) async {
    await tester
        .pumpWidget(buildRouteUnderTest('componentsB/noticeBar/noticeBar'));

    expect(find.text('关闭事件：0'), findsOneWidget);
    await tester
        .ensureVisible(find.byKey(const ValueKey('notice-page-closable')));
    await tester.pump();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('notice-page-closable')),
        matching: find.byWidgetPredicate(
          (widget) => widget is UPIcon && widget.name == 'close',
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('关闭事件：1'), findsOneWidget);
  });

  testWidgets('noticeBar page link opens the completed tag route',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => pushExampleRoute(
              context,
              findExampleRoute('componentsB/noticeBar/noticeBar'),
            ),
            child: const Text('打开通知栏'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开通知栏'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.ensureVisible(find.byKey(const ValueKey('notice-page-link')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('notice-page-link')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(
      find.byKey(const ValueKey('example-page-componentsB/tag/tag')),
      findsOneWidget,
    );
  });

  testWidgets('progress page increments the source manual percentage',
      (tester) async {
    await tester
        .pumpWidget(buildRouteUnderTest('componentsB/progress/progress'));

    expect(find.text('自定义样式(不支持安卓环境的nvue)'), findsOneWidget);
    expect(find.text('70%'), findsOneWidget);
    await tester
        .ensureVisible(find.byKey(const ValueKey('progress-page-manual')));
    await tester.pump();
    expect(find.text('手动值：50'), findsOneWidget);
    await tester.tap(find.text('增加'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('手动值：60'), findsOneWidget);
  });

  testWidgets('tabbar page updates the source basic selection', (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsB/tabbar/tabbar'));

    expect(find.text('基础功能'), findsOneWidget);
    expect(find.text('基础值：0'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('tabbar-page-basic')),
        matching: find.text('放映厅'),
      ),
    );
    await tester.pump();
    expect(find.text('基础值：1'), findsOneWidget);
  });

  testWidgets('tabbar page intercepts the second source tab', (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsB/tabbar/tabbar'));

    await tester.ensureVisible(
      find.byKey(const ValueKey('tabbar-page-intercept')),
    );
    await tester.pump();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('tabbar-page-intercept')),
        matching: find.text('放映厅'),
      ),
    );
    await tester.pump();
    expect(find.text('请您先登录'), findsOneWidget);
    expect(find.text('拦截值：0'), findsOneWidget);
    UPToast.hide();
  });

  testWidgets('tabbar-vue page updates the source dot style tab',
      (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsB/tabbar/tabbar2'));

    await tester.ensureVisible(find.byKey(const ValueKey('tabbar2-page-dot')));
    await tester.pump();
    expect(find.text('圆点值：0'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('tabbar2-page-dot')),
        matching: find.text('图片'),
      ),
    );
    await tester.pump();
    expect(find.text('圆点值：1'), findsOneWidget);
  });

  testWidgets('waterfall page removes the source product card', (tester) async {
    await tester
        .pumpWidget(buildRouteUnderTest('componentsB/waterfall/waterfall'));

    expect(find.text('商品数量：10'), findsOneWidget);
    await tester.tap(
      find
          .byWidgetPredicate(
            (widget) => widget is UPIcon && widget.name == 'close-circle-fill',
          )
          .first,
    );
    await tester.pump();
    expect(find.text('商品数量：9'), findsOneWidget);
  });

  testWidgets('waterfall page loads another deterministic source batch',
      (tester) async {
    await tester
        .pumpWidget(buildRouteUnderTest('componentsB/waterfall/waterfall'));

    expect(find.text('商品数量：10'), findsOneWidget);
    await tester.ensureVisible(find.text('加载更多'));
    await tester.pump();
    await tester.tap(find.text('加载更多'));
    await tester.pump();
    expect(find.text('商品数量：20'), findsOneWidget);
  });
}
