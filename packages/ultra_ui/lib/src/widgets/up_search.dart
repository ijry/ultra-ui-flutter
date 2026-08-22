import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';

/// 1:1 port of u-search.
class UPSearch extends StatefulWidget {
  const UPSearch({
    super.key,
    this.shape = 'round',
    this.bgColor = '',
    this.placeholder = '请输入关键字',
    this.clearabled = true,
    this.clearable,
    this.onlyClearableOnFocused = true,
    this.focus = false,
    this.showAction = true,
    this.actionText = '搜索',
    this.inputAlign = 'left',
    this.disabled = false,
    this.borderColor = 'transparent',
    this.searchIconColor = '#909399',
    this.searchIconSize = 22,
    this.color = '',
    this.placeholderColor = '',
    this.searchIcon = 'search',
    this.iconPosition = 'left',
    this.margin = '0',
    this.animation = false,
    this.value = '',
    this.modelValue,
    this.maxlength = -1,
    this.height = 32,
    this.label,
    this.actionStyle,
    this.inputStyle,
    this.customStyle,
    this.inputRight,
    this.onChange,
    this.onInput,
    this.onSearch,
    this.onCustom,
    this.onClear,
    this.onFocus,
    this.onBlur,
    this.onClick,
    this.onClickIcon,
    this.onUpdateValue,
    this.onUpdateModelValue,
    this.adjustPosition = true,
    this.autoBlur = true,
  });

  final String shape;
  final String bgColor;
  final String placeholder;
  final bool clearabled;
  final bool? clearable;
  final bool onlyClearableOnFocused;
  final bool focus;
  final bool showAction;
  final String actionText;
  final String inputAlign;
  final bool disabled;
  final String borderColor;
  final dynamic searchIconColor;
  final dynamic searchIconSize;
  final String color;
  final String placeholderColor;
  final String searchIcon;
  final String iconPosition;
  final dynamic margin;
  final bool animation;
  final dynamic value;
  final dynamic modelValue;
  final num maxlength;
  final dynamic height;
  final String? label;
  final TextStyle? actionStyle;
  final TextStyle? inputStyle;
  final BoxDecoration? customStyle;
  final Widget? inputRight;
  final ValueChanged<String>? onChange;

  /// Source emit alias: input.
  final ValueChanged<String>? onInput;
  final ValueChanged<String>? onSearch;

  /// Source `custom` event payload is the keyword.
  final ValueChanged<String>? onCustom;
  final VoidCallback? onClear;
  final ValueChanged<String>? onFocus;
  final ValueChanged<String>? onBlur;
  final VoidCallback? onClick;

  /// Source `clickIcon` event payload is the keyword.
  final ValueChanged<String>? onClickIcon;

  /// Source `update:modelValue` / v-model alias.
  final ValueChanged<String>? onUpdateValue;
  final ValueChanged<String>? onUpdateModelValue;
  final bool adjustPosition;
  final bool autoBlur;

  dynamic get effectiveValue => modelValue ?? value;

  /// Source computed: resolvedBgColor.
  dynamic get resolvedBgColor {
    if (bgColor.trim().isNotEmpty) return bgColor;
    return '#f2f2f2';
  }

  /// Source computed: resolvedBorderColor.
  dynamic get resolvedBorderColor {
    if (borderColor.trim().isNotEmpty && borderColor != 'transparent') {
      return borderColor;
    }
    return borderColor.isEmpty ? 'transparent' : borderColor;
  }

  /// Source computed: resolvedColor.
  dynamic get resolvedColor {
    if (color.trim().isNotEmpty) return color;
    return '#606266';
  }

  /// Source computed: resolvedPlaceholderColor.
  dynamic get resolvedPlaceholderColor {
    if (placeholderColor.trim().isNotEmpty) return placeholderColor;
    return '#909399';
  }

  @override
  State<UPSearch> createState() => UPSearchState();
}

