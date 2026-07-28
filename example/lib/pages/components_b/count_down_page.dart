import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class CountDownPage extends StatefulWidget {
  const CountDownPage({super.key});

  @override
  State<CountDownPage> createState() => _CountDownPageState();
}

class _CountDownPageState extends State<CountDownPage> {
  static const int _longTime = 30 * 60 * 60 * 1000;

  final GlobalKey<UPCountDownState> _manualKey = GlobalKey<UPCountDownState>();
  late UPCountDownTimeData _formatData;
  late UPCountDownTimeData _styleData;
  String _manualStatus = '未开始';

  @override
  void initState() {
    super.initState();
    _formatData = UPCountDownState.parseTimeData(_longTime);
    _styleData = UPCountDownState.parseTimeData(_longTime);
  }

  void _startManual() {
    setState(() => _manualStatus = '运行中');
    _manualKey.currentState?.start();
  }

  void _pauseManual() {
    setState(() => _manualStatus = '已暂停');
    _manualKey.currentState?.pause();
  }

  void _resetManual() {
    setState(() => _manualStatus = '未开始');
    _manualKey.currentState?.reset();
  }

  void _setFormatData(UPCountDownTimeData data) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _formatData = data);
      }
    });
  }

  void _setStyleData(UPCountDownTimeData data) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _styleData = data);
      }
    });
  }

  void _finish() {}

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '倒计时',
      child: Container(
        key: const ValueKey('example-page-componentsB/countDown/countDown'),
        child: Column(
          children: <Widget>[
            _CountDownBlock(
              title: '基础用法',
              child: UPCountDown(
                time: _longTime,
                format: 'HH:mm:ss',
                autoStart: true,
                millisecond: true,
                onFinish: _finish,
              ),
            ),
            _CountDownBlock(
              title: '自定义格式',
              child: Stack(
                children: <Widget>[
                  Offstage(
                    child: UPCountDown(
                      time: _longTime,
                      format: 'DD:HH:mm:ss',
                      autoStart: true,
                      millisecond: true,
                      onChange: _setFormatData,
                    ),
                  ),
                  _FormatTimeRow(data: _formatData),
                ],
              ),
            ),
            _CountDownBlock(
              title: '毫秒级渲染',
              child: const UPCountDown(
                time: _longTime,
                format: 'HH:mm:ss:SSS',
                autoStart: true,
                millisecond: true,
              ),
            ),
            _CountDownBlock(
              title: '自定义样式',
              child: Stack(
                children: <Widget>[
                  Offstage(
                    child: UPCountDown(
                      time: _longTime,
                      format: 'HH:mm:ss',
                      autoStart: true,
                      millisecond: true,
                      onChange: _setStyleData,
                    ),
                  ),
                  _CustomTimeRow(data: _styleData),
                ],
              ),
            ),
            _CountDownBlock(
              title: '手动控制',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  UPCountDown(
                    key: _manualKey,
                    time: 3 * 1000,
                    format: 'ss:SSS',
                    autoStart: false,
                    millisecond: true,
                  ),
                  const SizedBox(height: 8),
                  Text('手动状态：$_manualStatus'),
                  const SizedBox(height: 10),
                  UPGrid(
                    border: true,
                    children: <Widget>[
                      UPGridItem(
                        onClick: (_) => _resetManual(),
                        child: const _ManualGridItem(
                          iconName: 'reload',
                          label: '重置',
                        ),
                      ),
                      UPGridItem(
                        onClick: (_) => _startManual(),
                        child: const _ManualGridItem(
                          iconName: 'play-right-fill',
                          label: '开始',
                          primaryIcon: true,
                        ),
                      ),
                      UPGridItem(
                        onClick: (_) => _pauseManual(),
                        child: const _ManualGridItem(
                          iconName: 'pause-circle',
                          label: '暂停',
                        ),
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

class _CountDownBlock extends StatelessWidget {
  const _CountDownBlock({
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

class _FormatTimeRow extends StatelessWidget {
  const _FormatTimeRow({required this.data});

  final UPCountDownTimeData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _TimeText('${data.days} 天'),
        _TimeText('${_two(data.hours)} 时'),
        _TimeText('${data.minutes} 分'),
        _TimeText('${data.seconds} 秒'),
      ],
    );
  }
}

class _CustomTimeRow extends StatelessWidget {
  const _CustomTimeRow({required this.data});

  final UPCountDownTimeData data;

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return Row(
      children: <Widget>[
        _TimeBox(value: _two(data.hours)),
        _TimeDoc(color: tokens.primary),
        _TimeBox(value: '${data.minutes}'),
        _TimeDoc(color: tokens.primary),
        _TimeBox(value: '${data.seconds}'),
      ],
    );
  }
}

class _TimeText extends StatelessWidget {
  const _TimeText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF606266),
          fontSize: 15,
        ),
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return Container(
      width: 22,
      height: 22,
      margin: const EdgeInsets.only(top: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tokens.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TimeDoc extends StatelessWidget {
  const _TimeDoc({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(':', style: TextStyle(color: color)),
    );
  }
}

class _ManualGridItem extends StatelessWidget {
  const _ManualGridItem({
    required this.iconName,
    required this.label,
    this.primaryIcon = false,
  });

  final String iconName;
  final String label;
  final bool primaryIcon;

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final icon = primaryIcon
        ? Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tokens.primary,
              shape: BoxShape.circle,
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0xB39BBFFF),
                  blurRadius: 4,
                  offset: Offset(1, 1),
                ),
              ],
            ),
            child: UPIcon(name: iconName, color: Colors.white, size: 22),
          )
        : UPIcon(name: iconName, size: 22);
    return SizedBox(
      width: 70,
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          icon,
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF909399),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

String _two(int value) => value > 9 ? '$value' : '0$value';
