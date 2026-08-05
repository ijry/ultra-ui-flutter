import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class SkeletonPage extends StatefulWidget {
  const SkeletonPage({super.key});

  @override
  State<SkeletonPage> createState() => _SkeletonPageState();
}

class _SkeletonPageState extends State<SkeletonPage> {
  bool _animate = true;
  bool _loading = false;

  void _setAnimate(dynamic value) {
    setState(() => _animate = value == true);
  }

  void _setLoading(dynamic value) {
    setState(() => _loading = value == true);
  }

  Widget _block(String title, Widget child) {
    return ExampleDemoBlock(title: title, child: child);
  }

  Widget _switchRow(
      {required Key key,
      required bool value,
      required ValueChanged<dynamic> onChange}) {
    final tokens = UPThemeTokens.of(context);
    return UPSwitch(
      key: key,
      value: value,
      space: 2,
      inactiveColor: tokens.borderColor,
      onChange: onChange,
    );
  }

  Widget _contentSlot() {
    final tokens = UPThemeTokens.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tokens.primary,
            shape: BoxShape.circle,
          ),
          child: const Text(
            'u',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const <Widget>[
              UPText(type: 'main', size: 16, flex1: false, text: '利剑出鞘,一统江湖'),
              SizedBox(height: 5),
              UPText(
                type: 'tips',
                size: 14,
                flex1: false,
                text: '众多组件覆盖开发过程的各个需求，组件功能丰富，多端兼容。让您快速集成，开箱即用。',
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '骨架屏',
      child: Container(
        key: const ValueKey('example-page-componentsC/skeleton/skeleton'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _block(
              '基础使用',
              const Padding(
                padding: EdgeInsets.all(12),
                child: UPSkeleton(rows: 3, title: true, loading: true),
              ),
            ),
            _block(
              '自定义段落行数',
              const Padding(
                padding: EdgeInsets.all(12),
                child: UPSkeleton(rows: 2, title: true, loading: true),
              ),
            ),
            _block(
              '设置段落宽度',
              const Padding(
                padding: EdgeInsets.all(12),
                child: UPSkeleton(
                  rows: 2,
                  title: true,
                  rowsWidth: <dynamic>['100%', '35%'],
                  loading: true,
                ),
              ),
            ),
            _block(
              '设置段落高度',
              const Padding(
                padding: EdgeInsets.all(12),
                child: UPSkeleton(
                  rows: 3,
                  title: true,
                  rowsWidth: <dynamic>['100%', '100%', '100%'],
                  rowsHeight: <dynamic>['18px', '18px', '80px'],
                  loading: true,
                ),
              ),
            ),
            _block(
              '是否开启动画',
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _switchRow(
                      key: const ValueKey('skeleton-page-animate-switch'),
                      value: _animate,
                      onChange: _setAnimate,
                    ),
                    const UPGap(height: 15),
                    UPSkeleton(
                      animate: _animate,
                      rows: 3,
                      title: true,
                      loading: true,
                    ),
                  ],
                ),
              ),
            ),
            _block(
              '展示头像',
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const UPGap(height: 15),
                    UPSkeleton(
                      animate: _animate,
                      rows: 3,
                      title: true,
                      loading: true,
                      avatar: true,
                    ),
                  ],
                ),
              ),
            ),
            _block(
              '切换状态',
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _switchRow(
                      key: const ValueKey('skeleton-page-loading-switch'),
                      value: _loading,
                      onChange: _setLoading,
                    ),
                    const UPGap(height: 15),
                    UPSkeleton(
                      rows: 2,
                      title: true,
                      loading: !_loading,
                      avatar: true,
                      rowsHeight: 14,
                      child: _contentSlot(),
                    ),
                  ],
                ),
              ),
            ),
            const UPGap(height: 50, bgColor: 'transparent'),
          ],
        ),
      ),
    );
  }
}
