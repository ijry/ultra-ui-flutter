import 'package:flutter/material.dart';

import '../utils/up_utils.dart';

final Expando<Map<String, dynamic>> _upListItemState =
    Expando<Map<String, dynamic>>('upListItemState');

class UPList extends StatefulWidget {
  const UPList({
    super.key,
    this.showScrollbar = false,
    this.lowerThreshold = 50,
    this.upperThreshold = 0,
    this.scrollTop = 0,
    this.offsetAccuracy = 10,
    this.enableFlex = false,
    this.pagingEnabled = false,
    this.scrollable = true,
    this.scrollIntoView = '',
    this.scrollWithAnimation = false,
    this.enableBackToTop = false,
    this.height = 0,
    this.width = 0,
    this.preLoadScreen = 1,
    this.refresherEnabled = false,
    this.refresherThreshold = 45,
    this.refresherDefaultStyle = 'black',
    this.refresherBackground = '#FFF',
    this.refresherTriggered = false,
    this.sys,
    this.customStyle,
    this.onScroll,
    this.onScrolltolower,
    this.onScrolltoupper,
    this.onScrollToLower,
    this.onScrollToUpper,
    this.onRefresherrefresh,
    this.onRefresherpulling,
    this.onRefresherrestore,
    this.onRefresherabort,
    this.onUpdateRefresherTriggered,
    this.children = const <Widget>[],
  });

  final bool showScrollbar;
  final dynamic lowerThreshold;
  final dynamic upperThreshold;
  final dynamic scrollTop;
  final dynamic offsetAccuracy;
  final bool enableFlex;
  final bool pagingEnabled;
  final bool scrollable;
  final String scrollIntoView;
  final bool scrollWithAnimation;
  final bool enableBackToTop;
  final dynamic height;
  final dynamic width;
  final dynamic preLoadScreen;
  final bool refresherEnabled;
  final num refresherThreshold;
  final String refresherDefaultStyle;
  final dynamic refresherBackground;
  final bool refresherTriggered;

  /// Source retained system metrics.
  final dynamic sys;
  final BoxDecoration? customStyle;
  final ValueChanged<double>? onScroll;
  final VoidCallback? onScrolltolower;
  final VoidCallback? onScrolltoupper;
  final VoidCallback? onScrollToLower;
  final VoidCallback? onScrollToUpper;
  final VoidCallback? onRefresherrefresh;
  final VoidCallback? onRefresherpulling;
  final VoidCallback? onRefresherrestore;
  final VoidCallback? onRefresherabort;
  final ValueChanged<bool>? onUpdateRefresherTriggered;
  final List<Widget> children;

  /// Source computed: listStyle.
  dynamic get listStyle {
    final style = <String, dynamic>{};
    if (width != 0 && '$width' != '0') style['width'] = UPUtils.addUnit(width);
    if (height != 0 && '$height' != '0') {
      style['height'] = UPUtils.addUnit(height);
    }
    if (!style.containsKey('height')) {
      final wh = sys is Map ? sys['windowHeight'] : null;
      style['height'] = UPUtils.addUnit(wh ?? 0);
    }
    return style;
  }

  @override
  State<UPList> createState() => UPListState();
}

class UPListState extends State<UPList> {
  /// Source data.
  double innerScrollTop = 0;
  double offset = 0;

  late final ScrollController _controller;
  bool _lowerFired = false;
  bool _upperFired = false;
  bool _refreshing = false;

  double get scrollOffset => _controller.hasClients
      ? _controller.offset
      : UPUtils.getPx(widget.scrollTop);

  bool get isRefreshing => _refreshing || widget.refresherTriggered;

  void scrollTo(double offset, {bool animated = false}) {
    if (!_controller.hasClients) return;
    final target = offset.clamp(0.0, _controller.position.maxScrollExtent);
    if (animated || widget.scrollWithAnimation) {
      _controller.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _controller.jumpTo(target);
    }
  }

  void scrollToTop({bool animated = false}) => scrollTo(0, animated: animated);

  void scrollToBottom({bool animated = false}) {
    if (!_controller.hasClients) return;
    scrollTo(_controller.position.maxScrollExtent, animated: animated);
  }

