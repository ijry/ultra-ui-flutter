import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

/// Port of pages/template/keyboardPay — a red-packet payment keypad.
class KeyboardPayPage extends StatefulWidget {
  const KeyboardPayPage({super.key});

  @override
  State<KeyboardPayPage> createState() => _KeyboardPayPageState();
}

class _KeyboardPayPageState extends State<KeyboardPayPage> {
  bool _show = false;
  String _password = '';
  bool _paying = false;
  Timer? _payTimer;

  @override
  void dispose() {
    _payTimer?.cancel();
    super.dispose();
  }

  void _showPop([bool flag = true]) {
    setState(() {
      _password = '';
      _show = flag;
    });
  }

  void _onChange(dynamic value) {
    if (_password.length >= 6) return;
    setState(() => _password += '$value');
    if (_password.length >= 6) _pay();
  }

  void _onBackspace([dynamic _]) {
    if (_password.isEmpty) return;
    setState(() => _password = _password.substring(0, _password.length - 1));
  }

  /// Source shows a 2s loading, hides the keypad, then toasts success.
  void _pay() {
    setState(() => _paying = true);
    _payTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _paying = false;
        _show = false;
      });
      UPToast.show(context, message: '支付成功', type: 'success');
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: '自定义键盘支付',
      child: Container(
        key: const ValueKey('example-page-template/keyboardPay/index'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20),
              child: UPButton(
                key: const ValueKey('keyboard-pay-page-open'),
                type: 'success',
                onClick: () => _showPop(true),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    UPIcon(name: 'red-packet'),
                    SizedBox(width: 5),
                    Text('发送1.00元红包'),
                  ],
                ),
              ),
            ),
            if (_paying)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(child: UPLoadingIcon(text: '支付中', size: 24)),
              ),
            UPKeyboard(
              key: const ValueKey('keyboard-pay-page-keyboard'),
              mode: 'number',
              // Source page passes `dot-enabled` and `mask`, neither declared in
              // u-keyboard's props.js — uView 1.x leftovers. dotDisabled is the
              // real prop, and true here matches the intent of dot-enabled=false.
              dotDisabled: true,
              closeOnClickOverlay: false,
              show: _show,
              safeAreaInsetBottom: true,
              tooltip: false,
              onChange: _onChange,
              onBackspace: _onBackspace,
              // Source puts the amount, dots and caption above the keypad.
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              '1.00',
                              style: TextStyle(
                                fontSize: 40,
                                color: tokens.warning,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 5, bottom: 6),
                              child: Text(
                                '元',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: tokens.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          key: const ValueKey('keyboard-pay-page-close'),
                          onTap: () => _showPop(false),
                          child: const Padding(
                            padding: EdgeInsets.all(5),
                            child: UPIcon(
                              name: 'close',
                              color: Color(0xFF333333),
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  UPMessageInput(
                    mode: 'box',
                    maxlength: 6,
                    dotFill: true,
                    value: _password,
                    disabledKeyboard: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 10),
                    child: Text(
                      '支付键盘',
                      style: TextStyle(color: tokens.tipsColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
