import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

const List<Map<String, dynamic>> _categories = <Map<String, dynamic>>[
  <String, dynamic>{
    'name': '食品',
    'children': <Map<String, String>>[
      <String, String>{'name': '米饭'},
      <String, String>{'name': '面条'},
    ],
  },
  <String, dynamic>{
    'name': '饮料',
    'children': <Map<String, String>>[
      <String, String>{'name': '可乐'},
      <String, String>{'name': '果汁'},
    ],
  },
  <String, dynamic>{
    'name': '水果',
    'children': <Map<String, String>>[
      <String, String>{'name': '苹果'},
      <String, String>{'name': '香蕉'},
    ],
  },
];

class CateTabPage extends StatefulWidget {
  const CateTabPage({super.key});

  @override
  State<CateTabPage> createState() => _CateTabPageState();
}

class _CateTabPageState extends State<CateTabPage> {
  int _followIndex = 0;
  int _followChanges = 0;
  int _tabIndex = 0;
  int _tabChanges = 0;

  String _categoryName(int index) => '${_categories[index]['name']}';

  Widget _itemBuilder(
    BuildContext context,
    dynamic item,
    int tabIndex,
    int itemIndex,
  ) {
    return SizedBox(
      height: 160,
      child: ListTile(
        title: Text('${item['name']}'),
        subtitle: Text('${_categories[tabIndex]['name']} · 项目$itemIndex'),
      ),
    );
  }

  Widget _followTabBuilder(
    BuildContext context,
    dynamic tab,
    int index,
    bool active,
  ) {
    return Listener(
      onPointerDown: (_) => setState(() => _followChanges += 1),
      child: Text(
        '${tab['name']}',
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '垂直TAB',
      child: Container(
        key: const ValueKey('example-page-componentsD/cateTab/cateTab'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '左右联动',
              child: UPCateTab(
                key: const ValueKey('cate-tab-page-follow'),
                mode: 'follow',
                height: '320px',
                tabList: _categories,
                current: 0,
                itemBuilder: _itemBuilder,
                tabBuilder: _followTabBuilder,
                onChange: (index) => setState(() {
                  _followIndex = index;
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('当前分类：${_categoryName(_followIndex)}'),
                  Text('分类变化次数：$_followChanges'),
                ],
              ),
            ),
            ExampleDemoBlock(
              title: '左右独立',
              child: UPCateTab(
                key: const ValueKey('cate-tab-page-tab'),
                mode: 'tab',
                height: '320px',
                tabList: _categories,
                current: _tabIndex,
                itemBuilder: _itemBuilder,
                onChange: (index) => setState(() {
                  if (index != _tabIndex) _tabChanges += 1;
                  _tabIndex = index;
                }),
                onUpdateCurrent: (index) => setState(() {
                  _tabIndex = index;
                }),
                onUpdateModelValue: (index) => setState(() {
                  _tabIndex = index;
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('当前TAB：${_categoryName(_tabIndex)}'),
                  Text('TAB变化次数：$_tabChanges'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
