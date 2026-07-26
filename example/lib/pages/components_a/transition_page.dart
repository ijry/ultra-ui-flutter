import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

class TransitionPage extends StatefulWidget {
  const TransitionPage({super.key});

  @override
  State<TransitionPage> createState() => _TransitionPageState();
}

class _TransitionPageState extends State<TransitionPage> {
  static const List<_TransitionOption> _options = <_TransitionOption>[
    _TransitionOption('fade', '淡入'),
    _TransitionOption('fade-up', '上滑淡入'),
    _TransitionOption('zoom', '缩放'),
    _TransitionOption('fade-zoom', '缩放淡入'),
    _TransitionOption('fade-down', '下滑淡入'),
    _TransitionOption('fade-left', '左滑淡入'),
    _TransitionOption('fade-right', '右滑淡入'),
    _TransitionOption('slide-up', '上滑进入'),
    _TransitionOption('slide-down', '下滑进入'),
    _TransitionOption('slide-left', '左滑进入'),
    _TransitionOption('slide-right', '右滑进入'),
  ];

  Timer? _hideTimer;
  String _mode = 'fade';
  bool _show = false;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _openTransition(String mode) {
    _hideTimer?.cancel();
    setState(() {
      _mode = mode;
      _show = true;
    });
    _hideTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _show = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '动画',
      child: Container(
        key: const ValueKey('example-page-componentsA/transition/transition'),
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 140,
              child: Center(
                child: UPTransition(
                  show: _show,
                  mode: _mode,
                  child: Container(
                    key: const ValueKey('transition-preview'),
                    width: 120,
                    height: 120,
                    color: const Color(0xFF1989FA),
                  ),
                ),
              ),
            ),
            UPCellGroup(
              children: _options
                  .map(
                    (option) => UPCell(
                      title: option.title,
                      isLink: true,
                      clickable: true,
                      onClick: () => _openTransition(option.mode),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransitionOption {
  const _TransitionOption(this.mode, this.title);

  final String mode;
  final String title;
}
