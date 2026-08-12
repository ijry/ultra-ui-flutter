import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

const List<Map<String, dynamic>> _treeData = <Map<String, dynamic>>[
  <String, dynamic>{
    'id': 'root',
    'label': '根节点',
    'children': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'child-1',
        'label': '子节点一',
        'children': <Map<String, String>>[
          <String, String>{'id': 'grandchild-1', 'label': '孙节点一'},
        ],
      },
      <String, dynamic>{'id': 'child-2', 'label': '子节点二'},
      <String, dynamic>{
        'id': 'disabled',
        'label': '禁用节点',
        'disabled': true,
      },
    ],
  },
];

const List<String> _treeKeyOrder = <String>[
  'root',
  'child-1',
  'grandchild-1',
  'child-2',
  'disabled',
];

class TreePage extends StatefulWidget {
  const TreePage({super.key});

  @override
  State<TreePage> createState() => _TreePageState();
}

class _TreePageState extends State<TreePage> {
  final GlobalKey<UPTreeState> _checkboxTreeKey = GlobalKey<UPTreeState>();
  List<String> _checkedKeys = const <String>[];

  void _refreshCheckedKeys() {
    final treeState = _checkboxTreeKey.currentState;
    if (treeState == null) return;

    final checkedKeys =
        treeState.getCheckedKeys().map((key) => '$key').toList();
    checkedKeys.sort(
      (a, b) => _treeKeyOrder.indexOf(a).compareTo(_treeKeyOrder.indexOf(b)),
    );
    if (!mounted) return;
    setState(() => _checkedKeys = checkedKeys);
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '树形',
      child: Container(
        key: const ValueKey('example-page-componentsD/tree/tree'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '基础功能',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: const UPTree(
                  key: ValueKey('tree-page-basic'),
                  data: _treeData,
                  defaultExpandAll: true,
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '复选框',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    KeyedSubtree(
                      key: const ValueKey('tree-page-checkbox'),
                      child: UPTree(
                        key: _checkboxTreeKey,
                        showCheckbox: true,
                        defaultExpandAll: true,
                        defaultCheckedKeys: const <String>[],
                        data: _treeData,
                        onCheckChange: (_, __) => _refreshCheckedKeys(),
                        onCheck: (_) => _refreshCheckedKeys(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('已选：${_checkedKeys.join(',')}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
