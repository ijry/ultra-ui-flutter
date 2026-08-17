import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/up_utils.dart';

/// Port of u-message-input (verification code boxes).
class UPMessageInput extends StatefulWidget {
  const UPMessageInput({
    super.key,
    this.maxlength = 4,
    this.dotFill = false,
    this.mode = 'box',
    this.value = '',
    this.modelValue,
    this.breathe = true,
    this.focus = false,
    this.bold = false,
    this.fontSize = 60,
    this.activeColor = '#2979ff',
    this.inactiveColor = '#606266',
    this.width = 80,
    this.disabledKeyboard = false,
    this.customStyle,
    this.onChange,
    this.onFinish,
    this.onUpdateValue,
    this.onUpdateModelValue,
  });

  final dynamic maxlength;
  final bool dotFill;
  final String mode;
  final dynamic value;

  /// Source v-model / modelValue alias.
  final dynamic modelValue;
  final bool breathe;
  final bool focus;
  final bool bold;
  final dynamic fontSize;
  final dynamic activeColor;
  final dynamic inactiveColor;
  final dynamic width;
  final bool disabledKeyboard;
  final BoxDecoration? customStyle;
  final ValueChanged<String>? onChange;
  final ValueChanged<String>? onFinish;
  final ValueChanged<String>? onUpdateValue;

  /// Source update:modelValue alias.
  final ValueChanged<String>? onUpdateModelValue;
  dynamic get effectiveValue => modelValue ?? value;

  /// Source computed: animationClass(index).
  dynamic animationClass([dynamic index]) {
    final i = int.tryParse('$index') ?? -1;
    if (breathe && charArrLength == i) return 'u-breathe';
    return '';
  }

  /// Source computed: charArr.
  dynamic get charArr => '$effectiveValue'.split('');

  /// Source computed: charArrLength.
  dynamic get charArrLength => (charArr as List).length;

  /// Source computed: loopCharArr.
  dynamic get loopCharArr {
    final n = int.tryParse('$maxlength') ?? 0;
    return List<int>.filled(n < 0 ? 0 : n, 0);
  }

  @override
  State<UPMessageInput> createState() => UPMessageInputState();
}

class UPMessageInputState extends State<UPMessageInput>
    with SingleTickerProviderStateMixin {
  /// Source data.
  dynamic get valueModel => value;

  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final AnimationController _breathe;
  String _value = '';

  int get _max => int.tryParse('${widget.maxlength}') ?? 4;

  String get value => _value;
  bool get isFocused => _focusNode.hasFocus;
  bool get isFinished => _value.length >= _max;

  void setValue(String next, {bool emit = true}) {
    _onChanged(next, emit: emit);
  }

  void clear({bool emit = true}) => setValue('', emit: emit);

  void focus() {
    if (widget.disabledKeyboard) return;
    _focusNode.requestFocus();
  }

  void blur() => _focusNode.unfocus();

  /// Source `getVal` input path.
  void getVal(String raw, {bool emit = true}) => _onChanged(raw, emit: emit);

  @override
  void initState() {
    super.initState();
    final seed = '${widget.effectiveValue}';
    _value = seed.substring(0, seed.length > _max ? _max : seed.length);
    _controller = TextEditingController(text: _value);
    _focusNode = FocusNode();
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.breathe) {
      _breathe.repeat(reverse: true);
    }
    if (widget.focus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !widget.disabledKeyboard) _focusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant UPMessageInput oldWidget) {
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
    _breathe.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String raw, {bool emit = true}) {
    var next = raw.replaceAll(RegExp(r'[^0-9]'), '');
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
      widget.onUpdateValue?.call(next);
      widget.onUpdateModelValue?.call(next);
      if (next.length >= _max) widget.onFinish?.call(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = UPUtils.getPx('${widget.width}rpx');
    final fs = UPUtils.getPx('${widget.fontSize}rpx');
    final active =
        UPUtils.parseColor(widget.activeColor) ?? const Color(0xFF2979FF);
    final inactive =
        UPUtils.parseColor(widget.inactiveColor) ?? const Color(0xFF606266);
    final len = _value.length;

    Widget body = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!widget.disabledKeyboard) _focusNode.requestFocus();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0,
            child: SizedBox(
              width: 1,
              height: 1,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                maxLength: _max,
                enabled: !widget.disabledKeyboard,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: _onChanged,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_max, (index) {
              final ch = index < _value.length ? _value[index] : '';
              final isActive = len == index;
              final borderColor =
                  (isActive && widget.mode == 'box') ? active : inactive;
              final display = widget.dotFill && ch.isNotEmpty ? '●' : ch;

              Widget boxChild = Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.mode == 'middleLine' && ch.isEmpty)
                    Container(
                      width: size * 0.5,
                      height: widget.bold ? 4 : 2,
                      color: isActive ? active : inactive,
                    ),
                  if (widget.mode == 'bottomLine')
                    Positioned(
                      bottom: 0,
                      left: 4,
                      right: 4,
                      child: Container(
                        height: widget.bold ? 4 : 2,
                        color: isActive ? active : inactive,
                      ),
                    ),
                  if (isActive && widget.mode != 'middleLine' && ch.isEmpty)
                    AnimatedBuilder(
                      animation: _breathe,
                      builder: (_, __) {
                        final o = widget.breathe
                            ? (0.35 + 0.65 * _breathe.value)
                            : 1.0;
                        return Opacity(
                          opacity: o,
                          child: Container(
                            width: 1.5,
                            height: size * 0.5,
                            color: active,
                          ),
                        );
                      },
                    ),
                  if (display.isNotEmpty)
                    Text(
                      display,
                      style: TextStyle(
                        color: inactive,
                        fontSize: fs,
                        fontWeight:
                            widget.bold ? FontWeight.w700 : FontWeight.w400,
                        height: 1,
                      ),
                    ),
                ],
              );

              return Container(
                width: size,
                height: size,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: widget.mode == 'box'
                    ? BoxDecoration(
                        border: Border.all(color: borderColor, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      )
                    : null,
                child: boxChild,
              );
            }),
          ),
        ],
      ),
    );

    return body;
  }
}
