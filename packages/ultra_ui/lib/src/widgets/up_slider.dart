import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';

/// 1:1 port of u-slider defaults and events.
class UPSlider extends StatefulWidget {
  const UPSlider({
    super.key,
    this.value = 0,
    this.modelValue,
    this.blockSize = 18,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.activeColor = '#2979ff',
    this.inactiveColor = '#c0c4cc',
    this.blockColor = '#ffffff',
    this.blockStyle,
    this.innerStyle,
    this.barStyle,
    this.barStyle0,
    this.showValue = false,
    this.disabled = false,
    this.vertical = false,
    this.isRange = false,
    this.rangeValue = const [0, 0],
    this.size = '2px',
    this.height = '',
    this.length = 'auto',
    this.customStyle,
    this.onChange,
    this.onInput,
    this.onChanging,
    this.onUpdateValue,
    this.onUpdateModelValue,
    this.useNative = false,
    this.onStart,
    this.onDragStart,
    this.onDragEnd,
    this.onDrag,
  });

  final dynamic value;
  final dynamic modelValue;
  final dynamic blockSize;
  final dynamic min;
  final dynamic max;
  final dynamic step;
  final dynamic activeColor;
  final dynamic inactiveColor;
  final dynamic blockColor;
  final BoxDecoration? blockStyle;
  final dynamic innerStyle;

  /// Source retained active bar style.
  final dynamic barStyle;

  /// Source retained inactive bar style.
  final dynamic barStyle0;
  final bool showValue;
  final bool disabled;
  final bool vertical;
  final bool isRange;
  final List rangeValue;
  final dynamic size;
  final dynamic height;
  final dynamic length;
  final BoxDecoration? customStyle;

  /// Source `change` — emitted when sliding ends.
  final ValueChanged<dynamic>? onChange;

  /// Source emit alias: input.
  final ValueChanged<dynamic>? onInput;

  /// Source `changing` — emitted while dragging.
  final ValueChanged<dynamic>? onChanging;

  /// Source `update:modelValue` / v-model alias.
  final ValueChanged<dynamic>? onUpdateValue;
  final ValueChanged<dynamic>? onUpdateModelValue;
  final bool useNative;

  dynamic get effectiveValue => modelValue ?? value;

  /// Source `start` — first move after touch.
  final VoidCallback? onStart;

  /// Source drag-* emit aliases (host retained).
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;
  final ValueChanged<dynamic>? onDrag;

  /// Source method: initButtonStyle.
  dynamic initButtonStyle([dynamic _]) {
    final size = UPUtils.getPx(blockSize);
    return <String, dynamic>{
      'width': UPUtils.addUnit(size),
      'height': UPUtils.addUnit(size),
      'backgroundColor': blockColor,
      'borderRadius': UPUtils.addUnit(size / 2),
    };
  }

  /// Source computed: touchButtonStyle(barStyle).
  dynamic touchButtonStyle([dynamic barStyleArg]) {
    final style = <String, dynamic>{};
    if (blockSize == null || '$blockSize'.isEmpty) return style;
    final bar = barStyleArg is Map
        ? Map<String, dynamic>.from(barStyleArg)
        : <String, dynamic>{};
    if (vertical) {
      if (bar['height'] != null) {
        style['top'] = '${UPUtils.getPx(bar['height'])}px';
      }
    } else if (bar['width'] != null) {
      style['left'] =
          '${UPUtils.getPx(bar['width']) + UPUtils.getPx(blockSize) / 2}px';
    }
    return style;
  }

  /// Source computed: innerStyleCpu.
  dynamic get innerStyleCpu {
    final style = <String, dynamic>{};
    if (innerStyle is Map) {
      style.addAll(Map<String, dynamic>.from(innerStyle as Map));
    }
    if (vertical) {
      style['flexDirection'] = 'row';
      style['height'] = length;
      style['padding'] = '0';
      style['width'] = (isRange && showValue)
          ? '${UPUtils.getPx(blockSize) + 24}px'
          : '${UPUtils.getPx(blockSize)}px';
    } else {
      style['flexDirection'] = 'column';
      style['height'] = (isRange && showValue)
          ? '${UPUtils.getPx(blockSize) + 24}px'
          : '${UPUtils.getPx(blockSize)}px';
    }
    return style;
  }

