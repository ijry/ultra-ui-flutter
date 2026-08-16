import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class PullRefreshPage extends StatefulWidget {
  const PullRefreshPage({super.key});

  @override
  State<PullRefreshPage> createState() => _PullRefreshPageState();
}

class _PullRefreshPageState extends State<PullRefreshPage> {
  late final List<Map<String, dynamic>> _items;
  late final List<Map<String, dynamic>> _loadmoreItems;
  bool _basicRefreshing = false;
  bool _customRefreshing = false;
  bool _virtualRefreshing = false;
  bool _loadmoreRefreshing = false;
  int _basicRefreshCount = 0;
  int _loadmoreCount = 0;
  String _loadmoreStatus = 'loadmore';

  @override
  void initState() {
    super.initState();
    _items = List<Map<String, dynamic>>.generate(
      8,
      (index) => <String, dynamic>{
        'id': index,
        'name': 'Item $index',
      },
    );
    _loadmoreItems = _items
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: true);
  }

  void _refreshBasic() {
    setState(() {
      _basicRefreshing = true;
      _basicRefreshCount += 1;
    });
    Future<void>.delayed(const Duration(milliseconds: 250)).then((_) {
      if (mounted) setState(() => _basicRefreshing = false);
    });
  }

  void _refreshCustom() {
    setState(() => _customRefreshing = true);
    Future<void>.delayed(const Duration(milliseconds: 250)).then((_) {
      if (mounted) setState(() => _customRefreshing = false);
    });
  }

  void _refreshVirtual() {
    setState(() => _virtualRefreshing = true);
    Future<void>.delayed(const Duration(milliseconds: 250)).then((_) {
      if (mounted) setState(() => _virtualRefreshing = false);
    });
  }

  void _refreshLoadmore() {
    setState(() => _loadmoreRefreshing = true);
    Future<void>.delayed(const Duration(milliseconds: 250)).then((_) {
      if (mounted) setState(() => _loadmoreRefreshing = false);
    });
  }

  void _loadMore() {
    if (_loadmoreStatus != 'loadmore') return;
    setState(() => _loadmoreStatus = 'loading');
    Future<void>.delayed(const Duration(milliseconds: 250)).then((_) {
      if (!mounted) return;
      setState(() {
        final id = _loadmoreItems.length;
        _loadmoreItems.add(<String, dynamic>{
          'id': id,
          'name': 'Item $id',
        });
        _loadmoreCount += 1;
        _loadmoreStatus = 'loadmore';
      });
    });
  }

  Widget _buildRows(List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(item['name'].toString()),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '下拉刷新',
      child: Container(
        key: const ValueKey('example-page-componentsD/pullRefresh/pullRefresh'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '基本使用',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 180,
                    child: UPPullRefresh(
                      key: const ValueKey('pull-refresh-page-basic'),
                      threshold: 50,
                      refreshing: _basicRefreshing,
                      onRefresh: _refreshBasic,
                      child: _buildRows(_items),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('基础刷新次数：$_basicRefreshCount'),
                  ),
                ],
              ),
            ),
            ExampleDemoBlock(
              title: '自定义下拉动画',
              child: SizedBox(
                height: 180,
                child: UPPullRefresh(
                  key: const ValueKey('pull-refresh-page-custom'),
                  refreshing: _customRefreshing,
                  onRefresh: _refreshCustom,
                  pullSlot: const _RefreshStatus(
                    icon: 'arrow-downward',
                    text: '下拉刷新',
                  ),
                  releaseSlot: const _RefreshStatus(
                    icon: 'arrow-upward',
                    text: '释放刷新',
                  ),
                  refreshingSlot: const _RefreshStatus(
                    icon: 'loading',
                    text: '正在刷新...',
                    loading: true,
                  ),
                  child: _buildRows(_items),
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '结合虚拟列表',
              child: SizedBox(
                height: 180,
                child: UPPullRefresh(
                  key: const ValueKey('pull-refresh-page-virtual'),
                  useScrollView: false,
                  refreshing: _virtualRefreshing,
                  onRefresh: _refreshVirtual,
                  child: UPVirtualList(
                    listData: _items,
                    itemHeight: 32,
                    height: 180,
                    itemBuilder: (context, item, index) => Text(
                      'Item ${item['id']}: ${item['name']}',
                    ),
                  ),
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '上拉加载',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 180,
                    child: UPPullRefresh(
                      key: const ValueKey('pull-refresh-page-loadmore'),
                      showLoadmore: true,
                      refreshing: _loadmoreRefreshing,
                      onRefresh: _refreshLoadmore,
                      onLoadmore: _loadMore,
                      loadmoreProps: <String, dynamic>{
                        'status': _loadmoreStatus,
                        'loadmoreText': '上拉加载更多',
                        'loadingText': '努力加载中...',
                        'nomoreText': '我们是有底线的',
                        'iconSize': 18,
                      },
                      child: _buildRows(_loadmoreItems),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('加载次数：$_loadmoreCount'),
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

class _RefreshStatus extends StatelessWidget {
  const _RefreshStatus({
    required this.icon,
    required this.text,
    this.loading = false,
  });

  final String icon;
  final String text;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (loading)
            const UPLoadingIcon(mode: 'circle', size: 18)
          else
            UPIcon(name: icon, size: 18),
          const SizedBox(height: 4),
          Text(text),
        ],
      ),
    );
  }
}
