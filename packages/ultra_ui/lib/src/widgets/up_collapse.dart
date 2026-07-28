import 'dart:async';

import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import 'up_icon.dart';
import 'up_layout.dart';

final Expando<Map<String, dynamic>> _upCollapseItemState =
    Expando<Map<String, dynamic>>('upCollapseItemState');

class UPCollapse extends StatefulWidget {
  const UPCollapse({
    super.key,
    this.value,
    this.modelValue,
    this.accordion = false,
    this.border = true,
    this.onChange,
    this.onOpen,
    this.onClose,
    required this.children,
    this.customStyle,
    this.onUpdateValue,
    this.onUpdateModelValue,
  });

  final dynamic value;
  final dynamic modelValue;
  final bool accordion;
  final bool border;
  final ValueChanged<dynamic>? onChange;
  final ValueChanged<dynamic>? onOpen;
  final ValueChanged<dynamic>? onClose;
  final List<Widget> children;

  final BoxDecoration? customStyle;
  final ValueChanged<dynamic>? onUpdateValue;
  final ValueChanged<dynamic>? onUpdateModelValue;
  dynamic get effectiveValue => modelValue ?? value;

  /// Source computed: needInit.
  dynamic get needInit => <dynamic>[accordion, effectiveValue];

  @override
  State<UPCollapse> createState() => UPCollapseState();
}

class UPCollapseState extends State<UPCollapse> {
  late dynamic _activeValue;
  late Set<int> _expandedIndexes;

  dynamic get activeValue => _activeValue;

  void open(dynamic name) {
    final index = _indexForName(name);
    if (index != null) _setItemOpen(index, true);
  }

  void close(dynamic name) {
    final index = _indexForName(name);
    if (index != null) _setItemOpen(index, false);
  }

  void toggle(dynamic name) {
    final index = _indexForName(name);
    if (index != null) _toggleIndex(index);
  }

  void setValue(dynamic value) {
    _setExpandedFromValue(value);
    if (mounted) setState(() {});
    widget.onUpdateValue?.call(_activeValue);
    widget.onUpdateModelValue?.call(_activeValue);
    _emitChange();
  }

  /// Source `init`.
  void init() {
    _setExpandedFromValue(widget.effectiveValue);
    if (mounted) setState(() {});
  }

