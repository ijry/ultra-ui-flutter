import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';

/// Port of u-table2 / up-table2.
///
/// Supports selection, multi/single sort, tree expand, fixed-left visual
/// indicator and public methods close to source (`toggleSelect`,
/// `clearSelection`, `toggleExpand`, `setCurrentRow`, etc.).
class UPTable2 extends StatefulWidget {
  const UPTable2({
    super.key,
    this.columns = const [],
    this.data = const [],
    this.border = false,
    this.stripe = false,
    this.showHeader = true,
    this.fixedHeader = true,
    this.height,
    this.maxHeight,
    this.rowHeight = '36px',
    this.rowKey = 'id',
    this.currentRowKey,
    this.emptyText = '暂无数据',
    this.highlightCurrentRow = false,
    this.sortable = false,
    this.multiSort = false,
    this.sortOrders = const ['ascending', 'descending'],
    this.sortBy,
    this.treeProps = const {
      'children': 'children',
      'hasChildren': 'hasChildren'
    },
    this.defaultExpandAll = false,
    this.expandRowKeys = const [],
    this.mainCol = '',
    this.expandWidth = '25px',
    this.lazy = false,
    this.load,
    this.rowStyle,
    this.cellClassName,
    this.headerCellClassName,
    this.rowClassName,
    this.showOverflowTooltip = false,
    this.filters = const {},
    this.sortMethod,
    this.spanMethod,
    this.tableContext,
    this.parentRow,
    this.cellStyle,
    this.onRowClick,
    this.onRowDblclick,
    this.onHeaderClick,
    this.onCellClick,
    this.onSelectionChange,
    this.onSelect,
    this.onSelectAll,
    this.onSortChange,
    this.onCurrentChange,
    this.onExpandChange,
    this.onToggleExpand,
    this.onToggleSelect,
    this.onFilterChange,
    this.customStyle,
  });

  final List columns;
  final List data;
  final bool border;
  final bool stripe;
  final bool showHeader;
  final bool fixedHeader;
  final dynamic height;
  final dynamic maxHeight;
  final dynamic rowHeight;
  final String rowKey;
  final dynamic currentRowKey;
  final String emptyText;
  final bool highlightCurrentRow;

  /// Global sortable switch; column-level `sortable` wins when present.
  final dynamic sortable;
  final bool multiSort;
  final List sortOrders;
  final dynamic sortBy;
  final Map treeProps;
  final bool defaultExpandAll;
  final List expandRowKeys;
  final String mainCol;
  final dynamic expandWidth;
  final bool lazy;

  /// Lazy tree loader. Signature mirrors source:
  /// `load(row, meta, resolve)` where resolve accepts children list.
  final void Function(
    Map row,
    Map meta,
    void Function([List children]) resolve,
  )? load;

  /// Optional row style map or builder: `(row, rowIndex, level) => Map/BoxDecoration`.
  final dynamic rowStyle;

  /// Optional cell style builder: `(row, column, rowIndex, columnIndex) => Map`.
  /// Source className/filter/span props.
  final dynamic cellClassName;
  final dynamic headerCellClassName;
  final dynamic rowClassName;
  final dynamic showOverflowTooltip;
  final Map filters;
  final dynamic sortMethod;
  final dynamic spanMethod;

  /// Source `context` host object (renamed to avoid State.context clash).
  final dynamic tableContext;

  /// Source retained tree parent row.
  final dynamic parentRow;
  final dynamic cellStyle;

  final ValueChanged<Map>? onRowClick;
  final ValueChanged<Map>? onRowDblclick;
  final ValueChanged<Map>? onHeaderClick;
  final void Function(Map row, Map column, int rowIndex, int columnIndex)?
      onCellClick;
  final ValueChanged<List>? onSelectionChange;
  final ValueChanged<Map>? onSelect;
  final ValueChanged<List>? onSelectAll;
  final ValueChanged<List>? onSortChange;
  final void Function(Map? current, Map? old)? onCurrentChange;
  final ValueChanged<List>? onExpandChange;

  /// Source emit alias: toggleExpand.
  final ValueChanged<dynamic>? onToggleExpand;

  /// Source emit alias: toggleSelect.
  final ValueChanged<dynamic>? onToggleSelect;

  /// Source emit: filter-change.
  final ValueChanged<dynamic>? onFilterChange;
  final BoxDecoration? customStyle;

  /// Source `getComponentWidth` — returns provided measure or 0.
  dynamic getComponentWidth([dynamic v]) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is Map && v['width'] != null) {
      final w = v['width'];
      if (w is num) return w.toDouble();
      return double.tryParse('$w') ?? 0.0;
    }
    return double.tryParse('$v') ?? 0.0;
  }

  @override
  State<UPTable2> createState() => UPTable2State();
}

class _FlatRow {
  _FlatRow({
    required this.row,
    required this.level,
    this.parent,
    required this.rowIndex,
  });

  final Map row;
  final int level;
  final Map? parent;
  final int rowIndex;
}

class UPTable2State extends State<UPTable2> {
  /// Source data.
  List get fixedLeftColumns => visibleFixedLeftColumns;
  double headerHeight = 0;
  double scrollLeft = 0;
  double scrollWidth = 0;
  bool showFixedColumnShadow = false;
  double tableHeight = 0;
  double scrollOffset = 0;

  final selectedRows = <Map>[];
  final sortConditions = <Map>[];
  final expandedKeys = <dynamic>[];
  final lazyLoadingKeys = <dynamic>[];
  Map? currentRow;
  late final ScrollController _horizontalController;
  late final ScrollController _verticalController;
  double _verticalScrollOffset = 0;

