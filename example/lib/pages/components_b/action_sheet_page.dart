import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

class ActionSheetPage extends StatefulWidget {
  const ActionSheetPage({super.key});

  @override
  State<ActionSheetPage> createState() => _ActionSheetPageState();
}

class _ActionSheetPageState extends State<ActionSheetPage> {
  int? _activePreset;

  void _openPreset(int index) {
    if (index == 5) {
      UPToast.show(context, message: '请在微信内预览');
      return;
    }
    setState(() => _activePreset = index);
  }

  void _close() => setState(() => _activePreset = null);

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '上拉菜单',
      scrollable: false,
      child: Stack(
        children: <Widget>[
          Container(
            key: const ValueKey(
                'example-page-componentsB/actionSheet/actionSheet'),
            child: UPCellGroup(
              children: List<Widget>.generate(
                _presetTitles.length,
                (index) => UPCell(
                  title: _presetTitles[index],
                  isLink: true,
                  clickable: true,
                  onClick: () => _openPreset(index),
                ),
              ),
            ),
          ),
          if (_activePreset != null) _buildActiveSheet(),
          if (_activePreset == 4)
            Positioned(
              left: 20,
              right: 20,
              bottom: 90,
              child: IgnorePointer(
                child: Text(
                  '这是一段通过slot传入的内容,您可以在此自定义操作面板',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: UPThemeTokens.of(context).mainColor,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveSheet() {
    final preset = _activePreset!;
    return UPActionSheet(
      show: true,
      actions: preset == 0
          ? _normalActions
          : preset == 1
              ? _statusActions
              : preset == 4
                  ? const <Map<String, dynamic>>[]
                  : _standardActions,
      closeOnClickOverlay: preset != 0,
      cancelText: preset == 2 ? '取消' : '',
      description: preset == 3 ? '这是一段描述文本,字号偏小,颜色偏淡' : '',
      title: preset == 4 ? '标题位置' : '',
      round: preset == 4 ? 10 : 0,
      onClose: _close,
      onUpdateShow: (show) {
        if (!show) _close();
      },
    );
  }
}

const List<String> _presetTitles = <String>[
  '普通使用',
  '设置状态',
  '显示取消按钮',
  '描述内容',
  '显示标题(显示圆角)',
  '微信开放能力',
];

const List<Map<String, dynamic>> _normalActions = <Map<String, dynamic>>[
  <String, dynamic>{'name': '选项1'},
  <String, dynamic>{'name': '选项2'},
  <String, dynamic>{'name': '选项2'},
  <String, dynamic>{'name': '选项2'},
  <String, dynamic>{'name': '选项2'},
  <String, dynamic>{'name': '选项2'},
  <String, dynamic>{'name': '选项2'},
  <String, dynamic>{'name': '选项2'},
  <String, dynamic>{'name': '选项2'},
  <String, dynamic>{'name': '选项2'},
  <String, dynamic>{'name': '选项2'},
  <String, dynamic>{'name': '选项2'},
  <String, dynamic>{'name': '选项3', 'subname': '描述文本'},
];

const List<Map<String, dynamic>> _statusActions = <Map<String, dynamic>>[
  <String, dynamic>{'name': '选项1'},
  <String, dynamic>{'loading': true},
  <String, dynamic>{'name': '选项被禁用', 'disabled': true},
];

const List<Map<String, dynamic>> _standardActions = <Map<String, dynamic>>[
  <String, dynamic>{'name': '选项1'},
  <String, dynamic>{'name': '选项2'},
  <String, dynamic>{'name': '选项3'},
];
