import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';

typedef UPWaterfallColumnBuilder = Widget Function(
  BuildContext context,
  int colIndex,
  List<dynamic> colList,
);

/// 1:1 API shell of u-waterfall with shortest-column placement.
///
/// Uses optional item [height] / [h] fields when present; otherwise falls back
/// to item-count balancing and post-layout measured heights.
class UPWaterfall extends StatefulWidget {
  const UPWaterfall({
    super.key,
    required this.value,
    this.modelValue,
    this.addTime = 200,
    this.idKey = 'id',
    this.columns = 2,
    this.columnsMin = 2,
    this.minColumnWidth = 230,
    this.itemBuilder,
    this.columnBuilder,
    this.leftBuilder,
    this.onAfterAddOne,
    this.onAfterAddAll,
    this.onUpdateValue,
    this.onUpdateModelValue,
    this.customStyle,
  });

  final List value;
  final List? modelValue;
  final dynamic addTime;
  final String idKey;
  final dynamic columns;
  final dynamic columnsMin;
  final double minColumnWidth;
  final Widget Function(
    BuildContext context,
    dynamic item,
    int itemIndex,
    int colIndex,
  )? itemBuilder;

  /// Source `column` slot.
  final UPWaterfallColumnBuilder? columnBuilder;

  /// Source `left` slot.
  final UPWaterfallColumnBuilder? leftBuilder;
  final ValueChanged<dynamic>? onAfterAddOne;

  /// Source `after-add-all` event. Receives `{columnHeights, newData}`.
  final ValueChanged<dynamic>? onAfterAddAll;

  /// Source `update:modelValue` alias for clear/remove/modify mutations.
  final ValueChanged<List>? onUpdateValue;

  /// Source emit alias: input.
  ValueChanged<List>? get onInput => onUpdateValue;
  final ValueChanged<List>? onUpdateModelValue;
  List get effectiveValue => modelValue ?? value;
  final BoxDecoration? customStyle;

  /// Source computed: copyFlowList.
  dynamic get copyFlowList {
    final src = effectiveValue;
    if (src.isEmpty) return <dynamic>[];
    return jsonDecode(jsonEncode(src)) as List<dynamic>;
  }

  @override
  State<UPWaterfall> createState() => UPWaterfallState();
}

class UPWaterfallState extends State<UPWaterfall> {
  /// Source host helper.
  bool timeoutCleared = false;
  void clearTimeout([dynamic _]) {
    timeoutCleared = true;
  }

  late List<List<dynamic>> columnList;

  /// Source data.
  bool initialized = false;
  double windowHeight = 0;
  double windowWidth = 0;

  late List<double> columnHeights;
  final measured = <Object?, double>{};
  int _lastCols = 0;
  double _lastWidth = 0;
  List? _localValue;
  late List<dynamic> _inputSnapshot;
  Timer? _resizeTimer;

  List get _items => _localValue ?? widget.effectiveValue;

  /// Current column count after auto/fixed resolution.
  int get columnCount => _lastCols > 0 ? _lastCols : columnList.length;

  /// Snapshot of per-column heights used by the balancer.
  List<double> get heights => List<double>.unmodifiable(columnHeights);

  /// Snapshot of items per column.
  List<List<dynamic>> get columns => columnList
      .map((c) => List<dynamic>.unmodifiable(c))
      .toList(growable: false);

  int get minHeightColumnIndex => getMinHeightColumnIndex();

  /// Source `getMinHeightColumnIndex(columnHeights)` helper.
  int getMinHeightColumnIndex([List<dynamic>? heights]) {
    final currentHeights = heights ?? columnHeights;
    if (currentHeights.isEmpty) return 0;
    var minI = 0;
    for (var i = 1; i < currentHeights.length; i++) {
      final currentHeight = double.tryParse('${currentHeights[i]}') ?? 0;
      final minHeight = double.tryParse('${currentHeights[minI]}') ?? 0;
      if (currentHeight < minHeight) {
        minI = i;
      } else if (currentHeight == minHeight) {
        final currentLength = i < columnList.length ? columnList[i].length : 0;
        final minLength =
            minI < columnList.length ? columnList[minI].length : 0;
        if (currentLength < minLength) minI = i;
      }
    }
    return minI;
  }

