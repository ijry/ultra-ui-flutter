import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

const List<Map<String, Object>> _list = <Map<String, Object>>[
  <String, Object>{'id': 1, 'label': '项目 A'},
  <String, Object>{'id': 2, 'label': '项目 B'},
  <String, Object>{'id': 3, 'label': '项目 C'},
  <String, Object>{'id': 4, 'label': '项目 D'},
  <String, Object>{'id': 5, 'label': '项目 E'},
  <String, Object>{'id': 6, 'label': '项目 F'},
  <String, Object>{'id': 7, 'label': '项目 G'},
  <String, Object>{'id': 8, 'label': '项目 H'},
];

const List<Map<String, Object>> _list2 = <Map<String, Object>>[
  <String, Object>{'id': 1, 'label': '横向 A'},
  <String, Object>{'id': 2, 'label': '横向 B'},
  <String, Object>{'id': 3, 'label': '横向 C'},
  <String, Object>{'id': 4, 'label': '横向 D'},
  <String, Object>{'id': 5, 'label': '横向 E'},
  <String, Object>{'id': 6, 'label': '横向 F'},
  <String, Object>{'id': 7, 'label': '横向 G'},
  <String, Object>{'id': 8, 'label': '横向 H'},
];

class DragsortPage extends StatefulWidget {
  const DragsortPage({super.key});

  @override
  State<DragsortPage> createState() => _DragsortPageState();
}

class _DragsortPageState extends State<DragsortPage> {
  String _lastOrder = '';

  void _handleDragEnd(List sorted) {
    setState(() {
      _lastOrder = sorted
          .map((item) => item is Map ? '${item['label']}' : '$item')
          .join('、');
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: '拖动排序',
      child: Container(
        key: const ValueKey('example-page-componentsD/dragsort/dragsort'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: UPAlert(description: 'PC端查看时需要触摸仿真模式才会正确计算位置'),
            ),
            ExampleDemoBlock(
              title: '单列多行模式',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  // UPDragSort scrolls internally, so it needs a bounded height
                  // inside this page's own scroll view.
                  height: 300,
                  child: UPDragSort(
                    key: const ValueKey('dragsort-page-vertical'),
                    initialList: _list,
                    onDragEnd: _handleDragEnd,
                    itemBuilder: (context, item, index) =>
                        _item(tokens, item, index: index),
                  ),
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '自定义拖动句柄',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: 300,
                  child: UPDragSort(
                    key: const ValueKey('dragsort-page-handler'),
                    initialList: _list,
                    onDragEnd: _handleDragEnd,
                    itemBuilder: (context, item, index) =>
                        _item(tokens, item, index: index),
                    // Source `handler` slot: a grip drawn beside each row.
                    handlerBuilder: (context, item, index) => Container(
                      width: 24,
                      alignment: Alignment.center,
                      child: Container(
                        width: 14,
                        height: 3,
                        decoration: BoxDecoration(
                          color: tokens.tipsColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '多行多列模式',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: 300,
                  child: UPDragSort(
                    key: const ValueKey('dragsort-page-grid'),
                    initialList: _list,
                    draggable: true,
                    columns: 3,
                    direction: 'all',
                    onDragEnd: _handleDragEnd,
                    itemBuilder: (context, item, index) => _item(tokens, item),
                  ),
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '单行横向拖动',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: 80,
                  child: UPDragSort(
                    key: const ValueKey('dragsort-page-horizontal'),
                    initialList: _list2,
                    draggable: true,
                    direction: 'horizontal',
                    onDragEnd: _handleDragEnd,
                    itemBuilder: (context, item, index) => _item(tokens, item),
                  ),
                ),
              ),
            ),
            if (_lastOrder.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  '拖拽结束，新的顺序：$_lastOrder',
                  style: TextStyle(color: tokens.contentColor, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Source `.custom-item`: padded, centered, bordered, 8px radius. The vertical
  /// demos also prefix the 1-based index.
  Widget _item(UPThemeTokens tokens, dynamic item, {int? index}) {
    final label = item is Map ? '${item['label'] ?? ''}' : '$item';
    return Container(
      padding: const EdgeInsets.all(10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tokens.bgColor,
        border: Border.all(color: tokens.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        index == null ? label : '序号：${index + 1} - $label',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: tokens.mainColor, fontSize: 13),
      ),
    );
  }
}
