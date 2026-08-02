import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

import 'example_test_helpers.dart';

void main() {
  testWidgets('form page selects sex and reports validation state',
      (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsC/form/form'));

    expect(find.text('基础使用'), findsOneWidget);
    expect(find.text('姓名：楼兰'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('form-page-sex-trigger')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('女'));
    await tester.pump();
    expect(find.text('性别：女'), findsOneWidget);

    await tester.ensureVisible(find.text('提交'));
    await tester.pump();
    await tester.tap(find.text('提交'));
    await tester.pump();
    expect(find.text('提交状态：校验失败'), findsOneWidget);

    final form = tester.state<UPFormState>(find.byType(UPForm));
    form.setModelValue('userInfo.name', '楼兰');
    form.setModelValue('userInfo.sex', '女');
    form.setModelValue('userInfo.age', '20');
    form.setModelValue('radiovalue1', '苹果');
    form.setModelValue('checkboxValue1', <String>['羽毛球', '跑步']);
    form.setModelValue('intro', '这是简介');
    form.setModelValue('hotel', '2026-08-01 / 2026-08-02');
    form.setModelValue('code', '1234');
    form.setModelValue('userInfo.birthday', '2000-01-01');
    await tester.ensureVisible(find.text('提交'));
    await tester.pump();
    await tester.tap(find.text('提交'));
    await tester.pump();
    await tester.pump();
    expect(find.text('提交状态：校验通过'), findsOneWidget);

    await tester.ensureVisible(find.text('重置'));
    await tester.pump();
    await tester.tap(find.text('重置'));
    await tester.pump();
    expect(find.text('姓名：楼兰'), findsOneWidget);
    expect(find.text('提交状态：已重置'), findsOneWidget);
    UPToast.hide();
  });

  testWidgets('textarea page edits the source basic value', (tester) async {
    await tester
        .pumpWidget(buildRouteUnderTest('componentsC/textarea/textarea'));

    expect(find.text('字数统计'), findsOneWidget);
    final basicField = find.descendant(
      of: find.byKey(const ValueKey('textarea-page-basic')),
      matching: find.byType(TextField),
    );
    await tester.enterText(basicField, 'Flutter 文本域');
    await tester.pump();
    expect(find.text('基础值：Flutter 文本域'), findsOneWidget);
    expect(find.text('文本域已被禁用'), findsOneWidget);
  });

  testWidgets('noNetwork page renders normal state and retries offline panel',
      (tester) async {
    await tester
        .pumpWidget(buildRouteUnderTest('componentsC/noNetwork/noNetwork'));

    expect(find.text('网络正常'), findsOneWidget);
    expect(
      find.text('请您断开设备的WiFi和数据连接(或开启飞行模式)，即可看到效果'),
      findsOneWidget,
    );
    await tester.tap(find.text('模拟断网'));
    await tester.pump();
    expect(find.text('哎呀，网络信号丢失'), findsOneWidget);
    await tester.tap(find.text('重试'));
    await tester.pump();
    expect(find.text('重试：1'), findsOneWidget);
  });

  testWidgets('loadmore page emits the source loadmore action', (tester) async {
    await tester
        .pumpWidget(buildRouteUnderTest('componentsC/loadmore/loadmore'));

    expect(find.text('努力加载中,先喝杯茶'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('loadmore-page-clickable')),
        matching: find.text('加载更多'),
      ),
    );
    await tester.pump();
    expect(find.text('加载次数：1'), findsOneWidget);
    expect(find.text('加载更多'), findsWidgets);
    UPToast.hide();
    await tester.pump();
  });

  testWidgets('text page renders source modes and share fallback',
      (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsC/text/text'));

    expect(find.text('张*三'), findsOneWidget);
    expect(find.text('728,732.32'), findsOneWidget);
    expect(find.text('百度一下'), findsOneWidget);
    expect(find.text('查看更多'), findsOneWidget);

    await tester.ensureVisible(find.text('分享到微信'));
    await tester.pump();
    await tester.tap(find.text('分享到微信'));
    await tester.pump();
    expect(find.text('请在微信小程序内查看效果'), findsOneWidget);
    UPToast.hide();
    await tester.pump();
  });
}
