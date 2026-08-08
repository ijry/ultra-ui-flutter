import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class LayoutPage extends StatelessWidget {
  const LayoutPage({super.key});

  Widget _demoLayout(String color) {
    return Container(
      height: 25,
      decoration: BoxDecoration(
        color: UPUtils.parseColor(color),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _block(String title, Widget child) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '布局',
      child: Container(
        key: const ValueKey('example-page-componentsC/layout/layout'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _block(
              '基础使用',
              Column(
                children: <Widget>[
                  UPRow(
                    key: const ValueKey('layout-page-basic-row'),
                    children: <Widget>[
                      UPCol(span: 6, child: _demoLayout('#e5e9f2')),
                      UPCol(span: 6, child: _demoLayout('#ced7e1')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  UPRow(
                    children: <Widget>[
                      UPCol(span: 4, child: _demoLayout('#ced7e1')),
                      UPCol(span: 4, child: _demoLayout('#e5e9f2')),
                      UPCol(span: 4, child: _demoLayout('#99a9bf')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  UPRow(
                    justify: 'space-between',
                    children: <Widget>[
                      UPCol(span: 3, child: _demoLayout('#ced7e1')),
                      UPCol(span: 3, child: _demoLayout('#e5e9f2')),
                      UPCol(span: 3, child: _demoLayout('#ced7e1')),
                      UPCol(span: 3, child: _demoLayout('#e5e9f2')),
                    ],
                  ),
                ],
              ),
            ),
            _block(
              '分栏间隔',
              UPRow(
                key: const ValueKey('layout-page-gutter-row'),
                justify: 'space-between',
                gutter: 10,
                children: <Widget>[
                  UPCol(span: 3, child: _demoLayout('#ced7e1')),
                  UPCol(span: 3, child: _demoLayout('#e5e9f2')),
                  UPCol(span: 3, child: _demoLayout('#ced7e1')),
                  UPCol(span: 3, child: _demoLayout('#e5e9f2')),
                ],
              ),
            ),
            _block(
              '混合布局',
              UPRow(
                key: const ValueKey('layout-page-mixed-row'),
                justify: 'space-between',
                gutter: 10,
                children: <Widget>[
                  UPCol(span: 2, child: _demoLayout('#e5e9f2')),
                  UPCol(span: 4, child: _demoLayout('#ced7e1')),
                  UPCol(span: 6, child: _demoLayout('#99a9bf')),
                ],
              ),
            ),
            _block(
              '分栏偏移',
              Column(
                children: <Widget>[
                  UPRow(
                    key: const ValueKey('layout-page-offset-row'),
                    justify: 'space-between',
                    children: <Widget>[
                      UPCol(
                        span: 3,
                        offset: 3,
                        child: _demoLayout('#e5e9f2'),
                      ),
                      UPCol(
                        span: 3,
                        offset: 3,
                        child: _demoLayout('#ced7e1'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  UPRow(
                    children: <Widget>[
                      UPCol(span: 3, child: _demoLayout('#e5e9f2')),
                      UPCol(
                        key: const ValueKey('layout-page-offset-col'),
                        span: 3,
                        offset: 3,
                        child: _demoLayout('#ced7e1'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _block(
              '对齐方式',
              Column(
                children: <Widget>[
                  UPRow(
                    key: const ValueKey('layout-page-alignment-row'),
                    justify: 'space-between',
                    children: <Widget>[
                      UPCol(span: 3, child: _demoLayout('#e5e9f2')),
                      UPCol(span: 3, child: _demoLayout('#ced7e1')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  UPRow(
                    children: <Widget>[
                      UPCol(span: 3, child: _demoLayout('#e5e9f2')),
                      UPCol(span: 3, child: _demoLayout('#ced7e1')),
                    ],
                  ),
                ],
              ),
            ),
            const UPGap(height: 40),
          ],
        ),
      ),
    );
  }
}
