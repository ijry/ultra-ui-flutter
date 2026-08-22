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
                    UPFloatButton(
                      key: const ValueKey('float-button-page-basic'),
                      // Source's 基础功能 is the plain button: isMenu false.
                      isMenu: false,
                      onClick: () => setState(() => _menuMessage = '按钮点击'),
                    ),
                  ],
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '带子菜单模式',
              child: SizedBox(
                height: 180,
                child: Stack(
                  children: [
                    UPFloatButton(
                      key: const ValueKey('float-button-page-menu'),
                      isMenu: true,
                      list: _menuItems,
                      child: const KeyedSubtree(
                        key: ValueKey('float-button-page-menu-trigger'),
                        child: UPIcon(
                          name: 'plus',
                          color: Colors.white,
                        ),
                      ),
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
