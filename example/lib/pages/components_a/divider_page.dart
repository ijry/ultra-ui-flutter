import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class DividerPage extends StatelessWidget {
  const DividerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '分割线',
      child: Container(
        key: const ValueKey('example-page-componentsA/divider/divider'),
        child: const Column(
          children: <Widget>[
            _DividerBlock('基本案例', UPDivider(text: '分割线')),
            _DividerBlock('是否虚线', UPDivider(text: '分割线', dashed: true)),
            _DividerBlock('是否细线', UPDivider(text: '分割线', hairline: true)),
            _DividerBlock('是否以点代替文字', UPDivider(text: '分割线', dot: true)),
            _DividerBlock(
                '文本内容靠左', UPDivider(text: '分割线', textPosition: 'left')),
            _DividerBlock(
                '文本内容靠右', UPDivider(text: '分割线', textPosition: 'right')),
            _DividerBlock(
                '自定义文本颜色',
                UPDivider(
                    text: '分割线', textColor: '#2979ff', lineColor: '#2979ff')),
          ],
        ),
      ),
    );
  }
}

class _DividerBlock extends StatelessWidget {
  const _DividerBlock(this.title, this.divider);

  final String title;
  final Widget divider;

  @override
  Widget build(BuildContext context) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(padding: const EdgeInsets.all(16), child: divider),
    );
  }
}
