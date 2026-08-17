import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_cell.dart';
import 'up_icon.dart';

class UPDropdown extends StatefulWidget {
  const UPDropdown({
    super.key,
    this.activeColor = '#2979ff',
    this.inactiveColor = '#606266',
    this.closeOnClickMask = true,
    this.closeOnClickSelf = true,
    this.duration = 300,
    this.height = 40,
    this.borderBottom = false,
    this.titleSize = 14,
    this.borderRadius = 0,
    this.menuIcon = 'arrow-down',
    this.menuIconSize = 14,
    this.onOpen,
    this.onClose,
    required this.children,
    this.contentStyle,
    this.customStyle,
  });

  final dynamic activeColor;
  final dynamic inactiveColor;
  final bool closeOnClickMask;
  final bool closeOnClickSelf;
  final dynamic duration;
  final dynamic height;
  final bool borderBottom;
  final dynamic titleSize;
  final dynamic borderRadius;
  final String menuIcon;
  final dynamic menuIconSize;
  final ValueChanged<int>? onOpen;
  final ValueChanged<int>? onClose;
  final List<UPDropdownItem> children;

  /// Source retained dropdown content style.
  final dynamic contentStyle;

  final BoxDecoration? customStyle;

  /// Source computed: resolvedActiveColor.
  dynamic get resolvedActiveColor {
    final c = '$activeColor';
    return c == '#2979ff' ? '#2979ff' : activeColor;
  }

  /// Source computed: resolvedInactiveColor.
  dynamic get resolvedInactiveColor {
    final c = '$inactiveColor';
    return c == '#606266' ? '#606266' : inactiveColor;
  }

  /// Source computed: menuDisabledColor.
  dynamic get menuDisabledColor => '#c0c4cc';

  /// Source computed: popupStyle (widget-level assumes inactive).
  dynamic get popupStyle {
    final d = num.tryParse('$duration') ?? 300;
    return <String, dynamic>{
      'transform': 'translateY(-100%)',
      'transition-duration': '${d / 1000}s',
      'borderRadius':
          '0 0 ${UPUtils.addUnit(borderRadius)} ${UPUtils.addUnit(borderRadius)}',
    };
  }

  /// Source data defaults (widget-level snapshot).
  dynamic get contentHeight => 0;
  dynamic get highlightIndexList => const <dynamic>[];

  @override
  State<UPDropdown> createState() => UPDropdownState();
}

