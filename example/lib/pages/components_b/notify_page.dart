import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

class NotifyPage extends StatefulWidget {
  const NotifyPage({super.key});

  @override
  State<NotifyPage> createState() => _NotifyPageState();
}

class _NotifyPageState extends State<NotifyPage> {
  final GlobalKey<UPNotifyState> _notifyKey = GlobalKey<UPNotifyState>();

  void _openNotify(_NotifyPreset preset) {
    _notifyKey.currentState?.show(options: preset.notifyData);
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '消息提示',
      scrollable: false,
      child: Stack(
        children: <Widget>[
          ListView(
            key: const ValueKey('example-page-componentsB/notify/notify'),
            padding: const EdgeInsets.only(top: 30, bottom: 24),
            children: <Widget>[
              UPCellGroup(
                children: <Widget>[
                  for (final preset in _notifyPresets)
                    UPCell(
                      title: preset.title,
                      titleStyle: const TextStyle(fontWeight: FontWeight.w500),
                      isLink: true,
                      clickable: true,
                      iconSlot: Image.asset(
                        preset.iconAsset,
                        width: 18,
                        height: 18,
                        fit: BoxFit.contain,
                      ),
                      onClick: () => _openNotify(preset),
                    ),
                ],
              ),
            ],
          ),
          UPNotify(key: _notifyKey),
        ],
      ),
    );
  }
}

class _NotifyPreset {
  const _NotifyPreset({
    required this.title,
    required this.iconAsset,
    required this.notifyData,
  });

  final String title;
  final String iconAsset;
  final Map<String, dynamic> notifyData;
}

const List<_NotifyPreset> _notifyPresets = <_NotifyPreset>[
  _NotifyPreset(
    title: '主要通知',
    iconAsset: 'assets/uview/demo/notify/main.png',
    notifyData: <String, dynamic>{
      'message': 'notify顶部提示',
      'type': 'primary',
      'color': '#ffffff',
      'bgColor': '',
      'fontSize': 15,
      'duration': 3000,
    },
  ),
  _NotifyPreset(
    title: '成功通知',
    iconAsset: 'assets/uview/demo/notify/success.png',
    notifyData: <String, dynamic>{
      'message': 'notify顶部提示',
      'type': 'success',
      'color': '#ffffff',
      'bgColor': '',
      'fontSize': 15,
      'duration': 3000,
      'safeAreaInsetTop': false,
    },
  ),
  _NotifyPreset(
    title: '危险通知',
    iconAsset: 'assets/uview/demo/notify/error.png',
    notifyData: <String, dynamic>{
      'message': 'notify顶部提示',
      'type': 'error',
      'color': '#ffffff',
      'bgColor': '',
      'fontSize': 14,
      'duration': 3000,
      'safeAreaInsetTop': false,
    },
  ),
  _NotifyPreset(
    title: '警告通知',
    iconAsset: 'assets/uview/demo/notify/warning.png',
    notifyData: <String, dynamic>{
      'message': 'notify顶部提示',
      'type': 'warning',
      'color': '#ffffff',
      'bgColor': '',
      'fontSize': 15,
      'duration': 3000,
      'safeAreaInsetTop': false,
    },
  ),
  _NotifyPreset(
    title: '自定义样式',
    iconAsset: 'assets/uview/demo/notify/customStyle.png',
    notifyData: <String, dynamic>{
      'message': 'notify顶部提示',
      'color': '#fff',
      'bgColor': '#000',
      'fontSize': 15,
      'duration': 3000,
      'safeAreaInsetTop': false,
    },
  ),
  _NotifyPreset(
    title: '自定义时间',
    iconAsset: 'assets/uview/demo/notify/customTime.png',
    notifyData: <String, dynamic>{
      'message': 'notify顶部提示',
      'type': 'primary',
      'color': '#ffffff',
      'bgColor': '',
      'fontSize': 15,
      'duration': 6000,
      'safeAreaInsetTop': false,
    },
  ),
  _NotifyPreset(
    title: '插入状态栏高度',
    iconAsset: 'assets/uview/demo/notify/height.png',
    notifyData: <String, dynamic>{
      'message': 'notify顶部提示',
      'color': '#fff',
      'bgColor': '',
      'fontSize': 15,
      'duration': 3000,
      'safeAreaInsetTop': true,
    },
  ),
];
