import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class TextareaPage extends StatefulWidget {
  const TextareaPage({super.key});

  @override
  State<TextareaPage> createState() => _TextareaPageState();
}

class _TextareaPageState extends State<TextareaPage> {
  String _value1 = '';
  String _value2 = '统计字数';
  String _value3 = '';
  String _value4 = '';
  String _value5 = '';

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '文本域',
      child: Container(
        key: const ValueKey('example-page-componentsC/textarea/textarea'),
        child: Column(
          children: <Widget>[
            _TextareaBlock(
              key: const ValueKey('textarea-page-basic'),
              title: '基础使用',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  UPTextarea(
                    value: _value1,
                    placeholder: '请输入内容',
                    onUpdateValue: (value) => setState(() => _value1 = value),
                  ),
                  const SizedBox(height: 8),
                  Text('基础值：$_value1'),
                ],
              ),
            ),
            _TextareaBlock(
              title: '字数统计',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  UPTextarea(
                    value: _value2,
                    placeholder: '请输入内容',
                    count: true,
                    onUpdateValue: (value) => setState(() => _value2 = value),
                  ),
                  const SizedBox(height: 8),
                  Text(_value2),
                ],
              ),
            ),
            _TextareaBlock(
              title: '自动增高',
              child: UPTextarea(
                value: _value3,
                placeholder: '请输入内容',
                autoHeight: true,
                onUpdateValue: (value) => setState(() => _value3 = value),
              ),
            ),
            _TextareaBlock(
              title: '禁用状态',
              child: UPTextarea(
                value: _value4,
                placeholder: '文本域已被禁用',
                disabled: true,
                count: true,
                onUpdateValue: (value) => setState(() => _value4 = value),
              ),
            ),
            _TextareaBlock(
              title: '下划线模式',
              child: UPTextarea(
                value: _value5,
                placeholder: '请输入内容',
                border: 'bottom',
                onUpdateValue: (value) => setState(() => _value5 = value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextareaBlock extends StatelessWidget {
  const _TextareaBlock({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }
}
