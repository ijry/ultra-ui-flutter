import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

/// 地区数据（省市区）
const List<Map<String, Object>> _areaData = <Map<String, Object>>[
  <String, Object>{
    'label': '北京市',
    'value': '11',
    'children': <Map<String, Object>>[
      <String, Object>{
        'label': '北京市',
        'value': '1101',
        'children': <Map<String, Object>>[
          <String, Object>{'label': '东城区', 'value': '110101'},
          <String, Object>{'label': '西城区', 'value': '110102'},
          <String, Object>{'label': '朝阳区', 'value': '110105'},
        ],
      },
    ],
  },
  <String, Object>{
    'label': '广东省',
    'value': '44',
    'children': <Map<String, Object>>[
      <String, Object>{
        'label': '广州市',
        'value': '4401',
        'children': <Map<String, Object>>[
          <String, Object>{'label': '越秀区', 'value': '440103'},
          <String, Object>{'label': '荔湾区', 'value': '440103'},
          <String, Object>{'label': '海珠区', 'value': '440105'},
        ],
      },
      <String, Object>{
        'label': '深圳市',
        'value': '4403',
        'children': <Map<String, Object>>[
          <String, Object>{'label': '罗湖区', 'value': '440303'},
          <String, Object>{'label': '福田区', 'value': '440304'},
        ],
      },
    ],
  },
];

/// 商品分类数据
const List<Map<String, Object>> _categoryData = <Map<String, Object>>[
  <String, Object>{
    'label': '服装',
    'value': '1',
    'children': <Map<String, Object>>[
      <String, Object>{
        'label': '上装',
        'value': '1-1',
        'children': <Map<String, Object>>[
          <String, Object>{'label': 'T恤', 'value': '1-1-1'},
          <String, Object>{'label': '衬衫', 'value': '1-1-2'},
        ],
      },
      <String, Object>{
        'label': '下装',
        'value': '1-2',
        'children': <Map<String, Object>>[
          <String, Object>{'label': '裤子', 'value': '1-2-1'},
          <String, Object>{'label': '裙子', 'value': '1-2-2'},
        ],
      },
    ],
  },
  <String, Object>{
    'label': '数码',
    'value': '2',
    'children': <Map<String, Object>>[
      <String, Object>{
        'label': '手机',
        'value': '2-1',
        'children': <Map<String, Object>>[
          <String, Object>{'label': '智能手机', 'value': '2-1-1'},
          <String, Object>{'label': '功能手机', 'value': '2-1-2'},
        ],
      },
      <String, Object>{
        'label': '电脑',
        'value': '2-2',
        'children': <Map<String, Object>>[
          <String, Object>{'label': '笔记本', 'value': '2-2-1'},
          <String, Object>{'label': '台式机', 'value': '2-2-2'},
        ],
      },
    ],
  },
];

/// 组织架构数据（自定义字段名）
const List<Map<String, Object>> _orgData = <Map<String, Object>>[
  <String, Object>{
    'name': '总部',
    'id': '1',
    'childs': <Map<String, Object>>[
      <String, Object>{
        'name': '研发部',
        'id': '1-1',
        'childs': <Map<String, Object>>[
          <String, Object>{'name': '前端组', 'id': '1-1-1'},
          <String, Object>{'name': '后端组', 'id': '1-1-2'},
        ],
      },
      <String, Object>{
        'name': '市场部',
        'id': '1-2',
        'childs': <Map<String, Object>>[
          <String, Object>{'name': '销售组', 'id': '1-2-1'},
          <String, Object>{'name': '推广组', 'id': '1-2-2'},
        ],
      },
    ],
  },
];

class CascaderPage extends StatefulWidget {
  const CascaderPage({super.key});

  @override
  State<CascaderPage> createState() => _CascaderPageState();
}

class _CascaderPageState extends State<CascaderPage> {
  bool _show1 = false;
  List<dynamic> _result1 = const <dynamic>[];

  bool _show2 = false;
  List<dynamic> _result2 = const <dynamic>[];
  static const List<String> _defaultCategory = <String>['2', '2-2'];

  bool _show3 = false;
  List<dynamic> _result3 = const <dynamic>[];

  bool _show4 = false;
  List<dynamic> _result4 = const <dynamic>[];

  String _format(List<dynamic> result) =>
      result.isEmpty ? '' : result.join(' / ');

  Widget _selected(List<dynamic> result, UPThemeTokens tokens) {
    if (result.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        '已选择：${_format(result)}',
        style: TextStyle(color: tokens.mainColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: '级联选择器',
      child: Container(
        key: const ValueKey('example-page-componentsD/cascader/cascader'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '基础用法',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    UPButton(
                      key: const ValueKey('cascader-page-open-1'),
                      text: '选择地区',
                      onClick: () => setState(() => _show1 = true),
                    ),
                    _selected(_result1, tokens),
                    UPCascader(
                      show: _show1,
                      data: _areaData,
                      // Source keys results by label in this demo.
                      valueKey: 'label',
                      value: _result1,
                      onUpdateShow: (value) => setState(() => _show1 = value),
                      onUpdateModelValue: (value) =>
                          setState(() => _result1 = value),
                    ),
                  ],
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '带默认值',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    UPButton(
                      key: const ValueKey('cascader-page-open-2'),
                      text: '选择商品分类',
                      onClick: () => setState(() => _show2 = true),
                    ),
                    _selected(_result2, tokens),
                    UPCascader(
                      show: _show2,
                      data: _categoryData,
                      headerDirection: 'column',
                      value: _defaultCategory,
                      onUpdateShow: (value) => setState(() => _show2 = value),
                      onConfirm: (value) => setState(() => _result2 = value),
                    ),
                  ],
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '自定义字段名',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    UPButton(
                      key: const ValueKey('cascader-page-open-3'),
                      text: '选择组织架构',
                      onClick: () => setState(() => _show3 = true),
                    ),
                    _selected(_result3, tokens),
                    UPCascader(
                      show: _show3,
                      data: _orgData,
                      valueKey: 'id',
                      labelKey: 'name',
                      childrenKey: 'childs',
                      onUpdateShow: (value) => setState(() => _show3 = value),
                      onConfirm: (value) => setState(() => _result3 = value),
                    ),
                  ],
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '垂直头部及单列选项',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    UPButton(
                      key: const ValueKey('cascader-page-open-4'),
                      text: '选择商品分类',
                      onClick: () => setState(() => _show4 = true),
                    ),
                    _selected(_result4, tokens),
                    UPCascader(
                      show: _show4,
                      data: _categoryData,
                      headerDirection: 'column',
                      optionsCols: 1,
                      value: _defaultCategory,
                      onUpdateShow: (value) => setState(() => _show4 = value),
                      onConfirm: (value) => setState(() => _result4 = value),
                    ),
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
