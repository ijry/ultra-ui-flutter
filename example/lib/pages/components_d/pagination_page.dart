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
  int _basicPage = 1;
  int _sizedPage = 1;
  int _pageSize = 10;
  int _pageChanges = 0;

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '分页器',
      child: Container(
        key: const ValueKey('example-page-componentsD/pagination/pagination'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '基础分页',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: UPPagination(
                  key: const ValueKey('pagination-page-basic'),
                  currentPage: _basicPage,
                  total: 45,
                  layout: 'prev, pager, next',
                  onCurrentChange: (page) => setState(() {
                    _basicPage = page;
                    _pageChanges += 1;
                  }),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text('当前页：$_basicPage'),
            ),
            ExampleDemoBlock(
              title: '带页码选择',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: UPPagination(
                  key: const ValueKey('pagination-page-sized'),
                  currentPage: _sizedPage,
                  pageSize: _pageSize,
                  total: 100,
                  pageSizes: const <int>[10, 20],
                  layout: 'total, sizes, prev, pager, next',
                  onCurrentChange: (page) => setState(() {
                    _sizedPage = page;
                    _pageChanges += 1;
                  }),
                  onSizeChange: (size) => setState(() {
                    _pageSize = size;
                    _pageChanges += 1;
                  }),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('每页：$_pageSize'),
                  Text('分页变化次数：$_pageChanges'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