class UPSearchState extends State<UPSearch> {
  /// Source host helper.
  Future<void> setTimeout([dynamic cb, int ms = 0]) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
    if (cb is Function) cb();
  }

  /// Source data.
  bool get focused => isFocused;
  bool show = true;

  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _show = false;
  bool _focused = false;

  String get value => _controller.text;

  bool get isFocused => _focused || _focusNode.hasFocus;

  void setValue(String next, {bool emit = true}) {
    if (_controller.text == next) return;
    _controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
    setState(() {});
    if (emit) _emitValue(next);
  }

  /// Source `clear` method for ref-style callers.
  void clear({bool emit = true}) {
    if (_controller.text.isEmpty) {
      if (emit) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          widget.onClear?.call();
        });
      }
      return;
    }
    _controller.clear();
    setState(() {});
    if (emit) {
      _emitValue('');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onClear?.call();
      });
    }
  }

  /// Focus the input (source `getFocus` / focus prop behavior).
  void focus() {
    if (widget.disabled) return;
    _focusNode.requestFocus();
  }

  /// Source `getFocus` alias.
  void getFocus() => focus();

  /// Blur the input (source `blurFunc` equivalent).
  void blur() {
    _focusNode.unfocus();
  }

  /// Source `blurFunc` alias.
  void blurFunc() => blur();

  /// Trigger search with the current keyword.
  void search([String? keyword]) {
    final v = keyword ?? _controller.text;
    if (keyword != null && keyword != _controller.text) {
      setValue(keyword, emit: true);
    }
    widget.onSearch?.call(v);
    blur();
  }

  /// Trigger the right action button (`custom` event).
  void custom([String? keyword]) {
    final v = keyword ?? _controller.text;
    if (keyword != null && keyword != _controller.text) {
      setValue(keyword, emit: true);
    }
    widget.onCustom?.call(v);
    // Keep onSearch for existing Flutter callers, matching action tap.
    widget.onSearch?.call(v);
    blur();
  }

  /// Source `inputChange`.
  void inputChange(String raw, {bool emit = true}) {
    setValue(raw, emit: emit);
  }

  /// Source `clickHandler` — disabled open / focus path.
  void clickHandler() {
    if (widget.disabled) {
      widget.onClick?.call();
      return;
    }
    focus();
    widget.onClick?.call();
  }

  /// Source `clickIcon`.
  void clickIcon([String? keyword]) {
    final v = keyword ?? _controller.text;
    widget.onClickIcon?.call(v);
  }

  /// Source clear visibility helper.
  bool isShowClear() => _showClear;

  /// Source action visibility helper.
  bool showActionBtn() => _showActionButton;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.effectiveValue ?? ''}');
    _focused = widget.focus;
    _focusNode = FocusNode()
      ..addListener(() {
        if (_focusNode.hasFocus) {
          setState(() {
            _focused = true;
            if (widget.animation && widget.showAction) _show = true;
          });
          widget.onFocus?.call(_controller.text);
        } else {
          // Source delays unfocus flag so clear icon remains tappable.
          Future<void>.delayed(const Duration(milliseconds: 100), () {
            if (!mounted) return;
            setState(() => _focused = false);
          });
          setState(() => _show = false);
          widget.onBlur?.call(_controller.text);
        }
        setState(() {});
      });
    if (widget.focus) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _focusNode.requestFocus());
    }
  }

  @override
  void didUpdateWidget(covariant UPSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = '${widget.effectiveValue ?? ''}';
    if (next != _controller.text && widget.effectiveValue != null) {
      _controller.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _showClear {
    if (!(widget.clearable ?? widget.clearabled) || _controller.text.isEmpty) {
      return false;
    }
    if (widget.onlyClearableOnFocused) return _focused || _focusNode.hasFocus;
    return true;
  }

  bool get _showActionButton {
    if (!widget.showAction) return false;
    if (!widget.animation) return true;
    return _show || _focusNode.hasFocus;
  }

  void _emitValue(String v) {
    widget.onUpdateValue?.call(v);
    widget.onUpdateModelValue?.call(v);
    widget.onChange?.call(v);
    widget.onInput?.call(v);
  }

  EdgeInsets _parseMargin(dynamic margin) {
    if (margin == null || margin == '' || margin == 0 || margin == '0') {
      return EdgeInsets.zero;
    }
    if (margin is num) {
      final v = margin.toDouble();
      return EdgeInsets.all(v);
    }
    final parts = '$margin'.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      final v = UPUtils.getPx(parts[0]);
      return EdgeInsets.all(v);
    }
    if (parts.length == 2) {
      return EdgeInsets.symmetric(
        vertical: UPUtils.getPx(parts[0]),
        horizontal: UPUtils.getPx(parts[1]),
      );
    }
    if (parts.length >= 4) {
      return EdgeInsets.only(
        top: UPUtils.getPx(parts[0]),
        right: UPUtils.getPx(parts[1]),
        bottom: UPUtils.getPx(parts[2]),
        left: UPUtils.getPx(parts[3]),
      );
    }
    return EdgeInsets.zero;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final h = UPUtils.getPx(widget.height);
    // Source resolvedBgColor falls back to --up-card-bg-color, not the generic
    // --up-bg-color; the two differ in both palettes.
    final bg = UPUtils.parseColor(widget.bgColor) ?? tokens.cardBgColor;
    final radius = widget.shape == 'square' ? 4.0 : 100.0;
    final border =
        widget.borderColor == 'transparent' || widget.borderColor.isEmpty
            ? Colors.transparent
            : (UPUtils.parseColor(widget.borderColor) ?? Colors.transparent);
    final textColor = UPUtils.parseColor(widget.color) ?? tokens.contentColor;

    final searchIconWidget = GestureDetector(
      onTap: () => widget.onClickIcon?.call(_controller.text),
      behavior: HitTestBehavior.opaque,
      child: UPUtils.isImage(widget.searchIcon)
          ? Image.network(
              widget.searchIcon,
              width: UPUtils.getPx(widget.searchIconSize),
              height: UPUtils.getPx(widget.searchIconSize),
              errorBuilder: (_, __, ___) => UPIcon(
                name: 'search',
                size: widget.searchIconSize,
                color: widget.searchIconColor,
              ),
            )
          : UPIcon(
              name: widget.searchIcon,
              size: widget.searchIconSize,
              color: widget.searchIconColor,
            ),
    );

    final field = GestureDetector(
      onTap: widget.disabled
          ? widget.onClick
          : () {
              // Source only emits click when disabled.
              if (widget.disabled) widget.onClick?.call();
              _focusNode.requestFocus();
            },
      child: Container(
        height: h,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: border,
            width: border == Colors.transparent ? 0 : 1,
          ),
        ),
        child: Row(
          children: [
            if (widget.label != null && '${widget.label}'.isNotEmpty) ...[
              Text(
                '${widget.label}',
                style: TextStyle(color: tokens.mainColor, fontSize: 14),
              ),
              const SizedBox(width: 4),
            ],
            if (widget.iconPosition != 'right') ...[
              searchIconWidget,
              const SizedBox(width: 5),
            ],
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !widget.disabled,
                maxLength:
                    widget.maxlength < 0 ? null : widget.maxlength.toInt(),
                textAlign: widget.inputAlign == 'center'
                    ? TextAlign.center
                    : widget.inputAlign == 'right'
                        ? TextAlign.right
                        : TextAlign.left,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  height: 1.0,
                ).merge(widget.inputStyle),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  hintText: widget.placeholder,
                  hintStyle: TextStyle(
                    color: UPUtils.parseColor(widget.placeholderColor) ??
                        tokens.tipsColor,
                    fontSize: 14,
                  ),
                ),
                textInputAction: TextInputAction.search,
                onChanged: (v) {
                  setState(() {});
                  _emitValue(v);
                },
                onSubmitted: (v) => widget.onSearch?.call(v),
              ),
            ),
            if (_showClear)
              GestureDetector(
                onTap: () {
                  _controller.clear();
                  _emitValue('');
                  // Source delays clear event one tick after value update.
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    widget.onClear?.call();
                  });
                  setState(() {});
                },
                child: Transform.scale(
                  scale: 0.82,
                  child: Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFC6C7CB),
                      shape: BoxShape.circle,
                    ),
                    child: const UPIcon(
                      name: 'close',
                      size: 11,
                      color: '#ffffff',
                    ),
                  ),
                ),
              ),
            if (widget.iconPosition == 'right') ...[
              const SizedBox(width: 5),
              searchIconWidget,
            ],
            if (widget.inputRight != null) widget.inputRight!,
          ],
        ),
      ),
    );

    Widget row = Row(
      children: [
        Expanded(child: field),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: _showActionButton ? 40 : 0,
          margin: EdgeInsets.only(left: _showActionButton ? 5 : 0),
          alignment: Alignment.center,
          decoration: const BoxDecoration(),
          clipBehavior: Clip.hardEdge,
          child: _showActionButton
              ? GestureDetector(
                  onTap: () {
                    // Source action emits custom(keyword) only.
                    // Keep onSearch for existing Flutter callers.
                    widget.onCustom?.call(_controller.text);
                    widget.onSearch?.call(_controller.text);
                  },
                  child: Text(
                    widget.actionText,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    softWrap: false,
                    style: TextStyle(
                      color: tokens.mainColor,
                      fontSize: 14,
                    ).merge(widget.actionStyle),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );

    if (widget.customStyle != null) {
      row = DecoratedBox(decoration: widget.customStyle!, child: row);
    }

    return Padding(
      padding: _parseMargin(widget.margin),
      child: row,
    );
  }
}
