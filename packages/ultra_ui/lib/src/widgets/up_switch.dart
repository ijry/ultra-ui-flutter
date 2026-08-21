import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_loading_icon.dart';

/// 1:1 port of u-switch size metrics and events.
class UPSwitch extends StatefulWidget {
  const UPSwitch({
    super.key,
    this.loading = false,
    this.disabled = false,
    this.size = 25,
    this.activeColor = '#2979ff',
    this.inactiveColor = '#ffffff',
    this.dotActiveColor = '#ffffff',
    this.dotInactiveColor = '#ffffff',
    this.value = false,
    this.activeValue = true,
    this.inactiveValue = false,
    this.asyncChange = false,
    this.space = 0,
    this.customStyle,
    this.onChange,
    this.onInput,
    this.onUpdateValue,
    this.onUpdateModelValue,
  });

  final bool loading;
  final bool disabled;
  final dynamic size;
  final dynamic activeColor;
  final dynamic inactiveColor;
  final dynamic dotActiveColor;
  final dynamic dotInactiveColor;
  final dynamic value;
  final dynamic activeValue;
  final dynamic inactiveValue;
  final bool asyncChange;
  final dynamic space;
  final BoxDecoration? customStyle;
  final ValueChanged<dynamic>? onChange;

  /// Source emit alias: input.
  final ValueChanged<dynamic>? onInput;

  /// Source `update:modelValue` / v-model alias. Not emitted when [asyncChange].
  final ValueChanged<dynamic>? onUpdateValue;
  final ValueChanged<dynamic>? onUpdateModelValue;

  @override
  State<UPSwitch> createState() => UPSwitchState();
}

class UPSwitchState extends State<UPSwitch> {
  dynamic _local;

  dynamic get value => _local ?? widget.value;
  bool get isActive => value == widget.activeValue || value == true;

