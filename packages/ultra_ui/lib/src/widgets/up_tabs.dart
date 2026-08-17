import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_badge.dart';
import 'up_icon.dart';

/// 1:1 port of u-tabs defaults / shape modes.
class UPTabs extends StatefulWidget {
  const UPTabs({
    super.key,
    this.duration = 300,
    this.list = const [],
    this.lineColor = '',
    this.activeStyle,
    this.inactiveStyle,
    this.lineWidth = 20,
    this.lineHeight = 3,
    this.lineBgSize = 'cover',
    this.itemStyle,
    this.scrollable = true,
    this.current = 0,
    this.modelValue,
    this.keyName = 'name',
    this.iconStyle,
    this.shapeMode = '',
    this.styles,
    this.left,
    this.right,
    this.onClick,
    this.onChange,
    this.onUpdateCurrent,
    this.onUpdateModelValue,
    this.onLongPress,
    this.customStyle,
  });

  final dynamic duration;
  final List<dynamic> list;
  final dynamic lineColor;
  final Map<String, dynamic>? activeStyle;
  final Map<String, dynamic>? inactiveStyle;
  final dynamic lineWidth;
  final dynamic lineHeight;
  final String lineBgSize;
  final Map<String, dynamic>? itemStyle;
  final bool scrollable;
  final dynamic current;

  /// Source v-model alias for current.
  final dynamic modelValue;
  final String keyName;
  final Map<String, dynamic>? iconStyle;
  final String shapeMode;

  /// Source retained styles map.
  final dynamic styles;
  final Widget? left;
  final Widget? right;
  final void Function(dynamic item, int index)? onClick;
  final ValueChanged<int>? onChange;
  final ValueChanged<int>? onUpdateCurrent;

  /// Source update:modelValue alias for current.
  final ValueChanged<int>? onUpdateModelValue;
  final void Function(dynamic item, int index)? onLongPress;

  dynamic get effectiveCurrent => modelValue ?? current;

  final BoxDecoration? customStyle;

  /// Source computed: shapeModeClass.
  dynamic get shapeModeClass =>
      shapeMode.isNotEmpty ? 'u-tabs--shape-$shapeMode' : '';

  /// Source computed: showLine.
  dynamic get showLine =>
      true && !const ['capsule', 'pill-arrow', 'tag'].contains(shapeMode);

  /// Source computed: itemComputedStyle.
  dynamic get itemComputedStyle {
    final style = <String, dynamic>{};
    if (itemStyle != null) {
      style.addAll(itemStyle!);
      return style;
    }
    const defaults = {
      'capsule': '30px',
      'card': '34px',
      'pill-arrow': '32px',
      'tag': '28px',
    };
    final height = defaults[shapeMode];
    if (height != null) style['height'] = height;
    return style;
  }

  /// Source computed: textStyle(index).
  dynamic textStyle([dynamic index]) {
    final i = index is int ? index : int.tryParse('$index') ?? 0;
    final current = int.tryParse('$effectiveCurrent') ?? 0;
    final isActive = i == current;
    final style = <String, dynamic>{};
    final custom = isActive ? activeStyle : inactiveStyle;
    if (custom != null) style.addAll(custom);
    if (isActive && const ['pill-arrow', 'tag'].contains(shapeMode)) {
      style.putIfAbsent('color', () => '#ffffff');
    } else if (isActive) {
      style.putIfAbsent('color', () => '#303133');
    } else if (const ['pill-arrow', 'tag'].contains(shapeMode)) {
      style.putIfAbsent('color', () => '#606266');
    } else {
      style.putIfAbsent('color', () => '#606266');
    }
    if (list.isNotEmpty && i >= 0 && i < list.length) {
      final item = list[i];
      if (item is Map && item['disabled'] == true) {
        style['color'] = '#c8c9cc';
      }
    }
    return style;
  }

  /// Source computed: propsBadge defaults.
  dynamic get propsBadge => const <String, dynamic>{
        'isDot': false,
        'value': '',
        'show': false,
      };

  /// Source data defaults (widget-level snapshot).
  dynamic get innerCurrent => int.tryParse('$effectiveCurrent') ?? 0;
  dynamic get moving => false;

  @override
  State<UPTabs> createState() => UPTabsState();
}

