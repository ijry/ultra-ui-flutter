import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class StickyPage extends StatefulWidget {
  const StickyPage({super.key});

  @override
  State<StickyPage> createState() => _StickyPageState();
}

class _StickyPageState extends State<StickyPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '吸顶',
      scrollable: false,
      child: Container(
        key: const ValueKey('example-page-componentsA/sticky/sticky'),
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 24),
          children: <Widget>[
            ExampleDemoBlock(
              title: '基础使用',
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '滚动页面,即可看到下方的按钮会吸顶。',
                  style: TextStyle(color: Color(0xFF606266)),
                ),
              ),
            ),
            UPSticky(
              scrollController: _scrollController,
              bgColor: '#ffffff',
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: UPButton(
                  text: '吸顶按钮',
                  type: 'success',
                  onClick: () => UPToast.show(context, message: '点击了吸顶按钮'),
                ),
              ),
            ),
            const SizedBox(height: 1500),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: UPDivider(text: '已到底部'),
            ),
          ],
        ),
      ),
    );
  }
}