  /// Source item helpers (Batch I).
  void clickHandler([dynamic name]) {
    if (name == null) return;
    toggle(name);
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

  bool animating = false;
  Timer? _animateTimer;
  void setContentAnimate([dynamic name]) {
    _animateTimer?.cancel();
    if (mounted) {
      setState(() => animating = true);
    } else {
      animating = true;
    }
    // Flutter AnimatedSize handles visual transition; clear flag after duration-ish.
    _animateTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => animating = false);
    });
  }

  @override
  void dispose() {
    _animateTimer?.cancel();
    super.dispose();
  }

  void updateParentData([dynamic _]) {
    // Descendants read parent options from the inherited scope on rebuild.
    if (mounted) setState(() {});
  }

  /// Source `onChange`: toggle the target item and emit all item statuses.
  void onChange([dynamic target]) {
    if (target == null) {
      _emitChange();
      return;
    }
    if (target is UPCollapseItem) {
      final index = _indexForItem(target);
      if (index != null) _toggleIndex(index);
      return;
    }
    toggle(target is Map ? target['name'] : target);
  }

  @override
  void initState() {
    super.initState();
    _setExpandedFromValue(widget.effectiveValue);
  }

  @override
  void didUpdateWidget(covariant UPCollapse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.effectiveValue != widget.effectiveValue ||
        oldWidget.accordion != widget.accordion ||
        oldWidget.children != widget.children) {
      _setExpandedFromValue(widget.effectiveValue);
    }
  }

  dynamic _normalize(dynamic value) {
    if (widget.accordion) {
      if (value is List) return value.isEmpty ? null : value.first;
      return value;
    }
    if (value is List) return List<dynamic>.from(value);
    if (value == null || value == '') return <dynamic>[];
    return <dynamic>[value];
  }

  void _toggleIndex(int index) =>
      _setItemOpen(index, !_expandedIndexes.contains(index));

  void _setItemOpen(int index, bool opened) {
    if (!_isCollapseIndex(index)) return;
    if (_expandedIndexes.contains(index) == opened) return;
    final next = Set<int>.from(_expandedIndexes);
    if (widget.accordion && opened)
      next
        ..clear()
        ..add(index);
    else if (opened) {
      next.add(index);
    } else {
      next.remove(index);
    }
    _commitExpanded(next, index: index, opened: opened);
  }

  void _commitExpanded(
    Set<int> next, {
    required int index,
    required bool opened,
  }) {
    _expandedIndexes = next;
    _activeValue = _valueFromExpanded(next);
    if (mounted) setState(() {});
    _emitChange();
    widget.onUpdateValue?.call(_activeValue);
    widget.onUpdateModelValue?.call(_activeValue);
    final item = widget.children[index] as UPCollapseItem;
    if (opened) {
      widget.onOpen?.call(item.name);
    } else {
      widget.onClose?.call(item.name);
    }
  }

  void _setExpandedFromValue(dynamic value) {
    final normalized = _normalize(value);
    _activeValue = normalized;
    _expandedIndexes = <int>{};
    for (var index = 0; index < widget.children.length; index++) {
      final child = widget.children[index];
      if (child is! UPCollapseItem) continue;
      final selected = widget.accordion
          ? normalized != null && child.name == normalized
          : normalized is List && normalized.contains(child.name);
      if (selected) _expandedIndexes.add(index);
    }
  }

  dynamic _valueFromExpanded(Set<int> indexes) {
    if (widget.accordion) {
      if (indexes.isEmpty) return null;
      final index = indexes.first;
      return (widget.children[index] as UPCollapseItem).name;
    }
    return <dynamic>[
      for (var index = 0; index < widget.children.length; index++)
        if (indexes.contains(index))
          (widget.children[index] as UPCollapseItem).name,
    ];
  }

  int? _indexForName(dynamic name) {
    for (var index = 0; index < widget.children.length; index++) {
      final child = widget.children[index];
      if (child is UPCollapseItem && child.name == name) return index;
    }
    return null;
  }

  int? _indexForItem(UPCollapseItem item) {
    for (var index = 0; index < widget.children.length; index++) {
      if (identical(widget.children[index], item)) return index;
    }
    return null;
  }

  bool _isCollapseIndex(int index) =>
      index >= 0 &&
      index < widget.children.length &&
      widget.children[index] is UPCollapseItem;

  bool _isOpenIndex(int index) => _expandedIndexes.contains(index);

  void _toggleItem(int index) => _toggleIndex(index);

  void _setOpenItem(int index, bool opened) => _setItemOpen(index, opened);

  void _emitChange() {
    widget.onChange?.call(_changePayload());
  }

  List<Map<String, dynamic>> _changePayload() {
    final payload = <Map<String, dynamic>>[];
    for (var index = 0; index < widget.children.length; index++) {
      final child = widget.children[index];
      if (child is! UPCollapseItem) continue;
      payload.add(<String, dynamic>{
        'name': _eventName(child.name, index),
        'status': _isOpenIndex(index) ? 'open' : 'close',
      });
    }
    return payload;
  }

  dynamic _eventName(dynamic name, int index) {
    if (name == null || name == '' || name == 0 || name == false) {
      return index;
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    Widget root = _UPCollapseScope(
      value: _activeValue,
      accordion: widget.accordion,
      border: widget.border,
      isOpenIndex: _isOpenIndex,
      onToggleIndex: _toggleItem,
      onSetOpenIndex: _setOpenItem,
      child: Column(
        children: [
          if (widget.border) const UPLine(),
          for (var index = 0; index < widget.children.length; index++)
            _UPCollapseItemSlot(
              index: index,
              child: widget.children[index],
            ),
        ],
      ),
    );

    return root;
  }
}

class _UPCollapseScope extends InheritedWidget {
  const _UPCollapseScope({
    required this.value,
    required this.accordion,
    required this.border,
    required this.isOpenIndex,
    required this.onToggleIndex,
    required this.onSetOpenIndex,
    required super.child,
  });

  final dynamic value;
  final bool accordion;
  final bool border;
  final bool Function(int index) isOpenIndex;
  final ValueChanged<int> onToggleIndex;
  final void Function(int index, bool opened) onSetOpenIndex;

  static _UPCollapseScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_UPCollapseScope>();

  @override
  bool updateShouldNotify(covariant _UPCollapseScope oldWidget) {
    return value != oldWidget.value ||
        accordion != oldWidget.accordion ||
        border != oldWidget.border;
  }
}

class _UPCollapseItemSlot extends InheritedWidget {
  const _UPCollapseItemSlot({required this.index, required super.child});

  final int index;

  static int? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_UPCollapseItemSlot>()?.index;

  @override
  bool updateShouldNotify(covariant _UPCollapseItemSlot oldWidget) =>
      index != oldWidget.index;
}

