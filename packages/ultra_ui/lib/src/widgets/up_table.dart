import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';

/// 1:1 port of u-table / u-tr / u-th / u-td.
class UPTable extends StatelessWidget {
  const UPTable({
    super.key,
    this.borderColor = '#e4e7ed',
    this.align = 'center',
    this.padding = '5px 3px',
    this.fontSize = '14px',
    this.color = '#606266',
    this.thStyle = const {},
    this.bgColor = '#ffffff',
    required this.children,
    this.customStyle,
  });

  /// Source data.
  bool get show => true;
  final dynamic borderColor;
  final String align;
  final dynamic padding;
  final dynamic fontSize;
  final dynamic color;
  final Map thStyle;
  final dynamic bgColor;
  final List<UPTr> children;
  final BoxDecoration? customStyle;

  /// Source `change` — presentational table; returns payload for host.
  dynamic change([dynamic payload]) => payload;

  /// Source computed: resolvedBorderColor.
  dynamic get resolvedBorderColor {
    final c = '$borderColor';
    return c == '#e4e7ed' ? '#e4e7ed' : borderColor;
  }

  /// Source computed: resolvedColor.
  dynamic get resolvedColor {
    final c = '$color';
    return c == '#606266' ? '#606266' : color;
  }

  /// Source computed: resolvedBgColor.
  dynamic get resolvedBgColor {
    final c = '$bgColor';
    return c == '#ffffff' ? '#ffffff' : bgColor;
  }

  /// Source computed: tableStyle.
  dynamic get tableStyle => <String, dynamic>{
        'borderLeft': 'solid 1px $resolvedBorderColor',
        'borderTop': 'solid 1px $resolvedBorderColor',
        'backgroundColor': resolvedBgColor,
      };

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final border = UPUtils.parseColor(borderColor) ?? tokens.borderColor;
    final bg = UPUtils.parseColor(bgColor) ?? tokens.cardBgColor;
    final textColor = UPUtils.parseColor(color) ?? tokens.contentColor;
    Widget root = _UPTableScope(
      borderColor: border,
      align: align,
      padding: padding,
      fontSize: fontSize,
      color: textColor,
      thStyle: thStyle,
      bgColor: bg,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          border: Border(
            left: BorderSide(color: border, width: 1),
            top: BorderSide(color: border, width: 1),
          ),
        ),
        child: Column(children: children),
      ),
    );
    return root;
  }
}

class _UPTableScope extends InheritedWidget {
  const _UPTableScope({
    required this.borderColor,
    required this.align,
    required this.padding,
    required this.fontSize,
    required this.color,
    required this.thStyle,
    required this.bgColor,
    required super.child,
  });

  final Color borderColor;
  final String align;
  final dynamic padding;
  final dynamic fontSize;
  final Color color;
  final Map thStyle;
  final Color bgColor;

  static _UPTableScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_UPTableScope>();

  @override
  bool updateShouldNotify(covariant _UPTableScope oldWidget) => true;
}

class UPTr extends StatelessWidget {
  const UPTr({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(children: children);
  }
}

class UPTh extends StatelessWidget {
  const UPTh({super.key, this.width = '', this.child});
  final dynamic width;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scope = _UPTableScope.of(context);
    final tokens = UPThemeTokens.of(context);
    final border = scope?.borderColor ?? tokens.borderColor;
    final align = scope?.align ?? 'center';
    final pad = _edge(scope?.padding ?? '5px 3px');
    final fs = UPUtils.getPx(scope?.fontSize ?? 14);

    Widget content = DefaultTextStyle(
      style: TextStyle(
        color: tokens.mainColor,
        fontSize: fs,
        fontWeight: FontWeight.bold,
      ),
      textAlign: _textAlign(align),
      child: child ?? const SizedBox.shrink(),
    );

    content = Container(
      padding: pad,
      alignment: _alignment(align),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        border: Border(
          right: BorderSide(color: border, width: 1),
          bottom: BorderSide(color: border, width: 1),
        ),
      ),
      child: content,
    );

