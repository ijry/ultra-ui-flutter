import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';

class UPGap extends StatelessWidget {
  const UPGap({
    super.key,
    this.bgColor = 'transparent',
    this.height = 20,
    this.marginTop = 0,
    this.marginBottom = 0,
    this.customStyle,
  });

  final dynamic bgColor;
  final dynamic height;
  final dynamic marginTop;
  final dynamic marginBottom;
  final BoxDecoration? customStyle;

  /// Source computed: gapStyle.
  dynamic get gapStyle {
    final resolvedBg = (bgColor != null &&
            '$bgColor'.trim().isNotEmpty &&
            '$bgColor' != 'transparent')
        ? bgColor
        : 'transparent';
    return <String, dynamic>{
      'backgroundColor': resolvedBg,
      'height': UPUtils.addUnit(height),
      'marginTop': UPUtils.addUnit(marginTop),
      'marginBottom': UPUtils.addUnit(marginBottom),
    };
  }

  @override
  Widget build(BuildContext context) {
    final hasCustomBackground = bgColor != null &&
        '$bgColor'.trim().isNotEmpty &&
        '$bgColor' != 'transparent';
    // Source resolves --up-gap-bg-color first and only falls back to
    // dark ? #111111 : transparent when that variable is unset. Since the
    // variable *is* set in theme-vars-core.scss for both palettes, the token
    // is what actually applies.
    final defaultColor = UPThemeTokens.of(context).gapBgColor;
    final color = UPUtils.parseColor(
          hasCustomBackground ? bgColor : null,
          fallback: defaultColor,
        ) ??
        defaultColor;
    return Container(
      height: UPUtils.getPx(height),
      margin: EdgeInsets.only(
        top: UPUtils.getPx(marginTop),
        bottom: UPUtils.getPx(marginBottom),
      ),
      decoration: (customStyle ?? const BoxDecoration()).copyWith(
        color: customStyle?.color ?? color,
      ),
    );
  }
}

class UPLine extends StatelessWidget {
  const UPLine({
    super.key,
    this.color = '#d6d7d9',
    this.length = '100%',
    this.direction = 'row',
    this.hairline = true,
    this.margin = 0,
    this.dashed = false,
    this.customStyle,
  });

  final dynamic color;
  final dynamic length;
  final String direction;
  final bool hairline;
  final dynamic margin;
  final bool dashed;
  final BoxDecoration? customStyle;

  /// Source computed: lineStyle.
  dynamic get lineStyle {
    final style = <String, dynamic>{'margin': margin, 'borderColor': color};
    if (direction == 'row') {
      style['borderBottomWidth'] = '1px';
      style['borderBottomStyle'] = dashed ? 'dashed' : 'solid';
      style['width'] = UPUtils.addUnit(length);
      if (hairline) style['transform'] = 'scaleY(0.5)';
    } else {
      style['borderLeftWidth'] = '1px';
      style['borderLeftStyle'] = dashed ? 'dashed' : 'solid';
      style['height'] = UPUtils.addUnit(length);
      if (hairline) style['transform'] = 'scaleX(0.5)';
    }
    return style;
  }

  @override
  Widget build(BuildContext context) {
    final c = UPUtils.parseColor(color) ?? const Color(0xFFD6D7D9);
    final thickness = hairline ? 0.5 : 1.0;
    final isRow = direction == 'row';
    final percent = '$length'.endsWith('%');
    final fixed = percent ? null : UPUtils.getPx(length);

    Widget line;
    if (dashed) {
      line = CustomPaint(
        size: isRow
            ? Size(fixed ?? double.infinity, thickness)
            : Size(thickness, fixed ?? double.infinity),
        painter: _DashedLinePainter(
          color: c,
          thickness: thickness,
          isRow: isRow,
        ),
      );
    } else {
      line = Container(
        width: isRow ? fixed : thickness,
        height: isRow ? thickness : fixed,
        color: c,
      );
    }

    Widget root;
    if (percent && isRow) {
      root = SizedBox(width: double.infinity, child: line);
    } else if (percent && !isRow) {
      root = SizedBox(height: double.infinity, child: line);
    } else {
      root = line;
    }
    if (customStyle != null) {
      root = Container(decoration: customStyle, child: root);
    }
    return Padding(padding: _parseMargin(margin), child: root);
  }

