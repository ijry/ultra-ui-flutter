import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

/// Source `defaultProps`.
const Map<String, String> _defaultProps = <String, String>{
  'label': 'label',
  'children': 'children',
  'nodeKey': 'id',
  'disabled': 'disabled',
};

const List<Map<String, Object>> _treeData = <Map<String, Object>>[
  <String, Object>{
    'id': '1',
    'label': '一级 1',
    'children': <Map<String, Object>>[
      <String, Object>{
        'id': '1-1',
        'label': '二级 1-1',
        'children': <Map<String, Object>>[
          <String, Object>{'id': '1-1-1', 'label': '三级 1-1-1'},
          <String, Object>{'id': '1-1-2', 'label': '三级 1-1-2'},
        ],
      },
      <String, Object>{'id': '1-2', 'label': '二级 1-2'},
    ],
  },
  <String, Object>{
    'id': '2',
    'label': '一级 2',
    'children': <Map<String, Object>>[
      <String, Object>{'id': '2-1', 'label': '二级 2-1'},
      <String, Object>{'id': '2-2', 'label': '二级 2-2'},
    ],
  },
];

const List<Map<String, Object>> _customTreeData = <Map<String, Object>>[
  <String, Object>{
    'id': 'custom-1',
    'label': '设计资源',
    'tag': '目录',
    'children': <Map<String, Object>>[
      <String, Object>{'id': 'custom-1-1', 'label': '组件规范', 'tag': '文档'},
      <String, Object>{'id': 'custom-1-2', 'label': '图标资产', 'tag': '资源'},
    ],
  },
];

const List<Map<String, Object>> _checkTreeData = <Map<String, Object>>[
  <String, Object>{
    'id': '2',
    'label': '表单组件',
    'children': <Map<String, Object>>[
      <String, Object>{
        'id': '2-1',
        'label': '输入组件',
        'children': <Map<String, Object>>[
          <String, Object>{'id': '2-1-1', 'label': 'Input 输入框'},
          <String, Object>{'id': '2-1-2', 'label': 'Textarea 文本域'},
        ],
      },
      <String, Object>{
        'id': '2-2',
        'label': '选择组件',
        'children': <Map<String, Object>>[
          <String, Object>{'id': '2-2-1', 'label': 'Select 选择器'},
          <String, Object>{
            'id': '2-2-2',
            'label': 'Picker 选择器',
            'disabled': true,
          },
        ],
      },
    ],
  },
];

const List<Map<String, Object>> _accordionTreeData = <Map<String, Object>>[
  <String, Object>{
    'id': 'a',
    'label': '导航组件',
    'children': <Map<String, Object>>[
      <String, Object>{'id': 'a-1', 'label': 'Navbar 导航栏'},
      <String, Object>{'id': 'a-2', 'label': 'Tabbar 底部导航栏'},
    ],
  },
  <String, Object>{
    'id': 'b',
    'label': '反馈组件',
    'children': <Map<String, Object>>[
      <String, Object>{'id': 'b-1', 'label': 'Toast 消息提示'},
      <String, Object>{'id': 'b-2', 'label': 'Notify 通知'},
    ],
  },
];

class TreePage extends StatefulWidget {
  const TreePage({super.key});

  @override
  State<TreePage> createState() => _TreePageState();
}

class _TreePageState extends State<TreePage> {
  final GlobalKey<UPTreeState> _checkTree = GlobalKey<UPTreeState>();

  /// Source seeds this from its own `defaultCheckedKeys`.
  String _checkedKeysText = '2-1-1';

  void _handleCheck(Map state) {
    final keys = state['checkedKeys'];
    if (keys is! List) return;
    setState(() => _checkedKeysText = keys.join('、'));
  }

  void _setCheckedKeys() {
    final tree = _checkTree.currentState;
    if (tree == null) return;
    tree.setCheckedKeys(const <String>['2-1-2', '2-2-1']);
    setState(() => _checkedKeysText = tree.getCheckedKeys().join('、'));
  }

  void _getCheckedKeys() {
    final tree = _checkTree.currentState;
    if (tree == null) return;
    setState(() => _checkedKeysText = tree.getCheckedKeys().join('、'));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: '树形',
      child: Container(
        key: const ValueKey('example-page-componentsD/tree/tree'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const ExampleDemoBlock(
              title: '基础用法',
              child: Padding(
                padding: EdgeInsets.all(12),
                child: UPTree(
                  key: ValueKey('tree-page-basic'),
                  data: _treeData,
                  props: _defaultProps,
                  defaultExpandedKeys: <String>['1'],
                  highlightCurrent: true,
                  currentNodeKey: '1',
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '自定义节点',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: UPTree(
                  key: const ValueKey('tree-page-custom-node'),
                  data: _customTreeData,
                  props: _defaultProps,
                  defaultExpandAll: true,
                  indent: 40,
                  // Source default slot, scoped {node, level, expanded}.
                  nodeBuilder: (
                    node, {
                    required level,
                    required expanded,
                    required checked,
                    required indeterminate,
                    required disabled,
                  }) {
                    final tag = node['tag'];
                    final children = node['children'];
                    final hasChildren = children is List && children.isNotEmpty;
                    return Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            '${node['label'] ?? ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: tokens.mainColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (tag != null) ...<Widget>[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: tokens.primaryLight,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '$tag',
                              style: TextStyle(
                                color: tokens.primary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                        if (hasChildren) ...<Widget>[
                          const SizedBox(width: 6),
                          Text(
                            '${expanded ? '已展开' : '已收起'} · $level级',
                            style: TextStyle(
                              color: tokens.tipsColor,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
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
                    UPTree(
                      key: _checkTree,
                      data: _checkTreeData,
                      props: _defaultProps,
                      showCheckbox: true,
                      defaultExpandAll: true,
                      checkOnClickNode: true,
                      defaultCheckedKeys: const <String>['2-1-1'],
                      onCheck: _handleCheck,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: <Widget>[
                          UPButton(
                            key: const ValueKey('tree-page-set-checked'),
                            size: 'mini',
                            type: 'primary',
                            text: '设置选中',
                            onClick: _setCheckedKeys,
                          ),
                          const SizedBox(width: 8),
                          UPButton(
                            key: const ValueKey('tree-page-get-checked'),
                            size: 'mini',
                            text: '读取选中',
                            onClick: _getCheckedKeys,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '当前选中：$_checkedKeysText',
                        style: TextStyle(
                          color: tokens.contentColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const ExampleDemoBlock(
              title: '手风琴模式',
              child: Padding(
                padding: EdgeInsets.all(12),
                child: UPTree(
                  key: ValueKey('tree-page-accordion'),
                  data: _accordionTreeData,
                  props: _defaultProps,
                  accordion: true,
                  expandOnClickNode: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
