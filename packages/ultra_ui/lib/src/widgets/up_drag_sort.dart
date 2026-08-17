import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Port of u-dragsort / up-dragsort (reorderable list / grid).
class UPDragSort extends StatefulWidget {
  const UPDragSort({
    super.key,
    required this.initialList,
    this.draggable = true,
    this.vibrate = true,
    this.direction = 'vertical',
    this.columns = 3,
    this.itemBuilder,
    this.handlerBuilder,
    this.onDragEnd,
    this.customStyle,
  });

  final List initialList;
  final bool draggable;
  final bool vibrate;

  /// `vertical` | `horizontal` | `all`
  final String direction;
  final int columns;
  final Widget Function(BuildContext context, dynamic item, int index)?
      itemBuilder;

  /// Slot: handler. When provided, only the handler starts a drag.
  final Widget Function(BuildContext context, dynamic item, int index)?
      handlerBuilder;
  final ValueChanged<List>? onDragEnd;
  final BoxDecoration? customStyle;

  /// Source computed: movableAreaStyle.
  dynamic get movableAreaStyle => <String, dynamic>{
        'width': '100%',
      };

  /// Source method: calculateAreaSize.
  dynamic calculateAreaSize([dynamic v]) {
    if (v is Map) {
      return <String, dynamic>{
        'width': v['width'] ?? areaWidth,
        'height': v['height'] ?? areaHeight,
      };
    }
    if (v != null) return v;
    return <String, dynamic>{
      'width': areaWidth,
      'height': areaHeight,
    };
  }

  /// Source method: calculateItemSize.
  dynamic calculateItemSize([dynamic v]) {
    if (v is Map) {
      return <String, dynamic>{
        'width': v['width'] ?? itemWidth,
        'height': v['height'] ?? itemHeight,
      };
    }
    if (v != null) return v;
    return <String, dynamic>{
      'width': itemWidth,
      'height': itemHeight,
    };
  }

  /// Source data defaults.
  dynamic get areaHeight => 0;
  dynamic get areaWidth => 0;
  dynamic get currentPosition => const <String, dynamic>{'x': 0, 'y': 0};
  dynamic get dragIndex => -1;
  dynamic get itemHeight => 0;
  dynamic get itemWidth => 0;
  dynamic get sortChanged => false;

  @override
  State<UPDragSort> createState() => UPDragSortState();
}

class UPDragSortState extends State<UPDragSort> {
  late List list;
  String touchPhase = 'idle';
  bool allMode = false;
  List positions = const [];
  double areaHeight = 0;
  double areaWidth = 0;
  double itemHeight = 0;
  double itemWidth = 0;
  bool sortChanged = false;
  Map<String, dynamic> currentPosition = const <String, dynamic>{
    'x': 0,
    'y': 0
  };
  int dragIndex = -1;
  Timer? _dragEndTimer;
  Timer? _dragIndexTimer;

  /// Source-compatible current list snapshot.
  List get value => List.from(list);

  /// Replace list contents.
  void setValue(List next, {bool emit = true}) {
    setState(() => list = List.from(next));
    if (emit) widget.onDragEnd?.call(List.from(list));
  }

  /// Source `initList`: copy source items and initialize their coordinates.
  void initList([List? source]) {
    final next = List<dynamic>.from(source ?? widget.initialList);
    setState(() {
      list = [
        for (var index = 0; index < next.length; index++)
          _itemWithPosition(next[index], index),
      ];
      updatePositions();
    });
  }

