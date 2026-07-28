import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';

typedef UPNumberBoxSlotBuilder = Widget Function(
  BuildContext context,
  num value,
  bool disabled,
);

/// 1:1 port of u-number-box defaults and metrics.
class UPNumberBox extends StatefulWidget {
  const UPNumberBox({
    super.key,
    this.name = '',
    this.value = 0,
    this.modelValue,
    this.min = 1,
    this.max = 9007199254740991,
    this.step = 1,
    this.integer = false,
    this.disabled = false,
    this.disabledInput = false,
    this.asyncChange = false,
    this.inputWidth = 35,
    this.showMinus = true,
    this.showPlus = true,
    this.decimalLength,
    this.longPress = true,
    this.color = '',
    this.buttonWidth = 30,
    this.buttonSize = 30,
    this.buttonRadius = '0px',
    this.bgColor = '',
    this.disabledBgColor = '',
    this.inputBgColor = '',
    this.disablePlus = false,
    this.disableMinus = false,
    this.miniMode = false,
    this.cursorSpacing = 100,
    this.iconStyle,
    this.minusBuilder,
    this.inputBuilder,
    this.plusBuilder,
    this.onChange,
    this.onFocus,
    this.onBlur,
    this.onInput,
    this.onPlus,
    this.onMinus,
    this.onChangeDetail,
    this.onOverlimit,
    this.customStyle,
    this.onUpdateValue,
    this.onUpdateModelValue,
  });

  final dynamic name;
  final dynamic value;

  /// Source v-model / modelValue alias.
  final dynamic modelValue;
  final dynamic min;
  final dynamic max;
  final dynamic step;
  final bool integer;
  final bool disabled;
  final bool disabledInput;
  final bool asyncChange;
  final dynamic inputWidth;
  final bool showMinus;
  final bool showPlus;
  final dynamic decimalLength;
  final bool longPress;
  final dynamic color;
  final dynamic buttonWidth;
  final dynamic buttonSize;
  final dynamic buttonRadius;
  final dynamic bgColor;
  final dynamic disabledBgColor;
  final dynamic inputBgColor;
  final bool disablePlus;
  final bool disableMinus;
  final bool miniMode;

  /// Source keyboard cursor spacing (px; host retained).
  final dynamic cursorSpacing;

  /// Source retained icon style map/string.
  final dynamic iconStyle;
  final UPNumberBoxSlotBuilder? minusBuilder;
  final UPNumberBoxSlotBuilder? inputBuilder;
  final UPNumberBoxSlotBuilder? plusBuilder;
  final void Function(num value, {dynamic name})? onChange;
  final VoidCallback? onFocus;
  final VoidCallback? onBlur;
  final ValueChanged<num>? onInput;
  final VoidCallback? onPlus;
  final VoidCallback? onMinus;
  final ValueChanged<Map<String, dynamic>>? onChangeDetail;
  final ValueChanged<String>? onOverlimit;
  final BoxDecoration? customStyle;

  /// Source update:value alias.
  final ValueChanged<num>? onUpdateValue;

  /// Source update:modelValue alias.
  final ValueChanged<num>? onUpdateModelValue;
  dynamic get effectiveValue => modelValue ?? value;

  /// Source computed: resolvedColor.
  dynamic get resolvedColor {
    if (color != null && '$color'.trim().isNotEmpty) return color;
    return '#303133';
  }

  /// Source computed: resolvedDisabledIconColor.
  dynamic get resolvedDisabledIconColor => '#c8c9cc';

  /// Source computed: resolvedBgColor.
  dynamic get resolvedBgColor {
    if (bgColor != null && '$bgColor'.trim().isNotEmpty) return bgColor;
    return '#EBECEE';
  }

  /// Source computed: resolvedDisabledBgColor.
  dynamic get resolvedDisabledBgColor {
    if (disabledBgColor != null && '$disabledBgColor'.trim().isNotEmpty) {
      return disabledBgColor;
    }
    return '#f7f8fa';
  }

  /// Source computed: resolvedInputBgColor.
  dynamic get resolvedInputBgColor {
    if (inputBgColor != null && '$inputBgColor'.trim().isNotEmpty) {
      return inputBgColor;
    }
    return resolvedBgColor;
  }

  /// Source computed: buttonStyle(type).
  dynamic buttonStyle([dynamic type]) {
    final style = <String, dynamic>{
      'backgroundColor': resolvedBgColor,
      'width': UPUtils.addUnit(buttonWidth),
      'height': UPUtils.addUnit(buttonSize),
      'color': resolvedColor,
      'borderRadius': buttonRadius,
    };
    return style;
  }