class UPCollapseItem extends StatelessWidget {
  const UPCollapseItem({
    super.key,
    this.title = '',
    this.value = '',
    this.label = '',
    this.disabled = false,
    this.isLink = true,
    this.clickable = true,
    this.border = true,
    this.align = 'left',
    this.name = '',
    this.icon = '',
    this.duration = 300,
    this.showRight = true,
    this.child,
    this.titleWidget,
    this.iconWidget,
    this.rightIconWidget,
    this.customStyle,
    this.cellCustomClass = '',
    this.cellCustomStyle,
    this.iconStyle,
    this.rightIconStyle,
    this.titleStyle,
  });
  final String cellCustomClass;
  final dynamic cellCustomStyle;
  final dynamic iconStyle;
  final dynamic rightIconStyle;
  final dynamic titleStyle;

  final String title;
  final String value;
  final String label;
  final bool disabled;
  final bool isLink;
  final bool clickable;
  final bool border;
  final String align;
  final dynamic name;
  final String icon;
  final dynamic duration;
  final bool showRight;
  final Widget? child;
  final Widget? titleWidget;
  final Widget? iconWidget;
  final Widget? rightIconWidget;

  final BoxDecoration? customStyle;

  /// Source data defaults (runtime filled during build).
  Map<String, dynamic> get _state =>
      _upCollapseItemState[this] ??= <String, dynamic>{
        'animating': false,
        'expanded': false,
        'showBorder': false,
        'parentData': const <String, dynamic>{
          'accordion': false,
          'border': false,
        },
      };
  dynamic get animating => _state['animating'] == true;
  dynamic get animationData => <String, dynamic>{
        'duration': duration,
        'expanded': expanded == true,
        'name': name,
      };
  dynamic get elId => 'up-collapse-item';
  dynamic get expanded => _state['expanded'] == true;
  dynamic get showBorder => _state['showBorder'] == true;
  dynamic get parentData =>
      _state['parentData'] ??
      const <String, dynamic>{
        'accordion': false,
        'border': false,
      };

  @override
  Widget build(BuildContext context) {
    final scope = _UPCollapseScope.of(context);
    final itemIndex = _UPCollapseItemSlot.of(context);
    final tokens = UPThemeTokens.of(context);
    final open = itemIndex != null && (scope?.isOpenIndex(itemIndex) ?? false);
    final showBorder = border && (scope?.border ?? false) && open;
    _state['expanded'] = open;
    _state['showBorder'] = showBorder;
    _state['parentData'] = <String, dynamic>{
      'accordion': scope?.accordion ?? false,
      'border': scope?.border ?? false,
    };
    final ms = int.tryParse('$duration') ?? 300;

    Widget root = Column(
      children: [
        GestureDetector(
          onTap: !clickable || (disabled && animating)
              ? null
              : itemIndex == null
                  ? null
                  : () => scope?.onToggleIndex(itemIndex),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            decoration: cellCustomStyle is BoxDecoration
                ? (cellCustomStyle as BoxDecoration).copyWith(
                    color: (cellCustomStyle as BoxDecoration).color ??
                        tokens.cardBgColor,
                  )
                : BoxDecoration(color: tokens.cardBgColor),
            child: Row(
              children: [
                if (iconWidget != null) ...[
                  iconWidget!,
                  const SizedBox(width: 4),
                ] else if (icon.isNotEmpty) ...[
                  UPIcon(name: icon, size: 22, color: tokens.contentColor),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleWidget ??
                          Text(
                            title,
                            style: TextStyle(
                              color: disabled
                                  ? tokens.disabledColor
                                  : tokens.mainColor,
                              fontSize: 15,
                            ),
                          ),
                      if (label.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: tokens.tipsColor,
                              fontSize: 12,
                              height: 18 / 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (rightIconWidget != null)
                  rightIconWidget!
                else ...[
                  if (value.isNotEmpty)
                    Text(
                      value,
                      style: TextStyle(
                        color: tokens.contentColor,
                        fontSize: 14,
                        height: 24 / 14,
                      ),
                    ),
                  if (showRight && isLink) ...[
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: open ? 0.25 : 0,
                      duration: Duration(milliseconds: ms),
                      child: UPIcon(
                        name: 'arrow-right',
                        size: 16,
                        color: tokens.tipsColor,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
        if (showBorder) const UPLine(),
        AnimatedSize(
          duration: Duration(milliseconds: ms),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: open
              ? Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      color: tokens.contentColor,
                      fontSize: 14,
                      height: 18 / 14,
                    ),
                    child: child ?? const SizedBox.shrink(),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
        if (scope?.border ?? false) const UPLine(),
      ],
    );

    return root;
  }
}
