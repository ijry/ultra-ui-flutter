import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class CodePage extends StatefulWidget {
  const CodePage({super.key});

  @override
  State<CodePage> createState() => _CodePageState();
}

class _CodePageState extends State<CodePage> {
  final UPCodeController _basicController = UPCodeController();
  final UPCodeController _keepController = UPCodeController();
  final UPCodeController _textController = UPCodeController();

  String _tips = '';
  String _tips1 = '';
  String _tips2 = '';
  bool _disabled1 = false;
  bool _disabled2 = false;

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

  void _requestCode(UPCodeController controller) {
    if (controller.canGetCode) {
      UPToast.show(context, message: '验证码已发送');
      controller.start();
    } else {
      UPToast.show(context, message: '倒计时结束后再发送');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: '验证码',
      child: Container(
        key: const ValueKey('example-page-componentsB/code/code'),
        child: Column(
          children: <Widget>[
            _CodeBlock(
              title: '基础功能',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  UPCode(
                    controller: _basicController,
                    seconds: 20,
                    changeText: 'XS获取',
                    onChange: (text) => _setStateSafely(() => _tips = text),
                    onStart: () => _setStateSafely(() => _disabled1 = true),
                    onEnd: () => _setStateSafely(() => _disabled1 = false),
                  ),
                  UPButton(
                    text: _tips.isEmpty ? '获取验证码' : _tips,
                    type: 'success',
                    size: 'small',
                    disabled: _disabled1,
                    onClick: () => _requestCode(_basicController),
                  ),
                ],
              ),
            ),
            _CodeBlock(
              title: '保持倒计时(开始后，左上角返退出此页面再进入，会发现倒计时还在继续)',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  UPCode(
                    controller: _keepController,
                    keepRunning: true,
                    uniqueKey: 'code-page-keep',
                    changeText: '倒计时XS',
                    onChange: (text) => _setStateSafely(() => _tips1 = text),
                    onStart: () => _setStateSafely(() => _disabled2 = true),
                    onEnd: () => _setStateSafely(() => _disabled2 = false),
                  ),
                  UPButton(
                    text: _tips1.isEmpty ? '获取验证码' : _tips1,
                    type: 'primary',
                    size: 'small',
                    disabled: _disabled2,
                    onClick: () => _requestCode(_keepController),
                  ),
                ],
              ),
            ),
            _CodeBlock(
              title: '文本样式',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  UPCode(
                    controller: _textController,
                    keepRunning: true,
                    uniqueKey: 'code-page-text',
                    startText: '点我获取验证码',
                    onChange: (text) => _setStateSafely(() => _tips2 = text),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _requestCode(_textController),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 6,
                      ),
                      child: Text(
                        _tips2.isEmpty ? '点我获取验证码' : _tips2,
                        style: TextStyle(
                          color: tokens.primary,
                          fontSize: 15,
                        ),
                      ),
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

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}
