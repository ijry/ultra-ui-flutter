import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../../routes/example_catalog.dart';
import '../../routes/example_preview_catalog.dart';
import '../../routes/example_route.dart';
import '../shared/example_demo_block.dart';
import '../shared/example_route_list.dart';

class ComponentsHomePage extends StatelessWidget {
  const ComponentsHomePage({super.key});

  static const List<String> _groupTitles = <String>[
    '基础组件',
    '表单组件',
    '数据组件',
    '反馈组件',
    '布局组件',
    '导航组件',
    '其他组件',
  ];

  @override
  Widget build(BuildContext context) {
    final groups = _splitComponentGroups();
    return Scaffold(
      appBar: AppBar(title: const Text('uview-plus')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                'uview-plus 是 uview2.0 的 Vue3 版本，提供全面的组件和便捷工具。',
              ),
            ),
            ...List<Widget>.generate(_groupTitles.length, (index) {
              return ExampleDemoBlock(
                title: _groupTitles[index],
                child: ExampleRouteList(routes: groups[index]),
              );
            }),
            ExampleDemoBlock(
              title: '示例',
              child: UPCellGroup(
                children: <Widget>[
                  UPCell(
                    title: '激励广告',
                    isLink: true,
                    clickable: true,
                    onClick: () => pushExampleRoute(
                      context,
                      findExampleRoute('example/ad'),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 24, 12, 0),
              child: UPAlert(description: 'uview-plus 2022-2024'),
            ),
          ],
        ),
      ),
    );
  }

  List<List<ExamplePreviewRoute>> _splitComponentGroups() {
    var start = 0;
    return componentGroupLengths.map((length) {
      final group = componentPreviewRoutes.sublist(start, start + length);
      start += length;
      return group;
    }).toList();
  }
}
