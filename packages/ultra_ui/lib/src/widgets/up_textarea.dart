import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_form.dart';

/// 1:1 port of u-textarea defaults.
class UPTextarea extends StatefulWidget {
  const UPTextarea({
    super.key,
    this.value = '',
    this.modelValue,
    this.placeholder = '',
    this.placeholderStyle,
    this.placeholderClass = '',
    this.height = 70,
    this.disabled = false,
    this.count = false,
    this.focus = false,
    this.autoHeight = false,
    this.maxlength = 140,
    this.border = 'surround',
    this.cursorSpacing = 0,
    this.cursor = -1,
    this.selectionStart = -1,
    this.selectionEnd = -1,
    this.confirmType = 'done',
    this.showConfirmBar = true,
    this.adjustPosition = true,
    this.disableDefaultPadding = false,
    this.fixed = false,
    this.holdKeyboard = false,
    this.ignoreCompositionEvent = true,
    this.onChange,
    this.onFocus,
    this.onBlur,
    this.onConfirm,
    this.customStyle,
    this.onUpdateValue,
    this.onUpdateModelValue,
    this.formatter,
  });

  final dynamic value;
  final dynamic modelValue;
  final String placeholder;
  final dynamic placeholderStyle;
  final String placeholderClass;
  final dynamic height;
  final bool disabled;
  final bool count;
  final bool focus;
  final bool autoHeight;
  final int maxlength;
  final String border;
  final dynamic cursorSpacing;
  final int cursor;
  final int selectionStart;
  final int selectionEnd;
  final String confirmType;
  final bool showConfirmBar;
  final bool adjustPosition;
  final bool disableDefaultPadding;
  final bool fixed;
  final bool holdKeyboard;
  final bool ignoreCompositionEvent;
  final ValueChanged<String>? onChange;
  final VoidCallback? onFocus;
  final VoidCallback? onBlur;
  final ValueChanged<String>? onConfirm;
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

  /// Source computed: countStyle.
  dynamic get countStyle {
    if (disabled)
      return const <String, dynamic>{'backgroundColor': 'transparent'};
    return const <String, dynamic>{
      'backgroundColor': '#ffffff',
      'color': '#909193',
    };
  }

  /// Source computed: fieldStyle.
  dynamic get fieldStyle {
    final style = <String, dynamic>{
      'height': UPUtils.addUnit(height),
      'backgroundColor': 'transparent',
      'color': '#606266',
      'caretColor': '#303133',
    };
    if (autoHeight) {
      style['height'] = 'auto';
      style['minHeight'] = UPUtils.addUnit(height);
    }
    return style;
  }

  /// Source computed: textareaClass.
  dynamic get textareaClass {
    final classes = <String>[];
    if (border == 'surround') classes.add('u-textarea--radius');
    if (border == 'bottom') classes.add('u-textarea--no-radius');
    if (disabled) classes.add('u-textarea--disabled');
    return classes.join(' ');
  }

  /// Source computed: textareaBorderColor.
  dynamic get textareaBorderColor => '#dadbde';

  /// Source computed: textareaStyle.
  dynamic get textareaStyle {
    final style = <String, dynamic>{
      'backgroundColor': disabled ? '#f5f7fa' : '#ffffff',
      'color': '#606266',
    };
    if (border == 'surround') {
      style['borderWidth'] = '0.5px';
      style['borderStyle'] = 'solid';
      style['borderColor'] = textareaBorderColor;
    }
    if (border == 'bottom') {
      style['borderBottomWidth'] = '0.5px';
      style['borderBottomStyle'] = 'solid';
      style['borderBottomColor'] = textareaBorderColor;
    }
    return style;
  }

  @override
  State<UPTextarea> createState() => UPTextareaState();
}

class UPTextareaState extends State<UPTextarea> {
  /// Source `formValidate` — notify parent UPForm via nearest UPFormItem.prop.
  Future<void> formValidate([dynamic event]) async {
    final item = context.findAncestorStateOfType<UPFormItemState>();
    final form = context.findAncestorStateOfType<UPFormState>();
    if (item == null || form == null) return;
    final prop = item.widget.prop;
    if (prop.isEmpty) return;
    await form.validateField(prop, event: event == null ? null : '$event');
  }

  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String Function(String)? _innerFormatter;

  String get value => _controller.text;
  bool get isFocused => _focusNode.hasFocus;
  int get valueLength => value.length;

