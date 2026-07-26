import 'package:flutter/material.dart';

import '../../routes/example_preview_catalog.dart';
import '../../routes/example_route.dart';
import '../shared/example_demo_block.dart';
import '../shared/example_route_list.dart';

class TemplatesHomePage extends StatelessWidget {
  const TemplatesHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('模板')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: <Widget>[
            ExampleDemoBlock(
              title: '部件',
              child: ExampleRouteList(
                routes: <ExamplePreviewRoute>[templatePreviewRoutes[0]],
              ),
            ),
            ExampleDemoBlock(
              title: '页面',
              child: ExampleRouteList(routes: templatePreviewRoutes.sublist(1)),
            ),
          ],
        ),
      ),
    );
  }
}
