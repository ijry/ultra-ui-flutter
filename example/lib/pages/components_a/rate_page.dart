import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class RatePage extends StatefulWidget {
  const RatePage({super.key});

  @override
  State<RatePage> createState() => _RatePageState();
}

class _RatePageState extends State<RatePage> {
  num defaultValue = 1;
  num controlledValue = 3;
  num countFourValue = 1;
  num activeColorValue = 3;
  num voidColorValue = 2;
  num touchableValue = 2;
  num halfValue = 3.5;
  num activeIconValue = 3;

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '评分',
      child: Container(
        key: const ValueKey('example-page-componentsA/rate/rate'),
        child: Column(
          children: <Widget>[
            _RateBlock(
              title: '基本案例',
              child: _editableRate(
                value: defaultValue,
                onChange: (value) => setState(() => defaultValue = value),
              ),
            ),
            _RateBlock(
              title: '自定义选中星星数量',
              child: _editableRate(
                value: controlledValue,
                onChange: (value) => setState(() => controlledValue = value),
              ),
            ),
            _RateBlock(
              title: '自定义星星大小',
              child: _editableRate(
                value: countFourValue,
                count: 4,
                size: 30,
                onChange: (value) => setState(() => countFourValue = value),
              ),
            ),
            _RateBlock(
              title: '是否禁用评分',
              child: const UPRate(size: 20, disabled: true),
            ),
            _RateBlock(
              title: '是否只读评分',
              child: const UPRate(size: 20, readonly: true),
            ),
            _RateBlock(
              title: '自定义选中星星颜色',
              child: _editableRate(
                value: activeColorValue,
                activeColor: '#2979ff',
                onChange: (value) => setState(() => activeColorValue = value),
              ),
            ),
            _RateBlock(
              title: '自定义未选中星星颜色',
              child: _editableRate(
                value: voidColorValue,
                inactiveColor: '#2979ff',
                onChange: (value) => setState(() => voidColorValue = value),
              ),
            ),
            _RateBlock(
              title: '禁止触摸选择',
              child: const UPRate(size: 20, touchable: false),
            ),
            _RateBlock(
              title: '允许触摸选择',
              child: _editableRate(
                value: touchableValue,
                onChange: (value) => setState(() => touchableValue = value),
              ),
            ),
            _RateBlock(
              title: '是否允许半星',
              child: _editableRate(
                value: halfValue,
                allowHalf: true,
                minCount: 0.5,
                rateKey: const ValueKey('rate-half-mode'),
                onChange: (value) => setState(() => halfValue = value),
              ),
            ),
            _RateBlock(
              title: '自定义选中的图标',
              child: _editableRate(
                value: activeIconValue,
                activeIcon: 'heart-fill',
                inactiveIcon: 'heart',
                onChange: (value) => setState(() => activeIconValue = value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _editableRate({
    required num value,
    required ValueChanged<num> onChange,
    Key? rateKey,
    int count = 5,
    num size = 20,
    num minCount = 1,
    bool allowHalf = false,
    String activeColor = '',
    String inactiveColor = '',
    String activeIcon = 'star-fill',
    String inactiveIcon = 'star',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        UPRate(
          key: rateKey,
          size: size,
          count: count,
          minCount: minCount,
          value: value,
          allowHalf: allowHalf,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          activeIcon: activeIcon,
          inactiveIcon: inactiveIcon,
          onChange: onChange,
        ),
        const SizedBox(height: 8),
        Text('当前评分：$value'),
      ],
    );
  }
}

class _RateBlock extends StatelessWidget {
  const _RateBlock({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}