  /// Source data default: sizeLocal (height overrides size).
  dynamic get sizeLocal => ('$height'.trim().isNotEmpty) ? height : size;

  @override
  State<UPSlider> createState() => UPSliderState();
}

class UPSliderState extends State<UPSlider> {
  /// Source data.
  bool changeFromInside = false;
  bool touching = false;
  String status = 'end';
  dynamic get touchStatus => status;
  double distanceX = 0;
  double distanceY = 0;
  double startX = 0;
  double startY = 0;
  double startValue = 0;
  double startValue0 = 0;
  dynamic newValue;
  Map info = const {};
  Map sliderRect = const {};
  double? _localValue;
  List? _localRange;

  double _toDouble(dynamic v, [double fallback = 0]) =>
      (num.tryParse('$v') ?? fallback).toDouble();

  double get minN => _toDouble(widget.min, 0);
  double get maxN => _toDouble(widget.max, 100);
  double get stepN => _toDouble(widget.step, 1);

  double _format(double raw) {
    final clamped = raw.clamp(minN, maxN);
    if (stepN <= 0) return clamped;
    final steps = ((clamped - minN) / stepN).round();
    return (minN + steps * stepN).clamp(minN, maxN);
  }

  int _decimalPlaces(dynamic raw) {
    final text = '$raw'.trim().toLowerCase();
    if (text.isEmpty) return 0;
    final exponentIndex = text.indexOf('e');
    final coefficient =
        exponentIndex < 0 ? text : text.substring(0, exponentIndex);
    final exponent = exponentIndex < 0
        ? 0
        : int.tryParse(text.substring(exponentIndex + 1)) ?? 0;
    final decimalIndex = coefficient.indexOf('.');
    final fractionLength =
        decimalIndex < 0 ? 0 : coefficient.length - decimalIndex - 1;
    return (fractionLength - exponent).clamp(0, 15);
  }

  String _displayValue(double value) {
    if (value == 0) return '0';
    final normalized = double.parse(value.toStringAsPrecision(15));
    if (normalized.abs() >= 1e21) return normalized.toString();

    var precision = 0;
    for (final raw in <dynamic>[
      widget.min,
      widget.max,
      widget.step,
      normalized,
    ]) {
      final places = _decimalPlaces(raw);
      if (places > precision) precision = places;
    }

    return normalized
        .toStringAsFixed(precision)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  double get currentValue {
    if (widget.isRange) return lowValue;
    return _localValue ?? _format(_toDouble(widget.effectiveValue, 0));
  }

  double get lowValue {
    final range = _effectiveRange;
    return range[0];
  }

  double get highValue {
    final range = _effectiveRange;
    return range[1];
  }

  List<double> get _effectiveRange {
    if (_localRange != null) {
      return [
        _format(_toDouble(_localRange![0], minN)),
        _format(_toDouble(_localRange![1], maxN)),
      ];
    }
    final lowRaw = widget.rangeValue.isNotEmpty
        ? _toDouble(widget.rangeValue[0], minN)
        : minN;
    final highRaw = widget.rangeValue.length > 1
        ? _toDouble(widget.rangeValue[1], maxN)
        : maxN;
    var low = _format(lowRaw);
    var high = _format(highRaw);
    if (high < low) {
      final t = low;
      low = high;
      high = t;
    }
    return [low, high];
  }

  /// Source-compatible value snapshot.
  dynamic get value => widget.isRange ? [lowValue, highValue] : currentValue;

  @override
  void didUpdateWidget(covariant UPSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.effectiveValue != widget.effectiveValue) {
      _localValue = null;
    }
    if (!identical(oldWidget.rangeValue, widget.rangeValue)) {
      _localRange = null;
    }
  }

