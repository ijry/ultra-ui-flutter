import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';
import 'up_loading_icon.dart';
import 'up_popup.dart';

/// 1:1 port of u-action-sheet defaults.
class UPActionSheet extends StatefulWidget {
  const UPActionSheet({
    super.key,
    this.show = false,
    this.title = '',
    this.description = '',
    this.actions = const [],
    this.nameKey = 'name',
    this.subnameKey = 'subnameKey',
    this.cancelText = '',
    this.closeOnClickAction = true,
    this.safeAreaInsetBottom = true,
    this.closeOnClickOverlay = true,
    this.round = 0,
    this.wrapMaxHeight = '600px',
    this.openType = '',
    this.onSelect,
    this.onClose,
    this.onClosed,
    this.onCancel,
    this.onUpdateShow,
    this.child,
    this.customStyle,
  });

  final bool show;
  final String title;
  final String description;
  final List<dynamic> actions;
  final String nameKey;
  final String subnameKey;
  final String cancelText;
  final bool closeOnClickAction;
  final bool safeAreaInsetBottom;
  final bool closeOnClickOverlay;
  final dynamic round;
  final dynamic wrapMaxHeight;
  final String openType;
  final void Function(dynamic item, int index)? onSelect;
  final VoidCallback? onClose;

  /// Source emit `closed` — the nested popup finished its leave
  /// animation, unlike `close` which fires at dismissal.
  final VoidCallback? onClosed;
  final VoidCallback? onCancel;

  /// Source default slot — replaces the action list entirely.
  final Widget? child;
  final ValueChanged<bool>? onUpdateShow;
  final BoxDecoration? customStyle;

  /// Source computed: titleDynamicStyle.
  dynamic get titleDynamicStyle => const <String, dynamic>{'color': '#303133'};

  /// Source computed: descriptionDynamicStyle.
  dynamic get descriptionDynamicStyle =>
      const <String, dynamic>{'color': '#909193'};

  /// Source computed: closeIconColor.
  dynamic get closeIconColor => '#606266';

  /// Source computed: dividerColor.
  dynamic get dividerColor => '#dadbde';

  /// Source computed: cancelGapColor.
  dynamic get cancelGapColor => '#eaeaec';

  /// Source computed: cancelTextDynamicStyle.
  dynamic get cancelTextDynamicStyle =>
      const <String, dynamic>{'color': '#303133'};

  /// Source computed: itemStyle(index).
  dynamic itemStyle([dynamic index]) {
    final style = <String, dynamic>{'color': '#303133'};
    final i = index is int ? index : int.tryParse('$index');
    if (i != null && i >= 0 && i < actions.length) {
      final item = actions[i];
      if (item is Map) {
        if (item['color'] != null) style['color'] = item['color'];
        if (item['fontSize'] != null) {
          style['fontSize'] = UPUtils.addUnit(item['fontSize']);
        }
        if (item['disabled'] == true) style['color'] = '#c0c4cc';
      }
    }
    return style;
  }

  /// Source computed: subnameStyle(index).
  dynamic subnameStyle([dynamic index]) {
    final i = index is int ? index : int.tryParse('$index');
    var disabled = false;
    if (i != null && i >= 0 && i < actions.length) {
      final item = actions[i];
      if (item is Map) disabled = item['disabled'] == true;
    }
    return <String, dynamic>{
      'color': disabled ? '#c0c4cc' : '#909193',
    };
  }

  @override
  State<UPActionSheet> createState() => UPActionSheetState();
}

class UPActionSheetState extends State<UPActionSheet> {
  bool? _forcedShow;

  bool get isShown => _forcedShow ?? widget.show;

  void open() {
    _forcedShow = true;
    widget.onUpdateShow?.call(true);
    if (mounted) setState(() {});
  }

  void close() {
    closeHandler();
  }

  void toggle() => isShown ? close() : open();

  /// Source `hideKeyboard`.
  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// Source `closeHandler`.
  void closeHandler() {
    if (!widget.closeOnClickOverlay) return;
    _forcedShow = false;
    widget.onUpdateShow?.call(false);
    widget.onClose?.call();
    if (mounted) setState(() {});
  }

