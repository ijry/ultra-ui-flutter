import 'package:flutter/widgets.dart';

import '../utils/up_utils.dart';

/// 1:1-oriented port of u-virtual-list's fixed-height virtualization.
class UPVirtualList extends StatefulWidget {
  const UPVirtualList({
    super.key,
    this.listData = const [],
    this.itemHeight = 50,
    this.height = '100%',
    this.buffer = 4,
    this.keyField = 'id',
    this.scrollTop = 0,
    this.itemHeightBuilder,
    this.itemBuilder,
    this.onScroll,
    this.onUpdateScrollTop,
    this.customStyle,
  });

  final List listData;
  final double itemHeight;
  final dynamic height;
  final int buffer;
  final String keyField;
  final double scrollTop;
  final double Function(dynamic item, int index)? itemHeightBuilder;
  final Widget Function(BuildContext context, dynamic item, int index)?
      itemBuilder;
  final ValueChanged<double>? onScroll;
  final ValueChanged<double>? onUpdateScrollTop;
  final BoxDecoration? customStyle;

  /// Source computed: topPlaceholderHeight (startIndex defaults 0).
  dynamic get topPlaceholderHeight => 0 * itemHeight;

  /// Source computed: bottomPlaceholderHeight.
  dynamic get bottomPlaceholderHeight {
    final remain = listData.length;
    // without state startIndex, approximate full list as bottom placeholder.
    return remain * itemHeight;
  }

  @override
  State<UPVirtualList> createState() => UPVirtualListState();
}

class UPVirtualListState extends State<UPVirtualList> {
  late final ScrollController controller;
  double containerHeight = 0;
  int startIndex = 0;
  late List<double> _heights;
  late List<double> _offsets;

  double get scrollOffset =>
      controller.hasClients ? controller.offset : widget.scrollTop;
  int get firstVisibleIndex => startIndex;

  /// Source computed placeholders using current window.
  double get topPlaceholderHeight {
    if (_offsets.isEmpty) return 0;
    final start = startIndex.clamp(0, _offsets.length - 1);
    return start < _offsets.length ? _offsets[start] : 0.0;
  }

  double get bottomPlaceholderHeight {
    if (_offsets.isEmpty) return 0;
    final total = _offsets.last;
    final end = _windowEnd;
    final bottom = total - (end < _offsets.length ? _offsets[end] : total);
    return bottom < 0 ? 0.0 : bottom;
  }

  /// Source `visibleItems` (Batch K).
  List get visibleItems {
    if (widget.listData.isEmpty) return const [];
    return [
      for (var i = _windowStart; i < _windowEnd; i++) _itemWithIndex(i),
    ];
  }

  double get totalHeight => _offsets.isEmpty ? 0.0 : _offsets.last;

  int get lastVisibleIndex {
    if (widget.listData.isEmpty) return firstVisibleIndex;
    return (_windowEnd - 1).clamp(0, widget.listData.length - 1);
  }

  int get _remain {
    if (containerHeight <= 0) {
      return (500 / widget.itemHeight).ceil().clamp(1, 100000).toInt();
    }
    return (containerHeight / widget.itemHeight)
        .ceil()
        .clamp(1, 100000)
        .toInt();
  }

  int get _windowStart => (startIndex - (widget.buffer / 2).floor())
      .clamp(0, widget.listData.length)
      .toInt();

  /// Source computed `visibleCount` — rendered rows including the buffer.
  int get visibleCount => _remain + widget.buffer;

  int get _windowEnd => (_windowStart + _remain + widget.buffer)
      .clamp(0, widget.listData.length)
      .toInt();

  /// Source virtual helpers.
  void handleScroll([double? offset]) {
    _onScroll();
    if (offset != null) widget.onScroll?.call(offset);
  }

  void handleTouchMove([dynamic _]) {}

  void updateVisibleItems() {
    final next =
        (widget.scrollTop / widget.itemHeight).floor().clamp(0, 100000);
    if (mounted) {
      setState(() => startIndex = next);
    } else {
      startIndex = next;
    }
  }

  Map<String, int> getVisibleRange() => {
        'start': _windowStart,
        'end': _windowEnd,
      };
  void measureContainerHeight([dynamic _]) {
    if (!controller.hasClients) return;
    final h = controller.position.viewportDimension;
    if ((h - containerHeight).abs() > 0.5 && mounted) {
      setState(() => containerHeight = h);
    } else {
      containerHeight = h;
    }
  }

  double calculateDefaultHeight([dynamic _]) {
    final raw = widget.height;
    if (raw is num) return raw.toDouble();
    final text = '$raw'.trim();
    if (text.endsWith('px')) {
      return double.tryParse(text.replaceAll('px', '')) ?? 500;
    }
    if (text.endsWith('vh')) {
      final percent = double.tryParse(text.replaceAll('vh', ''));
      return percent == null ? 500 : percent / 100 * getViewportHeight();
    }
    return double.tryParse(text) ?? 500;
  }

  double getViewportHeight() {
    if (!controller.hasClients) return 0;
    return controller.position.viewportDimension;
  }

