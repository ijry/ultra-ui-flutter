import 'dart:async';

import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';

class UPAlert extends StatefulWidget {
  const UPAlert({
    super.key,
    this.title = '',
    this.type = 'warning',
    this.description = '',
    this.closable = false,
    this.showIcon = false,
    this.effect = 'light',
    this.center = false,
    this.fontSize = 14,
    this.transitionMode = 'fade',
    this.duration = 0,
    this.icon = '',
    this.modelValue = true,
    this.onClick,
    this.onClose,
    this.onClosed,
    this.onUpdateModelValue,
    this.customStyle,
    this.alert,
  });

  /// Source prop retained: alert (host/content alias).
  final dynamic alert;

  final String title;
  final String type;
  final String description;
  final bool closable;
  final bool showIcon;
  final String effect;
  final bool center;
  final dynamic fontSize;
  final String transitionMode;
  final dynamic duration;
  final String icon;
  final bool modelValue;
  final VoidCallback? onClick;
  final VoidCallback? onClose;
  final VoidCallback? onClosed;
  final ValueChanged<bool>? onUpdateModelValue;
  final BoxDecoration? customStyle;

  /// Source computed: iconColor.
  dynamic get iconColor => effect == 'light' ? type : '#fff';

  /// Source computed: iconName.
  dynamic get iconName {
    if (icon.isNotEmpty) return icon;
    switch (type) {
      case 'success':
        return 'checkmark-circle-fill';
      case 'error':
        return 'close-circle-fill';
      case 'warning':
        return 'error-circle-fill';
      case 'info':
        return 'info-circle-fill';
      case 'primary':
        return 'more-circle-fill';
      default:
        return 'error-circle-fill';
    }
  }

  @override
  State<UPAlert> createState() => UPAlertState();
}

class UPAlertState extends State<UPAlert> {
  late bool show;
  Timer? _timer;

  bool get isShown => show;

  void open({bool emit = true}) {
    if (show) return;
    setState(() => show = true);
    if (emit) widget.onUpdateModelValue?.call(true);
    _scheduleAutoClose();
  }

  void close({bool emit = true}) {
    if (!show) return;
    setState(() => show = false);
    if (emit) {
      widget.onUpdateModelValue?.call(false);
      final ms = int.tryParse('${widget.duration}') ?? 0;
      if (ms > 0) widget.onClosed?.call();
      widget.onClose?.call();
    }
  }

  void toggle({bool emit = true}) {
    if (show) {
      close(emit: emit);
    } else {
      open(emit: emit);
    }
  }

  /// Source `clickHandler` — emit click.
  void clickHandler() {
    widget.onClick?.call();
  }

  /// Source `closeHandler` — hide and emit close.
  void closeHandler() => close();

  @override
  void initState() {
    super.initState();
    show = widget.modelValue;
    _scheduleAutoClose();
  }

  @override
  void didUpdateWidget(covariant UPAlert oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.modelValue != widget.modelValue) {
      show = widget.modelValue;
    }
    if (oldWidget.duration != widget.duration ||
        oldWidget.modelValue != widget.modelValue) {
      _scheduleAutoClose();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _scheduleAutoClose() {
    _timer?.cancel();
    final ms = int.tryParse('${widget.duration}') ?? 0;
    if (show && ms > 0) {
      _timer = Timer(Duration(milliseconds: ms), _close);
    }
  }

  void _close() => close();

  Color _bg(UPThemeTokens tokens) {
    final dark = widget.effect == 'dark';
    switch (widget.type) {
      case 'success':
        return dark ? tokens.success : tokens.successLight;
      case 'error':
        return dark ? tokens.error : tokens.errorLight;
      case 'info':
        return dark ? tokens.info : tokens.infoLight;
      case 'primary':
        return dark ? tokens.primary : tokens.primaryLight;
      case 'warning':
      default:
        return dark ? tokens.warning : tokens.warningLight;
    }
  }

  Color _fg(UPThemeTokens tokens) {
    if (widget.effect == 'dark') return const Color(0xFFFFFFFF);
    switch (widget.type) {
      case 'success':
        return tokens.success;
      case 'error':
        return tokens.error;
      case 'info':
        return tokens.info;
      case 'primary':
        return tokens.primary;
      case 'warning':
      default:
        return tokens.warning;
    }
  }

  String get _iconName {
    if (widget.icon.isNotEmpty) return widget.icon;
    switch (widget.type) {
      case 'success':
        return 'checkmark-circle-fill';
      case 'error':
        return 'close-circle-fill';
      case 'info':
        return 'info-circle-fill';
      case 'primary':
        return 'more-circle-fill';
      case 'warning':
      default:
        return 'error-circle-fill';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();
    final tokens = UPThemeTokens.of(context);
    final fs = UPUtils.getPx(widget.fontSize);
    final fg = _fg(tokens);
    final align = widget.center ? TextAlign.center : TextAlign.left;

    return GestureDetector(
      onTap: clickHandler,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: (widget.customStyle ?? const BoxDecoration()).copyWith(
          color: widget.customStyle?.color ?? _bg(tokens),
          borderRadius:
              widget.customStyle?.borderRadius ?? BorderRadius.circular(4),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showIcon) ...[
              UPIcon(
                name: _iconName,
                size: 18,
                color: widget.effect == 'dark' ? '#ffffff' : widget.type,
              ),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: widget.closable ? 20 : 0),
                child: Column(
                  crossAxisAlignment: widget.center
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    if (widget.title.isNotEmpty)
                      Text(
                        widget.title,
                        textAlign: align,
                        style: TextStyle(
                          color: fg,
                          fontSize: fs,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    if (widget.description.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(
                          top: widget.title.isNotEmpty ? 2 : 0,
                        ),
                        child: Text(
                          widget.description,
                          textAlign: align,
                          style: TextStyle(
                            color: fg.withValues(alpha: 0.9),
                            fontSize: fs,
                            height: 1.3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (widget.closable)
              GestureDetector(
                onTap: closeHandler,
                behavior: HitTestBehavior.opaque,
                child: UPIcon(
                  name: 'close',
                  size: 15,
                  color: widget.effect == 'dark' ? '#ffffff' : widget.type,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