  EdgeInsets _parseMargin(dynamic value) {
    if (value is num) return EdgeInsets.all(value.toDouble());
    final parts = '$value'
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map(UPUtils.getPx)
        .toList();
    if (parts.isEmpty) return EdgeInsets.zero;
    if (parts.length == 1) return EdgeInsets.all(parts[0]);
    if (parts.length == 2) {
      return EdgeInsets.symmetric(vertical: parts[0], horizontal: parts[1]);
    }
    if (parts.length == 3) {
      return EdgeInsets.fromLTRB(parts[1], parts[0], parts[1], parts[2]);
    }
    return EdgeInsets.fromLTRB(parts[3], parts[0], parts[1], parts[2]);
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({
    required this.color,
    required this.thickness,
    required this.isRow,
  });

  final Color color;
  final double thickness;
  final bool isRow;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;
    const dash = 4.0;
    const gap = 3.0;
    if (isRow) {
      var x = 0.0;
      final y = size.height / 2;
      while (x < size.width) {
        canvas.drawLine(
          Offset(x, y),
          Offset((x + dash).clamp(0, size.width), y),
          paint,
        );
        x += dash + gap;
      }
    } else {
      var y = 0.0;
      final x = size.width / 2;
      while (y < size.height) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x, (y + dash).clamp(0, size.height)),
          paint,
        );
        y += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      color != oldDelegate.color ||
      thickness != oldDelegate.thickness ||
      isRow != oldDelegate.isRow;
}

class UPDivider extends StatelessWidget {
  const UPDivider({
    super.key,
    this.dashed = false,
    this.hairline = true,
    this.dot = false,
    this.textPosition = 'center',
    this.text = '',
    this.textSize = 14,
    this.textColor = '#909399',
    this.lineColor = '#dcdfe6',
    this.onClick,
    this.customStyle,
    this.child,
  });

  final bool dashed;
  final bool hairline;
  final bool dot;
  final String textPosition;
  final dynamic text;
  final dynamic textSize;
  final dynamic textColor;
  final dynamic lineColor;
  final VoidCallback? onClick;
  final BoxDecoration? customStyle;
  final Widget? child;

  Widget _line({double? width, bool expand = false}) {
    final child = UPLine(
      color: lineColor,
      length: width == null ? '100%' : width,
      hairline: hairline,
      dashed: dashed,
    );
    if (expand) return Expanded(child: child);
    return SizedBox(width: width, child: child);
  }

  /// Source computed: leftLineStyle.
  dynamic get leftLineStyle {
    final style = <String, dynamic>{};
    if (textPosition == 'left') {
      style['width'] = '80rpx';
    } else {
      style['flex'] = 1;
    }
    return style;
  }

  /// Source computed: rightLineStyle.
  dynamic get rightLineStyle {
    final style = <String, dynamic>{};
    if (textPosition == 'right') {
      style['width'] = '80rpx';
    } else {
      style['flex'] = 1;
    }
    return style;
  }

  /// Source computed: textStyle.
  dynamic get textStyle => <String, dynamic>{
        'fontSize': UPUtils.addUnit(textSize),
        'color': textColor,
      };

