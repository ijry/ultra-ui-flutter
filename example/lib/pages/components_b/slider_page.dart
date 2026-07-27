import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class SliderPage extends StatefulWidget {
  const SliderPage({super.key});

  @override
  State<SliderPage> createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  double _value1 = 30;
  double _value2 = 30;
  double _value3 = 0.3;
  double _value4 = 30;
  double _value5 = 30;
  List<double> _value6 = <double>[10, 20];
  double _value7 = 50;
  List<double> _value8 = <double>[20, 80];
  double _sliderValue = 4;
  bool _modalShow = false;
  bool _popupShow = false;

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '滑动选择器',
      scrollable: false,
      child: Stack(
        children: <Widget>[
          ListView(
            key: const ValueKey('example-page-componentsB/slider/slider'),
            padding: const EdgeInsets.only(bottom: 24),
            children: <Widget>[
              _SliderBlock(
                title: '基本案例',
                child: Column(
                  children: <Widget>[
                    UPSlider(
                      value: _value1,
                      onUpdateValue: (value) {
                        setState(() => _value1 = (value as num).toDouble());
                      },
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('当前值：${_value1.round()}'),
                    ),
                    const SizedBox(height: 8),
                    UPButton(
                      text: '前进',
                      onClick: () => setState(() => _value1 += 1),
                    ),
                  ],
                ),
              ),
              _SliderBlock(
                title: '自定义范围(10—50)',
                child: UPSlider(
                  value: _value2,
                  showValue: true,
                  min: 10,
                  max: 50,
                  onUpdateValue: (value) {
                    setState(() => _value2 = (value as num).toDouble());
                  },
                ),
              ),
              _SliderBlock(
                title: '指定步长(每次步进5)',
                child: UPSlider(
                  value: _value4,
                  step: 5,
                  onUpdateValue: (value) {
                    setState(() => _value4 = (value as num).toDouble());
                  },
                ),
              ),
              _SliderBlock(
                title: '小数步长(每次步进0.1)',
                child: UPSlider(
                  value: _value3,
                  step: 0.1,
                  min: 0,
                  max: 1,
                  showValue: true,
                  onUpdateValue: (value) {
                    setState(() => _value3 = (value as num).toDouble());
                  },
                ),
              ),
              _SliderBlock(
                title: '自定义样式',
                child: UPSlider(
                  value: _value5,
                  activeColor: '#deab8a',
                  blockColor: '#f47920',
                  height: '20px',
                  onUpdateValue: (value) {
                    setState(() => _value5 = (value as num).toDouble());
                  },
                ),
              ),
              _SliderBlock(
                title: '自定义样式(图片)',
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    UPSlider(
                      value: _value5,
                      activeColor: '#deab8a',
                      blockColor: '#f47920',
                      height: '4px',
                      onUpdateValue: (value) {
                        setState(() => _value5 = (value as num).toDouble());
                      },
                    ),
                    const IgnorePointer(
                      child: UPIcon(name: 'photo', color: '#CE4141', size: 32),
                    ),
                  ],
                ),
              ),
              _SliderBlock(
                title: '区间选择(双滑块)',
                child: UPSlider(
                  isRange: true,
                  showValue: true,
                  step: 2,
                  rangeValue: _value6,
                  height: '2px',
                  onUpdateValue: (value) {
                    setState(() => _value6 = _asRange(value));
                  },
                ),
              ),
              _SliderBlock(
                title: '垂直方向',
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    height: 220,
                    width: 80,
                    child: UPSlider(
                      value: _value7,
                      vertical: true,
                      size: '2px',
                      length: '200px',
                      onUpdateValue: (value) {
                        setState(() => _value7 = (value as num).toDouble());
                      },
                    ),
                  ),
                ),
              ),
              _SliderBlock(
                title: '垂直方向区间选择',
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    height: 220,
                    width: 80,
                    child: UPSlider(
                      rangeValue: _value8,
                      isRange: true,
                      vertical: true,
                      size: '2px',
                      length: '200px',
                      onUpdateValue: (value) {
                        setState(() => _value8 = _asRange(value));
                      },
                    ),
                  ),
                ),
              ),
              _SliderBlock(
                title: '在Modal弹窗中使用',
                child: UPText(
                  text: '打开弹窗',
                  color: 'primary',
                  onClick: () => setState(() => _modalShow = true),
                ),
              ),
              _SliderBlock(
                title: '在popup弹窗中使用',
                child: UPText(
                  text: '打开弹窗',
                  color: 'primary',
                  onClick: () => setState(() => _popupShow = true),
                ),
              ),
            ],
          ),
          if (_modalShow)
            UPModal(
              show: true,
              showConfirmButton: false,
              closeOnClickOverlay: true,
              onClose: () => setState(() => _modalShow = false),
              onUpdateShow: (show) {
                if (!show) setState(() => _modalShow = false);
              },
              child: UPSlider(
                value: _sliderValue,
                min: 1,
                max: 4,
                showValue: true,
                onUpdateValue: (value) {
                  setState(() => _sliderValue = (value as num).toDouble());
                },
              ),
            ),
          if (_popupShow)
            UPPopup(
              show: true,
              onClose: () => setState(() => _popupShow = false),
              onUpdateShow: (show) {
                if (!show) setState(() => _popupShow = false);
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: UPSlider(
                  value: _sliderValue,
                  min: 1,
                  max: 4,
                  showValue: true,
                  onUpdateValue: (value) {
                    setState(() => _sliderValue = (value as num).toDouble());
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<double> _asRange(dynamic value) {
    final list = value is List ? value : const <dynamic>[0, 0];
    return <double>[
      (list[0] as num).toDouble(),
      (list[1] as num).toDouble(),
    ];
  }
}

class _SliderBlock extends StatelessWidget {
  const _SliderBlock({
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
