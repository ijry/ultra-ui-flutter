import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_button.dart';
import 'up_popup.dart';

/// Simplified 1:1 API shell of u-calendar (single/multiple/range).
class UPCalendar extends StatefulWidget {
  const UPCalendar({
    super.key,
    this.title = '日期选择',
    this.showTitle = true,
    this.showSubtitle = true,
    this.mode = 'single',
    this.startText = '开始',
    this.endText = '结束',
    this.customList = const [],
    this.color = '#3c9cff',
    this.minDate = 0,
    this.maxDate = 0,
    this.defaultDate,
    this.maxCount = 999,
    this.maxRange,
    this.rangePrompt = '',
    this.showRangePrompt = true,
    this.rangeResultMode = 'all',
    this.enableTime = false,
    this.timePrecision = 'minute',
    this.defaultTime = '00:00',
    this.rowHeight = 56,
    this.showLunar = false,
    this.showMark = true,
    this.confirmText = '确认',
    this.confirmDisabledText = '确认',
    this.show = false,
    this.overlay = true,
    this.duration = 300,
    this.overlayOpacity = 0.5,
    this.overlayStyle,
    this.closeOnClickOverlay = false,
    this.readonly = false,
    this.showConfirm = true,
    this.allowSameDay = false,
    this.round = 0,
    this.zIndex = 10075,
    this.safeAreaInsetBottom = true,
    this.safeAreaInsetTop = false,
    this.bgColor = '',
    this.monthNum = 3,
    this.monthSwitch = false,
    this.showSwitch = false,
    this.monthFormat = '',
    this.forbidDays = const [],
    this.forbidDaysToast = '该日期不可选',
    this.showToday = true,
    this.weekText = const ['一', '二', '三', '四', '五', '六', '日'],
    this.pageInline = false,
    this.scrollIntoView = '',
    this.onConfirm,
    this.onClose,
    this.onClosed,
    this.onUpdateShow,
    this.onChange,
    this.onMonthSelected,
    this.onPrev,
    this.onNext,
    this.onPrevYear,
    this.onNextYear,
    this.onToday,
    this.todayColor = '',
    this.prevDisabled = false,
    this.nextDisabled = false,
    this.prevYearDisabled = false,
    this.nextYearDisabled = false,
    this.customStyle,
  });

  final String title;
  final bool showTitle;
  final bool showSubtitle;
  final String mode; // single | multiple | range
  final String startText;
  final String endText;
  final List customList;
  final dynamic color;
  final dynamic minDate;
  final dynamic maxDate;
  final dynamic defaultDate;
  final dynamic maxCount;

  /// Source max range days for range mode.
  final dynamic maxRange;
  final String rangePrompt;
  final bool showRangePrompt;

  /// Source range confirm payload mode: all | start | end.
  final String rangeResultMode;

  /// Source enable time selection (hour/minute/second).
  final bool enableTime;

  /// Source time precision: hour | minute | second.
  final String timePrecision;

  /// Source default time string HH / HH:mm / HH:mm:ss.
  final dynamic defaultTime;
  final dynamic rowHeight;
  final bool showLunar;
  final bool showMark;
  final String confirmText;
  final String confirmDisabledText;
  final bool show;
  final bool overlay;
  final dynamic duration;
  final dynamic overlayOpacity;
  final dynamic overlayStyle;
  final bool closeOnClickOverlay;
  final bool readonly;
  final bool showConfirm;
  final bool allowSameDay;
  final dynamic round;
  final dynamic zIndex;
  final bool safeAreaInsetBottom;
  final bool safeAreaInsetTop;
  final dynamic bgColor;
  final int monthNum;
  final bool monthSwitch;

  /// Source header month switch visibility (alias of monthSwitch when true).
  final bool showSwitch;
  final String monthFormat;
  final List forbidDays;
  final String forbidDaysToast;
  final bool showToday;
  final List weekText;
  final bool pageInline;

  /// Source retained scroll target id/date.
  final dynamic scrollIntoView;
  final ValueChanged<List<DateTime>>? onConfirm;
  final VoidCallback? onClose;

  /// Source emit `closed` — the nested popup finished its leave
  /// animation, unlike `close` which fires at dismissal.
  final VoidCallback? onClosed;

  /// Source update:show alias.
  final ValueChanged<bool>? onUpdateShow;
  final ValueChanged<List<DateTime>>? onChange;

  /// Source emit alias: monthSelected.
  final void Function(List dates, [String scene])? onMonthSelected;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback? onPrevYear;
  final VoidCallback? onNextYear;
  final VoidCallback? onToday;

  /// Source today highlight color; falls back to color.
  final dynamic todayColor;

  /// Source retained month/year nav disable flags.
  final bool prevDisabled;
  final bool nextDisabled;
  final bool prevYearDisabled;
  final bool nextYearDisabled;

