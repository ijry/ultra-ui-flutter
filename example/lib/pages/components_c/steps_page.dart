import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class StepsPage extends StatelessWidget {
  const StepsPage({super.key});

  List<Widget> _orderItems({BoxDecoration? firstStyle}) {
    return <Widget>[
      UPStepsItem(
        title: '已下单',
        desc: '10:30',
        itemStyle: firstStyle,
      ),
      const UPStepsItem(title: '已出库', desc: '10:35'),
      const UPStepsItem(title: '运输中', desc: '11:40'),
      const UPStepsItem(title: '已签收', desc: '19:50'),
      const UPStepsItem(title: '已拒收', desc: '20:10'),
      const UPStepsItem(title: '已退回', desc: '23:20'),
    ];
  }

  List<Widget> _threeItems({bool error = false, Widget? customIcon}) {
    return <Widget>[
      const UPStepsItem(title: '已下单', desc: '10:30'),
      UPStepsItem(
        title: error ? '仓库着火' : '已出库',
        desc: '10:35',
        error: error,
      ),
      UPStepsItem(
        title: error ? '破产清算' : '运输中',
        desc: '11:40',
        iconWidget: customIcon,
      ),
    ];
  }

  Widget _block(String title, Widget child) {
    return ExampleDemoBlock(title: title, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final customSlot = Container(
      width: 21,
      height: 21,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tokens.warning,
        shape: BoxShape.circle,
      ),
      child: const Text(
        '运',
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );

    return ExamplePageScaffold(
      title: '步骤条',
      child: Container(
        key: const ValueKey('example-page-componentsC/steps/steps'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _block(
              '基础演示',
              Padding(
                padding: const EdgeInsets.all(12),
                child: UPSteps(
                  current: 1,
                  children: _orderItems(
                    firstStyle: BoxDecoration(color: tokens.pageBgColor),
                  ),
                ),
              ),
            ),
            _block(
              '显示点类型',
              const Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    UPSteps(
                      current: 1,
                      dot: true,
                      children: [
                        UPStepsItem(title: '已下单', desc: '10:30'),
                        UPStepsItem(title: '已出库', desc: '10:35'),
                        UPStepsItem(title: '运输中', desc: '11:40'),
                      ],
                    ),
                    SizedBox(height: 18),
                    UPSteps(
                      current: 1,
                      dot: true,
                      direction: 'column',
                      children: [
                        UPStepsItem(title: '已下单', desc: '10:30'),
                        UPStepsItem(title: '已出库', desc: '10:35'),
                        UPStepsItem(title: '运输中', desc: '11:40'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _block(
              '错误状态',
              Padding(
                padding: const EdgeInsets.all(12),
                child: UPSteps(
                  current: 1,
                  children: _threeItems(error: true),
                ),
              ),
            ),
            _block(
              '自定义图标',
              Padding(
                padding: const EdgeInsets.all(12),
                child: UPSteps(
                  current: 1,
                  activeIcon: 'checkmark',
                  inactiveIcon: 'arrow-right',
                  children: _threeItems(),
                ),
              ),
            ),
            _block(
              '自定义插槽',
              Padding(
                padding: const EdgeInsets.all(12),
                child: UPSteps(
                  current: 1,
                  children: _threeItems(customIcon: customSlot),
                ),
              ),
            ),
            _block(
              '自定义颜色',
              Padding(
                padding: const EdgeInsets.all(12),
                child: UPSteps(
                  current: 1,
                  activeColor: '#3c9cff',
                  children: _threeItems(),
                ),
              ),
            ),
            _block(
              '竖向展示',
              Padding(
                padding: const EdgeInsets.all(12),
                child: UPSteps(
                  current: 1,
                  direction: 'column',
                  children: _threeItems(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
