import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class SwitchPage extends StatefulWidget {
  const SwitchPage({super.key});

  @override
  State<SwitchPage> createState() => _SwitchPageState();
}

class _SwitchPageState extends State<SwitchPage> {
  final List<bool> _values = <bool>[
    false,
    true,
    false,
    true,
    false,
    true,
    false,
    true,
    true,
    true,
    false,
    true,
    true,
  ];

  void _setValue(int index, dynamic value) {
    setState(() => _values[index] = value == true);
  }

  Future<void> _asyncChange(dynamic value) async {
    final next = value == true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(next ? '确定要打开吗' : '确定要关闭吗'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() => _values[12] = next);
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '开关',
      child: Container(
        key: const ValueKey('example-page-componentsB/switch/switch'),
        child: Column(
          children: <Widget>[
            _SwitchBlock(
              title: '基础功能',
              children: <Widget>[
                _switchRow(
                  key: const ValueKey('switch-page-basic-1'),
                  value: _values[0],
                  onChange: (value) => _setValue(0, value),
                  valueText: '${_values[0]}',
                ),
                _switchRow(
                  value: _values[1],
                  onChange: (value) => _setValue(1, value),
                  valueText: '${_values[1]}',
                ),
              ],
            ),
            _SwitchBlock(
              title: '加载中',
              children: <Widget>[
                _switchRow(value: _values[2], loading: true),
                _switchRow(value: _values[3], loading: true),
              ],
            ),
            _SwitchBlock(
              title: '禁用状态',
              children: <Widget>[
                _switchRow(value: _values[4], disabled: true),
                _switchRow(value: _values[5], disabled: true),
              ],
            ),
            _SwitchBlock(
              title: '自定义尺寸',
              children: <Widget>[
                _switchRow(
                  value: _values[6],
                  size: 28,
                  onChange: (value) => _setValue(6, value),
                ),
                _switchRow(
                  value: _values[7],
                  size: 20,
                  onChange: (value) => _setValue(7, value),
                ),
              ],
            ),
            _SwitchBlock(
              title: '自定义颜色',
              children: <Widget>[
                _switchRow(
                  value: _values[8],
                  activeColor: '#f56c6c',
                  loading: true,
                ),
                _switchRow(
                  value: _values[9],
                  activeColor: '#5ac725',
                  loading: true,
                ),
              ],
            ),
            _SwitchBlock(
              title: '自定义样式',
              children: <Widget>[
                _switchRow(
                  value: _values[10],
                  space: 2,
                  activeColor: '#f56c6c',
                  inactiveColor: 'rgb(230, 230, 230)',
                  onChange: (value) => _setValue(10, value),
                ),
                _switchRow(
                  value: _values[11],
                  space: 2,
                  activeColor: '#f9ae3d',
                  inactiveColor: 'rgb(230, 230, 230)',
                  onChange: (value) => _setValue(11, value),
                ),
              ],
            ),
            _SwitchBlock(
              title: '异步控制',
              footer: Text('异步值：${_values[12]}'),
              children: <Widget>[
                _switchRow(
                  key: const ValueKey('switch-page-async'),
                  value: _values[12],
                  asyncChange: true,
                  onChange: _asyncChange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchRow({
    Key? key,
    required bool value,
    bool loading = false,
    bool disabled = false,
    dynamic size = 25,
    dynamic activeColor = '#2979ff',
    dynamic inactiveColor = '#ffffff',
    dynamic space = 0,
    bool asyncChange = false,
    ValueChanged<dynamic>? onChange,
    String? valueText,
  }) {
    return Row(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        UPSwitch(
          value: value,
          loading: loading,
          disabled: disabled,
          size: size,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          space: space,
          asyncChange: asyncChange,
          onChange: onChange,
        ),
        if (valueText != null) ...[
          const SizedBox(width: 8),
          Text(valueText),
        ],
      ],
    );
  }
}

class _SwitchBlock extends StatelessWidget {
  const _SwitchBlock({
    required this.title,
    required this.children,
    this.footer,
  });

  final String title;
  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 30,
              runSpacing: 14,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: children,
            ),
            if (footer != null) ...[
              const SizedBox(height: 12),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}
