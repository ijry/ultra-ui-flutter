import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import 'up_button.dart';
import 'up_cell.dart';
import 'up_icon.dart';
import 'up_popup.dart';
import 'up_steps.dart';
import 'up_tabs.dart';

/// 1:1 API port of u-cascader.
class UPCascader extends StatefulWidget {
  const UPCascader({
    super.key,
    this.show = false,
    this.data = const [],
    this.value = const [],
    this.modelValue,
    this.valueKey = 'value',
    this.labelKey = 'label',
    this.childrenKey = 'children',
    this.maskCloseAble = true,
    this.zIndex = 1075,
    this.autoClose = false,
    this.closeable = true,
    this.closeIconColor = '#909193',
    this.headerDirection = 'row',
    this.optionsCols = 1,
    this.onClose,
    this.onCancel,
    this.onConfirm,
    this.onChange,
    this.onUpdateShow,
    this.onUpdateValue,
    this.onUpdateModelValue,
    this.customStyle,
  });

  final bool show;
  final List data;
  final List value;

  /// Source v-model / modelValue alias for value path.
  final List? modelValue;
  final String valueKey;
  final String labelKey;
  final String childrenKey;
  final bool maskCloseAble;
  final dynamic zIndex;
  final bool autoClose;
  final bool closeable;
  final dynamic closeIconColor;
  final String headerDirection; // row | column
  final int optionsCols; // 1 | 2
  final VoidCallback? onClose;
  final VoidCallback? onCancel;
  final ValueChanged<List>? onConfirm;
  final ValueChanged<List>? onChange;
  final ValueChanged<bool>? onUpdateShow;
  final ValueChanged<List>? onUpdateValue;

  /// Source update:modelValue alias.
  final ValueChanged<List>? onUpdateModelValue;

  List get effectiveValue => modelValue ?? value;

  final BoxDecoration? customStyle;

  /// Source computed: uZIndex.
  dynamic get uZIndex {
    final z = num.tryParse('$zIndex');
    if (z != null && z != 0) return z;
    return 10075;
  }

  /// Source computed: levelPaneStyle.
  dynamic get levelPaneStyle => const <String, dynamic>{
        'backgroundColor': 'var(--up-bg-color, #f7f7f7)',
      };

  @override
  State<UPCascader> createState() => UPCascaderState();
}

class UPCascaderState extends State<UPCascader> {
  /// Source data.
  bool popupShow = false;
  List selectedValueIndexs = const [];

  final selectedIndexes = <int>[];
  int tabsIndex = 0;
  List confirmValues = [];
  late bool innerShow;

  List get selectedPathValues => List.from(selectedValues);
  List get selectedPathLabels => List.from(selectedLabels);

  /// Source change flag helper (Batch K).
  bool get isChange {
    if (confirmValues.isEmpty && selectedValues.isEmpty) return false;
    if (confirmValues.length != selectedValues.length) return true;
    for (var i = 0; i < selectedValues.length; i++) {
      if ('${selectedValues[i]}' != '${confirmValues[i]}') return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    innerShow = widget.show;
    _syncFromValue();
  }

  @override
  void didUpdateWidget(covariant UPCascader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.show != widget.show) {
      innerShow = widget.show;
    }
    if (oldWidget.effectiveValue != widget.effectiveValue ||
        oldWidget.data != widget.data) {
      _syncFromValue();
    }
  }

  Map? _asMap(dynamic item) =>
      item is Map ? Map<dynamic, dynamic>.from(item) : null;

  List _childrenOf(Map? item) {
    if (item == null) return const [];
    final c = item[widget.childrenKey];
    return c is List ? c : const [];
  }

  void _syncFromValue() {
    selectedIndexes.clear();
    List level = widget.data;
    for (final v in widget.effectiveValue) {
      final idx = level.indexWhere((e) {
        final m = _asMap(e);
        return m != null && '${m[widget.valueKey]}' == '$v';
      });
      if (idx < 0) break;
      selectedIndexes.add(idx);
      level = _childrenOf(_asMap(level[idx]));
    }
    tabsIndex = selectedIndexes.isEmpty ? 0 : selectedIndexes.length - 1;
    confirmValues = List.from(selectedValues);
  }

  List<List> get levelList {
    final levels = <List>[widget.data];
    List current = widget.data;
    for (final idx in selectedIndexes) {
      if (idx < 0 || idx >= current.length) break;
      final children = _childrenOf(_asMap(current[idx]));
      if (children.isEmpty) break;
      levels.add(children);
      current = children;
    }
    return levels;
  }

