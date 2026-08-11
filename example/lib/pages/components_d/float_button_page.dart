import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

const _menuItems = <Map<String, String>>[
  {
    'key': 'plus',
    'name': 'plus',
    'color': '#fff',
    'backgroundColor': 'red',
  },
  {
    'key': 'order',
    'name': 'order',
    'color': '#fff',
    'backgroundColor': 'green',
  },
];

class FloatButtonPage extends StatefulWidget {
  const FloatButtonPage({super.key});

  @override
  State<FloatButtonPage> createState() => _FloatButtonPageState();
}

class _FloatButtonPageState extends State<FloatButtonPage> {
  String _menuMessage = '';
  bool _menuOpen = false;
  UPFloatButtonState? _menuState;

  Widget _customMenu() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _FloatMenuItem(color: Colors.red, icon: 'plus'),
        SizedBox(width: 8),
        _FloatMenuItem(color: Colors.green, icon: 'order'),
      ],
    );
  }

  Widget _menuHitTargets() {
    return Positioned(
      top: 0,
      right: 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _menuItems.length; i++)
            Padding(
              key: ValueKey('up-float-item-$i'),
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: GestureDetector(
                onTap: () => _menuState?.itemClick(i),
                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: UPUtils.parseColor(
                      _menuItems[i]['backgroundColor'],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: UPIcon(
                    name: _menuItems[i]['name']!,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '悬浮按钮',
      child: Container(
        key: const ValueKey('example-page-componentsD/floatButton/floatButton'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '基础功能',
              child: SizedBox(
                height: 180,
                child: Stack(
                  children: [
                    if (_menuOpen) _menuHitTargets(),
                    UPFloatButton(
                      key: const ValueKey('float-button-page-menu'),
                      isMenu: true,
                      top: '120px',
                      list: _menuItems,
                      listSlot: const SizedBox.shrink(),
                      child: Builder(
                        builder: (context) {
                          _menuState = context
                              .findAncestorStateOfType<UPFloatButtonState>();
                          return const KeyedSubtree(
                            key: ValueKey('float-button-page-menu-trigger'),
                            child: UPIcon(
                              name: 'plus',
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                      onClick: () => setState(() => _menuOpen = !_menuOpen),
                      onItemClick: (item, _) => setState(
                        () => _menuMessage = '菜单点击：${item['key']}',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '自定义插槽',
              child: SizedBox(
                height: 180,
                child: Stack(
                  children: [
                    UPFloatButton(
                      isMenu: true,
                      right: '150px',
                      top: '30px',
                      listSlot: _customMenu(),
                      child: const UPIcon(
                        name: 'plus',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                _menuMessage.isEmpty ? '菜单点击：' : _menuMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatMenuItem extends StatelessWidget {
  const _FloatMenuItem({
    required this.color,
    required this.icon,
  });

  final Color color;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: UPIcon(name: icon, color: Colors.white, size: 18),
    );
  }
}
