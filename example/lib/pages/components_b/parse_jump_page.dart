import 'package:flutter/material.dart';

import '../shared/example_page_scaffold.dart';

class ParseJumpPage extends StatelessWidget {
  const ParseJumpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '内部链接',
      child: Container(
        key: const ValueKey('example-page-componentsB/parse/jump'),
        padding: const EdgeInsets.all(16),
        child: const Text('跳转测试页面'),
      ),
    );
  }
}
