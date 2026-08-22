import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../../routes/example_catalog.dart';
import '../shared/example_page_scaffold.dart';

/// Port of pages/template/login — the phone-number step of a login flow.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _tel = TextEditingController();

  @override
  void dispose() {
    _tel.dispose();
    super.dispose();
  }

  /// Source `submit` only advances for a valid mainland mobile number, using
  /// its own `$u.test.mobile`.
  void _submit() {
    if (!UP.test.mobile(_tel.text)) return;
    pushExampleRoute(context, findExampleRoute('template/login/code'));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final filled = _tel.text.isNotEmpty;
    return ExamplePageScaffold(
      title: '登录',
      child: Container(
        key: const ValueKey('example-page-template/login/index'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Source content column: 600rpx wide, 80rpx from the top.
            Center(
              child: SizedBox(
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: Text(
                          '欢迎登录',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                            color: tokens.mainColor,
                          ),
                        ),
                      ),
                      UPInput(
                        key: const ValueKey('login-page-tel'),
                        type: 'number',
                        placeholder: '请输入手机号',
                        border: 'bottom',
                        value: _tel.text,
                        onChange: (value) =>
                            setState(() => _tel.text = '$value'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 30),
                        child: Text(
                          '未注册的手机号验证后自动创建账号',
                          style: TextStyle(fontSize: 12, color: tokens.info),
                        ),
                      ),
                      // Source tints the button once a number is entered.
                      GestureDetector(
                        key: const ValueKey('login-page-submit'),
                        onTap: _submit,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          alignment: Alignment.center,
                          color:
                              filled ? tokens.warning : const Color(0xFFFDF3D0),
                          child: Text(
                            '获取短信验证码',
                            style: TextStyle(
                              fontSize: 15,
                              color: filled ? Colors.white : tokens.tipsColor,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('密码登录',
                                style: TextStyle(color: tokens.tipsColor)),
                            Text('遇到问题',
                                style: TextStyle(color: tokens.tipsColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Source pads the social row by 350rpx top / 150rpx sides.
            Padding(
              padding: const EdgeInsets.fromLTRB(75, 175, 75, 75),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _loginType(
                      tokens, 'weixin-fill', '微信', const Color(0xFF53C240)),
                  _loginType(tokens, 'qq-fill', 'QQ', const Color(0xFF11B7E9)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 10, color: tokens.tipsColor),
                  children: <InlineSpan>[
                    const TextSpan(text: '登录代表同意'),
                    TextSpan(
                      text: '用户协议、隐私政策，',
                      style: TextStyle(color: tokens.warning),
                    ),
                    const TextSpan(
                      text: '并授权使用您的账号信息（如昵称、头像、收获地址）以便您统一管理',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginType(
      UPThemeTokens tokens, String icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        UPIcon(name: icon, size: 20, color: color),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: tokens.contentColor),
        ),
      ],
    );
  }
}