  /// Source `cancel`.
  void cancel() {
    widget.onCancel?.call();
    _forcedShow = false;
    widget.onUpdateShow?.call(false);
    widget.onClose?.call();
    if (mounted) setState(() {});
  }

  /// Source `slotClickHandler` — tapping custom slot content closes the sheet
  /// when `closeOnClickAction` is set.
  void slotClickHandler() {
    if (!widget.closeOnClickAction) return;
    _forcedShow = false;
    widget.onUpdateShow?.call(false);
    widget.onClose?.call();
    if (mounted) setState(() {});
  }

  /// Source `selectHandler`.
  void selectHandler(dynamic item, int index) {
    if (item is Map && (item['disabled'] == true || item['loading'] == true)) {
      return;
    }
    widget.onSelect?.call(item, index);
    if (widget.closeOnClickAction) {
      _forcedShow = false;
      widget.onUpdateShow?.call(false);
      widget.onClose?.call();
      if (mounted) setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant UPActionSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.show != widget.show) {
      _forcedShow = null;
    }
  }

  String _name(dynamic item) {
    if (item is Map) return '${item[widget.nameKey] ?? item['name'] ?? ''}';
    return '$item';
  }

  String _sub(dynamic item) {
    if (item is Map)
      return '${item[widget.subnameKey] ?? item['subname'] ?? ''}';
    return '';
  }

  bool _disabled(dynamic item) {
    if (item is Map) return item['disabled'] == true;
    return false;
  }

  bool _loading(dynamic item) {
    if (item is Map) return item['loading'] == true;
    return false;
  }

  Color? _color(dynamic item) {
    if (item is Map) return UPUtils.parseColor(item['color']);
    return null;
  }

  double? _fontSize(dynamic item) {
    if (item is Map && item['fontSize'] != null) {
      return UPUtils.getPx(item['fontSize']);
    }
    return null;
  }

  /// Source `getItemHoverStyle` — hover style map for an action item.
  Map getItemHoverStyle([dynamic item]) {
    final disabled = item != null && _disabled(item);
    final loading = item != null && _loading(item);
    return {
      'opacity': disabled || loading ? 1.0 : 0.7,
      'disabled': disabled,
      'loading': loading,
      'color': item == null ? null : _color(item)?.toARGB32(),
      'fontSize': item == null ? null : _fontSize(item),
    };
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);

    Widget itemTile(dynamic item, int index, {bool isCancel = false}) {
      final disabled = !isCancel && _disabled(item);
      final loading = !isCancel && _loading(item);
      final name = isCancel ? widget.cancelText : _name(item);
      final sub = isCancel ? '' : _sub(item);
      final color = isCancel
          ? tokens.mainColor
          : (_color(item) ??
              (disabled ? tokens.disabledColor : tokens.mainColor));
      final fontSize = _fontSize(item) ?? 16;
      return InkWell(
        onTap: disabled || loading
            ? null
            : () {
                if (isCancel) {
                  cancel();
                } else {
                  selectHandler(item, index);
                }
              },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: sub.isEmpty ? 16 : 12,
            horizontal: 16,
          ),
          alignment: Alignment.center,
          child: loading
              ? const UPLoadingIcon(mode: 'circle', size: 18)
              : Column(
                  children: [
                    Text(name,
                        style: TextStyle(color: color, fontSize: fontSize)),
                    if (sub.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          sub,
                          style: TextStyle(
                            color: disabled
                                ? tokens.disabledColor
                                : tokens.tipsColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      );
    }

    Widget root = UPPopup(
      show: isShown,
      mode: 'bottom',
      round: widget.round == 0 ? '0' : widget.round,
      safeAreaInsetBottom: widget.safeAreaInsetBottom,
      closeOnClickOverlay: widget.closeOnClickOverlay,
      maxHeight: widget.wrapMaxHeight,
      onClose: closeHandler,
      onClosed: widget.onClosed,
      child: Material(
        color: tokens.cardBgColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.title.isNotEmpty || widget.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        if (widget.title.isNotEmpty)
                          Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: tokens.mainColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (widget.description.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(
                                top: widget.title.isNotEmpty ? 6 : 0),
                            child: Text(
                              widget.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: tokens.tipsColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (widget.title.isNotEmpty)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: closeHandler,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: UPIcon(
                              name: 'close',
                              size: 17,
                              bold: true,
                              color: tokens.contentColor,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            // Source: a default slot replaces the whole action list, and
            // tapping it closes when closeOnClickAction is set.
            if (widget.child != null)
              GestureDetector(
                onTap: slotClickHandler,
                behavior: HitTestBehavior.opaque,
                child: widget.child,
              )
            else ...[
              if (widget.description.isNotEmpty)
                Divider(height: 1, thickness: 0.5, color: tokens.borderColor),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: widget.actions.length,
                  separatorBuilder: (_, __) => Divider(
                      height: 1, thickness: 0.5, color: tokens.borderColor),
                  itemBuilder: (_, i) => itemTile(widget.actions[i], i),
                ),
              ),
            ],
            if (widget.cancelText.isNotEmpty) ...[
              Container(height: 8, color: tokens.bgColor),
              itemTile({}, -1, isCancel: true),
            ],
          ],
        ),
      ),
    );
    return root;
  }
}

/// Port of u-action-sheet-data — input trigger + action sheet selection.
class UPActionSheetData extends StatefulWidget {
  const UPActionSheetData({
    super.key,
    this.modelValue = '',
    this.value,
    this.title = '',
    this.description = '',
    this.options = const [],
    this.valueKey = 'value',
    this.labelKey = 'name',
    this.trigger,
    this.onUpdateModelValue,
    this.onUpdateValue,
    this.onSelect,
    this.customStyle,
  });

