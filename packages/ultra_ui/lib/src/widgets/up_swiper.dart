import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/up_utils.dart';
import 'up_image.dart';
import 'up_icon.dart';
import 'up_loading_icon.dart';

/// 1:1 port of u-swiper.
class UPSwiper extends StatefulWidget {
  const UPSwiper({
    super.key,
    this.list = const [],
    this.indicator = false,
    this.vertical = false,
    this.indicatorActiveColor = '#FFFFFF',
    this.indicatorInactiveColor = 'rgba(255, 255, 255, 0.35)',
    this.indicatorStyle,
    this.indicatorMode = 'line',
    this.autoplay = true,
    this.current = 0,
    this.modelValue,
    this.currentItemId = '',
    this.interval = 3000,
    this.duration = 300,
    this.circular = false,
    this.previousMargin = 0,
    this.nextMargin = 0,
    this.acceleration = false,
    this.displayMultipleItems = 1,
    this.easingFunction = 'default',
    this.keyName = 'url',
    this.imgMode = 'aspectFill',
    this.height = 130,
    this.bgColor = '#f3f4f6',
    this.radius = 4,
    this.loading = false,
    this.showTitle = false,
    this.itemBuilder,
    this.indicatorSlot,
    this.onChange,
    this.onClick,
    this.customStyle,
    this.onUpdateCurrent,
    this.onUpdateModelValue,
  });

  final List<dynamic> list;
  final bool indicator;
  final bool vertical;
  final dynamic indicatorActiveColor;
  final dynamic indicatorInactiveColor;

  /// Map/string style; supports bottom/left/right numeric or unit strings.
  final dynamic indicatorStyle;
  final String indicatorMode;
  final bool autoplay;
  final dynamic current;

  /// Source v-model alias for current.
  final dynamic modelValue;
  final String currentItemId;
  final dynamic interval;
  final dynamic duration;
  final bool circular;
  final dynamic previousMargin;
  final dynamic nextMargin;
  final bool acceleration;
  final int displayMultipleItems;
  final String easingFunction;
  final String keyName;
  final String imgMode;
  final dynamic height;
  final dynamic bgColor;
  final dynamic radius;
  final bool loading;
  final bool showTitle;
  final Widget Function(BuildContext context, dynamic item, int index)?
      itemBuilder;
  final Widget? indicatorSlot;
  final ValueChanged<int>? onChange;

  /// Source emits index only; also supports (item, index) for existing Flutter API.
  final dynamic onClick;

  final BoxDecoration? customStyle;
  final ValueChanged<int>? onUpdateCurrent;

  /// Source update:modelValue alias for current.
  final ValueChanged<int>? onUpdateModelValue;
  dynamic get effectiveCurrent => modelValue ?? current;

  /// Source computed: itemStyle(index).
  dynamic itemStyle([dynamic index]) {
    final style = <String, dynamic>{};
    final prev = UPUtils.getPx(previousMargin);
    final next = UPUtils.getPx(nextMargin);
    if (prev > 0 && next > 0) {
      style['borderRadius'] = UPUtils.addUnit(radius);
      final currentIndex = int.tryParse('$effectiveCurrent') ?? 0;
      final i = index is int ? index : int.tryParse('$index') ?? 0;
      if (i != currentIndex) style['transform'] = 'scale(0.92)';
    }
    return style;
  }

  /// Source host helper: testImage.
  dynamic testImage([dynamic v]) => null;

  /// Source host helper: testObject.
  dynamic testObject([dynamic v]) => null;

  @override
  State<UPSwiper> createState() => UPSwiperState();
}

class UPSwiperState extends State<UPSwiper> {
  late final PageController _controller;
  late int _index;
  Timer? _timer;

  int get currentIndex => _index;
  bool get isAutoplaying => _timer != null && _timer!.isActive;

  bool get _circularEnabled => widget.circular && widget.list.length > 1;
  int get _pageCount => widget.list.length + (_circularEnabled ? 2 : 0);

  int _pageForLogicalIndex(int index) => _circularEnabled ? index + 1 : index;

