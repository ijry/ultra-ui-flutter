import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class CheckboxPage extends StatefulWidget {
  const CheckboxPage({super.key});

  @override
  State<CheckboxPage> createState() => _CheckboxPageState();
}

class _CheckboxPageState extends State<CheckboxPage> {
  List<dynamic> checkboxValue1 = <dynamic>['apple', 'orange'];
  List<dynamic> checkboxValue2 = <dynamic>['西游记', '红楼梦', '三国演义', '水浒传'];
  List<dynamic> checkboxValue3 = <dynamic>['傻瓜'];
  List<dynamic> checkboxValue4 = <dynamic>['黄庭坚', '欧阳修', '王安石'];
  List<dynamic> checkboxValue5 = <dynamic>['绿色'];
  List<dynamic> checkboxValue6 = <dynamic>['游艇', '轮船'];
  List<dynamic> checkboxValue7 = <dynamic>['汽车', '蒸汽机'];
  bool aloneChecked = false;

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '复选框',
      child: Container(
        key: const ValueKey('example-page-componentsA/checkbox/checkbox'),
        child: Column(
          children: <Widget>[
            _CheckboxBlock(
              title: '基本案例',
              prompt: '苹果、香蕉和橙子哪个最甜？',
              child: _group(
                value: checkboxValue1,
                placement: 'column',
                onChange: (value) => setState(() => checkboxValue1 = value),
                options: const <_CheckboxOption>[
                  _CheckboxOption('苹果', 'apple'),
                  _CheckboxOption('香蕉', 'banana'),
                  _CheckboxOption('橙子', 'orange'),
                ],
              ),
            ),
            _CheckboxBlock(
              title: '单独使用checkbox',
              prompt: '是否同意用户协议？',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  UPCheckbox(
                    label: '同意用户协议与隐私条款',
                    name: 'agree',
                    usedAlone: true,
                    checked: aloneChecked,
                    onChange: (value) => setState(() => aloneChecked = value),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 120,
                    child: UPButton(
                      type: 'primary',
                      size: 'small',
                      text: '切换',
                      onClick: () =>
                          setState(() => aloneChecked = !aloneChecked),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('$aloneChecked'),
                ],
              ),
            ),
            _CheckboxBlock(
              title: '自定义形状',
              prompt: '中国四大名著是？',
              child: _group(
                value: checkboxValue2,
                placement: 'column',
                shape: 'square',
                onChange: (value) => setState(() => checkboxValue2 = value),
                options: const <_CheckboxOption>[
                  _CheckboxOption('西游记', '西游记'),
                  _CheckboxOption('红楼梦', '红楼梦'),
                  _CheckboxOption('三国演义', '三国演义'),
                  _CheckboxOption('水浒传', '水浒传'),
                ],
              ),
            ),
            _CheckboxBlock(
              title: '是否禁用',
              prompt: '下面什么东西不能吃？',
              child: _group(
                value: checkboxValue3,
                placement: 'column',
                onChange: (value) => setState(() => checkboxValue3 = value),
                options: const <_CheckboxOption>[
                  _CheckboxOption('冬瓜', '冬瓜', disabled: true),
                  _CheckboxOption('西瓜', '西瓜'),
                  _CheckboxOption('黄瓜', '黄瓜'),
                  _CheckboxOption('傻瓜', '傻瓜'),
                ],
              ),
            ),
            _CheckboxBlock(
              title: '是否禁止点击提示语选中复选框',
              prompt: '北宋四大家是谁？',
              child: _group(
                value: checkboxValue4,
                placement: 'column',
                labelDisabled: true,
                onChange: (value) => setState(() => checkboxValue4 = value),
                options: const <_CheckboxOption>[
                  _CheckboxOption('黄庭坚', '黄庭坚'),
                  _CheckboxOption('欧阳修', '欧阳修'),
                  _CheckboxOption('苏小宝', '苏小宝'),
                  _CheckboxOption('王安石', '王安石'),
                ],
              ),
            ),
            _CheckboxBlock(
              title: '自定义颜色、图标和大小',
              prompt: '哪个颜色最好看？',
              child: _group(
                value: checkboxValue5,
                placement: 'column',
                activeColor: '#19be6b',
                iconColor: '#ffffff',
                size: 22,
                iconSize: 14,
                labelColor: '#19be6b',
                labelSize: 16,
                onChange: (value) => setState(() => checkboxValue5 = value),
                options: const <_CheckboxOption>[
                  _CheckboxOption('红色', '红色'),
                  _CheckboxOption('黄色', '黄色'),
                  _CheckboxOption('绿色', '绿色'),
                  _CheckboxOption('蓝色', '蓝色'),
                ],
              ),
            ),
            _CheckboxBlock(
              title: '横向排列形式',
              prompt: '什么东西不能飞？',
              child: _group(
                value: checkboxValue6,
                placement: 'row',
                onChange: (value) => setState(() => checkboxValue6 = value),
                options: const <_CheckboxOption>[
                  _CheckboxOption('小鸟', '小鸟'),
                  _CheckboxOption('游艇', '游艇'),
                  _CheckboxOption('轮船', '轮船'),
                  _CheckboxOption('飞机', '飞机'),
                ],
              ),
            ),
            _CheckboxBlock(
              title: '横向两端排列形式',
              prompt: '什么东西不能吃？',
              child: _group(
                value: checkboxValue7,
                placement: 'column',
                borderBottom: true,
                iconPlacement: 'right',
                onChange: (value) => setState(() => checkboxValue7 = value),
                options: const <_CheckboxOption>[
                  _CheckboxOption('汽车', '汽车'),
                  _CheckboxOption('蒸汽机', '蒸汽机'),
                  _CheckboxOption('猪肉', '猪肉'),
                  _CheckboxOption('抄手', '抄手'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _group({
    required List<dynamic> value,
    required String placement,
    required ValueChanged<List<dynamic>> onChange,
    required List<_CheckboxOption> options,
    String shape = 'square',
    String activeColor = '#2979ff',
    String iconColor = '#ffffff',
    int size = 18,
    int iconSize = 12,
    String labelColor = '#303133',
    int labelSize = 14,
    bool labelDisabled = false,
    bool borderBottom = false,
    String iconPlacement = 'left',
  }) {
    return UPCheckboxGroup(
      value: value,
      placement: placement,
      shape: shape,
      activeColor: activeColor,
      iconColor: iconColor,
      size: size,
      iconSize: iconSize,
      labelColor: labelColor,
      labelSize: labelSize,
      labelDisabled: labelDisabled,
      borderBottom: borderBottom,
      iconPlacement: iconPlacement,
      onChange: (next, {bool isChecked = false, name}) => onChange(next),
      children: options
          .map(
            (option) => UPCheckbox(
              name: option.value,
              label: option.label,
              disabled: option.disabled,
            ),
          )
          .toList(),
    );
  }
}

class _CheckboxOption {
  const _CheckboxOption(this.label, this.value, {this.disabled = false});

  final String label;
  final String value;
  final bool disabled;
}

class _CheckboxBlock extends StatelessWidget {
  const _CheckboxBlock({
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
