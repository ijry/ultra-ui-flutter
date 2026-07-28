import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

class NumberBoxPage extends StatefulWidget {
  const NumberBoxPage({super.key});

  @override
  State<NumberBoxPage> createState() => _NumberBoxPageState();
}

class _NumberBoxPageState extends State<NumberBoxPage> {
  num _value1 = 3;
  num _value2 = 3;
  num _value3 = 5;
  num _value4 = 3;
  num _value5 = 3;
  num _value6 = 3;
  num _value7 = 3;
  num _value8 = 3.1;
  num _value9 = 3;
  num _value10 = 3;
  num _value11 = 3;
  bool _asyncLoading = false;

  void _changeAsync(num next) {
    if (_asyncLoading) return;
    setState(() => _asyncLoading = true);
    UPToast.show(
      context,
      message: '正在加载',
      type: 'loading',
      overlay: true,
      duration: 3000,
    );
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _value9 = next;
        _asyncLoading = false;
      });
      UPToast.hide();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '步进器',
      child: Container(
        key: const ValueKey('example-page-componentsB/numberBox/numberBox'),
        padding: const EdgeInsets.only(top: 12, bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 8),
              child: Wrap(
                spacing: 16,
                runSpacing: 4,
                children: <Widget>[
                  Text('基础值：$_value1'),
                  Text('自定义值：$_value11'),
                ],
              ),
            ),
            UPCellGroup(
              border: true,
              children: <Widget>[
                _row(
                  title: '基础用法',
                  key: const ValueKey('number-box-page-basic'),
                  numberBox: UPNumberBox(
                    value: _value1,
                    step: 1,
                    onChange: (value, {name}) =>
                        setState(() => _value1 = value),
                  ),
                ),
                _row(
                  title: '步长设置',
                  numberBox: UPNumberBox(
                    value: _value2,
                    step: 2,
                    onChange: (value, {name}) =>
                        setState(() => _value2 = value),
                  ),
                ),
                _row(
                  title: '限制输入范围',
                  numberBox: UPNumberBox(
                    value: _value3,
                    step: 1,
                    min: 5,
                    max: 8,
                    onChange: (value, {name}) =>
                        setState(() => _value3 = value),
                  ),
                ),
                _row(
                  title: '限制输入整数',
                  numberBox: UPNumberBox(
                    value: _value4,
                    step: 1,
                    integer: true,
                    onChange: (value, {name}) =>
                        setState(() => _value4 = value),
                  ),
                ),
                _row(
                  title: '禁用状态',
                  numberBox: UPNumberBox(
                    value: _value5,
                    step: 1,
                    disabled: true,
                    onChange: (value, {name}) =>
                        setState(() => _value5 = value),
                  ),
                ),
                _row(
                  title: '禁用输入框',
                  numberBox: UPNumberBox(
                    value: _value6,
                    step: 1,
                    disabledInput: true,
                    onChange: (value, {name}) =>
                        setState(() => _value6 = value),
                  ),
                ),
                _row(
                  title: '禁用长按',
                  numberBox: UPNumberBox(
                    value: _value7,
                    step: 1,
                    longPress: false,
                    onChange: (value, {name}) =>
                        setState(() => _value7 = value),
                  ),
                ),
                _row(
                  title: '固定小数位数',
                  numberBox: UPNumberBox(
                    value: _value8,
                    step: 0.2,
                    decimalLength: 1,
                    onChange: (value, {name}) =>
                        setState(() => _value8 = value),
                  ),
                ),
                _row(
                  title: '异步变更',
                  numberBox: UPNumberBox(
                    value: _value9,
                    step: 1,
                    asyncChange: true,
                    onChange: (value, {name}) => _changeAsync(value),
                  ),
                ),
                _row(
                  title: '自定义大小颜色样式',
                  numberBox: UPNumberBox(
                    value: _value10,
                    step: 1,
                    color: '#FFFFFF',
                    buttonSize: 36,
                    bgColor: '#2979ff',
                    iconStyle: 'color: #fff',
                    onChange: (value, {name}) =>
                        setState(() => _value10 = value),
                  ),
                ),
                _row(
                  title: '自定义(为0时减少按钮会消失)',
                  key: const ValueKey('number-box-page-custom'),
                  numberBox: UPNumberBox(
                    value: _value11,
                    min: 0,
                    step: 1,
                    showMinus: _value11 > 0,
                    onChange: (value, {name}) =>
                        setState(() => _value11 = value),
                    minusBuilder: (context, value, disabled) => Container(
                      key: const ValueKey('number-box-custom-minus'),
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE6E6E6)),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const UPIcon(name: 'minus', size: 12),
                    ),
                    inputBuilder: (context, value, disabled) => Container(
                      width: 50,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text('$value', textAlign: TextAlign.center),
                    ),
                    plusBuilder: (context, value, disabled) => Container(
                      key: const ValueKey('number-box-custom-plus'),
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF0000),
                        shape: BoxShape.circle,
                      ),
                      child: const UPIcon(
                        name: 'plus',
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  UPCell _row({
    required String title,
    required UPNumberBox numberBox,
    Key? key,
  }) {
    return UPCell(
      title: title,
      border: true,
      rightIconSlot: KeyedSubtree(
        key: key,
        child: numberBox,
      ),
    );
  }
}
