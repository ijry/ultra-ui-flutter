import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class RadioPage extends StatefulWidget {
  const RadioPage({super.key});

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  String radiovalue1 = 'banana';
  String radiovalue2 = '李白';
  String radiovalue3 = '苹果';
  String radiovalue4 = '6倍镜';
  String radiovalue5 = '绿色';
  String radiovalue6 = '妲己';
  String radiovalue7 = '可爱';

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '单选框',
      child: Container(
        key: const ValueKey('example-page-componentsA/radio/radio'),
        child: Column(
          children: <Widget>[
            _RadioBlock(
              title: '基本案例',
              prompt: '苹果、香蕉和橙子哪个最甜？',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _group(
                    value: radiovalue1,
                    placement: 'column',
                    onChange: (value) => setState(() => radiovalue1 = value),
                    options: const <_RadioOption>[
                      _RadioOption('苹果', 'apple'),
                      _RadioOption('香蕉', 'banana'),
                      _RadioOption('橙子', 'orange'),
                      _RadioOption('榴莲', 'durian'),
                    ],
                  ),
                  Text('当前选择：$radiovalue1'),
                ],
              ),
            ),
            _RadioBlock(
              title: '自定义形状',
              prompt: '王者荣耀谁最帅？',
              child: _group(
                value: radiovalue2,
                placement: 'column',
                shape: 'square',
                onChange: (value) => setState(() => radiovalue2 = value),
                options: const <_RadioOption>[
                  _RadioOption('李白', '李白'),
                  _RadioOption('韩信', '韩信'),
                  _RadioOption('马可波罗', '马可波罗'),
                  _RadioOption('百里守约', '百里守约'),
                ],
              ),
            ),
            _RadioBlock(
              title: '是否禁用',
              prompt: '苹果、香蕉和菠萝哪个最甜？',
              child: _group(
                value: radiovalue3,
                placement: 'column',
                onChange: (value) => setState(() => radiovalue3 = value),
                options: const <_RadioOption>[
                  _RadioOption('苹果', '苹果', disabled: true),
                  _RadioOption('香蕉', '香蕉'),
                  _RadioOption('菠萝', '菠萝'),
                ],
              ),
            ),
            _RadioBlock(
              title: '纵向排列',
              prompt: '狙击枪用哪个倍镜最好？',
              child: _group(
                value: radiovalue4,
                placement: 'column',
                labelDisabled: true,
                onChange: (value) => setState(() => radiovalue4 = value),
                options: const <_RadioOption>[
                  _RadioOption('3倍镜', '3倍镜'),
                  _RadioOption('4倍镜', '4倍镜'),
                  _RadioOption('6倍镜', '6倍镜'),
                  _RadioOption('8倍镜', '8倍镜'),
                ],
              ),
            ),
            _RadioBlock(
              title: '自定义颜色和大小',
              prompt: '你比较喜欢下面哪个颜色？',
              child: _group(
                value: radiovalue5,
                placement: 'column',
                activeColor: '#19be6b',
                size: 22,
                iconSize: 14,
                iconColor: '#ffffff',
                labelColor: '#19be6b',
                labelSize: 16,
                onChange: (value) => setState(() => radiovalue5 = value),
                options: const <_RadioOption>[
                  _RadioOption('红色', '红色'),
                  _RadioOption('绿色', '绿色'),
                  _RadioOption('蓝色', '蓝色'),
                  _RadioOption('黄色', '黄色'),
                ],
              ),
            ),
            _RadioBlock(
              title: '横向排列形式',
              prompt: '王者荣耀哪个英雄最美？',
              child: _group(
                value: radiovalue6,
                placement: 'row',
                onChange: (value) => setState(() => radiovalue6 = value),
                options: const <_RadioOption>[
                  _RadioOption('妲己', '妲己'),
                  _RadioOption('虞姬', '虞姬'),
                  _RadioOption('不知火舞', '不知火舞'),
                ],
              ),
            ),
            _RadioBlock(
              title: '横向两端排列形式',
              prompt: '你觉得阿木木可爱吗？',
              child: _group(
                value: radiovalue7,
                placement: 'column',
                borderBottom: true,
                iconPlacement: 'right',
                onChange: (value) => setState(() => radiovalue7 = value),
                options: const <_RadioOption>[
                  _RadioOption('可爱', '可爱'),
                  _RadioOption('一般', '一般'),
                  _RadioOption('不可爱', '不可爱'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _group({
    required String value,
    required String placement,
    required ValueChanged<String> onChange,
    required List<_RadioOption> options,
    String shape = 'circle',
    String activeColor = '#2979ff',
    int size = 18,
    int iconSize = 12,
    String iconColor = '#ffffff',
    String labelColor = '#303133',
    int labelSize = 14,
    bool labelDisabled = false,
    bool borderBottom = false,
    String iconPlacement = 'left',
  }) {
    return UPRadioGroup(
      value: value,
      placement: placement,
      shape: shape,
      activeColor: activeColor,
      size: size,
      iconSize: iconSize,
      iconColor: iconColor,
      labelColor: labelColor,
      labelSize: labelSize,
      labelDisabled: labelDisabled,
      borderBottom: borderBottom,
      iconPlacement: iconPlacement,
      onChange: (next) => onChange('$next'),
      children: options
          .map(
            (option) => UPRadio(
              name: option.value,
              label: option.label,
              disabled: option.disabled,
            ),
          )
          .toList(),
    );
  }
}

class _RadioOption {
  const _RadioOption(this.label, this.value, {this.disabled = false});

  final String label;
  final String value;
  final bool disabled;
}

class _RadioBlock extends StatelessWidget {
  const _RadioBlock({
    required this.title,
    required this.prompt,
    required this.child,
  });

  final String title;
  final String prompt;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(prompt, style: const TextStyle(color: Color(0xFF606266))),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
