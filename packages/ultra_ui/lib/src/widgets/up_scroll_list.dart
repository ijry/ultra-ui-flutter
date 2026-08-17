import 'package:flutter/widgets.dart';

import '../utils/up_utils.dart';

/// 1:1 port of u-scroll-list.
class UPScrollList extends StatefulWidget {
  const UPScrollList({
    super.key,
    this.indicatorWidth = 50,
    this.indicatorBarWidth = 20,
    this.indicator = true,
    this.indicatorColor = '#f2f2f2',
    this.indicatorActiveColor = '#3c9cff',
    this.indicatorStyle,
    this.onLeft,
    this.onRight,
    required this.children,
    this.customStyle,
  });

  final dynamic indicatorWidth;
  final dynamic indicatorBarWidth;
  final bool indicator;
  final dynamic indicatorColor;
  final dynamic indicatorActiveColor;
  final EdgeInsetsGeometry? indicatorStyle;
  final VoidCallback? onLeft;
  final VoidCallback? onRight;
  final List<Widget> children;

  final BoxDecoration? customStyle;
  @override
  State<UPScrollList> createState() => UPScrollListState();
}

class UPScrollListState extends State<UPScrollList> {
  /// Source `getComponentWidth` — measured host width when laid out.
  Future<double> getComponentWidth() async {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return 0;
    return box.size.width;
  }

  /// Source data.
  double scrollLeft = 0;
  double scrollWidth = 0;
  Map<String, dynamic> scrollInfo = <String, dynamic>{
    'scrollLeft': 0,
    'scrollWidth': 0,
  };

  final controller = ScrollController();
  double progress = 0;
  bool _atLeft = true;
  bool _atRight = false;

  double get scrollProgress => progress;
  double get scrollOffset => controller.hasClients ? controller.offset : 0;
  bool get isAtLeft => _atLeft;
  bool get isAtRight => _atRight;

  /// Source `init`.
  void init() {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final width = box.size.width;
    if (width != scrollWidth) setState(() => scrollWidth = width);
  }

  /// Source scroll handlers.
  double _asDouble(dynamic value, [double fallback = 0]) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? fallback;
  }

  double get _contentWidth {
    if (controller.hasClients) {
      final view =
          scrollWidth > 0 ? scrollWidth : controller.position.viewportDimension;
      return controller.position.maxScrollExtent + view;
    }
    return _asDouble(scrollInfo['scrollWidth']);
  }

  Map<String, dynamic> _eventDetail(dynamic event) {
    if (event is Map) {
      final detail = event['detail'];
      if (detail is Map) {
        return <String, dynamic>{
          for (final entry in detail.entries) '${entry.key}': entry.value,
        };
      }
    }
    final offset = event == null
        ? (controller.hasClients ? controller.offset : scrollLeft)
        : _asDouble(event, scrollLeft);
    return <String, dynamic>{
      'scrollLeft': offset,
      'scrollWidth': _contentWidth,
    };
  }

  void _applyScrollDetail(Map<String, dynamic> detail) {
    final offset = _asDouble(detail['scrollLeft'], scrollLeft);
    final contentWidth = _asDouble(detail['scrollWidth'], _contentWidth);
    final max = contentWidth > scrollWidth ? contentWidth - scrollWidth : 0.0;
    final next = max <= 0 ? 0.0 : (offset / max).clamp(0.0, 1.0);
    final atLeft = offset <= 0;
    final atRight = max > 0 && offset >= max;
    void update() {
      scrollInfo = detail;
      scrollLeft = offset;
      progress = next;
      _atLeft = atLeft;
      _atRight = atRight;
    }

    if (mounted) {
      setState(update);
    } else {
      update();
    }
  }

  void scrollHandler([dynamic event]) =>
      _applyScrollDetail(_eventDetail(event));

  void _setSourceOffset(double offset, {bool atRight = false}) {
    final detail = Map<String, dynamic>.from(scrollInfo)
      ..['scrollLeft'] = offset;
    _applyScrollDetail(detail);
    _atRight = atRight;
    if (atRight) progress = 1;
  }

  void scrolltoupperHandler() {
    scrollEvent('left');
    _setSourceOffset(0);
  }

  void scrolltolowerHandler() {
    scrollEvent('right');
    _setSourceOffset(
      UPUtils.getPx(widget.indicatorWidth) -
          UPUtils.getPx(widget.indicatorBarWidth),
      atRight: true,
    );
  }

  void scrollEvent([dynamic status]) {
    if (status == 'left') {
      widget.onLeft?.call();
    } else if (status == 'right') {
      widget.onRight?.call();
    } else if (status != null) {
      scrollHandler(status);
    }
  }

  void nvueScrollHandler([dynamic _]) => scrollHandler();

  /// Source indicator style helpers (Batch L).
  Map barStyle([dynamic _]) => {
        'width': UPUtils.addUnit(widget.indicatorBarWidth),
        'backgroundColor': widget.indicatorActiveColor,
      };

  Map lineStyle([dynamic _]) => {
        'width': UPUtils.addUnit(widget.indicatorWidth),
        'backgroundColor': widget.indicatorColor,
      };

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

  void scrollToLeft({bool animated = false}) => scrollTo(0, animated: animated);

  void scrollToRight({bool animated = false}) {
    if (!controller.hasClients) return;
    scrollTo(controller.position.maxScrollExtent, animated: animated);
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) init();
    });
  }

  @override
  void dispose() {
    controller.removeListener(_onScroll);
    controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!controller.hasClients) return;
    final max = controller.position.maxScrollExtent;
    final offset = controller.offset;
    final next = max <= 0 ? 0.0 : (offset / max).clamp(0.0, 1.0);
    final nextAtLeft = offset <= 0;
    final nextAtRight = max > 0 && offset >= max;
    if (nextAtLeft && !_atLeft) widget.onLeft?.call();
    if (nextAtRight && !_atRight) widget.onRight?.call();
    final changed = (next - progress).abs() > 0.001 ||
        scrollLeft != offset ||
        _atLeft != nextAtLeft ||
        _atRight != nextAtRight;
    void update() {
      scrollInfo = <String, dynamic>{
        'scrollLeft': offset,
        'scrollWidth': _contentWidth,
      };
      scrollLeft = offset;
      progress = next;
      _atLeft = nextAtLeft;
      _atRight = nextAtRight;
    }

    if (changed && mounted) {
      setState(update);
    } else {
      update();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lineW = UPUtils.getPx(widget.indicatorWidth);
    final barW = UPUtils.getPx(widget.indicatorBarWidth);
    final lineColor =
        UPUtils.parseColor(widget.indicatorColor) ?? const Color(0xFFF2F2F2);
    final barColor = UPUtils.parseColor(widget.indicatorActiveColor) ??
        const Color(0xFF3C9CFF);
    final move = (lineW - barW).clamp(0.0, double.infinity);

    Widget root = Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            controller: controller,
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.children,
            ),
          ),
          if (widget.indicator)
            Padding(
              padding: widget.indicatorStyle ??
                  const EdgeInsets.only(top: 15, bottom: 0),
              child: Center(
                child: SizedBox(
                  width: lineW,
                  height: 4,
                  child: Stack(
                    children: [
                      Container(
                        width: lineW,
                        height: 4,
                        decoration: BoxDecoration(
                          color: lineColor,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      Positioned(
                        left: move * progress,
                        child: Container(
                          width: barW,
                          height: 4,
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return root;
  }
}
