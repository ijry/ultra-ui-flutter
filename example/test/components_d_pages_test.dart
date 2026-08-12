import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../lib/pages/components_d/copy_page.dart';
import '../lib/pages/components_d/box_page.dart';
import '../lib/pages/components_d/cate_tab_page.dart';
import '../lib/pages/components_d/float_button_page.dart';
import '../lib/pages/components_d/navbar_mini_page.dart';
import '../lib/pages/components_d/pagination_page.dart';
import '../lib/pages/components_d/qrcode_page.dart';
import '../lib/pages/components_d/select_page.dart';

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
}
