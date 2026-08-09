import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final _ListController _listController = _ListController();
  int _rows = 10;
  int _loadCount = 0;

  void _loadMore() {
    if (!mounted) return;
    setState(() {
      _loadCount += 1;
      if (_rows < 30) {
        _rows += 10;
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _listController.scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final children = List<Widget>.generate(
      _rows,
      (index) => UPListItem(
        child: UPCell(
          title: '列表长度-${index + 1}',
          iconSlot: const Padding(
            padding: EdgeInsets.only(right: 5),
            child: SizedBox(
              width: 35,
              height: 29,
              child: OverflowBox(
                maxWidth: 35,
                maxHeight: 35,
                alignment: Alignment.center,
                child: UPAvatar(
                  shape: 'square',
                  size: 35,
                  src: 'assets/uview/common/logo.png',
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return ExamplePageScaffold(
      key: const ValueKey('example-page-componentsC/list/list'),
      title: '列表',
      scrollable: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _ListHost(
              key: const ValueKey('list-page-widget'),
              controller: _listController,
              height: 520,
              lowerThreshold: 50,
              onScrolltolower: _loadMore,
              children: children,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text('列表数量：$_rows'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text('加载次数：$_loadCount'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListController {
  UPListState? state;

  void scrollToBottom() {
    state?.scrollToBottom();
  }
}

class _ListHost extends UPList {
  const _ListHost({
    super.key,
    required this.controller,
    required super.height,
    required super.lowerThreshold,
    required super.onScrolltolower,
    required super.children,
  });

  final _ListController controller;

  @override
  State<UPList> createState() => _ListHostState();
}

class _ListHostState extends UPListState {
  @override
  void initState() {
    super.initState();
    (widget as _ListHost).controller.state = this;
  }

  @override
  void dispose() {
    (widget as _ListHost).controller.state = null;
    super.dispose();
  }
}
