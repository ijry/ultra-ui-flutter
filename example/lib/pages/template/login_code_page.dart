import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

/// Port of pages/template/login/code — the verification-code step.
class LoginCodePage extends StatefulWidget {
  const LoginCodePage({super.key});

  @override
  State<LoginCodePage> createState() => _LoginCodePageState();
}

class _LoginCodePageState extends State<LoginCodePage> {
  static const int _maxlength = 4;

  String _value = '';
  int _second = 3;
  bool _show = false;
  bool _error = false;
  bool _sheetShown = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Source counts down in onLoad and, at zero, flips to the "can't receive"
    // link — flagging an error if the code is still incomplete.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _second -= 1;
        if (_second <= 0) {
          _show = true;
          if (_value.length != _maxlength) _error = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Source calls `uni.showActionSheet` with the two fallback options.
  /// UPActionSheet is declarative rather than imperative, so this toggles a flag.
  void _noCaptcha() => setState(() => _sheetShown = true);

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: '验证码',
      child: Container(
        key: const ValueKey('example-page-template/login/code'),
        // Source `.wrap` pads 80rpx all round, `.key-input` 30rpx vertically.
        padding: const EdgeInsets.fromLTRB(40, 55, 40, 55),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              '输入验证码',
              style: TextStyle(fontSize: 25, color: tokens.mainColor),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 30),
              child: Text(
                '验证码已发送至 +150****9320',
                style: TextStyle(fontSize: 15, color: tokens.contentColor),
              ),
            ),
            UPMessageInput(
              key: const ValueKey('login-code-page-input'),
              focus: true,
              value: _value,
              mode: 'bottomLine',
              maxlength: _maxlength,
              onChange: (value) => setState(() => _value = '$value'),
            ),
            // Source hides this text by default and reveals it via `.error`.
            if (_error)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  '验证码错误，请重新输入',
                  style: TextStyle(color: Colors.red, fontSize: 15),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: _show
                  ? GestureDetector(
                      key: const ValueKey('login-code-page-no-captcha'),
                      onTap: _noCaptcha,
                      child: Text(
                        '收不到验证码点这里',
                        style: TextStyle(color: tokens.warning, fontSize: 15),
                      ),
                    )
                  : Text(
                      '$_second秒后重新获取验证码',
                      style: TextStyle(color: tokens.warning, fontSize: 15),
                    ),
            ),
            UPActionSheet(
              show: _sheetShown,
              actions: const <Map<String, dynamic>>[
                <String, dynamic>{'name': '重新获取验证码'},
                <String, dynamic>{'name': '接听语音验证码'},
              ],
              cancelText: '取消',
              onClose: () => setState(() => _sheetShown = false),
              onSelect: (_, __) => setState(() => _sheetShown = false),
            ),
          ],
        ),
      ),
    );
  }
}
