import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

class ToastPage extends StatefulWidget {
  const ToastPage({super.key});

  @override
  State<ToastPage> createState() => _ToastPageState();
}

class _ToastPageState extends State<ToastPage> {
  Timer? _unresolvedRouteTimer;

  @override
  void dispose() {
    _unresolvedRouteTimer?.cancel();
    super.dispose();
  }

  void _showToast(_ToastPreset preset) {
    _unresolvedRouteTimer?.cancel();
    UPToast.show(
      context,
      message: preset.message,
      type: preset.hideIcon ? '' : preset.type,
      icon: preset.icon,
      loading: preset.loading,
      overlay: true,
      position: preset.position,
      duration: 2000,
    );

    if (preset.unresolvedUrl.isNotEmpty) {
      _unresolvedRouteTimer = Timer(const Duration(milliseconds: 2100), () {
        if (mounted) {
          UPToast.show(context, message: 'Tag 页面尚未迁移');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '提示消息',
      child: Container(
        key: const ValueKey('example-page-componentsB/toast/toast'),
        padding: const EdgeInsets.only(top: 30),
        child: UPCellGroup(
          children: List<Widget>.generate(
            _toastPresets.length,
            (index) {
              final preset = _toastPresets[index];
              return UPCell(
                title: preset.title,
                titleStyle: const TextStyle(fontWeight: FontWeight.w500),
                isLink: true,
                clickable: true,
                onClick: () => _showToast(preset),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ToastPreset {
  const _ToastPreset({
    required this.type,
    required this.title,
    required this.message,
    this.position = 'center',
    this.icon = '',
    this.hideIcon = false,
    this.loading = false,
    this.unresolvedUrl = '',
  });

  final String type;
  final String title;
  final String message;
  final String position;
  final String icon;
  final bool hideIcon;
  final bool loading;
  final String unresolvedUrl;
}

const List<_ToastPreset> _toastPresets = <_ToastPreset>[
  _ToastPreset(type: 'default', title: '默认主题', message: '锦瑟无端五十弦'),
  _ToastPreset(
    type: 'error',
    title: '失败主题(不带图标)',
    message: '一弦一柱思华年',
    hideIcon: true,
  ),
  _ToastPreset(type: 'success', title: '成功主题(带图标)', message: '庄生晓梦迷蝴蝶'),
  _ToastPreset(
    type: 'warning',
    title: '位置偏移上方',
    message: '望帝春心托杜鹃',
    position: 'top',
  ),
  _ToastPreset(type: 'loading', title: '正在加载', message: '正在加载', loading: true),
  _ToastPreset(
    type: 'default',
    title: '结束后跳转标签页',
    message: '此情可待成追忆',
    unresolvedUrl: '/pages/componentsB/tag/tag',
  ),
  _ToastPreset(
    type: 'default',
    title: '其它icon图标',
    message: '只是当时已惘然',
    icon: 'photo',
  ),
  _ToastPreset(
    type: 'default',
    title: '自定义图片图标',
    message: '只是当时已惘然',
    icon: 'assets/uview/demo/toast/jump.png',
  ),
];
