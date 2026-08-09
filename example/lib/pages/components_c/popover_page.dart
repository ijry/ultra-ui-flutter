import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class PopoverPage extends StatefulWidget {
  const PopoverPage({super.key});

  @override
  State<PopoverPage> createState() => _PopoverPageState();
}

class _PopoverPageState extends State<PopoverPage> {
  int _openCount = 0;
  int _closeCount = 0;

  void _recordOpen() {
    if (!mounted) return;
    setState(() => _openCount += 1);
  }

  void _recordClose() {
    if (!mounted) return;
    setState(() => _closeCount += 1);
  }

  Widget _content() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      child: Text('自定义内容'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      key: const ValueKey('example-page-componentsC/popover/popover'),
      title: 'Popover弹窗',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ExampleDemoBlock(
            title: '右侧弹出',
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: UPPopover(
                key: const ValueKey('popover-page-right'),
                color: '#333',
                bgColor: '#e3e4e6',
                popupBgColor: '#f7f7f7',
                direction: 'right',
                onOpen: _recordOpen,
                onClose: _recordClose,
                trigger: UPButton(
                  key: const ValueKey('popover-page-right-trigger'),
                  type: 'primary',
                  size: 'small',
                  text: '点击打开',
                  stop: false,
                ),
                content: _content(),
              ),
            ),
          ),
          ExampleDemoBlock(
            title: '左侧弹出及强制定位',
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerRight,
                child: UPPopover(
                  key: const ValueKey('popover-page-left'),
                  color: '#fff',
                  bgColor: '#333',
                  popupBgColor: '#333',
                  direction: 'left',
                  forcePosition: const <String, String>{
                    'right': '108px',
                    'top': '0px',
                  },
                  trigger: UPButton(
                    type: 'primary',
                    size: 'small',
                    text: '点击打开',
                    stop: false,
                  ),
                  content: _content(),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Text('打开次数：$_openCount'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text('关闭次数：$_closeCount'),
          ),
        ],
      ),
    );
  }
}