  int _logicalIndexForPage(int page) {
    if (!_circularEnabled) return page;
    if (page <= 0) return widget.list.length - 1;
    if (page >= widget.list.length + 1) return 0;
    return page - 1;
  }

  bool _isSentinelPage(int page) =>
      _circularEnabled && (page == 0 || page == widget.list.length + 1);

  void _setCurrentIndex(int next, {bool emit = true}) {
    if (widget.list.isEmpty) return;
    final safe = next.clamp(0, widget.list.length - 1);
    if (safe == _index) return;
    final previous = _index;
    if (previous >= 0 &&
        previous < widget.list.length &&
        _isVideo(widget.list[previous])) {
      pauseVideo(previous);
    }
    setState(() => _index = safe);
    if (emit) {
      widget.onChange?.call(safe);
      widget.onUpdateCurrent?.call(safe);
      widget.onUpdateModelValue?.call(safe);
    }
  }

  void _goToPage(int page, int logicalIndex, {required bool animated}) {
    if (!_controller.hasClients) {
      _setCurrentIndex(logicalIndex);
      return;
    }
    if (animated) {
      _controller.animateToPage(
        page,
        duration:
            Duration(milliseconds: int.tryParse('${widget.duration}') ?? 300),
        curve: _curve,
      );
    } else {
      _controller.jumpToPage(page);
    }
    // The native swiper synchronizes the public current value as the move
    // starts. _setCurrentIndex makes the later PageView callback idempotent.
    _setCurrentIndex(logicalIndex);
  }

  void swipeTo(int index, {bool animated = true}) {
    if (widget.list.isEmpty) return;
    final next = index.clamp(0, widget.list.length - 1);
    _goToPage(
      _pageForLogicalIndex(next),
      next,
      animated: animated,
    );
  }

  void next({bool animated = true}) {
    if (widget.list.isEmpty) return;
    final last = widget.list.length - 1;
    final nextIndex = _circularEnabled
        ? (_index + 1) % widget.list.length
        : (_index < last ? _index + 1 : _index);
    if (_circularEnabled && _index == last) {
      _goToPage(_pageCount - 1, nextIndex, animated: animated);
    } else {
      swipeTo(nextIndex, animated: animated);
    }
  }

  void prev({bool animated = true}) {
    if (widget.list.isEmpty) return;
    final nextIndex = _circularEnabled
        ? (_index - 1 + widget.list.length) % widget.list.length
        : (_index > 0 ? _index - 1 : _index);
    if (_circularEnabled && _index == 0) {
      _goToPage(0, nextIndex, animated: animated);
    } else {
      swipeTo(nextIndex, animated: animated);
    }
  }

  void startAutoplay() => _startAutoplay();

  void stopAutoplay() {
    _timer?.cancel();
    _timer = null;
  }

  /// Source `change`.
  void change(int index) => swipeTo(index);

  /// Source `clickHandler`.
  void clickHandler([int? index]) {
    final i = index ?? _index;
    if (i < 0 || i >= widget.list.length) return;
    final item = widget.list[i];
    final cb = widget.onClick;
    if (cb is void Function(int)) {
      cb(i);
    } else if (cb is void Function(dynamic, int)) {
      cb(item, i);
    } else if (cb is Function) {
      try {
        cb(item, i);
      } catch (_) {
        try {
          cb(i);
        } catch (_) {}
      }
    }
  }

  /// Source `getItemType`.
  String getItemType(dynamic item) {
    if (item is Map) {
      final type = '${item['type'] ?? item['itemType'] ?? ''}'.toLowerCase();
      if (type == 'video' || type == 'image') return type;
    }
    return _isVideo(item) ? 'video' : 'image';
  }

  /// Source `getSource`.
  String getSource(dynamic item) {
    if (item is Map) {
      return '${item[widget.keyName] ?? item['url'] ?? item['src'] ?? item['image'] ?? ''}';
    }
    return '$item';
  }

