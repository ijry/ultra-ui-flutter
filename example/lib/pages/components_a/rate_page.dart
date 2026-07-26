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
  num controlledValue = 3;
  num activeColorValue = 3;
  num voidColorValue = 2;
  num touchableValue = 2;
  num halfValue = 3.5;
  num activeIconValue = 3;
  num currentRating = 3;

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
              child: const UPRate(size: 20),
            ),
            _RateBlock(
              title: '自定义选中星星数量',
              child: _editableRate(
                value: controlledValue,
                onChange: (value) => setState(() {
                  controlledValue = value;
                  currentRating = value;
                }),
              ),
            ),
            _RateBlock(
              title: '自定义星星大小',
              child: const UPRate(size: 30, count: 4),
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
                onChange: (value) => setState(() {
                  activeColorValue = value;
                  currentRating = value;
                }),
              ),
            ),
            _RateBlock(
              title: '自定义未选中星星颜色',
              child: _editableRate(
                value: voidColorValue,
                inactiveColor: '#2979ff',
                onChange: (value) => setState(() {
                  voidColorValue = value;
                  currentRating = value;
                }),
              ),
            ),
            _RateBlock(
              title: '禁止触摸选择',
              child: const IgnorePointer(
                child: UPRate(size: 20, touchable: false),
              ),
            ),
            _RateBlock(
              title: '允许触摸选择',
              child: _editableRate(
                value: touchableValue,
                onChange: (value) => setState(() {
                  touchableValue = value;
                  currentRating = value;
                }),
              ),
            ),
            _RateBlock(
              title: '是否允许半星',
              child: _editableRate(
                value: halfValue,
                allowHalf: true,
                onChange: (value) => setState(() {
                  halfValue = value;
                  currentRating = value;
                }),
              ),
            ),
            _RateBlock(
              title: '自定义选中的图标',
              child: _editableRate(
                value: activeIconValue,
                activeIcon: 'heart-fill',
                inactiveIcon: 'heart',
                onChange: (value) => setState(() {
                  activeIconValue = value;
                  currentRating = value;
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('当前评分：$currentRating'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _editableRate({
    required num value,
    required ValueChanged<num> onChange,
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
          size: 20,
          value: value,
          allowHalf: allowHalf,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          activeIcon: activeIcon,
          inactiveIcon: inactiveIcon,
          onChange: onChange,
        ),
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
