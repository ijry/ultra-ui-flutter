import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_form.dart';
import 'up_icon.dart';

final Expando<Object> _upRadioChecked = Expando<Object>('upRadioChecked');

final Expando<Map<String, dynamic>> _upRadioState =
    Expando<Map<String, dynamic>>('upRadioState');
final Expando<Object> _upRadioGroupLastError =
    Expando<Object>('upRadioGroupLastError');
final Expando<Object> _upRadioLastError = Expando<Object>('upRadioLastError');

/// Group defaults mirror u-radio-group.
class UPRadioGroup extends StatelessWidget {
  /// Source host helper.
  dynamic get lastError => _upRadioGroupLastError[this];
  void error([dynamic payload]) {
    _upRadioGroupLastError[this] = payload;
  }

  const UPRadioGroup({
    super.key,
    this.value = '',
    this.modelValue,
    this.disabled = false,
    this.shape = 'circle',
    this.activeColor = '#2979ff',
    this.inactiveColor = '#c8c9cc',
    this.name = '',
    this.size = 18,
    this.placement = 'row',
    this.label = '',
    this.labelColor = '#303133',
    this.labelSize = 14,
    this.labelDisabled = false,
    this.iconColor = '#ffffff',
    this.iconSize = 12,
    this.borderBottom = false,
    this.iconPlacement = 'left',
    this.gap = '10px',
    this.customStyle,
    this.onChange,
    this.onUpdateValue,
    this.onUpdateModelValue,
    required this.children,
    this.onInput,
  });

  /// Source emit alias: input -> onInput.
  final ValueChanged<dynamic>? onInput;

  final dynamic value;

  /// Source v-model / modelValue alias.
  final dynamic modelValue;
  final bool disabled;
  final String shape;
  final dynamic activeColor;
  final dynamic inactiveColor;
  final String name;
  final dynamic size;
  final String placement;
  final String label;
  final dynamic labelColor;
  final dynamic labelSize;
  final bool labelDisabled;
  final dynamic iconColor;
  final dynamic iconSize;
  final bool borderBottom;
  final String iconPlacement;
  final dynamic gap;
  final BoxDecoration? customStyle;

  /// Source data.
  bool get checked => false;

  final ValueChanged<dynamic>? onChange;

  /// Source update:value alias.
  final ValueChanged<dynamic>? onUpdateValue;

  /// Source update:modelValue alias.
  final ValueChanged<dynamic>? onUpdateModelValue;
  dynamic get effectiveValue => modelValue ?? value;
  final List<Widget> children;

  void _select(dynamic itemName) {
    if (effectiveValue == itemName) return;
    onChange?.call(itemName);
    onUpdateValue?.call(itemName);
    onUpdateModelValue?.call(itemName);
  }

  /// Source computed: bemClass.
  dynamic get bemClass => <String>['u-radio-group--$placement'];

  /// Source computed: radioGroupStyle.
  dynamic get radioGroupStyle => <String, dynamic>{
        'gap': UPUtils.addUnit(gap),
      };

  /// Source method: unCheckedOther (select one radio by child/name).
  dynamic unCheckedOther([dynamic childInstance]) {
    dynamic name = childInstance;
    if (childInstance is UPRadio) name = childInstance.name;
    if (childInstance is Map && childInstance['name'] != null) {
      name = childInstance['name'];
    }
    if (name != null) _select(name);
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final gapPx = UPUtils.getPx(gap);
    final isRow = placement != 'column';
    final content = isRow
        ? Wrap(
            spacing: gapPx,
            runSpacing: gapPx,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: children,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(height: gapPx),
                children[i],
              ],
            ],
          );

    Widget body = _UPRadioScope(
      group: this,
      child: content,
    );
    if (customStyle != null) {
      body = Container(decoration: customStyle, child: body);
    }
    return body;
  }
}

class _UPRadioScope extends InheritedWidget {
  const _UPRadioScope({
    required this.group,
    required super.child,
  });

  final UPRadioGroup group;

  static UPRadioGroup? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_UPRadioScope>()?.group;
  }

  @override
  bool updateShouldNotify(covariant _UPRadioScope oldWidget) {
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
        group.placement != oldWidget.group.placement ||
        group.gap != oldWidget.group.gap;
  }
}

