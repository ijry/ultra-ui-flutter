import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';

/// 1:1 port of u-subsection (button / subsection modes with sliding bar).
class UPSubsection extends StatefulWidget {
  const UPSubsection({
    super.key,
    this.list = const [],
    this.current = 0,
    this.modelValue,
    this.activeColor = '#3c9cff',
    this.inactiveColor = '#303133',
    this.mode = 'button',
    this.fontSize = 12,
    this.bold = true,
    this.bgColor = '#eeeeef',
    this.keyName = 'name',
    this.activeColorKeyName = 'activeColorKey',
    this.inactiveColorKeyName = 'inactiveColorKey',
    this.disabled = false,
    this.customStyle,
    this.onUpdateCurrent,
    this.onUpdateModelValue,
    this.onChange,
  });

  final List list;
  final dynamic current;

  /// Source v-model alias for current.
  final dynamic modelValue;
  final dynamic activeColor;
  final dynamic inactiveColor;
  final String mode;
  final dynamic fontSize;
  final bool bold;
  final dynamic bgColor;
  final String keyName;
  final String activeColorKeyName;
  final String inactiveColorKeyName;
  final bool disabled;
  final BoxDecoration? customStyle;

  /// Source `update:current` v-model alias.
  final ValueChanged<int>? onUpdateCurrent;

  /// Source update:modelValue alias for current.
  final ValueChanged<int>? onUpdateModelValue;
  final ValueChanged<int>? onChange;

  dynamic get effectiveCurrent => modelValue ?? current;

  /// Source computed: isDarkMode.
  dynamic get isDarkMode => false;

  /// Source computed: resolvedInactiveColor.
  dynamic get resolvedInactiveColor {
    if (inactiveColor != null && '$inactiveColor'.trim().isNotEmpty) {
      return inactiveColor;
    }
    return '#303133';
  }

  /// Source computed: resolvedButtonBgColor.
  dynamic get resolvedButtonBgColor {
    if (bgColor != null && '$bgColor'.trim().isNotEmpty) return bgColor;
    return '#eeeeef';
  }

  /// Source computed: resolvedButtonBarColor.
  dynamic get resolvedButtonBarColor {
    if (disabled) return '#f5f5f5';
    return '#ffffff';
  }

  /// Source computed: resolvedDisabledTextColor.
  dynamic get resolvedDisabledTextColor => '#c8c9cc';

  /// Source computed: resolvedDisabledBorderColor.
  dynamic get resolvedDisabledBorderColor => '#d4d4d4';

  /// Source computed: wrapperStyle.
  dynamic get wrapperStyle {
    final style = <String, dynamic>{};
    if (mode == 'button') {
      style['backgroundColor'] = resolvedButtonBgColor;
    }
    return style;
  }

  /// Source computed: barStyle (width/height filled by state when measured).
  dynamic get barStyle {
    final style = <String, dynamic>{
      'width': '0px',
      'height': '0px',
      'transform': 'translateX(0px)',
    };
    if (mode == 'subsection') {
      style['backgroundColor'] =
          disabled ? resolvedDisabledBorderColor : activeColor;
    } else {
      style['backgroundColor'] = resolvedButtonBarColor;
    }
    return style;
  }

  /// Source computed: itemStyle(index).
  dynamic itemStyle([dynamic index]) {
    final style = <String, dynamic>{};
    if (mode == 'subsection') {
      style['borderColor'] =
          disabled ? resolvedDisabledBorderColor : activeColor;
      style['borderWidth'] = '1px';
      style['borderStyle'] = 'solid';
    }
    return style;
  }

  /// Source computed: textStyle(index, item).
  dynamic textStyle([dynamic index, dynamic item]) {
    final style = <String, dynamic>{
      'fontSize': UPUtils.addUnit(fontSize),
    };
    final i = index is int ? index : int.tryParse('$index') ?? 0;
    final current = int.tryParse('$effectiveCurrent') ?? 0;
    if (disabled) {
      style['fontWeight'] = 'normal';
      style['color'] = resolvedDisabledTextColor;
      return style;
    }
    style['fontWeight'] = (bold && current == i) ? 'bold' : 'normal';
    if (mode == 'subsection') {
      style['color'] = current == i ? '#FFF' : resolvedInactiveColor;
    } else {
      style['color'] = current == i ? activeColor : resolvedInactiveColor;
    }
    return style;
  }

  /// Source data defaults (widget-level snapshot).
  dynamic get innerCurrent => int.tryParse('$effectiveCurrent') ?? 0;
  dynamic get windowResizeCallback => null;

