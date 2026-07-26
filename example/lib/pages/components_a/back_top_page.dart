import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class BackTopPage extends StatefulWidget {
  const BackTopPage({super.key});

  @override
  State<BackTopPage> createState() => _BackTopPageState();
}

class _BackTopPageState extends State<BackTopPage> {
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _value = <dynamic>['自定义图标'];
  double _scrollTop = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      setState(() => _scrollTop = _scrollController.offset);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _value.map((item) => '$item').toSet();
    final square = selected.contains('显示方形');
    final customIcon = selected.contains('自定义图标');
    final customDistance = selected.contains('自定义距离');
    final customStyle = selected.contains('自定义样式');
    final longDuration = selected.contains('自定义返回顶部滚动时间');

    return ExamplePageScaffold(
      title: '返回顶部',
      scrollable: false,
      child: Stack(
        children: <Widget>[
          Container(
            key: const ValueKey('example-page-componentsA/backtop/backtop'),
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 24),
              children: <Widget>[
                ExampleDemoBlock(
                  title: '自定义backTop(滚动页面即可在右下角看到图标)',
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: UPCheckboxGroup(
                      value: _value,
                      placement: 'column',
                      shape: 'square',
                      onChange: (next, {bool isChecked = false, name}) {
                        setState(() => _value = next);
                      },
                      children: const <Widget>[
                        UPCheckbox(name: '显示方形', label: '显示方形'),
                        UPCheckbox(name: '自定义图标', label: '自定义图标'),
                        UPCheckbox(name: '自定义距离', label: '自定义距离'),
                        UPCheckbox(name: '自定义样式', label: '自定义样式'),
                        UPCheckbox(
                          name: '自定义返回顶部滚动时间',
                          label: '自定义返回顶部滚动时间',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 1200),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: customDistance ? 300 : 100,
            width: 40,
            height: 40,
            child: UPBackTop(
              mode: square ? 'square' : 'circle',
              icon: customIcon ? 'arrow-up' : 'arrow-upward',
              bottom: 0,
              right: 0,
              duration: longDuration ? 1500 : 300,
              scrollTop: _scrollTop,
              scrollController: _scrollController,
              customStyle: customStyle
                  ? const BoxDecoration(color: Color(0xFF2979FF))
                  : null,
              iconStyle: customStyle
                  ? const <String, dynamic>{'color': '#ffffff'}
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
