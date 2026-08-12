import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class DragsortPage extends StatefulWidget {
  const DragsortPage({super.key});

  @override
  State<DragsortPage> createState() => _DragsortPageState();
}

class _DragsortPageState extends State<DragsortPage> {
  List<String> _items = <String>['第一项', '第二项', '第三项'];
  int _dragChanges = 0;

  void _handleDragEnd(List items) {
    setState(() {
      _items = items.cast<String>();
      _dragChanges += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '拖动排序',
      scrollable: false,
      child: Container(
        key: const ValueKey('example-page-componentsD/dragsort/dragsort'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '基础功能',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: 220,
                  child: UPDragSort(
                    key: const ValueKey('dragsort-page-basic'),
                    initialList: _items,
                    direction: 'vertical',
                    itemBuilder: (context, item, index) => Container(
                      key: ValueKey('dragsort-page-item-$index'),
                      padding: const EdgeInsets.all(16),
                      child: Text('$item'),
                    ),
                    handlerBuilder: (context, item, index) => Icon(
                      Icons.drag_handle,
                      key: ValueKey('dragsort-page-handle-$index'),
                    ),
                    onDragEnd: _handleDragEnd,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text('排序：${_items.join(',')}'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text('拖动次数：$_dragChanges'),
            ),
          ],
        ),
      ),
    );
  }
}
