import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '标题',
      child: Container(
        key: const ValueKey('example-page-componentsD/title/title'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const <Widget>[
            ExampleDemoBlock(
              title: '默认',
              child: Padding(
                padding: EdgeInsets.all(16),
                child: UPTitle(
                  key: ValueKey('title-page-default'),
                  text: '默认标题',
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '自定义前缀',
              child: Padding(
                padding: EdgeInsets.all(16),
                child: UPTitle(
                  key: ValueKey('title-page-prefix'),
                  prefix: UPIcon(name: 'level', color: 'red', size: 16),
                  text: '等级3',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