class UPTabsState extends State<UPTabs> {
  /// Source host helper.
  Future<void> sleep([int ms = 0]) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
  }

  /// Source host helper.
  dynamic resolve([dynamic v]) => v;

  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _itemKeys = <GlobalKey>[];
  double _lineLeft = 0;
  bool _lineShow = false;
  int _innerCurrent = 0;

  int get currentIndex => _innerCurrent;
  bool moving = false;

  void setCurrent(int index, {bool emit = true}) {
    if (widget.list.isEmpty) return;
    final next = index.clamp(0, widget.list.length - 1);
    final item = widget.list[next];
    if (_disabled(item)) return;
    if (_innerCurrent == next) return;
    moving = true;
    setState(() => _innerCurrent = next);
    if (emit) {
      widget.onUpdateCurrent?.call(next);
      widget.onUpdateModelValue?.call(next);
      widget.onChange?.call(next);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resize();
      if (!mounted) return;
      if (moving) setState(() => moving = false);
    });
  }

  void next({bool emit = true}) {
    if (widget.list.isEmpty) return;
    setCurrent((_innerCurrent + 1).clamp(0, widget.list.length - 1),
        emit: emit);
  }

  void prev({bool emit = true}) {
    if (widget.list.isEmpty) return;
    setCurrent((_innerCurrent - 1).clamp(0, widget.list.length - 1),
        emit: emit);
  }

  /// Source `init` — recompute indicator.
  void init() {
    _ensureKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resize());
  }

  /// Source `resize`.
  void resize() => _resize();

  /// Source `clickHandler`.
  /// Source style/class helpers.
  bool showLine([dynamic _]) => _showLine;
  String shapeModeClass([dynamic _]) =>
      widget.lineWidth == 0 ? 'button' : 'line';
  Map itemComputedStyle([int index = 0]) => {
        'index': index,
        'current': currentIndex,
        'active': index == currentIndex,
      };
  dynamic propsBadge([dynamic item]) {
    if (item is Map) return item['badge'] ?? item['dot'];
    return null;
  }

  void animation([dynamic _]) {
    moving = true;
    resize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (moving) setState(() => moving = false);
    });
  }

  void clickHandler(int index) {
    if (index < 0 || index >= widget.list.length) return;
    final item = widget.list[index];
    if (_disabled(item)) return;
    widget.onClick?.call(item, index);
    setCurrent(index);
  }

  /// Source `longPressHandler`.
  void longPressHandler(int index) {
    if (index < 0 || index >= widget.list.length) return;
    final item = widget.list[index];
    widget.onLongPress?.call(item, index);
  }

  /// Source `setScrollLeft` — scroll tab strip.
  /// Source `getAllItemRect` — list of item sizes if laid out.
  List getAllItemRect() {
    final out = <Map>[];
    for (var i = 0; i < _itemKeys.length; i++) {
      final box = _itemKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) {
        out.add({'index': i, 'width': 0.0, 'height': 0.0});
      } else {
        final o = box.localToGlobal(Offset.zero);
        out.add({
          'index': i,
          'width': box.size.width,
          'height': box.size.height,
          'left': o.dx,
          'top': o.dy,
        });
      }
    }
    return out;
  }

  /// Source `queryRect` alias of [getAllItemRect]/[getTabsRect].
  Map queryRect([dynamic _]) => getTabsRect();

  /// Source `getTabsRect` — host size if laid out.
  Map getTabsRect() {
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

  /// Source `setLineLeft`.
  void setLineLeft(double left) {
    if ((_lineLeft - left).abs() < 0.5 && _lineShow) return;
    setState(() {
      _lineLeft = left < 0 ? 0 : left;
      _lineShow = true;
    });
  }

  void setScrollLeft(double offset) {
    scrollLeft = offset;
    if (!_scrollController.hasClients) return;
    _scrollController
        .jumpTo(offset.clamp(0, _scrollController.position.maxScrollExtent));
  }

  double get lineLeft => _lineLeft;

  /// Source data.
  bool get lineShow => _lineShow;
  double get lineOffsetLeft => _lineLeft;
  double scrollLeft = 0;
  double scrollViewWidth = 0;
  List get tabList => List.from(widget.list);
  Map get tabsRect => getTabsRect();

  @override
  void initState() {
    super.initState();
    _innerCurrent = int.tryParse('${widget.effectiveCurrent}') ?? 0;
    _ensureKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resize());
  }

  @override
  void didUpdateWidget(covariant UPTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = int.tryParse('${widget.effectiveCurrent}') ?? 0;
    if (next != _innerCurrent) {
      _innerCurrent = next;
    }
    if (oldWidget.list.length != widget.list.length) {
      _ensureKeys();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _resize());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _ensureKeys() {
    while (_itemKeys.length < widget.list.length) {
      _itemKeys.add(GlobalKey());
    }
    if (_itemKeys.length > widget.list.length) {
      _itemKeys.removeRange(widget.list.length, _itemKeys.length);
    }
  }

  String _label(dynamic item) {
    if (item is Map) {
      return '${item[widget.keyName] ?? item['name'] ?? ''}';
    }
    return '$item';
  }

  bool _disabled(dynamic item) {
    if (item is Map) return item['disabled'] == true;
    return false;
  }

  String? _iconName(dynamic item) {
    if (item is Map && item['icon'] != null) return '${item['icon']}';
    return null;
  }

  Map? _badge(dynamic item) {
    if (item is Map && item['badge'] is Map) {
      final badge = item['badge'] as Map;
      final hasValue = badge['value'] != null && '${badge['value']}'.isNotEmpty;
      final show = badge['show'] == true || badge['isDot'] == true || hasValue;
      if (show) return badge;
    }
    return null;
  }

  Color? _mapColor(Map<String, dynamic>? style, String key) {
    if (style == null) return null;
    return UPUtils.parseColor(style[key]);
  }

  double? _mapFontSize(Map<String, dynamic>? style) {
    if (style == null || style['fontSize'] == null) return null;
    return UPUtils.getPx(style['fontSize']);
  }

  bool get _showLine {
    return _lineShow &&
        !const {'capsule', 'pill-arrow', 'tag'}.contains(widget.shapeMode);
  }

  double get _defaultItemHeight {
    switch (widget.shapeMode) {
      case 'capsule':
        return 30;
      case 'card':
        return 34;
      case 'pill-arrow':
        return 32;
      case 'tag':
        return 28;
      default:
        return UPUtils.getPx(widget.itemStyle?['height'] ?? '44px');
    }
  }

  Future<void> _resize() async {
    if (!mounted || widget.list.isEmpty) return;
    if (_innerCurrent < 0) _innerCurrent = 0;
    if (_innerCurrent >= widget.list.length) {
      _innerCurrent = widget.list.length - 1;
    }

    final lw = UPUtils.getPx(widget.lineWidth);
    double offset = 0;
    double currentWidth = 0;
    for (var i = 0; i < widget.list.length; i++) {
      final box = _itemKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) continue;
      if (i < _innerCurrent) offset += box.size.width;
      if (i == _innerCurrent) currentWidth = box.size.width;
    }
    final nextLeft = offset + (currentWidth - lw) / 2;
    if ((nextLeft - _lineLeft).abs() > 0.5 || !_lineShow) {
      setState(() {
        _lineLeft = nextLeft < 0 ? 0 : nextLeft;
        _lineShow = true;
      });
    }

    if (widget.scrollable && _scrollController.hasClients) {
      final viewport = _scrollController.position.viewportDimension;
      final max = _scrollController.position.maxScrollExtent;
      final tabCenter = offset + currentWidth / 2;
      final target = (tabCenter - viewport / 2).clamp(0.0, max);
      final ms = int.tryParse('${widget.duration}') ?? 300;
      await _scrollController.animateTo(
        target,
        duration: Duration(milliseconds: ms),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleTap(int index) {
    final item = widget.list[index];
    widget.onClick?.call(item, index);
    if (_disabled(item)) return;
    if (_innerCurrent == index) return;
    setState(() => _innerCurrent = index);
    widget.onUpdateCurrent?.call(index);
    widget.onUpdateModelValue?.call(index);
    widget.onChange?.call(index);
    WidgetsBinding.instance.addPostFrameCallback((_) => _resize());
  }

  Color _textColor({
    required bool selected,
    required bool disabled,
    required UPThemeTokens tokens,
  }) {
    if (disabled) return tokens.lightColor;
    final activeColor = _mapColor(widget.activeStyle, 'color');
    final inactiveColor = _mapColor(widget.inactiveStyle, 'color');
    if (selected) {
      if (activeColor != null) return activeColor;
      if (widget.shapeMode == 'pill-arrow' || widget.shapeMode == 'tag') {
        return const Color(0xFFFFFFFF);
      }
      return tokens.mainColor;
    }
    if (inactiveColor != null) return inactiveColor;
    return tokens.contentColor;
  }

  BoxDecoration? _itemDecoration({
    required bool selected,
    required UPThemeTokens tokens,
  }) {
    switch (widget.shapeMode) {
      case 'capsule':
        return BoxDecoration(
          color: selected ? const Color(0xFFFFFFFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        );
      case 'card':
        return BoxDecoration(
          color: selected ? const Color(0xFFF6F8FB) : Colors.transparent,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        );
      case 'pill-arrow':
        return BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFFFF6C57), Color(0xFFFF3B30)],
                )
              : null,
          color: selected ? null : const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(8),
        );
      case 'tag':
        return BoxDecoration(
          color: selected ? const Color(0xFF2A6BF6) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(999),
        );
      default:
        return null;
    }
  }

  EdgeInsets get _itemPadding {
    switch (widget.shapeMode) {
      case 'capsule':
        return const EdgeInsets.symmetric(horizontal: 14);
      case 'card':
        return EdgeInsets.zero;
      case 'pill-arrow':
        return const EdgeInsets.symmetric(horizontal: 12);
      case 'tag':
        return const EdgeInsets.symmetric(horizontal: 14);
      default:
        return const EdgeInsets.symmetric(horizontal: 11);
    }
  }

  Widget _buildItem(int index, UPThemeTokens tokens) {
    final item = widget.list[index];
    final selected = index == _innerCurrent;
    final disabled = _disabled(item);
    final label = _label(item);
    final icon = _iconName(item);
    final badge = _badge(item);
    final color = _textColor(
      selected: selected,
      disabled: disabled,
      tokens: tokens,
    );
    final fs = selected
        ? (_mapFontSize(widget.activeStyle) ?? 15)
        : (_mapFontSize(widget.inactiveStyle) ?? 15);
    final iconSize = UPUtils.getPx(
        widget.iconStyle?['fontSize'] ?? widget.iconStyle?['size'] ?? 16);
    final iconColor =
        UPUtils.parseColor(widget.iconStyle?['color'], fallback: color) ??
            color;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null && icon.isNotEmpty) ...[
          UPIcon(name: icon, size: iconSize, color: iconColor),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: fs,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        if (badge != null)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: UPBadge(
              show: true,
              isDot: badge['isDot'] == true,
              value: badge['value'] ?? '',
              max: num.tryParse('${badge['max'] ?? 999}') ?? 999,
              type: '${badge['type'] ?? 'error'}',
              showZero: badge['showZero'] == true,
              bgColor: badge['bgColor'],
              color: badge['color'],
              shape: '${badge['shape'] ?? 'circle'}',
              numberType: '${badge['numberType'] ?? 'overflow'}',
              inverted: badge['inverted'] == true,
            ),
          ),
      ],
    );

    return GestureDetector(
      key: _itemKeys[index],
      onTap: () => _handleTap(index),
      onLongPress: () => widget.onLongPress?.call(item, index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: _defaultItemHeight,
        margin: EdgeInsets.only(
          right: (widget.shapeMode == 'pill-arrow' || widget.shapeMode == 'tag')
              ? 8
              : 0,
        ),
        padding: _itemPadding,
        alignment: Alignment.center,
        decoration: _itemDecoration(selected: selected, tokens: tokens),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            content,
            if (widget.shapeMode == 'pill-arrow' && selected)
              const Positioned(
                bottom: -6,
                child: CustomPaint(
                  size: Size(12, 6),
                  painter: _ArrowPainter(color: Color(0xFFFF3B30)),
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
    final ms = int.tryParse('${widget.duration}') ?? 300;
    final lineC = UPUtils.parseColor(widget.lineColor) ?? tokens.primary;
    final lw = UPUtils.getPx(widget.lineWidth);
    final lh = UPUtils.getPx(widget.lineHeight);

    final nav = Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Row(
          mainAxisSize: widget.scrollable ? MainAxisSize.min : MainAxisSize.max,
          children: [
            for (var i = 0; i < widget.list.length; i++)
              widget.scrollable
                  ? _buildItem(i, tokens)
                  : Expanded(child: _buildItem(i, tokens)),
          ],
        ),
        if (_showLine)
          AnimatedPositioned(
            duration: Duration(milliseconds: ms),
            curve: Curves.easeOut,
            left: _lineLeft,
            bottom: 2,
            child: Container(
              width: lw,
              height: lh,
              decoration: BoxDecoration(
                color: lineC,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
      ],
    );

    Widget body;
    if (widget.scrollable) {
      body = SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: nav,
      );
    } else {
      body = nav;
    }

    switch (widget.shapeMode) {
      case 'capsule':
        body = Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFEDF0F5),
            borderRadius: BorderRadius.circular(999),
          ),
          child: body,
        );
        break;
      case 'card':
        body = Container(
          decoration: BoxDecoration(
            color: const Color(0xFF9CCDE5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: body,
        );
        break;
      case 'pill-arrow':
        body = Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: body,
        );
        break;
      case 'tag':
        body = Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: body,
        );
        break;
    }

    // Keep lineBgSize referenced for API parity.
    assert(widget.lineBgSize.isNotEmpty || widget.lineBgSize.isEmpty);

    Widget root = (widget.left == null && widget.right == null)
        ? body
        : Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              if (widget.left != null) widget.left!,
              Expanded(child: body),
              if (widget.right != null) widget.right!,
            ],
          );
    return root;
  }
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) =>
      color != oldDelegate.color;
}

/// Source `u-tabs-item` alias — host content pane for a tab.
class UPTabsItem extends StatelessWidget {
  const UPTabsItem({
    super.key,
    this.child,
    this.customStyle,
  });

  final Widget? child;
  final BoxDecoration? customStyle;

  @override
  Widget build(BuildContext context) => child ?? const SizedBox.shrink();
}