  List get selectedValues {
    final values = <dynamic>[];
    List level = widget.data;
    for (final idx in selectedIndexes) {
      if (idx < 0 || idx >= level.length) break;
      final item = _asMap(level[idx]);
      if (item == null) break;
      values.add(item[widget.valueKey]);
      level = _childrenOf(item);
    }
    return values;
  }

  List get selectedLabels {
    final labels = <dynamic>[];
    List level = widget.data;
    for (final idx in selectedIndexes) {
      if (idx < 0 || idx >= level.length) break;
      final item = _asMap(level[idx]);
      if (item == null) break;
      labels.add(item[widget.labelKey]);
      level = _childrenOf(item);
    }
    return labels;
  }

  List get tabs {
    final labels = selectedLabels;
    if (labels.isEmpty)
      return const [
        {'name': '请选择'}
      ];
    final list = [
      for (final l in labels) {'name': '$l'}
    ];
    List level = widget.data;
    for (final idx in selectedIndexes) {
      if (idx < 0 || idx >= level.length) break;
      level = _childrenOf(_asMap(level[idx]));
    }
    if (level.isNotEmpty) list.add({'name': '请选择'});
    return list;
  }

  void open() {
    setState(() => innerShow = true);
    widget.onUpdateShow?.call(true);
  }

  void close() {
    setState(() => innerShow = false);
    widget.onUpdateShow?.call(false);
    widget.onClose?.call();
  }

  void reset() {
    setState(() {
      selectedIndexes.clear();
      tabsIndex = 0;
      confirmValues = [];
    });
  }

  void setValue(List values) {
    setState(() {
      selectedIndexes.clear();
      List level = widget.data;
      for (final v in values) {
        final idx = level.indexWhere((e) {
          final m = _asMap(e);
          return m != null && '${m[widget.valueKey]}' == '$v';
        });
        if (idx < 0) break;
        selectedIndexes.add(idx);
        level = _childrenOf(_asMap(level[idx]));
      }
      tabsIndex = selectedIndexes.isEmpty ? 0 : selectedIndexes.length - 1;
      confirmValues = List.from(selectedValues);
    });
    widget.onUpdateValue?.call(List.from(selectedValues));
    widget.onUpdateModelValue?.call(List.from(selectedValues));
    widget.onChange?.call(List.from(selectedValues));
  }

  /// Source `getSelectedValues`.
  List getSelectedValues() => List.from(selectedValues);

  /// Source `setDefaultValue` — re-sync from props.value without emitting.
  void setDefaultValue([List? values]) {
    final seed = values ?? widget.effectiveValue;
    setState(() {
      selectedIndexes.clear();
      List level = widget.data;
      for (final v in seed) {
        final idx = level.indexWhere((e) {
          final m = _asMap(e);
          return m != null && '${m[widget.valueKey]}' == '$v';
        });
        if (idx < 0) break;
        selectedIndexes.add(idx);
        level = _childrenOf(_asMap(level[idx]));
      }
      tabsIndex = selectedIndexes.isEmpty ? 0 : selectedIndexes.length - 1;
      confirmValues = List.from(selectedValues);
    });
  }

  /// Source `initLevelList` — rebuild selection path from current value.
  List initLevelList([dynamic _]) {
    _syncFromValue();
    return levelList;
  }

  /// Source `genTabsList` alias of [tabs].
  List genTabsList([dynamic _]) => List.from(tabs);

  /// Source `emitChange`.
  void emitChange([List? values]) {
    final v = values ?? selectedValues;
    widget.onChange?.call(List.from(v));
    widget.onUpdateValue?.call(List.from(v));
    widget.onUpdateModelValue?.call(List.from(v));
  }

  /// Source `toFatherIndex` — jump to a parent tab index.
  void toFatherIndex([dynamic index]) {
    final i = int.tryParse('$index') ?? 0;
    setState(() {
      if (i < 0) {
        tabsIndex = 0;
      } else if (i >= selectedIndexes.length) {
        tabsIndex = selectedIndexes.isEmpty ? 0 : selectedIndexes.length - 1;
      } else {
        tabsIndex = i;
        if (selectedIndexes.length > i + 1) {
          selectedIndexes.removeRange(i + 1, selectedIndexes.length);
        }
        confirmValues = List.from(selectedValues);
      }
    });
  }

  /// Source `tabsChange`.
  void tabsChange([dynamic index]) => toFatherIndex(index);

  /// Source `levelChange` — select item at level.
  void levelChange(int levelIndex, int itemIndex) =>
      _pick(levelIndex, itemIndex);