  Future<void> scrollIntoViewById(
    String id, {
    bool? animated,
    double alignment = 0,
  }) async {
    if (id.isEmpty) return;
    final ctx = _findAnchorContext(id);
    if (ctx == null || !_controller.hasClients) return;
    final useAnim = animated ?? widget.scrollWithAnimation;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final listBox = _controller.position.context.storageContext
        .findRenderObject() as RenderBox?;
    if (listBox == null || !listBox.hasSize) return;
    final itemTop = box.localToGlobal(Offset.zero).dy;
    final listTop = listBox.localToGlobal(Offset.zero).dy;
    final viewport = listBox.size.height;
    final target =
        (_controller.offset + (itemTop - listTop) - viewport * alignment)
            .clamp(0.0, _controller.position.maxScrollExtent);
    if (useAnim) {
      await _controller.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _controller.jumpTo(target);
    }
  }

  /// Source scroll event handler.
  void onScroll([dynamic event]) {
    double scrollTop;
    if (event is Map) {
      final contentOffset = event['contentOffset'];
      final detail = event['detail'];
      if (contentOffset is Map) {
        scrollTop = UPUtils.getPx(contentOffset['y'] ?? 0);
      } else if (detail is Map) {
        scrollTop = UPUtils.getPx(detail['scrollTop'] ?? 0);
      } else {
        scrollTop = UPUtils.getPx(event['scrollTop'] ?? 0);
      }
    } else if (event != null) {
      scrollTop = UPUtils.getPx(event);
    } else {
      scrollTop = _controller.hasClients ? _controller.offset : 0;
    }
    if (mounted) {
      setState(() => innerScrollTop = scrollTop);
    } else {
      innerScrollTop = scrollTop;
    }
    widget.onScroll?.call(scrollTop);
  }

  Future<void> scrolltolower([dynamic _]) async {
    await sleep(30);
    widget.onScrolltolower?.call();
    widget.onScrollToLower?.call();
  }

  Future<void> scrolltoupper([dynamic _]) async {
    await sleep(30);
    widget.onScrolltoupper?.call();
    widget.onScrollToUpper?.call();
    offset = 0;
  }

  bool pulling = false;
  double childOffset = 0;

  void refresherpulling([dynamic _]) {
    pulling = true;
    widget.onRefresherpulling?.call();
  }

  void refresherrefresh([dynamic _]) => widget.onRefresherrefresh?.call();
  void refresherrestore() {
    pulling = false;
    widget.onRefresherrestore?.call();
  }

  void refresherabort() {
    pulling = false;
    widget.onRefresherabort?.call();
  }

  Future<void> sleep(int ms) =>
      Future<void>.delayed(Duration(milliseconds: ms));
  void updateOffsetFromChild([dynamic offset]) {
    if (offset is num) {
      childOffset = offset.toDouble();
    } else if (offset is Map) {
      final raw = offset['offset'] ?? offset['scrollTop'] ?? offset['y'] ?? 0;
      childOffset = double.tryParse('$raw') ?? childOffset;
    }
    if (offset != null) this.offset = childOffset;
  }

  void finishRefresh() {
    if (!mounted) return;
    if (!_refreshing && !widget.refresherTriggered) return;
    setState(() => _refreshing = false);
    widget.onRefresherrestore?.call();
    widget.onUpdateRefresherTriggered?.call(false);
  }

  void startRefresh() {
    if (!mounted || !widget.refresherEnabled) return;
    setState(() => _refreshing = true);
    widget.onRefresherpulling?.call();
    widget.onRefresherrefresh?.call();
    widget.onUpdateRefresherTriggered?.call(true);
  }

  BuildContext? _findAnchorContext(String id) {
    BuildContext? found;
    void visitor(Element element) {
      if (found != null) return;
      final w = element.widget;
      if (w is UPListItem) {
        final anchor = '${w.anchor ?? ''}';
        if (anchor == id) {
          found = element;
          return;
        }
      }
      if (w.key is ValueKey && '${(w.key as ValueKey).value}' == id) {
        found = element;
        return;
      }
      element.visitChildren(visitor);
    }

    context.visitChildElements(visitor);
    return found;
  }

