import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

const List<Map<String, String>> _scenesList = <Map<String, String>>[
  <String, String>{'id': '1', 'name': '分类1'},
  <String, String>{'id': '2', 'name': '分类2'},
  // Source data really does label id 3 as "分类4".
  <String, String>{'id': '3', 'name': '分类4'},
];

class SelectPage extends StatefulWidget {
  const SelectPage({super.key});

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  String _cateId = '';
  String _pcSelectId = '';

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: '经典下拉框',
      child: Container(
        key: const ValueKey('example-page-componentsD/select/select'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '默认',
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: UPSelect(
                  key: const ValueKey('select-page-basic'),
                  label: '分类',
                  showOptionsLabel: true,
                  options: _scenesList,
                  current: _cateId,
                  onUpdateCurrent: (value) =>
                      setState(() => _cateId = '$value'),
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '插槽',
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: UPSelect(
                  key: const ValueKey('select-page-slot'),
                  label: '分类',
                  showOptionsLabel: true,
                  options: _scenesList,
                  current: _cateId,
                  onUpdateCurrent: (value) =>
                      setState(() => _cateId = '$value'),
                  // Source `optionItem` slot renders just the name as text.
                  optionItemBuilder: (item) => Text(
                    '${item['name'] ?? ''}',
                    style: TextStyle(color: tokens.mainColor, fontSize: 14),
                  ),
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '边框与下拉宽度',
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: UPSelect(
                  key: const ValueKey('select-page-border'),
                  label: '请选择分类',
                  showOptionsLabel: true,
                  options: _scenesList,
                  border: true,
                  optionsWidth: '100%',
                  current: _pcSelectId,
                  onUpdateCurrent: (value) =>
                      setState(() => _pcSelectId = '$value'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