  @override
  State<UPSubsection> createState() => UPSubsectionState();
}

class UPSubsectionState extends State<UPSubsection> {
  /// Source `getTextViewDisableClass`.
  String getTextViewDisableClass([dynamic index]) {
    if (!widget.disabled) return '';
    if (widget.mode == 'button') return 'item-button--disabled';
    return 'item-subsection--disabled';
  }

  /// Source data.
  Map itemRect = const {};

  late int _innerCurrent;
  double _itemWidth = 0;
  double _itemHeight = 0;

  int get currentIndex => _innerCurrent;

  void setCurrent(int index, {bool emit = true}) {
    if (widget.disabled || widget.list.isEmpty) return;
    final next = index.clamp(0, widget.list.length - 1);
    if (_innerCurrent == next) return;
    setState(() => _innerCurrent = next);
    if (emit) {
      widget.onUpdateCurrent?.call(next);
      widget.onUpdateModelValue?.call(next);
      widget.onChange?.call(next);
    }
  }

  void next({bool emit = true}) {
    if (widget.list.isEmpty) return;
    setCurrent((_innerCurrent + 1).clamp(0, widget.list.length - 1),
        emit: emit);
  }

  void prev({bool emit = true}) {
    if (widget.list.isEmpty) return;
    setCurrent((_innerCurrent - 1).clamp(0, widget.list.length - 1),
        emit: emit);
  }

  /// Source `init` — remeasure/sync current.
  void init() {
    final next = int.tryParse('${widget.effectiveCurrent}') ?? 0;
    if (widget.list.isEmpty) {
      _innerCurrent = 0;
      return;
    }
    setCurrent(next.clamp(0, widget.list.length - 1), emit: false);
    getRect();
  }

  /// Source sleep helper (drive with tester.pump under fake async).
  Future<void> sleep([int ms = 0]) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  /// Source `getText`.
  String getText(dynamic item) => _textOf(item);

