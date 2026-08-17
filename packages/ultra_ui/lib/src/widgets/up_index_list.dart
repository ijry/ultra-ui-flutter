import 'dart:async';

import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';

List<String> _defaultLetters() {
  return List.generate(26, (i) => String.fromCharCode(65 + i));
}

/// 1:1 port of u-index-list / u-index-anchor / u-index-item.
class UPIndexList extends StatefulWidget {
  const UPIndexList({
    super.key,
    this.inactiveColor = '#606266',
    this.activeColor = '#5677fc',
    this.indexList = const [],
    this.sticky = true,
    this.customNavHeight = 0,
    this.safeBottomFix = false,
    this.itemMargin = '0rpx',
    this.header,
    this.footer,
    this.options = const [],
    this.sys,
    this.letterInfo,
    this.onSelect,
    required this.children,
    this.customStyle,
  });

  final dynamic inactiveColor;
  final dynamic activeColor;
  final List indexList;
  final bool sticky;
  final dynamic customNavHeight;
  final bool safeBottomFix;
  final dynamic itemMargin;
  final Widget? header;
  final Widget? footer;

  /// Source retained host data/options.
  final List options;
  final dynamic sys;
  final dynamic letterInfo;
  final ValueChanged<dynamic>? onSelect;
  final List<UPIndexItem> children;
  final BoxDecoration? customStyle;

  /// Source computed: resolvedInactiveColor.
  dynamic get resolvedInactiveColor {
    final c = '$inactiveColor';
    return c == '#606266' ? '#606266' : inactiveColor;
  }

  /// Source computed: resolvedActiveColor.
  dynamic get resolvedActiveColor {
    final c = '$activeColor';
    return c == '#5677fc' ? '#5677fc' : activeColor;
  }

  /// Source computed: activeLetterTextColor.
  dynamic get activeLetterTextColor => '#ffffff';

  /// Source data defaults.
  dynamic get indicatorHeight => 0;
  dynamic get pageY => 0;
  dynamic get scrollIntoView => '';
  dynamic get scrollTop => 0;
  dynamic get scrollViewHeight => 0;
  dynamic get scrolling => false;
  dynamic get topOffset => 0;
  dynamic get activeIndex => -1;
  dynamic get touchmoveIndex => 1;
  dynamic get letterInfoDefault => const <String, dynamic>{
        'height': 0,
        'itemHeight': 0,
        'top': 0,
      };

  @override
  State<UPIndexList> createState() => UPIndexListState();
}

