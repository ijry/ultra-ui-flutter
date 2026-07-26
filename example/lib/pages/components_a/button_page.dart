import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class ButtonPage extends StatefulWidget {
  const ButtonPage({super.key});

  @override
  State<ButtonPage> createState() => _ButtonPageState();
}

class _ButtonPageState extends State<ButtonPage> {
  bool _showActionSheet = false;

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '按钮',
      child: Container(
        key: const ValueKey('example-page-componentsA/button/button'),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: UPButton(
                text: '打开上拉菜单',
                type: 'primary',
                onClick: () => setState(() => _showActionSheet = true),
              ),
            ),
            _ButtonBlock(
              title: '按钮类型',
              children: <Widget>[
                UPButton(
                  text: '默认按钮',
                  type: 'info',
                  onClick: () => setState(() => _showActionSheet = true),
                ),
                const UPButton(text: '成功按钮', type: 'success'),
                const UPButton(text: '危险按钮', type: 'error'),
                const UPButton(text: '主要按钮', type: 'primary'),
                const UPButton(text: '警告按钮', type: 'warning'),
              ],
            ),
            _ButtonBlock(
              title: '镂空按钮',
              children: const <Widget>[
                UPButton(text: '镂空按钮', type: 'info', plain: true),
                UPButton(text: '镂空按钮', type: 'success', plain: true),
                UPButton(text: '镂空按钮', type: 'error', plain: true),
                UPButton(text: '镂空按钮', type: 'primary', plain: true),
                UPButton(text: '镂空按钮', type: 'warning', plain: true),
              ],
            ),
            _ButtonBlock(
              title: '细边按钮',
              children: const <Widget>[
                UPButton(
                    text: '细边按钮', type: 'info', plain: true, hairline: true),
                UPButton(
                    text: '细边按钮', type: 'success', plain: true, hairline: true),
                UPButton(
                    text: '细边按钮', type: 'error', plain: true, hairline: true),
                UPButton(
                    text: '细边按钮', type: 'primary', plain: true, hairline: true),
                UPButton(
                    text: '细边按钮', type: 'warning', plain: true, hairline: true),
              ],
            ),
            _ButtonBlock(
              title: '禁用按钮',
              children: const <Widget>[
                UPButton(text: '禁用按钮', type: 'info', disabled: true),
                UPButton(text: '禁用按钮', type: 'success', disabled: true),
                UPButton(text: '禁用按钮', type: 'error', disabled: true),
                UPButton(text: '禁用按钮', type: 'primary', disabled: true),
                UPButton(text: '禁用按钮', type: 'warning', disabled: true),
              ],
            ),
            const _ButtonBlock(
              title: '加载中',
              children: <Widget>[
                UPButton(
                  loading: true,
                  loadingText: '加载中',
                  loadingMode: 'circle',
                  type: 'success',
                ),
                UPButton(loading: true, loadingText: '加载中', type: 'error'),
              ],
            ),
            _ButtonBlock(
              title: '按钮图标&按钮形状',
              children: const <Widget>[
                UPButton(
                  text: '按钮图标',
                  icon: 'map',
                  plain: true,
                  type: 'warning',
                ),
                UPButton(
                  text: '按钮图标',
                  plain: true,
                  shape: 'circle',
                  type: 'success',
                ),
              ],
            ),
            _ButtonBlock(
              title: '自定义颜色',
              children: const <Widget>[
                UPButton(
                  text: '渐变色按钮',
                  customStyle: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[Color(0xFF4253D8), Color(0xFFD333BA)],
                    ),
                  ),
                ),
                UPButton(
                  text: '渐变色按钮',
                  customStyle: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[Color(0xFFDBC20B), Color(0xFF049763)],
                    ),
                  ),
                ),
                UPButton(text: '青绿色按钮', color: '#0ab99c'),
              ],
            ),
            _ButtonBlock(
              title: '自定义大小',
              children: const <Widget>[
                UPButton(text: '超大尺寸', size: 'large', type: 'success'),
                UPButton(text: '普通尺寸', size: 'normal', type: 'error'),
                UPButton(text: '小型尺寸', size: 'small', type: 'primary'),
                UPButton(text: '超小尺寸', size: 'mini', type: 'warning'),
              ],
            ),
            UPActionSheet(
              show: _showActionSheet,
              actions: const <Map<String, String>>[
                <String, String>{'name': '拍照'},
                <String, String>{'name': '从相册选择'},
                <String, String>{'name': '删除'},
              ],
              cancelText: '取消',
              onUpdateShow: (show) => setState(() => _showActionSheet = show),
            ),
          ],
        ),
      ),
    );
  }
}

class _ButtonBlock extends StatelessWidget {
  const _ButtonBlock({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 1),
        child: Wrap(
          spacing: 15,
          runSpacing: 15,
          children: children,
        ),
      ),
    );
  }
}
