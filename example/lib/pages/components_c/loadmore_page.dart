import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class LoadmorePage extends StatefulWidget {
  const LoadmorePage({super.key});

  @override
  State<LoadmorePage> createState() => _LoadmorePageState();
}

class _LoadmorePageState extends State<LoadmorePage> {
  int _loadCount = 0;

  void _loadmore() {
    setState(() => _loadCount++);
    UPToast.show(context, message: '加载更多');
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '加载更多',
      child: Container(
        key: const ValueKey('example-page-componentsC/loadmore/loadmore'),
        child: Column(
          children: <Widget>[
            const _LoadmoreBlock(
              title: '基础使用',
              child: UPLoadmore(status: 'loading', isDot: true, iconSize: 17),
            ),
            const _LoadmoreBlock(
              title: '无更多数据',
              child: UPLoadmore(line: true, status: 'nomore'),
            ),
            _LoadmoreBlock(
              key: const ValueKey('loadmore-page-clickable'),
              title: '加载更多(点击触发事件)',
              child: Column(
                children: <Widget>[
                  UPLoadmore(
                    line: true,
                    status: 'loadmore',
                    onLoadmore: _loadmore,
                  ),
                  Text('加载次数：$_loadCount'),
                ],
              ),
            ),
            const _LoadmoreBlock(
              title: '自定义图标',
              child: UPLoadmore(status: 'loading', loadingIcon: 'circle'),
            ),
            const _LoadmoreBlock(
              title: '显示点',
              child: UPLoadmore(
                status: 'nomore',
                isDot: true,
                line: true,
                color: '#909399',
              ),
            ),
            const _LoadmoreBlock(
              title: '自定义提示语',
              child: UPLoadmore(
                status: 'loading',
                loadingText: '努力加载中,先喝杯茶',
                color: '#909399',
              ),
            ),
            const _LoadmoreBlock(
              title: '自定义线条颜色',
              child: UPLoadmore(
                loadmoreText: '看,我和别人不一样',
                color: '#1CD29B',
                lineColor: '#1CD29B',
                dashed: true,
                line: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadmoreBlock extends StatelessWidget {
  const _LoadmoreBlock({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }
}
