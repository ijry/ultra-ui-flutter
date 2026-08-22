import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';

final Expando<Map<String, dynamic>> _upGridState =
    Expando<Map<String, dynamic>>('upGridState');
final Expando<Map<String, dynamic>> _upGridItemState =
    Expando<Map<String, dynamic>>('upGridItemState');

/// 1:1 port of u-grid / u-grid-item.
class UPGrid extends StatelessWidget {
  const UPGrid({
    super.key,
    this.col = 3,
    this.border = false,
    this.align = 'left',
    this.gap = '0px',
    this.options = const [],
    this.customStyle,
    required this.children,
  });

  final dynamic col;
  final bool border;
  final String align;
  final dynamic gap;

  /// Source retained options list (host data mode).
  final List options;
  final BoxDecoration? customStyle;

  /// Source data.
  int get index => 0;

  final List<Widget> children;

  /// Source parent helpers (Batch J).
  Map<String, dynamic> get _state => _upGridState[this] ??= <String, dynamic>{
        'initialized': false,
        'lastChildClick': null
      };
  dynamic get lastChildClick => _state['lastChildClick'];
  bool get initialized => _state['initialized'] == true;
  void init([dynamic _]) {
    _state['initialized'] = true;
  }

  void childClick([dynamic payload]) {
    _state['lastChildClick'] = payload;
  }

  void updateParentData([dynamic _]) {
    _state['initialized'] = true;
  }

  /// Source computed: parentData.
  dynamic get parentData => <dynamic>[
        null, // hoverClass host shell
        col,
        null, // size host shell
        border,
      ];

  /// Source computed: gridStyle.
  dynamic get gridStyle {
    String justify;
    switch (align) {
      case 'center':
        justify = 'center';
        break;
      case 'right':
        justify = 'flex-end';
        break;
      case 'left':
      default:
        justify = 'flex-start';
    }
    return <String, dynamic>{'justifyContent': justify};
  }

  @override
  Widget build(BuildContext context) {
    final columns = int.tryParse('$col') ?? 3;
    final gapPx = UPUtils.getPx(gap);
    Widget body = _UPGridScope(
      col: columns,
      border: border,
      align: align,
      gap: gapPx,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          final totalGap = gapPx * (columns - 1).clamp(0, columns);
          final itemW = columns <= 0 ? width : (width - totalGap) / columns;
          final aligned = align == 'center'
              ? WrapAlignment.center
              : align == 'right'
                  ? WrapAlignment.end
                  : WrapAlignment.start;
          return Wrap(
            alignment: aligned,
            spacing: gapPx,
            runSpacing: gapPx,
            children: [
              for (final child in children)
                SizedBox(width: itemW, child: child),
            ],
          );
        },
      ),
    );
    if (customStyle != null) {
      body = Container(decoration: customStyle, child: body);
    }
    return body;
  }
}

class _UPGridScope extends InheritedWidget {
  const _UPGridScope({
    required this.col,
    required this.border,
    required this.align,
    required this.gap,
    required super.child,
  });

  final int col;
  final bool border;
  final String align;
  final double gap;

  static _UPGridScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_UPGridScope>();

  @override
  bool updateShouldNotify(covariant _UPGridScope oldWidget) {
    return col != oldWidget.col ||
        border != oldWidget.border ||
        align != oldWidget.align ||
        gap != oldWidget.gap;
  }
}

class UPGridItem extends StatelessWidget {
  const UPGridItem({
    super.key,
    this.name,
    this.bgColor = 'transparent',
    this.customStyle,
    this.onClick,
    required this.child,
    this.onUGridItem,
  });

  /// Source emit alias: $uGridItem -> onUGridItem.
  final ValueChanged<dynamic>? onUGridItem;

  final dynamic name;
  final dynamic bgColor;
  final BoxDecoration? customStyle;
  final ValueChanged<dynamic>? onClick;
  final Widget child;

  /// Source item helpers (Batch J).
  Map<String, dynamic> get _state =>
      _upGridItemState[this] ??= <String, dynamic>{'initialized': false};
  bool get initialized => _state['initialized'] == true;
  void init([dynamic _]) {
    _state['initialized'] = true;
  }

  void updateParentData([dynamic _]) {
    _state['initialized'] = true;
  }

  void clickHandler([dynamic _]) => onClick?.call(_ ?? name);
  List gridItemClasses([dynamic _]) => const ['up-grid-item'];

  /// Source computed: itemStyle.
  dynamic get itemStyle => <String, dynamic>{
        'background': bgColor,
        'width': '100%',
      };

  /// Source `getItemWidth` — parentWidth / col (+ optional px string like nvue).
  /// Call as getItemWidth(parentWidth, col). Without args returns 0.
  dynamic getItemWidth([dynamic parentWidth, dynamic col]) {
    final pw = _toDouble(parentWidth);
    final c = _toInt(col, fallback: 3);
    if (pw <= 0 || c <= 0) return 0;
    final w = pw / c;
    return '${w}px';
  }

  /// Source `getParentWidth` — accepts measured width or map with width.
  dynamic getParentWidth([dynamic v]) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is Map && v['width'] != null) {
      return _toDouble(v['width']);
    }
    final parsed = double.tryParse('$v');
    return parsed ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? 0;
  }

  static int _toInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? fallback;
  }

  /// Source data default: classes (border class list; filled during build).
  dynamic get classes {
    final list = <dynamic>['up-grid-item'];
    if (_state['border'] == true) list.add('up-border');
    if (_state['align'] != null && '${_state['align']}' != 'left') {
      list.add('up-grid-item--${_state['align']}');
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final scope = _UPGridScope.of(context);
    final tokens = UPThemeTokens.of(context);
    final border = scope?.border ?? false;
    final align = scope?.align ?? 'left';
    _state['border'] = border;
    _state['align'] = align;
    _state['initialized'] = true;

    final alignment = align == 'center'
        ? Alignment.center
        : align == 'right'
            ? Alignment.centerRight
            : Alignment.centerLeft;

    Widget body = GestureDetector(
      onTap: onClick == null ? null : () => onClick!(name),
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: alignment,
        decoration: (customStyle ?? const BoxDecoration()).copyWith(
          color: customStyle?.color ??
              (UPUtils.parseColor(bgColor) ?? const Color(0x00000000)),
          border: customStyle?.border ??
              (border
                  ? Border.all(color: tokens.borderColor, width: 0.5)
                  : null),
        ),
        child: child,
      ),
    );
    return body;
  }
}
