import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class CountToPage extends StatefulWidget {
  const CountToPage({super.key});

  @override
  State<CountToPage> createState() => _CountToPageState();
}

class _CountToPageState extends State<CountToPage> {
  final GlobalKey<UPCountToState> _manualKey = GlobalKey<UPCountToState>();
  String _manualStatus = '未开始';

  void _startManual() {
    setState(() => _manualStatus = '运行中');
    _manualKey.currentState?.start();
  }

  void _pauseManual() {
    setState(() => _manualStatus = '已暂停');
    _manualKey.currentState?.stop();
  }

  void _resumeManual() {
    setState(() => _manualStatus = '继续中');
    _manualKey.currentState?.resume();
  }

  void _end() {}

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '数字滚动',
      child: Container(
        key: const ValueKey('example-page-componentsB/countTo/countTo'),
        child: Column(
          children: <Widget>[
            _CountToBlock(
              title: '基础功能',
              child: UPCountTo(endVal: 3000, onEnd: _end),
            ),
            const _CountToBlock(
              title: '倒计数',
              child: UPCountTo(startVal: 300),
            ),
            const _CountToBlock(
              title: '显示小数位',
              child: UPCountTo(
                startVal: 100.00,
                endVal: 10.55,
                decimals: 2,
              ),
            ),
            const _CountToBlock(
              title: '千分位分隔符',
              child: UPCountTo(
                startVal: 2000,
                endVal: 1542,
                separator: ',',
                decimals: 2,
              ),
            ),
            _CountToBlock(
              title: '自定义控制',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  UPCountTo(
                    key: _manualKey,
                    endVal: 3000,
                    autoplay: false,
                  ),
                  const SizedBox(height: 8),
                  Text('计数状态：$_manualStatus'),
                  const SizedBox(height: 12),
                  UPGrid(
                    border: true,
                    align: 'center',
                    children: <Widget>[
                      UPGridItem(
                        onClick: (_) => _startManual(),
                        child: const _CountToGridItem(label: '开始'),
                      ),
                      UPGridItem(
                        onClick: (_) => _pauseManual(),
                        child: const _CountToGridItem(label: '暂停'),
                      ),
                      UPGridItem(
                        onClick: (_) => _resumeManual(),
                        child: const _CountToGridItem(label: '继续'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const _CountToBlock(
              title: '自定义',
              child: UPCountTo(
                endVal: 3000,
                color: '#909399',
                fontSize: 40,
                bold: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountToBlock extends StatelessWidget {
  const _CountToBlock({
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

class _CountToGridItem extends StatelessWidget {
  const _CountToGridItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 74,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDBFBDB), width: 2),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFDBFBDB),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF19BE6B),
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