  /// Source `initColumnList`: reset the columns without inserting data.
  void initColumnList() {
    final width = _lastWidth > 0 ? _lastWidth : 375.0;
    setState(() => _initializeColumns(maxWidth: width));
  }

  int getColumnsCount() => _columnCount(
      windowWidth > 0 ? windowWidth : (_lastWidth > 0 ? _lastWidth : 375));

  /// Source `cloneData(data)` helper.
  List cloneData([List? data]) => _cloneSourceList(data ?? _items);

  /// Source window-resize handler. It redistributes only when the column count
  /// changes after the source's 300ms debounce window.
  void handleWindowResize([dynamic res]) {
    final size = res is Map ? res['size'] : null;
    final width = _numberValue(
      size is Map ? size['windowWidth'] : null,
    );
    final height = _numberValue(
      size is Map ? size['windowHeight'] : null,
    );
    if (width != null) {
      windowWidth = width;
      _lastWidth = width;
    }
    if (height != null) windowHeight = height;
    _resizeTimer?.cancel();
    _resizeTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final newColumnsCount = getColumnsCount();
      if (newColumnsCount != columnList.length) redistributeData();
    });
  }

  /// Source `handleData`: append incoming data to the current columns.
  void handleData([List? next, bool emit = false]) {
    final newData = List<dynamic>.from(next ?? _items);
    if (newData.isEmpty) return;
    setState(() => _appendData(newData));
    if (emit) _emitValueUpdate(_items);
  }

  /// Source `redistributeData`: reset columns and allocate the source input.
  void redistributeData() {
    measured.clear();
    _localValue = null;
    setState(() {
      _initializeColumns(maxWidth: _lastWidth > 0 ? _lastWidth : 375);
      _appendData(_cloneSourceList(widget.effectiveValue));
    });
  }

  void rebuild() {
    measured.clear();
    setState(() => _rebuild(maxWidth: _lastWidth > 0 ? _lastWidth : 375));
  }

  /// Source `clear(bak)`: empty columns and optional modelValue emit.
  void clear({bool emit = true}) {
    measured.clear();
    _localValue = <dynamic>[];
    initColumnList();
    if (emit) _emitValueUpdate(const []);
  }

  /// Source `remove(id)`: drop one item by [idKey] from columns/local list.
  dynamic remove(dynamic id, {bool emit = true}) {
    dynamic removed;
    var columnIndex = -1;
    for (var i = 0; i < columnList.length; i++) {
      final itemIndex =
          columnList[i].indexWhere((item) => _matchesId(item, id));
      if (itemIndex == -1) continue;
      removed = columnList[i].removeAt(itemIndex);
      columnIndex = i;
      break;
    }
    if (columnIndex == -1) return null;
    measured.remove(_idOf(removed));
    final estimatedHeight = _estimateHeight(removed);
    if (columnIndex < columnHeights.length) {
      columnHeights[columnIndex] =
          (columnHeights[columnIndex] - estimatedHeight)
              .clamp(0.0, double.infinity);
    }
    final next = _cloneSourceList(_items);
    next.removeWhere((item) => _matchesId(item, id));
    _localValue = next;
    setState(() {});
    if (emit) _emitValueUpdate(next);
    return removed;
  }

  /// Source `modify(id, key, value)` for map items.
  bool modify(dynamic id, String key, dynamic value, {bool emit = true}) {
    var found = false;
    setState(() {
      for (var columnIndex = 0;
          columnIndex < columnList.length;
          columnIndex++) {
        final itemIndex =
            columnList[columnIndex].indexWhere((item) => _matchesId(item, id));
        if (itemIndex == -1) continue;
        final item = columnList[columnIndex][itemIndex];
        if (item is Map) {
          columnList[columnIndex]
              [itemIndex] = Map<dynamic, dynamic>.from(item)..[key] = value;
          found = true;
        }
        break;
      }
    });
    if (!found) return false;
    final next = _items.map((item) {
      if (_matchesId(item, id) && item is Map) {
        return Map<dynamic, dynamic>.from(item)..[key] = value;
      }
      return item;
    }).toList();
    _localValue = next;
    if (emit) _emitValueUpdate(next);
    return true;
  }

  @override
  void initState() {
    super.initState();
    _inputSnapshot = _cloneSourceList(widget.effectiveValue);
    _rebuild(maxWidth: 375);
  }

  @override
  void didUpdateWidget(covariant UPWaterfall oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextInput = _cloneSourceList(widget.effectiveValue);
    final previousInput = _inputSnapshot;
    final valueChanged = !_sameSourceList(previousInput, nextInput);
    final columnsChanged = '${oldWidget.columns}' != '${widget.columns}';
    if (columnsChanged ||
        oldWidget.columnsMin != widget.columnsMin ||
        oldWidget.minColumnWidth != widget.minColumnWidth) {
      _inputSnapshot = nextInput;
      _localValue = null;
      measured.clear();
      _rebuild(maxWidth: _lastWidth > 0 ? _lastWidth : 375);
      return;
    }
    if (!valueChanged) return;

    _inputSnapshot = nextInput;
    _localValue = null;
    if (nextInput.isEmpty) {
      clear(emit: false);
      return;
    }
    // Source only takes the cheap append path when the new list starts with the
    // old one; otherwise the items were reordered or replaced and must be
    // redistributed, or stale entries would linger in the columns.
    if (!isPureAppend(nextInput, previousInput)) {
      // redistributeData re-reads the widget's current value, which is already
      // nextInput at this point.
      redistributeData();
      return;
    }
    final startIndex = previousInput.isEmpty ? 0 : previousInput.length;
    if (startIndex < nextInput.length) {
      handleData(nextInput.sublist(startIndex));
    }
  }

  /// Source `isPureAppend` — whether [newData] merely extends [oldData].
  bool isPureAppend(List<dynamic>? newData, List<dynamic>? oldData) {
    if (oldData == null || oldData.isEmpty) return true;
    if (newData == null || newData.length < oldData.length) return false;
    for (var i = 0; i < oldData.length; i++) {
      if (jsonEncode(oldData[i]) != jsonEncode(newData[i])) return false;
    }
    return true;
  }

  List<dynamic> _cloneSourceList(List source) =>
      jsonDecode(jsonEncode(source)) as List<dynamic>;

  bool _sameSourceList(List<dynamic> a, List<dynamic> b) =>
      jsonEncode(a) == jsonEncode(b);

  double? _numberValue(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value');
  }

  int _columnCount(double maxWidth) {
    if ('${widget.columns}' == 'auto') {
      final minCols = int.tryParse('${widget.columnsMin}') ?? 2;
      // The source reserves a 10rpx (about 7px) gap for every column.
      final width = widget.minColumnWidth + 7;
      final n = width > 0 ? (maxWidth / width).floor() : 1;
      return n < minCols ? minCols : n;
    }
    return int.tryParse('${widget.columns}') ?? 2;
  }

  Object? _idOf(dynamic item) {
    if (item is Map) return item[widget.idKey] ?? item.hashCode;
    return item.hashCode;
  }

  bool _matchesId(dynamic item, dynamic id) {
    if (item is Map) return item[widget.idKey] == id;
    return item == id;
  }

  double _estimateHeight(dynamic item) {
    final id = _idOf(item);
    if (measured.containsKey(id)) return measured[id]!;
    if (item is Map) {
      for (final k in ['height', 'h', 'itemHeight']) {
        final v = item[k];
        final n = double.tryParse('$v');
        if (n != null && n > 0) return n;
      }
    }
    return 1; // count-based fallback unit
  }

  void _rebuild({required double maxWidth}) {
    _initializeColumns(maxWidth: maxWidth);
    _appendData(_items);
  }

  void _initializeColumns({required double maxWidth}) {
    initialized = true;
    windowWidth = maxWidth;
    final requestedColumns = _columnCount(maxWidth);
    final cols = requestedColumns < 1 ? 1 : requestedColumns;
    _lastCols = cols;
    _lastWidth = maxWidth;
    columnList = List.generate(cols, (_) => <dynamic>[]);
    columnHeights = List.filled(cols, 0.0);
  }

  void _appendData(List<dynamic> items) {
    if (columnList.isEmpty) return;
    final newData = List<dynamic>.from(items);
    for (final item in newData) {
      final target = getMinHeightColumnIndex(columnHeights);
      columnList[target].add(item);
      columnHeights[target] += _estimateHeight(item);
      widget.onAfterAddOne?.call(_afterAddOnePayload(item, target));
    }
    if (newData.isNotEmpty) {
      widget.onAfterAddAll?.call({
        'columnHeights': List<double>.from(columnHeights),
        'newData': newData,
      });
    }
  }

  Map<dynamic, dynamic> _afterAddOnePayload(dynamic item, int columnIndex) {
    final payload = item is Map
        ? Map<dynamic, dynamic>.from(item)
        : <dynamic, dynamic>{'value': item};
    payload['height'] =
        columnIndex < columnHeights.length ? columnHeights[columnIndex] : 0.0;
    return payload;
  }

  void _emitValueUpdate(List values) {
    final next = List<dynamic>.from(values);
    if (widget.modelValue != null) {
      widget.onUpdateModelValue?.call(next);
      return;
    }
    if (widget.onUpdateValue != null) {
      widget.onUpdateValue?.call(next);
    } else {
      // Keep the Flutter alias useful for existing value-based call sites.
      widget.onUpdateModelValue?.call(next);
    }
  }

  bool _pendingRelayout = false;

  void _onChildSize(Object? id, double height, int colIndex) {
    if (height <= 0) return;
    final prev = measured[id];
    if (prev != null && (prev - height).abs() < 0.5) return;
    final wasUnit = prev == null || prev <= 1.5;
    measured[id] = height;
    // Rebalance only when previous estimate was unit fallback.
    if (wasUnit && (height - (prev ?? 1)).abs() > 8 && !_pendingRelayout) {
      _pendingRelayout = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pendingRelayout = false;
        if (!mounted) return;
        setState(() => _rebuild(maxWidth: _lastWidth > 0 ? _lastWidth : 375));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget root = LayoutBuilder(
      builder: (context, constraints) {
        final width =
            constraints.maxWidth.isFinite ? constraints.maxWidth : 375.0;
        final cols = _columnCount(width);
        if (columnList.length != cols) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _rebuild(maxWidth: width));
          });
        } else {
          windowWidth = width;
          _lastWidth = width;
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var c = 0; c < columnList.length; c++) ...[
              if (c > 0) const SizedBox(width: 7),
              Expanded(
                child: Column(
                  children: [
                    if (widget.columnBuilder != null)
                      widget.columnBuilder!(context, c, columnList[c]),
                    if (widget.leftBuilder != null)
                      widget.leftBuilder!(context, c, columnList[c]),
                    if (widget.columnBuilder == null &&
                        widget.leftBuilder == null)
                      for (var i = 0; i < columnList[c].length; i++)
                        _buildDefaultItem(context, columnList[c][i], i, c),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
    return root;
  }

  Widget _buildDefaultItem(
    BuildContext context,
    dynamic item,
    int itemIndex,
    int columnIndex,
  ) {
    return _MeasureSize(
      onChange: (height) => _onChildSize(_idOf(item), height, columnIndex),
      child: widget.itemBuilder?.call(
            context,
            item,
            itemIndex,
            columnIndex,
          ) ??
          const SizedBox.shrink(),
    );
  }

  @override
  void dispose() {
    _resizeTimer?.cancel();
    super.dispose();
  }
}

class _MeasureSize extends StatefulWidget {
  const _MeasureSize({required this.child, required this.onChange});
  final Widget child;
  final ValueChanged<double> onChange;

  @override
  State<_MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<_MeasureSize> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) widget.onChange(box.size.height);
    });
    return widget.child;
  }
}
