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

  testWidgets('steps page renders source variants', (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsC/steps/steps'));

    expect(find.text('基础演示'), findsOneWidget);
    expect(find.text('显示点类型'), findsOneWidget);
    expect(find.text('错误状态'), findsOneWidget);
    expect(find.text('自定义图标'), findsOneWidget);
    expect(find.text('自定义插槽'), findsOneWidget);
    expect(find.text('自定义颜色'), findsOneWidget);
    expect(find.text('竖向展示'), findsOneWidget);
    expect(find.text('运'), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) => widget is UPStepsItem && widget.error),
      findsOneWidget,
    );
  });

  testWidgets('navbar page renders source variants and callbacks',
      (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsC/navbar/navbar'));

    expect(find.text('基础功能'), findsOneWidget);
    expect(find.text('自定义文本'), findsOneWidget);
    expect(find.text('自定义插槽'), findsOneWidget);
    expect(find.text('个人中心'), findsNWidgets(3));
    expect(find.text('返回'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('navbar-page-left')));
    await tester.pump();
    expect(find.text('左侧点击：1'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('navbar-page-right')));
    await tester.pump();
    expect(find.text('右侧点击：1'), findsOneWidget);
  });

  testWidgets('skeleton page toggles source loading state', (tester) async {
    await tester
        .pumpWidget(buildRouteUnderTest('componentsC/skeleton/skeleton'));

    expect(find.text('基础使用'), findsOneWidget);
    expect(find.text('自定义段落行数'), findsOneWidget);
    expect(find.text('设置段落宽度'), findsOneWidget);
    expect(find.text('设置段落高度'), findsOneWidget);
    expect(find.text('是否开启动画'), findsOneWidget);
    expect(find.text('展示头像'), findsOneWidget);
    expect(find.text('切换状态'), findsOneWidget);
    expect(find.text('利剑出鞘,一统江湖'), findsNothing);

    final loadingSwitch =
        find.byKey(const ValueKey('skeleton-page-loading-switch'));
    await tester.ensureVisible(loadingSwitch);
    await tester.pump();
    await tester.tap(loadingSwitch);
    await tester.pump();
    expect(find.text('利剑出鞘,一统江湖'), findsOneWidget);
  });

  testWidgets('input page edits, filters, clears, and confirms source values',
      (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsC/input/input'));

    expect(find.text('基础使用'), findsOneWidget);
    expect(find.text('前后插槽'), findsOneWidget);

    final basic = find.descendant(
      of: find.byKey(const ValueKey('input-page-basic')),
      matching: find.byType(TextField),
    );
    await tester.enterText(basic, 'hello');
    await tester.pump();
    expect(find.text('基础值：hello'), findsOneWidget);

    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    expect(find.text('确认：hello'), findsOneWidget);

    final number = find.descendant(
      of: find.byKey(const ValueKey('input-page-number')),
      matching: find.byType(TextField),
    );
    await tester.enterText(number, '12a3');
    await tester.pump();
    expect(find.text('数字值：123'), findsOneWidget);

    final passwordState = tester.state<UPInputState>(
      find.byKey(const ValueKey('input-page-password')),
    );
    expect(passwordState.isPassword(), isTrue);
    passwordState.setValue('secret');
    passwordState.onClear();
    await tester.pump();
    expect(passwordState.value, isEmpty);
    UPToast.hide();
  });

  testWidgets('album page renders source variants and previews an image',
      (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsC/album/album'));

    expect(find.text('基础使用'), findsOneWidget);
    expect(find.text('多图模式'), findsOneWidget);
    expect(find.text('图文对齐'), findsOneWidget);
    expect(find.text('更改裁剪模式'), findsOneWidget);
    expect(find.text('更改图片大小'), findsOneWidget);
    expect(find.text('自定义圆角'), findsOneWidget);
    expect(find.text('自定义形状'), findsOneWidget);
    expect(find.text('自适应自动换行'), findsOneWidget);

    final multi = tester.widget<UPAlbum>(
      find.byKey(const ValueKey('album-page-multiple')),
    );
    expect(multi.urls, hasLength(10));
    expect(multi.maxCount, 9);

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('album-page-basic')),
        matching: find.byType(UPImage),
      ),
    );
    await tester.pump();
    expect(find.textContaining('预览：'), findsOneWidget);
  });

  testWidgets('avatar page renders source variants and reports clicks',
      (tester) async {
    await tester.pumpWidget(
      buildRouteUnderTest('componentsC/avatar/avatar'),
    );

    expect(find.text('基础演示'), findsOneWidget);
    expect(find.text('头像形状'), findsOneWidget);
    expect(find.text('头像尺寸'), findsOneWidget);
    expect(find.text('图标头像'), findsOneWidget);
    expect(find.text('文字头像(自动背景色)'), findsOneWidget);
    expect(find.text('图片加载失败(显示默认头像)'), findsOneWidget);
    expect(find.text('头像组'), findsOneWidget);

    final group = tester.widget<UPAvatarGroup>(
      find.byKey(const ValueKey('avatar-page-group-wide')),
    );
    expect(group.urls, hasLength(7));
    expect(group.gap, 0.4);

    await tester.tap(find.byKey(const ValueKey('avatar-page-clickable')));
    await tester.pump();
    expect(find.text('点击次数：1'), findsOneWidget);
  });

  testWidgets('read more page expands and closes parsed content',
      (tester) async {
    await tester.pumpWidget(
      buildRouteUnderTest('componentsC/readMore/readMore'),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('状态：close'), findsOneWidget);
    expect(find.text('展开阅读全文'), findsOneWidget);

    await tester.tap(find.text('展开阅读全文'));
    await tester.pump();
    expect(find.text('状态：open'), findsOneWidget);
    expect(find.text('展开次数：1'), findsOneWidget);
    expect(find.text('收起'), findsOneWidget);

    await tester.tap(find.text('收起'));
    await tester.pump();
    expect(find.text('状态：close'), findsOneWidget);
    expect(find.text('收起次数：1'), findsOneWidget);
  });

  testWidgets('layout page renders source layout sections and parameters',
      (tester) async {
    await tester.pumpWidget(
      buildRouteUnderTest('componentsC/layout/layout'),
    );

    expect(find.text('基础使用'), findsOneWidget);
    expect(find.text('分栏间隔'), findsOneWidget);
    expect(find.text('混合布局'), findsOneWidget);
    expect(find.text('分栏偏移'), findsOneWidget);
    expect(find.text('对齐方式'), findsOneWidget);

    final gutterRow = tester.widget<UPRow>(
      find.byKey(const ValueKey('layout-page-gutter-row')),
    );
    expect(gutterRow.gutter, 10);

    final offsetCol = tester.widget<UPCol>(
      find.byKey(const ValueKey('layout-page-offset-col')),
    );
    expect(offsetCol.span, 3);
    expect(offsetCol.offset, 3);
  });

  testWidgets('index list page renders contacts and opens popup page',
      (tester) async {
    await tester.pumpWidget(
      buildRouteUnderTest('componentsC/indexList/indexList'),
    );

    expect(find.text('新的朋友'), findsOneWidget);
    expect(find.text('标签'), findsOneWidget);
    expect(find.text('朋友圈'), findsOneWidget);
    expect(find.text('QQ'), findsOneWidget);
    expect(find.text('A'), findsWidgets);
    expect(find.text('#'), findsWidgets);

    final indexList = tester.state<UPIndexListState>(
      find.byKey(const ValueKey('index-list-page-widget')),
    );
    await indexList.jumpToLetter('C');
    await tester.pump();
    expect(indexList.activeLetter, 'C');

    indexList.scrollTo(99999);
    await tester.pump();
    expect(find.text('共305位好友'), findsOneWidget);

    indexList.scrollToTop();
    await tester.pump();
    final newFriend = find.byKey(
      const ValueKey('index-list-page-new-friend'),
    );
    await tester.ensureVisible(newFriend);
    await tester.tap(newFriend);
    await tester.pumpAndSettle();
    expect(find.text('索引列表(弹窗)'), findsOneWidget);
  });

  testWidgets('index list2 page opens and closes its popup', (tester) async {
    await tester.pumpWidget(
      buildRouteUnderTest('componentsC/indexList/indexList2'),
    );

    expect(find.text('打开弹窗'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('index-list2-page-content')),
      findsNothing,
    );

    await tester.tap(find.byKey(const ValueKey('index-list2-page-open')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('index-list2-page-content')),
      findsOneWidget,
    );
    final popupIndexList = tester.state<UPIndexListState>(
      find.byType(UPIndexList),
    );
    await popupIndexList.jumpToLetter('C');
    await tester.pump();
    expect(popupIndexList.activeLetter, 'C');

    final popup = tester.state<UPPopupState>(
      find.byKey(const ValueKey('index-list2-page-popup')),
    );
    popup.close();
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('index-list2-page-content')),
      findsNothing,
    );
  });

  testWidgets(
    'tooltip page opens custom trigger and records extension action',
    (tester) async {
      await tester.pumpWidget(
        buildRouteUnderTest('componentsC/tooltip/tooltip'),
      );

      expect(find.text('基础使用'), findsOneWidget);
      expect(find.text('单例打开'), findsOneWidget);
      expect(find.text('自定义触发器'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('tooltip-page-custom-trigger')),
      );
      await tester.pump();
      expect(find.text('自定义内容'), findsOneWidget);

      final extension = tester.state<UPTooltipState>(
        find.byKey(const ValueKey('tooltip-page-extension')),
      );
      extension.open();
      await tester.pump();
      await tester.tap(find.text('扩展').last);
      await tester.pump();
      expect(find.text('扩展点击：1'), findsOneWidget);
    },
  );

  testWidgets('guide page runs the first-entry flow and can reset it',
      (tester) async {
    const storageKey = 'components-c-batch4-guide';
    UPGuide.clearRemembered(storageKey);
    addTearDown(() => UPGuide.clearRemembered(storageKey));

    await tester.pumpWidget(buildRouteUnderTest('componentsC/guide/guide'));
    await tester.pump();

    final guide = tester.state<UPGuideState>(
      find.byKey(const ValueKey('guide-page-widget')),
    );
    expect(guide.isOpen, isTrue);
    expect(find.text('欢迎使用 uview-plus'), findsOneWidget);

    await tester.tap(find.text('下一步'));
    await tester.pump(const Duration(milliseconds: 320));
    await tester.pump(const Duration(milliseconds: 320));
    expect(find.text('引导页支持多页滑动'), findsOneWidget);

    await tester.tap(find.text('下一步'));
    await tester.pump(const Duration(milliseconds: 320));
    await tester.pump(const Duration(milliseconds: 320));
    expect(find.text('只显示一次'), findsOneWidget);

    await tester.tap(find.text('立即体验'));
    await tester.pump();
    expect(guide.isOpen, isFalse);
    expect(find.text('完成次数：1'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('guide-page-reset')));
    await tester.pump();
    expect(find.text('重置次数：1'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('guide-page-open')));
    await tester.pump();
    expect(guide.isOpen, isTrue);
  });

  testWidgets('popover page opens custom content and closes', (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsC/popover/popover'));

    expect(find.text('右侧弹出'), findsOneWidget);
    expect(find.text('左侧弹出及强制定位'), findsOneWidget);
    expect(find.text('自定义内容'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('popover-page-right-trigger')),
    );
    await tester.pump();
    expect(find.text('自定义内容'), findsOneWidget);
    expect(find.text('打开次数：1'), findsOneWidget);

    final popover = tester.state<UPPopoverState>(
      find.byKey(const ValueKey('popover-page-right')),
    );
    popover.close();
    await tester.pump();
    expect(find.text('自定义内容'), findsNothing);
    expect(find.text('关闭次数：1'), findsOneWidget);
  });

  testWidgets('tabs page changes selection and renders source variants',
      (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsC/tabs/tabs'));

    expect(find.text('基础演示'), findsOneWidget);
    expect(find.text('粘性布局'), findsOneWidget);
    expect(find.text('显示徽标'), findsOneWidget);
    expect(find.text('胶囊模式'), findsOneWidget);
    expect(find.text('卡片模式'), findsOneWidget);
    expect(find.text('圆角矩形箭头模式'), findsOneWidget);
    expect(find.text('Tag模式'), findsOneWidget);

    final basic = tester.state<UPTabsState>(
      find.byKey(const ValueKey('tabs-page-basic')),
    );
    basic.setCurrent(2);
    await tester.pump();
    expect(find.text('当前索引：2'), findsOneWidget);
    expect(find.text('点击次数：1'), findsOneWidget);

    final disabled = find.byKey(const ValueKey('tabs-page-disabled'));
    await tester.tap(find.descendant(of: disabled, matching: find.text('电影')));
    await tester.pump();
    expect(find.text('当前索引：2'), findsOneWidget);

    final nextButton = find.byKey(const ValueKey('tabs-page-next'));
    await tester.ensureVisible(nextButton);
    await tester.pump();
    await tester.tap(nextButton);
    await tester.pump();
    expect(find.text('当前索引：3'), findsOneWidget);
  });

  testWidgets('list page appends deterministic rows at the lower edge',
      (tester) async {
    await tester.pumpWidget(buildRouteUnderTest('componentsC/list/list'));
    await tester.pump();

    expect(find.text('列表长度-1'), findsOneWidget);
    expect(find.text('列表长度-10'), findsOneWidget);
    expect(find.text('列表数量：10'), findsOneWidget);

    final list = tester.state<UPListState>(
      find.byKey(const ValueKey('list-page-widget')),
    );
    list.scrollToBottom();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    await tester.pump();
    expect(find.text('列表长度-20'), findsOneWidget);
    expect(find.text('列表数量：20'), findsOneWidget);
  });
}