class UPIndexListState extends State<UPIndexList> {
  /// Source host helper.
  Future<void> sleep([int ms = 0]) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
  }

  /// Source host helper.
  dynamic resolve([dynamic v]) => v;

  /// Source data.
  double itemHeight = 0;
  int touchmoveIndex = -1;
  double scrollTop = 0;
  double scrollViewHeight = 0;
  double topOffset = 0;
  bool scrolling = false;
  double indicatorHeight = 0;
  double pageY = 0;
  String scrollIntoView = '';

  final scrollController = ScrollController();
  final itemKeys = <GlobalKey>[];
  int activeIndex = 0;
  bool touching = false;
  Timer? _touchEndTimer;

  List get letters {
    if (widget.indexList.isNotEmpty) return widget.indexList;
    return _defaultLetters();
  }

  int get currentIndex => activeIndex;

  /// Source indicator helper (Batch K).
  double get indicatorTop {
    if (letters.isEmpty) return 0;
    return activeIndex * 16.0;
  }

  dynamic get activeLetter {
    if (letters.isEmpty) return null;
    return letters[activeIndex.clamp(0, letters.length - 1)];
  }

  double get scrollOffset =>
      scrollController.hasClients ? scrollController.offset : 0;

  @override
  void initState() {
    super.initState();
    itemKeys.addAll(List.generate(widget.children.length, (_) => GlobalKey()));
    scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant UPIndexList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      itemKeys
        ..clear()
        ..addAll(List.generate(widget.children.length, (_) => GlobalKey()));
      if (activeIndex >= widget.children.length) {
        activeIndex = widget.children.isEmpty ? 0 : widget.children.length - 1;
      }
    }
  }

  @override
  void dispose() {
    _touchEndTimer?.cancel();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.hasClients) {
      scrollTop = scrollController.offset;
      scrollViewHeight = scrollController.position.viewportDimension;
      topOffset = UPUtils.getPx(widget.customNavHeight);
      pageY = scrollTop + topOffset;
      indicatorHeight = itemHeight > 0 ? itemHeight : 16;
      scrolling = true;
    }
    if (touching) return;
    for (var i = itemKeys.length - 1; i >= 0; i--) {
      final ctx = itemKeys[i].currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) continue;
      final offset = box.localToGlobal(Offset.zero).dy;
      final threshold = UPUtils.getPx(widget.customNavHeight) + 32;
      if (offset <= threshold) {
        if (activeIndex != i) setState(() => activeIndex = i);
        break;
      }
    }
  }

  Future<void> jumpTo(int index, {bool animated = false}) async {
    final lettersLocal = letters;
    if (index >= 0 && index < lettersLocal.length) {
      scrollIntoView = '${lettersLocal[index]}';
    }
    await _jumpTo(index, animated: animated, emitSelect: true);
  }

  Future<void> jumpToLetter(dynamic letter, {bool animated = false}) async {
    final index = _letterIndexOf(letter);
    if (index < 0) return;
    await jumpTo(index, animated: animated);
  }

  Future<void> setActiveIndex(int index, {bool jump = true}) async {
    if (index < 0 || index >= itemKeys.length) return;
    if (jump) {
      await _jumpTo(index, animated: false, emitSelect: false);
      return;
    }
    if (activeIndex != index) setState(() => activeIndex = index);
  }

  /// Source letter list alias.
  List get uIndexList => letters;

  /// Source touch helpers.
  void touchStart([dynamic _]) {
    touching = true;
  }

  void touchMove(Offset local, double totalHeight) {
    touching = true;
    _onLetterTouch(local, totalHeight);
  }

  /// Source touch end alias.
  void touchEnd([dynamic _]) {
    _scheduleTouchEnd(holdMs: 50);
  }

  void onTouchStart([dynamic _]) => touchStart(_);
  void onTouchMove(Offset local, double totalHeight) =>
      touchMove(local, totalHeight);
  void onTouchEnd([dynamic _]) => touchEnd(_);

  String getIndexListLetter([int? index]) {
    final i = index ?? activeIndex;
    if (letters.isEmpty) return '';
    return _letterText(letters[i.clamp(0, letters.length - 1)]);
  }

  /// Rect helpers (layout dependent; measured when available).
  Map letterRect = const {'width': 0.0, 'height': 0.0, 'left': 0.0, 'top': 0.0};
  Map scrollViewRect = const {
    'width': 0.0,
    'height': 0.0,
    'left': 0.0,
    'top': 0.0
  };
  Map listRect = const {'width': 0.0, 'height': 0.0, 'left': 0.0, 'top': 0.0};
  Map headerRect = const {'width': 0.0, 'height': 0.0, 'left': 0.0, 'top': 0.0};
  Map letterInfo = const {};

  Map _measureBox(BuildContext? ctx) {
    if (ctx == null)
      return {'width': 0.0, 'height': 0.0, 'left': 0.0, 'top': 0.0};
    final box = ctx.findRenderObject() as RenderBox?;
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

  Map getIndexListLetterRect([dynamic _]) {
    letterRect = _measureBox(context);
    // Approximate letter rail as full height / letter count width 20.
    final h = (letterRect['height'] as num?)?.toDouble() ?? 0;
    final top = (letterRect['top'] as num?)?.toDouble() ?? 0;
    final left = ((letterRect['left'] as num?)?.toDouble() ?? 0) +
        (((letterRect['width'] as num?)?.toDouble() ?? 0) - 20).clamp(0, 10000);
    letterRect = {
      'width': 20.0,
      'height': h,
      'left': left,
      'top': top,
    };
    return Map<String, dynamic>.from(letterRect);
  }

  Map getIndexListScrollViewRect([dynamic _]) {
    scrollViewRect = _measureBox(context);
    return Map<String, dynamic>.from(scrollViewRect);
  }

  Map getIndexListRect([dynamic _]) {
    listRect = _measureBox(context);
    return Map<String, dynamic>.from(listRect);
  }

  void setIndexListLetterInfo([dynamic info]) {
    if (info is Map) {
      letterInfo = Map<String, dynamic>.from(info);
      return;
    }
    final rect = getIndexListLetterRect();
    final count = letters.isEmpty ? 1 : letters.length;
    final itemH = ((rect['height'] as num?)?.toDouble() ?? 0) / count;
    letterInfo = {
      'itemHeight': itemH,
      'count': count,
      'top': rect['top'],
      'height': rect['height'],
      'activeIndex': activeIndex,
      'activeLetter': activeLetter,
    };
  }

  Map getHeaderRect([dynamic _]) {
    if (widget.header == null) {
      headerRect = {'width': 0.0, 'height': 0.0, 'left': 0.0, 'top': 0.0};
      return Map<String, dynamic>.from(headerRect);
    }
    headerRect = _measureBox(context);
    return Map<String, dynamic>.from(headerRect);
  }

  /// Source `init`.
  void init() {
    activeIndex = 0;
    touching = false;
    scrolling = false;
    scrollTop = 0;
    if (mounted) setState(() {});
  }

  /// Source `scrollHandler` alias of internal scroll observer.
  void scrollHandler([dynamic _]) {
    final manual = _ is num ? _.toDouble() : null;
    _onScroll();
    if (manual != null) {
      scrollTop = manual;
      scrolling = true;
    }
  }

  /// Source `setValueForTouch` — map touch ratio (0..1) to active letter.
  void setValueForTouch(dynamic value, [double totalHeight = 1]) {
    final ratio = (num.tryParse('$value') ?? 0).toDouble().clamp(0.0, 1.0);
    final h = totalHeight <= 0 ? 1.0 : totalHeight;
    touchMove(Offset(0, ratio * h), h);
  }

  void scrollTo(double offset, {bool animated = false}) {
    if (!scrollController.hasClients) return;
    final target = offset.clamp(0.0, scrollController.position.maxScrollExtent);
    if (animated) {
      scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    } else {
      scrollController.jumpTo(target);
    }
  }

  void scrollToTop({bool animated = false}) => scrollTo(0, animated: animated);

  Future<void> _jumpTo(
    int index, {
    bool animated = false,
    bool emitSelect = true,
  }) async {
    if (index < 0 || index >= itemKeys.length) return;
    // Keep touching=true through the jump so scroll-spy does not overwrite.
    _touchEndTimer?.cancel();
    setState(() {
      activeIndex = index;
      touching = true;
    });
    if (emitSelect && letters.isNotEmpty) {
      final letter = letters[index.clamp(0, letters.length - 1)];
      widget.onSelect?.call(letter);
    }
    // Prefer immediate scroll; if layout not ready, try next frame.
    if (scrollController.hasClients) {
      _scrollToIndex(index, animated: animated);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToIndex(index, animated: animated);
      });
    }
    _scheduleTouchEnd(holdMs: animated ? 350 : 50);
  }

  void _scrollToIndex(int index, {bool animated = false}) {
    if (!scrollController.hasClients) return;
    double? target;
    final ctx = itemKeys[index].currentContext;
    if (ctx != null) {
      final box = ctx.findRenderObject() as RenderBox?;
      final listBox = scrollController.position.context.storageContext
          .findRenderObject() as RenderBox?;
      if (box != null && box.hasSize && listBox != null && listBox.hasSize) {
        final itemTop = box.localToGlobal(Offset.zero).dy;
        final listTop = listBox.localToGlobal(Offset.zero).dy;
        target = scrollController.offset + (itemTop - listTop);
      }
    }
    // Fallback: estimate from measured item heights when available.
    if (target == null) {
      var offset = 0.0;
      for (var i = 0; i < index && i < itemKeys.length; i++) {
        final c = itemKeys[i].currentContext;
        final b = c?.findRenderObject() as RenderBox?;
        offset += b != null && b.hasSize ? b.size.height : 120.0;
        offset += UPUtils.getPx(widget.itemMargin);
      }
      target = offset;
    }
    final clamped =
        target.clamp(0.0, scrollController.position.maxScrollExtent);
    if (animated) {
      scrollController.animateTo(
        clamped,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    } else {
      scrollController.jumpTo(clamped);
    }
  }

  int _letterIndexOf(dynamic letter) {
    final target = _letterText(letter);
    for (var i = 0; i < letters.length; i++) {
      if (_letterText(letters[i]) == target) return i;
    }
    return -1;
  }

  void _onLetterTouch(Offset local, double totalHeight) {
    final count = letters.length;
    if (count == 0) return;
    final itemH = totalHeight / count;
    final index = (local.dy / itemH).floor().clamp(0, count - 1);
    if (index != activeIndex) {
      _jumpTo(index, animated: false, emitSelect: true);
    }
  }

  void _scheduleTouchEnd({int holdMs = 300}) {
    _touchEndTimer?.cancel();
    _touchEndTimer = Timer(Duration(milliseconds: holdMs), () {
      if (mounted) setState(() => touching = false);
    });
  }

  String _letterText(dynamic item) {
    if (item is Map) return '${item['key'] ?? item['name'] ?? ''}';
    return '$item';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final inactive =
        UPUtils.parseColor(widget.inactiveColor) ?? tokens.contentColor;
    final active =
        UPUtils.parseColor(widget.activeColor) ?? const Color(0xFF5677FC);
    final letterList = letters;

    Widget root = Stack(
      children: [
        Positioned.fill(
          child: ListView(
            controller: scrollController,
            children: [
              if (widget.header != null) widget.header!,
              for (var i = 0; i < widget.children.length; i++)
                KeyedSubtree(
                  key: itemKeys[i],
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: UPUtils.getPx(widget.itemMargin),
                    ),
                    child: widget.children[i],
                  ),
                ),
              if (widget.footer != null) widget.footer!,
              if (widget.safeBottomFix)
                SizedBox(height: MediaQuery.paddingOf(context).bottom),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final letterAreaH = constraints.maxHeight * 0.6;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragDown: (d) =>
                    _onLetterTouch(d.localPosition, letterAreaH),
                onVerticalDragUpdate: (d) =>
                    _onLetterTouch(d.localPosition, letterAreaH),
                onVerticalDragEnd: (_) => _scheduleTouchEnd(),
                onVerticalDragCancel: _scheduleTouchEnd,
                onTapDown: (d) => _onLetterTouch(d.localPosition, letterAreaH),
                onTapUp: (_) => _scheduleTouchEnd(),
                onTapCancel: _scheduleTouchEnd,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < letterList.length; i++)
                        GestureDetector(
                          onTap: () => jumpTo(i),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 18,
                            height: 16,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: activeIndex == i ? active : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _letterText(letterList[i]),
                              style: TextStyle(
                                fontSize: 10,
                                color: activeIndex == i
                                    ? const Color(0xFFFFFFFF)
                                    : inactive,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (touching && letterList.isNotEmpty)
          Positioned(
            right: 50,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active.withValues(alpha: 0.85),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Text(
                  _letterText(
                    letterList[activeIndex.clamp(0, letterList.length - 1)],
                  ),
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
    return root;
  }
}

class UPIndexItem extends StatelessWidget {
  const UPIndexItem({
    super.key,
    required this.anchor,
    required this.children,
  });

  final UPIndexAnchor anchor;
  final List<Widget> children;

  /// Source index-item rect helper (Batch J).
  Map getIndexItemRect([dynamic _]) => const {
        'width': 0.0,
        'height': 0.0,
        'left': 0.0,
        'top': 0.0,
      };

  /// Source data: id.
  dynamic get id => '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        anchor,
        ...children,
      ],
    );
  }
}

class UPIndexAnchor extends StatelessWidget {
  const UPIndexAnchor({
    super.key,
    this.text = '',
    this.color = '#606266',
    this.size = 14,
    this.bgColor = '#f1f1f1',
    this.height = 32,
  });

  final dynamic text;
  final dynamic color;
  final dynamic size;
  final dynamic bgColor;
  final dynamic height;

  String get _displayText {
    final t = text;
    if (t is Map) return '${t['name'] ?? t['key'] ?? ''}';
    return '$t';
  }

  /// Source computed: parentSticky (no parent => true).
  bool get parentSticky => true;

  /// Source computed: resolvedBgColor.
  dynamic get resolvedBgColor {
    final c = '$bgColor';
    if (c == '#f1f1f1' || c == '#dedede') return '#f1f1f1';
    return bgColor;
  }

  /// Source computed: resolvedColor.
  dynamic get resolvedColor {
    final c = '$color';
    return c == '#606266' ? '#606266' : color;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final c = UPUtils.parseColor(color) ?? tokens.contentColor;
    final bg = UPUtils.parseColor(bgColor) ?? const Color(0xFFF1F1F1);
    return Container(
      height: UPUtils.getPx(height),
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      alignment: Alignment.centerLeft,
      child: Text(
        _displayText,
        style: TextStyle(
          color: c,
          fontSize: UPUtils.getPx(size),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
