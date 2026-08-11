import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class NavbarMiniPage extends StatefulWidget {
  const NavbarMiniPage({super.key});

  @override
  State<NavbarMiniPage> createState() => _NavbarMiniPageState();
}

class _NavbarMiniPageState extends State<NavbarMiniPage> {
  int _leftCount = 0;

  void _recordLeftClick() {
    if (!mounted) return;
    setState(() => _leftCount += 1);
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '迷你导航栏',
      child: Container(
        key: const ValueKey('example-page-componentsD/navbarMini/navbarMini'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '基础功能',
              child: Column(
                children: <Widget>[
                  UPNavbarMini(
                    key: const ValueKey('navbar-mini-page-basic'),
                    safeAreaInsetTop: true,
                    fixed: true,
                    autoBack: true,
                    leftSlot: const KeyedSubtree(
                      key: ValueKey('navbar-mini-page-left'),
                      child: UPIcon(name: 'arrow-leftward', size: 20),
                    ),
                    onLeftClick: _recordLeftClick,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Text('左侧点击：$_leftCount'),
                  ),
                ],
              ),
            ),
            ExampleDemoBlock(
              title: '自定义插槽',
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: UPNavbarMini(
                  key: const ValueKey('navbar-mini-page-custom'),
                  fixed: false,
                  safeAreaInsetTop: false,
                  leftSlot: const UPIcon(name: 'arrow-left', size: 19),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