  final BoxDecoration? customStyle;
  @override
  State<UPCalendar> createState() => UPCalendarState();
}

class UPCalendarState extends State<UPCalendar> {
  late DateTime baseMonth;

  /// Source data.
  dynamic innerFormatter;
  double listHeight = 0;
  int monthIndex = 0;
  dynamic rangeEndTime;
  dynamic rangeStartTime;
  dynamic scrollIntoViewScroll;
  double scrollTop = 0;
  dynamic singleTime;
  bool timePickerShow = false;
  dynamic timePickerTarget;
  dynamic timePickerValue;
  dynamic lastToast;
  double scrollOffset = 0;
  dynamic monthTop;

  /// Source-compatible switch visibility.
  bool get effectiveShowSwitch => widget.showSwitch || widget.monthSwitch;
  int get effectiveMaxRange {
    final n = int.tryParse('${widget.maxRange ?? ''}');
    if (n == null || n <= 0) return 1 << 30;
    return n;
  }

  final selected = <DateTime>[];
  List<DateTime> get selectedDates => List<DateTime>.from(selected);

  /// Source rangeResultMode aware confirm payload.
  List<DateTime> get confirmDates {
    if (widget.mode != 'range' || selected.isEmpty) {
      return List<DateTime>.from(selected);
    }
    if (widget.rangeResultMode == 'start') {
      return [selected.first];
    }
    if (widget.rangeResultMode == 'end') {
      return [selected.length > 1 ? selected.last : selected.first];
    }
    return List<DateTime>.from(selected);
  }

  /// Current first month shown.
  DateTime get currentMonth => baseMonth;

  /// Source date range helpers (Batch K).
  DateTime? get innerMinDate => _parseDate(widget.minDate);
  DateTime? get innerMaxDate => _parseDate(widget.maxDate);
  DateTime get todayDate => DateTime.now();
  dynamic get todayColorValue {
    final c = widget.todayColor;
    if (c != null && '$c'.isNotEmpty) return c;
    return widget.color;
  }

  bool get switchPrevDisabled {
    final min = innerMinDate;
    if (min == null) return false;
    final minMonth = DateTime(min.year, min.month, 1);
    return !baseMonth.isAfter(minMonth);
  }

  bool get switchNextDisabled {
    final max = innerMaxDate;
    if (max == null) return false;
    final maxMonth = DateTime(max.year, max.month, 1);
    return !baseMonth.isBefore(maxMonth);
  }

  bool get buttonDisabled => !_confirmEnabled;

  /// Source style / utility residual helpers (Batch L).
  Map dayStyle([dynamic date]) {
    final d = date is DateTime ? _dateOnly(date) : _parseDate(date);
    if (d == null) return const {};
    return {
      'date': '${d.year}-${_pad(d.month)}-${_pad(d.day)}',
      'selected': isSelectedDate(d),
      'disabled': isForbid(d),
      'today': dateSame(d, DateTime.now()),
    };
  }

  Map daySelectStyle([dynamic date]) {
    final base = Map<String, dynamic>.from(dayStyle(date));
    base['active'] = base['selected'] == true;
    return base;
  }

  Map textStyle([dynamic date]) {
    final d = date is DateTime ? _dateOnly(date) : _parseDate(date);
    final selected = d != null && isSelectedDate(d);
    final disabled = d != null && isForbid(d);
    return {
      'color': selected ? '#ffffff' : (disabled ? '#c0c4cc' : '#303133'),
      'fontSize': 15,
      'fontWeight': selected ? 'bold' : 'normal',
    };
  }

  String getBottomInfo([dynamic date]) {
    final d = date is DateTime ? _dateOnly(date) : _parseDate(date);
    if (d == null) return '';
    if (dateSame(d, DateTime.now())) return '今天';
    if (isSelectedDate(d)) return '已选';
    return '';
  }

  double getWrapperWidth([dynamic _]) => 0;

  /// Source `handler` alias for day selection.
  void handler([dynamic date]) {
    final d = date is DateTime ? _dateOnly(date) : _parseDate(date);
    if (d == null) return;
    clickHandler(d);
  }

  dynamic resolve([dynamic value]) => value;
  String resolvedTodayColor([dynamic _]) => '#3c9cff';
  Future<void> sleep([int ms = 0]) async {
    if (ms <= 0) return;
    await Future<void>.delayed(Duration(milliseconds: ms));
  }

  /// Source-compatible month navigation helpers (header methods).
  void prev() {
    widget.onPrev?.call();
    final min = _parseDate(widget.minDate);
    final next = DateTime(baseMonth.year, baseMonth.month - 1, 1);
    if (min != null && next.isBefore(DateTime(min.year, min.month, 1))) {
      return;
    }
    setState(() => baseMonth = next);
  }

