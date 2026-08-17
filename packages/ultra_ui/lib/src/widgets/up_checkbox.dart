import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_form.dart';
import 'up_icon.dart';

final Expando<Map<String, dynamic>> _upCheckboxState =
    Expando<Map<String, dynamic>>('upCheckboxState');
final Expando<Object> _upCheckboxGroupLastError =
    Expando<Object>('upCheckboxGroupLastError');
final Expando<Object> _upCheckboxLastError =
    Expando<Object>('upCheckboxLastError');

/// Group defaults mirror u-checkbox-group.
class UPCheckboxGroup extends StatelessWidget {
  /// Source host helper.
  dynamic get lastError => _upCheckboxGroupLastError[this];
  void error([dynamic payload]) {
    _upCheckboxGroupLastError[this] = payload;
  }

  const UPCheckboxGroup({
    super.key,
    this.name = '',
    this.value = const [],
    this.modelValue,
    this.shape = 'square',
    this.disabled = false,
    this.activeColor = '#2979ff',
    this.inactiveColor = '#c8c9cc',
    this.size = 18,
    this.placement = 'row',
    this.labelSize = 14,
    this.labelColor = '#303133',
    this.labelDisabled = false,
    this.iconColor = '#ffffff',
    this.iconSize = 12,
    this.iconPlacement = 'left',
    this.borderBottom = false,
    this.customStyle,
    this.onChange,
    this.onUpdateValue,
    this.onUpdateModelValue,
    required this.children,
    this.onInput,
  });

  /// Source emit alias: input -> onInput.
  final ValueChanged<dynamic>? onInput;

  final String name;
  final List<dynamic> value;

  /// Source v-model / modelValue alias.
  final List<dynamic>? modelValue;
  final String shape;
  final bool disabled;
  final dynamic activeColor;
  final dynamic inactiveColor;
  final dynamic size;
  final String placement;
  final dynamic labelSize;
  final dynamic labelColor;
  final bool labelDisabled;
  final dynamic iconColor;
  final dynamic iconSize;
  final String iconPlacement;
  final bool borderBottom;
  final BoxDecoration? customStyle;
  final void Function(List<dynamic> value, {bool isChecked, dynamic name})?
      onChange;

  /// Source update:value alias.
  final ValueChanged<List<dynamic>>? onUpdateValue;

  /// Source update:modelValue alias.
  final ValueChanged<List<dynamic>>? onUpdateModelValue;
  List<dynamic> get effectiveValue => modelValue ?? value;
  final List<Widget> children;

  void _toggle(dynamic itemName, bool nextChecked) {
    final next = List<dynamic>.from(effectiveValue);
    if (nextChecked) {
      if (!next.contains(itemName)) next.add(itemName);
    } else {
      next.remove(itemName);
    }
    onChange?.call(next, isChecked: nextChecked, name: itemName);
    onUpdateValue?.call(next);
    onUpdateModelValue?.call(next);
  }

  /// Source group helper: re-emit selected values after child toggle.
  void unCheckedOther([dynamic childInstance]) {
    dynamic name;
    var isChecked = true;
    if (childInstance is UPCheckbox) {
      name = childInstance.name;
      isChecked = childInstance.checked;
    } else if (childInstance is Map) {
      name = childInstance['name'];
      isChecked = childInstance['isChecked'] == true ||
          childInstance['checked'] == true ||
          childInstance['isChecked'] == null;
    } else {
      name = childInstance;
    }
    final values = List<dynamic>.from(effectiveValue);
    onUpdateValue?.call(values);
    onUpdateModelValue?.call(values);
    onChange?.call(values, isChecked: isChecked, name: name);
  }

  /// Source computed: bemClass.
  dynamic get bemClass => <String>['u-checkbox-group--$placement'];

  @override
  Widget build(BuildContext context) {
    final isRow = placement != 'column';
    final content = isRow
        ? Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: children,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          );

    return _UPCheckboxScope(
      group: this,
      child: content,
    );
  }
}