  /// Source computed: inputStyle.
  dynamic get inputStyle {
    return <String, dynamic>{
      'color': resolvedColor,
      'backgroundColor': resolvedInputBgColor,
      'height': UPUtils.addUnit(buttonSize),
      'width': UPUtils.addUnit(inputWidth),
    };
  }

  /// Source computed: watchChange dependency tuple.
  dynamic watchChange([dynamic _]) => [integer, decimalLength, min, max];

  /// Source computed: hideMinus.
  dynamic get hideMinus {
    final raw = effectiveValue;
    final n = raw is num ? raw : num.tryParse('$raw') ?? 0;
    return n == 0 && miniMode == true;
  }

  @override
  State<UPNumberBox> createState() => UPNumberBoxState();
}

class UPNumberBoxState extends State<UPNumberBox> {
  /// Source data.
  dynamic longPressTimer;

  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  num _current = 0;

  @override
  void initState() {
    super.initState();
    _current = _format(widget.effectiveValue);
    _controller = TextEditingController(text: '$_current');
    _focusNode = FocusNode()
      ..addListener(() {
        if (_focusNode.hasFocus) {
          widget.onFocus?.call();
        } else {
          widget.onBlur?.call();
          _commit(_controller.text);
        }
      });
  }

  @override
  void didUpdateWidget(covariant UPNumberBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _format(widget.effectiveValue);
    if (next != _current) {
      _current = next;
      _controller.text = '$_current';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Source-compatible current value.
  num get value => _current;
  num get currentValue => _current;
  bool get isFocused => _focusNode.hasFocus;

  /// Source `init` — re-sync from widget value.
  void init() {
    final next = _format(widget.effectiveValue);
    setState(() {
      _current = next;
      _controller.text = '$next';
    });
  }

  /// Programmatic value write (also works with asyncChange).
  void setValue(dynamic raw, {String type = ''}) {
    final formatted = _format(raw);
    setState(() {
      _current = formatted;
      _controller.text = '$formatted';
    });
    widget.onChange?.call(formatted, name: widget.name);
    widget.onUpdateValue?.call(formatted);
    widget.onUpdateModelValue?.call(formatted);
    widget.onChangeDetail?.call({
      'value': formatted,
      'name': widget.name,
      'type': type,
    });
  }

  /// Source helpers.
  bool isDisabled([String type = '']) {
    if (widget.disabled) return true;
    if (type.isEmpty) return false;
    return _isDisabled(type);
  }

  num format([dynamic raw]) => _format(raw);
  num filter([dynamic raw]) => _format(raw);

  void onInput([dynamic raw]) {
    final next = _format(raw ?? _controller.text);
    setState(() {
      _current = next;
      _controller.text = '$next';
    });
    widget.onInput?.call(next);
  }

  void onChange([String type = '']) => emitChange(type);

  void add([dynamic _]) => plus();

  /// Source `clickHandler('plus'|'minus')`.
  /// Source `clickHandler('plus'|'minus')`.
  void clickHandler(String type) => _stepBy(type);

  /// Source handler alias (Batch J).
  void handler([String type = 'plus']) {
    if (type == 'minus') {
      minus();
    } else {
      plus();
    }
  }

  void plus() => clickHandler('plus');
  void minus() => clickHandler('minus');

  /// Source `check` / re-format current value.
  void check() {
    setValue(_current);
  }

  /// Source `emitChange`.
  void emitChange([String type = '']) {
    widget.onChange?.call(_current, name: widget.name);
    widget.onUpdateValue?.call(_current);
    widget.onUpdateModelValue?.call(_current);
    widget.onChangeDetail?.call({
      'value': _current,
      'name': widget.name,
      'type': type,
    });
  }

  /// Source long-press helpers.
  bool _pressing = false;
  void longPressStep(String type) => clickHandler(type);
  void onTouchStart([dynamic type]) {
    _pressing = true;
    if (type is String && type.isNotEmpty) {
      longPressStep(type);
    }
  }

  void onTouchEnd([dynamic _]) {
    _pressing = false;
    clearTimeout();
  }

  void clearTimeout() {
    _pressing = false;
  }

  bool get isPressing => _pressing;

  /// Source keyboard helper (Batch K).
  double getCursorSpacing([dynamic _]) => UPUtils.getPx(widget.cursorSpacing);

  void focus() {
    if (widget.disabled || widget.disabledInput) return;
    _focusNode.requestFocus();
  }

  /// Source `onFocus` method alias.
  void onFocus([dynamic _]) => focus();

  void blur() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    } else {
      _commit(_controller.text);
    }
  }