  void next() {
    widget.onNext?.call();
    final max = _parseDate(widget.maxDate);
    final next = DateTime(baseMonth.year, baseMonth.month + 1, 1);
    if (max != null && next.isAfter(DateTime(max.year, max.month, 1))) {
      return;
    }
    setState(() => baseMonth = next);
  }

  void prevYear() {
    widget.onPrevYear?.call();
    final min = _parseDate(widget.minDate);
    final next = DateTime(baseMonth.year - 1, baseMonth.month, 1);
    if (min != null && next.isBefore(DateTime(min.year, min.month, 1))) {
      return;
    }
    setState(() => baseMonth = next);
  }

  void nextYear() {
    widget.onNextYear?.call();
    final max = _parseDate(widget.maxDate);
    final next = DateTime(baseMonth.year + 1, baseMonth.month, 1);
    if (max != null && next.isAfter(DateTime(max.year, max.month, 1))) {
      return;
    }
    setState(() => baseMonth = next);
  }

  /// Source `subtitle` / month labels.
  String subtitle([dynamic _]) {
    return '${baseMonth.year}年${baseMonth.month.toString().padLeft(2, '0')}月';
  }

  /// Source `currentMonths`.
  List currentMonths([dynamic _]) {
    final n = int.tryParse('${widget.monthNum}') ?? 1;
    return [
      for (var i = 0; i < n; i++)
        DateTime(baseMonth.year, baseMonth.month + i, 1),
    ];
  }

  /// Source selected label helpers.
  String singleDateLabel([dynamic _]) {
    if (selected.isEmpty) return '';
    final d = selected.first;
    return '${d.year}-${_pad(d.month)}-${_pad(d.day)}';
  }

  String rangeStartDateLabel([dynamic _]) {
    if (selected.isEmpty) return '';
    final d = selected.first;
    return '${d.year}-${_pad(d.month)}-${_pad(d.day)}';
  }

  String rangeEndDateLabel([dynamic _]) {
    if (selected.length < 2) return '';
    final d = selected[1];
    return '${d.year}-${_pad(d.month)}-${_pad(d.day)}';
  }

  /// Source disabled flags.
  bool todayDisabled([dynamic _]) => _disabled(_dateOnly(DateTime.now()));
  bool switchPrevYearDisabled([dynamic _]) {
    final min = _parseDate(widget.minDate);
    if (min == null) return false;
    final next = DateTime(baseMonth.year - 1, baseMonth.month, 1);
    return next.isBefore(DateTime(min.year, min.month, 1));
  }

  bool switchNextYearDisabled([dynamic _]) {
    final max = _parseDate(widget.maxDate);
    if (max == null) return false;
    final next = DateTime(baseMonth.year + 1, baseMonth.month, 1);
    return next.isAfter(DateTime(max.year, max.month, 1));
  }

  /// Source `selectedChange`.
  void selectedChange([List? dates]) {
    final out = dates == null
        ? List<DateTime>.from(selected)
        : [
            for (final d in dates)
              if (_parseDate(d) != null) _parseDate(d)!,
          ];
    if (dates != null) {
      setState(() {
        selected
          ..clear()
          ..addAll(out);
      });
    }
    widget.onChange?.call(List<DateTime>.from(selected));
  }

  /// Source month / date helpers (Batch I).
  void prevMonth() => prev();
  void nextMonth() => next();

  List getMonths([dynamic _]) => currentMonths();

  String monthTitle([dynamic month]) {
    final d = month is DateTime ? month : (_parseDate(month) ?? baseMonth);
    if (widget.monthFormat.isNotEmpty) {
      return widget.monthFormat
          .replaceAll('YYYY', '${d.year}')
          .replaceAll('MM', _pad(d.month))
          .replaceAll('M', '${d.month}');
    }
    return '${d.year}年${d.month.toString().padLeft(2, '0')}月';
  }

  bool dateSame(dynamic a, dynamic b) {
    final da = a is DateTime ? _dateOnly(a) : _parseDate(a);
    final db = b is DateTime ? _dateOnly(b) : _parseDate(b);
    if (da == null || db == null) return false;
    return _sameDay(da, db);
  }

  bool isSelectedDate([dynamic date]) {
    final d = date is DateTime ? _dateOnly(date) : _parseDate(date);
    if (d == null) return false;
    return _isSelected(d);
  }

  bool isForbid([dynamic date]) {
    final d = date is DateTime ? _dateOnly(date) : _parseDate(date);
    if (d == null) return true;
    return _disabled(d);
  }