  /// Source `handleAllModeChange(index)`, with its existing host-mode helper
  /// retained for non-index invocations.
  void handleAllModeChange([dynamic indexOrEnabled]) {
    if (indexOrEnabled is int && widget.direction == 'all') {
      if (itemWidth <= 0 || itemHeight <= 0 || list.isEmpty) return;
      final columns = widget.columns.clamp(1, 12);
      final column =
          (currentPosition['x']! / itemWidth).round().clamp(0, columns - 1);
      final row =
          (currentPosition['y']! / itemHeight).round().clamp(0, 1 << 30);
      final target = (row * columns + column).clamp(0, list.length - 1);
      if (target != indexOrEnabled) reorderItems(indexOrEnabled, target);
      return;
    }
    if (indexOrEnabled is bool) {
      allMode = indexOrEnabled;
    } else if (indexOrEnabled == null) {
      allMode = !allMode;
    } else {
      allMode = '$indexOrEnabled' == 'true' ||
          '$indexOrEnabled' == '1' ||
          '$indexOrEnabled' == 'all';
    }
    if (mounted) setState(() {});
  }

  /// Source `onChange(index, event)`, retaining the old list helper form.
  void onChange([dynamic indexOrNext, dynamic event]) {
    if (indexOrNext is List && event == null) {
      setValue(indexOrNext);
      return;
    }
    if (indexOrNext is! int || event is! Map) return;
    final detail = event['detail'];
    if (detail is! Map || detail['source'] != 'touch') return;
    final x = _number(detail['x']) ?? 0;
    final y = _number(detail['y']) ?? 0;
    currentPosition = {'x': x, 'y': y};
    if (widget.direction == 'all') {
      handleAllModeChange(indexOrNext);
      return;
    }
    final itemSize = widget.direction == 'horizontal' ? itemWidth : itemHeight;
    if (itemSize <= 0 || list.isEmpty) return;
    final coordinate = widget.direction == 'horizontal' ? x : y;
    final target = (coordinate / itemSize).round().clamp(0, list.length - 1);
    if (target != indexOrNext) reorderItems(indexOrNext, target);
  }

  /// Source `reorderItems`: update positions but defer `drag-end` to touch end.
  void reorderItems(int from, int to) {
    if (from < 0 || from >= list.length || to < 0 || to >= list.length) return;
    if (from == to || !_itemDraggable(list[from])) return;
    setState(() {
      final item = list.removeAt(from);
      list.insert(to, item);
      dragIndex = to;
      sortChanged = true;
      updatePositions(true);
    });
    if (widget.vibrate) HapticFeedback.selectionClick();
  }

  void updatePositions([dynamic isDragging]) {
    if (isDragging is List) {
      positions = List.from(isDragging);
      return;
    }
    final preserveDragged = isDragging == true;
    final columns = widget.columns.clamp(1, 12);
    list = [
      for (var index = 0; index < list.length; index++)
        if (preserveDragged && dragIndex == index)
          list[index]
        else
          _itemWithPosition(list[index], index),
    ];
    positions = [
      for (var index = 0; index < list.length; index++)
        {
          'index': index,
          'item': list[index],
          'x': widget.direction == 'horizontal'
              ? index * itemWidth
              : widget.direction == 'all'
                  ? (index % columns) * itemWidth
                  : 0,
          'y': widget.direction == 'vertical'
              ? index * itemHeight
              : widget.direction == 'all'
                  ? (index ~/ columns) * itemHeight
                  : 0,
        },
    ];
  }

  /// Source `onTouchStart(index, event)`, retaining one-argument host calls.
  void onTouchStart([dynamic indexOrEvent, dynamic event]) {
    touchPhase = 'start';
    if (indexOrEvent is int) {
      final currentTarget = event is Map ? event['currentTarget'] : null;
      final dataset = currentTarget is Map ? currentTarget['dataset'] : null;
      if (widget.handlerBuilder != null &&
          (dataset is! Map || dataset['action'] != 'handler')) {
        return;
      }
      if (indexOrEvent < 0 ||
          indexOrEvent >= list.length ||
          !_itemDraggable(list[indexOrEvent])) {
        return;
      }
      _dragIndexTimer?.cancel();
      setState(() {
        sortChanged = false;
        dragIndex = indexOrEvent;
      });
      return;
    }
    if (indexOrEvent is Offset) {
      currentPosition = {'x': indexOrEvent.dx, 'y': indexOrEvent.dy};
    } else if (indexOrEvent is Map) {
      currentPosition = {
        'x': _number(indexOrEvent['x'] ?? indexOrEvent['dx']) ?? 0,
        'y': _number(indexOrEvent['y'] ?? indexOrEvent['dy']) ?? 0,
      };
    }
  }