  /// Source `init` — re-sync local overrides from props.
  void init() {
    setState(() {
      _localValue = null;
      _localRange = null;
    });
  }

  /// Programmatic single-value write.
  /// Source `updateValue` alias of [setValue].
  void updateValue(dynamic raw,
          {bool emitChange = true, bool emitChanging = false}) =>
      setValue(raw, emitChange: emitChange, emitChanging: emitChanging);

  void setValue(dynamic raw,
      {bool emitChange = true, bool emitChanging = false}) {
    newValue = raw;
    changeFromInside = true;
    if (widget.isRange) {
      if (raw is List && raw.length >= 2) {
        setRange(raw[0], raw[1],
            emitChange: emitChange, emitChanging: emitChanging);
      }
      return;
    }
    final next = _format(_toDouble(raw, 0));
    setState(() => _localValue = next);
    if (emitChanging) {
      widget.onDrag?.call(next);
      widget.onChanging?.call(next);
    }
    if (emitChange) {
      widget.onChange?.call(next);
      widget.onInput?.call(next);
      widget.onDragEnd?.call();
    }
    widget.onUpdateValue?.call(next);
    widget.onUpdateModelValue?.call(next);
  }

  /// Programmatic range write.
  void setRange(
    dynamic low,
    dynamic high, {
    bool emitChange = true,
    bool emitChanging = false,
  }) {
    var a = _format(_toDouble(low, minN));
    var b = _format(_toDouble(high, maxN));
    if (b < a) {
      final t = a;
      a = b;
      b = t;
    }
    final out = [a, b];
    setState(() => _localRange = out);
    if (emitChanging) {
      widget.onDrag?.call(out);
      widget.onChanging?.call(out);
    }
    if (emitChange) {
      widget.onChange?.call(out);
      widget.onInput?.call(out);
      widget.onDragEnd?.call();
    }
    widget.onUpdateValue?.call(out);
    widget.onUpdateModelValue?.call(out);
  }

  /// Source `getSliderStep`.
  double getSliderStep() => stepN;

  /// Source `toSliderNumber` / `normalizeSliderValue` / `formatByStep`.
  double toSliderNumber(dynamic raw) => _format(_toDouble(raw, minN));
  double normalizeSliderValue(dynamic raw) => toSliderNumber(raw);
  double formatByStep(dynamic raw) => toSliderNumber(raw);

  /// Source `changingHandler`.
  void changingHandler(dynamic raw) {
    if (widget.disabled) return;
    setValue(raw, emitChange: false, emitChanging: true);
  }

  /// Source `changeHandler`.
  void changeHandler(dynamic raw) {
    if (widget.disabled) return;
    setValue(raw, emitChange: true, emitChanging: false);
  }

  /// Source touch aliases (host may call without gesture details).
  void onTouchStart([dynamic _]) {
    status = 'start';
    touching = true;
    if (_ is Offset) {
      startX = _.dx;
    } else if (_ is num) {
      startX = _.toDouble();
    } else if (_ is Map) {
      startX = getTouchX(_);
    }
    startValue = currentValue;
    if (widget.isRange) startValue0 = highValue;
    widget.onStart?.call();
    widget.onDragStart?.call();
  }

  void onTouchMove(dynamic raw) {
    status = 'move';
    changingHandler(raw);
  }

  void onTouchEnd([dynamic raw]) {
    status = 'end';
    touching = false;
    if (raw != null) changeHandler(raw);
    widget.onDragEnd?.call();
  }

  void onTouchStart2([dynamic _]) => onTouchStart();
  void onTouchMove2(dynamic raw) => onTouchMove(raw);
  void onTouchEnd2([dynamic raw]) => onTouchEnd(raw);

