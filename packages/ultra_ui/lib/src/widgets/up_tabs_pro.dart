import 'package:flutter/widgets.dart';

import 'up_tabs.dart';

/// Payload passed to [UPTabsPro.contentBuilder], mirroring the source default
/// slot scope `{ current, index, item, value, list }`.
class UPTabsProContentScope {
  const UPTabsProContentScope({
    required this.current,
    required this.index,
    required this.item,
    required this.value,
    required this.list,
  });

  final num current;
  final num index;
  final dynamic item;
  final dynamic value;
  final List<dynamic> list;
}

/// 1:1 port of u-tabs-pro.
///
/// A thin wrapper over [UPTabs] that owns an internal `current` index and
/// optionally renders a content pane below the tab strip.
class UPTabsPro extends StatefulWidget {
  const UPTabsPro({
    super.key,
    this.list = const [],
    this.keyName = 'name',
    this.current = 0,
    this.contentMode = 'static',
    this.lineColor = '',
    this.activeStyle = const <String, dynamic>{},
    this.inactiveStyle = const <String, dynamic>{},
    this.lineWidth = 20,
    this.lineHeight = 3,
    this.lineBgSize = 'cover',
    this.itemStyle = const <String, dynamic>{'height': '44px'},
    this.scrollable = true,
    this.duration = 300,
    this.iconStyle = const <String, dynamic>{},
    this.shapeMode = '',
    this.showContent = true,
    this.contentClass = '',
    this.contentStyle = '',
    this.bindIndexRef = '',
    this.left,
    this.right,
    this.contentBuilder,
    this.onClick,
    this.onLongPress,
    this.onChange,
    this.onUpdateCurrent,
    this.customStyle,
  });

  final List<dynamic> list;
  final String keyName;
  final dynamic current;

  /// Source prop, declared but unused by the source template.
  final String contentMode;
  final dynamic lineColor;
  final Map<String, dynamic>? activeStyle;
  final Map<String, dynamic>? inactiveStyle;
  final dynamic lineWidth;
  final dynamic lineHeight;
  final String lineBgSize;
  final Map<String, dynamic>? itemStyle;
  final bool scrollable;
  final dynamic duration;
  final Map<String, dynamic>? iconStyle;
  final String shapeMode;
  final bool showContent;

  /// Source prop; Flutter has no CSS class engine, retained for compatibility.
  final String contentClass;
  final dynamic contentStyle;

  /// Source prop, declared but unused by the source template.
  final String bindIndexRef;

  /// Source `left` slot, forwarded to [UPTabs].
  final Widget? left;

  /// Source `right` slot, forwarded to [UPTabs].
  final Widget? right;

  /// Source default slot, rendered in the content pane when [showContent].
  final Widget Function(UPTabsProContentScope scope)? contentBuilder;

  final void Function(dynamic item, int index)? onClick;
  final void Function(dynamic item, int index)? onLongPress;
  final void Function(dynamic item, int index)? onChange;
  final ValueChanged<num>? onUpdateCurrent;

  final BoxDecoration? customStyle;

  /// Source computed: safeList.
  List<dynamic> get safeList => list;

  /// Source computed: resolvedLineColor.
  dynamic get resolvedLineColor {
    final color = lineColor;
    if (color == null) return null;
    if (color is String && color.isEmpty) return null;
    return color;
  }

  @override
  State<UPTabsPro> createState() => UPTabsProState();
}

class UPTabsProState extends State<UPTabsPro> {
  num _innerCurrent = 0;

  /// Source data: innerCurrent.
  num get innerCurrent => _innerCurrent;

  /// Source computed: currentItem.
  dynamic get currentItem {
    final list = widget.safeList;
    // Source indexes with the raw number, so a fractional index misses.
    if (_innerCurrent != _innerCurrent.roundToDouble()) return null;
    final i = _innerCurrent.toInt();
    if (i < 0 || i >= list.length) return null;
    return list[i];
  }

  /// Source computed: currentValue.
  dynamic get currentValue {
    final item = currentItem;
    if (item == null) return null;
    if (item is Map) return item[widget.keyName];
    return null;
  }

