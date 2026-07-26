import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../../routes/example_catalog.dart';
import '../../routes/example_preview_catalog.dart';
import '../shared/example_demo_block.dart';
import '../shared/example_route_list.dart';

class ComponentsHomePage extends StatelessWidget {
  const ComponentsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
            ...componentPreviewGroups.map((group) {
              return ExampleDemoBlock(
                title: group.title,
                child: ExampleRouteList(routes: group.routes),
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
}