  /// Source data.
  String get innerValue => _controller.text;
  bool get focused => _focusNode.hasFocus;
  bool changeFromInner = false;
  bool firstChange = true;
  dynamic innerFormatter;

  String _applyFormatter(String raw) {
    final fmt = _innerFormatter ?? widget.formatter;
    if (fmt == null) return raw;
    return fmt(raw);
  }

  /// Source `normalizeValue`.
  String normalizeValue(String raw) => _applyFormatter(raw);

  /// Source `setFormatter`.
  void setFormatter(String Function(String)? formatter) {
    _innerFormatter = formatter;
  }

  /// Source aliases.
  void valueChange([String? raw]) => setValue(raw ?? value);
  void onConfirm([String? raw]) {
    final v = raw ?? value;
    widget.onConfirm?.call(v);
  }

  /// Source `onInput`.
  void onInput(String raw, {bool emit = true}) {
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

  /// Source `onLinechange` — cache last line count for host inspection.
  int lastLineCount = 1;
  void onLinechange([int lineCount = 1]) {
    lastLineCount = lineCount;
  }

  /// Source `onKeyboardheightchange` — cache last keyboard height for host.
  num keyboardHeight = 0;
  void onKeyboardheightchange([dynamic height]) {
    if (height is num) {
      keyboardHeight = height;
    } else if (height is Map && height['height'] is num) {
      keyboardHeight = height['height'] as num;
    } else if (height != null) {
      keyboardHeight = num.tryParse('$height') ?? keyboardHeight;
    }
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
    if (_controller.text.isEmpty) return;
    _controller.clear();
    setState(() {});
    if (emit) {
      widget.onUpdateValue?.call('');
      widget.onUpdateModelValue?.call('');
      widget.onChange?.call('');
    }
  }

  void focus() {
    if (widget.disabled) return;
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
    _innerFormatter = widget.formatter;
    _focusNode = FocusNode()
      ..addListener(() {
        if (_focusNode.hasFocus) {
          widget.onFocus?.call();
        } else {
          widget.onBlur?.call();
        }
        setState(() {});
      });
    if (widget.focus) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _focusNode.requestFocus());
    }
  }

  @override
  void didUpdateWidget(covariant UPTextarea oldWidget) {
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
    final h = UPUtils.getPx(widget.height);
    Border? border;
    if (widget.border == 'surround') {
      border = Border.all(
        color: _focusNode.hasFocus ? tokens.primary : tokens.borderColor,
      );
    } else if (widget.border == 'bottom') {
      border = Border(
        bottom: BorderSide(
          color: _focusNode.hasFocus ? tokens.primary : tokens.borderColor,
        ),
      );
    }

    final field = TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: !widget.disabled,
      maxLines: null,
      minLines: widget.autoHeight ? 3 : null,
      expands: !widget.autoHeight,
      maxLength: widget.maxlength < 0 ? null : widget.maxlength,
      style: TextStyle(
        color: tokens.mainColor,
        fontSize: 15,
        height: 1.4,
      ),
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        counterText: '',
        hintText: widget.placeholder,
        hintStyle: TextStyle(color: tokens.tipsColor, fontSize: 15),
      ),
      onChanged: (v) => onInput(v),
      onSubmitted: widget.onConfirm,
      textInputAction: TextInputAction.done,
      inputFormatters: widget.maxlength > 0
          ? [LengthLimitingTextInputFormatter(widget.maxlength)]
          : null,
    );

    return Container(
      constraints: widget.autoHeight
          ? BoxConstraints(minHeight: h)
          : BoxConstraints.tightFor(height: h + (widget.count ? 22 : 0)),
      padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
      decoration: (widget.customStyle ?? const BoxDecoration()).copyWith(
        color: widget.customStyle?.gradient != null
            ? null
            : widget.customStyle?.color ??
                (widget.disabled ? tokens.bgColor : tokens.cardBgColor),
        borderRadius: widget.customStyle?.borderRadius ??
            (widget.border == 'surround' ? BorderRadius.circular(4) : null),
        border: widget.customStyle?.border ?? border,
      ),
      child: Column(
        mainAxisSize: widget.autoHeight ? MainAxisSize.min : MainAxisSize.max,
        children: [
          if (widget.autoHeight) field else Expanded(child: field),
          if (widget.count && widget.maxlength > 0)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_controller.text.length}/${widget.maxlength}',
                style: TextStyle(color: tokens.tipsColor, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