  String get _childrenKey => '${widget.treeProps['children'] ?? 'children'}';
  String get _hasChildrenKey =>
      '${widget.treeProps['hasChildren'] ?? 'hasChildren'}';

  Map _col(dynamic c) => c is Map ? Map<dynamic, dynamic>.from(c) : {};
  Map _row(dynamic r) => r is Map ? Map<dynamic, dynamic>.from(r) : {};

  dynamic _rowKeyOf(Map row, [int? fallbackIndex]) =>
      row[widget.rowKey] ?? fallbackIndex;

  double _colWidth(Map col) {
    final w = col['width'];
    if (w == null) return 100;
    return UPUtils.getPx(w);
  }

  bool get hasTree {
    return widget.data.any((item) {
      final row = _row(item);
      final children = row[_childrenKey];
      return (children is List && children.isNotEmpty) ||
          row[_hasChildrenKey] == true;
    });
  }

  /// Source data helpers (Batch K).
  List get filteredData => List.from(widget.data);
  List get visibleFixedLeftColumns {
    return widget.columns.where((c) {
      final col = _col(c);
      return '${col['fixed'] ?? ''}' == 'left';
    }).toList();
  }

  Map cellStyleInner([
    Map? column,
    Map? row,
    int? rowIndex,
    int? columnIndex,
    int level = 1,
  ]) {
    final col = column ?? const <dynamic, dynamic>{};
    final data = row ?? const <dynamic, dynamic>{};
    final style = <String, dynamic>{
      'column': col,
      'row': data,
      'width': _colWidth(col),
      'flex': col['width'] == null ? 1 : null,
    };
    if ('${col['key'] ?? ''}' == computedMainCol) {
      style['paddingLeft'] = (16.0 * (level - 1)) + 2;
    }

    final cs = widget.cellStyle;
    if (cs is Function) {
      final scope = <String, dynamic>{
        'row': data,
        'column': col,
        'rowIndex': rowIndex,
        'columnIndex': columnIndex,
        'level': level,
        'context': widget.tableContext,
      };
      Map? result;
      try {
        final value = cs(scope);
        if (value is Map) result = value;
      } catch (_) {}
      if (result == null) {
        try {
          final value = Function.apply(cs, [data, col, rowIndex, columnIndex]);
          if (value is Map) result = value;
        } catch (_) {}
      }
      if (result != null) {
        style.addAll(Map<String, dynamic>.from(result));
      }
    }
    return style;
  }

  String get computedMainCol {
    if (widget.mainCol.isNotEmpty) return widget.mainCol;
    for (final c in widget.columns) {
      final col = _col(c);
      final type = '${col['type'] ?? 'default'}';
      if (type == 'default' || type.isEmpty) {
        return '${col['key'] ?? ''}';
      }
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _horizontalController = ScrollController()
      ..addListener(_handleHorizontalScroll);
    _verticalController = ScrollController()
      ..addListener(_handleVerticalScroll);
    expandedKeys
      ..clear()
      ..addAll(widget.expandRowKeys);
    _initDefaultExpandAll();
    _syncCurrentRowKey(widget.currentRowKey);
  }

  @override
  void dispose() {
    _horizontalController
      ..removeListener(_handleHorizontalScroll)
      ..dispose();
    _verticalController
      ..removeListener(_handleVerticalScroll)
      ..dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant UPTable2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expandRowKeys != widget.expandRowKeys) {
      expandedKeys
        ..clear()
        ..addAll(widget.expandRowKeys);
      _initDefaultExpandAll();
    }
    if (oldWidget.defaultExpandAll != widget.defaultExpandAll ||
        oldWidget.data != widget.data) {
      if (widget.defaultExpandAll) _initDefaultExpandAll();
    }
    if (oldWidget.currentRowKey != widget.currentRowKey) {
      _syncCurrentRowKey(widget.currentRowKey);
    }
  }

  void _syncCurrentRowKey(dynamic key) {
    if (key == null) return;
    final found = _findRowByKey(widget.data, key);
    if (found != null) currentRow = found;
  }

  Map? _findRowByKey(List list, dynamic key) {
    for (final item in list) {
      final row = _row(item);
      if (_rowKeyOf(row) == key) return row;
      final children = row[_childrenKey];
      if (children is List) {
        final nested = _findRowByKey(children, key);
        if (nested != null) return nested;
      }
    }
    return null;
  }

  /// Source expand-all initializer alias.
  void initDefaultExpandAll() => _initDefaultExpandAll();

  /// Source style/span helpers.
  Map getRowStyle([
    dynamic row,
    dynamic rowIndex,
    dynamic level = 1,
    dynamic parentRow,
  ]) {
    final rs = widget.rowStyle;
    if (rs is Function) {
      try {
        final result = Function.apply(rs, [row, rowIndex, level]);
        if (result is Map) return Map<String, dynamic>.from(result);
      } catch (_) {}
      try {
        final result = rs({
          'row': row,
          'rowIndex': rowIndex,
          'level': level,
          'parentRow': parentRow,
          'context': widget.tableContext,
        });
        if (result is Map) return Map<String, dynamic>.from(result);
      } catch (_) {}
    }
    if (rs is Map) return Map<String, dynamic>.from(rs);
    return <String, dynamic>{};
  }

