import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_form.dart';
import 'up_icon.dart';

Map<String, dynamic> _parseUPInputIconStyle(dynamic style) {
  if (style is Map) {
    return style.map((key, value) {
      final normalized = switch ('$key') {
        'font-size' => 'fontSize',
        'font-weight' => 'fontWeight',
        _ => '$key',
      };
      return MapEntry(normalized, value);
    });
  }
  if (style is! String) return const <String, dynamic>{};

  final parsed = <String, dynamic>{};
  for (final declaration in style.split(';')) {
    final separator = declaration.indexOf(':');
    if (separator < 0) continue;
    final key = declaration.substring(0, separator).trim();
    final value = declaration.substring(separator + 1).trim();
    if (key.isEmpty || value.isEmpty) continue;
    parsed[switch (key) {
      'font-size' => 'fontSize',
      'font-weight' => 'fontWeight',
      _ => key,
    }] = value;
  }
  return parsed;
}

bool _isUPInputIconBold(dynamic value) {
  if (value == true) return true;
  if ('$value'.toLowerCase() == 'bold') return true;
  final weight = num.tryParse('$value');
  return weight != null && weight >= 600;
}

class UPInput extends StatefulWidget {
  const UPInput({
    super.key,
    this.value = '',
    this.modelValue,
    this.type = 'text',
    this.disabled = false,
    this.disabledColor = '',
    this.clearable = false,
    this.password = false,
    this.maxlength = 140,
    this.placeholder,
    this.placeholderStyle,
    this.placeholderClass = '',
    this.showWordLimit = false,
    this.focus = false,
    this.inputAlign = 'left',
    this.fontSize = '15px',
    this.color = '',
    this.prefixIcon = '',
    this.suffixIcon = '',
    this.prefixIconStyle,
    this.suffixIconStyle,
    this.border = 'surround',
    this.readonly = false,
    this.shape = 'square',
    this.cursorColor = '#53c21d',
    this.cursorSpacing = 0,
    this.cursor = -1,
    this.selectionStart = -1,
    this.selectionEnd = -1,
    this.confirmType = 'done',
    this.confirmHold = false,
    this.holdKeyboard = false,
    this.adjustPosition = true,
    this.autoBlur = false,
    this.disableDefaultPadding = false,
    this.fixed = false,
    this.ignoreCompositionEvent = true,
    this.onlyClearableOnFocused = true,
    this.passwordVisibilityToggle = true,
    this.onChange,
    this.onConfirm,
    this.onFocus,
    this.onBlur,
    this.onClear,
    this.onKeyboardheightchange,
    this.onNicknamereview,
    this.customStyle,
    this.onUpdateValue,
    this.onUpdateModelValue,
    this.formatter,
  });

  final dynamic value;

  /// Source v-model / modelValue alias.
  final dynamic modelValue;
  final String type;
  final bool disabled;
  final String disabledColor;
  final bool clearable;
  final bool password;
  final int maxlength;
  final String? placeholder;

  /// Source placeholderStyle retained (Map/TextStyle).
  final dynamic placeholderStyle;
  final String placeholderClass;
  final bool showWordLimit;
  final bool focus;
  final String inputAlign;
  final dynamic fontSize;
  final String color;
  final String prefixIcon;
  final String suffixIcon;
  final dynamic prefixIconStyle;
  final dynamic suffixIconStyle;
  final String border;
  final bool readonly;
  final String shape;
  final String cursorColor;
  final dynamic cursorSpacing;
  final int cursor;
  final int selectionStart;
  final int selectionEnd;
  final String confirmType;
  final bool confirmHold;
  final bool holdKeyboard;
  final bool adjustPosition;
  final bool autoBlur;
  final bool disableDefaultPadding;
  final bool fixed;
  final bool ignoreCompositionEvent;
  final bool onlyClearableOnFocused;
  final bool passwordVisibilityToggle;
  final ValueChanged<String>? onChange;
  final ValueChanged<String>? onConfirm;
  final VoidCallback? onFocus;
  final VoidCallback? onBlur;
  final VoidCallback? onClear;

  /// Source platform helper.
  final ValueChanged<dynamic>? onKeyboardheightchange;

