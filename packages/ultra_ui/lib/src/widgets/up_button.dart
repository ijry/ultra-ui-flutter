import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';
import 'up_loading_icon.dart';

/// 1:1 port of u-button defaults/metrics.
class UPButton extends StatefulWidget {
  /// Source host helper.
  dynamic resolveNvueColor([dynamic c]) => c;

  const UPButton({
    super.key,
    this.hairline = false,
    this.type = 'info',
    this.size = 'normal',
    this.shape = 'square',
    this.plain = false,
    this.disabled = false,
    this.loading = false,
    this.loadingText = '',
    this.loadingMode = 'spinner',
    this.loadingSize = 15,
    this.throttleTime = 0,
    this.hoverStartTime = 0,
    this.hoverStayTime = 200,
    this.text = '',
    this.icon = '',
    this.iconColor = '',
    this.color = '',
    this.stop = true,
    // Platform-only retained API (no-op on Flutter)
    this.openType = '',
    this.formType = '',
    this.appParameter = '',
    this.hoverStopPropagation = true,
    this.lang = 'en',
    this.sessionFrom = '',
    this.sendMessageTitle = '',
    this.sendMessagePath = '',
    this.sendMessageImg = '',
    this.showMessageCard = false,
    this.dataName = '',
    this.customStyle,
    this.child,
    this.onClick,
    this.onGetphonenumber,
    this.onGetuserinfo,
    this.onError,
    this.onOpensetting,
    this.onLaunchapp,
    this.onAgreeprivacyauthorization,
  });

  /// Source host helper.
  void error([dynamic e]) => onError?.call(e);

  final bool hairline;
  final String type;
  final String size;
  final String shape;
  final bool plain;
  final bool disabled;
  final bool loading;
  final dynamic loadingText;
  final String loadingMode;
  final num loadingSize;
  final num throttleTime;
  final num hoverStartTime;
  final num hoverStayTime;
  final dynamic text;
  final String icon;
  final String iconColor;
  final String color;
  final bool stop;
  final String openType;
  final String formType;
  final String appParameter;
  final bool hoverStopPropagation;
  final String lang;
  final String sessionFrom;
  final String sendMessageTitle;
  final String sendMessagePath;
  final String sendMessageImg;
  final bool showMessageCard;
  final String dataName;
  final BoxDecoration? customStyle;
  final Widget? child;
  final VoidCallback? onClick;

  /// Platform openType emit aliases (host retained).
  final ValueChanged<dynamic>? onGetphonenumber;
  final ValueChanged<dynamic>? onGetuserinfo;
  final ValueChanged<dynamic>? onError;
  final ValueChanged<dynamic>? onOpensetting;
  final ValueChanged<dynamic>? onLaunchapp;
  final ValueChanged<dynamic>? onAgreeprivacyauthorization;

  /// Source computed: bem-like class tokens for host styling parity.
  dynamic get bemClass {
    final parts = <String>['u-button', 'u-button--$shape', 'u-button--$size'];
    final hasCustomColor = color.trim().isNotEmpty;
    if (!hasCustomColor) {
      parts.add('u-button--$type');
    }
    if (disabled) parts.add('u-button--disabled');
    if (plain) parts.add('u-button--plain');
    if (hairline) parts.add('u-button--hairline');
    return parts.join(' ');
  }

  /// Source computed: dark theme flag (Flutter host can override via theme later).
  dynamic get isDarkTheme => false;

  /// Source computed nvue color helpers with light defaults.
  dynamic get nvueMainColor => isDarkTheme == true ? '#f5f5f5' : '#303133';
  dynamic get nvueBorderColor => isDarkTheme == true ? '#3a3a3c' : '#dadbde';

  /// Source computed theme type color.
  dynamic get themeTypeColor {
    switch (type) {
      case 'primary':
        return '#3c9cff';
      case 'success':
        return '#5ac725';
      case 'warning':
        return '#f9ae3d';
      case 'error':
        return '#f56c6c';
      case 'info':
      default:
        return '#909399';
    }
  }

