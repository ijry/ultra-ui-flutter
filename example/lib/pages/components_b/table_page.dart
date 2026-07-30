import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  int _borderColorIndex = 0;
  int _alignIndex = 1;

  static const List<String> _borderColorLabels = <String>[
    'gray',
    'primary',
    'warning',
  ];
  static const List<String> _borderColorValues = <String>[
    '#e4e7ed',
    '#2979ff',
    '#ff9900',
  ];
  static const List<String> _alignLabels = <String>['左', '中', '右'];
  static const List<String> _alignValues = <String>[
    'left',
    'center',
    'right',
  ];

  String get _borderColorLabel => _borderColorLabels[_borderColorIndex];
  String get _borderColor => _borderColorValues[_borderColorIndex];
  String get _align => _alignValues[_alignIndex];

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '表格',
      child: Container(
        key: const ValueKey('example-page-componentsB/table/table'),
        child: Column(
          children: <Widget>[
            _TableBlock(
              title: '演示效果',
              child: UPTable(
                align: _align,
                borderColor: _borderColor,
                children: const <UPTr>[
                  UPTr(
                    children: <Widget>[
                      UPTh(child: Text('姓名')),
                      UPTh(child: Text('年龄')),
                      UPTh(child: Text('籍贯')),
                      UPTh(child: Text('性别')),
                    ],
                  ),
                  UPTr(
                    children: <Widget>[
                      UPTd(child: Text('吕布')),
                      UPTd(child: Text('22')),
                      UPTd(child: Text('楚河')),
                      UPTd(child: Text('男')),
                    ],
                  ),
                  UPTr(
                    children: <Widget>[
                      UPTd(child: Text('项羽')),
                      UPTd(child: Text('28')),
                      UPTd(child: Text('汉界')),
                      UPTd(child: Text('男')),
                    ],
                  ),
                  UPTr(
                    children: <Widget>[
                      UPTd(child: Text('木兰')),
                      UPTd(child: Text('24')),
                      UPTd(child: Text('南国')),
                      UPTd(child: Text('女')),
                    ],
                  ),
                ],
              ),
            ),
            _ControlBlock(
              key: const ValueKey('table-page-border'),
              title: '边框颜色',
              stateText: '边框颜色：$_borderColorLabel',
              child: UPSubsection(
                list: _borderColorLabels,
                current: _borderColorIndex,
                onChange: (index) {
                  setState(() => _borderColorIndex = index);
                },
              ),
            ),
            _ControlBlock(
              key: const ValueKey('table-page-align'),
              title: '对齐方式',
              stateText: '对齐方式：$_align',
              child: UPSubsection(
                list: _alignLabels,
                current: _alignIndex,
                onChange: (index) {
                  setState(() => _alignIndex = index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableBlock extends StatelessWidget {
  const _TableBlock({required this.title, required this.child});

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

class _ControlBlock extends StatelessWidget {
  const _ControlBlock({
    super.key,
    required this.title,
    required this.stateText,
    required this.child,
  });

  final String title;
  final String stateText;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            child,
            const SizedBox(height: 8),
            Text(stateText),
          ],
        ),
      ),
    );
  }
}