  /// Source `click`.
  void click([dynamic v]) {
    onClick?.call();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final tc = UPUtils.parseColor(textColor) ?? tokens.tipsColor;
    final side = UPUtils.getPx('80rpx');

    final middle = <Widget>[];
    if (dot) {
      middle.add(const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          '●',
          style: TextStyle(color: Color(0xFFC0C4CC), fontSize: 12, height: 1),
        ),
      ));
    }
    if (child != null) {
      middle.add(child!);
    } else if (!dot && _isJsTruthy(text)) {
      middle.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Text(
          '$text',
          style: TextStyle(
            color: tc,
            fontSize: UPUtils.getPx(textSize),
            height: 1,
          ),
        ),
      ));
    }

    final List<Widget> children;
    if (textPosition == 'left') {
      children = [_line(width: side), ...middle, _line(expand: true)];
    } else if (textPosition == 'right') {
      children = [_line(expand: true), ...middle, _line(width: side)];
    } else {
      children = [_line(expand: true), ...middle, _line(expand: true)];
    }

    Widget root = Row(children: children);
    if (onClick != null) {
      root = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onClick,
        child: root,
      );
    }
    if (customStyle != null) {
      root = Container(decoration: customStyle, child: root);
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: root,
    );
  }

  bool _isJsTruthy(dynamic value) {
    if (value == null || value == false || value == '') return false;
    if (value is num && (value == 0 || value.isNaN)) return false;
    return true;
  }
}

class UPRow extends StatelessWidget {
  const UPRow({
    super.key,
    this.gutter = 0,
    this.justify = 'start',
    this.align = 'center',
    this.onClick,
    required this.children,
    this.customStyle,
  });

  final dynamic gutter;
  final String justify;
  final String align;
  final VoidCallback? onClick;
  final List<Widget> children;
  final BoxDecoration? customStyle;

  MainAxisAlignment get _main {
    switch (justify) {
      case 'end':
      case 'flex-end':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'around':
      case 'space-around':
        return MainAxisAlignment.spaceAround;
      case 'between':
      case 'space-between':
        return MainAxisAlignment.spaceBetween;
      case 'evenly':
      case 'space-evenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  CrossAxisAlignment get _cross {
    switch (align) {
      case 'top':
      case 'start':
      case 'flex-start':
        return CrossAxisAlignment.start;
      case 'bottom':
      case 'end':
      case 'flex-end':
        return CrossAxisAlignment.end;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      default:
        return CrossAxisAlignment.center;
    }
  }

  /// Source computed: uJustify.
  dynamic get uJustify {
    if (justify == 'end' || justify == 'start') return 'flex-$justify';
    if (justify == 'around' || justify == 'between') return 'space-$justify';
    return justify;
  }

  /// Source computed: uAlignItem.
  dynamic get uAlignItem {
    if (align == 'top') return 'flex-start';
    if (align == 'bottom') return 'flex-end';
    return align;
  }

  /// Source computed: rowStyle.
  dynamic get rowStyle {
    final style = <String, dynamic>{
      'alignItems': uAlignItem,
      'justifyContent': uJustify,
    };
    final g = num.tryParse('$gutter');
    if (g != null && g != 0) {
      style['marginLeft'] = UPUtils.addUnit(-g / 2);
      style['marginRight'] = UPUtils.addUnit(-g / 2);
    }
    return style;
  }

  /// Source `getComponentWidth` — returns provided measure or 0.
  dynamic getComponentWidth([dynamic v]) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is Map && v['width'] != null) {
      final w = v['width'];
      if (w is num) return w.toDouble();
      return double.tryParse('$w') ?? 0;
    }
    return double.tryParse('$v') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final g = UPUtils.getPx(gutter);
    Widget root = GestureDetector(
      onTap: onClick,
      behavior: HitTestBehavior.opaque,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width =
              constraints.hasBoundedWidth ? constraints.maxWidth : 0.0;
          return _UPRowScope(
            gutter: g,
            width: width,
            child: Row(
              mainAxisAlignment: _main,
              crossAxisAlignment: _cross,
              children: children,
            ),
          );
        },
      ),
    );
    if (customStyle != null) {
      root = Container(decoration: customStyle, child: root);
    }
    return root;
  }
}

class _UPRowScope extends InheritedWidget {
  const _UPRowScope({
    required this.gutter,
    required this.width,
    required super.child,
  });

  final double gutter;
  final double width;

  static _UPRowScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_UPRowScope>();

  @override
  bool updateShouldNotify(covariant _UPRowScope oldWidget) =>
      gutter != oldWidget.gutter || width != oldWidget.width;
}

final Expando<Map<String, dynamic>> _upColState =
    Expando<Map<String, dynamic>>('upColState');

