import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../../routes/example_catalog.dart';
import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class NavbarPage extends StatefulWidget {
  const NavbarPage({super.key});

  @override
  State<NavbarPage> createState() => _NavbarPageState();
}

class _NavbarPageState extends State<NavbarPage> {
  int _leftClicks = 0;
  int _rightClicks = 0;

  void _onLeftClick() {
    setState(() => _leftClicks += 1);
  }

  void _onRightClick() {
    setState(() => _rightClicks += 1);
  }

  Widget _customLeftSlot() {
    final tokens = UPThemeTokens.of(context);
    return Opacity(
      opacity: 0.8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          border: Border.all(color: tokens.borderColor, width: 0.5),
          borderRadius: BorderRadius.circular(100),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            UPIcon(name: 'arrow-left', size: 19),
            UPLine(
              direction: 'column',
              hairline: false,
              length: 16,
              margin: '0 8px',
            ),
            UPIcon(name: 'home', size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '导航栏',
      child: Container(
        key: const ValueKey('example-page-componentsC/navbar/navbar'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const UPNavbar(
              title: '导航栏',
              safeAreaInsetTop: true,
              fixed: true,
              placeholder: true,
              autoBack: true,
            ),
            ExampleDemoBlock(
              title: 'iOS 大标题模式',
              // Source links out to its own navbarIos page rather than demoing
              // the mode inline: ios mode needs page-level scroll to drive it.
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: UPButton(
                  key: const ValueKey('navbar-page-ios-link'),
                  type: 'primary',
                  text: '查看 iOS 模式示例',
                  onClick: () => pushExampleRoute(
                    context,
                    findExampleRoute('componentsC/navbarIos/navbarIos'),
                  ),
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '基础功能',
              child: Column(
                children: <Widget>[
                  UPNavbar(
                    title: '个人中心',
                    safeAreaInsetTop: false,
                    fixed: false,
                    leftSlot: const SizedBox(
                      key: ValueKey('navbar-page-left'),
                      child: UPIcon(name: 'arrow-left'),
                    ),
                    onLeftClick: _onLeftClick,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('左侧点击：$_leftClicks'),
                  ),
                ],
              ),
            ),
            ExampleDemoBlock(
              title: '自定义文本',
              child: Column(
                children: <Widget>[
                  UPNavbar(
                    title: '个人中心',
                    safeAreaInsetTop: false,
                    fixed: false,
                    leftText: '返回',
                    rightIcon: 'map',
                    rightSlot: const SizedBox(
                      key: ValueKey('navbar-page-right'),
                      child: UPIcon(name: 'map', size: 20),
                    ),
                    onRightClick: _onRightClick,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('右侧点击：$_rightClicks'),
                  ),
                ],
              ),
            ),
            ExampleDemoBlock(
              title: '自定义插槽',
              child: UPNavbar(
                title: '个人中心',
                safeAreaInsetTop: false,
                fixed: false,
                leftText: '返回',
                leftSlot: _customLeftSlot(),
              ),
            ),
            const UPGap(height: 50),
          ],
        ),
      ),
    );
  }
}
