import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class PaginationPage extends StatefulWidget {
  const PaginationPage({super.key});

  @override
  State<PaginationPage> createState() => _PaginationPageState();
}

class _PaginationPageState extends State<PaginationPage> {
  /// Source keeps one currentPage/pageSize shared across all three demos.
  int _currentPage = 1;
  int _pageSize = 10;
  static const int _total = 100;
  static const List<int> _pageSizes = <int>[10, 20, 30, 40];

  void _handleCurrentChange(int page) => setState(() => _currentPage = page);
  void _handleSizeChange(int size) => setState(() => _pageSize = size);

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: '分页器',
      child: Container(
        key: const ValueKey('example-page-componentsD/pagination/pagination'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '基础',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: UPPagination(
                  key: const ValueKey('pagination-page-basic'),
                  currentPage: _currentPage,
                  pageSize: _pageSize,
                  total: _total,
                  pageSizes: _pageSizes,
                  layout: 'prev, total, next',
                  onCurrentChange: _handleCurrentChange,
                  onSizeChange: _handleSizeChange,
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '上一页下一页文案',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: UPPagination(
                  key: const ValueKey('pagination-page-text'),
                  prevText: '上一页',
                  nextText: '下一页',
                  currentPage: _currentPage,
                  pageSize: _pageSize,
                  total: _total,
                  pageSizes: _pageSizes,
                  layout: 'prev, total, next',
                  onCurrentChange: _handleCurrentChange,
                  onSizeChange: _handleSizeChange,
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '显示分页切换',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: UPPagination(
                  key: const ValueKey('pagination-page-pager'),
                  currentPage: _currentPage,
                  pageSize: _pageSize,
                  total: _total,
                  pageSizes: _pageSizes,
                  layout: 'prev, pager, next',
                  onCurrentChange: _handleCurrentChange,
                  onSizeChange: _handleSizeChange,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                '当前页：$_currentPage · 每页：$_pageSize',
                style: TextStyle(color: tokens.contentColor, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