  int getDefaultMonthIndex([dynamic _]) {
    final months = currentMonths();
    final target = selected.isNotEmpty ? selected.first : baseMonth;
    for (var i = 0; i < months.length; i++) {
      final m = months[i];
      if (m is DateTime && m.year == target.year && m.month == target.month) {
        return i;
      }
    }
    return 0;
  }

  dynamic getDefaultTimeValue([dynamic _]) => defaultTime();

  List get hourOptions => [for (var i = 0; i < 24; i++) i];
  List get minuteOptions => [for (var i = 0; i < 60; i++) i];
  List get secondOptions => [for (var i = 0; i < 60; i++) i];
  List initTimeOptions([dynamic _]) => const [
        {'label': 'hour', 'range': 24},
        {'label': 'minute', 'range': 60},
        {'label': 'second', 'range': 60},
      ];

  String appendTime(dynamic date, [dynamic time]) {
    final d = date is DateTime ? _dateOnly(date) : _parseDate(date);
    if (d == null) return '';
    final t = time == null || '$time'.isEmpty ? defaultTime() : time;
    return '${d.year}-${_pad(d.month)}-${_pad(d.day)} $t';
  }

  void selectDate([dynamic date]) {
    final d = date is DateTime ? _dateOnly(date) : _parseDate(date);
    if (d == null || _disabled(d)) return;
    clickHandler(d);
  }

  void selectToday() => jumpToToday();

  void scrollIntoDefaultMonth([dynamic _]) {
    final target = selected.isNotEmpty ? selected.first : DateTime.now();
    setState(() {
      baseMonth = DateTime(target.year, target.month, 1);
    });
  }

  /// Source time / month residual helpers (Batch J).
  void setDefaultDate([dynamic date]) {
    if (date == null) {
      clearSelected();
      return;
    }
    if (date is List) {
      setSelected(date);
    } else {
      setSelected([date]);
    }
  }

  void setMonth([dynamic month]) {
    final d = month is DateTime ? month : _parseDate(month);
    if (d == null) return;
    setState(() => baseMonth = DateTime(d.year, d.month, 1));
  }

  String padTime([dynamic value = 0, int len = 2]) {
    var s = '$value';
    while (s.length < len) {
      s = '0$s';
    }
    return s;
  }

  List initTimeValues([dynamic _]) {
    final t = '${defaultTime()}';
    final parts = t.split(RegExp(r'[:\s]'));
    return [
      int.tryParse(parts.isNotEmpty ? parts[0] : '0') ?? 0,
      int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
      int.tryParse(parts.length > 2 ? parts[2] : '0') ?? 0,
    ];
  }

  List parseTimeValue([dynamic value]) {
    final raw = value == null ? defaultTime() : value;
    if (raw is List) return List.from(raw);
    final s = '$raw';
    final parts = s.split(RegExp(r'[:\s]'));
    return [
      int.tryParse(parts.isNotEmpty ? parts[0] : '0') ?? 0,
      int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
      int.tryParse(parts.length > 2 ? parts[2] : '0') ?? 0,
    ];
  }

  List timeToPickerValue([dynamic value]) => parseTimeValue(value);
  dynamic pickerValueToTime([List? values]) {
    final v = values ??
        (timePickerValue is List
            ? List.from(timePickerValue as List)
            : initTimeValues());
    final h = padTime(v.isNotEmpty ? v[0] : 0);
    final m = padTime(v.length > 1 ? v[1] : 0);
    final s = padTime(v.length > 2 ? v[2] : 0);
    final p = timePrecision();
    if (p == 'hour') return h;
    if (p == 'second') return '$h:$m:$s';
    return '$h:$m';
  }

  String formatTimeText([dynamic value]) {
    final v = parseTimeValue(value);
    return '${pickerValueToTime(v)}';
  }

  int timeToSecond([dynamic value]) {
    final v = parseTimeValue(value);
    final h = int.tryParse('${v.isNotEmpty ? v[0] : 0}') ?? 0;
    final m = int.tryParse('${v.length > 1 ? v[1] : 0}') ?? 0;
    final s = int.tryParse('${v.length > 2 ? v[2] : 0}') ?? 0;
    return h * 3600 + m * 60 + s;
  }

  void toast([dynamic message]) {
    lastToast = message;
  }

  void updateMonthTop([dynamic _]) => onUpdateMonthTop(_);
  bool validateSameDayRangeTime([dynamic _]) {
    if (!widget.enableTime ||
        widget.mode != 'range' ||
        widget.rangeResultMode != 'boundary') {
      return true;
    }
    if (selected.length < 2) return true;
    final a = _dateOnly(selected.first);
    final b = _dateOnly(selected.last);
    if (a != b) return true;
    final startSeconds = timeToSecond(rangeStartTime ?? defaultTime());
    final endSeconds = timeToSecond(rangeEndTime ?? defaultTime());
    return endSeconds >= startSeconds;
  }