  Map getCellSpan([
    dynamic row,
    dynamic column,
    dynamic rowIndex,
    dynamic columnIndex,
  ]) {
    final sm = widget.spanMethod;
    if (sm is! Function) {
      return <String, dynamic>{'rowspan': 1, 'colspan': 1};
    }
    try {
      final result = sm({
        'row': row,
        'column': column,
        'rowIndex': rowIndex,
        'columnIndex': columnIndex,
        'context': widget.tableContext,
      });
      if (result is List) {
        return <String, dynamic>{
          'rowspan': result.isNotEmpty ? (result[0] ?? 1) : 1,
          'colspan': result.length > 1 ? (result[1] ?? 1) : 1,
        };
      }
      if (result is Map) {
        return <String, dynamic>{
          'rowspan': result['rowspan'] ?? 1,
          'colspan': result['colspan'] ?? 1,
        };
      }
    } catch (_) {}
    return <String, dynamic>{'rowspan': 1, 'colspan': 1};
  }

  String getCellSpanClass([
    dynamic row,
    dynamic column,
    dynamic rowIndex,
    dynamic columnIndex,
  ]) {
    final span = getCellSpan(row, column, rowIndex, columnIndex);
    final rs = int.tryParse('${span['rowspan']}') ?? 1;
    final cs = int.tryParse('${span['colspan']}') ?? 1;
    if (rs == 0 || cs == 0) return 'u-table-cell-hidden';
    if (rs > 1 || cs > 1) return 'u-table-cell-merged';
    return '';
  }

  Map getCellSpanStyle([
    dynamic row,
    dynamic column,
    dynamic rowIndex,
    dynamic columnIndex,
  ]) {
    final span = getCellSpan(row, column, rowIndex, columnIndex);
    final style = <String, dynamic>{};
    final rs = int.tryParse('${span['rowspan']}') ?? 1;
    final cs = int.tryParse('${span['colspan']}') ?? 1;
    if (rs > 1) {
      // Source uses parseInt(rowHeight); '36px' => 36.
      final raw = '${widget.rowHeight}';
      final parsed =
          int.tryParse(RegExp(r'-?\d+').firstMatch(raw)?.group(0) ?? '') ??
              UPUtils.getPx(widget.rowHeight).round();
      style['height'] = '${rs * parsed}px';
    }
    if (cs > 1) style['flex'] = cs;
    if (rs == 0 || cs == 0) style['display'] = 'none';
    return style;
  }

  bool isOverflowTooltipEnabled([dynamic column]) {
    if (column is Map) {
      if ('${column['type'] ?? ''}' == 'selection') return false;
      if (column.containsKey('showOverflowTooltip')) {
        return column['showOverflowTooltip'] == true;
      }
    }
    final v = widget.showOverflowTooltip;
    if (v is bool) return v;
    return '$v' == 'true';
  }

  Map getFixedShadowStyle([dynamic col, dynamic index]) {
    // Host-compat: string side arg returns side marker map.
    if (col is String) {
      return <String, dynamic>{'side': col, 'width': 'auto'};
    }
    final style = <String, dynamic>{
      'width': (col is Map && col['width'] != null)
          ? UPUtils.addUnit(col['width'])
          : 'auto',
    };
    if (col is Map && col['style'] is Map) {
      style.addAll(Map<String, dynamic>.from(col['style'] as Map));
    }
    return style;
  }

  String getFixedClass([dynamic side = 'left']) =>
      '$side' == 'left' ? 'fixed-left' : 'fixed-right';
  dynamic getSortValueBy(dynamic row, dynamic column) {
    if (row is! Map) return null;
    dynamic field = column;
    dynamic sortBy;
    if (column is Map) {
      field = column['field'] ?? column['key'] ?? column['prop'];
      sortBy = column['sortBy'];
    }
    return _sortValueBy(row, field, sortBy);
  }

  bool hasExpandableChildren([dynamic row]) {
    if (row is Map) return _hasExpandableChildren(row);
    return false;
  }

  void _handleHorizontalScroll() {
    if (!_horizontalController.hasClients) return;
    onScroll(_horizontalController.offset);
  }

  void _handleVerticalScroll() {
    if (!_verticalController.hasClients) return;
    final offset = _verticalController.offset;
    if (_verticalScrollOffset == offset) return;
    setState(() => _verticalScrollOffset = offset);
  }

  void onScroll([double? offset]) {
    if (offset == null) return;
    if (scrollLeft == offset && showFixedColumnShadow == (offset > 0)) return;
    void update() {
      scrollOffset = offset;
      scrollLeft = offset;
      showFixedColumnShadow = offset > 0;
    }

    if (mounted) {
      setState(update);
    } else {
      update();
    }
  }

  void _initDefaultExpandAll() {
    if (!widget.defaultExpandAll) return;
    final keys = <dynamic>[];
    void walk(List rows) {
      for (final item in rows) {
        final row = _row(item);
        if (_hasExpandableChildren(row)) {
          keys.add(_rowKeyOf(row));
        }
        final children = row[_childrenKey];
        if (children is List) walk(children);
      }
    }

    walk(widget.data);
    for (final k in keys) {
      if (!expandedKeys.contains(k)) expandedKeys.add(k);
    }
  }

  bool _hasExpandableChildren(Map row) {
    final children = row[_childrenKey];
    return (children is List && children.isNotEmpty) ||
        row[_hasChildrenKey] == true;
  }

  bool isExpanded(Map row) {
    final key = _rowKeyOf(row);
    return key != null && expandedKeys.contains(key);
  }

  bool isSelected(Map row) {
    final key = _rowKeyOf(row);
    return selectedRows.any((r) => _rowKeyOf(r) == key);
  }

