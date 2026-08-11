import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class BoxPage extends StatelessWidget {
  const BoxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '盒子',
      child: Container(
        key: const ValueKey('example-page-componentsD/box/box'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '基础功能',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: const UPBox(
                  key: ValueKey('box-page-basic'),
                  height: '160px',
                  gap: '12px',
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '自定义插槽',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: const UPBox(
                  key: ValueKey('box-page-custom'),
                  height: '180px',
                  gap: '12px',
                  left: UPIcon(name: 'arrow-left', size: 19),
                  rightTop: UPIcon(name: 'arrow-left', size: 19),
                  rightBottom: UPIcon(name: 'arrow-left', size: 19),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