  void onTouchMove([dynamic _]) {
    touchPhase = 'move';
    if (_ is Offset) {
      currentPosition = {'x': _.dx, 'y': _.dy};
    } else if (_ is Map) {
      currentPosition = {
        'x': _['x'] ?? _['dx'] ?? 0,
        'y': _['y'] ?? _['dy'] ?? 0,
      };
    }
  }

  void onTouchEnd([dynamic _]) {
    touchPhase = 'end';
    if (dragIndex == -1) return;
    final activeIndex = dragIndex;
    final current = list[activeIndex];
    if (current is Map) {
      final moved = Map<dynamic, dynamic>.from(current);
      if (widget.direction == 'horizontal') {
        moved['x'] = (currentPosition['x'] ?? 0) + 0.001;
      } else {
        moved['x'] = (currentPosition['x'] ?? 0) + 0.001;
        moved['y'] = (currentPosition['y'] ?? 0) + 0.001;
      }
      setState(() => list[activeIndex] = moved);
    }
    _scheduleTouchEndSettlement();
  }

  void _scheduleTouchEndSettlement() {
    _dragEndTimer?.cancel();
    _dragEndTimer = Timer(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      setState(() {
        updatePositions();
        if (sortChanged) {
          widget.onDragEnd?.call(List.from(list));
          sortChanged = false;
        }
      });
      _dragIndexTimer?.cancel();
      _dragIndexTimer = Timer(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => dragIndex = -1);
      });
    });
  }

  void measureLayout() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    areaWidth = box.size.width;
    areaHeight = box.size.height;
    if (list.isEmpty) {
      itemWidth = areaWidth;
      itemHeight = 0;
    } else if (widget.direction == 'all') {
      final columns = widget.columns.clamp(1, 12);
      final rows = (list.length / columns).ceil();
      itemWidth = areaWidth / columns;
      itemHeight = rows == 0 ? 0 : areaHeight / rows;
    } else {
      itemWidth = areaWidth;
      itemHeight = areaHeight / list.length;
    }
    updatePositions();
  }

  Future<void> sleep([int ms = 0]) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
  }

  void reset([List? source]) {
    initList(source);
  }

  void move(int from, int to, {bool emit = true}) {
    if (from < 0 || from >= list.length) return;
    if (to < 0 || to >= list.length) return;
    if (from == to) return;
    if (!_itemDraggable(list[from])) return;
    setState(() {
      final item = list.removeAt(from);
      list.insert(to, item);
      sortChanged = true;
      dragIndex = to;
      updatePositions(true);
    });
    if (widget.vibrate) {
      HapticFeedback.selectionClick();
    }
    if (emit) widget.onDragEnd?.call(List.from(list));
  }

  void insert(int index, dynamic item, {bool emit = true}) {
    final i = index.clamp(0, list.length);
    setState(() => list.insert(i, item));
    if (emit) widget.onDragEnd?.call(List.from(list));
  }

  void removeAt(int index, {bool emit = true}) {
    if (index < 0 || index >= list.length) return;
    setState(() => list.removeAt(index));
    if (emit) widget.onDragEnd?.call(List.from(list));
  }

  @override
  void initState() {
    super.initState();
    list = <dynamic>[];
    initList();
  }

  @override
  void didUpdateWidget(covariant UPDragSort oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialList != widget.initialList) {
      initList();
    }
    if (oldWidget.direction != widget.direction) {
      initList();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) measureLayout();
      });
    } else if (oldWidget.columns != widget.columns &&
        widget.direction == 'all') {
      initList();
      updatePositions();
    }
  }

  double? _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value');
  }

  dynamic _itemWithPosition(dynamic item, int index) {
    if (item is! Map) return item;
    if (widget.direction == 'horizontal' && itemWidth > 0) {
      return Map<dynamic, dynamic>.from(item)
        ..['x'] = index * itemWidth
        ..['y'] = 0;
    }
    if (widget.direction == 'vertical' && itemHeight > 0) {
      return Map<dynamic, dynamic>.from(item)
        ..['x'] = 0
        ..['y'] = index * itemHeight;
    }
    if (widget.direction == 'all' && itemWidth > 0 && itemHeight > 0) {
      final columns = widget.columns.clamp(1, 12);
      return Map<dynamic, dynamic>.from(item)
        ..['x'] = (index % columns) * itemWidth
        ..['y'] = (index ~/ columns) * itemHeight;
    }
    return Map<dynamic, dynamic>.from(item)
      ..['x'] = null
      ..['y'] = null;
  }

  bool _itemDraggable(dynamic item) {
    if (!widget.draggable) return false;
    if (item is Map && item['draggable'] == false) return false;
    return true;
  }

  Widget _defaultItem(dynamic item, int index) {
    // Source fallback slot renders only `item.label`.
    final text = item is Map && item['label'] != null ? '${item['label']}' : '';
    return Text(text);
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (!_itemDraggable(list[oldIndex])) return;
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);
      sortChanged = true;
      dragIndex = newIndex;
    });
    if (widget.vibrate) {
      HapticFeedback.selectionClick();
    }
    widget.onDragEnd?.call(List.from(list));
  }

  bool _reorderGridItem(int from, int to) {
    if (from < 0 || from >= list.length || to < 0 || to >= list.length) {
      return false;
    }
    if (from == to || !_itemDraggable(list[from])) return false;
    setState(() {
      final item = list.removeAt(from);
      list.insert(to, item);
      dragIndex = to;
      sortChanged = true;
      updatePositions();
    });
    if (widget.vibrate) {
      HapticFeedback.selectionClick();
    }
    // In Flutter's accepted-drag path the target callback can occur without
    // LongPressDraggable.onDragEnd. Treat acceptance as the source touch-end
    // boundary and reuse its delayed one-shot settlement.
    touchPhase = 'end';
    _scheduleTouchEndSettlement();
    return true;
  }

  void _startGridDrag(int index) {
    if (!_itemDraggable(list[index])) return;
    setState(() {
      dragIndex = index;
      sortChanged = false;
    });
    onTouchStart();
  }

  void _updateGridDrag(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox?;
    final position =
        box?.globalToLocal(details.globalPosition) ?? details.globalPosition;
    onTouchMove(position);
  }

  void _finishGridDrag() {
    // Flutter can invoke onDragEnd before the target accepts the item. Keep
    // the source drag state alive until onTouchEnd's delayed settlement so a
    // later target reorder is included in the one drag-end emission.
    onTouchEnd();
  }

  Key _keyFor(int index, dynamic item) =>
      ValueKey('ds-$index-${identityHashCode(item)}-$item');

  Widget _content(
    BuildContext context,
    int index, {
    Widget? body,
    Widget? handler,
  }) {
    final item = list[index];
    final resolvedBody = body ??
        widget.itemBuilder?.call(context, item, index) ??
        _defaultItem(item, index);
    final resolvedHandler =
        handler ?? widget.handlerBuilder?.call(context, item, index);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffffffff),
        border: Border.all(
          color: const Color.fromRGBO(125, 126, 128, 0.35),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: resolvedHandler == null
          ? resolvedBody
          : Row(
              children: [
                resolvedHandler,
                Expanded(child: resolvedBody),
              ],
            ),
    );
  }

  Widget _buildStatic(BuildContext context) {
    if (widget.direction == 'horizontal') {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < list.length; i++)
              KeyedSubtree(
                  key: _keyFor(i, list[i]), child: _content(context, i)),
          ],
        ),
      );
    }
    if (widget.direction == 'all') {
      final cols = widget.columns.clamp(1, 12);
      return LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth.isFinite
              ? constraints.maxWidth / cols
              : MediaQuery.sizeOf(context).width / cols;
          return Wrap(
            children: [
              for (var i = 0; i < list.length; i++)
                SizedBox(
                  width: w,
                  child: KeyedSubtree(
                    key: _keyFor(i, list[i]),
                    child: _content(context, i),
                  ),
                ),
            ],
          );
        },
      );
    }
    return Column(
      children: [
        for (var i = 0; i < list.length; i++)
          KeyedSubtree(key: _keyFor(i, list[i]), child: _content(context, i)),
      ],
    );
  }

  Widget _buildGridDraggable(BuildContext context) {
    final columns = widget.columns.clamp(1, 12);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final cellWidth = width / columns;
        return Wrap(
          children: [
            for (var index = 0; index < list.length; index++)
              SizedBox(
                width: cellWidth,
                child: _buildGridDropTarget(context, index, cellWidth),
              ),
          ],
        );
      },
    );
  }

  Widget _buildGridDropTarget(
    BuildContext context,
    int index,
    double cellWidth,
  ) {
    final item = list[index];
    final handler = widget.handlerBuilder?.call(context, item, index);
    final body = widget.itemBuilder?.call(context, item, index) ??
        _defaultItem(item, index);

    Widget gridContent;
    if (handler == null) {
      gridContent = _gridDraggable(
        context,
        index,
        cellWidth,
        child: _content(context, index, body: body),
      );
    } else {
      gridContent = _content(
        context,
        index,
        body: body,
        handler: _gridDraggable(
          context,
          index,
          cellWidth,
          child: handler,
        ),
      );
    }

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) =>
          details.data != index &&
          details.data >= 0 &&
          details.data < list.length &&
          _itemDraggable(list[details.data]),
      onAcceptWithDetails: (details) {
        _reorderGridItem(details.data, index);
      },
      builder: (context, candidateData, rejectedData) => KeyedSubtree(
        key: _keyFor(index, item),
        child: gridContent,
      ),
    );
  }

  Widget _gridDraggable(
    BuildContext context,
    int index,
    double cellWidth, {
    required Widget child,
  }) {
    if (!_itemDraggable(list[index])) return child;
    return LongPressDraggable<int>(
      data: index,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: cellWidth,
          child: IgnorePointer(child: _content(context, index)),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: child),
      onDragStarted: () => _startGridDrag(index),
      onDragUpdate: _updateGridDrag,
      onDragEnd: (_) => _finishGridDrag(),
      child: child,
    );
  }

  Widget _buildReorderable(BuildContext context) {
    final horizontal = widget.direction == 'horizontal';
    final listView = ReorderableListView.builder(
      scrollDirection: horizontal ? Axis.horizontal : Axis.vertical,
      shrinkWrap: !horizontal,
      physics: horizontal
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: widget.handlerBuilder == null,
      itemCount: list.length,
      onReorder: _onReorder,
      itemBuilder: (context, index) {
        final key = _keyFor(index, list[index]);
        final item = list[index];
        final body = widget.itemBuilder?.call(context, item, index) ??
            _defaultItem(item, index);
        final handler = widget.handlerBuilder?.call(context, item, index);
        if (handler != null) {
          return KeyedSubtree(
            key: key,
            child: _content(
              context,
              index,
              body: body,
              handler: ReorderableDragStartListener(
                index: index,
                enabled: _itemDraggable(item),
                child: handler,
              ),
            ),
          );
        }
        return KeyedSubtree(
          key: key,
          child: _content(context, index, body: body),
        );
      },
    );

    if (horizontal) {
      return SizedBox(height: 56, child: listView);
    }
    return listView;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      measureLayout();
    });
    Widget root = widget.draggable
        ? widget.direction == 'all'
            ? _buildGridDraggable(context)
            : _buildReorderable(context)
        : _buildStatic(context);
    return root;
  }

  @override
  void dispose() {
    _dragEndTimer?.cancel();
    _dragIndexTimer?.cancel();
    super.dispose();
  }
}