  /// Source `onBlur` method alias.
  void onBlur([dynamic _]) => blur();

  void clear() {
    setValue(_min);
  }

  num get _min => num.tryParse('${widget.min}') ?? 1;
  num get _max => num.tryParse('${widget.max}') ?? 9007199254740991;
  num get _step => num.tryParse('${widget.step}') ?? 1;

  num _format(dynamic raw) {
    var n = num.tryParse('$raw') ?? _min;
    if (widget.integer) n = n.round();
    if (widget.decimalLength != null) {
      final d = int.tryParse('${widget.decimalLength}') ?? 0;
      n = num.parse(n.toStringAsFixed(d));
    }
    if (n < _min) n = _min;
    if (n > _max) n = _max;
    return n;
  }

  void _emit(num next, [String type = '']) {
    final formatted = _format(next);
    if (!widget.asyncChange) {
      setState(() {
        _current = formatted;
        _controller.text = '$formatted';
      });
    }
    widget.onChange?.call(formatted, name: widget.name);
    if (!widget.asyncChange) {
      widget.onUpdateValue?.call(formatted);
      widget.onUpdateModelValue?.call(formatted);
    }
    widget.onChangeDetail?.call({
      'value': formatted,
      'name': widget.name,
      'type': type,
    });
  }

  void _commit(String text) {
    final n = num.tryParse(text);
    if (n == null) {
      _controller.text = '$_current';
      return;
    }
    _emit(n);
  }

  bool _isDisabled(String type) {
    if (widget.disabled) return true;
    if (type == 'minus') {
      return widget.disableMinus || _current <= _min;
    }
    return widget.disablePlus || _current >= _max;
  }

  void _stepBy(String type) {
    if (_isDisabled(type)) {
      widget.onOverlimit?.call(type);
      return;
    }
    final next = type == 'minus' ? _current - _step : _current + _step;
    if (next < _min || next > _max) {
      widget.onOverlimit?.call(type);
    }
    _emit(next, type);
    if (type == 'minus') {
      widget.onMinus?.call();
    } else {
      widget.onPlus?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final color = UPUtils.parseColor(widget.color) ?? tokens.mainColor;
    final bg = UPUtils.parseColor(widget.bgColor) ?? const Color(0xFFEBECEE);
    final disabledBg =
        UPUtils.parseColor(widget.disabledBgColor) ?? const Color(0xFFF7F8FA);
    final inputBg = UPUtils.parseColor(widget.inputBgColor) ?? bg;
    final size = UPUtils.getPx(widget.buttonSize);
    final btnW = UPUtils.getPx(widget.buttonWidth);
    final inputW = UPUtils.getPx(widget.inputWidth);
    final radius = UPUtils.getPx(widget.buttonRadius);
    final hideMinus = widget.miniMode && _current == 0;

    Widget button(String type) {
      final disabled = _isDisabled(type);
      final slot = type == 'minus' ? widget.minusBuilder : widget.plusBuilder;
      final content = slot?.call(context, _current, disabled) ??
          Container(
            width: btnW,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: disabled ? disabledBg : bg,
              borderRadius: BorderRadius.circular(radius),
            ),
            child: UPIcon(
              name: type == 'minus' ? 'minus' : 'plus',
              size: 15,
              bold: true,
              color: disabled ? tokens.disabledColor : color,
            ),
          );
      return GestureDetector(
        onTap: () => _stepBy(type),
        onLongPressStart: widget.longPress
            ? (_) async {
                while (mounted && !_isDisabled(type)) {
                  _stepBy(type);
                  await Future<void>.delayed(const Duration(milliseconds: 100));
                }
              }
            : null,
        child: content,
      );
    }

    Widget input() {
      final slot = widget.inputBuilder;
      if (slot != null) {
        return slot(context, _current, widget.disabled || widget.disabledInput);
      }
      return SizedBox(
        width: inputW,
        height: size,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: !(widget.disabled || widget.disabledInput),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 14,
            height: 1.2,
          ),
          keyboardType: widget.integer
              ? TextInputType.number
              : const TextInputType.numberWithOptions(decimal: true),
          inputFormatters:
              widget.integer ? [FilteringTextInputFormatter.digitsOnly] : null,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: inputBg,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (v) {
            final n = num.tryParse(v);
            if (n != null) {
              widget.onInput?.call(n);
              widget.onChange?.call(n, name: widget.name);
            }
          },
          onSubmitted: _commit,
        ),
      );
    }

    Widget body = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showMinus && !hideMinus) button('minus'),
        if (!hideMinus) input(),
        if (widget.showPlus) button('plus'),
      ],
    );
    return body;
  }
}
