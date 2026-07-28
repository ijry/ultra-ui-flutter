import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  double _percentage1 = 30;
  double _percentage6 = 50;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _updateTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _percentage1 = 120);
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _changeManual(int delta) {
    setState(() {
      _percentage6 = (_percentage6 + delta).clamp(0, 100).toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '进度条',
      child: Container(
        key: const ValueKey('example-page-componentsB/progress/progress'),
        child: Column(
          children: <Widget>[
            const _ProgressBlock(
              title: '默认配置',
              child: UPLineProgress(),
            ),
            _ProgressBlock(
              title: '基础功能',
              child: UPLineProgress(percentage: _percentage1),
            ),
            const _ProgressBlock(
              title: '不显示百分比',
              child: UPLineProgress(
                showText: false,
                percentage: 40,
              ),
            ),
            const _ProgressBlock(
              title: '从右往左',
              child: UPLineProgress(
                showText: false,
                percentage: 40,
                fromRight: true,
              ),
            ),
            const _ProgressBlock(
              title: '自定义高度',
              child: UPLineProgress(
                height: 8,
                showText: false,
                percentage: 50,
              ),
            ),
            const _ProgressBlock(
              title: '自定义颜色',
              child: UPLineProgress(
                height: 8,
                showText: false,
                percentage: 60,
                activeColor: '#3c9cff',
                inactiveColor: '#f3f4f6',
              ),
            ),
            const _ProgressBlock(
              title: '自定义样式(不支持安卓环境的nvue)',
              child: UPLineProgress(
                height: 8,
                showText: false,
                percentage: 70,
                activeColor: '#3c9cff',
                inactiveColor: '#f3f4f6',
                child: _PercentageSlot(value: 70),
              ),
            ),
            _ProgressBlock(
              key: const ValueKey('progress-page-manual'),
              title: '手动加减',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  UPLineProgress(
                    height: 8,
                    showText: false,
                    percentage: _percentage6,
                    activeColor: '#3c9cff',
                    inactiveColor: '#f3f4f6',
                  ),
                  const SizedBox(height: 12),
                  Text('手动值：${_percentage6.round()}'),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _ManualCircleButton(
                        text: '减少',
                        onTap: () => _changeManual(-10),
                      ),
                      const SizedBox(width: 60),
                      _ManualCircleButton(
                        text: '增加',
                        onTap: () => _changeManual(10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBlock extends StatelessWidget {
  const _ProgressBlock({
    super.key,
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

class _PercentageSlot extends StatelessWidget {
  const _PercentageSlot({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(5, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: UPThemeTokens.of(context).warning,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          '$value%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _ManualCircleButton extends StatelessWidget {
  const _ManualCircleButton({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFFDBFBDB),
          shape: BoxShape.circle,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF19BE6B),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
