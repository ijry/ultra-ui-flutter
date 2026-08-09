import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class TooltipPage extends StatefulWidget {
  const TooltipPage({super.key});

  @override
  State<TooltipPage> createState() => _TooltipPageState();
}

class _TooltipPageState extends State<TooltipPage> {
  final GlobalKey<UPTooltipState> _customTooltipKey =
      GlobalKey<UPTooltipState>();
  int _extensionClicks = 0;

  void _openCustomTooltip() {
    _customTooltipKey.currentState?.open();
  }

  Widget _button({
    required String text,
    required VoidCallback onClick,
    Key? key,
  }) {
    return UPButton(
      key: key,
      type: 'primary',
      size: 'small',
      text: text,
      stop: false,
      onClick: onClick,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '长按提示',
      child: Container(
        key: const ValueKey('example-page-componentsC/tooltip/tooltip'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const ExampleDemoBlock(
              title: '基础使用',
              child: UPTooltip(
                text: '长按文本，上方提示',
                overlay: true,
              ),
            ),
            const ExampleDemoBlock(
              title: '下方显示',
              child: Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: UPTooltip(
                  text: '长按文本，下方提示',
                  direction: 'bottom',
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '扩展按钮',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  UPTooltip(
                    key: const ValueKey('tooltip-page-extension'),
                    text: '显示多个扩展按钮',
                    buttons: const <String>['扩展'],
                    showCopy: false,
                    onClick: (_) => setState(() => _extensionClicks += 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Text('扩展点击：$_extensionClicks'),
                  ),
                ],
              ),
            ),
            const ExampleDemoBlock(
              title: '自动调整位置',
              child: UPTooltip(
                text: '自动调整气泡位置',
                buttons: <String>['扩展', '搜索', '翻译'],
              ),
            ),
            const ExampleDemoBlock(
              title: '高亮选中文本背景色',
              child: UPTooltip(
                text: '长按文本，显示背景色',
                buttons: <String>['扩展', '搜索', '翻译'],
                bgColor: '#e3e4e6',
                triggerMode: 'click',
                direction: 'top',
              ),
            ),
            ExampleDemoBlock(
              title: '单例打开',
              child: Wrap(
                spacing: 12,
                children: <Widget>[
                  const UPTooltip(
                    text: '第一个',
                    triggerMode: 'click',
                    singleton: true,
                  ),
                  const UPTooltip(
                    text: '第二个',
                    triggerMode: 'click',
                    singleton: true,
                  ),
                ],
              ),
            ),
            ExampleDemoBlock(
              title: '自定义触发器',
              child: UPTooltip(
                key: _customTooltipKey,
                text: '长按文本，显示背景色',
                color: '#333',
                bgColor: '#e3e4e6',
                popupBgColor: '#f7f7f7',
                triggerMode: 'click',
                direction: 'right',
                child: _button(
                  key: const ValueKey('tooltip-page-custom-trigger'),
                  text: '点击',
                  onClick: _openCustomTooltip,
                ),
                content: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                  child: Text('自定义内容'),
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '左侧弹出',
              child: Align(
                alignment: Alignment.centerRight,
                child: UPTooltip(
                  text: '长按文本，显示背景色',
                  color: '#fff',
                  bgColor: '#333',
                  popupBgColor: '#333',
                  triggerMode: 'click',
                  forcePosition: const <String, String>{
                    'right': '108px',
                    'top': '0px',
                  },
                  direction: 'left',
                  child: _button(
                    text: '点击',
                    onClick: () {},
                  ),
                  content: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                    child: Text('自定义内容'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
