import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class CodeInputPage extends StatefulWidget {
  const CodeInputPage({super.key});

  @override
  State<CodeInputPage> createState() => _CodeInputPageState();
}

class _CodeInputPageState extends State<CodeInputPage> {
  String _basicValue = '';
  int _finishCount = 0;

  void _onBasicChange(String value) {
    if (!mounted) return;
    setState(() => _basicValue = value);
  }

  void _onFinish(String value) {
    if (!mounted) return;
    setState(() {
      _basicValue = value;
      _finishCount += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      key: const ValueKey('example-page-componentsC/codeInput/codeInput'),
      title: '验证码输入',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ExampleDemoBlock(
            title: '基础使用',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 8),
                UPCodeInput(
                  key: const ValueKey('code-input-page-basic'),
                  maxlength: 4,
                  onChange: _onBasicChange,
                  onFinish: _onFinish,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
                  child: Text('基础值：$_basicValue'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Text('完成次数：$_finishCount'),
                ),
              ],
            ),
          ),
          const ExampleDemoBlock(
            title: '横线模式',
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: UPCodeInput(
                mode: 'line',
                maxlength: 4,
                bold: true,
              ),
            ),
          ),
          const ExampleDemoBlock(
            title: '设置长度',
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: UPCodeInput(maxlength: 6),
            ),
          ),
          const ExampleDemoBlock(
            title: '设置间距',
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: UPCodeInput(
                mode: 'box',
                space: 0,
                maxlength: 4,
              ),
            ),
          ),
          const ExampleDemoBlock(
            title: '细边框',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: UPCodeInput(
                    mode: 'box',
                    space: 0,
                    maxlength: 4,
                    hairline: true,
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: UPCodeInput(
                    mode: 'line',
                    space: 10,
                    maxlength: 4,
                    hairline: true,
                  ),
                ),
              ],
            ),
          ),
          const ExampleDemoBlock(
            title: '调整颜色',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: UPCodeInput(
                    mode: 'box',
                    space: 0,
                    maxlength: 4,
                    hairline: true,
                    color: '#f56c6c',
                    borderColor: '#f56c6c',
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: UPCodeInput(
                    mode: 'line',
                    size: 30,
                    maxlength: 4,
                    hairline: true,
                    color: '#3c9cff',
                    borderColor: '#3c9cff',
                  ),
                ),
              ],
            ),
          ),
          const ExampleDemoBlock(
            title: '点模式',
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: UPCodeInput(
                mode: 'box',
                dot: true,
                space: 0,
                maxlength: 4,
                hairline: true,
              ),
            ),
          ),
          const ExampleDemoBlock(
            title: '预置内容',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: UPCodeInput(
                    mode: 'box',
                    space: 0,
                    maxlength: 4,
                    hairline: true,
                    value: '123',
                    fontSize: 17,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Text('预置值：123'),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: UPCodeInput(
                    mode: 'line',
                    space: 10,
                    maxlength: 4,
                    hairline: true,
                    value: '34',
                    fontSize: 17,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Text('预置值：34'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
