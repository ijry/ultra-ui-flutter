import 'package:flutter/material.dart';
import '../theme/up_theme.dart';
import '../utils/up_utils.dart';

/// Port of u-cate-tab / up-cate-tab.
///
/// Modes:
/// - `follow`: right pane lists all sections; scrolling updates left active tab
/// - `tab`: right pane shows only current tab items
class UPCateTab extends StatefulWidget {
  const UPCateTab({
    super.key,
    this.mode = 'follow',
    this.height = '100%',
    this.tabList = const [],
    this.tabKeyName = 'name',
    this.itemKeyName = 'name',
    this.current = 0,
    this.modelValue,
    this.onUpdateCurrent,
    this.onUpdateModelValue,
    this.onChange,
    this.itemBuilder,
    this.itemListBuilder,
    this.rightTopBuilder,
    this.tabBuilder,
    this.customStyle,
  });

  final String mode;
  final dynamic height;
  final List tabList;
  final String tabKeyName;
  final String itemKeyName;
  final int current;

  /// Source v-model alias for current.
  final dynamic modelValue;
  final ValueChanged<int>? onUpdateCurrent;

  /// Source update:modelValue alias for current.
  final ValueChanged<int>? onUpdateModelValue;
  int get effectiveCurrent =>
      int.tryParse('${modelValue ?? current}') ?? current;

  /// Alias callback for active index change.
  final ValueChanged<int>? onChange;

  /// Source `pageItem` slot, scoped `{pageItem}` — replaces the rendering of one
  /// child row within a tab's section.
  final Widget Function(
    BuildContext context,
    dynamic item,
    int tabIndex,
    int itemIndex,
  )? itemBuilder;

  /// Source `itemList` slot, scoped `{item}` — replaces a tab's *whole* section
  /// (its heading and all its rows) with one widget, receiving the tab itself
  /// rather than a child. Distinct from [itemBuilder]: this one is called once
  /// per tab, and a tab's children need not be a list of rows at all. The choose
  /// demo relies on it to render a nested picker per day.
  final Widget Function(
    BuildContext context,
    dynamic tab,
    int tabIndex,
  )? itemListBuilder;

  /// Source `rightTop` slot, scoped `{tabList}` — header above the right pane.
  final Widget Function(BuildContext context, List tabList)? rightTopBuilder;

  final Widget Function(
    BuildContext context,
    dynamic tab,
    int index,
    bool active,
  )? tabBuilder;
  final BoxDecoration? customStyle;

  @override
  State<UPCateTab> createState() => UPCateTabState();
}

