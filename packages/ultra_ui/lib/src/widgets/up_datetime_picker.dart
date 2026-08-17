import 'package:flutter/widgets.dart';

import 'up_input.dart';
import 'up_picker.dart';

String _pad(int n) => n.toString().padLeft(2, '0');

/// 1:1 API-compatible shell of u-datetime-picker (built on UPPicker).
class UPDatetimePicker extends StatefulWidget {
  const UPDatetimePicker({
    super.key,
    this.hasInput = false,
    this.inputProps = const {},
    this.inputBorder = 'surround',
    this.disabled = false,
    this.disabledColor = '',
    this.placeholder = '请选择',
    this.format = '',
    this.show = false,
    this.popupMode = 'bottom',
    this.showToolbar = true,
    this.toolbarRightSlot = false,
    this.toolbarRight,
    this.toolbarBottom,
    this.value,
    this.modelValue,
    this.title = '',
    this.mode = 'datetime',
    this.maxDate,
    this.minDate,
    this.minHour = 0,
    this.maxHour = 23,
    this.minMinute = 0,
    this.maxMinute = 59,
    this.minSecond = 0,
    this.maxSecond = 59,
    this.loading = false,
    this.itemHeight = 44,
    this.cancelText = '取消',
    this.confirmText = '确认',
    this.cancelColor = '#909193',
    this.confirmColor = '#3c9cff',
    this.visibleItemCount = 5,
    this.closeOnClickOverlay = false,
    this.defaultIndex = const [],
    this.pageInline = false,
    this.filter,
    this.formatter,
    this.maskStyle,
    this.maskClass = '',
    this.onClose,
    this.onCancel,
    this.onConfirm,
    this.onChange,
    this.onInput,
    this.onUpdateValue,
    this.onUpdateModelValue,
    this.onUpdateShow,
    this.trigger,
    this.customStyle,
  });

  final bool hasInput;
  final Map inputProps;
  final String inputBorder;
  final bool disabled;
  final dynamic disabledColor;
  final String placeholder;
  final String format;
  final bool show;
  final String popupMode;
  final bool showToolbar;
  final bool toolbarRightSlot;
  final Widget? toolbarRight;
  final Widget? toolbarBottom;
  final dynamic value;

  /// Source v-model / modelValue alias.
  final dynamic modelValue;
  final String title;
  final String mode;
  final int? maxDate;
  final int? minDate;
  final int minHour;
  final int maxHour;
  final int minMinute;
  final int maxMinute;
  final int minSecond;
  final int maxSecond;
  final bool loading;
  final dynamic itemHeight;
  final String cancelText;
  final String confirmText;
  final dynamic cancelColor;
  final dynamic confirmColor;
  final dynamic visibleItemCount;
  final bool closeOnClickOverlay;
  final List defaultIndex;
  final bool pageInline;

  /// Source column filter callback.
  final dynamic filter;

  /// Source column formatter callback: `formatter(type, value)`.
  final dynamic formatter;
  final dynamic maskStyle;
  final String maskClass;
  final VoidCallback? onClose;
  final VoidCallback? onCancel;
  final ValueChanged<dynamic>? onConfirm;
  final ValueChanged<dynamic>? onChange;

  /// Source emit alias: input.
  final ValueChanged<dynamic>? onInput;
  final ValueChanged<dynamic>? onUpdateValue;

  /// Source update:modelValue alias.
  final ValueChanged<dynamic>? onUpdateModelValue;

  /// Retained Dart compatibility callback. The source component does not emit
  /// `update:show`, so it is intentionally not invoked.
  final ValueChanged<bool>? onUpdateShow;
  final Widget? trigger;

  final BoxDecoration? customStyle;

  dynamic get effectiveValue => modelValue ?? value;

  /// Source computed `propsChange` — deps that force column re-init.
  dynamic propsChange([dynamic _]) => [
        mode,
        maxDate,
        minDate,
        minHour,
        maxHour,
        minMinute,
        maxMinute,
        minSecond,
        maxSecond,
        filter,
        modelValue,
      ];

  /// Source computed: resolvedMaskStyle.
  dynamic get resolvedMaskStyle => maskStyle ?? '';

  /// Source computed: inputPropsInner.
  dynamic get inputPropsInner => <String, dynamic>{
        'border': inputBorder,
        'placeholder': placeholder,
        'disabled': disabled,
        'disabledColor': disabledColor,
        ...Map<String, dynamic>.from(inputProps),
      };