  @override
  void initState() {
    super.initState();
    // Source watch current: immediate.
    _innerCurrent = normalizeCurrent(widget.current);
  }

  @override
  void didUpdateWidget(UPTabsPro oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Source watch current.
    if (oldWidget.current != widget.current) {
      final next = normalizeCurrent(widget.current);
      if (next != _innerCurrent) setState(() => _innerCurrent = next);
      return;
    }
    // Source watch list: deep. Re-clamps and reports only when it moves.
    if (!_sameList(oldWidget.list, widget.list)) {
      final next = normalizeCurrent(_innerCurrent);
      if (next != _innerCurrent) {
        setState(() => _innerCurrent = next);
        widget.onUpdateCurrent?.call(next);
      }
    }
  }

  bool _sameList(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!identical(a[i], b[i]) && a[i] != b[i]) return false;
    }
    return true;
  }

  /// Source `normalizeCurrent`.
  num normalizeCurrent([dynamic value]) {
    final maxIndex =
        widget.safeList.length - 1 > 0 ? widget.safeList.length - 1 : 0;
    final parsed = _toNumber(value);
    final next = parsed ?? 0;
    if (next < 0) return 0;
    if (next > maxIndex) return maxIndex;
    return next;
  }

  /// JS `Number(value)` with `Number.isFinite` rejection.
  num? _toNumber(dynamic value) {
    if (value is num) return value.isFinite ? value : null;
    if (value is bool) return value ? 1 : 0;
    if (value == null) return 0;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return 0;
      final parsed = num.tryParse(trimmed);
      if (parsed == null || !parsed.isFinite) return null;
      return parsed;
    }
    return null;
  }

  /// Source `updateCurrent`.
  void updateCurrent([dynamic value]) {
    final next = normalizeCurrent(value);
    if (next != _innerCurrent) setState(() => _innerCurrent = next);
    widget.onUpdateCurrent?.call(next);
  }

  /// Source `clickHandler`.
  void clickHandler(dynamic item, int index, [dynamic event]) {
    widget.onClick?.call(item, index);
  }

  /// Source `longPressHandler`.
  void longPressHandler(dynamic item, int index) {
    widget.onLongPress?.call(item, index);
  }

  /// Source `changeHandler`.
  ///
  /// The source binds both `@update:current` and `@change` from the nested
  /// tabs, and this handler calls `updateCurrent` again, so a single tab tap
  /// reports `update:current` twice. Retained for event parity.
  void changeHandler(dynamic item, int index) {
    updateCurrent(index);
    widget.onChange?.call(item, index);
  }

  dynamic _itemAt(int index) {
    final list = widget.safeList;
    if (index < 0 || index >= list.length) return null;
    return list[index];
  }

  @override
  Widget build(BuildContext context) {
    final tabs = UPTabs(
      list: widget.safeList,
      keyName: widget.keyName,
      current: _innerCurrent,
      lineColor: widget.resolvedLineColor ?? '',
      activeStyle: widget.activeStyle,
      inactiveStyle: widget.inactiveStyle,
      lineWidth: widget.lineWidth,
      lineHeight: widget.lineHeight,
      lineBgSize: widget.lineBgSize,
      itemStyle: widget.itemStyle,
      scrollable: widget.scrollable,
      duration: _toNumber(widget.duration) ?? 300,
      iconStyle: widget.iconStyle,
      shapeMode: widget.shapeMode,
      left: widget.left,
      right: widget.right,
      onClick: (item, index) => clickHandler(item, index),
      onLongPress: (item, index) => longPressHandler(item, index),
      onUpdateCurrent: (index) => updateCurrent(index),
      onChange: (index) => changeHandler(_itemAt(index), index),
    );

    final children = <Widget>[tabs];
    if (widget.showContent && widget.contentBuilder != null) {
      children.add(
        widget.contentBuilder!(
          UPTabsProContentScope(
            current: _innerCurrent,
            index: _innerCurrent,
            item: currentItem,
            value: currentValue,
            list: widget.safeList,
          ),
        ),
      );
    }

    return Container(
      decoration: widget.customStyle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
