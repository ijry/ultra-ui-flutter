import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../lib/pages/components_d/copy_page.dart';
import '../lib/pages/components_d/box_page.dart';
import '../lib/pages/components_d/cate_tab_page.dart';
import '../lib/pages/components_d/city_locate_page.dart';
import '../lib/pages/components_d/dragsort_page.dart';
import '../lib/pages/components_d/float_button_page.dart';
import '../lib/pages/components_d/navbar_mini_page.dart';
import '../lib/pages/components_d/pagination_page.dart';
import '../lib/pages/components_d/pull_refresh_page.dart';
import '../lib/pages/components_d/qrcode_page.dart';
import '../lib/pages/components_d/select_page.dart';
import '../lib/pages/components_d/title_page.dart';
import '../lib/pages/components_d/tree_page.dart';
import '../lib/pages/components_d/virtual_list_page.dart';

void main() {
  testWidgets('qrcode page renders source variants offline', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: const QrcodePage(),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('example-page-componentsD/qrcode/qrcode')),
      findsOneWidget,
    );
    expect(find.text('不带logo'), findsOneWidget);
    expect(find.text('带logo'), findsOneWidget);
    expect(find.text('二维码颜色'), findsOneWidget);
    expect(find.byType(UPQrcode), findsNWidgets(3));
    expect(find.byKey(const ValueKey('qrcode-page-logo')), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('copy page reports successful text and button copies',
      (tester) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') return null;
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
      UPToast.hide();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: const CopyPage(),
      ),
    );

    expect(find.text('点击文字复制'), findsOneWidget);
    expect(find.text('点击按钮复制'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('copy-page-text')));
    await tester.pump();
    expect(find.text('复制次数：1'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('copy-page-button')));
    await tester.pump();
    expect(find.text('复制次数：2'), findsOneWidget);
    UPToast.hide();
    await tester.pump();
  });

  testWidgets('navbar mini page invokes its source left callback',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: const NavbarMiniPage(),
      ),
    );

    expect(find.text('基础功能'), findsOneWidget);
    expect(find.text('自定义插槽'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('navbar-mini-page-left')));
    await tester.pump();
    expect(find.text('左侧点击：1'), findsOneWidget);
  });

  testWidgets('box page renders default and custom slots', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: const BoxPage(),
      ),
    );

    expect(find.text('基础功能'), findsOneWidget);
    expect(find.text('自定义插槽'), findsOneWidget);
    expect(find.byKey(const ValueKey('box-page-basic')), findsOneWidget);
    expect(find.byKey(const ValueKey('box-page-custom')), findsOneWidget);
    expect(find.byType(UPIcon), findsNWidgets(3));
  });

  testWidgets('float button page opens menu and emits item click',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: const FloatButtonPage(),
      ),
    );

    final state = tester.state<UPFloatButtonState>(
      find.byKey(const ValueKey('float-button-page-menu')),
    );
    expect(state.isOpen, isFalse);
    await tester.tap(
      find.byKey(const ValueKey('float-button-page-menu-trigger')),
    );
    await tester.pump();
    expect(state.isOpen, isTrue);
    expect(find.byKey(const ValueKey('up-float-item-0')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('up-float-item-0')));
    await tester.pump();
    expect(find.text('菜单点击：plus'), findsOneWidget);
  });

  testWidgets('cate tab page switches local categories', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: const CateTabPage(),
      ),
    );

    expect(
      find.byKey(const ValueKey('example-page-componentsD/cateTab/cateTab')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('cate-tab-page-follow')), findsOneWidget);
    expect(find.byKey(const ValueKey('cate-tab-page-tab')), findsOneWidget);
    expect(find.text('食品'), findsWidgets);
    expect(find.text('米饭'), findsWidgets);

    final follow = find.byKey(const ValueKey('cate-tab-page-follow'));
    final secondMenu = find.descendant(
      of: follow,
      matching: find.byKey(const ValueKey('up-cate-tab-left-1')),
    );
    expect(secondMenu, findsOneWidget);
    expect(tester.getCenter(secondMenu).dy, greaterThan(0));
    await tester.tap(secondMenu);
    await tester.pumpAndSettle();
    expect(find.text('当前分类：饮料'), findsOneWidget);
    expect(find.text('分类变化次数：1'), findsOneWidget);
  });

  testWidgets('select page opens and selects an option', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: const SelectPage(),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('select-page-trigger')));
    await tester.pumpAndSettle();
    expect(
        find.byKey(const ValueKey('up-select-options-panel')), findsOneWidget);
    expect(find.text('选项二'), findsOneWidget);
    await tester.tap(find.text('选项二'));
    await tester.pumpAndSettle();
    expect(find.text('当前选择：选项二'), findsOneWidget);
    expect(find.byKey(const ValueKey('up-select-options-panel')), findsNothing);
  });

  testWidgets('pagination page changes page and page size', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: const PaginationPage(),
      ),
    );

    expect(find.byKey(const ValueKey('pagination-page-basic')), findsOneWidget);
    await tester.tap(find.text('2').first);
    await tester.pump();
    expect(find.text('当前页：2'), findsOneWidget);

    await tester.tap(find.text('20条/页'));
    await tester.pump();
    expect(find.text('每页：20'), findsOneWidget);
  });

  testWidgets('tree page expands and cascades checked children',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: const TreePage(),
      ),
    );

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('tree-page-checkbox')),
        matching: find.text('子节点一'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('up-tree-checkbox-root')));
    await tester.pump();
    expect(
      find.text('已选：root,child-1,grandchild-1,child-2'),
      findsOneWidget,
    );
    expect(find.textContaining('disabled'), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('tree-page-checkbox')),
        matching: find.text('禁用节点'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('dragsort page reorders with a real drag gesture',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: const DragsortPage(),
      ),
    );

    final first = find.byKey(const ValueKey('dragsort-page-item-0'));
    final second = find.byKey(const ValueKey('dragsort-page-item-1'));
    final firstHandle = find.byKey(const ValueKey('dragsort-page-handle-0'));
    final dragState = tester.state<UPDragSortState>(
      find.byKey(const ValueKey('dragsort-page-basic')),
    );
    expect(first, findsOneWidget);
    expect(second, findsOneWidget);
    expect(firstHandle, findsOneWidget);
    final gesture = await tester.startGesture(tester.getCenter(firstHandle));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveBy(const Offset(0, 20));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveBy(const Offset(0, 60));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveBy(const Offset(0, 60));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(dragState.value, <String>['第二项', '第一项', '第三项']);
    expect(find.text('排序：第二项,第一项,第三项'), findsOneWidget);
  });

  testWidgets('city locate page resolves local location and selects a city',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: const CityLocatePage(),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(
      find.byKey(
        const ValueKey('example-page-componentsD/cityLocate/cityLocate'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('city-locate-page-basic')),
      findsOneWidget,
    );
    expect(find.text('当前定位：南京'), findsOneWidget);

    final shanghai = find.descendant(
      of: find.byKey(const ValueKey('city-locate-page-basic')),
      matching: find.text('上海'),
    );
    expect(shanghai, findsWidgets);
    await tester.tap(shanghai.first);
    await tester.pump();

    expect(find.text('已选择：上海'), findsOneWidget);
  });

  testWidgets('title page renders source default and custom prefix variants',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: const TitlePage(),
      ),
    );

    expect(
      find.byKey(const ValueKey('example-page-componentsD/title/title')),
      findsOneWidget,
    );
    expect(find.text('默认'), findsOneWidget);
    expect(find.text('自定义前缀'), findsOneWidget);
    expect(find.byKey(const ValueKey('title-page-default')), findsOneWidget);
    expect(find.byKey(const ValueKey('title-page-prefix')), findsOneWidget);
    expect(find.text('默认标题'), findsOneWidget);
    expect(find.text('等级3'), findsOneWidget);
    expect(find.byType(UPTitle), findsNWidgets(2));
    expect(find.byType(UPIcon), findsOneWidget);
  });

  testWidgets('pull refresh page responds to a real downward drag',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: const PullRefreshPage(),
      ),
    );

    expect(
      find.byKey(
        const ValueKey('example-page-componentsD/pullRefresh/pullRefresh'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('pull-refresh-page-basic')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('pull-refresh-page-custom')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('pull-refresh-page-virtual')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('pull-refresh-page-loadmore')),
      findsOneWidget,
    );

    final basic = find.byKey(const ValueKey('pull-refresh-page-basic'));
    final gesture = await tester.startGesture(tester.getCenter(basic));
    await gesture.moveBy(const Offset(0, 160));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(find.text('基础刷新次数：1'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('virtual list page scrolls real visible rows', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: const VirtualListPage(),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(
        const ValueKey('example-page-componentsD/virtualList/virtualList'),
      ),
      findsOneWidget,
    );
    final list = find.byKey(const ValueKey('virtual-list-page-basic'));
    expect(list, findsOneWidget);
    expect(find.text('Item 0'), findsOneWidget);

    await tester.drag(list, const Offset(0, -420));
    await tester.pump();

    expect(find.text('Item 8'), findsWidgets);
    expect(
      find.byKey(const ValueKey('virtual-list-page-result')),
      findsOneWidget,
    );
    expect(find.textContaining('滚动位置：'), findsOneWidget);
  });
}
