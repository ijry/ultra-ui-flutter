import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class DropdownPage extends StatefulWidget {
  const DropdownPage({super.key});

  @override
  State<DropdownPage> createState() => _DropdownPageState();
}

class _DropdownPageState extends State<DropdownPage> {
  final GlobalKey<UPDropdownState> _dropdownKey = GlobalKey<UPDropdownState>();

  dynamic _distanceValue = '';
  dynamic _temperatureValue = 2;
  bool _closeOnClickMask = true;
  bool _borderBottom = false;
  String _activeColor = '#2979ff';
  final Set<int> _selectedAttributes = <int>{0};

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '下拉菜单',
      child: Container(
        key: const ValueKey('example-page-componentsB/dropdown/dropdown'),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: UPDropdown(
                key: _dropdownKey,
                activeColor: _activeColor,
                borderBottom: _borderBottom,
                closeOnClickMask: _closeOnClickMask,
                children: <UPDropdownItem>[
                  UPDropdownItem(
                    title: '距离',
                    value: _distanceValue,
                    options: _distanceOptions,
                    onUpdateValue: (value) {
                      setState(() => _distanceValue = value);
                    },
                  ),
                  UPDropdownItem(
                    title: '温度',
                    value: _temperatureValue,
                    options: _temperatureOptions,
                    onUpdateValue: (value) {
                      setState(() => _temperatureValue = value);
                    },
                  ),
                  UPDropdownItem(title: '属性', child: _buildAttributeMenu()),
                ],
              ),
            ),
            ExampleDemoBlock(
              title: '当前选择：${_distanceValue == '' ? '默认排序' : _distanceValue}',
              child: const SizedBox(height: 1),
            ),
            ExampleDemoBlock(
              title: '参数配置',
              child: const SizedBox(height: 1),
            ),
            _ConfigBlock(
              title: '下边框',
              child: UPSubsection(
                current: _borderBottom ? 0 : 1,
                list: const <String>['有', '无'],
                onChange: (index) => setState(() => _borderBottom = index == 0),
              ),
            ),
            _ConfigBlock(
              title: '激活颜色',
              child: UPSubsection(
                current: _activeColors.indexOf(_activeColor),
                list: _activeColors,
                onChange: (index) {
                  setState(() => _activeColor = _activeColors[index]);
                },
              ),
            ),
            _ConfigBlock(
              title: '遮罩是否可点击',
              child: UPSubsection(
                current: _closeOnClickMask ? 0 : 1,
                list: const <String>['是', '否'],
                onChange: (index) {
                  setState(() => _closeOnClickMask = index == 0);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeMenu() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: List<Widget>.generate(_attributeLabels.length, (index) {
              final selected = _selectedAttributes.contains(index);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selected) {
                      _selectedAttributes.remove(index);
                    } else {
                      _selectedAttributes.add(index);
                    }
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        selected ? const Color(0xFF2979FF) : Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: const Color(0xFF2979FF)),
                  ),
                  child: Text(
                    _attributeLabels[index],
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF2979FF),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          UPButton(
            text: '确定',
            type: 'primary',
            onClick: () => _dropdownKey.currentState?.close(),
          ),
        ],
      ),
    );
  }
}

class _ConfigBlock extends StatelessWidget {
  const _ConfigBlock({required this.title, required this.child});

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

const List<Map<String, dynamic>> _distanceOptions = <Map<String, dynamic>>[
  <String, dynamic>{'label': '默认排序', 'value': 1},
  <String, dynamic>{'label': '距离优先', 'value': 2},
  <String, dynamic>{'label': '价格优先', 'value': 3},
];

const List<Map<String, dynamic>> _temperatureOptions = <Map<String, dynamic>>[
  <String, dynamic>{'label': '去冰', 'value': 1},
  <String, dynamic>{'label': '加冰', 'value': 2},
  <String, dynamic>{'label': '正常温', 'value': 3},
  <String, dynamic>{'label': '加热', 'value': 4},
  <String, dynamic>{'label': '极寒风暴', 'value': 5},
];

const List<String> _attributeLabels = <String>[
  '琪花瑶草',
  '清词丽句',
  '宛转蛾眉',
  '煦色韶光',
  '鱼沉雁落',
  '章台杨柳',
  '霞光万道',
];

const List<String> _activeColors = <String>[
  '#2979ff',
  '#ff9900',
  '#19be6b',
];
