import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class GapPage extends StatelessWidget {
  const GapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '间隔槽',
      child: Container(
        key: const ValueKey('example-page-componentsA/gap/gap'),
        child: const Column(
          children: <Widget>[
            _GapBlock('基本案例', UPGap(bgColor: '#f3f4f6')),
            _GapBlock('自定义颜色', UPGap(bgColor: '#2979ff')),
            _GapBlock('自定义高度', UPGap(bgColor: '#f3f4f6', height: 40)),
            _GapBlock('自定义上下边距',
                UPGap(bgColor: '#f3f4f6', marginTop: 20, marginBottom: 20)),
          ],
        ),
      ),
    );
  }
}

class _GapBlock extends StatelessWidget {
  const _GapBlock(this.title, this.gap);

  final String title;
  final Widget gap;

  @override
  Widget build(BuildContext context) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(padding: const EdgeInsets.all(16), child: gap),
    );
  }
}
