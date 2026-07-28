import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';
import 'up_status_bar.dart';
import 'up_transition.dart';

/// Port of u-notify / up-notify.
///
/// Supports both declarative [show] and imperative [UPNotifyState.show].
class UPNotify extends StatefulWidget {
  bool typeof(dynamic v, [String type = ""]) => type.isEmpty
      ? v != null
      : v.runtimeType.toString().toLowerCase().contains(type.toLowerCase());

  const UPNotify({
    super.key,
    this.show = false,
    this.top = 0,
    this.type = 'primary',
    this.color = '#ffffff',
    this.bgColor = '',
    this.message = '',
    this.duration = 3000,
    this.fontSize = 15,
    this.safeAreaInsetTop = false,
    this.icon,
    this.customStyle,
    this.onOpen,
    this.onClose,
    this.onUpdateShow,
    this.onClick,
  });

  final bool show;
  final dynamic top;
  final String type;
  final dynamic color;
  final dynamic bgColor;
  final String message;
  final dynamic duration;
  final dynamic fontSize;
  final bool safeAreaInsetTop;
  final String? icon;
  final BoxDecoration? customStyle;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;

  /// Source update:show alias.
  final ValueChanged<bool>? onUpdateShow;
  final VoidCallback? onClick;

  /// Source computed: containerStyle.
  dynamic get containerStyle {
    final t = num.tryParse('$top') ?? 0;
    return <String, dynamic>{
      'top': UPUtils.addUnit(t),
      'position': 'fixed',
      'left': 0,
      'right': 0,
      'zIndex': 10076,
    };
  }

  /// Source computed: backgroundColor.
  dynamic get backgroundColor {
    final style = <String, dynamic>{};
    final bg = '$bgColor'.trim();
    if (bg.isNotEmpty) style['backgroundColor'] = bgColor;
    return style;
  }

  @override
  State<UPNotify> createState() => UPNotifyState();
}

class UPNotifyState extends State<UPNotify> {
  bool open = false;
  late Map<String, dynamic> _config;
  late Map<String, dynamic> _tmpConfig;
  Timer? timer;

  /// Source retained config fields.
  Map get config => Map<String, dynamic>.from(_config);
  Map get tmpConfig => Map<String, dynamic>.from(_tmpConfig);
  set config(Map value) => _config = Map<String, dynamic>.from(value);
  set tmpConfig(Map value) => _tmpConfig = Map<String, dynamic>.from(value);

  @override
  void initState() {
    super.initState();
    _config = {
      'top': widget.top,
      'type': widget.type,
      'color': widget.color,
      'bgColor': widget.bgColor,
      'message': widget.message,
      'duration': widget.duration,
      'fontSize': widget.fontSize,
      'safeAreaInsetTop': widget.safeAreaInsetTop,
      'icon': widget.icon,
    };
    _tmpConfig = Map<String, dynamic>.from(_config);
    if (widget.show) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.show) show();
      });
    }
  }

  @override
  void didUpdateWidget(covariant UPNotify oldWidget) {
    super.didUpdateWidget(oldWidget);
    _config = {
      'top': widget.top,
      'type': widget.type,
      'color': widget.color,
      'bgColor': widget.bgColor,
      'message': widget.message,
      'duration': widget.duration,
      'fontSize': widget.fontSize,
      'safeAreaInsetTop': widget.safeAreaInsetTop,
      'icon': widget.icon,
    };
    final showChanged = oldWidget.show != widget.show;
    if (showChanged) {
      if (widget.show) {
        show();
      } else {
        close();
      }
    } else if (open) {
      // Keep visible message in sync for declarative usage.
      setState(() {
        _tmpConfig = {
          ..._tmpConfig,
          'message': widget.message,
          'type': widget.type,
          'color': widget.color,
          'bgColor': widget.bgColor,
          'top': widget.top,
          'fontSize': widget.fontSize,
          'safeAreaInsetTop': widget.safeAreaInsetTop,
          'icon': widget.icon,
        };
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void primary(String msg) =>
      show(options: {'type': 'primary', 'message': msg});
  void success(String msg) =>
      show(options: {'type': 'success', 'message': msg});
  void error(String msg) => show(options: {'type': 'error', 'message': msg});
  void warning(String msg) =>
      show(options: {'type': 'warning', 'message': msg});

  void show({Map? options}) {
    final merged = <String, dynamic>{..._config, ...?options};
    timer?.cancel();
    setState(() {
      open = true;
      _tmpConfig = merged;
    });
    widget.onOpen?.call();
    widget.onUpdateShow?.call(true);
    final d = (num.tryParse('${merged['duration']}') ?? 3000).toInt();
    if (d > 0) {
      timer = Timer(Duration(milliseconds: d), () {
        close();
        final complete = merged['complete'];
        if (complete is VoidCallback) complete();
        if (complete is Function) {
          try {
            complete();
          } catch (_) {}
        }
      });
    }
  }

  void close() {
    clearTimer();
  }

  void clearTimeout() => clearTimer();

  void clearTimer() {
    timer?.cancel();
    timer = null;
    if (!open) return;
    setState(() => open = false);
    widget.onClose?.call();
    widget.onUpdateShow?.call(false);
  }

  Color _typeColor(UPThemeTokens tokens, String type) {
    switch (type) {
      case 'success':
        return tokens.success;
      case 'warning':
        return tokens.warning;
      case 'error':
        return tokens.error;
      case 'primary':
      default:
        return tokens.primary;
    }
  }

  String? _resolveIcon(String type) {
    final custom = _tmpConfig['icon'];
    if (custom is String && custom.isNotEmpty) return custom;
    switch (type) {
      case 'success':
        return 'checkmark-circle';
      case 'error':
        return 'close-circle';
      case 'warning':
        return 'error-circle';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final type = '${_tmpConfig['type'] ?? 'primary'}';
    final bg =
        UPUtils.parseColor(_tmpConfig['bgColor']) ?? _typeColor(tokens, type);
    final textColor = UPUtils.parseColor(_tmpConfig['color']) ?? Colors.white;
    final topPx = UPUtils.getPx(_tmpConfig['top'] ?? 0);
    final fs = UPUtils.getPx(_tmpConfig['fontSize'] ?? 15);
    final safeTop = _tmpConfig['safeAreaInsetTop'] == true;
    final iconName = _resolveIcon(type);
    // Source hardcodes zIndex: 10076 for fixed top layer.
    return IgnorePointer(
      ignoring: !open,
      child: Align(
        alignment: Alignment.topCenter,
        child: UPTransition(
          show: open,
          mode: 'slide-down',
          duration: 250,
          child: Material(
            type: MaterialType.transparency,
            elevation: 0,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: topPx),
              decoration:
                  (widget.customStyle ?? const BoxDecoration()).copyWith(
                color: widget.customStyle?.color ?? bg,
              ),
              child: GestureDetector(
                onTap: widget.onClick,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (safeTop) const UPStatusBar(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (iconName != null) ...[
                            UPIcon(
                              name: iconName,
                              color: textColor,
                              size: (fs > 0 ? fs : 15) * 1.3,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Flexible(
                            child: Text(
                              '${_tmpConfig['message'] ?? ''}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textColor,
                                fontSize: fs > 0 ? fs : 15,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