  void onScroll([dynamic offset]) {
    if (offset is num) {
      scrollOffset = offset.toDouble();
    } else if (offset is Map) {
      final v = offset['scrollTop'] ??
          offset['offset'] ??
          offset['y'] ??
          offset['top'];
      scrollOffset =
          (v is num) ? v.toDouble() : double.tryParse('$v') ?? scrollOffset;
    } else if (offset != null) {
      scrollOffset = double.tryParse('$offset') ?? scrollOffset;
    }
  }

  void onUpdateMonthTop([dynamic value]) {
    monthTop = value;
  }

  dynamic getMonthRect([dynamic _]) => const {
        'width': 0.0,
        'height': 0.0,
        'top': 0.0,
        'left': 0.0,
      };
  Future<Map> getMonthRectByPromise([dynamic _]) async =>
      Map<String, dynamic>.from(getMonthRect());

  /// Source time panel helpers.
  bool showTimePanel([dynamic _]) {
    if (!widget.enableTime) return false;
    if (widget.mode == 'single') return true;
    if (widget.mode == 'range' && widget.rangeResultMode == 'boundary') {
      return true;
    }
    return false;
  }

  String todayText([dynamic _]) => '今天';
  String timePrecision([dynamic _]) {
    final p = '${widget.timePrecision}'.trim();
    if (p == 'hour' || p == 'second' || p == 'minute') return p;
    return 'minute';
  }

  String defaultTime([dynamic _]) {
    final raw = widget.defaultTime;
    if (raw == null || '$raw'.trim().isEmpty) {
      final p = timePrecision();
      if (p == 'hour') return '00';
      if (p == 'second') return '00:00:00';
      return '00:00';
    }
    return formatTimeText(raw);
  }

  /// Source header `today` / jumpToToday.
  void today() {
    widget.onToday?.call();
    jumpToToday();
  }

  void jumpToToday() {
    final now = _dateOnly(DateTime.now());
    if (_disabled(now)) return;
    setState(() {
      baseMonth = DateTime(now.year, now.month, 1);
      if (widget.mode == 'single') {
        selected
          ..clear()
          ..add(now);
      }
    });
    if (widget.mode == 'single') {
      widget.onChange?.call(List<DateTime>.from(selected));
    }
  }

  /// Programmatic selection helpers.
  void setSelected(List dates) {
    setState(() {
      selected
        ..clear()
        ..addAll([
          for (final d in dates)
            if (_parseDate(d) != null) _parseDate(d)!
        ]);
    });
    widget.onChange?.call(List<DateTime>.from(selected));
  }

  void clearSelected() {
    setState(selected.clear);
    widget.onChange?.call(const <DateTime>[]);
  }

  void confirm() {
    if (!_confirmEnabled) return;
    if (!validateSameDayRangeTime()) return;
    final out = getConfirmValue();
    final payload =
        widget.mode == 'range' ? applySelectedTimes(confirmDates) : out;
    widget.onConfirm?.call(payload);
  }

  /// Source `close`.
  void close() {
    widget.onClose?.call();
    widget.onUpdateShow?.call(false);
  }

  /// Source `init` (re-apply default selection / month).
  void init() {
    final now = DateTime.now();
    setState(() {
      baseMonth = DateTime(now.year, now.month, 1);
      selected.clear();
      _initDefault();
      _syncBaseMonthFromSelection();
    });
  }

  /// Source `setFormatter` (host may store formatter).
  void Function(dynamic)? _innerFormatter;
  void setFormatter(void Function(dynamic)? formatter) {
    _innerFormatter = formatter;
  }

  /// Source `getConfirmValue`.
  List<DateTime> getConfirmValue([List? source]) {
    final out = <DateTime>[
      for (final d in (source ?? selected))
        if (d is DateTime)
          _dateOnly(d)
        else if (_parseDate(d) != null)
          _parseDate(d)!
    ];
    if (widget.mode == 'range' && out.length == 1 && widget.allowSameDay) {
      out.add(out.first);
    }
    if (widget.mode == 'range' && out.length > 2) {
      return applySelectedTimes([out.first, out.last]);
    }
    return applySelectedTimes(out);
  }

  /// Source `monthSelected`.
  void monthSelected(List dates, [String scene = 'init']) {
    widget.onMonthSelected?.call(dates, scene);
    setState(() {
      selected
        ..clear()
        ..addAll([
          for (final d in dates)
            if (_parseDate(d) != null) _parseDate(d)!
        ]);
    });
    if (!widget.showConfirm && scene == 'tap') {
      confirm();
    } else {
      widget.onChange?.call(List<DateTime>.from(selected));
    }
  }

  /// Source day click alias.
  void clickHandler(DateTime day) => _tapDay(day);

