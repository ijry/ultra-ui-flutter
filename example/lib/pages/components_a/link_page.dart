import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class LinkPage extends StatelessWidget {
  const LinkPage({super.key});

  static const String _uviewUrl = 'https://uview-plus.jiangruyi.com/';
  static const String _uniAppUrl = 'https://uniapp.dcloud.io/';

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '超链接',
      child: Container(
        key: const ValueKey('example-page-componentsA/link/link'),
        child: Column(
          children: <Widget>[
            _LinkBlock(
                '基本案例', _link(context, text: '打开uview-plus文档', url: _uviewUrl)),
            _LinkBlock(
                '显示下划线',
                _link(context,
                    text: 'Go to uview-plus doc',
                    url: _uviewUrl,
                    underLine: true)),
            _LinkBlock(
                '自定义颜色',
                _link(context,
                    text: '打开uview-plus文档', url: _uviewUrl, color: '#19be6b')),
            _LinkBlock('自定义链接内容',
                _link(context, text: '打开uni-app文档', url: _uniAppUrl)),
            Opacity(
              opacity: 0.5,
              child: _LinkBlock(
                  '禁用状态',
                  const IgnorePointer(
                      child: UPLink(text: '禁用链接', color: '#909399'))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _link(
    BuildContext context, {
    required String text,
    required String url,
    bool underLine = false,
    String? color,
  }) {
    return UPLink(
      text: text,
      color: color,
      underLine: underLine,
      onClick: () => UPToast.show(context, message: url),
    );
  }
}

class _LinkBlock extends StatelessWidget {
  const _LinkBlock(this.title, this.link);

  final String title;
  final Widget link;

  @override
  Widget build(BuildContext context) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(padding: const EdgeInsets.all(16), child: link),
    );
  }
}