  @override
  State<UPDatetimePicker> createState() => UPDatetimePickerState();
}

class UPDatetimePickerState extends State<UPDatetimePicker> {
  /// Source host helper.
  Future<void> setTimeout([dynamic cb, int ms = 0]) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
    if (cb is Function) cb();
  }

  /// Source host helper.
  dynamic lastError;
  void error([dynamic payload]) {
    lastError = payload;
  }

  late DateTime current;

  /// Source data.
  List get innerDefaultIndex => List.from(widget.defaultIndex);
  dynamic innerFormatter;
  late String inputValue;
  bool showByClickInput = false;

  late List columns;
  late List indexes;

  @override
  void initState() {
    super.initState();
    current = _sourceControlledValue(widget.effectiveValue);
    _rebuild();
    inputValue = getInputValue();
  }

  @override
  void didUpdateWidget(covariant UPDatetimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.effectiveValue != widget.effectiveValue ||
        oldWidget.mode != widget.mode ||
        oldWidget.minDate != widget.minDate ||
        oldWidget.maxDate != widget.maxDate ||
        oldWidget.minHour != widget.minHour ||
        oldWidget.maxHour != widget.maxHour ||
        oldWidget.minMinute != widget.minMinute ||
        oldWidget.maxMinute != widget.maxMinute ||
        oldWidget.minSecond != widget.minSecond ||
        oldWidget.maxSecond != widget.maxSecond ||
        oldWidget.filter != widget.filter) {
      current = _sourceControlledValue(widget.effectiveValue);
      _rebuild();
      inputValue = getInputValue();
    }
    if (!oldWidget.show && widget.show) {
      current = _sourceControlledValue(widget.effectiveValue);
      _rebuild();
    }
    if (oldWidget.show && !widget.show && widget.hasInput) {
      showByClickInput = false;
    }
  }

  DateTime? _parseValue(dynamic v) {
    if (v == null || '$v'.isEmpty) return null;
    if (v is DateTime) return v;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
    final s = '$v';
    if (!_isDateMode) {
      final time =
          RegExp(r'^(\d{1,2}):(\d{1,2})(?::(\d{1,2}))?$').firstMatch(s);
      if (time != null) {
        final hour = (int.tryParse(time.group(1)!) ?? widget.minHour)
            .clamp(widget.minHour, widget.maxHour);
        final minute = (int.tryParse(time.group(2)!) ?? widget.minMinute)
            .clamp(widget.minMinute, widget.maxMinute);
        final second = (int.tryParse(time.group(3) ?? '${widget.minSecond}') ??
                widget.minSecond)
            .clamp(widget.minSecond, widget.maxSecond);
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, hour, minute, second);
      }
    }
    // support yyyy-MM-dd HH:mm:ss-ish
    final m = RegExp(
      r'^(\d{4})-(\d{1,2})-(\d{1,2})(?:[ T](\d{1,2}):(\d{1,2})(?::(\d{1,2}))?)?$',
    ).firstMatch(s);
    if (m != null) {
      return DateTime(
        int.parse(m.group(1)!),
        int.parse(m.group(2)!),
        int.parse(m.group(3)!),
        int.tryParse(m.group(4) ?? '0') ?? 0,
        int.tryParse(m.group(5) ?? '0') ?? 0,
        int.tryParse(m.group(6) ?? '0') ?? 0,
      );
    }
    if (RegExp(r'^\d+$').hasMatch(s)) {
      return DateTime.fromMillisecondsSinceEpoch(int.parse(s));
    }
    return null;
  }

  DateTime get min {
    if (widget.minDate != null && widget.minDate != 0) {
      return DateTime.fromMillisecondsSinceEpoch(widget.minDate!);
    }
    final y = DateTime.now().year - 10;
    return DateTime(y, 1, 1);
  }

  DateTime get max {
    if (widget.maxDate != null && widget.maxDate != 0) {
      return DateTime.fromMillisecondsSinceEpoch(widget.maxDate!);
    }
    final y = DateTime.now().year + 10;
    return DateTime(y, 1, 1);
  }

  bool get _isDateMode => widget.mode != 'time' && widget.mode != 'timesecond';

  DateTime _sourceControlledValue(dynamic value) {
    final parsed = _parseValue(value);
    if (parsed != null) return _isDateMode ? _clampDate(parsed) : parsed;
    if (_isDateMode) return min;
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      widget.minHour,
      widget.minMinute,
      widget.mode == 'timesecond' ? widget.minSecond : 0,
    );
  }

  DateTime _clampDate(DateTime value) {
    if (value.isBefore(min)) return min;
    if (value.isAfter(max)) return max;
    return value;
  }

  ({int year, int month, int day, int hour, int minute, int second})
      _rangeBoundary({required bool maximum, required DateTime value}) {
    final boundary = maximum ? max : min;
    var month = maximum ? 12 : 1;
    var day = maximum ? DateTime(value.year, value.month + 1, 0).day : 1;
    var hour = maximum ? 23 : 0;
    var minute = maximum ? 59 : 0;
    var second = maximum ? 59 : 0;

    if (value.year == boundary.year) {
      month = boundary.month;
      if (value.month == month) {
        day = boundary.day;
        if (value.day == day) {
          hour = boundary.hour;
          if (value.hour == hour) {
            minute = boundary.minute;
            if (value.minute == minute) second = boundary.second;
          }
        }
      }
    }

    return (
      year: boundary.year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      second: second,
    );
  }

  List _range(int from, int to, {bool pad = false}) {
    return [
      for (var i = from; i <= to; i++) pad ? _pad(i) : '$i',
    ];
  }

  List _filterValues(String type, List values) {
    final filter = widget.filter;
    if (filter is! Function) return values;
    final result = Function.apply(filter, [type, List<dynamic>.from(values)]);
    return result is Iterable ? List<dynamic>.from(result) : const [];
  }

  dynamic _formatValue(String type, dynamic value) {
    final formatter = widget.formatter ?? innerFormatter;
    if (formatter is! Function) return value;
    try {
      return Function.apply(formatter, [type, value]);
    } catch (_) {
      return value;
    }
  }

  List _formatValues(String type, List values) {
    return [for (final value in values) _formatValue(type, value)];
  }

  int _indexForValue(List values, String value) {
    final index = values.indexWhere((item) => '$item' == value);
    return index < 0 ? 0 : index;
  }

  int _indexForFormattedValue(String type, List values, String value) {
    return _indexForValue(values, '${_formatValue(type, value)}');
  }

  void _rebuild() {
    final mode = widget.mode;
    final active = _isDateMode ? _clampDate(current) : current;
    if (_isDateMode) current = active;
    final minBoundary =
        _isDateMode ? _rangeBoundary(maximum: false, value: active) : null;
    final maxBoundary =
        _isDateMode ? _rangeBoundary(maximum: true, value: active) : null;
    final years = _formatValues(
      'year',
      _filterValues(
        'year',
        _range(minBoundary?.year ?? min.year, maxBoundary?.year ?? max.year),
      ),
    );
    final months = _formatValues(
      'month',
      _filterValues(
        'month',
        _range(minBoundary?.month ?? 1, maxBoundary?.month ?? 12, pad: true),
      ),
    );
    final days = _formatValues(
      'day',
      _filterValues(
        'day',
        _range(
          minBoundary?.day ?? 1,
          maxBoundary?.day ?? DateTime(active.year, active.month + 1, 0).day,
          pad: true,
        ),
      ),
    );
    final hours = _formatValues(
      'hour',
      _filterValues(
        'hour',
        _range(
          minBoundary?.hour ?? widget.minHour,
          maxBoundary?.hour ?? widget.maxHour,
          pad: true,
        ),
      ),
    );
    final minutes = _formatValues(
      'minute',
      _filterValues(
        'minute',
        _range(
          minBoundary?.minute ?? widget.minMinute,
          maxBoundary?.minute ?? widget.maxMinute,
          pad: true,
        ),
      ),
    );
    final seconds = _formatValues(
      'second',
      _filterValues(
        'second',
        _range(
          minBoundary?.second ?? widget.minSecond,
          maxBoundary?.second ?? widget.maxSecond,
          pad: true,
        ),
      ),
    );

    List cols;
    List idx;
    switch (mode) {
      case 'time':
        cols = [hours, minutes];
        idx = [
          _indexForFormattedValue('hour', hours, _pad(current.hour)),
          _indexForFormattedValue('minute', minutes, _pad(current.minute)),
        ];
        break;
      case 'timesecond':
        cols = [hours, minutes, seconds];
        idx = [
          _indexForFormattedValue('hour', hours, _pad(current.hour)),
          _indexForFormattedValue('minute', minutes, _pad(current.minute)),
          _indexForFormattedValue('second', seconds, _pad(current.second)),
        ];
        break;
      case 'year-month':
        cols = [years, months];
        idx = [
          _indexForFormattedValue('year', years, '${current.year}'),
          _indexForFormattedValue('month', months, _pad(current.month)),
        ];
        break;
      case 'date':
        cols = [years, months, days];
        idx = [
          _indexForFormattedValue('year', years, '${current.year}'),
          _indexForFormattedValue('month', months, _pad(current.month)),
          _indexForFormattedValue('day', days, _pad(current.day)),
        ];
        break;
      case 'datehour':
        cols = [years, months, days, hours];
        idx = [
          _indexForFormattedValue('year', years, '${current.year}'),
          _indexForFormattedValue('month', months, _pad(current.month)),
          _indexForFormattedValue('day', days, _pad(current.day)),
          _indexForFormattedValue('hour', hours, _pad(current.hour)),
        ];
        break;
      case 'datetimesecond':
        cols = [years, months, days, hours, minutes, seconds];
        idx = [
          _indexForFormattedValue('year', years, '${current.year}'),
          _indexForFormattedValue('month', months, _pad(current.month)),
          _indexForFormattedValue('day', days, _pad(current.day)),
          _indexForFormattedValue('hour', hours, _pad(current.hour)),
          _indexForFormattedValue('minute', minutes, _pad(current.minute)),
          _indexForFormattedValue('second', seconds, _pad(current.second)),
        ];
        break;
      case 'datetime':
      default:
        cols = [years, months, days, hours, minutes];
        idx = [
          _indexForFormattedValue('year', years, '${current.year}'),
          _indexForFormattedValue('month', months, _pad(current.month)),
          _indexForFormattedValue('day', days, _pad(current.day)),
          _indexForFormattedValue('hour', hours, _pad(current.hour)),
          _indexForFormattedValue('minute', minutes, _pad(current.minute)),
        ];
        break;
    }
    columns = cols;
    indexes = idx;
  }

  dynamic _compose(List values) {
    final mode = widget.mode;
    int asInt(dynamic v, int fallback) {
      final matches = RegExp(r'\d+').allMatches('$v').toList();
      if (matches.length != 1) return fallback;
      return int.tryParse(matches.single.group(0)!) ?? fallback;
    }

    if (mode == 'time') {
      final h = asInt(values[0], current.hour);
      final m = asInt(values[1], current.minute);
      return '${_pad(h)}:${_pad(m)}';
    }
    if (mode == 'timesecond') {
      final h = asInt(values[0], current.hour);
      final m = asInt(values[1], current.minute);
      final s = asInt(values[2], current.second);
      return '${_pad(h)}:${_pad(m)}:${_pad(s)}';
    }

    final y = asInt(values[0], current.year);
    final mo = asInt(values[1], current.month);
    var d = mode == 'year-month' ? 1 : asInt(values[2], current.day);
    final maxD = DateTime(y, mo + 1, 0).day;
    if (d > maxD) d = maxD;
    var h = current.hour;
    var mi = current.minute;
    var s = current.second;
    if (mode == 'datehour') {
      h = asInt(values[3], h);
    } else if (mode == 'datetime') {
      h = asInt(values[3], h);
      mi = asInt(values[4], mi);
    } else if (mode == 'datetimesecond') {
      h = asInt(values[3], h);
      mi = asInt(values[4], mi);
      s = asInt(values[5], s);
    }
    final dt = _clampDate(DateTime(y, mo, d, h, mi, s));
    setState(() {
      current = dt;
      _rebuild();
    });
    return dt.millisecondsSinceEpoch;
  }

  /// Public helpers close to source usage.
  dynamic get value => current.millisecondsSinceEpoch;
  DateTime get currentDate => current;

  void setValue(dynamic v) {
    final parsed = _parseValue(v);
    if (parsed == null) return;
    setState(() {
      current = _isDateMode ? _clampDate(parsed) : parsed;
      _rebuild();
    });
    widget.onUpdateValue?.call(current.millisecondsSinceEpoch);
    widget.onUpdateModelValue?.call(current.millisecondsSinceEpoch);
    widget.onChange?.call(current.millisecondsSinceEpoch);
    widget.onInput?.call(current.millisecondsSinceEpoch);
  }

  void open() {
    if (widget.hasInput && !widget.disabled) {
      setState(() => showByClickInput = true);
    }
  }

  void close() {
    if (widget.hasInput && showByClickInput) {
      setState(() => showByClickInput = false);
    }
    if (!widget.closeOnClickOverlay) return;
    widget.onClose?.call();
  }

  void _handlePickerClose() => close();

  /// Source `correctValue`.
  dynamic correctValue([dynamic v]) {
    if (_isDateMode) {
      final parsed = _parseValue(v);
      final next = parsed == null ? min : _clampDate(parsed);
      return next.millisecondsSinceEpoch;
    }

    final parsed = _parseValue(v);
    final now = DateTime.now();
    final value = parsed ??
        DateTime(
          now.year,
          now.month,
          now.day,
          widget.minHour,
          widget.minMinute,
          widget.mode == 'timesecond' ? widget.minSecond : 0,
        );
    final hour = value.hour.clamp(widget.minHour, widget.maxHour);
    final minute = value.minute.clamp(widget.minMinute, widget.maxMinute);
    if (widget.mode == 'timesecond') {
      final second = value.second.clamp(widget.minSecond, widget.maxSecond);
      return '${_pad(hour)}:${_pad(minute)}:${_pad(second)}';
    }
    return '${_pad(hour)}:${_pad(minute)}';
  }

  /// Source `getBoundary`.
  Map getBoundary([String type = 'min', dynamic innerValue]) {
    final maximum = type == 'max';
    final value = _parseValue(innerValue) ?? current;
    final boundary = _rangeBoundary(maximum: maximum, value: value);
    return {
      '${type}Year': boundary.year,
      '${type}Month': boundary.month,
      '${type}Date': boundary.day,
      '${type}Hour': boundary.hour,
      '${type}Minute': boundary.minute,
      '${type}Second': boundary.second,
    };
  }

  /// Source `getRanges` — column ranges for current mode.
  Map getRanges([dynamic _]) {
    _rebuild();
    return {
      'columns': List.from(columns),
      'indexes': List.from(indexes),
      'mode': widget.mode,
    };
  }

  /// Source `generateArray`.
  List generateArray(int start, int end, [bool pad = false]) =>
      _range(start, end, pad: pad);

  /// Source `getOriginColumns`.
  List getOriginColumns([dynamic _]) {
    _rebuild();
    return List.from(columns);
  }

  /// Source `updateColumns` / `updateIndexs` / `updateColumnValue`.
  void updateColumns([dynamic _]) => setState(_rebuild);
  void updateIndexs([dynamic _]) => setState(_rebuild);
  void updateColumnValue([dynamic _]) => setState(_rebuild);

  /// Source `safeColumnValue`.
  dynamic safeColumnValue(dynamic value, [dynamic fallback]) {
    if (value == null || '$value'.isEmpty) return fallback;
    return value;
  }

  /// Source `onShowByClickInput`.
  void onShowByClickInput([dynamic _]) {
    if (widget.disabled) return;
    setState(() => showByClickInput = !showByClickInput);
  }

  /// Source `init`.
  void init() {
    current = _sourceControlledValue(widget.effectiveValue);
    setState(() {
      _rebuild();
      inputValue = getInputValue();
    });
  }

  /// Source `cancel` / `confirm`.
  void cancel() {
    if (widget.hasInput && showByClickInput) {
      setState(() => showByClickInput = false);
    }
    widget.onCancel?.call();
  }

  void confirm() {
    final v = current.millisecondsSinceEpoch;
    if (widget.hasInput) {
      setState(() {
        showByClickInput = false;
        inputValue = getInputValue();
      });
    }
    widget.onConfirm?.call({
      'value': v,
      'mode': widget.mode,
    });
    widget.onUpdateValue?.call(v);
    widget.onUpdateModelValue?.call(v);
    widget.onInput?.call(v);
  }

  /// Source `getInputValue`.
  String getInputValue() {
    final dt = current;
    if (widget.mode != 'time' &&
        widget.mode != 'timesecond' &&
        widget.format.isNotEmpty) {
      return _formatInputDate(dt, widget.format);
    }
    switch (widget.mode) {
      case 'time':
        return '${_pad(dt.hour)}:${_pad(dt.minute)}';
      case 'timesecond':
        return '${_pad(dt.hour)}:${_pad(dt.minute)}:${_pad(dt.second)}';
      case 'year-month':
        return '${dt.year}-${_pad(dt.month)}';
      case 'date':
        return '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)}';
      case 'datehour':
        return '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} ${_pad(dt.hour)}';
      default:
        return '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} ${_pad(dt.hour)}:${_pad(dt.minute)}';
    }
  }

  String _formatInputDate(DateTime value, String format) {
    final tokens = <String, String>{
      'YYYY': value.year.toString().padLeft(4, '0'),
      'YY': (value.year % 100).toString().padLeft(2, '0'),
      'MM': _pad(value.month),
      'M': '${value.month}',
      'DD': _pad(value.day),
      'D': '${value.day}',
      'HH': _pad(value.hour),
      'H': '${value.hour}',
      'mm': _pad(value.minute),
      'm': '${value.minute}',
      'ss': _pad(value.second),
      's': '${value.second}',
    };
    return format.replaceAllMapped(
      RegExp(r'YYYY|YY|MM|DD|HH|mm|ss|M|D|H|m|s'),
      (match) => tokens[match.group(0)]!,
    );
  }

  /// Source formatter/intercept helpers (Batch J + BH).
  dynamic formatter([dynamic value, dynamic type]) {
    final fn = innerFormatter;
    if (fn is Function) {
      try {
        return Function.apply(fn, [value, type]);
      } catch (_) {
        try {
          return Function.apply(fn, [value]);
        } catch (_) {
          return value;
        }
      }
    }
    return value;
  }

  dynamic intercept([dynamic value]) => value;

  /// Source `times` residual helper (current time parts).
  List get times => [
        current.hour,
        current.minute,
        current.second,
      ];

  void setFormatter(dynamic formatter) {
    innerFormatter = formatter;
  }

  /// Source `change`.
  void change(dynamic v) => setValue(v);

  @override
  Widget build(BuildContext context) {
    final showPicker = widget.pageInline ||
        widget.show ||
        (widget.hasInput && showByClickInput);
    final picker = UPPicker(
      show: showPicker,
      popupMode: widget.popupMode,
      showToolbar: widget.showToolbar,
      title: widget.title,
      columns: columns,
      loading: widget.loading,
      itemHeight: widget.itemHeight,
      cancelText: widget.cancelText,
      confirmText: widget.confirmText,
      cancelColor: widget.cancelColor,
      confirmColor: widget.confirmColor,
      visibleItemCount: widget.visibleItemCount,
      closeOnClickOverlay: widget.closeOnClickOverlay,
      defaultIndex: indexes,
      toolbarRightSlot: widget.toolbarRightSlot,
      toolbarRight: widget.toolbarRight,
      toolbarBottom: widget.toolbarBottom,
      maskClass: widget.maskClass,
      // An omitted prop keeps UPPicker's dark-theme default active. An
      // explicit empty style remains the source-compatible resolved value.
      maskStyle: widget.maskStyle,
      pageInline: widget.pageInline,
      onClose: _handlePickerClose,
      onCancel: cancel,
      onChange: (values, idxs, col) {
        final composed = _compose(values);
        final selected = _parseValue(composed);
        if (selected != null) {
          setState(() {
            current = _isDateMode ? _clampDate(selected) : selected;
            _rebuild();
          });
        }
        widget.onChange?.call({
          'value': composed,
          'mode': widget.mode,
        });
      },
      onConfirm: (values, idxs) {
        final composed = _compose(values);
        if (widget.hasInput) {
          setState(() {
            showByClickInput = false;
            inputValue = getInputValue();
          });
        }
        widget.onConfirm?.call({
          'value': composed,
          'mode': widget.mode,
        });
        widget.onUpdateValue?.call(composed);
        widget.onUpdateModelValue?.call(composed);
        widget.onInput?.call(composed);
      },
    );

    if (!widget.hasInput) return picker;

    final inputProps = widget.inputPropsInner;
    final inputDisabled = inputProps['disabled'] is bool
        ? inputProps['disabled'] as bool
        : widget.disabled;
    final trigger = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.disabled ? null : onShowByClickInput,
      child: widget.trigger ??
          UPInput(
            value: inputValue,
            readonly: showByClickInput,
            border: '${inputProps['border'] ?? widget.inputBorder}',
            placeholder: '${inputProps['placeholder'] ?? widget.placeholder}',
            disabled: inputDisabled,
            disabledColor:
                '${inputProps['disabledColor'] ?? widget.disabledColor}',
          ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [trigger, picker],
    );
  }
}