  /// Source platform helper.
  final ValueChanged<dynamic>? onNicknamereview;
  final BoxDecoration? customStyle;

  /// Source update:modelValue alias.
  final ValueChanged<String>? onUpdateValue;
  final ValueChanged<String>? onUpdateModelValue;

  /// Source content formatter.
  final String Function(String)? formatter;

  dynamic get effectiveValue => modelValue ?? value;

  /// Source computed: placeholderStyleInner.
  dynamic get placeholderStyleInner {
    if (placeholderStyle != null && '$placeholderStyle'.trim().isNotEmpty) {
      return placeholderStyle;
    }
    return 'color: #909399';
  }

  /// Source computed: inputClass.
  dynamic get inputClass {
    final classes = <String>[];
    if (border == 'surround') {
      classes.add('u-input--radius');
    }
    classes.add('u-input--$shape');
    if (border == 'bottom') {
      classes.add('u-input--no-radius');
    }
    return classes.join(' ');
  }

  /// Source computed: inputBorderColor.
  dynamic get inputBorderColor => '#dadbde';

  /// Source computed: wrapperStyle.
  dynamic get wrapperStyle {
    final style = <String, dynamic>{};
    if (disabled) {
      style['backgroundColor'] =
          disabledColor.isNotEmpty ? disabledColor : '#f3f4f6';
    }
    if (border == 'surround') {
      style['borderWidth'] = '0.5px';
      style['borderStyle'] = 'solid';
      style['borderColor'] = inputBorderColor;
    }
    if (border == 'bottom') {
      style['borderBottomWidth'] = '0.5px';
      style['borderBottomStyle'] = 'solid';
      style['borderBottomColor'] = inputBorderColor;
    }
    if (border == 'none') {
      style['padding'] = '0';
    } else {
      style['paddingTop'] = '6px';
      style['paddingBottom'] = '6px';
      style['paddingLeft'] = '9px';
      style['paddingRight'] = '9px';
    }
    return style;
  }

  /// Source computed: inputStyle.
  dynamic get inputStyle {
    return <String, dynamic>{
      'color': color.isNotEmpty ? color : '#303133',
      'fontSize': UPUtils.addUnit(fontSize),
      'textAlign': inputAlign,
    };
  }

  @override
  State<UPInput> createState() => UPInputState();
}

class UPInputState extends State<UPInput> {
  /// Source platform helper.
  num keyboardHeight = 0;
  void keyboardheightchange([dynamic e]) {
    onkeyboardheightchange(e);
  }

  /// Source platform helper.
  void nicknamereview([dynamic e]) => widget.onNicknamereview?.call(e);

