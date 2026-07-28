import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../../routes/example_catalog.dart';
import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class NoticeBarPage extends StatefulWidget {
  const NoticeBarPage({super.key});

  @override
  State<NoticeBarPage> createState() => _NoticeBarPageState();
}

class _NoticeBarPageState extends State<NoticeBarPage> {
  static const String _text1 =
      'uview-plus众多组件覆盖开发过程的各个需求，组件功能丰富，多端兼容。让您快速集成，开箱即用';
  static const String _text2 = 'uview-plus众多的贴心小工具，是您开发过程中召之即来的利器，让您飞镖在手，百步穿杨';
  static const String _text3 = 'uview-plus收集众多的常用页面和布局，减少开发者的重复工作，让您专注逻辑，事半功倍';
  static const String _text5 = '涵盖uniapp各个方面，给开发者方向指导和设计理念，让您茅塞顿开，一马平川';
  static const List<String> _text4 = <String>[
    '寒雨连江夜入吴',
    '平明送客楚山孤',
    '洛阳亲友如相问',
    '一片冰心在玉壶',
  ];

  UPNoticeOpenPageHandler? _previousOpenPageHandler;
  int _closeCount = 0;
  int _clickIndex = -1;

  @override
  void initState() {
    super.initState();
    _previousOpenPageHandler = UPNoticeBar.openPageHandler;
    UPNoticeBar.openPageHandler = (
      String url, {
      String linkType = 'navigateTo',
    }) async {
      if (!mounted) return;
      if (url == '/pages/componentsB/tag/tag') {
        await pushExampleRoute(
          context,
          findExampleRoute('componentsB/tag/tag'),
        );
      }
    };
  }

  @override
  void dispose() {
    UPNoticeBar.openPageHandler = _previousOpenPageHandler;
    super.dispose();
  }

  void _recordClick(int index) {
    setState(() => _clickIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '滚动通知',
      child: Container(
        key: const ValueKey('example-page-componentsB/noticeBar/noticeBar'),
        child: Column(
          children: <Widget>[
            const _NoticeBlock(
              title: '基础功能',
              child: UPNoticeBar(
                text: _text1,
                fontSize: '30px',
              ),
            ),
            _NoticeBlock(
              key: const ValueKey('notice-page-closable'),
              title: '可关闭',
              footer: Text('关闭事件：$_closeCount'),
              child: UPNoticeBar(
                text: _text5,
                mode: 'closable',
                onClose: () => setState(() => _closeCount++),
              ),
            ),
            const _NoticeBlock(
              title: '自定义横向滚动速度',
              child: UPNoticeBar(
                text: _text2,
                speed: 250,
                mode: 'closable',
              ),
            ),
            const _NoticeBlock(
              title: '可跳转(点击右箭头)',
              child: UPNoticeBar(
                key: ValueKey('notice-page-link'),
                text: _text3,
                mode: 'link',
                url: '/pages/componentsB/tag/tag',
              ),
            ),
            _NoticeBlock(
              title: '横向步进滚动',
              footer: Text('点击索引：$_clickIndex'),
              child: UPNoticeBar(
                text: _text4,
                step: true,
                onClick: _recordClick,
              ),
            ),
            _NoticeBlock(
              title: '纵向滚动',
              footer: Text('点击索引：$_clickIndex'),
              child: UPNoticeBar(
                text: _text4,
                direction: 'column',
                onClick: _recordClick,
              ),
            ),
            _NoticeBlock(
              title: '纵向滚动(文字居中)',
              footer: Text('点击索引：$_clickIndex'),
              child: UPNoticeBar(
                text: _text4,
                direction: 'column',
                justifyContent: 'center',
                onClick: _recordClick,
              ),
            ),
            const _NoticeBlock(
              title: '自定义样式',
              child: UPNoticeBar(
                text: _text1,
                color: '#ffffff',
                bgColor: '#f56c6c',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoticeBlock extends StatelessWidget {
  const _NoticeBlock({
    super.key,
    required this.title,
    required this.child,
    this.footer,
  });

  final String title;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            child,
            if (footer != null) ...[
              const SizedBox(height: 8),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}
