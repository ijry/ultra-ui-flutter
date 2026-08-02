import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import 'up_button.dart';
import 'up_icon.dart';
import 'up_image.dart';

/// Port of u-no-network.
class UPNoNetwork extends StatefulWidget {
  const UPNoNetwork({
    super.key,
    this.tips = '哎呀，网络信号丢失',
    this.zIndex = '',
    this.image = '',
    this.show = true,
    this.onUpdateShow,
    this.onRetry,
    this.onDisconnected,
    this.onConnected,
    this.customStyle,
  });

  final String tips;
  final dynamic zIndex;
  final String image;
  final bool show;
  final ValueChanged<bool>? onUpdateShow;
  final VoidCallback? onRetry;
  final VoidCallback? onDisconnected;
  final VoidCallback? onConnected;

  final BoxDecoration? customStyle;
  @override
  State<UPNoNetwork> createState() => UPNoNetworkState();
}

class UPNoNetworkState extends State<UPNoNetwork> {
  /// Source data.
  bool isConnected = true;
  String networkType = 'unknown';

  bool? _forcedShow;

  bool get isVisible => _forcedShow ?? widget.show;

  void show() {
    widget.onUpdateShow?.call(true);
    setState(() => _forcedShow = true);
    widget.onDisconnected?.call();
  }

  void hide() {
    widget.onUpdateShow?.call(false);
    setState(() => _forcedShow = false);
    widget.onConnected?.call();
  }

  void retry() => widget.onRetry?.call();

  /// Source host helper `toast` (presentation is host-owned).
  dynamic lastToast;
  void toast([String message = '']) {
    lastToast = message;
  }

  /// Source `emitEvent` — host can observe via onRetry / connectivity hooks.
  void emitEvent([String type = 'retry']) {
    if (type == 'retry') {
      retry();
    } else if (type == 'disconnected') {
      widget.onDisconnected?.call();
    } else if (type == 'connected') {
      widget.onConnected?.call();
    }
  }

  /// Host-only settings open retained for API compatibility (uni open settings).
  /// Source openSettings alias (Batch J + BI).
  bool openedAppSettings = false;
  bool openedSystemSettings = false;
  void openSettings([dynamic _]) => openAppSettings();

  void openAppSettings([dynamic _]) {
    openedAppSettings = true;
  }

  void openSystemSettings([dynamic _]) {
    openedSystemSettings = true;
  }

  void gotoAppSetting() => openAppSettings();
  void gotoiOSSetting() => openSystemSettings();
  void gotoAndroidSetting() => openSystemSettings();

  /// Source `network` helper — visibility reflects offline UI.
  bool network() => !isVisible;

  @override
  void initState() {
    super.initState();
    if (isVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onDisconnected?.call();
      });
    }
  }

  @override
  void didUpdateWidget(covariant UPNoNetwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.show && widget.show) {
      widget.onDisconnected?.call();
    } else if (oldWidget.show && !widget.show) {
      widget.onConnected?.call();
    }
  }

  Widget _image(UPThemeTokens tokens) {
    final src = widget.image;
    if (src.isEmpty) {
      return UPIcon(name: 'wifi-off', size: 80, color: tokens.tipsColor);
    }
    if (src.startsWith('http://') ||
        src.startsWith('https://') ||
        src.startsWith('assets/')) {
      return UPImage(
        src: src,
        width: 150,
        height: 150,
        mode: 'aspectFit',
        showLoading: false,
      );
    }
    if (src.startsWith('data:image')) {
      return UPIcon(name: 'wifi-off', size: 80, color: tokens.tipsColor);
    }
    return UPIcon(name: src, size: 80, color: tokens.tipsColor);
  }

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    final tokens = UPThemeTokens.of(context);
    Widget root = Stack(
      children: [
        const Positioned.fill(
          child: ColoredBox(color: Color(0xFFFFFFFF)),
        ),
        Center(
          child: Transform.translate(
            offset: const Offset(0, -50),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _image(tokens),
                const SizedBox(height: 15),
                Text(
                  widget.tips,
                  style: TextStyle(color: tokens.tipsColor, fontSize: 14),
                ),
                const SizedBox(height: 15),
                UPButton(
                  text: '重试',
                  type: 'primary',
                  size: 'mini',
                  plain: true,
                  onClick: widget.onRetry,
                ),
              ],
            ),
          ),
        ),
      ],
    );
    return root;
  }
}
