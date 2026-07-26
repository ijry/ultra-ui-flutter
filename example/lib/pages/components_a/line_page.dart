import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class LinePage extends StatelessWidget {
  const LinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '线条',
      child: Container(
        key: const ValueKey('example-page-componentsA/line/line'),
        child: const Column(
          children: <Widget>[
            _LineBlock('基本案例', UPLine()),
            _LineBlock('自定义颜色', UPLine(color: '#2979ff')),
            _LineBlock('自定义长度', UPLine(length: 200)),
            _LineBlock(
                '自定义方向',
                SizedBox(
                    height: 36,
                    child: UPLine(
                        length: 30, color: '#2979ff', direction: 'col'))),
            _LineBlock('是否显示1px粗线条', UPLine(hairline: false)),
            _LineBlock('线条与上下左右元素的间距', UPLine(margin: 20)),
            _LineBlock('是否虚线', UPLine(color: '#2979ff', dashed: true)),
          ],
        ),
      ),
    );
  }
}

class _LineBlock extends StatelessWidget {
  const _LineBlock(this.title, this.line);

  final String title;
  final Widget line;

  @override
  Widget build(BuildContext context) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(padding: const EdgeInsets.all(16), child: line),
    );
  }
}
