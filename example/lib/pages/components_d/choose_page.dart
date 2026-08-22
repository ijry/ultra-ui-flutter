import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

const List<Map<String, Object>> _options1 = <Map<String, Object>>[
  <String, Object>{'id': 1, 'title': '选项1'},
  <String, Object>{'id': 2, 'title': '选项2'},
  <String, Object>{'id': 3, 'title': '选项3'},
  <String, Object>{'id': 4, 'title': '选项4'},
  <String, Object>{'id': 5, 'title': '选项5'},
  <String, Object>{'id': 6, 'title': '选项6'},
];

const List<Map<String, Object>> _options2 = <Map<String, Object>>[
  <String, Object>{'id': 1, 'title': '选项A'},
  <String, Object>{'id': 2, 'title': '选项B'},
  <String, Object>{'id': 3, 'title': '选项C'},
  <String, Object>{'id': 4, 'title': '选项D'},
  <String, Object>{'id': 5, 'title': '选项E'},
  <String, Object>{'id': 6, 'title': '选项F'},
];

const List<Map<String, Object>> _options3 = <Map<String, Object>>[
  <String, Object>{'id': 1, 'title': '9:00-10:00'},
  <String, Object>{'id': 2, 'title': '10:00-11:00'},
  <String, Object>{'id': 3, 'title': '11:00-12:00'},
  <String, Object>{'id': 4, 'title': '12:00-13:00'},
  <String, Object>{'id': 5, 'title': '13:00-14:00'},
  <String, Object>{'id': 6, 'title': '14:00-15:00'},
  <String, Object>{'id': 7, 'title': '15:00-16:00'},
  <String, Object>{'id': 8, 'title': '16:00-17:00'},
];

const List<Map<String, Object>> _options4 = <Map<String, Object>>[
  <String, Object>{'id': 1, 'title': '较宽选项1'},
  <String, Object>{'id': 2, 'title': '较宽选项2'},
  <String, Object>{'id': 3, 'title': '较宽选项3'},
];

/// Source builds the 12 delivery slots by hand; generating them keeps the three
/// day tabs identical, which is what the source data actually is.
List<Map<String, Object>> _deliveryTimes() => <Map<String, Object>>[
      for (var i = 0; i < 12; i++)
        <String, Object>{'id': i + 1, 'title': '${9 + i}:00-${10 + i}:00'},
    ];

class ChoosePage extends StatefulWidget {
  const ChoosePage({super.key});

  @override
  State<ChoosePage> createState() => _ChoosePageState();
}

class _ChoosePageState extends State<ChoosePage> {
  int _value1 = 0;
  int _value2 = 1;
  int _value5 = 0;
  int _deliveryCurrent = 0;

  late final List<Map<String, Object>> _deliveryOptions = <Map<String, Object>>[
    <String, Object>{
      'name': '今天',
      'selectedIndex': 0,
      'times': _deliveryTimes(),
    },
    <String, Object>{
      'name': '明天',
      'selectedIndex': 0,
      'times': _deliveryTimes(),
    },
    <String, Object>{
      'name': '后天',
      'selectedIndex': 0,
      'times': _deliveryTimes(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: '选项选择器',
      child: Container(
        key: const ValueKey('example-page-componentsD/choose/choose'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '基本用法',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: UPChoose(
                  key: const ValueKey('choose-page-basic'),
                  options: _options1,
                  value: _value1,
                  onChange: (value) =>
                      setState(() => _value1 = value is int ? value : 0),
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '不换行显示',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: UPChoose(
                  key: const ValueKey('choose-page-nowrap'),
                  options: _options2,
                  value: _value2,
                  wrap: false,
                  onChange: (value) =>
                      setState(() => _value2 = value is int ? value : 0),
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '时间选择',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: UPChoose(
                  key: const ValueKey('choose-page-time'),
                  options: _options3,
                  value: _value5,
                  itemWidth: '340rpx',
                  itemHeight: '70rpx',
                  onChange: (value) =>
                      setState(() => _value5 = value is int ? value : 0),
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '快递上门时间预约',
              child: SizedBox(
                height: 300,
                child: UPCateTab(
                  key: const ValueKey('choose-page-delivery'),
                  height: '300px',
                  mode: 'tab',
                  tabList: _deliveryOptions,
                  current: _deliveryCurrent,
                  onUpdateCurrent: (value) =>
                      setState(() => _deliveryCurrent = value),
                  itemListBuilder: (context, item, index) {
                    final map = item as Map;
                    final times = map['times'];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              '${map['name'] ?? ''}',
                              style: TextStyle(color: tokens.contentColor),
                            ),
                          ),
                          UPChoose(
                            options: times is List ? times : const <Object>[],
                            value: map['selectedIndex'],
                            itemWidth: '460rpx',
                            itemHeight: '60rpx',
                            onChange: (value) => setState(() {
                              _deliveryOptions[index]['selectedIndex'] =
                                  value is int ? value : 0;
                            }),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '自定义尺寸',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: UPChoose(
                  key: const ValueKey('choose-page-custom-size'),
                  options: _options4,
                  value: _value5,
                  wrap: false,
                  itemWidth: '250rpx',
                  itemHeight: '220rpx',
                  onChange: (value) =>
                      setState(() => _value5 = value is int ? value : 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
