import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';

/// 1:1 port of u-badge.
class UPBadge extends StatelessWidget {
  const UPBadge({
    super.key,
    this.isDot = false,
    this.value = '',
    this.modelValue,
    this.show = true,
    this.max = 999,
    this.type = 'error',
    this.showZero = false,
    this.bgColor,
    this.color,
    this.shape = 'circle',
    this.numberType = 'overflow',
    this.offset = const [],
    this.inverted = false,
    this.absolute = false,
    this.customStyle,
    this.child,
  });

  final bool isDot;
  final dynamic value;
  final dynamic modelValue;
  final bool show;
  final num max;
  final String type;
  final bool showZero;
  final dynamic bgColor;
  final dynamic color;
  final String shape;
  final String numberType;
  final List offset;
  final bool inverted;
  final bool absolute;
  final BoxDecoration? customStyle;
  final Widget? child;

  dynamic _showValue() {
    if (isDot) return '';
    final raw = value;
    final n = raw is num ? raw : num.tryParse('$raw');
    switch (numberType) {
      case 'ellipsis':
        if (n != null && n > max) return '...';
        return raw;
      case 'limit':
        if (n == null) return raw;
        if (n > 999) {
          if (n >= 9999) {
            final v = (n / 10000 * 100).floor() / 100;
            return '${_trimNum(v)}w';
          }
          final v = (n / 1000 * 100).floor() / 100;
          return '${_trimNum(v)}k';
        }
        return raw;
      case 'overflow':
      default:
        if (n != null && n > max) return '$max+';
        return raw;
    }
  }

  String _trimNum(num v) {
    if (v == v.roundToDouble()) return '${v.toInt()}';
    return '$v';
  }

  bool get _shouldShow {
    if (!show) return false;
    if (isDot) return true;
    final raw = value;
    final n = raw is num ? raw : num.tryParse('$raw');
    if (n != null && n == 0) return showZero;
    if ('$raw' == '0') return showZero;
    if ('$raw'.isEmpty) return false;
    return true;
  }

  /// Source computed box style (host positioning).
  dynamic get boxStyle {
    final style = <String, dynamic>{};
    if (absolute) {
      style['position'] = 'absolute';
      if (offset.isNotEmpty) {
        final top = offset[0];
        final right = offset.length > 1 ? offset[1] : top;
        style['top'] = UPUtils.addUnit(top);
        style['right'] = UPUtils.addUnit(right);
      }
    }
    return style;
  }

  /// Source computed badge style map.
  dynamic get badgeStyle {
    final style = <String, dynamic>{};
    if (color != null && '$color'.trim().isNotEmpty) {
      style['color'] = color;
    }
    if (bgColor != null && '$bgColor'.trim().isNotEmpty && !inverted) {
      style['backgroundColor'] = bgColor;
    }
    if (absolute) {
      style['position'] = 'absolute';
      if (offset.isNotEmpty) {
        final top = offset[0];
        final right = offset.length > 1 ? offset[1] : top;
        style['top'] = UPUtils.addUnit(top);
        style['right'] = UPUtils.addUnit(right);
      }
    }
    return style;
  }

  /// Source computed display value with numberType rules.
  dynamic get showValue => _showValue();

  @override
  Widget build(BuildContext context) {
    if (!_shouldShow) return child ?? const SizedBox.shrink();
    final tokens = UPThemeTokens.of(context);
    final typeColor = tokens.typeColor(type);
    final bg = inverted
        ? Colors.transparent
        : (UPUtils.parseColor(bgColor) ?? typeColor);
    final fg =
        UPUtils.parseColor(color) ?? (inverted ? typeColor : Colors.white);
    final text = '${_showValue()}';

    final baseDecoration = isDot
        ? BoxDecoration(
            color: inverted ? typeColor : bg,
            shape: BoxShape.circle,
          )
        : BoxDecoration(
            color: bg,
            borderRadius: shape == 'horn'
                ? const BorderRadius.only(
                    topLeft: Radius.circular(100),
                    topRight: Radius.circular(100),
                    bottomRight: Radius.circular(100),
                    bottomLeft: Radius.circular(0),
                  )
                : BorderRadius.circular(100),
          );
    // Vue applies [addStyle(customStyle), badgeStyle]. customStyle.color
    // overrides class defaults, while an explicit bgColor in badgeStyle is
    // later and overrides that caller color.
    final hasExplicitBgColor =
        bgColor != null && '$bgColor'.trim().isNotEmpty && !inverted;
    final resolvedColor =
        hasExplicitBgColor ? bg : customStyle?.color ?? baseDecoration.color;
    final decoration = BoxDecoration(
      color: customStyle?.gradient == null ? resolvedColor : null,
      borderRadius: customStyle?.borderRadius ?? baseDecoration.borderRadius,
      border: customStyle?.border ?? baseDecoration.border,
      boxShadow: customStyle?.boxShadow ?? baseDecoration.boxShadow,
      gradient: customStyle?.gradient ?? baseDecoration.gradient,
      image: customStyle?.image ?? baseDecoration.image,
      backgroundBlendMode: customStyle?.backgroundBlendMode ??
          baseDecoration.backgroundBlendMode,
      shape: baseDecoration.shape,
    );

    final badge = isDot
        ? Container(
            width: 8,
            height: 8,
            decoration: decoration,
          )
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: decoration,
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                color: fg,
                fontSize: inverted ? 13 : 11,
                height: 1.0,
              ),
            ),
          );

    if (child == null) {
      if (absolute && offset.isNotEmpty) {
        final top = UPUtils.getPx(offset[0]);
        final right = offset.length > 1 ? UPUtils.getPx(offset[1]) : top;
        return Align(
          alignment: Alignment.topRight,
          child: Transform.translate(
            offset: Offset(-right, top),
            child: badge,
          ),
        );
      }
      return badge;
    }

    final top = offset.isNotEmpty ? UPUtils.getPx(offset[0]) : 0.0;
    final right = offset.length > 1
        ? UPUtils.getPx(offset[1])
        : (offset.isNotEmpty ? top : 0.0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child!,
        if (absolute)
          Positioned(top: top, right: right, child: badge)
        else
          Positioned(
            top: 0,
            right: 0,
            child: Transform.translate(
              offset: Offset(
                offset.isEmpty ? 4 : -right,
                offset.isEmpty ? -4 : top,
              ),
              child: badge,
            ),
          ),
      ],
    );
  }
}