  bool isLazyLoading(Map row) {
    final key = _rowKeyOf(row);
    return key != null && lazyLoadingKeys.contains(key);
  }

  bool isColumnSortable(Map column) {
    if (column.containsKey('sortable')) return column['sortable'] == true;
    if (widget.sortable is bool) return widget.sortable == true;
    if (widget.sortable is String) {
      return '${widget.sortable}'.isNotEmpty && '${widget.sortable}' != 'false';
    }
    return false;
  }

  List getColumnSortOrders(Map column) {
    final local = column['sortOrders'];
    if (local is List && local.isNotEmpty) return local;
    return widget.sortOrders;
  }

  dynamic getColumnSortBy(Map column) {
    if (column.containsKey('sortBy')) return column['sortBy'];
    return widget.sortBy;
  }

  dynamic _sortValueBy(Map row, dynamic field, dynamic sortBy) {
    if (sortBy is Function) {
      return Function.apply(sortBy, [row]);
    }
    if (sortBy is List && sortBy.isNotEmpty) {
      return sortBy.map((k) => row[k]).join('');
    }
    if (sortBy is String && sortBy.isNotEmpty) {
      return row[sortBy];
    }
    return row[field];
  }

  int _compareValues(dynamic a, dynamic b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    if (a is num && b is num) return a.compareTo(b);
    final an = num.tryParse('$a');
    final bn = num.tryParse('$b');
    if (an != null && bn != null) return an.compareTo(bn);
    return '$a'.compareTo('$b');
  }

  List<Map> get sortedData {
    final list = widget.data.map(_row).toList();
    if (sortConditions.isEmpty) return list;
    list.sort((a, b) {
      for (final cond in sortConditions) {
        final field = cond['field'];
        final order = '${cond['order']}';
        final column =
            cond['column'] is Map ? _col(cond['column']) : <dynamic, dynamic>{};
        final sortBy = getColumnSortBy(column);
        final av = _sortValueBy(a, field, sortBy);
        final bv = _sortValueBy(b, field, sortBy);
        final cmp = _compareValues(av, bv);
        if (cmp != 0) {
          return (order == 'descending' || order == 'desc') ? -cmp : cmp;
        }
      }
      return 0;
    });
    return list;
  }

  List<_FlatRow> get flattenedSortedData {
    final result = <_FlatRow>[];
    void walk(List rows, Map? parent, int level) {
      for (var i = 0; i < rows.length; i++) {
        final row = _row(rows[i]);
        result.add(
          _FlatRow(row: row, level: level, parent: parent, rowIndex: i),
        );
        final children = row[_childrenKey];
        if (children is List && children.isNotEmpty && isExpanded(row)) {
          walk(children, row, level + 1);
        }
      }
    }

    walk(sortedData, null, 1);
    return result;
  }

  String _sortIcon(dynamic field) {
    Map? cond;
    for (final c in sortConditions) {
      if (c['field'] == field) {
        cond = c;
        break;
      }
    }
    if (cond == null) return '';
    final order = '${cond['order']}';
    if (order == 'ascending' || order == 'asc') return ' ↑';
    if (order == 'descending' || order == 'desc') return ' ↓';
    return '';
  }

  void handleHeaderClick(Map column) {
    widget.onHeaderClick?.call(column);
    if (!isColumnSortable(column)) return;
    final field = column['key'];
    final orders = getColumnSortOrders(column)
        .map((e) => '$e')
        .where((e) => e.isNotEmpty)
        .toList();
    if (orders.isEmpty) {
      orders.addAll(const ['ascending', 'descending']);
    }
    final index = sortConditions.indexWhere((c) => c['field'] == field);
    String? newOrder = orders.first;
    if (index >= 0) {
      final currentOrder = '${sortConditions[index]['order']}';
      final nextIndex = orders.indexOf(currentOrder) + 1;
      if (nextIndex > 0 && nextIndex < orders.length) {
        newOrder = orders[nextIndex];
      } else {
        setState(() => sortConditions.removeAt(index));
        widget.onSortChange?.call(List.from(sortConditions));
        return;
      }
    }

    setState(() {
      if (!widget.multiSort) {
        sortConditions
          ..clear()
          ..add({'field': field, 'order': newOrder, 'column': column});
      } else {
        if (index >= 0) {
          sortConditions[index] = {
            'field': field,
            'order': newOrder,
            'column': column,
          };
        } else {
          sortConditions
              .add({'field': field, 'order': newOrder, 'column': column});
        }
      }
    });
    widget.onSortChange?.call(List.from(sortConditions));
  }

  void handleRowClick(Map row) {
    if (widget.highlightCurrentRow) {
      final old = currentRow;
      setState(() => currentRow = row);
      widget.onCurrentChange?.call(row, old);
    }
    widget.onRowClick?.call(row);
  }

  void toggleSelect(Map row) {
    widget.onToggleSelect?.call(row);
    final key = _rowKeyOf(row);
    final index = selectedRows.indexWhere((r) => _rowKeyOf(r) == key);
    setState(() {
      if (index >= 0) {
        selectedRows.removeAt(index);
        _unselectChildren(row);
      } else {
        selectedRows.add(Map<dynamic, dynamic>.from(row));
        _selectChildren(row);
      }
    });
    widget.onSelectionChange?.call(List.from(selectedRows));
    widget.onSelect?.call(row);
  }