  /// Source time-picker helpers.
  void openTimePicker([String target = 'single']) {
    final t = (target.isEmpty ? 'single' : target);
    dynamic currentValue = singleTime ?? defaultTime();
    if (t == 'start') currentValue = rangeStartTime ?? defaultTime();
    if (t == 'end') currentValue = rangeEndTime ?? defaultTime();
    setState(() {
      timePickerTarget = t;
      timePickerValue = timeToPickerValue(currentValue);
      timePickerShow = true;
    });
  }

  void closeTimePicker() {
    if (!timePickerShow) return;
    setState(() => timePickerShow = false);
  }

  void confirmTimePicker() {
    final value = pickerValueToTime(
      timePickerValue is List ? List.from(timePickerValue as List) : null,
    );
    setState(() {
      final t = '${timePickerTarget ?? 'single'}';
      if (t == 'start') {
        rangeStartTime = value;
      } else if (t == 'end') {
        rangeEndTime = value;
      } else {
        singleTime = value;
      }
      timePickerShow = false;
    });
  }

  void onTimePickerChange([dynamic e]) {
    dynamic next = e;
    if (e is Map) {
      next = e['detail'] is Map ? e['detail']['value'] : (e['value'] ?? e);
    }
    if (next is! List) return;
    setState(() => timePickerValue = List.from(next));
  }

  void ensureDefaultTimes([dynamic _]) {
    final def = defaultTime();
    singleTime ??= def;
    rangeStartTime ??= def;
    rangeEndTime ??= def;
    if (singleTime == null || '$singleTime'.isEmpty) singleTime = def;
    if (rangeStartTime == null || '$rangeStartTime'.isEmpty)
      rangeStartTime = def;
    if (rangeEndTime == null || '$rangeEndTime'.isEmpty) rangeEndTime = def;
  }

  DateTime _applyTime(DateTime date, dynamic timeText) {
    final parts = parseTimeValue(timeText);
    final h = int.tryParse('${parts.isNotEmpty ? parts[0] : 0}') ?? 0;
    final m = int.tryParse('${parts.length > 1 ? parts[1] : 0}') ?? 0;
    final s = int.tryParse('${parts.length > 2 ? parts[2] : 0}') ?? 0;
    return DateTime(date.year, date.month, date.day, h, m, s);
  }

  List<DateTime> applySelectedTimes([List? source]) {
    final dates = <DateTime>[
      for (final d in (source ?? selected))
        if (d is DateTime)
          _dateOnly(d)
        else if (_parseDate(d) != null)
          _parseDate(d)!
    ];
    if (!widget.enableTime || !showTimePanel()) return dates;
    ensureDefaultTimes();
    if (widget.mode == 'single' && dates.isNotEmpty) {
      return [_applyTime(dates.first, singleTime)];
    }
    if (widget.mode == 'range' &&
        widget.rangeResultMode == 'boundary' &&
        dates.length >= 2) {
      return [
        _applyTime(dates.first, rangeStartTime),
        _applyTime(dates.last, rangeEndTime),
      ];
    }
    return dates;
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    baseMonth = DateTime(now.year, now.month, 1);
    ensureDefaultTimes();
    _initDefault();
    _syncBaseMonthFromSelection();
  }

  @override
  void didUpdateWidget(covariant UPCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.defaultDate != widget.defaultDate ||
        oldWidget.minDate != widget.minDate ||
        oldWidget.maxDate != widget.maxDate) {
      selected.clear();
      _initDefault();
      _syncBaseMonthFromSelection();
    }
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime? _parseDate(dynamic value) {
    if (value == null || value == 0 || value == '' || value == false) {
      return null;
    }
    if (value is DateTime) return _dateOnly(value);
    if (value is int) {
      // unix ms or seconds
      if (value > 100000000000) {
        return _dateOnly(DateTime.fromMillisecondsSinceEpoch(value));
      }
      if (value > 1000000000) {
        return _dateOnly(DateTime.fromMillisecondsSinceEpoch(value * 1000));
      }
      return null;
    }
    if (value is String && value.isNotEmpty) {
      final p = DateTime.tryParse(value.replaceAll('/', '-'));
      if (p != null) return _dateOnly(p);
    }
    return null;
  }

  void _initDefault() {
    final d = widget.defaultDate;
    if (d == null) return;
    if (d is DateTime) {
      selected.add(_dateOnly(d));
    } else if (d is List) {
      for (final item in d) {
        final p = _parseDate(item);
        if (p != null) selected.add(p);
      }
    } else {
      final p = _parseDate(d);
      if (p != null) selected.add(p);
    }
  }