  dynamic get nvueInfoBackgroundColor =>
      isDarkTheme == true ? '#1c1c1e' : '#ffffff';
  dynamic get nvuePlainBackgroundColor =>
      isDarkTheme == true ? '#1c1c1e' : '#ffffff';

  /// Source computed baseColor style map.
  dynamic get baseColor {
    final custom = color;
    if (custom.trim().isEmpty) {
      return const <String, dynamic>{};
    }
    final style = <String, dynamic>{};
    final colorText = '$custom';
    if (plain) {
      style['color'] = custom;
    } else {
      style['color'] = 'white';
      style['background-color'] = custom;
    }
    if (colorText.contains('gradient')) {
      style['border-width'] = 0;
      style['background-image'] = custom;
    }
    return style;
  }

  /// Source computed nvue text style.
  dynamic get nvueTextStyle => <String, dynamic>{
        'fontSize': textSize,
        'color': plain
            ? (color.isNotEmpty ? color : type)
            : (type == 'info' ? nvueMainColor : '#ffffff'),
      };

  /// Source computed text size by button size.
  dynamic get textSize {
    switch (size) {
      case 'large':
        return 16;
      case 'small':
        return 12;
      case 'mini':
        return 10;
      case 'normal':
      default:
        return 14;
    }
  }

  /// Source computed loading color.
  dynamic get loadingColor {
    if (plain) {
      return color.isNotEmpty ? color : themeTypeColor;
    }
    if (type == 'info') {
      return isDarkTheme == true ? '#9ca3af' : '#c9c9c9';
    }
    return 'rgb(200, 200, 200)';
  }

  @override
  State<UPButton> createState() => UPButtonState();
}

class UPButtonState extends State<UPButton> {
  /// Source host helper.
  dynamic resolveNvueColor([dynamic c]) => c;

  bool _active = false;
  DateTime? _lastClickAt;
  bool? _localLoading;
  bool contacted = false;
  dynamic lastContact;
  bool chooseAvatarCalled = false;
  dynamic lastChooseAvatar;

  bool get isActive => _active;
  bool get isLoading => _localLoading ?? widget.loading;
  bool get isDisabled => widget.disabled || isLoading;

  bool _isJsTruthy(dynamic value) {
    if (value == null || value == false || value == '') return false;
    if (value is num && (value == 0 || value.isNaN)) return false;
    return true;
  }

  String get _text => widget.text == null ? '' : '${widget.text}';

  String get _loadingText =>
      _isJsTruthy(widget.loadingText) ? '${widget.loadingText}' : _text;

  void setLoading(bool value) {
    if ((_localLoading ?? widget.loading) == value) return;
    setState(() => _localLoading = value);
  }

  /// Programmatic click (respects disabled/loading/throttle).
  void click() => _handleTap();

  /// Source `clickHandler` alias.
  void clickHandler([dynamic _]) => click();

  /// Platform openType shells (no-op on Flutter; retained for API parity).
  void getphonenumber([dynamic e]) => widget.onGetphonenumber?.call(e);
  void getuserinfo([dynamic e]) => widget.onGetuserinfo?.call(e);
  void getPhoneNumber([dynamic _]) => getphonenumber(_);
  void getUserInfo([dynamic _]) => getuserinfo(_);

  /// Source open-type launchApp helper.
  /// Source theme var helper (Batch J).
  Map upThemeVar([dynamic _]) => const {};

  /// Source `iconColorCom` helper (Batch K).
  dynamic iconColorCom([dynamic _]) => widget.color;

  void launchapp([dynamic e]) {
    widget.onLaunchapp?.call(e);
    launchAppError(e);
  }

  void launchAppError([dynamic e]) => widget.onError?.call(e);
  void opensetting([dynamic e]) => widget.onOpensetting?.call(e);
  void openSetting([dynamic _]) => opensetting(_);
  void contact([dynamic payload]) {
    contacted = true;
    lastContact = payload;
  }

