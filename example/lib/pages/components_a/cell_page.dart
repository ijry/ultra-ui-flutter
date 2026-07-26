import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

class CellPage extends StatelessWidget {
  const CellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '单元格',
      child: Container(
        key: const ValueKey('example-page-componentsA/cell/cell'),
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: <Widget>[
            _CellSection(
              title: '基础功能',
              children: const <Widget>[
                UPCell(title: 'uview-plus', value: '内容', isLink: true),
                UPCell(title: '利剑出鞘,一统江湖', value: '内容', label: '挣脱束缚,向往自由'),
              ],
            ),
            _CellSection(
              title: '自定义图标/图片',
              children: const <Widget>[
                UPCell(title: '单元格', icon: 'lock-fill'),
                UPCell(
                  title: '单元格',
                  iconSlot: Image(
                      image: AssetImage('assets/uview/demo/cell/tag.png'),
                      width: 18,
                      height: 18),
                ),
              ],
            ),
            _CellSection(
              title: '自定义大小',
              children: const <Widget>[
                UPCell(size: 'large', title: '单元格', value: '内容', isLink: true),
                UPCell(size: 'large', title: '单元格', value: '内容', label: '描述信息'),
              ],
            ),
            _CellSection(
              title: '显示右箭头',
              children: const <Widget>[
                UPCell(required: true, title: '单元格', value: '组件', isLink: true),
                UPCell(
                    title: '单元格',
                    value: '工具',
                    arrowDirection: 'up',
                    isLink: true),
                UPCell(
                    title: '单元格',
                    value: '模板',
                    arrowDirection: 'down',
                    isLink: true),
              ],
            ),
            _CellSection(
              title: '跳转页面',
              children: const <Widget>[
                UPCell(title: '打开标签页', isLink: true),
                UPCell(title: '打开徽标页', isLink: true),
              ],
            ),
            _CellSection(
              title: '右侧内容垂直居中',
              children: <Widget>[
                const UPCell(
                  required: true,
                  title: '单元格',
                  value: '内容',
                  label: '描述信息',
                  center: true,
                ),
                UPCell(
                  value: '内容',
                  titleSlot: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('单元格'),
                      SizedBox(width: 6),
                      UPTag(
                          text: '标签',
                          plain: true,
                          size: 'mini',
                          type: 'warning'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CellSection extends StatelessWidget {
  const _CellSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: UPCellGroup(title: title, children: children),
    );
  }
}
