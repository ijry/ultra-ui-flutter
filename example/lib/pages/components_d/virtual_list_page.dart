import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class VirtualListPage extends StatefulWidget {
  const VirtualListPage({super.key});

  @override
  State<VirtualListPage> createState() => _VirtualListPageState();
}

class _VirtualListPageState extends State<VirtualListPage> {
  late final List<Map<String, dynamic>> _items;
  double _scrollTop = 0;

  @override
  void initState() {
    super.initState();
    _items = List<Map<String, dynamic>>.generate(
      10000,
      (index) => <String, dynamic>{
        'id': index,
        'name': 'Item $index',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '虚拟列表',
      child: Container(
        key: const ValueKey('example-page-componentsD/virtualList/virtualList'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '基本使用',
              child: UPVirtualList(
                key: const ValueKey('virtual-list-page-basic'),
                listData: _items,
                itemHeight: 49,
                height: '800px',
                keyField: 'id',
                scrollTop: _scrollTop,
                onUpdateScrollTop: (value) {
                  setState(() => _scrollTop = value);
                },
                itemBuilder: (context, item, index) => UPCell(
                  title: 'Item ${item['id']}',
                ),
              ),
            ),
            Padding(
              key: const ValueKey('virtual-list-page-result'),
              padding: const EdgeInsets.all(16),
              child: Text('滚动位置：${_scrollTop.toStringAsFixed(0)}'),
            ),
          ],
        ),
      ),
    );
  }
}