  /// Source `getPoster`.
  String getPoster(dynamic item) {
    if (item is Map) {
      return '${item['poster'] ?? item['cover'] ?? ''}';
    }
    return '';
  }

  /// Host-only video pause retained (uni video pause).
  bool videoPaused = false;
  void pauseVideo([dynamic _]) {
    videoPaused = true;
  }

  double get _prevMargin => UPUtils.getPx(widget.previousMargin);
  double get _nextMargin => UPUtils.getPx(widget.nextMargin);
  bool get _hasSideMargin => _prevMargin > 0 && _nextMargin > 0;

  @override
  void initState() {
    super.initState();
    _index = _resolveInitialIndex();
    _controller = PageController(
      initialPage: _pageForLogicalIndex(_index),
      viewportFraction: _viewportFraction,
    );
    _startAutoplay();
  }

  double get _viewportFraction {
    if (widget.displayMultipleItems > 1) {
      return 1 / widget.displayMultipleItems;
    }
    // Approximate previous/next margin by shrinking viewport.
    // Exact pixel margins need layout width; use fraction heuristic.
    if (_hasSideMargin) {
      return 0.88;
    }
    return 1.0;
  }

  int _resolveInitialIndex() {
    if (widget.list.isEmpty) return 0;
    if (widget.currentItemId.isNotEmpty) {
      for (var i = 0; i < widget.list.length; i++) {
        final item = widget.list[i];
        if (item is Map &&
            '${item['id'] ?? item['itemId'] ?? ''}' == widget.currentItemId) {
          return i;
        }
      }
    }
    final value = int.tryParse('${widget.effectiveCurrent}') ?? 0;
    return value.clamp(0, widget.list.length - 1);
  }

