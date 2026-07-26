import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class SwipeActionPage extends StatefulWidget {
  const SwipeActionPage({super.key});

  @override
  State<SwipeActionPage> createState() => _SwipeActionPageState();
}

class _SwipeActionPageState extends State<SwipeActionPage> {
  bool _showBaseRow = true;

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('温馨提示'),
        content: const Text('确定要删除吗？'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _showBaseRow = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '滑动单元格',
      child: Container(
        key: const ValueKey('example-page-componentsA/swipeAction/swipeAction'),
        child: Column(
          children: <Widget>[
            if (_showBaseRow)
              ExampleDemoBlock(
                title: '演示案例',
                child: UPSwipeAction(
                  children: <Widget>[
                    UPSwipeActionItem(
                      closeOnClick: false,
                      options: const <Map<String, dynamic>>[
                        <String, dynamic>{
                          'text': '删除',
                          'style': <String, dynamic>{
                            'backgroundColor': '#f56c6c',
                          },
                        },
                      ],
                      onClick: (_) => _confirmDelete(),
                      child: const _SwipeRow('基础使用'),
                    ),
                  ],
                ),
              ),
            ExampleDemoBlock(
              title: '按钮组',
              child: UPSwipeAction(
                children: <Widget>[
                  UPSwipeActionItem(
                    options: const <Map<String, dynamic>>[
                      <String, dynamic>{
                        'text': '收藏',
                        'style': <String, dynamic>{
                          'backgroundColor': '#3c9cff',
                        },
                      },
                      <String, dynamic>{
                        'text': '删除',
                        'style': <String, dynamic>{
                          'backgroundColor': '#f56c6c',
                        },
                      },
                    ],
                    child: const _SwipeRow('两个按钮并列'),
                  ),
                ],
              ),
            ),
            ExampleDemoBlock(
              title: '带图标',
              child: UPSwipeAction(
                children: <Widget>[
                  UPSwipeActionItem(
                    options: const <Map<String, dynamic>>[
                      <String, dynamic>{
                        'text': '收藏',
                        'icon': 'star-fill',
                        'iconSize': '20',
                        'style': <String, dynamic>{
                          'backgroundColor': '#f9ae3d',
                        },
                      },
                    ],
                    child: const _SwipeRow('自定义图标'),
                  ),
                ],
              ),
            ),
            ExampleDemoBlock(
              title: '组合使用',
              child: UPSwipeAction(
                children: <Widget>[
                  _combinationRow('禁用状态', disabled: true),
                  _combinationRow('正常状态'),
                  _combinationRow('自动关闭', closeOnClick: true),
                ],
              ),
            ),
            ExampleDemoBlock(
              title: '自定义按钮形状',
              child: UPSwipeAction(
                children: <Widget>[
                  UPSwipeActionItem(
                    options: const <Map<String, dynamic>>[
                      <String, dynamic>{
                        'icon': 'trash-fill',
                        'style': <String, dynamic>{
                          'backgroundColor': '#f56c6c',
                          'width': '40px',
                          'height': '40px',
                          'borderRadius': '100px',
                          'margin': '0 6px',
                        },
                      },
                      <String, dynamic>{
                        'icon': 'heart-fill',
                        'style': <String, dynamic>{
                          'backgroundColor': '#5ac725',
                          'width': '40px',
                          'height': '40px',
                          'borderRadius': '100px',
                          'margin': '0 6px',
                        },
                      },
                    ],
                    child: const _SwipeRow('圆形按钮'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  UPSwipeActionItem _combinationRow(
    String label, {
    bool disabled = false,
    bool closeOnClick = false,
  }) {
    return UPSwipeActionItem(
      disabled: disabled,
      closeOnClick: closeOnClick,
      options: const <Map<String, dynamic>>[
        <String, dynamic>{
          'text': '置顶',
          'style': <String, dynamic>{'backgroundColor': '#3c9cff'},
        },
        <String, dynamic>{
          'text': '取消',
          'style': <String, dynamic>{'backgroundColor': '#f9ae3d'},
        },
      ],
      child: _SwipeRow(label),
    );
  }
}

class _SwipeRow extends StatelessWidget {
  const _SwipeRow(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE4E7ED)),
          bottom: BorderSide(color: Color(0xFFE4E7ED)),
        ),
      ),
      child: Text(label, style: const TextStyle(color: Color(0xFF303133))),
    );
  }
}