  /// Source placement / format helpers (Batch I).
  bool canNotDo([dynamic _]) => widget.disabled;
  double format([dynamic raw]) => toSliderNumber(raw ?? currentValue);
  double formatStep([dynamic raw]) => formatByStep(raw ?? currentValue);
  List getRange([dynamic _]) => [lowValue, highValue];
  Map getSliderRect([dynamic _]) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return {'width': 0.0, 'height': 0.0, 'left': 0.0, 'top': 0.0};
    }
    final o = box.localToGlobal(Offset.zero);
    return {
      'width': box.size.width,
      'height': box.size.height,
      'left': o.dx,
      'top': o.dy,
    };
  }

  double getTouchX([dynamic event, dynamic rect]) {
    if (event is Offset) return event.dx;
    if (event is num) return event.toDouble();
    if (event is Map) {
      final x = event['x'] ?? event['clientX'] ?? event['pageX'] ?? 0;
      return double.tryParse('$x') ?? 0;
    }
    return 0;
  }

  void initX([dynamic event]) {
    if (event is Offset) {
      startX = event.dx;
    } else if (event is num) {
      startX = event.toDouble();
    } else if (event is Map) {
      startX = getTouchX(event);
    } else {
      final rect = getSliderRect();
      startX = (rect['left'] as num?)?.toDouble() ?? 0;
    }
    startValue = currentValue;
    if (widget.isRange) startValue0 = highValue;
    sliderRect = getSliderRect();
  }

  void setTouchStatus([dynamic next]) {
    status = '${next ?? status}';
    touching = status == 'start' || status == 'move' || status == 'dragging';
  }

  void updateSliderPlacement([dynamic raw]) {
    if (widget.isRange) {
      if (raw is List && raw.length >= 2) {
        setRange(raw[0], raw[1], emitChange: false, emitChanging: true);
      }
      return;
    }
    setValue(raw, emitChange: false, emitChanging: true);
  }

  void emitEvent([String type = 'change', dynamic value]) {
    final v = value ?? this.value;
    if (type == 'changing') {
      widget.onChanging?.call(v);
    } else {
      widget.onChange?.call(v);
      widget.onInput?.call(v);
    }
    widget.onUpdateValue?.call(v);
    widget.onUpdateModelValue?.call(v);
  }

  int digitLength([num value = 0]) {
    final s = '$value';
    final i = s.indexOf('.');
    return i < 0 ? 0 : s.length - i - 1;
  }

  Future<void> sleep([int ms = 0]) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
  }

  /// Source `onClick`.
  void onClick(dynamic raw) => changeHandler(raw);

  @override
  Widget build(BuildContext context) {
    final active =
        UPUtils.parseColor(widget.activeColor) ?? const Color(0xFF2979FF);
    final inactive =
        UPUtils.parseColor(widget.inactiveColor) ?? const Color(0xFFC0C4CC);
    final block = UPUtils.parseColor(widget.blockColor) ?? Colors.white;
    final trackH = widget.height != null && '${widget.height}'.isNotEmpty
        ? UPUtils.getPx(widget.height)
        : UPUtils.getPx(widget.size);
    final thumb = UPUtils.getPx(widget.blockSize);
    final theme = SliderTheme.of(context).copyWith(
      trackHeight: trackH > 0 ? trackH : 2,
      activeTrackColor: active,
      inactiveTrackColor: inactive,
      thumbColor: block,
      rangeThumbShape:
          RoundRangeSliderThumbShape(enabledThumbRadius: thumb / 2),
      disabledActiveTrackColor: active.withValues(alpha: 0.5),
      disabledInactiveTrackColor: inactive.withValues(alpha: 0.5),
      overlayShape: SliderComponentShape.noOverlay,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: thumb / 2),
    );

    var started = false;
    Widget slider;
    if (widget.isRange) {
      final range = _effectiveRange;
      final low = range[0];
      final high = range[1];
      slider = SliderTheme(
        data: theme,
        child: RangeSlider(
          values: RangeValues(low, high),
          min: minN,
          max: maxN,
          divisions:
              stepN > 0 ? ((maxN - minN) / stepN).round().clamp(1, 1000) : null,
          onChanged: widget.disabled
              ? null
              : (v) {
                  if (!started) {
                    started = true;
                    widget.onStart?.call();
                    widget.onDragStart?.call();
                  }
                  final out = [
                    _format(v.start),
                    _format(v.end),
                  ];
                  setState(() => _localRange = out);
                  widget.onChanging?.call(out);
                  widget.onUpdateValue?.call(out);
                  widget.onUpdateModelValue?.call(out);
                },
          onChangeEnd: widget.disabled
              ? null
              : (v) {
                  final out = [
                    _format(v.start),
                    _format(v.end),
                  ];
                  setState(() => _localRange = out);
                  widget.onChange?.call(out);
                  widget.onInput?.call(out);
                  widget.onDragEnd?.call();
                  widget.onUpdateValue?.call(out);
                  widget.onUpdateModelValue?.call(out);
                },
        ),
      );
      if (widget.showValue) {
        slider = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            slider,
            Text(
              '${_displayValue(low)} - ${_displayValue(high)}',
              style: TextStyle(
                color: UPThemeTokens.of(context).contentColor,
                fontSize: 12,
              ),
            ),
          ],
        );
      }
      if (widget.disabled) {
        // Source applies .u-slider--disabled to the inner range surface,
        // including its optional range labels, not to the outer root.
        slider = Opacity(opacity: 0.5, child: slider);
      }
    } else {
      final val = currentValue;
      slider = SliderTheme(
        data: theme,
        child: Slider(
          value: val,
          min: minN,
          max: maxN,
          divisions:
              stepN > 0 ? ((maxN - minN) / stepN).round().clamp(1, 1000) : null,
          onChangeStart: widget.disabled
              ? null
              : (_) {
                  widget.onStart?.call();
                  widget.onDragStart?.call();
                },
          onChanged: widget.disabled
              ? null
              : (v) {
                  final next = _format(v);
                  setState(() => _localValue = next);
                  widget.onChanging?.call(next);
                  widget.onUpdateValue?.call(next);
                  widget.onUpdateModelValue?.call(next);
                },
          onChangeEnd: widget.disabled
              ? null
              : (v) {
                  final next = _format(v);
                  setState(() => _localValue = next);
                  widget.onChange?.call(next);
                  widget.onInput?.call(next);
                  widget.onDragEnd?.call();
                  widget.onUpdateValue?.call(next);
                  widget.onUpdateModelValue?.call(next);
                },
        ),
      );
      if (widget.disabled) {
        // The single-value label is a source sibling of .u-slider-inner.
        slider = Opacity(opacity: 0.5, child: slider);
      }
      if (widget.showValue) {
        slider = Row(
          children: [
            Expanded(child: slider),
            const SizedBox(width: 8),
            Text(
              _displayValue(val),
              style: TextStyle(
                color: UPThemeTokens.of(context).contentColor,
                fontSize: 14,
              ),
            ),
          ],
        );
      }
    }

    if (widget.vertical) {
      slider = RotatedBox(quarterTurns: -1, child: slider);
    }

    if (widget.customStyle != null) {
      slider = Container(decoration: widget.customStyle, child: slider);
    }

    // length is source layout hint; when numeric, constrain main axis.
    final len = '${widget.length}';
    if (len.isNotEmpty && len != 'auto') {
      final l = UPUtils.getPx(widget.length);
      if (l > 0) {
        slider = SizedBox(
          width: widget.vertical ? null : l,
          height: widget.vertical ? l : null,
          child: slider,
        );
      }
    }

    // Silence unused blockStyle for API parity; apply as thumb overlay hint.
    if (widget.blockStyle != null && !widget.isRange) {
      // Kept for API compatibility; Material thumb is limited.
    }

    return slider;
  }
}
