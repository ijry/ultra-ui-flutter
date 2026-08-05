import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final UPCodeController _codeController = UPCodeController();

  String _value = '';
  String _inputNumber = '';
  String _inputPassword = '123456';
  String _tips = '';
  String _basicConfirm = '';
  String _codeText = '';

  void _setStateSafely(VoidCallback callback) {
    if (!mounted) return;
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      setState(callback);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(callback);
    });
  }

  void _onCodeChange(String text) {
    _setStateSafely(() {
      _tips = text;
      _codeText = text;
    });
  }

  void _getCode() {
    if (_codeController.canGetCode) {
      UPToast.show(context, message: '验证码已发送');
      _codeController.start();
      return;
    }
    UPToast.show(context, message: '倒计时结束后再发送');
  }

  Widget _block(String title, Widget child) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }

  Widget _valueLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '输入框',
      child: Container(
        key: const ValueKey('example-page-componentsC/input/input'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _block(
              '基础使用',
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  UPInput(
                    key: const ValueKey('input-page-basic'),
                    value: _value,
                    placeholder: '请输入内容',
                    border: 'surround',
                    confirmType: 'search',
                    onChange: (value) => setState(() => _value = value),
                    onConfirm: (value) {
                      setState(() => _basicConfirm = '确认：$value');
                      UPToast.show(context, message: '@confirm触发');
                    },
                  ),
                  _valueLine('基础值：$_value'),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: UPButton(
                      text: '变化',
                      onClick: () => setState(() => _value = '0.123456'),
                    ),
                  ),
                  if (_basicConfirm.isNotEmpty) _valueLine(_basicConfirm),
                ],
              ),
            ),
            _block(
              '颜色',
              const UPInput(
                placeholder: '请输入内容',
                border: 'surround',
                color: 'blue',
              ),
            ),
            _block(
              '可清空内容(仅focus时显示清除图标)',
              const UPInput(
                placeholder: '请输入内容',
                border: 'surround',
                clearable: true,
              ),
            ),
            _block(
              '可清空内容(始终显示清除图标)',
              const UPInput(
                placeholder: '请输入内容',
                border: 'surround',
                clearable: true,
                onlyClearableOnFocused: false,
              ),
            ),
            _block(
              '数字键盘',
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  UPInput(
                    key: const ValueKey('input-page-number'),
                    value: _inputNumber,
                    placeholder: '请输入内容',
                    border: 'surround',
                    type: 'number',
                    clearable: true,
                    onChange: (value) => setState(() => _inputNumber = value),
                  ),
                  _valueLine('数字值：$_inputNumber'),
                ],
              ),
            ),
            _block(
              '密码类型',
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  UPInput(
                    key: const ValueKey('input-page-password'),
                    value: _inputPassword,
                    placeholder: '请输入内容',
                    border: 'surround',
                    password: true,
                    clearable: true,
                    passwordVisibilityToggle: true,
                    onChange: (value) => setState(() => _inputPassword = value),
                  ),
                  _valueLine('密码值：$_inputPassword'),
                ],
              ),
            ),
            _block(
              '显示下划线',
              const UPInput(
                placeholder: '请输入内容',
                border: 'bottom',
                clearable: true,
              ),
            ),
            _block(
              '禁用状态',
              const UPInput(
                placeholder: '禁用状态',
                border: 'surround',
                disabled: true,
              ),
            ),
            _block(
              '圆形',
              const UPInput(
                placeholder: '请输入内容',
                border: 'surround',
                shape: 'circle',
              ),
            ),
            _block(
              '前后图标',
              Column(
                children: const <Widget>[
                  UPInput(
                    placeholder: '前置图标',
                    prefixIcon: 'search',
                    prefixIconStyle: 'font-size: 22px;color: #909399',
                  ),
                  SizedBox(height: 15),
                  UPInput(
                    placeholder: '后置图标',
                    suffixIcon: 'map-fill',
                    suffixIconStyle: 'color: #909399',
                  ),
                ],
              ),
            ),
            _block(
              '前后插槽',
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(right: 3),
                        child: UPText(
                          text: 'http://',
                          type: 'tips',
                          flex1: false,
                        ),
                      ),
                      const Expanded(
                        child: UPInput(placeholder: '前置插槽'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: <Widget>[
                      const Expanded(
                        child: UPInput(placeholder: '后置插槽'),
                      ),
                      UPCode(
                        controller: _codeController,
                        seconds: 20,
                        changeText: 'X秒重新获取哈哈哈',
                        onChange: _onCodeChange,
                      ),
                      const SizedBox(width: 4),
                      UPButton(
                        text: _tips.isEmpty ? _codeText : _tips,
                        type: 'success',
                        size: 'mini',
                        onClick: _getCode,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const UPGap(height: 50),
          ],
        ),
      ),
    );
  }
}