class _UPCheckboxScope extends InheritedWidget {
  const _UPCheckboxScope({
    required this.group,
    required super.child,
  });

  final UPCheckboxGroup group;

  static UPCheckboxGroup? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_UPCheckboxScope>()
        ?.group;
  }

  @override
  bool updateShouldNotify(covariant _UPCheckboxScope oldWidget) {
    return group.effectiveValue != oldWidget.group.effectiveValue ||
        group.disabled != oldWidget.group.disabled ||
        group.activeColor != oldWidget.group.activeColor ||
        group.inactiveColor != oldWidget.group.inactiveColor ||
        group.size != oldWidget.group.size ||
        group.shape != oldWidget.group.shape ||
        group.iconSize != oldWidget.group.iconSize ||
        group.iconColor != oldWidget.group.iconColor ||
        group.labelSize != oldWidget.group.labelSize ||
        group.labelColor != oldWidget.group.labelColor ||
        group.labelDisabled != oldWidget.group.labelDisabled ||
        group.iconPlacement != oldWidget.group.iconPlacement ||
        group.borderBottom != oldWidget.group.borderBottom ||
        group.placement != oldWidget.group.placement;
  }
}

/// 1:1 port of u-checkbox defaults and visual metrics.
class UPCheckbox extends StatelessWidget {
  const UPCheckbox({
    super.key,
    this.name = '',
    this.shape = '',
    this.size = '',
    this.checked = false,
    this.disabled = '',
    this.activeColor = '',
    this.inactiveColor = '',
    this.iconSize = '',
    this.iconColor = '',
    this.label = '',
    this.labelSize = '',
    this.labelColor = '',
    this.labelDisabled = '',
    this.usedAlone = false,
    this.customStyle,
    this.onChange,
    this.onUpdateValue,
    this.onUpdateChecked,
  });

  final dynamic name;
  final String shape;
  final dynamic size;
  final bool checked;
  final dynamic disabled;
  final dynamic activeColor;
  final dynamic inactiveColor;
  final dynamic iconSize;
  final dynamic iconColor;
  final dynamic label;
  final dynamic labelSize;
  final dynamic labelColor;
  final dynamic labelDisabled;
  final bool usedAlone;

  /// Source host helper.
  dynamic get lastError => _upCheckboxLastError[this];
  void error([dynamic payload]) {
    _upCheckboxLastError[this] = payload;
  }

  final BoxDecoration? customStyle;
  final ValueChanged<bool>? onChange;

  /// Source update:modelValue for usedAlone.
  final ValueChanged<bool>? onUpdateValue;

  /// Source update:checked alias.
  final ValueChanged<bool>? onUpdateChecked;

  bool get isDisabled {
    if (disabled is bool) return disabled as bool;
    if (disabled is String) return disabled == 'true';
    return false;
  }

  /// Source `init` / `updateParentData` — parentData is prop-derived.
  Map<String, dynamic> get _state =>
      _upCheckboxState[this] ??= <String, dynamic>{'initialized': false};
  bool get initialized => _state['initialized'] == true;
  void init() {
    updateParentData();
  }

  void updateParentData() {
    // parentData getter rebuilds from local props each access.
    _state['initialized'] = true;
  }

  /// Source parent data snapshot from local props (group fills at runtime).
  Map get parentData {
    dynamic pick(dynamic v, dynamic fallback) {
      if (v == null) return fallback;
      if (v is String && v.trim().isEmpty) return fallback;
      return v;
    }

    return <String, dynamic>{
      'iconSize': pick(iconSize, 12),
      'labelDisabled': pick(labelDisabled, null),
      'disabled': pick(disabled, null),
      'shape': pick(shape, null),
      'activeColor': pick(activeColor, null),
      'inactiveColor': pick(inactiveColor, null),
      'size': pick(size, 18),
      'value': name,
      'modelValue': name,
      'iconColor': pick(iconColor, null),
      'placement': 'row',
      'borderBottom': false,
      'iconPlacement': 'left',
    };
  }

