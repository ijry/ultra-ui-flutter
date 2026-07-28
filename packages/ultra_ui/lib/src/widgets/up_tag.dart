import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';
import 'up_transition.dart';

/// 1:1 port of u-tag.
class UPTag extends StatelessWidget {
  const UPTag({
    super.key,
    this.type = 'primary',
    this.disabled = false,
    this.size = 'medium',
    this.shape = 'square',
    this.text = '',
    this.bgColor = '',
    this.color = '',
    this.borderColor = '',
    this.closeColor = '#C6C7CB',
    this.name = '',
    this.plainFill = false,
    this.plain = false,
    this.closable = false,
    this.show = true,
    this.icon = '',
    this.iconColor = '',
    this.textSize = '',
    this.height = '',
    this.padding = '',
    this.borderRadius = '',
    this.autoBgColor = 0,
    this.customStyle,
    this.iconWidget,
    this.contentWidget,
    this.child,
    this.onClick,
    this.onClose,
  });

  final String type;
  final dynamic disabled;
  final String size;
  final String shape;
  final dynamic text;
  final String bgColor;
  final String color;
  final String borderColor;
  final String closeColor;
  final dynamic name;
  final bool plainFill;
  final bool plain;
  final bool closable;
  final bool show;
  final String icon;
  final String iconColor;
  final dynamic textSize;
  final dynamic height;
  final dynamic padding;
  final dynamic borderRadius;
  final num autoBgColor;
  final BoxDecoration? customStyle;
  final Widget? iconWidget;
  final Widget? contentWidget;
  final Widget? child;

  /// Accepts `void Function()` or `void Function(dynamic name)`.
  final dynamic onClick;

  /// Accepts `void Function()` or `void Function(dynamic name)`.
  final dynamic onClose;

  double get _height {
    if (height != '' && height != null) return UPUtils.getPx(height);
    switch (size) {
      case 'mini':
        return 22;
      case 'large':
        return 32;
      default:
        return 26;
    }
  }

  double get _fontSize {
    if (textSize != '' && textSize != null) return UPUtils.getPx(textSize);
    switch (size) {
      case 'mini':
        return 12;
      case 'large':
        return 15;
      default:
        return 13;
    }
  }

  double get _iconSize {
    switch (size) {
      case 'mini':
        return 16;
      case 'large':
        return 21;
      default:
        return 19;
    }
  }

  double get _closeSize {
    switch (size) {
      case 'mini':
        return 18;
      case 'large':
        return 25;
      default:
        return 22;
    }
  }

  double get _closeIconSize {
    switch (size) {
      case 'mini':
        return 12;
      case 'large':
        return 15;
      default:
        return 13;
    }
  }

  EdgeInsets get _padding {
    if (padding != '' && padding != null) {
      final p = '$padding'.trim();
      final parts = p.split(RegExp(r'\s+'));
      if (parts.length == 1) {
        final v = UPUtils.getPx(parts[0]);
        return EdgeInsets.all(v);
      }
      if (parts.length == 2) {
        return EdgeInsets.symmetric(
          vertical: UPUtils.getPx(parts[0]),
          horizontal: UPUtils.getPx(parts[1]),
        );
      }
      if (parts.length >= 4) {
        return EdgeInsets.only(
          top: UPUtils.getPx(parts[0]),
          right: UPUtils.getPx(parts[1]),
          bottom: UPUtils.getPx(parts[2]),
          left: UPUtils.getPx(parts[3]),
        );
      }
    }
    switch (size) {
      case 'mini':
        return const EdgeInsets.symmetric(horizontal: 5);
      case 'large':
        return const EdgeInsets.symmetric(horizontal: 15);
      default:
        return const EdgeInsets.symmetric(horizontal: 10);
    }
  }

  Color _typeLight(UPThemeTokens tokens) {
    switch (type) {
      case 'success':
        return tokens.successLight;
      case 'warning':
        return tokens.warningLight;
      case 'error':
        return tokens.errorLight;
      case 'info':
        return tokens.infoLight;
      default:
        return tokens.primaryLight;
    }
  }

  void _emitClick() {
    final cb = onClick;
    if (cb is void Function(dynamic)) {
      cb(name);
    } else if (cb is void Function()) {
      cb();
    } else if (cb != null) {
      Function.apply(cb, [name]);
    }
  }

  void _emitClose() {
    final cb = onClose;
    if (cb is void Function(dynamic)) {
      cb(name);
    } else if (cb is void Function()) {
      cb();
    } else if (cb != null) {
      Function.apply(cb, [name]);
    }
  }

  /// Source `clickHandler`.
  void clickHandler() {
    _emitClick();
  }

  /// Source `closeHandler`.
  void closeHandler() {
    _emitClose();
  }

  /// Source `getBgColor` helper.
  Color getBgColor([UPThemeTokens? tokens, dynamic darkColor]) {
    // Approximate source lighten for plain fill / auto bg.
    final seed = darkColor ?? color;
    if (seed != null && '$seed'.trim().isNotEmpty) {
      final light =
          UPUtils.genLightColor(seed, autoBgColor > 0 ? autoBgColor : 1);
      if (light != null) return light;
    }
    return const Color(0xFFE8F3FF);
  }

  /// Source host helper: testImage (from uview-plus test.image).
  dynamic testImage([dynamic v]) => null;