  @override
  void initState() {
    super.initState();
    _refreshing = widget.refresherTriggered;
    _controller = ScrollController(
      initialScrollOffset: UPUtils.getPx(widget.scrollTop),
    );
    _controller.addListener(_handleScroll);
    if (widget.scrollIntoView.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) scrollIntoViewById(widget.scrollIntoView);
      });
    }
  }

  @override
  void didUpdateWidget(covariant UPList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = UPUtils.getPx(widget.scrollTop);
    if (oldWidget.scrollTop != widget.scrollTop) {
      scrollTo(next, animated: widget.scrollWithAnimation);
    }
    if (oldWidget.scrollIntoView != widget.scrollIntoView &&
        widget.scrollIntoView.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) scrollIntoViewById(widget.scrollIntoView);
      });
    }
    if (oldWidget.refresherTriggered != widget.refresherTriggered) {
      _refreshing = widget.refresherTriggered;
    }
  }

  void _handleScroll() {
    if (!_controller.hasClients) return;
    final pos = _controller.position;
    onScroll(pos.pixels);
    final lower = UPUtils.getPx(widget.lowerThreshold);
    final upper = UPUtils.getPx(widget.upperThreshold);
    if (pos.pixels >= pos.maxScrollExtent - lower) {
      if (!_lowerFired) {
        _lowerFired = true;
        // ignore: discarded_futures
        scrolltolower();
      }
    } else {
      _lowerFired = false;
    }
    if (pos.pixels <= upper) {
      if (!_upperFired) {
        _upperFired = true;
        // ignore: discarded_futures
        scrolltoupper();
      }
    } else {
      _upperFired = false;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleScroll);
    _controller.dispose();
    super.dispose();
  }

  /// Source list init/query helpers (Batch J).
  bool initialized = false;
  void init([dynamic _]) {
    initialized = true;
  }

  Map queryRect([dynamic _]) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return {'width': 0.0, 'height': 0.0, 'left': 0.0, 'top': 0.0};
    }
    final o = box.localToGlobal(Offset.zero);
    return {
      'width': box.size.width,
      'height': box.size.height,
      'left': o.dx,
      'top': o.dy,
    };
  }

  void updateParentData([dynamic _]) {
    // Inherited parent props are read live; mark initialized for parity.
    initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final h = UPUtils.getPx(widget.height);
    final w = UPUtils.getPx(widget.width);
    Widget list = ListView(
      controller: _controller,
      physics: widget.scrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      children: widget.children,
    );

    if (widget.refresherEnabled) {
      list = RefreshIndicator(
        color: widget.refresherDefaultStyle == 'white'
            ? const Color(0xFFFFFFFF)
            : null,
        backgroundColor: UPUtils.parseColor(widget.refresherBackground) ??
            const Color(0xFFFFFFFF),
        displacement:
            UPUtils.getPx(widget.refresherThreshold).clamp(20.0, 120.0),
        onRefresh: () async {
          setState(() => _refreshing = true);
          widget.onRefresherpulling?.call();
          widget.onRefresherrefresh?.call();
          widget.onUpdateRefresherTriggered?.call(true);
        },
        child: list,
      );
    }

    return Container(
      height: h > 0 ? h : null,
      width: w > 0 ? w : null,
      decoration: widget.customStyle,
      child: list,
    );
  }
}

class UPListItem extends StatelessWidget {
  const UPListItem({
    super.key,
    this.anchor = '',
    required this.child,
  });

  final dynamic anchor;
  final Widget child;

  /// Source list-item helpers (Batch J).
  Map<String, dynamic> get _state =>
      _upListItemState[this] ??= <String, dynamic>{'initialized': false};
  bool get initialized => _state['initialized'] == true;
  void init([dynamic _]) {
    _state['initialized'] = true;
  }

  void updateParentData([dynamic _]) {
    // Inherited parent props are read live; mark initialized for parity.
    _state['initialized'] = true;
  }

  Map queryRect([dynamic _]) => const {
        'width': 0.0,
        'height': 0.0,
        'left': 0.0,
        'top': 0.0,
      };

  @override
  Widget build(BuildContext context) => child;
}