    final w = '$width';
    if (w.isNotEmpty && w.endsWith('%')) {
      final p = double.tryParse(w.replaceAll('%', '')) ?? 0;
      return Expanded(flex: p.round().clamp(1, 100), child: content);
    }
    if (w.isNotEmpty) {
      return SizedBox(width: UPUtils.getPx(w), child: content);
    }
    return Expanded(child: content);
  }
}

class UPTd extends StatelessWidget {
  const UPTd({
    super.key,
    this.width = 'auto',
    this.textAlign = '',
    this.fontSize = '',
    this.borderColor = '',
    this.color = '',
    this.child,
  });

  final dynamic width;
  final String textAlign;
  final dynamic fontSize;
  final dynamic borderColor;
  final dynamic color;
  final Widget? child;

  /// Source data: tdStyle.
  dynamic get tdStyle {
    final style = <String, dynamic>{};
    final w = '$width';
    if (w.isNotEmpty && w != 'auto') {
      style['width'] = UPUtils.addUnit(width);
    }
    if (textAlign.isNotEmpty) style['textAlign'] = textAlign;
    if ('$fontSize'.trim().isNotEmpty) {
      style['fontSize'] = UPUtils.addUnit(fontSize);
    }
    if ('$borderColor'.trim().isNotEmpty) style['borderColor'] = borderColor;
    if ('$color'.trim().isNotEmpty) style['color'] = color;
    return style;
  }

  @override
  Widget build(BuildContext context) {
    final scope = _UPTableScope.of(context);
    final tokens = UPThemeTokens.of(context);
    final border = UPUtils.parseColor(borderColor) ??
        scope?.borderColor ??
        tokens.borderColor;
    final align = textAlign.isNotEmpty ? textAlign : (scope?.align ?? 'center');
    final pad = _edge(scope?.padding ?? '5px 3px');
    final fs = UPUtils.getPx(
      '$fontSize'.isEmpty ? (scope?.fontSize ?? 14) : fontSize,
    );
    final c = UPUtils.parseColor(color) ?? scope?.color ?? tokens.contentColor;

    Widget content = DefaultTextStyle(
      style: TextStyle(color: c, fontSize: fs),
      textAlign: _textAlign(align),
      child: child ?? const SizedBox.shrink(),
    );

    content = Container(
      padding: pad,
      alignment: _alignment(align),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: border, width: 1),
          bottom: BorderSide(color: border, width: 1),
        ),
      ),
      child: content,
    );

    final w = '$width';
    if (w.isNotEmpty && w != 'auto' && w.endsWith('%')) {
      final p = double.tryParse(w.replaceAll('%', '')) ?? 0;
      return Expanded(flex: p.round().clamp(1, 100), child: content);
    }
    if (w.isNotEmpty && w != 'auto') {
      return SizedBox(width: UPUtils.getPx(w), child: content);
    }
    return Expanded(child: content);
  }
}

EdgeInsets _edge(dynamic value) {
  if (value is EdgeInsets) return value;
  final parts = '$value'.trim().split(RegExp(r'\s+'));
  final nums = parts.map(UPUtils.getPx).toList();
  if (nums.length == 1) return EdgeInsets.all(nums[0]);
  if (nums.length == 2) {
    return EdgeInsets.symmetric(vertical: nums[0], horizontal: nums[1]);
  }
  if (nums.length >= 4) {
    return EdgeInsets.only(
      top: nums[0],
      right: nums[1],
      bottom: nums[2],
      left: nums[3],
    );
  }
  return EdgeInsets.zero;
}

TextAlign _textAlign(String align) {
  switch (align) {
    case 'left':
      return TextAlign.left;
    case 'right':
      return TextAlign.right;
    default:
      return TextAlign.center;
  }
}

Alignment _alignment(String align) {
  switch (align) {
    case 'left':
      return Alignment.centerLeft;
    case 'right':
      return Alignment.centerRight;
    default:
      return Alignment.center;
  }
}