  void chooseavatar([dynamic payload]) {
    chooseAvatarCalled = true;
    lastChooseAvatar = payload;
  }

  void chooseAvatar([dynamic _]) => chooseavatar(_);
  void agreeprivacyauthorization([dynamic e]) =>
      widget.onAgreeprivacyauthorization?.call(e);
  void agreePrivacyAuthorization([dynamic _]) => agreeprivacyauthorization(_);

  double get _textSize {
    switch (widget.size) {
      case 'large':
        return 16;
      case 'small':
        return 12;
      case 'mini':
        return 10;
      case 'normal':
      default:
        return 14;
    }
  }

  double get _height {
    switch (widget.size) {
      case 'large':
        return 50;
      case 'small':
        return 30;
      case 'mini':
        return 22;
      case 'normal':
      default:
        return 40;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case 'large':
        return const EdgeInsets.symmetric(horizontal: 15);
      case 'small':
      case 'mini':
        return const EdgeInsets.symmetric(horizontal: 8);
      case 'normal':
      default:
        return const EdgeInsets.symmetric(horizontal: 12);
    }
  }

  double? get _minWidth {
    switch (widget.size) {
      case 'small':
        return 60;
      case 'mini':
        return 50;
      default:
        return null;
    }
  }

  bool get _isBlock => widget.size == 'large';

