import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../lib/pages/components_d/copy_page.dart';
import '../lib/pages/components_d/box_page.dart';
import '../lib/pages/components_d/float_button_page.dart';
import '../lib/pages/components_d/navbar_mini_page.dart';
import '../lib/pages/components_d/qrcode_page.dart';
import 'example_test_helpers.dart';

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
}