  /// Source emit path for usedAlone hosts.
  void emitEvent([bool? nextChecked]) {
    if (isDisabled) return;
    final next = nextChecked ?? !checked;
    onChange?.call(next);
    onUpdateValue?.call(next);
    onUpdateChecked?.call(next);
  }

  /// Source `setRadioCheckedStatus` alias (checkbox set checked).
  void setRadioCheckedStatus(bool next) => emitEvent(next);

  /// Source click handlers.
  void wrapperClickHandler() => emitEvent();
  void iconClickHandler() => emitEvent();
  void labelClickHandler() => emitEvent();

  bool _asBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is String) {
      if (value.isEmpty) return fallback;
      return value == 'true';
    }
    return fallback;
  }

  bool _hasValue(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.isNotEmpty;
    return true;
  }

  /// Source `formValidate` — requires [context] to reach parent form.
  Future<void> formValidate([dynamic event, BuildContext? context]) async {
    final ctx = context;
    if (ctx == null) return;
    final item = ctx.findAncestorStateOfType<UPFormItemState>();
    final form = ctx.findAncestorStateOfType<UPFormState>();
    if (item == null || form == null) return;
    final prop = item.widget.prop;
    if (prop.isEmpty) return;
    await form.validateField(prop, event: event == null ? null : '$event');
  }

  /// Source computed: elIconColor (selected/plain-aware defaults).
  dynamic get elIconColor {
    if (iconColor != null && '$iconColor'.trim().isNotEmpty) return iconColor;
    return '#ffffff';
  }

  /// Source computed: iconClasses.
  dynamic get iconClasses {
    final classes = <String>['u-checkbox__icon-wrap'];
    if (shape == 'circle' || shape == '')
      classes.add('u-checkbox__icon-wrap--circle');
    if (shape == 'square') classes.add('u-checkbox__icon-wrap--square');
    return classes;
  }

  /// Source computed: iconWrapStyle.
  dynamic get iconWrapStyle {
    final s = size != null && '$size'.trim().isNotEmpty ? size : 21;
    return <String, dynamic>{
      'width': UPUtils.addUnit(s),
      'height': UPUtils.addUnit(s),
    };
  }

  /// Source computed: checkboxStyle.
  dynamic get checkboxStyle {
    final style = <String, dynamic>{};
    if (labelColor != null && '$labelColor'.trim().isNotEmpty) {
      style['color'] = labelColor;
    }
    if (labelSize != null && '$labelSize'.trim().isNotEmpty) {
      style['fontSize'] = UPUtils.addUnit(labelSize);
    }
    return style;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final group = usedAlone ? null : _UPCheckboxScope.of(context);

    final elDisabled =
        _hasValue(disabled) ? _asBool(disabled) : (group?.disabled ?? false);
    final elLabelDisabled = _hasValue(labelDisabled)
        ? _asBool(labelDisabled)
        : (group?.labelDisabled ?? false);
    final elSize = _hasValue(size)
        ? UPUtils.getPx(size)
        : UPUtils.getPx(group?.size ?? 18);
    final elIconSize = _hasValue(iconSize)
        ? UPUtils.getPx(iconSize)
        : UPUtils.getPx(group?.iconSize ?? 12);
    final elActiveColor = _hasValue(activeColor)
        ? (UPUtils.parseColor(activeColor) ?? tokens.primary)
        : (UPUtils.parseColor(group?.activeColor) ?? const Color(0xFF2979FF));
    final elInactiveColor = _hasValue(inactiveColor)
        ? (UPUtils.parseColor(inactiveColor) ?? tokens.disabledColor)
        : (UPUtils.parseColor(group?.inactiveColor) ?? const Color(0xFFC8C9CC));
    final elLabelColor = _hasValue(labelColor)
        ? (UPUtils.parseColor(labelColor) ?? tokens.mainColor)
        : (UPUtils.parseColor(group?.labelColor) ?? tokens.mainColor);
    final elShape = shape.isNotEmpty
        ? shape
        : (group?.shape.isNotEmpty == true ? group!.shape : 'square');
    final elLabelSize = _hasValue(labelSize)
        ? UPUtils.getPx(labelSize)
        : UPUtils.getPx(group?.labelSize ?? 14);
    final iconPlacement = group?.iconPlacement ?? 'left';
    final borderBottom = group?.borderBottom ?? false;
    final placement = group?.placement ?? 'row';

    final isChecked =
        usedAlone ? checked : (group?.effectiveValue.contains(name) ?? checked);

    final markColor = elDisabled
        ? (isChecked ? elInactiveColor : const Color(0x00000000))
        : (isChecked
            ? (UPUtils.parseColor(
                    _hasValue(iconColor) ? iconColor : group?.iconColor) ??
                const Color(0xFFFFFFFF))
            : const Color(0x00000000));

    final bg = isChecked && !elDisabled
        ? elActiveColor
        : (elDisabled ? tokens.bgColor : tokens.cardBgColor);
    final borderColor =
        isChecked && !elDisabled ? elActiveColor : elInactiveColor;
    final radius = elShape == 'circle' ? 100.0 : 3.0;

    void toggle() {
      if (elDisabled) return;
      final next = !isChecked;
      if (usedAlone) {
        onChange?.call(next);
        onUpdateValue?.call(next);
        onUpdateChecked?.call(next);
      } else {
        group?._toggle(name, next);
        onChange?.call(next);
      }
    }

    final iconWrap = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: elDisabled ? null : toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: elSize,
        height: elSize,
        margin: EdgeInsets.only(right: iconPlacement == 'right' ? 0 : 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: isChecked
            ? UPIcon(
                name: 'checkbox-mark',
                size: elIconSize,
                color: markColor,
              )
            : null,
      ),
    );

    final labelText = '$label';
    final labelWidget = labelText.isEmpty
        ? const SizedBox.shrink()
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: (elDisabled || elLabelDisabled) ? null : toggle,
            child: Padding(
              padding: const EdgeInsets.only(left: 5, right: 12),
              child: Text(
                labelText,
                style: TextStyle(
                  color: elDisabled ? elInactiveColor : elLabelColor,
                  fontSize: elLabelSize,
                  height: 1,
                ),
              ),
            ),
          );

    final rowChildren = iconPlacement == 'right'
        ? <Widget>[
            Flexible(child: labelWidget),
            iconWrap,
          ]
        : <Widget>[iconWrap, labelWidget];

    BoxDecoration deco = customStyle ?? const BoxDecoration();
    if (borderBottom && placement == 'column') {
      const sourceWidth = 0.5;
      final callerBorder = customStyle?.border;
      final sourceColor = tokens.borderColor;
      final border = callerBorder is Border
          ? Border(
              // .u-border-bottom uses !important for color and bottom width,
              // leaving caller top/left/right widths intact.
              top: callerBorder.top.copyWith(color: sourceColor),
              right: callerBorder.right.copyWith(color: sourceColor),
              bottom: callerBorder.bottom.copyWith(
                color: sourceColor,
                width: sourceWidth,
                style: BorderStyle.solid,
              ),
              left: callerBorder.left.copyWith(color: sourceColor),
            )
          : callerBorder is BorderDirectional
              ? BorderDirectional(
                  top: callerBorder.top.copyWith(color: sourceColor),
                  start: callerBorder.start.copyWith(color: sourceColor),
                  end: callerBorder.end.copyWith(color: sourceColor),
                  bottom: callerBorder.bottom.copyWith(
                    color: sourceColor,
                    width: sourceWidth,
                    style: BorderStyle.solid,
                  ),
                )
              : Border(
                  bottom: BorderSide(color: sourceColor, width: sourceWidth),
                );
      deco = deco.copyWith(border: border);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: iconPlacement == 'right' && !elDisabled ? toggle : null,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: borderBottom && placement == 'column'
            ? const EdgeInsets.only(bottom: 8)
            : EdgeInsets.zero,
        decoration: deco,
        clipBehavior: Clip.hardEdge,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: rowChildren,
        ),
      ),
    );
  }
}