class UPCateTabState extends State<UPCateTab> {
  /// Source host helper.
  Future<void> setTimeout([dynamic cb, int ms = 0]) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
    if (cb is Function) cb();
  }

  /// Source host helper.
  dynamic resolve([dynamic v]) => v;

  late int innerCurrent;

  /// Source data.
  List get arr => List.from(widget.tabList);
  dynamic itemId;
  double menuHeight = 0;
  double get menuItemHeight => _menuItemHeight;
  List menuItemPos = const [];
  double oldScrollTop = 0;
  List rects = const [];
  dynamic scrollIntoView;
  double scrollRightTop = 0;
  double scrollTop = 0;
  dynamic timer;

  final leftController = ScrollController();
  final rightController = ScrollController();
  final sectionKeys = <GlobalKey>[];
  bool _programmaticRightScroll = false;
  static const double _menuItemHeight = 50;

  @override
  void initState() {
    super.initState();
    innerCurrent = widget.effectiveCurrent;
    _ensureSectionKeys();
    rightController.addListener(_onRightScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSectionPositions();
      if (widget.mode == 'follow') {
        _scrollRightToSection(innerCurrent, animate: false);
      }
      _scrollLeftMenu(innerCurrent);
    });
  }

  @override
  void didUpdateWidget(covariant UPCateTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabList.length != widget.tabList.length) {
      _ensureSectionKeys();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateSectionPositions();
      });
    }
    if (oldWidget.effectiveCurrent != widget.effectiveCurrent &&
        widget.effectiveCurrent != innerCurrent) {
      switchMenu(widget.effectiveCurrent);
    }
  }

  @override
  void dispose() {
    rightController.removeListener(_onRightScroll);
    leftController.dispose();
    rightController.dispose();
    super.dispose();
  }

  void _ensureSectionKeys() {
    while (sectionKeys.length < widget.tabList.length) {
      sectionKeys.add(GlobalKey());
    }
    if (sectionKeys.length > widget.tabList.length) {
      sectionKeys.removeRange(widget.tabList.length, sectionKeys.length);
    }
  }

  String tabName(dynamic tab) {
    if (tab is Map) return '${tab[widget.tabKeyName] ?? tab['name'] ?? ''}';
    return '$tab';
  }

  List itemsOf(dynamic tab) {
    if (tab is Map) {
      final list =
          tab['children'] ?? tab['list'] ?? tab['goods'] ?? tab['items'] ?? [];
      return list is List ? list : const [];
    }
    return const [];
  }

  String itemName(dynamic item) {
    if (item is Map) {
      return '${item[widget.itemKeyName] ?? item['name'] ?? item['title'] ?? ''}';
    }
    return '$item';
  }

  int get currentIndex => innerCurrent;

  /// Source-compatible public method.
  void switchMenu(int index) {
    if (widget.tabList.isEmpty) return;
    final next = index.clamp(0, widget.tabList.length - 1);
    final changed = next != innerCurrent;
    setState(() => innerCurrent = next);
    if (changed) {
      widget.onUpdateCurrent?.call(next);
      widget.onUpdateModelValue?.call(next);
      widget.onChange?.call(next);
    }
    _scrollLeftMenu(next);
    if (widget.mode == 'follow') {
      _scrollRightToSection(next);
    } else if (rightController.hasClients) {
      rightController.jumpTo(0);
    }
  }

  /// Source menu helpers (Batch I).
  void swichMenu(int index) => switchMenu(index); // source typo alias
  List getMenuItemTop([dynamic _]) {
    _updateSectionPositions();
    return List.from(menuItemPos);
  }

  Map leftMenuStatus([dynamic _]) => {
        'current': innerCurrent,
        'count': widget.tabList.length,
      };
  void observer([dynamic _]) {
    if (widget.mode == 'follow') {
      _onRightScroll();
    }
  }

  void rightScroll([dynamic _]) => _onRightScroll();

  void setCurrent(int index) => switchMenu(index);

  /// Source `getElRect`.
  Map getElRect() {
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

  void _scrollLeftMenu(int index) {
    if (!leftController.hasClients) return;
    final viewport = leftController.position.viewportDimension;
    final target = index * _menuItemHeight + _menuItemHeight / 2 - viewport / 2;
    final clamped = target.clamp(
      0.0,
      leftController.position.maxScrollExtent,
    );
    leftController.animateTo(
      clamped,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  void _scrollRightToSection(int index, {bool animate = true}) {
    if (widget.mode != 'follow') return;
    if (index < 0 || index >= sectionKeys.length) return;
    final ctx = sectionKeys[index].currentContext;
    if (ctx == null) return;
    scrollIntoView = 'item$index';
    _programmaticRightScroll = true;
    Scrollable.ensureVisible(
      ctx,
      duration: animate ? const Duration(milliseconds: 220) : Duration.zero,
      alignment: 0,
      curve: Curves.easeOut,
    ).whenComplete(() {
      Future<void>.delayed(const Duration(milliseconds: 80), () {
        _programmaticRightScroll = false;
      });
    });
  }

  void _onRightScroll() {
    if (widget.mode != 'follow' || _programmaticRightScroll) return;
    if (!rightController.hasClients || sectionKeys.isEmpty) return;
    final offset = rightController.offset;
    oldScrollTop = offset;
    scrollRightTop = offset;
    _updateSectionPositions();
    final rightBox = context.findRenderObject() as RenderBox?;
    if (rightBox == null || !rightBox.hasSize) return;

    // Use section tops relative to right scroll content.
    double? bestTop;
    var bestIndex = innerCurrent;
    for (var i = 0; i < sectionKeys.length; i++) {
      final ctx = sectionKeys[i].currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) continue;
      final offset = box.localToGlobal(Offset.zero, ancestor: rightBox).dy;
      // Prefer the last section whose top has crossed a small threshold.
      if (offset <= 24) {
        if (bestTop == null || offset >= bestTop) {
          bestTop = offset;
          bestIndex = i;
        }
      }
    }
    if (bestIndex != innerCurrent) {
      setState(() => innerCurrent = bestIndex);
      widget.onUpdateCurrent?.call(bestIndex);
      widget.onUpdateModelValue?.call(bestIndex);
      widget.onChange?.call(bestIndex);
      _scrollLeftMenu(bestIndex);
    }
  }

  void _updateSectionPositions() {
    if (widget.mode != 'follow' || sectionKeys.isEmpty) return;
    final rightBox = context.findRenderObject() as RenderBox?;
    if (rightBox == null || !rightBox.hasSize) return;
    final offsets = <double>[];
    for (final key in sectionKeys) {
      final ctx = key.currentContext;
      final box = ctx?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) {
        offsets.add(offsets.isEmpty ? 0 : offsets.last);
        continue;
      }
      final localTop = box.localToGlobal(Offset.zero, ancestor: rightBox).dy;
      offsets.add(rightController.hasClients
          ? rightController.offset + localTop
          : localTop);
    }
    rects = List.from(offsets);
    menuItemPos = List.from(offsets);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final h = widget.height.toString().endsWith('%')
        ? null
        : UPUtils.getPx(widget.height);
    final tabs = widget.tabList;
    _ensureSectionKeys();

    final left = Container(
      width: 96,
      color: tokens.bgColor,
      child: ListView.builder(
        controller: leftController,
        itemCount: tabs.length,
        itemExtent: _menuItemHeight,
        itemBuilder: (context, i) {
          final active = i == innerCurrent;
          final tab = tabs[i];
          if (widget.tabBuilder != null) {
            return GestureDetector(
              key: ValueKey('up-cate-tab-left-$i'),
              onTap: () => switchMenu(i),
              child: widget.tabBuilder!(context, tab, i, active),
            );
          }
          return GestureDetector(
            key: ValueKey('up-cate-tab-left-$i'),
            onTap: () => switchMenu(i),
            child: Container(
              height: _menuItemHeight,
              alignment: Alignment.center,
              color: active ? tokens.cardBgColor : Colors.transparent,
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 16,
                    color: active ? tokens.primary : Colors.transparent,
                  ),
                  Expanded(
                    child: Text(
                      tabName(tab),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: active ? tokens.primary : tokens.contentColor,
                        fontWeight:
                            active ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    Widget right;
    if (widget.mode == 'tab') {
      final idx = tabs.isEmpty ? 0 : innerCurrent.clamp(0, tabs.length - 1);
      // itemList replaces the tab's whole section, so it short-circuits the
      // per-row list rather than being applied inside it.
      if (widget.itemListBuilder != null && tabs.isNotEmpty) {
        right = SingleChildScrollView(
          key: ValueKey('up-cate-tab-right-tab-$idx'),
          controller: rightController,
          child: widget.itemListBuilder!(context, tabs[idx], idx),
        );
      } else {
        final items = tabs.isEmpty ? const [] : itemsOf(tabs[idx]);
        right = ListView.builder(
          key: ValueKey('up-cate-tab-right-tab-$idx'),
          controller: rightController,
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            if (widget.itemBuilder != null) {
              return widget.itemBuilder!(context, item, innerCurrent, i);
            }
            return ListTile(
              dense: true,
              title: Text(
                itemName(item),
                style: TextStyle(color: tokens.mainColor, fontSize: 14),
              ),
            );
          },
        );
      }
    } else {
      final children = <Widget>[];
      for (var ti = 0; ti < tabs.length; ti++) {
        final tab = tabs[ti];
        if (widget.itemListBuilder != null) {
          // Section key stays on the outermost widget so `follow` mode can still
          // measure this tab's scroll offset.
          children.add(
            KeyedSubtree(
              key: sectionKeys[ti],
              child: widget.itemListBuilder!(context, tab, ti),
            ),
          );
          continue;
        }
        children.add(
          Container(
            key: sectionKeys[ti],
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Text(
              tabName(tab),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: tokens.mainColor,
              ),
            ),
          ),
        );
        final items = itemsOf(tab);
        for (var ii = 0; ii < items.length; ii++) {
          final item = items[ii];
          if (widget.itemBuilder != null) {
            children.add(widget.itemBuilder!(context, item, ti, ii));
          } else {
            children.add(
              ListTile(
                dense: true,
                title: Text(
                  itemName(item),
                  style: TextStyle(color: tokens.contentColor, fontSize: 13),
                ),
              ),
            );
          }
        }
      }
      right = ListView(
        controller: rightController,
        children: children,
      );
    }

    Widget root = SizedBox(
      height: h ?? 360,
      child: Row(
        children: [
          left,
          Expanded(
            child: Container(
              color: tokens.cardBgColor,
              // Source rightTop sits above the scrolling right pane, inside the
              // same scroll view; placing it in a Column keeps it pinned, which
              // is the useful reading of a header here.
              child: widget.rightTopBuilder == null
                  ? right
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        widget.rightTopBuilder!(context, tabs),
                        Expanded(child: right),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
    return root;
  }
}