  final dynamic modelValue;

  /// Alias of [modelValue].
  final dynamic value;
  final String title;
  final String description;
  final List options;
  final String valueKey;
  final String labelKey;
  final Widget? trigger;
  final ValueChanged<dynamic>? onUpdateModelValue;
  final ValueChanged<dynamic>? onUpdateValue;
  final void Function(dynamic item, int index)? onSelect;
  final BoxDecoration? customStyle;

  dynamic get effectiveValue => modelValue != '' && modelValue != null
      ? modelValue
      : (value ?? modelValue);

  @override
  State<UPActionSheetData> createState() => UPActionSheetDataState();
}

class UPActionSheetDataState extends State<UPActionSheetData> {
  bool show = false;
  String current = '';

  @override
  void initState() {
    super.initState();
    _syncLabel(widget.effectiveValue);
  }

  @override
  void didUpdateWidget(covariant UPActionSheetData oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.effectiveValue != widget.effectiveValue ||
        oldWidget.options != widget.options) {
      _syncLabel(widget.effectiveValue);
    }
  }

  void _syncLabel(dynamic value) {
    current = '';
    if (value == null || '$value'.isEmpty) return;
    for (final ele in widget.options) {
      if (ele is Map && '${ele[widget.valueKey]}' == '$value') {
        current = '${ele[widget.labelKey] ?? ''}';
        return;
      }
    }
  }

  /// Source `hideKeyboard`.
  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void open() {
    setState(() => show = true);
  }

  void close() {
    setState(() => show = false);
  }

  void select(dynamic item, [int index = 0]) {
    dynamic next;
    if (item is Map) {
      next = item[widget.valueKey];
      current = '${item[widget.labelKey] ?? ''}';
    } else {
      next = item;
      current = '$item';
    }
    widget.onUpdateModelValue?.call(next);
    widget.onUpdateValue?.call(next);
    widget.onSelect?.call(item, index);
    setState(() => show = false);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final trigger = widget.trigger ??
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
          decoration: BoxDecoration(
            color: tokens.cardBgColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            current.isEmpty
                ? (widget.title.isEmpty ? '请选择' : widget.title)
                : current,
            style: TextStyle(
              color: current.isEmpty ? tokens.tipsColor : tokens.mainColor,
              fontSize: 15,
            ),
          ),
        );

    Widget root = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: open,
          child: trigger,
        ),
        UPActionSheet(
          show: show,
          actions: widget.options,
          title: widget.title,
          description: widget.description,
          nameKey: widget.labelKey,
          safeAreaInsetBottom: true,
          onClose: close,
          onSelect: select,
        ),
      ],
    );
    return root;
  }
}
