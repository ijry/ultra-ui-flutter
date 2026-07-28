import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _value1 = '';
  String _value2 = '天山雪莲';
  String _value3 = '';
  String _value4 = '';
  String _value5 = '';
  String _value6 = '';
  String _value7 = '';
  String _value8 = '';
  String _value9 = '';
  String _value10 = '';
  String _value11 = '';
  String _value12 = '';
  String _value13 = '';
  String _value14 = '';
  String _value15 = '';

  void _showIconToast() {
    UPToast.show(context, message: '点击了左侧图标');
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '搜索',
      child: Container(
        key: const ValueKey('example-page-componentsB/search/search'),
        child: Column(
          children: <Widget>[
            _SearchBlock(
              title: '基础功能',
              child: KeyedSubtree(
                key: const ValueKey('search-page-basic'),
                child: UPSearch(
                  value: _value1,
                  showAction: false,
                  onChange: (value) => setState(() => _value1 = value),
                ),
              ),
            ),
            _SearchBlock(
              title: '设置初始值',
              child: UPSearch(
                value: _value2,
                showAction: false,
                onChange: (value) => setState(() => _value2 = value),
              ),
            ),
            _SearchBlock(
              title: '搜索框形状',
              child: Column(
                children: <Widget>[
                  UPSearch(
                    value: _value3,
                    showAction: false,
                    shape: 'round',
                    onChange: (value) => setState(() => _value3 = value),
                  ),
                  const SizedBox(height: 10),
                  UPSearch(
                    value: _value4,
                    showAction: false,
                    shape: 'square',
                    onChange: (value) => setState(() => _value4 = value),
                  ),
                ],
              ),
            ),
            _SearchBlock(
              title: '右侧控件',
              child: UPSearch(
                value: _value5,
                animation: true,
                onChange: (value) => setState(() => _value5 = value),
              ),
            ),
            _SearchBlock(
              title: '可清空内容(仅focus时显示清除图标)',
              child: UPSearch(
                value: _value2,
                showAction: false,
                clearable: true,
                onChange: (value) => setState(() => _value2 = value),
              ),
            ),
            _SearchBlock(
              title: '可清空内容(始终显示清除图标)',
              child: UPSearch(
                value: _value2,
                showAction: false,
                clearable: true,
                onlyClearableOnFocused: false,
                onChange: (value) => setState(() => _value2 = value),
              ),
            ),
            const _SearchBlock(
              title: '禁用输入框',
              child: UPSearch(
                placeholder: '输入框被禁用,可以监听点击事件进行跳转',
                disabled: true,
                showAction: false,
              ),
            ),
            _SearchBlock(
              title: '点击左侧图标',
              child: KeyedSubtree(
                key: const ValueKey('search-page-click-icon'),
                child: UPSearch(
                  value: _value6,
                  showAction: false,
                  onClickIcon: (_) => _showIconToast(),
                  onChange: (value) => setState(() => _value6 = value),
                ),
              ),
            ),
            _SearchBlock(
              title: '搜索框内容水平对齐',
              child: Column(
                children: <Widget>[
                  UPSearch(
                    value: _value7,
                    showAction: false,
                    inputAlign: 'left',
                    onChange: (value) => setState(() => _value7 = value),
                  ),
                  const SizedBox(height: 10),
                  UPSearch(
                    value: _value8,
                    showAction: false,
                    inputAlign: 'center',
                    onChange: (value) => setState(() => _value8 = value),
                  ),
                  const SizedBox(height: 10),
                  UPSearch(
                    value: _value9,
                    showAction: false,
                    inputAlign: 'right',
                    onChange: (value) => setState(() => _value9 = value),
                  ),
                ],
              ),
            ),
            _SearchBlock(
              title: '自定义',
              child: Column(
                children: <Widget>[
                  UPSearch(
                    value: _value10,
                    showAction: false,
                    borderColor: 'rgb(230, 230, 230)',
                    onChange: (value) => setState(() => _value10 = value),
                  ),
                  const SizedBox(height: 10),
                  UPSearch(
                    value: _value11,
                    showAction: false,
                    searchIconColor: '#FF0000',
                    onChange: (value) => setState(() => _value11 = value),
                  ),
                  const SizedBox(height: 10),
                  UPSearch(
                    value: _value12,
                    showAction: false,
                    placeholderColor: '#FF0000',
                    onChange: (value) => setState(() => _value12 = value),
                  ),
                  const SizedBox(height: 10),
                  UPSearch(
                    value: _value13,
                    showAction: false,
                    color: '#FF0000',
                    onChange: (value) => setState(() => _value13 = value),
                  ),
                  const SizedBox(height: 10),
                  UPSearch(
                    value: _value14,
                    label: '手机',
                    showAction: false,
                    onChange: (value) => setState(() => _value14 = value),
                  ),
                  const SizedBox(height: 10),
                  UPSearch(
                    value: _value15,
                    searchIcon: 'scan',
                    showAction: false,
                    onChange: (value) => setState(() => _value15 = value),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBlock extends StatelessWidget {
  const _SearchBlock({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}