/// 1:1 port of u-radio defaults and visual metrics.
class UPRadio extends StatelessWidget {
  const UPRadio({
    super.key,
    this.name = '',
    this.shape = '',
    this.disabled = '',
    this.labelDisabled = '',
    this.activeColor = '',
    this.inactiveColor = '',
    this.iconSize = '',
    this.labelSize = '',
    this.label = '',
    this.size = '',
    this.labelColor = '',
    this.iconColor = '',
    this.customStyle,
    this.onChange,
  });

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

  final dynamic name;
  final String shape;
  final dynamic disabled;
  final dynamic labelDisabled;
  final dynamic activeColor;
  final dynamic inactiveColor;
  final dynamic iconSize;
  final dynamic labelSize;
  final dynamic label;
  final dynamic size;
  final dynamic labelColor;
  final dynamic iconColor;
  final BoxDecoration? customStyle;
  final ValueChanged<dynamic>? onChange;

  bool get isDisabled {
    if (disabled is bool) return disabled as bool;
    if (disabled is String) return disabled == 'true';
    return false;
  }

  /// Source `init` / `updateParentData`.
  Map<String, dynamic> get _state =>
      _upRadioState[this] ??= <String, dynamic>{'initialized': false};
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

  bool get checked => _upRadioChecked[this] == true;

  /// Source host helper.
  dynamic get lastError => _upRadioLastError[this];
  void error([dynamic payload]) {
    _upRadioLastError[this] = payload;
  }

  /// Source emit path.
  void emitEvent([dynamic value]) {
    if (isDisabled) return;
    onChange?.call(value ?? name);
  }

  /// Source `setRadioCheckedStatus`.
  void setRadioCheckedStatus([dynamic value]) => emitEvent(value ?? name);

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

  /// Source computed: elIconColor.
  dynamic get elIconColor {
    if (iconColor != null && '$iconColor'.trim().isNotEmpty) return iconColor;
    return '#ffffff';
  }

  /// Source computed: iconClasses.
  dynamic get iconClasses {
    final classes = <String>['u-radio__icon-wrap'];
    if (shape == 'circle' || shape == '')
      classes.add('u-radio__icon-wrap--circle');
    if (shape == 'square') classes.add('u-radio__icon-wrap--square');
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

  /// Source computed: radioStyle.
  dynamic get radioStyle {
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
    final group = _UPRadioScope.of(context);
    final selected = group == null ? false : group.effectiveValue == name;
    _upRadioChecked[this] = selected;

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
        ? (UPUtils.parseColor(labelColor) ?? tokens.contentColor)
        : (UPUtils.parseColor(group?.labelColor) ?? tokens.mainColor);
    final elShape = shape.isNotEmpty
        ? shape
        : (group?.shape.isNotEmpty == true ? group!.shape : 'circle');
    final elLabelSize = _hasValue(labelSize)
        ? UPUtils.getPx(labelSize)
        : UPUtils.getPx(group?.labelSize ?? 14);
    final iconPlacement = group?.iconPlacement ?? 'left';
    final borderBottom = group?.borderBottom ?? false;
    final placement = group?.placement ?? 'row';
    final isChecked = group != null ? group.effectiveValue == name : false;

    final markColor = elDisabled
        ? (isChecked ? elInactiveColor : const Color(0x00000000))
        : (isChecked
            ? (UPUtils.parseColor(
                    _hasValue(iconColor) ? iconColor : group.iconColor) ??
                const Color(0xFFFFFFFF))
            : const Color(0x00000000));

    final bg = isChecked && !elDisabled
        ? elActiveColor
        : (elDisabled ? tokens.bgColor : tokens.cardBgColor);
    final borderColor =
        isChecked && !elDisabled ? elActiveColor : elInactiveColor;
    final radius = elShape == 'square' ? 3.0 : 100.0;

    void select() {
      if (elDisabled) return;
      if (!isChecked) {
        onChange?.call(name);
      }
      group?._select(name);
    }

    final iconWrap = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: elDisabled ? null : select,
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
            onTap: (elDisabled || elLabelDisabled) ? null : select,
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
      onTap: iconPlacement == 'right' && !elDisabled ? select : null,
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