class UPCol extends StatelessWidget {
  const UPCol({
    super.key,
    this.span = 12,
    this.offset = 0,
    this.justify = 'start',
    this.align = 'stretch',
    this.textAlign = 'left',
    this.onClick,
    this.child,
    this.customStyle,
  });

  final dynamic span;
  final dynamic offset;
  final String justify;
  final String align;
  final String textAlign;
  final VoidCallback? onClick;
  final Widget? child;
  final BoxDecoration? customStyle;

  TextAlign get _textAlign {
    switch (textAlign) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      default:
        return TextAlign.left;
    }
  }

  /// Source col helpers (Batch J + BI).
  Map<String, dynamic> get _state => _upColState[this] ??= <String, dynamic>{
        'initialized': false,
        'parentData': null
      };
  bool get initialized => _state['initialized'] == true;
  dynamic get parentDataRuntime => _state['parentData'];
  void init([dynamic _]) {
    _state['initialized'] = true;
  }

  void updateParentData([dynamic data]) {
    _state['parentData'] = data ?? parentData;
    _state['initialized'] = true;
  }

  void clickHandler([dynamic _]) => onClick?.call();

  /// Source data: gridNum.
  dynamic get gridNum => 12;

  /// Source data: parentData (runtime filled from UPRow gutter in build).
  dynamic get parentData {
    final runtime = _state['parentData'];
    if (runtime is Map) return runtime;
    return const <String, dynamic>{'gutter': 0};
  }

  /// Source computed: uJustify.
  dynamic get uJustify {
    if (justify == 'end' || justify == 'start') return 'flex-$justify';
    if (justify == 'around' || justify == 'between') return 'space-$justify';
    return justify;
  }

  /// Source computed: uAlignItem.
  dynamic get uAlignItem {
    if (align == 'top') return 'flex-start';
    if (align == 'bottom') return 'flex-end';
    return align;
  }

  /// Source computed: colStyle.
  dynamic get colStyle {
    final gutter = parentData is Map ? parentData['gutter'] : 0;
    final spanNum = num.tryParse('$span') ?? 12;
    final offsetNum = num.tryParse('$offset') ?? 0;
    final grid = num.tryParse('$gridNum') ?? 12;
    return <String, dynamic>{
      'paddingLeft': UPUtils.addUnit(UPUtils.getPx(gutter) / 2),
      'paddingRight': UPUtils.addUnit(UPUtils.getPx(gutter) / 2),
      'alignItems': uAlignItem,
      'justifyContent': uJustify,
      'textAlign': textAlign,
      'flex': '0 0 ${100 / grid * spanNum}%',
      'marginLeft': '${100 / 12 * offsetNum}%',
    };
  }

  @override
  Widget build(BuildContext context) {
    final parent = _UPRowScope.of(context);
    final gutter = parent?.gutter ?? 0;
    _state['parentData'] = <String, dynamic>{'gutter': gutter};
    _state['initialized'] = true;
    final s = (num.tryParse('$span') ?? 12).toDouble();
    final o = (num.tryParse('$offset') ?? 0).toDouble();

    final content = GestureDetector(
      onTap: onClick,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: gutter / 2),
        child: DefaultTextStyle.merge(
          textAlign: _textAlign,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
    final width = parent?.width ?? 0;
    Widget body = content;
    if (width > 0) {
      final offsetWidth = width / 12 * o;
      final columnWidth = width / 12 * s;
      body = customStyle == null
          ? SizedBox(width: columnWidth, child: content)
          : Container(
              width: columnWidth,
              decoration: customStyle,
              child: content,
            );
      if (offsetWidth >= 0) {
        body = Padding(
          padding: EdgeInsets.only(left: offsetWidth),
          child: body,
        );
      } else {
        // CSS permits negative margin-left values; Flutter padding does not.
        body = Transform.translate(offset: Offset(offsetWidth, 0), child: body);
      }
    } else if (customStyle != null) {
      body = Container(decoration: customStyle, child: body);
    }
    return body;
  }
}