  /// Source computed style map.
  dynamic get style {
    final style = <String, dynamic>{};
    if (bgColor.isNotEmpty) {
      style['backgroundColor'] = bgColor;
    }
    if (color.isNotEmpty) {
      style['color'] = color;
    }
    if (borderColor.isNotEmpty) {
      style['borderColor'] = borderColor;
    }
    if (height != null && '$height'.trim().isNotEmpty) {
      final h = UPUtils.addUnit(height);
      style['height'] = h;
      style['lineHeight'] = h;
    }
    if (padding != null && '$padding'.trim().isNotEmpty) {
      style['padding'] = padding;
    }
    if (borderRadius != null && '$borderRadius'.trim().isNotEmpty) {
      style['borderRadius'] = UPUtils.addUnit(borderRadius);
    }
    if (autoBgColor > 0 && color.isNotEmpty) {
      final light = UPUtils.genLightColor(color, autoBgColor);
      if (light != null) {
        final hex =
            light.toARGB32().toRadixString(16).padLeft(8, '0').substring(2);
        style['backgroundColor'] = '#$hex';
      }
    }
    return style;
  }

  /// Source computed text color style map.
  dynamic get textColor {
    final style = <String, dynamic>{};
    if (color.isNotEmpty) {
      style['color'] = color;
    }
    if (textSize != null && '$textSize'.trim().isNotEmpty) {
      style['textSize'] = UPUtils.addUnit(textSize);
    }
    return style;
  }

  /// Source computed image style by tag size.
  dynamic get imgStyle {
    final width = size == 'large'
        ? '17px'
        : size == 'medium'
            ? '15px'
            : '13px';
    return <String, dynamic>{'width': width, 'height': width};
  }

  /// Source computed icon color.
  dynamic get elIconColor {
    if (iconColor.isNotEmpty) return iconColor;
    return plain ? type : '#ffffff';
  }

  /// Source computed close color.
  dynamic get resolvedCloseColor {
    if (closeColor != '#C6C7CB') return closeColor;
    return closeColor;
  }

  /// Source computed close icon size.
  dynamic get closeSize => _closeIconSize;

  /// Source computed leading icon size.
  dynamic get iconSize => _iconSize;

  /// Compatibility alias for earlier misspelling.
  Color getBagColor([UPThemeTokens? tokens, dynamic darkColor]) =>
      getBgColor(tokens, darkColor);

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final typeColor = tokens.typeColor(type);
    final light = _typeLight(tokens);
    final radius = borderRadius != '' && borderRadius != null
        ? UPUtils.getPx(borderRadius)
        : (shape == 'circle' ? 100.0 : 3.0);

    Color fg = plain || plainFill ? typeColor : Colors.white;
    Color bg = plain ? Colors.transparent : (plainFill ? light : typeColor);
    Color bd = typeColor;

    if (bgColor.isNotEmpty) {
      bg = UPUtils.parseColor(bgColor) ?? bg;
    }
    if (color.isNotEmpty) {
      fg = UPUtils.parseColor(color) ?? fg;
    }
    if (borderColor.isNotEmpty) {
      bd = UPUtils.parseColor(borderColor) ?? bd;
    }
    if (autoBgColor > 0 && color.isNotEmpty) {
      bg = UPUtils.genLightColor(color, autoBgColor) ?? bg;
    }
    final iconColorResolved = iconColor.isNotEmpty
        ? (UPUtils.parseColor(iconColor) ?? fg)
        : (plain ? typeColor : Colors.white);

    final closeBg = closeColor.isNotEmpty && closeColor != '#C6C7CB'
        ? (UPUtils.parseColor(closeColor) ?? tokens.disabledColor)
        : tokens.disabledColor;

    final tagBody = Container(
      height: _height,
      padding: _padding,
      margin: EdgeInsets.only(
        right: closable ? 10 : 0,
        top: closable ? 10 : 0,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: bd, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconWidget != null) ...[
            iconWidget!,
            const SizedBox(width: 4),
          ] else if (icon.isNotEmpty) ...[
            if (UPUtils.isImage(icon))
              Image.network(
                icon,
                width: _iconSize,
                height: _iconSize,
                errorBuilder: (_, __, ___) => UPIcon(
                  name: 'photo',
                  size: _iconSize,
                  color: iconColorResolved,
                ),
              )
            else
              UPIcon(
                name: icon,
                size: _iconSize,
                color: iconColorResolved,
              ),
            const SizedBox(width: 4),
          ],
          if (contentWidget != null)
            contentWidget!
          else
            DefaultTextStyle(
              style: TextStyle(
                color: fg,
                fontSize: _fontSize,
                height: 1.0,
              ),
              child: child ??
                  Text(
                    '$text',
                    style: TextStyle(
                      color: fg,
                      fontSize: _fontSize,
                      height: 1.0,
                    ),
                  ),
            ),
        ],
      ),
    );

    final content = GestureDetector(
      onTap: clickHandler,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          tagBody,
          if (closable)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: closeHandler,
                behavior: HitTestBehavior.opaque,
                child: Transform.translate(
                  offset: const Offset(4, -4),
                  child: Transform.scale(
                    scale: 0.6,
                    child: Container(
                      width: _closeSize,
                      height: _closeSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: closeBg,
                        shape: BoxShape.circle,
                      ),
                      child: UPIcon(
                        name: 'close',
                        size: _closeIconSize,
                        color: '#ffffff',
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return UPTransition(
      show: show,
      mode: 'fade',
      child: content,
    );
  }
}