  @override
  void didUpdateWidget(covariant UPSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _local = null;
    }
  }

  void setValue(dynamic next, {bool emit = true}) {
    setState(() => _local = next);
    if (emit) {
      if (!widget.asyncChange) {
        widget.onUpdateValue?.call(next);
        widget.onUpdateModelValue?.call(next);
      }
      widget.onChange?.call(next);
      widget.onInput?.call(next);
    }
  }

  /// Source style helpers.
  Map switchStyle([dynamic _]) {
    final s = UPUtils.getPx(widget.size);
    return {
      'width': s * 2 + 2,
      'height': s + 2,
      'active': isActive,
    };
  }

  Map nodeStyle([dynamic _]) {
    final s = UPUtils.getPx(widget.size);
    final spacePx = UPUtils.getPx(widget.space);
    return {
      'size': (s - spacePx).clamp(1.0, s),
      'active': isActive,
    };
  }

  Map bgStyle([dynamic _]) => {
        'activeColor': widget.activeColor,
        'inactiveColor': widget.inactiveColor,
        'active': isActive,
      };

  dynamic customInactiveColor([dynamic _]) => widget.inactiveColor;
  dynamic resolvedActiveColor([dynamic _]) => widget.activeColor;
  dynamic resolvedInactiveColor([dynamic _]) => widget.inactiveColor;
  dynamic resolvedDotActiveColor([dynamic _]) => widget.dotActiveColor;
  dynamic resolvedDotInactiveColor([dynamic _]) => widget.dotInactiveColor;
  dynamic resolvedLoadingInactiveColor([dynamic _]) => widget.inactiveColor;

  /// Source `clickHandler`.
  /// Source `clickHandler`.
  void clickHandler() {
    if (widget.disabled || widget.loading) return;
    final next = isActive ? widget.inactiveValue : widget.activeValue;
    if (!widget.asyncChange) {
      setState(() => _local = next);
      widget.onUpdateValue?.call(next);
      widget.onUpdateModelValue?.call(next);
    }
    widget.onChange?.call(next);
    widget.onInput?.call(next);
  }

  void toggle() => clickHandler();

  @override
  Widget build(BuildContext context) {
    final s = UPUtils.getPx(widget.size);
    // Source: width = size * 2 + 2, height = size + 2
    final width = s * 2 + 2;
    final height = s + 2;
    final spacePx = UPUtils.getPx(widget.space);
    final nodeSize = (s - spacePx).clamp(1.0, s);
    final tokens = UPThemeTokens.of(context);
    final active =
        UPUtils.parseColor(widget.activeColor) ?? const Color(0xFF2979FF);
    final inactiveText = '${widget.inactiveColor}'.trim().toLowerCase();
    final hasCustomInactive = inactiveText.isNotEmpty &&
        inactiveText != '#ffffff' &&
        inactiveText != '#fff';
    // Source only honors the prop when it differs from the default; otherwise
    // --up-switch-inactive-color applies, which has its own dark value.
    final inactive = hasCustomInactive
        ? (UPUtils.parseColor(widget.inactiveColor) ??
            tokens.switchInactiveColor)
        : tokens.switchInactiveColor;
    // Source default border: rgba(0, 0, 0, 0.12) in light, #4b5563 in dark.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = hasCustomInactive
        ? const Color(0x00000000)
        : (isDark ? const Color(0xFF4B5563) : const Color(0x1F000000));
    final pad = spacePx > 0 ? spacePx / 2 : 1.0;
    final checked = isActive;

    Widget node = Container(
      width: nodeSize,
      height: nodeSize,
      decoration: BoxDecoration(
        color: checked
            ? (UPUtils.parseColor(widget.dotActiveColor) ?? Colors.white)
            : (UPUtils.parseColor(widget.dotInactiveColor) ?? Colors.white),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 1,
            offset: Offset(1, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: widget.loading
          ? UPLoadingIcon(
              mode: 'circle',
              size: s * 0.6,
              color: checked ? active : const Color(0xFFAAABAD),
            )
          : null,
    );

    final sourceDecoration = BoxDecoration(
      color: checked ? active : inactive,
      borderRadius: BorderRadius.circular(100),
      border: Border.all(
        color: checked ? Colors.transparent : borderColor,
        width: 1,
      ),
    );
    final callerDecoration = widget.customStyle;
    final decoration = callerDecoration == null
        ? sourceDecoration
        : BoxDecoration(
            // Vue applies addStyle(customStyle) after switchStyle, so caller
            // fields override source-computed root fields.
            color: callerDecoration.gradient == null
                ? callerDecoration.color ?? sourceDecoration.color
                : null,
            image: callerDecoration.image ?? sourceDecoration.image,
            border: callerDecoration.border ?? sourceDecoration.border,
            borderRadius: callerDecoration.shape == BoxShape.circle
                ? null
                : callerDecoration.borderRadius ??
                    sourceDecoration.borderRadius,
            boxShadow: callerDecoration.boxShadow ?? sourceDecoration.boxShadow,
            gradient: callerDecoration.gradient ?? sourceDecoration.gradient,
            backgroundBlendMode: callerDecoration.backgroundBlendMode ??
                sourceDecoration.backgroundBlendMode,
            shape: callerDecoration.shape,
          );

    final switchBody = AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: const Cubic(0.3, 1.05, 0.4, 1.05),
      width: width,
      height: height,
      padding: EdgeInsets.all(pad),
      decoration: decoration,
      clipBehavior: Clip.hardEdge,
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 400),
        curve: const Cubic(0.3, 1.05, 0.4, 1.05),
        alignment: checked ? Alignment.centerRight : Alignment.centerLeft,
        child: node,
      ),
    );

    return Opacity(
      opacity: widget.disabled ? 0.6 : 1,
      child: GestureDetector(
        onTap: widget.disabled || widget.loading ? null : clickHandler,
        child: switchBody,
      ),
    );
  }
}
