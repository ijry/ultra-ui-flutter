import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class CopyPage extends StatefulWidget {
  const CopyPage({super.key});

  @override
  State<CopyPage> createState() => _CopyPageState();
}

class _CopyPageState extends State<CopyPage> {
  int _successCount = 0;

  void _recordSuccess() {
    if (!mounted) return;
    setState(() => _successCount += 1);
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '复制',
      child: Container(
        key: const ValueKey('example-page-componentsD/copy/copy'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '点击文字复制',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: UPCopy(
                  key: const ValueKey('copy-page-text'),
                  content: 'uview-plus is great !',
                  onSuccess: _recordSuccess,
                  child: const Text('点击复制'),
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '点击按钮复制',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: UPCopy(
                  key: const ValueKey('copy-page-button'),
                  content: 'uview-plus is great !',
                  onSuccess: _recordSuccess,
                  child: const IgnorePointer(
                    child: UPButton(
                      type: 'primary',
                      text: '点击复制',
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text('复制次数：$_successCount'),
            ),
          ],
        ),
      ),
    );
  }
}
