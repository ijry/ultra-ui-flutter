import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class TagPage extends StatefulWidget {
  const TagPage({super.key});

  @override
  State<TagPage> createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> {
  final List<bool> _close = <bool>[true, true, true];
  int _radio = 0;
  final List<bool> _checks = <bool>[true, false, false];

  String get _closeState => _close.join(',');

  String get _checkState => _checks
      .asMap()
      .entries
      .where((entry) => entry.value)
      .map((entry) => '${entry.key + 1}')
      .join(',');

  void _selectRadio(int index) {
    setState(() => _radio = index);
  }

  void _toggleCheck(int index) {
    setState(() => _checks[index] = !_checks[index]);
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '标签',
      child: Container(
        key: const ValueKey('example-page-componentsB/tag/tag'),
        child: Column(
          children: <Widget>[
            const _TagBlock(
              title: '基础功能',
              children: <Widget>[
                UPTag(text: '标签', plain: true, size: 'mini', type: 'warning'),
              ],
            ),
            const _TagBlock(
              title: '自定义主题',
              children: <Widget>[
                UPTag(text: '标签'),
                UPTag(text: '标签', type: 'warning'),
                UPTag(text: '标签', type: 'success'),
                UPTag(text: '标签', type: 'error'),
              ],
            ),
            const _TagBlock(
              title: '圆形标签',
              children: <Widget>[
                UPTag(text: '标签', plain: true, shape: 'circle'),
                UPTag(text: '标签', type: 'warning', shape: 'circle'),
              ],
            ),
            const _TagBlock(
              title: '镂空标签',
              children: <Widget>[
                UPTag(text: '标签', plain: true),
                UPTag(text: '标签', type: 'warning', plain: true),
                UPTag(text: '标签', type: 'success', plain: true),
                UPTag(text: '标签', type: 'error', plain: true),
              ],
            ),
            const _TagBlock(
              title: '镂空带背景色',
              children: <Widget>[
                UPTag(text: '标签', plain: true, plainFill: true),
                UPTag(
                  text: '标签',
                  type: 'warning',
                  plain: true,
                  plainFill: true,
                ),
                UPTag(
                  text: '标签',
                  type: 'success',
                  plain: true,
                  plainFill: true,
                ),
                UPTag(
                  text: '标签',
                  type: 'error',
                  plain: true,
                  plainFill: true,
                ),
              ],
            ),
            const _TagBlock(
              title: '自定义尺寸',
              children: <Widget>[
                UPTag(text: '标签', plain: true, size: 'mini'),
                UPTag(text: '标签', type: 'warning'),
                UPTag(text: '标签', type: 'success', plain: true, size: 'large'),
              ],
            ),
            _TagBlock(
              key: const ValueKey('tag-page-closeable'),
              title: '可关闭标签',
              footer: Text('关闭状态：$_closeState'),
              children: <Widget>[
                if (_close[0])
                  UPTag(
                    text: '标签',
                    size: 'mini',
                    closable: true,
                    show: _close[0],
                    onClose: () => setState(() => _close[0] = false),
                  ),
                if (_close[1])
                  UPTag(
                    text: '标签',
                    type: 'warning',
                    closable: true,
                    show: _close[1],
                    onClose: () => setState(() => _close[1] = false),
                  ),
                if (_close[2])
                  UPTag(
                    text: '标签',
                    type: 'success',
                    plain: true,
                    size: 'large',
                    closable: true,
                    show: _close[2],
                    onClose: () => setState(() => _close[2] = false),
                  ),
              ],
            ),
            const _TagBlock(
              title: '带图片和图标',
              children: <Widget>[
                UPTag(text: '标签', size: 'mini', icon: 'map', plain: true),
                UPTag(text: '标签', type: 'warning', icon: 'tags-fill'),
                UPTag(
                  text: '标签',
                  type: 'success',
                  plain: true,
                  size: 'large',
                  iconWidget: Image(
                    image: AssetImage('assets/uview/demo/cell/tag.png'),
                    width: 17,
                    height: 17,
                  ),
                ),
              ],
            ),
            _TagBlock(
              title: '单选标签',
              footer: Text('单选：${_radio + 1}'),
              children: <Widget>[
                for (var index = 0; index < 3; index++)
                  UPTag(
                    text: '选项${index + 1}',
                    plain: _radio != index,
                    type: 'warning',
                    name: index,
                    onClick: (_) => _selectRadio(index),
                  ),
              ],
            ),
            _TagBlock(
              title: '多选标签',
              footer: Text('多选：$_checkState'),
              children: <Widget>[
                for (var index = 0; index < 3; index++)
                  UPTag(
                    text: '选项${index + 1}',
                    plain: !_checks[index],
                    type: 'warning',
                    name: index,
                    onClick: (_) => _toggleCheck(index),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TagBlock extends StatelessWidget {
  const _TagBlock({
    super.key,
    required this.title,
    required this.children,
    this.footer,
  });

  final String title;
  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 20,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: children,
            ),
            if (footer != null) ...[
              const SizedBox(height: 10),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}