  dynamic getItemKey(dynamic item) {
    if (item is! Map) return null;
    if (item.containsKey(widget.keyField)) return item[widget.keyField];
    return item['_virtualIndex'];
  }

  void scrollTo(double offset, {bool animated = false}) {
    if (!controller.hasClients) return;
    final target = offset.clamp(0.0, controller.position.maxScrollExtent);
    if (animated) {
      controller.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      controller.jumpTo(target);
    }
  }

  void scrollToTop({bool animated = false}) => scrollTo(0, animated: animated);

  void scrollToIndex(int index, {bool animated = false}) {
    if (_offsets.isEmpty) return;
    final safe = index.clamp(0, _offsets.length - 1);
    final offset = _offsets[safe];
    scrollTo(offset, animated: animated);
  }

  @override
  void initState() {
    super.initState();
    controller = ScrollController(initialScrollOffset: widget.scrollTop);
    controller.addListener(_onScroll);
    _rebuildMetrics();
  }

  @override
  void didUpdateWidget(covariant UPVirtualList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listData != widget.listData ||
        oldWidget.itemHeight != widget.itemHeight) {
      _rebuildMetrics();
    }
    if (oldWidget.scrollTop != widget.scrollTop) {
      startIndex =
          (widget.scrollTop / widget.itemHeight).floor().clamp(0, 100000);
    }
    if (oldWidget.scrollTop != widget.scrollTop &&
        (controller.offset - widget.scrollTop).abs() > 1) {
      final target = widget.scrollTop;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !controller.hasClients) return;
        if ((controller.offset - target).abs() > 1) {
          controller.jumpTo(target);
        }
      });
    }
  }

  double _heightOf(dynamic item, int index) => widget.itemHeight;

  dynamic _itemWithIndex(int index) {
    final item = widget.listData[index];
    if (item is Map) return {...item, '_virtualIndex': index};
    return {'_virtualIndex': index};
  }

  void _rebuildMetrics() {
    _heights = [
      for (var i = 0; i < widget.listData.length; i++)
        _heightOf(widget.listData[i], i),
    ];
    _offsets = List<double>.filled(_heights.length + 1, 0);
    for (var i = 0; i < _heights.length; i++) {
      _offsets[i + 1] = _offsets[i] + _heights[i];
    }
  }

  int _indexAtOffset(double offset) {
    if (_heights.isEmpty) return 0;
    var lo = 0;
    var hi = _heights.length - 1;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      final start = _offsets[mid];
      final end = _offsets[mid + 1];
      if (offset < start) {
        hi = mid - 1;
      } else if (offset >= end) {
        lo = mid + 1;
      } else {
        return mid;
      }
    }
    return lo.clamp(0, _heights.length - 1);
  }

  void _onScroll() {
    final offset = controller.offset;
    final next = _indexAtOffset(offset);
    if (next != startIndex) setState(() => startIndex = next);
    widget.onScroll?.call(offset);
    widget.onUpdateScrollTop?.call(offset);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  double _resolveHeight(BoxConstraints constraints) {
    final raw = widget.height;
    if (raw is num) return raw.toDouble();
    final text = '$raw'.trim();
    if (text.endsWith('%')) {
      final p = double.tryParse(text.replaceAll('%', '')) ?? 100;
      if (constraints.maxHeight.isFinite) {
        return constraints.maxHeight * p / 100;
      }
      return 500;
    }
    if (text.endsWith('vh')) {
      final p = double.tryParse(text.replaceAll('vh', '')) ?? 100;
      // Approximate viewport height for tests/desktop.
      return 700 * p / 100;
    }
    final px = UPUtils.getPx(raw);
    return px > 0
        ? px
        : (constraints.maxHeight.isFinite ? constraints.maxHeight : 500);
  }

  @override
  Widget build(BuildContext context) {
    Widget root = LayoutBuilder(
      builder: (context, constraints) {
        final height = _resolveHeight(constraints);
        final nextH = height;
        if ((nextH - containerHeight).abs() > 0.5) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => containerHeight = nextH);
          });
        }

        final total = _offsets.isEmpty ? 0.0 : _offsets.last;
        final start = _windowStart;
        final end = _windowEnd;
        final top = start < _offsets.length ? _offsets[start] : 0.0;
        final bottom = total - (end < _offsets.length ? _offsets[end] : total);

        return SizedBox(
          height: height,
          child: ListView(
            controller: controller,
            padding: EdgeInsets.zero,
            children: [
              SizedBox(height: top),
              for (var i = start; i < end; i++)
                KeyedSubtree(
                  key: ValueKey(getItemKey(_itemWithIndex(i))),
                  child: SizedBox(
                    height: widget.itemHeight,
                    child: widget.itemBuilder
                            ?.call(context, _itemWithIndex(i), i) ??
                        const SizedBox.shrink(),
                  ),
                ),
              SizedBox(height: bottom < 0 ? 0 : bottom),
            ],
          ),
        );
      },
    );
    return root;
  }
}
