import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';
import 'up_loadmore.dart';
import 'up_loading_icon.dart';

/// 1:1 port of u-pull-refresh (gesture shell).
class UPPullRefresh extends StatefulWidget {
  const UPPullRefresh({
    super.key,
    this.refreshing = false,
    this.threshold = 80,
    this.damping = 0.4,
    this.maxDistance = 120,
    this.showLoadmore = false,
    this.loadmoreStatus = 'loadmore',
    this.loadmoreProps = const {},
    this.useScrollView = true,
    this.enableBackToTop = false,
    this.lowerThreshold = 50,
    this.scrollTop = 0,
    this.onRefresh,
    this.onLoadmore,
    this.onScroll,
    this.pullSlot,
    this.releaseSlot,
    this.refreshingSlot,
    required this.child,
    this.customStyle,
  });

  final bool refreshing;
  final double threshold;
  final double damping;
  final double maxDistance;
  final bool showLoadmore;
  final String loadmoreStatus;
  final Map loadmoreProps;
  final bool useScrollView;
  final bool enableBackToTop;
  final dynamic lowerThreshold;
  final dynamic scrollTop;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoadmore;
  final ValueChanged<double>? onScroll;
  final Widget? pullSlot;
  final Widget? releaseSlot;
  final Widget? refreshingSlot;
  final Widget child;

  final BoxDecoration? customStyle;
  @override
  State<UPPullRefresh> createState() => UPPullRefreshState();
}

class UPPullRefreshState extends State<UPPullRefresh> {
  bool isRefreshing = false;
  String refreshStatus = 'pull';
  double refreshDistance = 0;
  double startY = 0;
  double currentY = 0;
  bool touching = false;
  double contentTranslateY = 0;
  final controller = ScrollController();

  double get pullDistance => refreshDistance;
  double get distance => refreshDistance;
  set distance(double value) => refreshDistance = value;

  void finishRefresh() {
    if (!mounted) return;
    setState(() {
      isRefreshing = false;
      refreshStatus = 'pull';
      _resetRefreshValues();
    });
  }

  void startRefresh() {
    if (!mounted) return;
    setState(() {
      isRefreshing = true;
      refreshStatus = 'refreshing';
      refreshDistance = widget.threshold;
      contentTranslateY = widget.threshold;
    });
  }

  void scrollTo(double offset) {
    if (!controller.hasClients) return;
    controller.jumpTo(offset.clamp(0.0, controller.position.maxScrollExtent));
  }

  void scrollToTop() => scrollTo(0);

  void _resetRefreshValues() {
    refreshDistance = 0;
    contentTranslateY = 0;
  }

  /// Source resetRefresh only returns the content to its resting position.
  void resetRefresh() {
    if (!mounted) {
      _resetRefreshValues();
      return;
    }
    setState(_resetRefreshValues);
  }

  /// Source `isScrollViewAtTop`.
  bool isScrollViewAtTop() => true;

  /// Source `handleScroll`.
  void handleScroll([double? offset]) {
    final o = offset ?? (controller.hasClients ? controller.offset : 0.0);
    widget.onScroll?.call(o);
  }

  /// Source `handleScrollToLower`.
  void handleScrollToLower() {
    if (widget.showLoadmore && _loadmoreStatus == 'loadmore') {
      widget.onLoadmore?.call();
    }
  }

  /// Source touch aliases.
  void onTouchStart([dynamic event]) {
    if (isRefreshing) return;
    final pageY = _touchPageY(event);
    touching = true;
    startY = pageY;
    currentY = pageY;
    refreshStatus = 'pull';
  }

  void onTouchMove(dynamic event) {
    if (!mounted || !touching || isRefreshing) return;
    currentY = _touchPageY(event);
    final diff = currentY - startY;
    if (diff <= 0 || !isScrollViewAtTop()) return;
    final next = (diff * widget.damping).clamp(0.0, widget.maxDistance);
    setState(() {
      refreshDistance = next;
      contentTranslateY = next;
      refreshStatus = next >= widget.threshold ? 'release' : 'pull';
    });
  }

  void onTouchEnd([dynamic _]) {
    if (!mounted || !touching) return;
    touching = false;
    if (refreshDistance >= widget.threshold && !isRefreshing) {
      startRefresh();
      widget.onRefresh?.call();
    } else {
      resetRefresh();
    }
  }

  double _touchPageY(dynamic event) {
    if (event is num) return event.toDouble();
    if (event is Offset) return event.dy;
    if (event is Map) {
      final touches = event['touches'];
      if (touches is List && touches.isNotEmpty) {
        final touch = touches.first;
        if (touch is Map && touch['pageY'] is num) {
          return (touch['pageY'] as num).toDouble();
        }
        if (touch is num) return touch.toDouble();
      }
      if (event['pageY'] is num) return (event['pageY'] as num).toDouble();
    }
    return currentY;
  }