  /// Source public selection helpers.
  void selectChildren(Map row) {
    setState(() => _selectChildren(row));
    widget.onSelectionChange?.call(List.from(selectedRows));
  }

  void unselectChildren(Map row) {
    setState(() => _unselectChildren(row));
    widget.onSelectionChange?.call(List.from(selectedRows));
  }

  /// Source `loadLazyChildren`.
  void loadLazyChildren(Map row, [int level = 1]) =>
      _loadLazyChildren(row, level);

  /// Source `getSortIcon`.
  String getSortIcon([dynamic field]) => _sortIcon(field);

  /// Source `getSortValue`.
  dynamic getSortValue(dynamic row, [dynamic column]) =>
      getSortValueBy(row, column);

  /// Source style helpers.
  Map headerColStyle([dynamic column]) {
    final col = column is Map ? _col(column) : <dynamic, dynamic>{};
    return {
      'width': _colWidth(col),
      'field': col['field'] ?? col['key'] ?? col['prop'],
      'align': col['align'] ?? 'left',
    };
  }

  Map setCellStyle([dynamic row, dynamic column]) {
    return {
      'row': row is Map ? _rowKeyOf(row) : null,
      'column': column is Map
          ? (column['field'] ?? column['key'] ?? column['prop'])
          : column,
    };
  }

  void _selectChildren(Map row) {
    final children = row[_childrenKey];
    if (children is! List) return;
    for (final childRaw in children) {
      final child = _row(childRaw);
      final childKey = _rowKeyOf(child);
      final exists = selectedRows.any((r) => _rowKeyOf(r) == childKey);
      if (!exists) {
        selectedRows.add(Map<dynamic, dynamic>.from(child));
      }
      _selectChildren(child);
    }
  }

  void _unselectChildren(Map row) {
    final children = row[_childrenKey];
    if (children is! List) return;
    for (final childRaw in children) {
      final child = _row(childRaw);
      final childKey = _rowKeyOf(child);
      selectedRows.removeWhere((r) => _rowKeyOf(r) == childKey);
      _unselectChildren(child);
    }
  }

  void toggleSelectAll() {
    final flat = flattenedSortedData.map((e) => e.row).toList();
    final allSelected = flat.isNotEmpty && flat.every((row) => isSelected(row));
    setState(() {
      selectedRows.clear();
      if (!allSelected) {
        for (final row in flat) {
          selectedRows.add(Map<dynamic, dynamic>.from(row));
        }
      }
    });
    widget.onSelectionChange?.call(List.from(selectedRows));
    widget.onSelectAll?.call(List.from(selectedRows));
  }

  void clearSelection() {
    setState(() => selectedRows.clear());
    widget.onSelectionChange?.call(const []);
  }

  void setCurrentRow(Map? row) {
    final old = currentRow;
    setState(() =>
        currentRow = row == null ? null : Map<dynamic, dynamic>.from(row));
    widget.onCurrentChange?.call(currentRow, old);
  }

  void toggleExpand(Map row, [int level = 1]) {
    widget.onToggleExpand?.call(row);
    final key = _rowKeyOf(row);
    if (key == null) return;
    setState(() {
      if (expandedKeys.contains(key)) {
        expandedKeys.remove(key);
      } else {
        expandedKeys.add(key);
        _loadLazyChildren(row, level);
      }
    });
    widget.onExpandChange?.call(List.from(expandedKeys));
  }

  void expand(dynamic key) {
    if (key == null || expandedKeys.contains(key)) return;
    final row = _findRowByKey(widget.data, key);
    setState(() {
      expandedKeys.add(key);
      if (row != null) _loadLazyChildren(row, 1);
    });
    widget.onExpandChange?.call(List.from(expandedKeys));
  }

  void collapse(dynamic key) {
    if (key == null || !expandedKeys.contains(key)) return;
    setState(() => expandedKeys.remove(key));
    widget.onExpandChange?.call(List.from(expandedKeys));
  }

  void expandAll() {
    final keys = <dynamic>[];
    void walk(List rows) {
      for (final item in rows) {
        final row = _row(item);
        if (_hasExpandableChildren(row)) keys.add(_rowKeyOf(row));
        final children = row[_childrenKey];
        if (children is List) walk(children);
      }
    }

    walk(widget.data);
    setState(() {
      expandedKeys
        ..clear()
        ..addAll(keys.where((e) => e != null));
    });
    widget.onExpandChange?.call(List.from(expandedKeys));
  }

  void collapseAll() {
    setState(() => expandedKeys.clear());
    widget.onExpandChange?.call(const []);
  }

  void clearSort() {
    setState(() => sortConditions.clear());
    widget.onSortChange?.call(const []);
  }

  List getSelection() => List.from(selectedRows);
  List getSortConditions() => List.from(sortConditions);
  List getExpandedKeys() => List.from(expandedKeys);

  void _loadLazyChildren(Map row, int level) {
    if (!widget.lazy || widget.load == null) return;
    final key = _rowKeyOf(row);
    if (key == null) return;
    final children = row[_childrenKey];
    if ((children is List && children.isNotEmpty) ||
        lazyLoadingKeys.contains(key)) {
      return;
    }
    setState(() => lazyLoadingKeys.add(key));
    void resolve([List childrenList = const []]) {
      if (!mounted) return;
      setState(() {
        row[_childrenKey] = List.from(childrenList);
        lazyLoadingKeys.remove(key);
      });
    }

    widget.load!(
      row,
      {
        'row': row,
        'level': level,
        'expanded': isExpanded(row),
        'loading': true,
      },
      resolve,
    );
  }

