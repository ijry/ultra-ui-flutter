import 'package:flutter/widgets.dart';

import '../icons/icon_code_points.dart';
import '../theme/up_theme.dart';
import '../utils/up_utils.dart';

/// 1:1 port of u-icon defaults and behavior.
class UPIcon extends StatelessWidget {
  const UPIcon({
    super.key,
    this.name = '',
    this.color,
    this.size = '16px',
    this.bold = false,
    this.index,
    this.customPrefix = 'uicon',
    this.label = '',
    this.labelPos = 'right',
    this.labelSize = '15px',
    this.labelColor,
    this.space = '3px',
    this.width = '',
    this.height = '',
    this.top = 0,
    this.stop = false,
    this.hoverClass = '',
    this.imgMode = '',
    this.onClick,
    this.customStyle,
  });

  final String name;
  final dynamic color;
  final dynamic size;
  final bool bold;
  final dynamic index;
  final String customPrefix;
  final dynamic label;
  final String labelPos;
  final dynamic labelSize;
  final dynamic labelColor;
  final dynamic space;
  final dynamic width;
  final dynamic height;
  final dynamic top;
  final bool stop;
  final String hoverClass;
  final String imgMode;
  final void Function(dynamic index)? onClick;

  final BoxDecoration? customStyle;
  bool get _isImg => name.contains('/');

  /// Source `clickHandler`.
  void clickHandler([dynamic idx]) => onClick?.call(idx ?? index);

  /// Source image detection helper.
  bool isImg() => _isImg;

  /// Source computed: uClasses.
  dynamic get uClasses {
    final classes = <String>[
      '$customPrefix-$name',
    ];
    if (customPrefix == 'uicon') {
      classes.add('u-iconfont');
    } else {
      classes.add(customPrefix);
    }
    const themeTypes = {'primary', 'success', 'info', 'error', 'warning'};
    if (color != null && themeTypes.contains('$color')) {
      classes.add('u-icon__icon--$color');
    }
    return classes.join(' ');
  }

  /// Source computed: iconStyle.
  dynamic get iconStyle {
    final style = <String, dynamic>{
      'fontSize': UPUtils.addUnit(size),
      'lineHeight': UPUtils.addUnit(size),
      'fontWeight': bold ? 'bold' : 'normal',
      'top': UPUtils.addUnit(top),
    };
    if (customPrefix != 'uicon') {
      style['fontFamily'] = customPrefix;
    }
    const themeTypes = {'primary', 'success', 'info', 'error', 'warning'};
    if (color != null &&
        '$color'.trim().isNotEmpty &&
        !themeTypes.contains('$color')) {
      style['color'] = color;
    }
    return style;
  }

  /// Source computed: imgStyle.
  dynamic get imgStyle {
    final w = (width != null && '$width'.trim().isNotEmpty && width != '')
        ? width
        : size;
    final h = (height != null && '$height'.trim().isNotEmpty && height != '')
        ? height
        : size;
    return <String, dynamic>{
      'width': UPUtils.addUnit(w),
      'height': UPUtils.addUnit(h),
    };
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final resolvedSize = UPUtils.getPx(size);
    final gap = UPUtils.getPx(space);
    final labelText = '$label';
    final iconColor = _resolveColor(context, color) ?? tokens.contentColor;
    final resolvedLabelColor =
        _resolveColor(context, labelColor) ?? tokens.contentColor;

    Widget iconChild;
    if (_isImg) {
      final w =
          (width == '' || width == null) ? resolvedSize : UPUtils.getPx(width);
      final h = (height == '' || height == null)
          ? resolvedSize
          : UPUtils.getPx(height);
      final isNetwork =
          name.startsWith('http://') || name.startsWith('https://');
      iconChild = isNetwork
          ? Image.network(
              name,
              width: w,
              height: h,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => SizedBox(width: w, height: h),
            )
          : Image.asset(
              name,
              width: w,
              height: h,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => SizedBox(width: w, height: h),
            );
    } else {
      final codePoint = kUpIconCodePoints[name];
      iconChild = SizedBox(
        width: resolvedSize,
        height: resolvedSize,
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: Text(
              codePoint == null ? name : String.fromCharCode(codePoint),
              style: TextStyle(
                fontFamily: customPrefix == 'uicon' ? 'upicon' : customPrefix,
                package: customPrefix == 'uicon' ? 'ultra_ui' : null,
                fontSize: resolvedSize,
                height: 1.0,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: iconColor,
              ),
            ),
          ),
        ),
      );
    }
    if (customStyle != null) {
      iconChild = DecoratedBox(
        decoration: customStyle!,
        child: iconChild,
      );
    }

    final labelWidget = labelText.isEmpty
        ? null
        : Text(
            labelText,
            style: TextStyle(
              color: resolvedLabelColor,
              fontSize: UPUtils.getPx(labelSize),
              height: 1.0,
            ),
          );

    final children = <Widget>[iconChild];
    if (labelWidget != null) {
      switch (labelPos) {
        case 'left':
          children.insert(
            0,
            Padding(padding: EdgeInsets.only(right: gap), child: labelWidget),
          );
          break;
        case 'top':
          children.insert(
            0,
            Padding(padding: EdgeInsets.only(bottom: gap), child: labelWidget),
          );
          break;
        case 'bottom':
          children.add(
            Padding(padding: EdgeInsets.only(top: gap), child: labelWidget),
          );
          break;
        case 'right':
        default:
          children.add(
            Padding(padding: EdgeInsets.only(left: gap), child: labelWidget),
          );
      }
    }

    final isVertical = labelPos == 'top' || labelPos == 'bottom';
    final content = isVertical
        ? Column(mainAxisSize: MainAxisSize.min, children: children)
        : Row(mainAxisSize: MainAxisSize.min, children: children);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onClick == null ? null : () => onClick?.call(index),
      child: Transform.translate(
        offset: Offset(0, UPUtils.getPx(top)),
        child: content,
      ),
    );
  }

  Color? _resolveColor(BuildContext context, dynamic value) {
    if (value == null || value == '') return null;
    final text = '$value';
    final tokens = UPThemeTokens.of(context);
    switch (text) {
      case 'primary':
        return tokens.primary;
      case 'success':
        return tokens.success;
      case 'warning':
        return tokens.warning;
      case 'error':
        return tokens.error;
      case 'info':
        return tokens.info;
    }
    return UPUtils.parseColor(value);
  }
}
