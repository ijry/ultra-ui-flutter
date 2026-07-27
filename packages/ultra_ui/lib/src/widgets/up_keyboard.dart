import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import 'up_car_keyboard.dart';
import 'up_number_keyboard.dart';
import 'up_popup.dart';

/// 1:1 port of u-keyboard.
class UPKeyboard extends StatefulWidget {
  const UPKeyboard({
    super.key,
    this.mode = 'number',
    this.dotDisabled = false,
    this.tooltip = true,
    this.showTips = true,
    this.tips = '',
    this.showCancel = true,
    this.showConfirm = true,
    this.random = false,
    this.safeAreaInsetBottom = true,
    this.closeOnClickOverlay = true,
    this.show = false,
    this.overlay = true,
    this.zIndex = 10075,
    this.cancelText = '取消',
    this.confirmText = '确认',
    this.autoChange = false,
    this.onChange,
    this.onClose,
    this.onConfirm,
    this.onCancel,
    this.onBackspace,
    this.onUpdateShow,
    this.child,
    this.customStyle,
  });

  final String mode; // number | card | car
  final bool dotDisabled;
  final bool tooltip;
  final bool showTips;
  final String tips;
  final bool showCancel;
  final bool showConfirm;
  final bool random;
  final bool safeAreaInsetBottom;
  final bool closeOnClickOverlay;
  final bool show;
  final bool overlay;
  final dynamic zIndex;
  final String cancelText;
  final String confirmText;
  final bool autoChange;
  final ValueChanged<dynamic>? onChange;
  final VoidCallback? onClose;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onBackspace;
  final ValueChanged<bool>? onUpdateShow;
  final Widget? child;

  final BoxDecoration? customStyle;

  /// Source computed: popupStyle.
  dynamic get popupStyle => <String, dynamic>{
        'backgroundColor': 'rgb(214, 218, 220)',
        'display': show ? 'flex' : 'none',
        'mode': mode,
      };

  @override
  State<UPKeyboard> createState() => UPKeyboardState();
}

class UPKeyboardState extends State<UPKeyboard> {
  bool? _localShow;
  final GlobalKey<UPCarKeyboardState> _carKey = GlobalKey<UPCarKeyboardState>();
  final GlobalKey<UPNumberKeyboardState> _numberKey =
      GlobalKey<UPNumberKeyboardState>();

  bool get isShown => _localShow ?? widget.show;

  String get _tips {
    if (widget.tips.isNotEmpty) return widget.tips;
    if (widget.mode == 'number') return '数字键盘';
    if (widget.mode == 'card') return '身份证键盘';
    return '车牌号键盘';
  }

  bool get _usesNumberKeyboard =>
      widget.mode == 'number' || widget.mode == 'card';

  @override
  void didUpdateWidget(covariant UPKeyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.show != widget.show) {
      _localShow = null;
    }
  }

  void open({bool emit = true}) {
    if (isShown) return;
    setState(() => _localShow = true);
    if (emit) widget.onUpdateShow?.call(true);
  }

  void close({bool emit = true}) {
    if (!isShown) return;
    setState(() => _localShow = false);
    if (emit) {
      widget.onUpdateShow?.call(false);
      widget.onClose?.call();
    }
  }

  void toggle({bool emit = true}) {
    if (isShown) {
      close(emit: emit);
    } else {
      open(emit: emit);
    }
  }

  /// Source `change` helper — forward a key press.
  void change(dynamic value) {
    if (widget.mode == 'car') {
      final state = _carKey.currentState;
      if (state != null) {
        state.input('$value');
        return;
      }
    } else {
      final state = _numberKey.currentState;
      if (state != null) {
        state.input(value);
        return;
      }
    }
    widget.onChange?.call(value);
  }

  /// Source `backspace`.
  void backspace() {
    if (widget.mode == 'car') {
      final state = _carKey.currentState;
      if (state != null) {
        state.backspace();
        return;
      }
    } else {
      final state = _numberKey.currentState;
      if (state != null) {
        state.backspace();
        return;
      }
    }
    widget.onBackspace?.call();
  }

  /// Source confirm / cancel aliases.
  void onConfirm() {
    widget.onConfirm?.call();
    close();
  }

  void onCancel() {
    widget.onCancel?.call();
    close();
  }

  void popupClose() => close();

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final panel = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.child != null) widget.child!,
        if (widget.tooltip)
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: tokens.cardBgColor,
            child: Row(
              children: [
                if (widget.showCancel)
                  GestureDetector(
                    onTap: onCancel,
                    child: Text(
                      widget.cancelText,
                      style: TextStyle(color: tokens.tipsColor, fontSize: 15),
                    ),
                  )
                else
                  const SizedBox(width: 40),
                Expanded(
                  child: widget.showTips
                      ? Text(
                          _tips,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: tokens.contentColor,
                            fontSize: 14,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                if (widget.showConfirm)
                  GestureDetector(
                    onTap: onConfirm,
                    child: Text(
                      widget.confirmText,
                      style: TextStyle(color: tokens.primary, fontSize: 15),
                    ),
                  )
                else
                  const SizedBox(width: 40),
              ],
            ),
          ),
        if (_usesNumberKeyboard)
          UPNumberKeyboard(
            key: _numberKey,
            mode: widget.mode == 'card' ? 'card' : 'number',
            dotDisabled: widget.dotDisabled,
            random: widget.random,
            onChange: widget.onChange,
            onBackspace: widget.onBackspace,
          )
        else
          UPCarKeyboard(
            key: _carKey,
            random: widget.random,
            autoChange: widget.autoChange,
            onChange: widget.onChange,
            onBackspace: widget.onBackspace,
          ),
      ],
    );

    Widget root = UPPopup(
      show: isShown,
      overlay: widget.overlay,
      mode: 'bottom',
      zIndex: widget.zIndex,
      safeAreaInsetBottom: widget.safeAreaInsetBottom,
      closeOnClickOverlay: widget.closeOnClickOverlay,
      bgColor: 'rgb(214, 218, 220)',
      round: 0,
      onClose: () => close(),
      child: panel,
    );

    return root;
  }
}