  dynamic _loadmoreProp(String name, dynamic fallback) {
    return widget.loadmoreProps.containsKey(name)
        ? widget.loadmoreProps[name]
        : fallback;
  }

  String get _loadmoreStatus => '${_loadmoreProp('status', 'loadmore')}';

  bool _loadmoreBool(String name, bool fallback) {
    final value = _loadmoreProp(name, fallback);
    return value is bool ? value : '$value' == 'true';
  }

  UPLoadmore _buildLoadmore() {
    return UPLoadmore(
      status: _loadmoreStatus,
      bgColor: _loadmoreProp('bgColor', 'transparent'),
      icon: _loadmoreBool('icon', true),
      fontSize: _loadmoreProp('fontSize', 14),
      iconSize: _loadmoreProp('iconSize', 17),
      color: _loadmoreProp('color', '#606266'),
      loadingIcon: '${_loadmoreProp('loadingIcon', 'spinner')}',
      loadmoreText: '${_loadmoreProp('loadmoreText', '加载更多')}',
      loadingText: '${_loadmoreProp('loadingText', '正在加载...')}',
      nomoreText: '${_loadmoreProp('nomoreText', '没有更多了')}',
      isDot: _loadmoreBool('isDot', false),
      iconColor: _loadmoreProp('iconColor', '#b7b7b7'),
      marginTop: _loadmoreProp('marginTop', 10),
      marginBottom: _loadmoreProp('marginBottom', 10),
      height: _loadmoreProp('height', 'auto'),
      line: _loadmoreBool('line', false),
      lineColor: _loadmoreProp('lineColor', '#E6E8EB'),
      dashed: _loadmoreBool('dashed', false),
    );
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      widget.onScroll?.call(controller.offset);
      if (widget.showLoadmore &&
          controller.hasClients &&
          controller.position.pixels >=
              controller.position.maxScrollExtent -
                  UPUtils.getPx(widget.lowerThreshold)) {
        if (_loadmoreStatus == 'loadmore') widget.onLoadmore?.call();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncScrollTop());
  }

  @override
  void didUpdateWidget(covariant UPPullRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshing != widget.refreshing) {
      if (widget.refreshing) {
        startRefresh();
      } else {
        finishRefresh();
      }
    }
    if (oldWidget.scrollTop != widget.scrollTop) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncScrollTop());
    }
  }

  void _syncScrollTop() {
    if (!mounted || !controller.hasClients) return;
    final target = UPUtils.getPx(widget.scrollTop)
        .clamp(
          0.0,
          controller.position.maxScrollExtent,
        )
        .toDouble();
    if ((controller.offset - target).abs() > 0.5) controller.jumpTo(target);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) => onTouchStart(event.position);

  void _onPointerMove(PointerMoveEvent event) => onTouchMove(event.position);

  void _onPointerUp(PointerUpEvent event) => onTouchEnd();

  void _onPointerCancel(PointerCancelEvent event) {
    if (!touching) return;
    touching = false;
    resetRefresh();
  }

  Widget _indicator(UPThemeTokens tokens) {
    if (refreshStatus == 'refreshing') {
      return widget.refreshingSlot ??
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const UPLoadingIcon(mode: 'circle', size: 16),
                  Text(
                    '正在刷新...',
                    style: const TextStyle(
                      color: Color(0xFF303133),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
    }
    if (refreshStatus == 'release') {
      return widget.releaseSlot ??
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  UPIcon(
                    name: 'arrow-upward',
                    size: 26,
                    color: const Color(0xFF606266),
                  ),
                  Text(
                    '释放刷新',
                    style: const TextStyle(
                      color: Color(0xFF303133),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
    }
    return widget.pullSlot ??
        Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                UPIcon(
                  name: 'arrow-downward',
                  size: 26,
                  color: const Color(0xFF606266),
                ),
                Text(
                  '下拉刷新',
                  style: const TextStyle(
                    color: Color(0xFF303133),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final body = widget.useScrollView
        ? ListView(
            controller: controller,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              widget.child,
              if (widget.showLoadmore) _buildLoadmore(),
            ],
          )
        : Column(
            children: [
              Expanded(child: widget.child),
              if (widget.showLoadmore) _buildLoadmore(),
            ],
          );

    Widget root = Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: refreshDistance,
            child: _indicator(tokens),
          ),
          AnimatedContainer(
            duration:
                touching ? Duration.zero : const Duration(milliseconds: 200),
            transform: Matrix4.translationValues(0, contentTranslateY, 0),
            child: SizedBox.expand(child: body),
          ),
        ],
      ),
    );
    return root;
  }
}