  @override
  void didUpdateWidget(covariant UPSwiper oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentChanged =
        '${oldWidget.effectiveCurrent}' != '${widget.effectiveCurrent}' ||
            oldWidget.currentItemId != widget.currentItemId;
    final structureChanged = oldWidget.list.length != widget.list.length ||
        oldWidget.circular != widget.circular;
    if (currentChanged || structureChanged) {
      final next = currentChanged
          ? _resolveInitialIndex()
          : _index.clamp(0, widget.list.isEmpty ? 0 : widget.list.length - 1);
      if (widget.list.isEmpty) {
        _index = 0;
      } else {
        _index = next;
        if (_controller.hasClients) {
          _controller.jumpToPage(_pageForLogicalIndex(next));
        }
      }
    }
    if (oldWidget.autoplay != widget.autoplay ||
        oldWidget.interval != widget.interval ||
        oldWidget.list.length != widget.list.length ||
        oldWidget.circular != widget.circular) {
      _startAutoplay();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoplay() {
    _timer?.cancel();
    if (!widget.autoplay || widget.list.length <= 1 || widget.loading) return;
    final ms = int.tryParse('${widget.interval}') ?? 3000;
    _timer = Timer.periodic(Duration(milliseconds: ms), (_) {
      if (!mounted || widget.list.isEmpty) return;
      next();
    });
  }

  Curve get _curve {
    switch (widget.easingFunction) {
      case 'linear':
        return Curves.linear;
      case 'easeInCubic':
        return Curves.easeInCubic;
      case 'easeOutCubic':
        return Curves.easeOutCubic;
      case 'easeInOutCubic':
        return Curves.easeInOutCubic;
      default:
        return Curves.easeOut;
    }
  }

  String _url(dynamic item) {
    if (item is String) return item;
    if (item is Map) return '${item[widget.keyName] ?? item['url'] ?? ''}';
    return '';
  }

  String _title(dynamic item) {
    if (item is Map) return '${item['title'] ?? ''}';
    return '';
  }

  String _poster(dynamic item) {
    if (item is Map) return '${item['poster'] ?? ''}';
    return '';
  }

  bool _isVideo(dynamic item) {
    if (item is Map &&
        '${item['type'] ?? item['itemType'] ?? ''}'.toLowerCase() == 'video') {
      return true;
    }
    final src = _url(item);
    return RegExp(r'\.(mp4|mov|m3u8|webm)(\?|$)', caseSensitive: false)
        .hasMatch(src);
  }

  void _emitClick(dynamic item, int index) {
    final cb = widget.onClick;
    if (cb == null) return;
    if (cb is void Function(int)) {
      cb(index);
    } else if (cb is void Function(dynamic, int)) {
      cb(item, index);
    } else if (cb is Function) {
      try {
        cb(index);
      } catch (_) {
        try {
          cb(item, index);
        } catch (_) {}
      }
    }
  }

  EdgeInsets _indicatorPadding() {
    final style = widget.indicatorStyle;
    if (style is! Map) {
      return const EdgeInsets.only(bottom: 10);
    }
    double px(dynamic v, [double d = 0]) {
      if (v == null || '$v'.isEmpty) return d;
      return UPUtils.getPx(v);
    }

    return EdgeInsets.only(
      left: px(style['left']),
      right: px(style['right']),
      bottom: px(style['bottom'], 10),
      top: px(style['top']),
    );
  }

  Alignment _indicatorAlign() {
    final style = widget.indicatorStyle;
    if (style is Map) {
      if (style['left'] != null && style['right'] == null) {
        return Alignment.bottomLeft;
      }
      if (style['right'] != null && style['left'] == null) {
        return Alignment.bottomRight;
      }
    }
    return Alignment.bottomCenter;
  }

  @override
  Widget build(BuildContext context) {
    final h = UPUtils.getPx(widget.height);
    final r = UPUtils.getPx(widget.radius);
    final bg = UPUtils.parseColor(widget.bgColor) ?? const Color(0xFFF3F4F6);
    final active =
        UPUtils.parseColor(widget.indicatorActiveColor) ?? Colors.white;
    final inactive = UPUtils.parseColor(widget.indicatorInactiveColor) ??
        const Color(0x59FFFFFF);

    Widget root = ClipRRect(
      borderRadius: BorderRadius.circular(r),
      child: Container(
        height: h,
        color: bg,
        child: Stack(
          children: [
            if (widget.loading)
              const Center(child: UPLoadingIcon(mode: 'circle', size: 28))
            else if (widget.list.isEmpty)
              const Center(child: Text('暂无数据'))
            else
              PageView.builder(
                controller: _controller,
                scrollDirection:
                    widget.vertical ? Axis.vertical : Axis.horizontal,
                itemCount: _pageCount,
                onPageChanged: (page) {
                  final index = _logicalIndexForPage(page);
                  _setCurrentIndex(index);
                  if (_isSentinelPage(page)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted || !_controller.hasClients) return;
                      final currentPage = _controller.page;
                      if (currentPage != null &&
                          (currentPage - page).abs() < 0.01) {
                        _controller.jumpToPage(_pageForLogicalIndex(index));
                      }
                    });
                  }
                },
                itemBuilder: (context, page) {
                  final i = _logicalIndexForPage(page);
                  final item = widget.list[i];
                  final selected = i == _index;
                  Widget child;
                  if (widget.itemBuilder != null) {
                    child = widget.itemBuilder!(context, item, i);
                  } else {
                    final url = _url(item);
                    final video = _isVideo(item);
                    child = Stack(
                      fit: StackFit.expand,
                      children: [
                        if (video)
                          Container(
                            color: Colors.black,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_poster(item).isNotEmpty)
                                  Expanded(
                                    child: UPImage(
                                      src: _poster(item),
                                      width: double.infinity,
                                      height: h,
                                      mode: widget.imgMode,
                                      radius: 0,
                                    ),
                                  )
                                else
                                  const UPIconNameFallback(),
                                const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    '视频',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (url.isNotEmpty)
                          UPImage(
                            src: url,
                            width: double.infinity,
                            height: h,
                            mode: widget.imgMode,
                            radius: 0,
                          )
                        else
                          ColoredBox(color: bg),
                        if (widget.showTitle && _title(item).isNotEmpty)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              color: const Color(0x4D000000),
                              child: Text(
                                _title(item),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }

                  // Source scales non-active items when both margins set.
                  final scale = _hasSideMargin && !selected ? 0.92 : 1.0;
                  return GestureDetector(
                    onTap: () => _emitClick(item, i),
                    child: AnimatedScale(
                      scale: scale,
                      duration: const Duration(milliseconds: 300),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          _hasSideMargin ? r : 0,
                        ),
                        child: child,
                      ),
                    ),
                  );
                },
              ),
            if (!widget.loading &&
                widget.list.isNotEmpty &&
                (widget.indicatorSlot != null ||
                    (widget.indicator && !widget.showTitle)))
              Positioned.fill(
                child: Padding(
                  padding: _indicatorPadding(),
                  child: Align(
                    alignment: _indicatorAlign(),
                    child: widget.indicatorSlot ??
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(widget.list.length, (i) {
                            final selected = i == _index;
                            if (widget.indicatorMode == 'dot') {
                              return Container(
                                width: 6,
                                height: 6,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  color: selected ? active : inactive,
                                  shape: BoxShape.circle,
                                ),
                              );
                            }
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: selected ? 14 : 8,
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: selected ? active : inactive,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return root;
  }
}

/// Tiny placeholder when video has no poster (avoids hard dependency).
class UPIconNameFallback extends StatelessWidget {
  const UPIconNameFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return const UPIcon(
        name: 'play-circle', size: 40, color: Color(0xB3FFFFFF));
  }
}

/// Source `u-swiper-indicator` standalone indicator widget.
class UPSwiperIndicator extends StatelessWidget {
  const UPSwiperIndicator({
    super.key,
    this.length = 0,
    this.current = 0,
    this.indicatorActiveColor = '#FFFFFF',
    this.indicatorInactiveColor = 'rgba(255, 255, 255, 0.35)',
    this.indicatorMode = 'line',
    this.customStyle,
  });

  final dynamic length;
  final dynamic current;
  final dynamic indicatorActiveColor;
  final dynamic indicatorInactiveColor;
  final String indicatorMode;
  final BoxDecoration? customStyle;

  int get _len {
    if (length is int) return length as int;
    return int.tryParse('$length') ?? 0;
  }

  int get _current {
    if (current is int) return current as int;
    return int.tryParse('$current') ?? 0;
  }

  /// Source `lineStyle`.
  Map lineStyle([dynamic _]) {
    final lineWidth = 22.0;
    return {
      'width': lineWidth,
      'transform': 'translateX(${_current * lineWidth})',
      'backgroundColor': indicatorActiveColor,
    };
  }

  /// Source `dotStyle`.
  Map dotStyle([dynamic index = 0]) {
    final i = index is int ? index : int.tryParse('$index') ?? 0;
    return {
      'backgroundColor':
          i == _current ? indicatorActiveColor : indicatorInactiveColor,
    };
  }

  @override
  Widget build(BuildContext context) {
    final active = UPUtils.parseColor(indicatorActiveColor) ?? Colors.white;
    final inactive =
        UPUtils.parseColor(indicatorInactiveColor) ?? const Color(0x59FFFFFF);
    final count = _len < 0 ? 0 : _len;
    final idx = count == 0 ? 0 : _current.clamp(0, count - 1);

    Widget body;
    if (indicatorMode == 'dot') {
      body = Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (i) {
          final selected = i == idx;
          return Container(
            width: selected ? 12 : 5,
            height: 5,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: selected ? active : inactive,
              borderRadius: BorderRadius.circular(100),
            ),
          );
        }),
      );
    } else {
      const lineWidth = 22.0;
      body = Container(
        width: lineWidth * (count <= 0 ? 1 : count),
        height: 4,
        decoration: BoxDecoration(
          color: inactive,
          borderRadius: BorderRadius.circular(100),
        ),
        alignment: Alignment.centerLeft,
        child: Transform.translate(
          offset: Offset(lineWidth * idx, 0),
          child: Container(
            width: lineWidth,
            height: 4,
            decoration: BoxDecoration(
              color: active,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
      );
    }

    return body;
  }
}
