import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../utils/up_utils.dart';

class UPCodeInput extends StatefulWidget {
  const UPCodeInput({
    super.key,
    this.adjustPosition = true,
    this.maxlength = 6,
    this.dot = false,
    this.mode = 'box',
    this.hairline = false,
    this.space = 10,
    this.value = '',
    this.modelValue,
    this.focus = false,
    this.bold = false,
    this.color = '#606266',
    this.fontSize = 18,
    this.size = 35,
    this.disabledKeyboard = false,
    this.borderColor = '#c9cacc',
    this.disabledDot = true,
    this.customStyle,
    this.onChange,
    this.onInput,
    this.onFinish,
    this.onUpdateValue,
    this.onUpdateModelValue,
  });

  final bool adjustPosition;
  final dynamic maxlength;
  final bool dot;
  final String mode;
  final bool hairline;
  final dynamic space;
  final dynamic value;

  /// Source v-model / modelValue alias.
  final dynamic modelValue;
  final bool focus;
  final bool bold;
  final dynamic color;
  final dynamic fontSize;
  final dynamic size;
  final bool disabledKeyboard;
  final dynamic borderColor;
  final bool disabledDot;
  final BoxDecoration? customStyle;
  final ValueChanged<String>? onChange;

  /// Source emit alias: input.
  final ValueChanged<String>? onInput;
  final ValueChanged<String>? onFinish;
  final ValueChanged<String>? onUpdateValue;

  /// Source update:modelValue alias.
  final ValueChanged<String>? onUpdateModelValue;

  dynamic get effectiveValue => modelValue ?? value;

  /// Source computed: itemStyle(index).
  dynamic itemStyle([dynamic index]) {
    final i = index is int ? index : int.tryParse('$index') ?? 0;
    final max = int.tryParse('$maxlength') ?? 6;
    final style = <String, dynamic>{
      'width': UPUtils.addUnit(size),
      'height': UPUtils.addUnit(size),
    };
    if (mode == 'box') {
      style['border'] = '${hairline ? 0.5 : 1}px solid $borderColor';
      if (UPUtils.getPx(space) == 0) {
        if (i == 0) {
          style['borderTopLeftRadius'] = '3px';
          style['borderBottomLeftRadius'] = '3px';
        }
        if (i == max - 1) {
          style['borderTopRightRadius'] = '3px';
          style['borderBottomRightRadius'] = '3px';
        }
        if (i != max - 1) {
          style['borderRight'] = 'none';
        }
      }
    }
    if (i != max - 1) {
      style['marginRight'] = UPUtils.addUnit(space);
    } else {
      style['marginRight'] = 0;
    }
    return style;
  }

  /// Source computed: lineStyle.
  dynamic get lineStyle => <String, dynamic>{
        'height': hairline ? '2px' : '4px',
        'width': UPUtils.addUnit(size),
        'backgroundColor': borderColor,
      };

  @override
  State<UPCodeInput> createState() => UPCodeInputState();
}

class UPCodeInputState extends State<UPCodeInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String _value = '';

  /// Source data.
  String get inputValue => _value;
  bool get isFocus => _focusNode.hasFocus;
  dynamic timer;

  int get _max => int.tryParse('${widget.maxlength}') ?? 6;

  String get value => _value;
  bool get isFocused => _focusNode.hasFocus;
  bool get isFinished => _value.length >= _max;

  /// Source code helpers (Batch K).
  int get codeLength => _value.length;
  List<String> get codeArray {
    final chars = _value.split('');
    while (chars.length < _max) {
      chars.add('');
    }
    return chars.take(_max).toList();
  }

  void setValue(String next, {bool emit = true}) {
    _onChanged(next, emit: emit);
  }

  void clear({bool emit = true}) => setValue('', emit: emit);

  void focus() {
    if (widget.disabledKeyboard) return;
    _focusNode.requestFocus();
  }

  void blur() => _focusNode.unfocus();

  /// Source `inputHandler`.
  void inputHandler(String raw, {bool emit = true}) =>
      _onChanged(raw, emit: emit);

  @override
  void initState() {
    super.initState();
    final seed = '${widget.effectiveValue}';
    _value = seed.substring(0, seed.length > _max ? _max : seed.length);
    _controller = TextEditingController(text: _value);
    _focusNode = FocusNode();
    if (widget.focus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant UPCodeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = '${widget.effectiveValue}';
    if (next != _value) {
      _value = next.substring(0, next.length > _max ? _max : next.length);
      _controller.value = TextEditingValue(
        text: _value,
        selection: TextSelection.collapsed(offset: _value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String raw, {bool emit = true}) {
    var next = raw;
    if (widget.disabledDot) {
      next = next.replaceAll('.', '');
    }
    if (next.length > _max) next = next.substring(0, _max);
    if (next == _value && _controller.text == next) return;
    setState(() => _value = next);
    if (_controller.text != next) {
      _controller.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
    if (emit) {
      widget.onChange?.call(next);
      widget.onInput?.call(next);
      widget.onUpdateValue?.call(next);
      widget.onUpdateModelValue?.call(next);
      if (next.length >= _max) {
        widget.onFinish?.call(next);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = UPUtils.getPx(widget.size);
    final space = UPUtils.getPx(widget.space);
    final fs = UPUtils.getPx(widget.fontSize);
    final color = UPUtils.parseColor(widget.color) ?? const Color(0xFF606266);
    final border =
        UPUtils.parseColor(widget.borderColor) ?? const Color(0xFFC9CACC);
    final chars = _value.split('');
    final isLine = widget.mode == 'line';
    final bw = widget.hairline ? 0.5 : 1.0;

    Widget body = SizedBox(
      height: size,
      child: Stack(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_max, (i) {
              final ch = i < chars.length ? chars[i] : '';
              return Container(
                width: size,
                height: size,
                margin: EdgeInsets.only(right: i == _max - 1 ? 0 : space),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: isLine ? null : Border.all(color: border, width: bw),
                  borderRadius: !isLine && space == 0
                      ? BorderRadius.horizontal(
                          left: i == 0 ? const Radius.circular(3) : Radius.zero,
                          right: i == _max - 1
                              ? const Radius.circular(3)
                              : Radius.zero,
                        )
                      : (isLine ? null : BorderRadius.circular(3)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (widget.dot && ch.isNotEmpty)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      )
                    else
                      Text(
                        ch,
                        style: TextStyle(
                          color: color,
                          fontSize: fs,
                          fontWeight:
                              widget.bold ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    if (isLine)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: widget.hairline ? 2 : 4,
                          color: border,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: EditableText(
                controller: _controller,
                focusNode: _focusNode,
                style: const TextStyle(color: Color(0x00000000), fontSize: 1),
                cursorColor: const Color(0x00000000),
                backgroundCursorColor: const Color(0x00000000),
                keyboardType: TextInputType.number,
                maxLines: 1,
                readOnly: widget.disabledKeyboard,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    widget.disabledDot ? RegExp(r'[0-9]') : RegExp(r'[0-9.]'),
                  ),
                  LengthLimitingTextInputFormatter(_max),
                ],
                onChanged: _onChanged,
              ),
            ),
          ),
        ],
      ),
    );

    return body;
  }
}
