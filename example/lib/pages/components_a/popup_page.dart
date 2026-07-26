import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

class PopupPage extends StatefulWidget {
  const PopupPage({super.key});

  @override
  State<PopupPage> createState() => _PopupPageState();
}

class _PopupPageState extends State<PopupPage> {
  static const _PopupPreset _defaultPreset = _PopupPreset(overlay: true);

  bool _show = false;
  _PopupPreset _preset = _defaultPreset;

  void _open(_PopupPreset preset) {
    setState(() {
      _preset = preset;
      _show = true;
    });
  }

  void _close() => setState(() => _show = false);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_show,
      // Keep the declared Flutter 3.19 minimum SDK compatible.
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) {
        if (!didPop && _show) _close();
      },
      child: ExamplePageScaffold(
        title: '弹窗',
        scrollable: false,
        child: Stack(
          children: <Widget>[
            Container(
              key: const ValueKey('example-page-componentsA/popup/popup'),
              padding: const EdgeInsets.only(top: 20),
              child: UPCellGroup(
                children: _popupOptions
                    .map(
                      (option) => _PopupCell(
                        title: option.title,
                        asset: option.asset,
                        onClick: () => _open(option.preset),
                      ),
                    )
                    .toList(),
              ),
            ),
            UPPopup(
              show: _show,
              safeAreaInsetBottom: true,
              safeAreaInsetTop: true,
              mode: _preset.mode,
              round: _preset.round,
              overlay: _preset.overlay,
              closeable: _preset.closeable,
              closeOnClickOverlay: _preset.closeOnClickOverlay,
              touchable: _preset.touchable,
              minHeight: _preset.minHeight,
              maxHeight: _preset.maxHeight,
              onClose: _close,
              onUpdateShow: (show) => setState(() => _show = show),
              child: _PopupContent(
                mode: _preset.mode,
                scrollHeight: _preset.scrollHeight,
                onClose: _close,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopupContent extends StatelessWidget {
  const _PopupContent({
    required this.mode,
    required this.scrollHeight,
    required this.onClose,
  });

  final String mode;
  final double scrollHeight;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final horizontal = mode == 'top' || mode == 'bottom';
    return Container(
      width: horizontal ? double.infinity : 200,
      margin: EdgeInsets.only(top: mode == 'left' || mode == 'right' ? 160 : 0),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 120,
            height: scrollHeight,
            child: ListView.builder(
              itemCount: 30,
              itemBuilder: (context, index) => Text('列表滚动${index + 1}'),
            ),
          ),
          const SizedBox(height: 10),
          UPButton(
            text: '点我关闭',
            type: 'success',
            size: 'small',
            onClick: onClose,
          ),
        ],
      ),
    );
  }
}

class _PopupCell extends StatelessWidget {
  const _PopupCell({
    required this.title,
    required this.asset,
    required this.onClick,
  });

  final String title;
  final String asset;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return UPCell(
      title: title,
      titleStyle: const TextStyle(fontWeight: FontWeight.w500),
      isLink: true,
      clickable: true,
      iconSlot: Image.asset(asset, width: 48, height: 30, fit: BoxFit.contain),
      onClick: onClick,
    );
  }
}

class _PopupOption {
  const _PopupOption(this.title, this.asset, this.preset);

  final String title;
  final String asset;
  final _PopupPreset preset;
}

class _PopupPreset {
  const _PopupPreset({
    this.overlay = true,
    this.mode = 'bottom',
    this.round = '',
    this.closeable = false,
    this.closeOnClickOverlay = true,
    this.touchable = false,
    this.minHeight = '200px',
    this.maxHeight = '600px',
    this.scrollHeight = 80,
  });

  final bool overlay;
  final String mode;
  final dynamic round;
  final bool closeable;
  final bool closeOnClickOverlay;
  final bool touchable;
  final dynamic minHeight;
  final dynamic maxHeight;
  final double scrollHeight;
}

const List<_PopupOption> _popupOptions = <_PopupOption>[
  _PopupOption(
    '顶部弹出',
    'assets/uview/demo/popup/modeTop.png',
    _PopupPreset(mode: 'top'),
  ),
  _PopupOption(
    '右侧弹出',
    'assets/uview/demo/popup/modeRight.png',
    _PopupPreset(mode: 'right'),
  ),
  _PopupOption(
    '底部弹出',
    'assets/uview/demo/popup/modeBottom.png',
    _PopupPreset(mode: 'bottom'),
  ),
  _PopupOption(
    '左侧弹出',
    'assets/uview/demo/popup/modeLeft.png',
    _PopupPreset(mode: 'left'),
  ),
  _PopupOption(
    '居中弹出',
    'assets/uview/demo/popup/modeCenter.png',
    _PopupPreset(mode: 'center', round: 10),
  ),
  _PopupOption(
    '显示圆角',
    'assets/uview/demo/popup/showRadis.png',
    _PopupPreset(round: 10),
  ),
  _PopupOption(
    '禁止点击遮罩关闭',
    'assets/uview/demo/popup/noClose.png',
    _PopupPreset(closeOnClickOverlay: false),
  ),
  _PopupOption(
    '显示关闭按钮',
    'assets/uview/demo/popup/showCloseBtn.png',
    _PopupPreset(closeable: true),
  ),
  _PopupOption(
    '底部弹出(支持手势)',
    'assets/uview/demo/popup/showCloseBtn.png',
    _PopupPreset(
      closeable: true,
      touchable: true,
      minHeight: '300rpx',
      maxHeight: '80%',
      scrollHeight: 500,
    ),
  ),
];
