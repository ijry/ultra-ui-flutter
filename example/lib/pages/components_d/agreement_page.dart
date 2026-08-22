import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class AgreementPage extends StatefulWidget {
  const AgreementPage({super.key});

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  final UPAgreementController _agreement1 = UPAgreementController();
  final UPAgreementController _agreement2 = UPAgreementController();

  int _checked1 = 0;
  int _checked2 = 0;

  static const String _urlProtocol =
      '/pages/user_agreement/agreement/info?title=用户协议';
  static const String _urlPrivacy =
      '/pages/user_agreement/agreement/info?title=隐私政策';

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: '协议',
      child: Container(
        key: const ValueKey('example-page-componentsD/agreement/agreement'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '基础用法',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    UPButton(
                      key: const ValueKey('agreement-page-show-1'),
                      type: 'primary',
                      text: '显示协议',
                      onClick: _agreement1.showModal,
                    ),
                    UPAgreement(
                      controller: _agreement1,
                      urlProtocol: _urlProtocol,
                      urlPrivacy: _urlPrivacy,
                      onConfirm: (value) => setState(() => _checked1 = value),
                    ),
                    if (_checked1 != 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '已同意基础协议',
                          style: TextStyle(color: tokens.contentColor),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '自定义插槽',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    UPButton(
                      key: const ValueKey('agreement-page-show-2'),
                      type: 'error',
                      text: '显示协议',
                      onClick: _agreement2.showModal,
                    ),
                    UPAgreement(
                      controller: _agreement2,
                      urlProtocol: _urlProtocol,
                      urlPrivacy: _urlPrivacy,
                      onConfirm: (value) => setState(() => _checked2 = value),
                      // Source replaces the body with three inline links.
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '请仔细阅读并同意以下协议：',
                            style: TextStyle(color: tokens.mainColor),
                          ),
                          const SizedBox(height: 8),
                          for (final entry in const <String>[
                            '用户服务协议',
                            '隐私保护政策',
                            '第三方信息共享清单',
                          ])
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text('《',
                                    style: TextStyle(color: tokens.mainColor)),
                                Text(
                                  entry,
                                  style: TextStyle(color: tokens.primary),
                                ),
                                Text('》',
                                    style: TextStyle(color: tokens.mainColor)),
                              ],
                            ),
                        ],
                      ),
                    ),
                    if (_checked2 != 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '已同意自定义协议',
                          style: TextStyle(color: tokens.contentColor),
                        ),
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
}