  /// Source host helper.
  Future<void> sleep([int ms = 0]) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
  }

  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _obscure = false;
  String Function(String)? _innerFormatter;

  String get value => _controller.text;
  bool get isFocused => _focusNode.hasFocus;

  /// Source data.
  String get innerValue => _controller.text;
  bool get focused => _focusNode.hasFocus;
  bool get showPassword => _obscure || widget.password;
  String blurValue = '';
  bool changeFromInner = false;
  bool clearInput = false;
  bool firstChange = true;
  dynamic innerFormatter;

  String _applyFormatter(String raw) {
    final fmt = _innerFormatter ?? widget.formatter;
    if (fmt == null) return raw;
    return fmt(raw);
  }

  /// Source `setFormatter`.
  void setFormatter(String Function(String)? formatter) {
    _innerFormatter = formatter;
  }

  /// Source `onInput` / input change path.
  ///
  /// TextField may already have updated the controller; always emit when asked.
  void inputHandler(String raw, {bool emit = true}) {
    changeFromInner = true;
    firstChange = false;
    final formatted = _applyFormatter(raw);
    if (_controller.text != formatted) {
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      setState(() {});
    }
    if (emit) {
      widget.onUpdateValue?.call(formatted);
      widget.onUpdateModelValue?.call(formatted);
      widget.onChange?.call(formatted);
    }
  }

  /// Source aliases around input/clear/confirm.
  void onInput(String raw, {bool emit = true}) => inputHandler(raw, emit: emit);
  void onConfirm([String? raw]) {
    final v = raw ?? value;
    widget.onConfirm?.call(v);
  }

  void onClear([dynamic _]) => clear();
  void valueChange([String? raw]) => setValue(raw ?? value);
  void onkeyboardheightchange([dynamic height]) {
    if (height is num) {
      keyboardHeight = height;
    } else if (height is Map) {
      final h = height['height'] ?? height['detail'];
      if (h is Map && h['height'] is num) {
        keyboardHeight = h['height'] as num;
      } else if (h is num) {
        keyboardHeight = h;
      } else {
        keyboardHeight =
            num.tryParse('${height['height'] ?? ''}') ?? keyboardHeight;
      }
    } else if (height != null) {
      keyboardHeight = num.tryParse('$height') ?? keyboardHeight;
    }
    widget.onKeyboardheightchange?.call(height);
  }

  void onnicknamereview([dynamic e]) {
    widget.onNicknamereview?.call(e);
  }

  /// Source computed: isPassword.
  bool isPassword([dynamic _]) {
    var ret = widget.password || widget.type == 'password';
    // source flips to false when showPassword toggle is active/revealed.
    if (showPassword && widget.passwordVisibilityToggle && !_obscure) {
      // keep password mode when obscure still true; when revealed, not password.
    }
    if (widget.passwordVisibilityToggle &&
        !_obscure &&
        (widget.password || widget.type == 'password')) {
      // revealed
      ret = false;
    } else if (widget.password || widget.type == 'password') {
      ret = true;
    } else {
      ret = false;
    }
    return ret;
  }

  /// Source computed: isShowClear.
  bool isShowClear([dynamic _]) {
    if (!widget.clearable || widget.readonly) return false;
    if (widget.onlyClearableOnFocused) {
      return focused && innerValue.isNotEmpty;
    }
    return innerValue.isNotEmpty;
  }

  /// Source `clickHandler` — focus when interactive.
  void clickHandler() {
    if (widget.disabled || widget.readonly) return;
    focus();
  }

  /// Source `doFocus` alias.
  void doFocus() => focus();

  /// Source `doBlur` alias.
  void doBlur() => blur();

  /// Source `formValidate` — notify parent UPForm via nearest UPFormItem.prop.
  Future<void> formValidate([dynamic event]) async {
    final item = context.findAncestorStateOfType<UPFormItemState>();
    final form = context.findAncestorStateOfType<UPFormState>();
    if (item == null || form == null) return;
    final prop = item.widget.prop;
    if (prop.isEmpty) return;
    await form.validateField(prop, event: event == null ? null : '$event');
  }

  void setValue(String next, {bool emit = true}) {
    final formatted = _applyFormatter(next);
    if (_controller.text == formatted) {
      if (emit) {
        widget.onUpdateValue?.call(formatted);
        widget.onUpdateModelValue?.call(formatted);
        widget.onChange?.call(formatted);
      }
      return;
    }
    _controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    setState(() {});
    if (emit) {
      widget.onUpdateValue?.call(formatted);
      widget.onUpdateModelValue?.call(formatted);
      widget.onChange?.call(formatted);
    }
  }

  void clear({bool emit = true}) {
    clearInput = true;
    if (_controller.text.isEmpty) {
      if (emit) widget.onClear?.call();
      return;
    }
    _controller.clear();
    setState(() {});
    if (emit) {
      widget.onUpdateValue?.call('');
      widget.onUpdateModelValue?.call('');
      widget.onChange?.call('');
      widget.onClear?.call();
    }
  }

  void focus() {
    if (widget.disabled || widget.readonly) return;
    _focusNode.requestFocus();
  }

  /// Source `onFocus` method alias.
  void onFocus([dynamic _]) => focus();

  void blur() => _focusNode.unfocus();

  /// Source `onBlur` method alias.
  void onBlur([dynamic _]) => blur();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.effectiveValue ?? ''}');
    _focusNode = FocusNode();
    _obscure = widget.password || widget.type == 'password';
    _innerFormatter = widget.formatter;
    if (widget.focus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        widget.onFocus?.call();
      } else {
        widget.onBlur?.call();
      }
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant UPInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = '${widget.effectiveValue ?? ''}';
    if (next != _controller.text) {
      _controller.text = next;
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final fontSize = UPUtils.getPx(widget.fontSize);
    final textColor = UPUtils.parseColor(widget.color) ?? tokens.mainColor;
    final prefixIconStyle = _parseUPInputIconStyle(widget.prefixIconStyle);
    final suffixIconStyle = _parseUPInputIconStyle(widget.suffixIconStyle);
    final radius = widget.shape == 'circle' ? 100.0 : 4.0;
    final isDisabled = widget.disabled || widget.readonly;
    final disabledBg =
        UPUtils.parseColor(widget.disabledColor) ?? tokens.bgColor;

    Border? border;
    if (widget.border == 'surround') {
      border = Border.all(
        color: _focusNode.hasFocus ? tokens.primary : tokens.borderColor,
        width: 1,
      );
    } else if (widget.border == 'bottom') {
      border = Border(
        bottom: BorderSide(
          color: _focusNode.hasFocus ? tokens.primary : tokens.borderColor,
          width: 1,
        ),
      );
    }

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: (widget.customStyle ?? const BoxDecoration()).copyWith(
        color: widget.customStyle?.gradient != null
            ? null
            : widget.customStyle?.color ??
                (isDisabled && widget.disabled
                    ? disabledBg
                    : tokens.cardBgColor),
        borderRadius: widget.customStyle?.borderRadius ??
            (widget.border == 'surround'
                ? BorderRadius.circular(radius)
                : null),
        border: widget.customStyle?.border ?? border,
      ),
      child: Row(
        children: [
          if (widget.prefixIcon.isNotEmpty) ...[
            UPIcon(
              name: widget.prefixIcon,
              size: prefixIconStyle['fontSize'] ?? 18,
              color: prefixIconStyle['color'] ?? tokens.tipsColor,
              bold: _isUPInputIconBold(prefixIconStyle['fontWeight']),
              top: prefixIconStyle['top'] ?? 0,
            ),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: !isDisabled,
              obscureText: _obscure,
              maxLength: widget.maxlength < 0 ? null : widget.maxlength,
              cursorColor: UPUtils.parseColor(widget.cursorColor),
              textAlign: widget.inputAlign == 'center'
                  ? TextAlign.center
                  : widget.inputAlign == 'right'
                      ? TextAlign.right
                      : TextAlign.left,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                height: 1.2,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                counterText: '',
                hintText: widget.placeholder,
                hintStyle: TextStyle(
                  color: tokens.tipsColor,
                  fontSize: fontSize,
                ),
              ),
              keyboardType: widget.type == 'number'
                  ? TextInputType.number
                  : widget.type == 'digit'
                      ? const TextInputType.numberWithOptions(decimal: true)
                      : TextInputType.text,
              inputFormatters: widget.type == 'number'
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : null,
              onChanged: (v) => inputHandler(v),
              onSubmitted: widget.onConfirm,
            ),
          ),
          if (widget.clearable &&
              _controller.text.isNotEmpty &&
              _focusNode.hasFocus &&
              !isDisabled)
            GestureDetector(
              onTap: () {
                _controller.clear();
                widget.onUpdateValue?.call('');
                widget.onUpdateModelValue?.call('');
                widget.onChange?.call('');
                widget.onClear?.call();
                setState(() {});
              },
              child: UPIcon(
                name: 'close-circle-fill',
                size: 16,
                color: tokens.tipsColor,
              ),
            ),
          if ((widget.password || widget.type == 'password') &&
              widget.passwordVisibilityToggle) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => setState(() => _obscure = !_obscure),
              child: UPIcon(
                name: _obscure ? 'eye-off' : 'eye',
                size: 18,
                color: tokens.tipsColor,
              ),
            ),
          ],
          if (widget.suffixIcon.isNotEmpty) ...[
            const SizedBox(width: 6),
            UPIcon(
              name: widget.suffixIcon,
              size: suffixIconStyle['fontSize'] ?? 18,
              color: suffixIconStyle['color'] ?? tokens.tipsColor,
              bold: _isUPInputIconBold(suffixIconStyle['fontWeight']),
              top: suffixIconStyle['top'] ?? 0,
            ),
          ],
          if (widget.showWordLimit && widget.maxlength > 0) ...[
            const SizedBox(width: 6),
            Text(
              '${_controller.text.length}/${widget.maxlength}',
              style: TextStyle(color: tokens.tipsColor, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
