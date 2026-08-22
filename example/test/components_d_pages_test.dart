import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../lib/pages/components_d/barcode_page.dart';
import '../lib/pages/components_d/copy_page.dart';
import '../lib/pages/components_d/box_page.dart';
import '../lib/pages/components_d/cate_tab_page.dart';
import '../lib/pages/components_d/city_locate_page.dart';
import '../lib/pages/components_d/dragsort_page.dart';
import '../lib/pages/components_d/float_button_page.dart';
import '../lib/pages/components_d/novel_reader_page.dart';
import '../lib/pages/components_d/root_toast_host_page.dart';
import '../lib/pages/components_d/tabs_pro_page.dart';
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

    await tester.tap(find.byKey(const ValueKey('select-page-basic')));
    await tester.pumpAndSettle();
    expect(
        find.byKey(const ValueKey('up-select-options-panel')), findsOneWidget);
    // Source data: 分类1 / 分类2 / 分类4 (id 3 really is labelled 分类4).
    expect(find.text('分类2'), findsOneWidget);
    await tester.tap(find.text('分类2'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('up-select-options-panel')), findsNothing);
    // The trigger shows the picked label once showOptionsLabel resolves it.
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('select-page-basic')),
        matching: find.text('分类2'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('pagination page changes page and page size', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: const PaginationPage(),
      ),
    );

    expect(find.byKey(const ValueKey('pagination-page-basic')), findsOneWidget);
    // The `prev, pager, next` demo is the one with numbered pages.
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('pagination-page-pager')),
        matching: find.text('2'),
      ),
    );
    await tester.pump();
    expect(find.textContaining('当前页：2'), findsOneWidget);
  });

  testWidgets('tree page expands and cascades checked children',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: const TreePage(),
      ),
    );

    // Source check-demo data, expanded by defaultExpandAll.
    expect(find.text('Input 输入框'), findsOneWidget);
    // defaultCheckedKeys seeds the readout before any interaction.
    expect(find.text('当前选中：2-1-1'), findsOneWidget);

    // The check demo is the third block, below the 600px test viewport, so a tap
    // at its unscrolled position lands outside the view and silently does
    // nothing. Scroll it in first.
    await tester.ensureVisible(find.text('Textarea 文本域'));
    await tester.pumpAndSettle();

    // checkOnClickNode: tapping the label checks it and cascades to ancestors.
    await tester.tap(find.text('Textarea 文本域'));
    await tester.pump();
    expect(find.textContaining('2-1-2'), findsOneWidget);

    // setCheckedKeys replaces the selection wholesale.
    await tester
        .ensureVisible(find.byKey(const ValueKey('tree-page-set-checked')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('tree-page-set-checked')));
    await tester.pump();
    final readout = tester.widget<Text>(find.textContaining('当前选中：'));
    expect(readout.data, contains('2-1-2'));
    expect(readout.data, contains('2-2-1'));

    // The disabled node stays present but never becomes checked.
    expect(find.text('Picker 选择器'), findsOneWidget);
    expect(readout.data, isNot(contains('2-2-2')));
  });

  testWidgets('dragsort page reorders with a real drag gesture',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: const DragsortPage(),
      ),
    );

    final dragState = tester.state<UPDragSortState>(
      find.byKey(const ValueKey('dragsort-page-vertical')),
    );
    String labelAt(int i) => '${(dragState.value[i] as Map)['label']}';
    expect(labelAt(0), '项目 A');
    expect(labelAt(1), '项目 B');

    // Drag the first row past the second. The vertical demo has no handler
    // slot, so ReorderableListView's default drag handle is the row itself —
    // and that handle starts on a *long press*, not an immediate pan, so the
    // gesture has to dwell before moving.
    //
    // Scope the finder to this demo: 自定义拖动句柄 renders identical labels.
    final first = find.descendant(
      of: find.byKey(const ValueKey('dragsort-page-vertical')),
      matching: find.text('序号：1 - 项目 A'),
    );
    final gesture = await tester.startGesture(tester.getCenter(first));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveBy(const Offset(0, 20));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveBy(const Offset(0, 60));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveBy(const Offset(0, 60));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(labelAt(0), isNot('项目 A'),
        reason: 'the dragged row must have moved out of first place');
    expect(find.textContaining('拖拽结束，新的顺序：'), findsOneWidget);
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

  testWidgets('barcode page renders every source barcode variant',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: const BarcodePage(),
      ),
    );

    expect(
      find.byKey(const ValueKey('example-page-componentsD/barcode/barcode')),
      findsOneWidget,
    );
    expect(find.byType(UPBarcode), findsNWidgets(8));
    expect(
      find.byKey(const ValueKey('barcode-page-code128')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('barcode-page-ean5')), findsOneWidget);
    expect(find.byKey(const ValueKey('barcode-page-ean2')), findsOneWidget);
    expect(find.byKey(const ValueKey('barcode-page-custom')), findsOneWidget);
    expect(find.text('自定义样式条形码'), findsOneWidget);
    expect(find.text('CUSTOM123'), findsOneWidget);
  });

  testWidgets('tabs-pro page switches its content pane', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: const TabsProPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('example-page-componentsD/tabsPro/tabsPro')),
      findsOneWidget,
    );
    expect(find.byType(UPTabsPro), findsNWidgets(2));
    expect(find.byKey(const ValueKey('tabs-pro-page-basic')), findsOneWidget);
    expect(find.text('第 1 个面板'), findsOneWidget);
    expect(find.text('当前索引：0'), findsOneWidget);

    // Selecting another tab moves both the pane and the reported index.
    await tester.tap(find.text('热榜').first);
    await tester.pumpAndSettle();
    expect(find.text('第 3 个面板'), findsOneWidget);
    expect(find.text('当前索引：2'), findsOneWidget);
  });

  testWidgets('root-toast-host page drives toast without a local widget',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: const RootToastHostPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey(
          'example-page-componentsD/rootToastHost/rootToastHost')),
      findsOneWidget,
    );
    // The page mounts no UPToast of its own; the host supplies it.
    expect(find.text('最近调用：未调用'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('root-toast-host-page-toast')));
    await tester.pump();
    expect(find.text('最近调用：toast -> 已处理'), findsOneWidget);
    expect(find.text('来自全局宿主'), findsOneWidget);

    // Let the toast's own dismiss timer expire, or the test ends with it
    // pending.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('novel-reader page renders both reading modes', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: const NovelReaderPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(
          const ValueKey('example-page-componentsD/novelReader/novelReader')),
      findsOneWidget,
    );
    expect(find.byType(UPNovelReader), findsNWidgets(2));
    expect(
        find.byKey(const ValueKey('novel-reader-page-scroll')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('novel-reader-page-paged')), findsOneWidget);
    expect(find.text('当前章节：第一章 风起'), findsOneWidget);
    // Toolbars start hidden, per the source.
    expect(find.text('最近事件：未触发'), findsOneWidget);
  });
}