  Color? _rowBg(Map row, int flatIndex) {
    if (widget.highlightCurrentRow &&
        currentRow != null &&
        _rowKeyOf(currentRow!) == _rowKeyOf(row)) {
      return UPThemeTokens.of(context).primary.withValues(alpha: 0.08);
    }
    if (widget.stripe && flatIndex.isOdd) {
      return const Color(0xFFFAFAFA);
    }
    return null;
  }

  Map<String, dynamic> _styleMap(Map style) {
    return style.map((key, value) => MapEntry('$key', value));
  }

  double _stylePx(dynamic value, double fallback) {
    if (value == null || '$value'.trim().isEmpty || '$value' == 'auto') {
      return fallback;
    }
    final px = UPUtils.getPx(value);
    return px > 0 ? px : fallback;
  }

  FontWeight _fontWeight(dynamic value, FontWeight fallback) {
    if (value is FontWeight) return value;
    final text = '${value ?? ''}'.toLowerCase();
    if (text == 'bold' || text == 'bolder') return FontWeight.w700;
    final weight = int.tryParse(text);
    if (weight == null) return fallback;
    if (weight <= 100) return FontWeight.w100;
    if (weight <= 200) return FontWeight.w200;
    if (weight <= 300) return FontWeight.w300;
    if (weight <= 400) return FontWeight.w400;
    if (weight <= 500) return FontWeight.w500;
    if (weight <= 600) return FontWeight.w600;
    if (weight <= 700) return FontWeight.w700;
    if (weight <= 800) return FontWeight.w800;
    return FontWeight.w900;
  }

  TextAlign _textAlign(dynamic value, TextAlign fallback) {
    switch ('${value ?? ''}'.toLowerCase()) {
      case 'center':
        return TextAlign.center;
      case 'right':
      case 'end':
        return TextAlign.right;
      case 'left':
      case 'start':
        return TextAlign.left;
      default:
        return fallback;
    }
  }

  Alignment _alignmentFor(TextAlign align) {
    switch (align) {
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.right:
      case TextAlign.end:
        return Alignment.centerRight;
      default:
        return Alignment.centerLeft;
    }
  }

  double _columnOffset(List<Map> columns, int columnIndex) {
    var offset = 0.0;
    for (var index = 0; index < columnIndex; index++) {
      offset += _colWidth(columns[index]);
    }
    return offset;
  }

