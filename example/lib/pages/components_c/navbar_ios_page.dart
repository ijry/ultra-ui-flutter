import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

class NavbarIosPage extends StatefulWidget {
  const NavbarIosPage({super.key});

  @override
  State<NavbarIosPage> createState() => _NavbarIosPageState();
}

class _NavbarIosPageState extends State<NavbarIosPage> {
  final ScrollController _controller = ScrollController();
  double _scrollTop = 0;

  /// Source builds 30 rows so there is enough travel to collapse the title.
  static final List<String> _cells =
      List<String>.generate(30, (i) => '列表项 ${i + 1}');

  @override
  void initState() {
    super.initState();
    // ios mode requires the *page* to feed its scroll offset to the navbar;
    // the source comments that the component cannot read page-level scroll on
    // its own, and the same is true here — UPNavbar takes scrollTop as a prop.
    _controller.addListener(() {
      final next = _controller.offset;
      if (next != _scrollTop) setState(() => _scrollTop = next);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: 'iOS 大标题',
      // The navbar is the page header here, and the list owns the scrolling, so
      // this page supplies its own scroll view rather than nesting in one.
      scrollable: false,
      child: Container(
        key: const ValueKey('example-page-componentsC/navbarIos/navbarIos'),
        color: tokens.pageBgColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            UPNavbar(
              key: const ValueKey('navbar-ios-page-navbar'),
              mode: 'ios',
              title: '设置',
              scrollTop: _scrollTop,
              autoBack: true,
              rightIcon: 'search',
              safeAreaInsetTop: false,
              fixed: false,
            ),
            Expanded(
              child: ListView(
                controller: _controller,
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 40),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 16),
                    child: Text(
                      '向下滚动，观察大标题被压缩进导航栏，标题过渡为居中形态并出现磨砂背景。',
                      style: TextStyle(
                        fontSize: 13,
                        color: tokens.tipsColor,
                      ),
                    ),
                  ),
                  for (final cell in _cells)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      decoration: BoxDecoration(
                        color: tokens.cardBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        cell,
                        style: TextStyle(
                          fontSize: 15,
                          color: tokens.mainColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
