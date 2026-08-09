import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  final _GuideController _guideController = _GuideController();
  int _changeCount = 0;
  int _skipCount = 0;
  int _finishCount = 0;
  int _resetCount = 0;

  Future<void> _resetGuide() async {
    await _guideController.reset();
    if (!mounted) return;
    setState(() => _resetCount += 1);
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      key: const ValueKey('example-page-componentsC/guide/guide'),
      title: '首屏引导',
      scrollable: false,
      child: Stack(
        children: <Widget>[
          ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: <Widget>[
              const ExampleDemoBlock(
                title: '基础使用',
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('进入页面时自动展示三页引导。'),
                ),
              ),
              ExampleDemoBlock(
                title: '引导控制',
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      UPButton(
                        key: const ValueKey('guide-page-open'),
                        type: 'primary',
                        size: 'small',
                        text: '重新打开引导',
                        stop: false,
                        onClick: _guideController.open,
                      ),
                      UPButton(
                        key: const ValueKey('guide-page-reset'),
                        type: 'default',
                        size: 'small',
                        text: '重置首次标记',
                        stop: false,
                        onClick: _resetGuide,
                      ),
                    ],
                  ),
                ),
              ),
              ExampleDemoBlock(
                title: '状态回调',
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('变化次数：$_changeCount'),
                      Text('跳过次数：$_skipCount'),
                      Text('完成次数：$_finishCount'),
                      Text('重置次数：$_resetCount'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned.fill(
            child: _GuideHost(
              key: const ValueKey('guide-page-widget'),
              controller: _guideController,
              show: true,
              once: true,
              storageKey: 'components-c-batch4-guide',
              list: const <Map<String, String>>[
                <String, String>{
                  'image': 'assets/uview/common/logo.png',
                  'title': '欢迎使用 uview-plus',
                  'desc': '一套跨端可复用的高质量组件库。',
                },
                <String, String>{
                  'image': 'assets/uview/common/logo.png',
                  'title': '引导页支持多页滑动',
                  'desc': '可配置跳过、下一步和立即体验。',
                },
                <String, String>{
                  'image': 'assets/uview/common/logo.png',
                  'title': '只显示一次',
                  'desc': '默认内置本地存储记忆能力。',
                },
              ],
              onChange: (_) {
                if (!mounted) return;
                setState(() => _changeCount += 1);
              },
              onSkip: () {
                if (!mounted) return;
                setState(() => _skipCount += 1);
              },
              onFinish: () {
                if (!mounted) return;
                setState(() => _finishCount += 1);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideController {
  UPGuideState? state;

  void open() {
    state?.open();
  }

  Future<void> reset() async {
    await state?.reset();
  }
}

class _GuideHost extends UPGuide {
  const _GuideHost({
    super.key,
    required this.controller,
    required super.show,
    required super.once,
    required super.storageKey,
    required super.list,
    super.onChange,
    super.onSkip,
    super.onFinish,
  });

  final _GuideController controller;

  @override
  State<UPGuide> createState() => _GuideHostState();
}

class _GuideHostState extends UPGuideState {
  @override
  void initState() {
    super.initState();
    (widget as _GuideHost).controller.state = this;
  }

  @override
  void dispose() {
    (widget as _GuideHost).controller.state = null;
    super.dispose();
  }
}
