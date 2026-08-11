import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class SubsectionPage extends StatefulWidget {
  const SubsectionPage({super.key});

  @override
  State<SubsectionPage> createState() => _SubsectionPageState();
}

class _SubsectionPageState extends State<SubsectionPage> {
  static const List<String> _items = <String>[
    '未付款',
    '待评价',
    '已付款',
  ];

  static const List<Map<String, dynamic>> _customItems = <Map<String, dynamic>>[
    <String, dynamic>{
      'name': '禁用',
      'textColor': '#FF4D4D',
    },
    <String, dynamic>{
      'name': '启用',
      'textColor': '#00CC88',
    },
    <String, dynamic>{
      'name': '未激活文字',
      'inactiveColorKey': 'pink',
    },
  ];

  int _basicIndex = 0;
  int _buttonIndex = 0;
  int _themeIndex = 0;
  int _defaultIndex = 1;
  int _customIndex = 0;

  int _basicChanges = 0;
  int _buttonChanges = 0;
  int _themeChanges = 0;
  int _defaultChanges = 0;
  int _customChanges = 0;

  void _setBasic(int index) {
    if (!mounted) return;
    setState(() {
      _basicIndex = index;
      _basicChanges += 1;
    });
  }

  void _setButton(int index) {
    if (!mounted) return;
    setState(() {
      _buttonIndex = index;
      _buttonChanges += 1;
    });
  }

  void _setTheme(int index) {
    if (!mounted) return;
    setState(() {
      _themeIndex = index;
      _themeChanges += 1;
    });
  }

  void _setDefault(int index) {
    if (!mounted) return;
    setState(() {
      _defaultIndex = index;
      _defaultChanges += 1;
    });
  }

  void _setCustom(int index) {
    if (!mounted) return;
    setState(() {
      _customIndex = index;
      _customChanges += 1;
    });
  }

  Widget _enabledBlock({
    required String title,
    required Widget subsection,
    required String indexLabel,
    required String changeLabel,
  }) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            subsection,
            const SizedBox(height: 8),
            Text(indexLabel),
            Text(changeLabel),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      key: const ValueKey('example-page-componentsC/subsection/subsection'),
      title: '分段器',
      child: Column(
        children: <Widget>[
          _enabledBlock(
            title: '基础使用',
            subsection: UPSubsection(
              key: const ValueKey('subsection-page-basic'),
              list: _items,
              mode: 'subsection',
              current: _basicIndex,
              onChange: _setBasic,
            ),
            indexLabel: '基础索引：$_basicIndex',
            changeLabel: '基础变化次数：$_basicChanges',
          ),
          _enabledBlock(
            title: '按钮模式',
            subsection: UPSubsection(
              key: const ValueKey('subsection-page-button'),
              list: _items,
              mode: 'button',
              current: _buttonIndex,
              onChange: _setButton,
            ),
            indexLabel: '按钮索引：$_buttonIndex',
            changeLabel: '按钮变化次数：$_buttonChanges',
          ),
          _enabledBlock(
            title: '更换主题',
            subsection: UPSubsection(
              key: const ValueKey('subsection-page-theme'),
              list: _items,
              mode: 'subsection',
              current: _themeIndex,
              activeColor: '#f56c6c',
              onChange: _setTheme,
            ),
            indexLabel: '主题索引：$_themeIndex',
            changeLabel: '主题变化次数：$_themeChanges',
          ),
          _enabledBlock(
            title: '默认位置',
            subsection: UPSubsection(
              key: const ValueKey('subsection-page-default'),
              list: _items,
              mode: 'button',
              current: _defaultIndex,
              activeColor: '#f9ae3d',
              onChange: _setDefault,
            ),
            indexLabel: '默认索引：$_defaultIndex',
            changeLabel: '默认变化次数：$_defaultChanges',
          ),
          _enabledBlock(
            title: '按钮模式通过list自定义颜色',
            subsection: UPSubsection(
              key: const ValueKey('subsection-page-custom-colors'),
              list: _customItems,
              mode: 'button',
              current: _customIndex,
              activeColorKeyName: 'textColor',
              onChange: _setCustom,
            ),
            indexLabel: '自定义颜色索引：$_customIndex',
            changeLabel: '自定义颜色变化次数：$_customChanges',
          ),
          ExampleDemoBlock(
            title: '禁用',
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: <Widget>[
                  UPSubsection(
                    key: const ValueKey('subsection-page-disabled-button'),
                    list: _customItems,
                    mode: 'button',
                    disabled: true,
                    activeColorKeyName: 'textColor',
                  ),
                  const SizedBox(height: 20),
                  UPSubsection(
                    key: const ValueKey('subsection-page-disabled-subsection'),
                    list: _items,
                    mode: 'subsection',
                    disabled: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
