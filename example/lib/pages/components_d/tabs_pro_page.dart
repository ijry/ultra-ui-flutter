import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

const List<Map<String, String>> _tabs = <Map<String, String>>[
  <String, String>{'name': '关注'},
  <String, String>{'name': '推荐'},
  <String, String>{'name': '热榜'},
  <String, String>{'name': '视频'},
];

class TabsProPage extends StatefulWidget {
  const TabsProPage({super.key});

  @override
  State<TabsProPage> createState() => _TabsProPageState();
}

class _TabsProPageState extends State<TabsProPage> {
  int _current = 0;
  String _lastEvent = '未触发';

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '增强标签',
      child: Container(
        key: const ValueKey('example-page-componentsD/tabsPro/tabsPro'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '基础用法（自带内容区）',
              child: UPTabsPro(
                key: const ValueKey('tabs-pro-page-basic'),
                list: _tabs,
                current: _current,
                onChange: (item, index) {
                  if (!mounted) return;
                  setState(() {
                    _current = index;
                    _lastEvent = 'change -> $index';
                  });
                },
                contentBuilder: (scope) => SizedBox(
                  height: 120,
                  child: Center(child: Text('第 ${scope.index + 1} 个面板')),
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '仅标签（showContent 关闭）',
              child: UPTabsPro(
                key: const ValueKey('tabs-pro-page-tabs-only'),
                list: _tabs,
                showContent: false,
                onClick: (item, index) {
                  if (!mounted) return;
                  setState(() => _lastEvent = 'click -> $index');
                },
                onLongPress: (item, index) {
                  if (!mounted) return;
                  setState(() => _lastEvent = 'longPress -> $index');
                },
              ),
            ),
            Padding(
              key: const ValueKey('tabs-pro-page-result'),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('当前索引：$_current'),
                  const SizedBox(height: 8),
                  Text('最近事件：$_lastEvent'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