  /// Source `handleCancel` alias.
  void handleCancel() => _cancel();

  /// Source `handleConfirm` alias.
  void handleConfirm() => _confirm();

  /// Source confirm alias.
  void confirm() => _confirm();

  void _close() => close();

  void _cancel() {
    widget.onCancel?.call();
    _close();
  }

  void _confirm() {
    final values =
        confirmValues.isNotEmpty ? List.from(confirmValues) : selectedValues;
    confirmValues = List.from(values);
    widget.onConfirm?.call(values);
    widget.onUpdateValue?.call(values);
    widget.onUpdateModelValue?.call(values);
    _close();
  }

  void _pick(int levelIndex, int itemIndex) {
    setState(() {
      if (selectedIndexes.length > levelIndex) {
        selectedIndexes.removeRange(levelIndex, selectedIndexes.length);
      }
      while (selectedIndexes.length < levelIndex) {
        selectedIndexes.add(0);
      }
      if (selectedIndexes.length == levelIndex) {
        selectedIndexes.add(itemIndex);
      } else {
        selectedIndexes[levelIndex] = itemIndex;
      }
      final nextLevels = levelList;
      final children = _childrenOf(_asMap(nextLevels[levelIndex][itemIndex]));
      tabsIndex = children.isNotEmpty ? levelIndex + 1 : levelIndex;
      confirmValues = List.from(selectedValues);
    });
    final values = selectedValues;
    widget.onChange?.call(values);
    widget.onUpdateValue?.call(values);
    widget.onUpdateModelValue?.call(values);
    if (widget.autoClose) {
      final levels = levelList;
      final lastLevelIndex = selectedIndexes.length - 1;
      if (lastLevelIndex >= 0 && lastLevelIndex < levels.length) {
        final last = _asMap(levels[lastLevelIndex][selectedIndexes.last]);
        if (last != null && _childrenOf(last).isEmpty) {
          _confirm();
        }
      }
    }
  }

  Widget _levelPane(List currentLevel, int levelIndex, UPThemeTokens tokens) {
    return ListView(
      children: [
        for (var i = 0; i < currentLevel.length; i++)
          Builder(builder: (context) {
            final item = _asMap(currentLevel[i]) ?? {};
            final selected = selectedIndexes.length > levelIndex &&
                selectedIndexes[levelIndex] == i;
            return UPCell(
              title: '${item[widget.labelKey] ?? ''}',
              border: true,
              onClick: () => _pick(levelIndex, i),
              rightIconSlot: selected
                  ? UPIcon(
                      name: 'checkbox-mark',
                      size: 17,
                      color: tokens.primary,
                    )
                  : null,
            );
          }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final levels = levelList;
    final dual = widget.optionsCols == 2;

    Widget body;
    if (dual) {
      // Show current and previous columns like source optionsCols=2.
      final cols = <Widget>[];
      final start = (tabsIndex - 1).clamp(0, levels.length);
      final end = (tabsIndex + 1).clamp(0, levels.length);
      for (var i = start; i < end; i++) {
        cols.add(
          Expanded(
            child: _levelPane(levels[i], i, tokens),
          ),
        );
      }
      if (cols.isEmpty && levels.isNotEmpty) {
        cols.add(Expanded(child: _levelPane(levels.first, 0, tokens)));
      }
      body = SizedBox(
        height: 280,
        child: Row(children: cols),
      );
    } else {
      final currentLevel =
          tabsIndex < levels.length ? levels[tabsIndex] : const [];
      body = SizedBox(
        height: 280,
        child: _levelPane(currentLevel, tabsIndex, tokens),
      );
    }

    Widget root = UPPopup(
      show: innerShow,
      mode: 'bottom',
      overlay: true,
      closeOnClickOverlay: widget.maskCloseAble,
      zIndex: widget.zIndex,
      closeable: widget.closeable,
      onClose: _close,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.headerDirection == 'column')
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: UPSteps(
                current: tabsIndex,
                direction: 'column',
                dot: true,
                children: [
                  for (var i = 0; i < tabs.length; i++)
                    GestureDetector(
                      onTap: () => setState(() => tabsIndex = i),
                      child: UPStepsItem(title: '${tabs[i]['name'] ?? ''}'),
                    ),
                ],
              ),
            )
          else
            UPTabs(
              list: tabs,
              current: tabsIndex,
              onChange: (i) => setState(() => tabsIndex = i),
            ),
          body,
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: UPButton(
                    text: '取消',
                    onClick: _cancel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: UPButton(
                    text: '确认',
                    type: 'primary',
                    onClick: _confirm,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return root;
  }
}
