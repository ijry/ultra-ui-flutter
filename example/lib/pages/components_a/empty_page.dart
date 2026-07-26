import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

class EmptyPage extends StatefulWidget {
  const EmptyPage({super.key});

  @override
  State<EmptyPage> createState() => _EmptyPageState();
}

class _EmptyPageState extends State<EmptyPage> {
  static const List<_EmptyOption> _options = <_EmptyOption>[
    _EmptyOption('car', '购物车为空'),
    _EmptyOption('data', '数据为空'),
    _EmptyOption('comment', '评论为空'),
    _EmptyOption('coupon', '优惠券为空'),
    _EmptyOption('history', '历史记录为空'),
    _EmptyOption('list', '列表为空'),
    _EmptyOption('message', '消息为空'),
    _EmptyOption('news', '新闻为空'),
    _EmptyOption('order', '订单为空'),
    _EmptyOption('page', '页面不存在'),
    _EmptyOption('permission', '权限不足'),
    _EmptyOption('search', '搜索结果为空'),
    _EmptyOption('wifi', '网络不给力'),
  ];

  String _mode = 'data';

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '内容为空',
      child: Container(
        key: const ValueKey('example-page-componentsA/empty/empty'),
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(left: 20, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('演示效果'),
              ),
            ),
            UPEmpty(
              mode: _mode,
              text: _options.firstWhere((option) => option.mode == _mode).title,
              child: _mode == 'car'
                  ? const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: UPButton(
                        text: '查看更多商品',
                        size: 'small',
                        type: 'primary',
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 10),
            UPCellGroup(
              children: _options
                  .map(
                    (option) => UPCell(
                      title: option.title,
                      isLink: true,
                      clickable: true,
                      onClick: () => setState(() => _mode = option.mode),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyOption {
  const _EmptyOption(this.mode, this.title);

  final String mode;
  final String title;
}