  /// Prefer selected/default month, then clamp into [minDate, maxDate].
  void _syncBaseMonthFromSelection() {
    if (selected.isNotEmpty) {
      final d = selected.first;
      baseMonth = DateTime(d.year, d.month, 1);
    }
    final min = _parseDate(widget.minDate);
    final max = _parseDate(widget.maxDate);
    if (min != null) {
      final minMonth = DateTime(min.year, min.month, 1);
      if (baseMonth.isBefore(minMonth)) {
        baseMonth = minMonth;
      }
    }
    if (max != null) {
      final maxMonth = DateTime(max.year, max.month, 1);
      if (baseMonth.isAfter(maxMonth)) {
        baseMonth = maxMonth;
      }
    }
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _disabled(DateTime day) {
    final min = _parseDate(widget.minDate);
    final max = _parseDate(widget.maxDate);
    if (min != null && day.isBefore(min)) return true;
    if (max != null && day.isAfter(max)) return true;
    if (_isForbidden(day)) return true;
    return false;
  }

  String? _customInfo(DateTime day) {
    for (final item in widget.customList) {
      if (item is! Map) continue;
      final date = _parseDate(item['date'] ?? item['day'] ?? item['value']);
      if (date != null && _sameDay(date, day)) {
        return '${item['info'] ?? item['text'] ?? item['bottomInfo'] ?? ''}';
      }
    }
    return null;
  }

  // Minimal lunar labels for demo parity (not full lunar calendar).
  String _lunarHint(DateTime day) {
    const names = [
      '初一',
      '初二',
      '初三',
      '初四',
      '初五',
      '初六',
      '初七',
      '初八',
      '初九',
      '初十',
      '十一',
      '十二',
      '十三',
      '十四',
      '十五',
      '十六',
      '十七',
      '十八',
      '十九',
      '二十',
      '廿一',
      '廿二',
      '廿三',
      '廿四',
      '廿五',
      '廿六',
      '廿七',
      '廿八',
      '廿九',
      '三十',
    ];
    return names[(day.day - 1) % names.length];
  }

  bool _isSelected(DateTime day) {
    if (widget.mode == 'range' && selected.length == 2) {
      final a = selected[0];
      final b = selected[1];
      final start = a.isBefore(b) ? a : b;
      final end = a.isBefore(b) ? b : a;
      return !day.isBefore(start) && !day.isAfter(end);
    }
    return selected.any((e) => _sameDay(e, day));
  }

  bool _isStartOrEnd(DateTime day) {
    return selected.any((e) => _sameDay(e, day));
  }

  bool _isForbidden(DateTime day) {
    for (final raw in widget.forbidDays) {
      final fd = raw is DateTime ? _dateOnly(raw) : _parseDate(raw);
      if (fd != null && _sameDay(fd, day)) return true;
      final s = '$raw';
      final d = _dateOnly(day);
      if (s == '${d.year}-${_pad(d.month)}-${_pad(d.day)}') return true;
    }
    return false;
  }

  bool isForbiddenDay([dynamic day]) {
    final d = day is DateTime ? _dateOnly(day) : _parseDate(day);
    if (d == null) return false;
    return _isForbidden(d);
  }

  void _tapDay(DateTime day) {
    if (widget.readonly || _disabled(day)) return;
    setState(() {
      if (widget.mode == 'single') {
        selected
          ..clear()
          ..add(day);
      } else if (widget.mode == 'multiple') {
        final idx = selected.indexWhere((e) => _sameDay(e, day));
        if (idx >= 0) {
          selected.removeAt(idx);
        } else {
          final maxCount = int.tryParse('${widget.maxCount}') ?? 999;
          if (selected.length < maxCount) selected.add(day);
        }
      } else {
        // range
        if (selected.isEmpty || selected.length >= 2) {
          selected
            ..clear()
            ..add(day);
        } else if (_sameDay(selected.first, day) && !widget.allowSameDay) {
          // ignore same-day unless allowed
        } else {
          final start = selected.first;
          final days = day.difference(start).inDays.abs() + 1;
          if (days > effectiveMaxRange) {
            // Source showRangePrompt toast retained via prop only.
            return;
          }
          selected.add(day);
          selected.sort((a, b) => a.compareTo(b));
        }
      }
    });
    widget.onChange?.call(List<DateTime>.from(selected));
  }

  Widget _month(DateTime month, Color themeColor) {
    final first = DateTime(month.year, month.month, 1);
    final leading = (first.weekday + 6) % 7;
    final days = DateTime(month.year, month.month + 1, 0).day;
    final rowH = UPUtils.getPx(widget.rowHeight);
    final cells = <Widget>[];
    for (var i = 0; i < leading; i++) {
      cells.add(SizedBox(height: rowH));
    }
    final today = _dateOnly(DateTime.now());
    for (var d = 1; d <= days; d++) {
      final day = DateTime(month.year, month.month, d);
      final selectedDay = _isSelected(day);
      final edge = _isStartOrEnd(day);
      final isToday = widget.showToday && _sameDay(day, today);
      final disabled = _disabled(day);
      final custom = widget.showMark ? _customInfo(day) : null;
      cells.add(
        GestureDetector(
          onTap: disabled ? null : () => _tapDay(day),
          child: Opacity(
            opacity: disabled ? 0.35 : 1,
            child: Container(
              height: rowH,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selectedDay
                    ? (edge ? themeColor : themeColor.withValues(alpha: 0.15))
                    : null,
                borderRadius: BorderRadius.circular(edge ? 4 : 0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$d',
                    style: TextStyle(
                      color: edge
                          ? const Color(0xFFFFFFFF)
                          : (isToday ? themeColor : const Color(0xFF303133)),
                      fontSize: 15,
                      fontWeight:
                          edge || isToday ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (custom != null && custom.isNotEmpty)
                    Text(
                      custom,
                      style: TextStyle(
                        color: edge ? const Color(0xFFFFFFFF) : themeColor,
                        fontSize: 10,
                      ),
                    )
                  else if (widget.showLunar)
                    Text(
                      _lunarHint(day),
                      style: TextStyle(
                        color: edge
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xFF909193),
                        fontSize: 10,
                      ),
                    )
                  else if (widget.mode == 'range' && selected.length == 2) ...[
                    if (_sameDay(day, selected.first))
                      Text(
                        widget.startText,
                        style: TextStyle(
                          color: edge ? const Color(0xFFFFFFFF) : themeColor,
                          fontSize: 10,
                        ),
                      ),
                    if (_sameDay(day, selected.last) &&
                        !_sameDay(selected.first, selected.last))
                      Text(
                        widget.endText,
                        style: TextStyle(
                          color: edge ? const Color(0xFFFFFFFF) : themeColor,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            '${month.year}年${month.month}月',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF303133),
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: cells,
        ),
      ],
    );
  }

  bool get _confirmEnabled {
    if (selected.isEmpty) return false;
    if (widget.mode == 'range') {
      if (selected.length < 2 && !widget.allowSameDay) return false;
      if (selected.length == 1 && widget.allowSameDay) return true;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final themeColor = UPUtils.parseColor(widget.color) ?? tokens.primary;
    final months = [
      for (var i = 0; i < widget.monthNum; i++)
        DateTime(baseMonth.year, baseMonth.month + i, 1),
    ];

    final body = Container(
      color: UPUtils.parseColor(widget.bgColor) ?? tokens.cardBgColor,
      constraints: const BoxConstraints(maxHeight: 520),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showTitle)
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Text(
                widget.title,
                style: TextStyle(
                  color: tokens.mainColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (widget.showSubtitle)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                selected.isEmpty
                    ? '请选择日期'
                    : selected
                        .map((e) => '${e.year}-${_pad(e.month)}-${_pad(e.day)}')
                        .join(' ~ '),
                style: TextStyle(color: tokens.tipsColor, fontSize: 13),
              ),
            ),
          Row(
            children: [
              for (final w in widget.weekText)
                Expanded(
                  child: Center(
                    child: Text(
                      '$w',
                      style: TextStyle(color: tokens.tipsColor, fontSize: 13),
                    ),
                  ),
                ),
            ],
          ),
          Flexible(
            child: ListView(
              children: [for (final m in months) _month(m, themeColor)],
            ),
          ),
          if (widget.showConfirm)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: UPButton(
                text: _confirmEnabled
                    ? widget.confirmText
                    : widget.confirmDisabledText,
                type: 'primary',
                disabled: !_confirmEnabled,
                color: '${widget.color}',
                onClick: !_confirmEnabled
                    ? null
                    : () {
                        final out = List<DateTime>.from(selected);
                        if (widget.mode == 'range' &&
                            out.length == 1 &&
                            widget.allowSameDay) {
                          out.add(out.first);
                        }
                        widget.onConfirm
                            ?.call(widget.mode == 'range' ? confirmDates : out);
                      },
              ),
            ),
        ],
      ),
    );

    Widget root = UPPopup(
      show: widget.show,
      overlay: widget.overlay,
      mode: 'bottom',
      duration: widget.duration,
      overlayStyle: widget.overlayStyle,
      overlayOpacity: widget.overlayOpacity,
      closeOnClickOverlay: widget.closeOnClickOverlay,
      zIndex: widget.zIndex,
      safeAreaInsetBottom: widget.safeAreaInsetBottom,
      safeAreaInsetTop: widget.safeAreaInsetTop,
      closeable: !widget.pageInline,
      round: widget.round,
      bgColor: widget.bgColor,
      pageInline: widget.pageInline,
      onClose: widget.onClose,
      onClosed: widget.onClosed,
      child: body,
    );
    return root;
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}
