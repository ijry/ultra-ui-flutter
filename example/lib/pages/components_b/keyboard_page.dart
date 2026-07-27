import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

class KeyboardPage extends StatefulWidget {
  const KeyboardPage({super.key});

  @override
  State<KeyboardPage> createState() => _KeyboardPageState();
}

class _KeyboardPageState extends State<KeyboardPage> {
  String _input = '';
  String _mode = '';
  bool _dotDisabled = false;
  bool _random = false;
  bool _showKeyboard = false;

  void _openKeyboard(_KeyboardPreset preset) {
    setState(() {
      _input = '';
      _mode = preset.mode;
      _dotDisabled = preset.dotDisabled;
      _random = preset.random;
      _showKeyboard = true;
    });
  }

  void _closeKeyboard() {
    if (!_showKeyboard) return;
    setState(() => _showKeyboard = false);
  }

  void _appendInput(dynamic value) {
    setState(() => _input += '$value');
  }

  void _backspace() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '键盘',
      scrollable: false,
      child: Stack(
        children: <Widget>[
          Container(
            key: const ValueKey('example-page-componentsB/keyboard/keyboard'),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                UPCellGroup(
                  children: List<Widget>.generate(
                    _keyboardPresets.length,
                    (index) {
                      final preset = _keyboardPresets[index];
                      return UPCell(
                        title: preset.title,
                        titleStyle:
                            const TextStyle(fontWeight: FontWeight.w500),
                        isLink: true,
                        clickable: true,
                        iconSlot: Image.asset(
                          preset.iconAsset,
                          width: 18,
                          height: 18,
                          fit: BoxFit.contain,
                        ),
                        onClick: () => _openKeyboard(preset),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('输入内容：${_input.isEmpty ? '未输入' : _input}'),
                  ),
                ),
              ],
            ),
          ),
          if (_showKeyboard)
            UPKeyboard(
              mode: _mode,
              dotDisabled: _dotDisabled,
              random: _random,
              show: true,
              onClose: _closeKeyboard,
              onCancel: _closeKeyboard,
              onConfirm: _closeKeyboard,
              onUpdateShow: (show) {
                if (!show) _closeKeyboard();
              },
              onChange: _appendInput,
              onBackspace: _backspace,
            ),
        ],
      ),
    );
  }
}

class _KeyboardPreset {
  const _KeyboardPreset({
    required this.title,
    required this.iconAsset,
    this.mode = '',
    this.dotDisabled = false,
    this.random = false,
  });

  final String title;
  final String iconAsset;
  final String mode;
  final bool dotDisabled;
  final bool random;
}

const List<_KeyboardPreset> _keyboardPresets = <_KeyboardPreset>[
  _KeyboardPreset(
    title: '车牌号键盘',
    iconAsset: 'assets/uview/demo/keyboard/car.png',
  ),
  _KeyboardPreset(
    title: '数字键盘',
    iconAsset: 'assets/uview/demo/keyboard/number.png',
    mode: 'number',
  ),
  _KeyboardPreset(
    title: '身份证键盘',
    iconAsset: 'assets/uview/demo/keyboard/IdCard.png',
    mode: 'card',
  ),
  _KeyboardPreset(
    title: '隐藏键盘"."符号',
    iconAsset: 'assets/uview/demo/keyboard/dot.png',
    mode: 'number',
    dotDisabled: true,
  ),
  _KeyboardPreset(
    title: '打乱键盘按键的顺序',
    iconAsset: 'assets/uview/demo/keyboard/order.png',
    mode: 'number',
    random: true,
  ),
];