class UPDropdownState extends State<UPDropdown> {
  /// Source host helper.
  Future<void> setTimeout([dynamic cb, int ms = 0]) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
    if (cb is Function) cb();
  }

  int current = -1;

  /// Source data.
  List menuList = const [];
  double opacity = 1;
  bool get showDropdown => current >= 0;
  dynamic zIndex;

  final Set<int> _highlightIndexes = <int>{};
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _menuKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  Size _menuSize = Size.zero;

  int get _ms => int.tryParse('${widget.duration}') ?? 300;
  int get currentIndex => current;
  bool get isOpen => current >= 0;
  Set<int> get highlightIndexes => Set<int>.from(_highlightIndexes);

  /// Source data alias of highlight indexes as list.
  List get highlightIndexList => (_highlightIndexes.toList()..sort());

  List<Map<String, dynamic>> _buildMenuList() => [
        for (final item in widget.children)
          <String, dynamic>{
            'title': item.title,
            'disabled': item.disabled,
          },
      ];

  @override
  void initState() {
    super.initState();
    menuList = _buildMenuList();
  }

  @override
  void didUpdateWidget(covariant UPDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    menuList = _buildMenuList();
    _overlayEntry?.markNeedsBuild();
  }

  /// Source `init` — rebuild child menu metadata without resetting UI state.
  void init() {
    setState(() => menuList = _buildMenuList());
  }

  void toggle(int index) {
    if (index == current) {
      close();
    } else {
      open(index);
    }
  }

  void open(int index) {
    if (index < 0 || index >= widget.children.length) return;
    setState(() => current = index);
    widget.onOpen?.call(index);
    getContentHeight();
    _showOverlay();
  }

  void close() {
    final prev = current;
    _removeOverlay();
    setState(() => current = -1);
    widget.onClose?.call(prev);
  }

  /// Source `maskClick`.
  void maskClick() {
    if (widget.closeOnClickMask) close();
  }

  /// Source `getContentHeight` — windowHeight - menu bottom.
  double contentHeightLocal = 0;
  double get contentHeight => contentHeightLocal;

  double getContentHeight() {
    final box = _menuKey.currentContext?.findRenderObject() as RenderBox? ??
        context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return contentHeightLocal;
    final offset = box.localToGlobal(Offset.zero);
    _menuSize = box.size;
    final menuBottom = offset.dy + box.size.height;
    final windowHeight = MediaQuery.sizeOf(context).height;
    contentHeightLocal = (windowHeight - menuBottom).clamp(0.0, windowHeight);
    return contentHeightLocal;
  }

  void _showOverlay() {
    if (!mounted || current < 0) return;
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
      return;
    }
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    _overlayEntry = OverlayEntry(builder: _buildOverlay);
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildOverlay(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final active =
        UPUtils.parseColor(widget.activeColor) ?? const Color(0xFF2979FF);
    final inactive =
        UPUtils.parseColor(widget.inactiveColor) ?? tokens.contentColor;
    final radius = UPUtils.getPx(widget.borderRadius);
    final width = _menuSize.width > 0
        ? _menuSize.width
        : MediaQuery.sizeOf(context).width;
    final height = contentHeightLocal > 0
        ? contentHeightLocal
        : MediaQuery.sizeOf(context).height;

    return CompositedTransformFollower(
      link: _layerLink,
      showWhenUnlinked: false,
      targetAnchor: Alignment.bottomLeft,
      followerAnchor: Alignment.topLeft,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                key: const ValueKey('up-dropdown-mask'),
                behavior: HitTestBehavior.opaque,
                onTap: maskClick,
                child: const ColoredBox(color: Color(0x4D000000)),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: width,
                constraints: BoxConstraints(maxHeight: height),
                decoration: BoxDecoration(
                  color: tokens.cardBgColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(radius),
                    bottomRight: Radius.circular(radius),
                  ),
                ),
                child: _UPDropdownScope(
                  activeColor: active,
                  inactiveColor: inactive,
                  close: close,
                  child: widget.children[current],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void menuClick(int index) {
    final item = widget.children[index];
    if (item.disabled) return;
    if (index == current && widget.closeOnClickSelf) {
      close();
      return;
    }
    open(index);
  }

  void highlight([dynamic indexParams]) {
    setState(() {
      _highlightIndexes.clear();
      if (indexParams is List) {
        _highlightIndexes.addAll(
            indexParams.map((e) => int.tryParse('$e')).whereType<int>());
      } else if (indexParams != null) {
        final index = int.tryParse('$indexParams');
        if (index != null) _highlightIndexes.add(index);
      }
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final active =
        UPUtils.parseColor(widget.activeColor) ?? const Color(0xFF2979FF);
    final inactive =
        UPUtils.parseColor(widget.inactiveColor) ?? tokens.contentColor;
    final h = UPUtils.getPx(widget.height);
    final titleSize = UPUtils.getPx(widget.titleSize);
    final iconSize = UPUtils.getPx(widget.menuIconSize);

    Widget root = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CompositedTransformTarget(
          link: _layerLink,
          child: Container(
            key: _menuKey,
            height: h,
            decoration: BoxDecoration(
              color: tokens.cardBgColor,
              border: widget.borderBottom
                  ? Border(
                      bottom: BorderSide(color: tokens.borderColor, width: 0.5),
                    )
                  : null,
            ),
            child: Row(
              children: [
                for (var i = 0; i < widget.children.length; i++)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => menuClick(i),
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              '${widget.children[i].title}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: widget.children[i].disabled
                                    ? tokens.disabledColor
                                    : (i == current ||
                                            _highlightIndexes.contains(i)
                                        ? active
                                        : inactive),
                                fontSize: titleSize,
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          AnimatedRotation(
                            turns: i == current ? 0.5 : 0,
                            duration: Duration(milliseconds: _ms),
                            child: UPIcon(
                              name: widget.menuIcon,
                              size: iconSize,
                              color:
                                  i == current || _highlightIndexes.contains(i)
                                      ? active
                                      : tokens.disabledColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );

    return root;
  }
}

class _UPDropdownScope extends InheritedWidget {
  const _UPDropdownScope({
    required this.activeColor,
    required this.inactiveColor,
    required this.close,
    required super.child,
  });

  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback close;

  static _UPDropdownScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_UPDropdownScope>();

  @override
  bool updateShouldNotify(covariant _UPDropdownScope oldWidget) {
    return activeColor != oldWidget.activeColor ||
        inactiveColor != oldWidget.inactiveColor;
  }
}

class UPDropdownItem extends StatelessWidget {
  const UPDropdownItem({
    super.key,
    this.value,
    this.modelValue,
    this.title = '',
    this.options = const [],
    this.disabled = false,
    this.height = 'auto',
    this.closeOnClickOverlay = true,
    this.closeOnClickOption = true,
    this.onChange,
    this.onUpdateValue,
    this.onUpdateModelValue,
    this.child,
    this.onInput,
  });

  /// Source emit alias: input -> onInput.
  final ValueChanged<dynamic>? onInput;

  final dynamic value;

  /// Source v-model / modelValue alias.
  final dynamic modelValue;
  final dynamic title;
  final List options;
  final bool disabled;
  final dynamic height;
  final bool closeOnClickOverlay;
  final bool closeOnClickOption;
  final ValueChanged<dynamic>? onChange;
  final ValueChanged<dynamic>? onUpdateValue;

  /// Source update:modelValue alias.
  final ValueChanged<dynamic>? onUpdateModelValue;
  final Widget? child;
  dynamic get effectiveValue => modelValue ?? value;

  /// Source cell click helper.
  void cellClick([dynamic value]) {
    onUpdateValue?.call(value);
    onUpdateModelValue?.call(value);
    onInput?.call(value);
    onChange?.call(value);
  }

  /// Source computed: propsChange.
  dynamic propsChange([dynamic v]) => '$title-$disabled';

  @override
  Widget build(BuildContext context) {
    final scope = _UPDropdownScope.of(context);
    if (child != null) return child!;

    final h = '$height' == 'auto' ? null : UPUtils.getPx(height);
    final items = options.map((e) {
      if (e is Map) return e;
      return {'label': '$e', 'value': e};
    }).toList();

    return SizedBox(
      height: h,
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final item in items)
            UPCell(
              title: '${item['label'] ?? ''}',
              isLink: false,
              border: true,
              titleStyle: TextStyle(
                color: effectiveValue == item['value']
                    ? scope?.activeColor ?? const Color(0xFF2979FF)
                    : scope?.inactiveColor ?? const Color(0xFF606266),
              ),
              valueSlot: effectiveValue == item['value']
                  ? UPIcon(
                      name: 'checkbox-mark',
                      size: 16,
                      color: scope?.activeColor ?? const Color(0xFF2979FF),
                    )
                  : null,
              onClick: () {
                onUpdateValue?.call(item['value']);
                onUpdateModelValue?.call(item['value']);
                onInput?.call(item['value']);
                scope?.close();
                onChange?.call(item['value']);
              },
            ),
        ],
      ),
    );
  }
}