  @override
  void didUpdateWidget(covariant UPButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loading != widget.loading) {
      _localLoading = null;
    }
  }

  void _handleTap() {
    if (widget.disabled || isLoading) return;
    final throttle = widget.throttleTime.toInt();
    if (throttle > 0) {
      final now = DateTime.now();
      if (_lastClickAt != null &&
          now.difference(_lastClickAt!).inMilliseconds < throttle) {
        return;
      }
      _lastClickAt = now;
    }
    widget.onClick?.call();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final metrics = _resolveColors(tokens);
    final radius = widget.shape == 'circle' ? 100.0 : 3.0;
    final borderWidth = widget.hairline ? 0.5 : 1.0;

    final textColor = metrics.foreground;
    final bg = metrics.background;
    final borderColor = metrics.border;

    Widget content;
    if (isLoading) {
      final loadingText = _loadingText;
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          UPLoadingIcon(
            mode: widget.loadingMode,
            size: widget.loadingSize.toDouble() * 1.15,
            color: metrics.loadingColor,
          ),
          const SizedBox(width: 4),
          Text(
            loadingText,
            style: TextStyle(
              color: textColor,
              fontSize: _textSize,
              height: 1.0,
            ),
          ),
        ],
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon.isNotEmpty) ...[
            UPIcon(
              name: widget.icon,
              color: metrics.iconColor,
              size: _textSize * 1.35,
            ),
            const SizedBox(width: 2),
          ],
          if (widget.child != null)
            widget.child!
          else
            Text(
              _text,
              style: TextStyle(
                color: textColor,
                fontSize: _textSize,
                height: 1.0,
              ),
            ),
        ],
      );
    }

    final baseDecoration = BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(radius),
      border: metrics.showBorder
          ? Border.all(color: borderColor, width: borderWidth)
          : null,
    );
    final customDecoration = widget.customStyle;
    final decoration = customDecoration == null
        ? baseDecoration
        : baseDecoration.copyWith(
            color: customDecoration.gradient == null
                ? customDecoration.color ?? baseDecoration.color
                : null,
            image: customDecoration.image ?? baseDecoration.image,
            border: customDecoration.border ?? baseDecoration.border,
            borderRadius:
                customDecoration.borderRadius ?? baseDecoration.borderRadius,
            boxShadow: customDecoration.boxShadow ?? baseDecoration.boxShadow,
            gradient: customDecoration.gradient ?? baseDecoration.gradient,
            backgroundBlendMode: customDecoration.backgroundBlendMode ??
                baseDecoration.backgroundBlendMode,
          );

    final button = AnimatedOpacity(
      duration: Duration(milliseconds: widget.hoverStayTime.toInt()),
      opacity: widget.disabled ? 0.5 : (_active ? 0.75 : 1.0),
      child: Container(
        width: _isBlock ? double.infinity : null,
        height: _height,
        constraints: BoxConstraints(
          minWidth: _minWidth ?? 0,
        ),
        padding: _padding,
        alignment: Alignment.center,
        decoration: decoration,
        child: content,
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        if (widget.disabled || isLoading) return;
        setState(() => _active = true);
      },
      onTapCancel: () => setState(() => _active = false),
      onTapUp: (_) {
        setState(() => _active = false);
        _handleTap();
      },
      child: button,
    );
  }

  _ButtonColors _resolveColors(UPThemeTokens tokens) {
    final custom = widget.color.trim();
    if (custom.isNotEmpty) {
      if (custom.contains('gradient')) {
        // Keep API; Flutter gradient parsing is limited in P0.
        // Fall back to primary solid if unparsed.
        final fallback = tokens.primary;
        return _ButtonColors(
          foreground: widget.plain ? fallback : Colors.white,
          background: widget.plain ? tokens.cardBgColor : fallback,
          border: fallback,
          iconColor: widget.iconColor.isNotEmpty
              ? (UPUtils.parseColor(widget.iconColor) ?? fallback)
              : (widget.plain ? fallback : Colors.white),
          loadingColor: widget.plain ? fallback : const Color(0xFFC8C8C8),
          showBorder: !custom.contains('gradient') || widget.plain,
        );
      }
      final c = UPUtils.parseColor(custom) ?? tokens.primary;
      return _ButtonColors(
        foreground: widget.plain ? c : Colors.white,
        background: widget.plain ? tokens.cardBgColor : c,
        border: c,
        iconColor: widget.iconColor.isNotEmpty
            ? (UPUtils.parseColor(widget.iconColor) ?? c)
            : (widget.plain ? c : Colors.white),
        loadingColor: widget.plain ? c : const Color(0xFFC8C8C8),
        showBorder: true,
      );
    }

    final typeColor = tokens.typeColor(widget.type);
    if (widget.plain) {
      final fg = widget.type == 'info' ? tokens.mainColor : typeColor;
      final border = widget.type == 'info' ? tokens.borderColor : typeColor;
      return _ButtonColors(
        foreground: fg,
        background: tokens.cardBgColor,
        border: border,
        iconColor: widget.iconColor.isNotEmpty
            ? (UPUtils.parseColor(widget.iconColor) ?? fg)
            : fg,
        loadingColor: typeColor,
        showBorder: true,
      );
    }

    if (widget.type == 'info') {
      return _ButtonColors(
        foreground: tokens.mainColor,
        background: tokens.cardBgColor,
        border: tokens.borderColor,
        iconColor: widget.iconColor.isNotEmpty
            ? (UPUtils.parseColor(widget.iconColor) ?? tokens.mainColor)
            : tokens.mainColor,
        loadingColor: const Color(0xFFC9C9C9),
        showBorder: true,
      );
    }

    return _ButtonColors(
      foreground: Colors.white,
      background: typeColor,
      border: typeColor,
      iconColor: widget.iconColor.isNotEmpty
          ? (UPUtils.parseColor(widget.iconColor) ?? Colors.white)
          : Colors.white,
      loadingColor: const Color(0xFFC8C8C8),
      showBorder: true,
    );
  }
}

class _ButtonColors {
  const _ButtonColors({
    required this.foreground,
    required this.background,
    required this.border,
    required this.iconColor,
    required this.loadingColor,
    required this.showBorder,
  });

  final Color foreground;
  final Color background;
  final Color border;
  final Color iconColor;
  final Color loadingColor;
  final bool showBorder;
}
