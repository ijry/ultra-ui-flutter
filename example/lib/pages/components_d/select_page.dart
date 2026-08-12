import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

const List<Map<String, String>> _options = <Map<String, String>>[
  <String, String>{'id': '1', 'name': '选项一'},
  <String, String>{'id': '2', 'name': '选项二'},
  <String, String>{'id': '3', 'name': '选项三'},
];

class SelectPage extends StatefulWidget {
  const SelectPage({super.key});

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  String _current = '1';
  int _selectCount = 0;

  String _labelFor(String value) {
    for (final option in _options) {
      if (option['id'] == value) return option['name']!;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final select = UPSelect(
      key: const ValueKey('select-page-basic'),
      label: '请选择',
      current: _current,
      options: _options,
      border: true,
      showOptionsLabel: true,
      onSelect: (item) => setState(() {
        _current = '${item['id']}';
        _selectCount += 1;
      }),
      onUpdateCurrent: (value) => setState(() => _current = '$value'),
    );

    return ExamplePageScaffold(
      title: '经典下拉框',
      child: Container(
        key: const ValueKey('example-page-componentsD/select/select'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '基础功能',
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: KeyedSubtree(
                  key: const ValueKey('select-page-trigger'),
                  child: select,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('当前选择：${_labelFor(_current)}'),
                  Text('选择次数：$_selectCount'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