  /// Source `getRect` — item metrics; live-measure when not yet cached.
  Map<String, double> getRect() {
    if ((_itemWidth <= 0 || _itemHeight <= 0) && mounted) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize && widget.list.isNotEmpty) {
        final len = widget.list.length;
        _itemWidth = box.size.width / len;
        _itemHeight = box.size.height;
        itemRect = {
          'width': _itemWidth,
          'height': _itemHeight,
        };
      }
    }
    return {
      'itemWidth': _itemWidth,
      'itemHeight': _itemHeight,
    };
  }

  /// Source computed: barStyle (measured width/height + translateX).
  dynamic get barStyle {
    final style = <String, dynamic>{
      'width': UPUtils.addUnit(_itemWidth),
      'height': UPUtils.addUnit(_itemHeight),
      'transform': 'translateX(${UPUtils.addUnit(_innerCurrent * _itemWidth)})',
    };
    if (widget.mode == 'subsection') {
      style['backgroundColor'] = widget.disabled
          ? widget.resolvedDisabledBorderColor
          : widget.activeColor;
    } else {
      style['backgroundColor'] = widget.resolvedButtonBarColor;
    }
    return style;
  }

  /// Source `clickHandler`.
  void clickHandler(int index) => setCurrent(index);

  @override
  void initState() {
    super.initState();
    _innerCurrent = int.tryParse('${widget.effectiveCurrent}') ?? 0;
  }

  @override
  void didUpdateWidget(covariant UPSubsection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = int.tryParse('${widget.effectiveCurrent}') ?? 0;
    if (next != _innerCurrent) {
      _innerCurrent = next;
    }
  }

  String _textOf(dynamic item) {
    if (item is Map) return '${item[widget.keyName] ?? ''}';
    return '$item';
  }

  Color? _itemColor(dynamic item, String key) {
    if (item is Map && item[key] != null) {
      return UPUtils.parseColor(item[key]);
    }
    return null;
  }

  BorderRadius _barRadius(int index, int len, bool isButton) {
    if (isButton) return BorderRadius.circular(4);
    if (index <= 0) {
      return const BorderRadius.horizontal(left: Radius.circular(4));
    }
    if (index >= len - 1) {
      return const BorderRadius.horizontal(right: Radius.circular(4));
    }
    return BorderRadius.zero;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final fs = UPUtils.getPx(widget.fontSize);
    final active =
        UPUtils.parseColor(widget.activeColor, fallback: tokens.primary) ??
            tokens.primary;
    final inactive =
        UPUtils.parseColor(widget.inactiveColor, fallback: tokens.mainColor) ??
            tokens.mainColor;
    final bg =
        UPUtils.parseColor(widget.bgColor, fallback: const Color(0xFFEEEEEF)) ??
            const Color(0xFFEEEEEF);
    final isButton = widget.mode != 'subsection';
    final len = widget.list.length;
    final disabledText = tokens.disabledColor;
    final disabledBorder = tokens.borderColor;
    final barColor = isButton
        ? (widget.disabled ? const Color(0xFFF5F5F5) : const Color(0xFFFFFFFF))
        : (widget.disabled ? disabledBorder : active);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final pad = isButton ? 3.0 : 0.0;
        final height = isButton ? 34.0 : 32.0;
        final itemW = len == 0 ? 0.0 : (totalW - pad * 2) / len;
        final itemH = height - pad * 2;
        if ((itemW - _itemWidth).abs() > 0.5 ||
            (itemH - _itemHeight).abs() > 0.5) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _itemWidth = itemW;
              _itemHeight = itemH;
              itemRect = {
                'width': itemW,
                'height': itemH,
              };
            });
          });
        }

        final sourceDecoration = BoxDecoration(
          color: isButton ? bg : const Color(0x00000000),
          borderRadius: BorderRadius.circular(4),
        );
        final callerDecoration = widget.customStyle;
        final decoration = callerDecoration == null
            ? sourceDecoration
            : BoxDecoration(
                // Source wrapperStyle follows customStyle and only supplies
                // backgroundColor in button mode.
                color: callerDecoration.gradient == null
                    ? (isButton
                        ? sourceDecoration.color
                        : callerDecoration.color ?? sourceDecoration.color)
                    : null,
                image: callerDecoration.image ?? sourceDecoration.image,
                border: callerDecoration.border ?? sourceDecoration.border,
                borderRadius: callerDecoration.shape == BoxShape.circle
                    ? null
                    : callerDecoration.borderRadius ??
                        sourceDecoration.borderRadius,
                boxShadow:
                    callerDecoration.boxShadow ?? sourceDecoration.boxShadow,
                gradient:
                    callerDecoration.gradient ?? sourceDecoration.gradient,
                backgroundBlendMode: callerDecoration.backgroundBlendMode ??
                    sourceDecoration.backgroundBlendMode,
                shape: callerDecoration.shape,
              );

        return Container(
          height: height,
          width: double.infinity,
          padding: EdgeInsets.all(pad),
          decoration: decoration,
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              if (len > 0 && _itemWidth > 0)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: _innerCurrent * _itemWidth,
                  top: 0,
                  width: _itemWidth,
                  height: _itemHeight > 0 ? _itemHeight : itemH,
                  child: Container(
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: _barRadius(_innerCurrent, len, isButton),
                    ),
                  ),
                ),
              Row(
                children: List.generate(len, (i) {
                  final item = widget.list[i];
                  final selected = i == _innerCurrent;
                  final itemActive =
                      _itemColor(item, widget.activeColorKeyName) ?? active;
                  final itemInactive =
                      _itemColor(item, widget.inactiveColorKeyName) ?? inactive;

                  Color textColor;
                  if (widget.disabled) {
                    textColor = disabledText;
                  } else if (isButton) {
                    textColor = selected ? itemActive : itemInactive;
                  } else {
                    textColor = selected
                        ? (_itemColor(item, widget.activeColorKeyName) ??
                            const Color(0xFFFFFFFF))
                        : itemInactive;
                  }

                  final borderColor = widget.disabled ? disabledBorder : active;

                  return Expanded(
                    child: GestureDetector(
                      onTap: widget.disabled
                          ? null
                          : () {
                              setState(() => _innerCurrent = i);
                              widget.onUpdateCurrent?.call(i);
                              widget.onUpdateModelValue?.call(i);
                              widget.onChange?.call(i);
                            },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: isButton
                              ? null
                              : Border(
                                  top: BorderSide(color: borderColor),
                                  bottom: BorderSide(color: borderColor),
                                  left: BorderSide(color: borderColor),
                                  right: i == len - 1
                                      ? BorderSide(color: borderColor)
                                      : BorderSide.none,
                                ),
                          borderRadius: !isButton
                              ? (i == 0
                                  ? const BorderRadius.horizontal(
                                      left: Radius.circular(4),
                                    )
                                  : i == len - 1
                                      ? const BorderRadius.horizontal(
                                          right: Radius.circular(4),
                                        )
                                      : null)
                              : null,
                        ),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            color: textColor,
                            fontSize: fs,
                            height: 14 / (fs == 0 ? 12 : fs),
                            fontWeight:
                                widget.bold && selected && !widget.disabled
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                          ),
                          child: Text(_textOf(item)),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