  double _spannedWidth(List<Map> columns, int columnIndex, int columnSpan) {
    var width = 0.0;
    final end = (columnIndex + columnSpan).clamp(0, columns.length);
    for (var index = columnIndex; index < end; index++) {
      width += _colWidth(columns[index]);
    }
    return width > 0 ? width : _colWidth(columns[columnIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final cols = widget.columns.map(_col).toList();
    final flat = flattenedSortedData;
    final rh = UPUtils.getPx(widget.rowHeight);
    final h = widget.height == null ? null : UPUtils.getPx(widget.height);
    final maxH =
        widget.maxHeight == null ? null : UPUtils.getPx(widget.maxHeight);
    final expandW = UPUtils.getPx(widget.expandWidth);
    final treeEnabled = hasTree;
    final mainColKey = computedMainCol;
    final allVisibleSelected =
        flat.isNotEmpty && flat.every((item) => isSelected(item.row));
    final naturalBodyHeight = flat.isEmpty
        ? 80.0
        : flat.fold<double>(
            0,
            (sum, item) =>
                sum +
                _stylePx(
                  _styleMap(getRowStyle(
                    item.row,
                    item.rowIndex,
                    item.level,
                    item.parent,
                  ))['height'],
                  rh,
                ),
          );
    final naturalTableHeight = (widget.showHeader ? rh : 0) + naturalBodyHeight;
    final fixedLayerHeight = h ??
        (maxH == null || naturalTableHeight <= maxH
            ? naturalTableHeight
            : maxH);

    Widget cellContent({
      required Map col,
      required String text,
      required bool header,
      int level = 1,
      Map? row,
      bool showExpand = false,
      bool expanded = false,
      bool loading = false,
      VoidCallback? onExpand,
      Map effectiveStyle = const <String, dynamic>{},
      Map rowStyle = const <String, dynamic>{},
      double? width,
      double? height,
      Key? cellKey,
      Widget? child,
    }) {
      final style = _styleMap(effectiveStyle);
      final inherited = _styleMap(rowStyle);
      final baseAlign = _textAlign(
        col[header ? 'headerAlign' : 'align'] ?? col['align'] ?? 'left',
        TextAlign.left,
      );
      final textAlign = _textAlign(
        style['textAlign'] ?? inherited['textAlign'],
        baseAlign,
      );
      final alignment = _alignmentFor(textAlign);
      final padLeft = (!header && treeEnabled && '${col['key']}' == mainColKey)
          ? (style['paddingLeft'] is num
              ? (style['paddingLeft'] as num).toDouble()
              : (16.0 * (level - 1)) + 2)
          : 8.0;
      final defaultColor = header ? tokens.mainColor : tokens.contentColor;
      final color = UPUtils.parseColor(style['color']) ??
          UPUtils.parseColor(inherited['color']) ??
          defaultColor;
      final fontSize = _stylePx(
        style['fontSize'] ?? inherited['fontSize'],
        header ? 13 : 13,
      );
      final fontWeight = _fontWeight(
        style['fontWeight'] ?? inherited['fontWeight'],
        header ? FontWeight.w600 : FontWeight.normal,
      );
      final cellWidth = _stylePx(style['width'], width ?? _colWidth(col));
      final cellHeight = _stylePx(style['height'], height ?? rh);
      final background = UPUtils.parseColor(style['backgroundColor']);
      return Container(
        key: cellKey,
        width: cellWidth,
        height: cellHeight,
        alignment: alignment,
        padding: EdgeInsets.only(left: padLeft, right: 8),
        decoration: BoxDecoration(
          color: background ?? (header ? const Color(0xFFF5F7FA) : null),
          border: widget.border
              ? Border(
                  right: BorderSide(color: tokens.borderColor, width: 0.5),
                  bottom: BorderSide(color: tokens.borderColor, width: 0.5),
                )
              : null,
        ),
        child: child ??
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (showExpand)
                  GestureDetector(
                    key: ValueKey(
                        'up-table2-expand-${row == null ? '' : row[widget.rowKey]}'),
                    behavior: HitTestBehavior.opaque,
                    onTap: onExpand,
                    child: SizedBox(
                      width: expandW > 0 ? expandW : 25,
                      height: rh,
                      child: Center(
                        child: Text(
                          loading ? '...' : (expanded ? 'v' : '>'),
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  )
                else if (!header &&
                    treeEnabled &&
                    '${col['key']}' == mainColKey)
                  SizedBox(width: expandW > 0 ? expandW : 25),
                Expanded(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: textAlign,
                    style: TextStyle(
                      color: color,
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                    ),
                  ),
                ),
              ],
            ),
      );
    }

    final header = widget.showHeader
        ? Row(
            children: [
              for (var ci = 0; ci < cols.length; ci++)
                Builder(
                  builder: (context) {
                    final col = cols[ci];
                    final type = '${col['type'] ?? 'default'}';
                    if (type == 'selection') {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: toggleSelectAll,
                        child: Container(
                          width: _colWidth(col),
                          height: rh,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FA),
                            border: widget.border
                                ? Border(
                                    right: BorderSide(
                                        color: tokens.borderColor, width: 0.5),
                                    bottom: BorderSide(
                                        color: tokens.borderColor, width: 0.5),
                                  )
                                : null,
                          ),
                          child: Text(
                            allVisibleSelected ? '☑' : '☐',
                            style: TextStyle(
                              color: tokens.primary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }
                    final title =
                        '${col['title'] ?? ''}${isColumnSortable(col) ? (_sortIcon(col['key']).isEmpty ? ' ↕' : _sortIcon(col['key'])) : ''}';
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => handleHeaderClick(col),
                      child: cellContent(
                        col: col,
                        text: title,
                        header: true,
                      ),
                    );
                  },
                ),
            ],
          )
        : const SizedBox.shrink();

    final body = flat.isEmpty
        ? Container(
            height: 80,
            alignment: Alignment.center,
            child: Text(
              widget.emptyText,
              style: TextStyle(color: tokens.tipsColor, fontSize: 13),
            ),
          )
        : Builder(
            builder: (context) {
              final tableWidth = cols.fold<double>(
                0,
                (sum, col) => sum + _colWidth(col),
              );
              final rowStyles = <Map<String, dynamic>>[];
              final rowHeights = <double>[];
              for (final item in flat) {
                final style = _styleMap(
                  getRowStyle(item.row, item.rowIndex, item.level, item.parent),
                );
                rowStyles.add(style);
                rowHeights.add(_stylePx(style['height'], rh));
              }
              final rowOffsets = <double>[];
              var totalHeight = 0.0;
              for (final height in rowHeights) {
                rowOffsets.add(totalHeight);
                totalHeight += height;
              }

              return SizedBox(
                width: tableWidth,
                height: totalHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (var i = 0; i < flat.length; i++)
                      Builder(
                        builder: (context) {
                          final item = flat[i];
                          final row = item.row;
                          final rowStyle = rowStyles[i];
                          final rowHeight = rowHeights[i];
                          final rowBackground =
                              UPUtils.parseColor(rowStyle['backgroundColor']) ??
                                  _rowBg(row, i);
                          final rowWidth =
                              _stylePx(rowStyle['width'], tableWidth);
                          return Positioned(
                            top: rowOffsets[i],
                            left: 0,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => handleRowClick(row),
                              onDoubleTap: widget.onRowDblclick == null
                                  ? null
                                  : () => widget.onRowDblclick?.call(row),
                              child: Container(
                                key: ValueKey('up-table2-row-$i'),
                                width: rowWidth,
                                height: rowHeight,
                                decoration: BoxDecoration(color: rowBackground),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    for (var ci = 0; ci < cols.length; ci++)
                                      Builder(
                                        builder: (context) {
                                          final col = cols[ci];
                                          final span = getCellSpan(
                                            row,
                                            col,
                                            item.rowIndex,
                                            ci,
                                          );
                                          final rowSpan = int.tryParse(
                                                  '${span['rowspan']}') ??
                                              1;
                                          final columnSpan = int.tryParse(
                                                  '${span['colspan']}') ??
                                              1;
                                          if (rowSpan == 0 || columnSpan == 0) {
                                            return const SizedBox.shrink();
                                          }
                                          final spanStyle =
                                              _styleMap(getCellSpanStyle(
                                            row,
                                            col,
                                            item.rowIndex,
                                            ci,
                                          ));
                                          final effectiveStyle =
                                              _styleMap(cellStyleInner(
                                            col,
                                            row,
                                            item.rowIndex,
                                            ci,
                                            item.level,
                                          ))
                                                ..addAll(spanStyle);
                                          final cellWidth = _spannedWidth(
                                            cols,
                                            ci,
                                            columnSpan < 1 ? 1 : columnSpan,
                                          );
                                          // Flutter uses explicit geometry for merged cells;
                                          // retain source's flex helper in the public style map.
                                          if (columnSpan > 1) {
                                            effectiveStyle['width'] = cellWidth;
                                          }
                                          final cellHeight = _stylePx(
                                            spanStyle['height'],
                                            rowSpan > 1
                                                ? rh * rowSpan
                                                : rowHeight,
                                          );
                                          final type =
                                              '${col['type'] ?? 'default'}';
                                          final selection = type == 'selection';
                                          final isMain =
                                              '${col['key']}' == mainColKey;
                                          final expandable = treeEnabled &&
                                              isMain &&
                                              _hasExpandableChildren(row);
                                          return Positioned(
                                            top: 0,
                                            left: _columnOffset(cols, ci),
                                            child: GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onTap: selection
                                                  ? () => toggleSelect(row)
                                                  : () =>
                                                      widget.onCellClick?.call(
                                                        row,
                                                        col,
                                                        item.rowIndex,
                                                        ci,
                                                      ),
                                              child: cellContent(
                                                cellKey: ValueKey(
                                                  'up-table2-cell-$i-$ci',
                                                ),
                                                col: col,
                                                text:
                                                    '${row[col['key']] ?? ''}',
                                                header: false,
                                                level: item.level,
                                                row: row,
                                                rowStyle: rowStyle,
                                                effectiveStyle: effectiveStyle,
                                                width: cellWidth,
                                                height: cellHeight,
                                                showExpand: expandable,
                                                expanded: isExpanded(row),
                                                loading: isLazyLoading(row),
                                                onExpand: expandable
                                                    ? () => toggleExpand(
                                                          row,
                                                          item.level,
                                                        )
                                                    : null,
                                                child: selection
                                                    ? Text(
                                                        isSelected(row)
                                                            ? '☑'
                                                            : '☐',
                                                        style: TextStyle(
                                                          color: UPUtils
                                                                  .parseColor(
                                                                effectiveStyle[
                                                                    'color'],
                                                              ) ??
                                                              UPUtils
                                                                  .parseColor(
                                                                rowStyle[
                                                                    'color'],
                                                              ) ??
                                                              tokens.primary,
                                                          fontSize: _stylePx(
                                                            effectiveStyle[
                                                                'fontSize'],
                                                            16,
                                                          ),
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          );

    final fixedLeft = cols.where((c) => '${c['fixed']}' == 'left').toList();

    final naturalTable = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        body,
      ],
    );

    final tableWidth = cols.fold<double>(
      0,
      (sum, col) => sum + _colWidth(col),
    );
    final fixedWidth = fixedLeft.fold<double>(
      0,
      (sum, col) => sum + _colWidth(col),
    );
    final constrainedHeight =
        h ?? (maxH == null || naturalTableHeight <= maxH ? null : maxH);
    final useFixedHeaderLayout =
        widget.fixedHeader && constrainedHeight != null;

    Widget fixedOverlay({required Widget child}) => Positioned(
          left: 0,
          top: 0,
          child: Container(
            key: const ValueKey('up-table2-fixed-left'),
            width: fixedWidth,
            height: fixedLayerHeight,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              boxShadow: [
                BoxShadow(
                  color: tokens.borderColor.withValues(alpha: 0.45),
                  offset: const Offset(2, 0),
                  blurRadius: 4,
                ),
              ],
            ),
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.topLeft,
                minWidth: tableWidth,
                maxWidth: tableWidth,
                minHeight: 0,
                maxHeight: fixedLayerHeight,
                child: child,
              ),
            ),
          ),
        );

    Widget content;
    if (useFixedHeaderLayout) {
      final mainTable = SizedBox(
        width: tableWidth,
        height: constrainedHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            Expanded(
              child: SingleChildScrollView(
                key: const ValueKey('up-table2-vertical-scroll'),
                controller: _verticalController,
                child: body,
              ),
            ),
          ],
        ),
      );
      final fixedTable = SizedBox(
        width: tableWidth,
        height: constrainedHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            Expanded(
              child: ClipRect(
                child: Transform.translate(
                  offset: Offset(0, -_verticalScrollOffset),
                  child: body,
                ),
              ),
            ),
          ],
        ),
      );
      content = SizedBox(
        height: constrainedHeight,
        child: Stack(
          children: [
            SingleChildScrollView(
              key: const ValueKey('up-table2-horizontal-scroll'),
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: mainTable,
            ),
            if (fixedLeft.isNotEmpty && showFixedColumnShadow)
              fixedOverlay(child: fixedTable),
          ],
        ),
      );
    } else {
      content = Stack(
        children: [
          SingleChildScrollView(
            key: const ValueKey('up-table2-horizontal-scroll'),
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: naturalTable,
          ),
          if (fixedLeft.isNotEmpty && showFixedColumnShadow)
            fixedOverlay(child: naturalTable),
        ],
      );
    }

    if (!useFixedHeaderLayout && (h != null || maxH != null)) {
      content = SizedBox(
        height: h,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH ?? double.infinity),
          child: SingleChildScrollView(child: content),
        ),
      );
    }

    Widget root = Container(
      decoration: widget.border
          ? BoxDecoration(
              border: Border.all(color: tokens.borderColor, width: 0.5),
            )
          : null,
      child: content,
    );
    return root;
  }
}
