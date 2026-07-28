import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class BadgePage extends StatelessWidget {
  const BadgePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '徽标数',
      child: Container(
        key: const ValueKey('example-page-componentsB/badge/badge'),
        child: const Column(
          children: <Widget>[
            _BadgeBlock(
              title: '直角边形状',
              children: <Widget>[
                UPBadge(value: 1500, shape: 'horn'),
              ],
            ),
            _BadgeBlock(
              title: '徽标数显示方式',
              children: <Widget>[
                UPBadge(value: 5132, numberType: 'ellipsis'),
                UPBadge(value: 1011, numberType: 'overflow'),
                UPBadge(value: 1500, numberType: 'limit'),
                UPBadge(value: 45187, numberType: 'limit'),
              ],
            ),
            _BadgeBlock(
              title: '显示圆点',
              children: <Widget>[
                UPBadge(value: 1011, numberType: 'overflow', isDot: true),
              ],
            ),
            _BadgeBlock(
              title: '自定义主题',
              children: <Widget>[
                UPBadge(value: 9, type: 'error'),
                UPBadge(value: 9, type: 'warning'),
                UPBadge(value: 9, type: 'success'),
                UPBadge(value: 9, type: 'primary'),
              ],
            ),
            _BadgeBlock(
              title: '反转色',
              children: <Widget>[
                UPBadge(value: 9, type: 'error', inverted: true),
                UPBadge(value: 1532, type: 'warning', inverted: true),
                UPBadge(value: 12, type: 'success', inverted: true),
                UPBadge(value: 999, type: 'primary', inverted: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeBlock extends StatelessWidget {
  const _BadgeBlock({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
        child: Wrap(
          spacing: 40,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: children,
        ),
      ),
    );
  }
}
