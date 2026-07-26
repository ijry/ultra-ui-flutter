import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class LoadingIconPage extends StatelessWidget {
  const LoadingIconPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '加载中图标',
      child: Container(
        key: const ValueKey(
            'example-page-componentsA/loading-icon/loading-icon'),
        child: const Column(
          children: <Widget>[
            _LoadingBlock('基本案例', UPLoadingIcon()),
            _LoadingBlock('半圆loading', UPLoadingIcon(mode: 'semicircle')),
            _LoadingBlock('圆形loading', UPLoadingIcon(mode: 'circle')),
            _LoadingBlock('自定义动画',
                UPLoadingIcon(mode: 'circle', timingFunction: 'linear')),
            _LoadingBlock('自定义颜色', UPLoadingIcon(color: '#19be6b')),
            _LoadingBlock('自定义大小', UPLoadingIcon(size: 36, color: '#2979ff')),
            _LoadingBlock('自定义文字', UPLoadingIcon(vertical: true, text: '加载中')),
          ],
        ),
      ),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock(this.title, this.icon);

  final String title;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(padding: const EdgeInsets.all(16), child: icon),
    );
  }
}
