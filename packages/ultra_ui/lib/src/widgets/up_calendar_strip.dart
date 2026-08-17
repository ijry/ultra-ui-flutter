import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_calendar.dart';

/// Port of u-calendar-strip (horizontal month strip + expand full calendar).
class UPCalendarStrip extends StatefulWidget {
  const UPCalendarStrip({
    super.key,
    this.value,
    this.modelValue,
    this.minDate,
    this.maxDate,
    this.color = '#3c9cff',
    this.weekText = const ['日', '一', '二', '三', '四', '五', '六'],
    this.fullCalendar = true,
    this.fullMonthNum = 1,
    this.readonly = false,
    this.showToday = true,
    this.monthFormat = 'yyyy年MM月',
    this.expandHint = '下拉展开',
    this.collapseHint = '收起',
    this.fullCalendarProps = const {},
    this.collapseAfterSelect = false,
    this.pullDownThreshold = 60,
    this.onChange,
    this.onConfirm,
    this.onMonthChange,
    this.onExpand,
    this.onToggleFull,
    this.onUpdateModelValue,
    this.onUpdateValue,
    this.customStyle,
  });

  final dynamic value;
  final dynamic modelValue;
  final dynamic minDate;
  final dynamic maxDate;
  final dynamic color;
  final List weekText;
  final bool fullCalendar;
  final dynamic fullMonthNum;
  final bool readonly;
  final bool showToday;
  final String monthFormat;
  final String expandHint;
  final String collapseHint;
  final Map fullCalendarProps;
  final bool collapseAfterSelect;
  final dynamic pullDownThreshold;
  final ValueChanged<DateTime>? onChange;
  final ValueChanged<DateTime>? onConfirm;
  final ValueChanged<String>? onMonthChange;
  final ValueChanged<bool>? onExpand;
  final ValueChanged<bool>? onToggleFull;
  final ValueChanged<String>? onUpdateModelValue;
  final ValueChanged<String>? onUpdateValue;

  final BoxDecoration? customStyle;
  @override
  State<UPCalendarStrip> createState() => UPCalendarStripState();
}

class UPCalendarStripState extends State<UPCalendarStrip> {
  late DateTime _selected;

  /// Source data.
  DateTime get innerSelectedDate => _selected;
  bool get innerShowFull => _expanded;
  dynamic scrollIntoView;
  double touchStartX = 0;
  double touchStartY = 0;

  late DateTime _currentMonth;
  bool _expanded = false;

  DateTime get selectedDate => _selected;
  String get currentMonth =>
      '${_currentMonth.year}-${_pad(_currentMonth.month)}';
  bool get isExpanded => _expanded;

  /// Source date range helpers (Batch K).
  bool get hasMinDate => _parse(widget.minDate) != null;
  bool get hasMaxDate => _parse(widget.maxDate) != null;
  DateTime? get innerMinDate => _parse(widget.minDate);
  DateTime? get innerMaxDate => _parse(widget.maxDate);
  DateTime? get minDateDay => innerMinDate;
  DateTime? get maxDateDay => innerMaxDate;
  DateTime? get panelMinDate => innerMinDate;
  DateTime? get panelMaxDate => innerMaxDate;
  int get panelMonthNum => 1;
  DateTime get todayDate => DateTime.now();
  String get monthLabel => _fmtMonth(_currentMonth);
  List<DateTime> get monthDays => _monthDays;
  bool get switchPrevDisabled => _prevDisabled;
  bool get switchNextDisabled => _nextDisabled;

  /// Source residual helper.
  String pullHintText([dynamic _]) => '下拉查看完整日历';

  void rangeChange([dynamic _]) {
    // Source watcher: re-sync selection when min/max range changes.
    final next = _parse(widget.modelValue) ?? _parse(widget.value) ?? _selected;
    syncByValue(next);
  }

  @override
  void initState() {
    super.initState();
    _selected =
        _parse(widget.modelValue) ?? _parse(widget.value) ?? DateTime.now();
    _currentMonth = DateTime(_selected.year, _selected.month, 1);
  }

  @override
  void didUpdateWidget(covariant UPCalendarStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _parse(widget.modelValue) ?? _parse(widget.value);
    if (next != null && !_sameDay(next, _selected)) {
      _selected = next;
      _currentMonth = DateTime(next.year, next.month, 1);
    }
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  DateTime? _parse(dynamic v) {
    if (v == null || '$v'.isEmpty) return null;
    if (v is DateTime) return DateTime(v.year, v.month, v.day);
    if (v is int) {
      // support ms / seconds
      final ms = v > 100000000000 ? v : (v > 1000000000 ? v * 1000 : null);
      if (ms == null) return null;
      final d = DateTime.fromMillisecondsSinceEpoch(ms);
      return DateTime(d.year, d.month, d.day);
    }
    final s = '$v'.replaceAll('/', '-');
    final parts = s.split(RegExp(r'[-T\s:]'));
    if (parts.length >= 3) {
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y != null && m != null && d != null) return DateTime(y, m, d);
    }
    return null;
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _inRange(DateTime d) {
    final min = _parse(widget.minDate);
    final max = _parse(widget.maxDate);
    if (min != null && d.isBefore(min)) return false;
    if (max != null && d.isAfter(max)) return false;
    return true;
  }

  String _fmtDate(DateTime d) => '${d.year}-${_pad(d.month)}-${_pad(d.day)}';

  String _fmtMonth(DateTime d) {
    return widget.monthFormat
        .replaceAll('yyyy', '${d.year}')
        .replaceAll('MM', d.month.toString().padLeft(2, '0'))
        .replaceAll('M', '${d.month}');
  }

  String _weekLabel(DateTime d) {
    // Source weekText default starts Sunday.
    final idx = d.weekday % 7; // Sun=0
    if (idx >= 0 && idx < widget.weekText.length) {
      return '${widget.weekText[idx]}';
    }
    return '';
  }

  bool get _prevDisabled {
    final min = _parse(widget.minDate);
    if (min == null) return false;
    final minMonth = DateTime(min.year, min.month, 1);
    return !_currentMonth.isAfter(minMonth);
  }

  bool get _nextDisabled {
    final max = _parse(widget.maxDate);
    if (max == null) return false;
    final maxMonth = DateTime(max.year, max.month, 1);
    return !_currentMonth.isBefore(maxMonth);
  }

  List<DateTime> get _monthDays {
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    return [
      for (var d = 1; d <= daysInMonth; d++)
        DateTime(_currentMonth.year, _currentMonth.month, d),
    ];
  }

  void _emit(DateTime d, {bool confirm = false}) {
    final s = _fmtDate(d);
    widget.onChange?.call(d);
    widget.onUpdateModelValue?.call(s);
    widget.onUpdateValue?.call(s);
    if (confirm) widget.onConfirm?.call(d);
  }

  void _select(DateTime d, {bool confirm = true}) {
    if (widget.readonly || !_inRange(d)) return;
    setState(() {
      _selected = d;
      _currentMonth = DateTime(d.year, d.month, 1);
    });
    _emit(d, confirm: confirm);
  }

  void prevMonth() {
    if (_prevDisabled) return;
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
    widget.onMonthChange?.call(currentMonth);
  }

  void nextMonth() {
    if (_nextDisabled) return;
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
    widget.onMonthChange?.call(currentMonth);
  }

  void toggleFull([String source = 'button']) {
    if (!widget.fullCalendar) return;
    setState(() => _expanded = !_expanded);
    widget.onExpand?.call(_expanded);
    widget.onToggleFull?.call(_expanded);
  }

  void openFull() {
    if (!widget.fullCalendar) return;
    setState(() => _expanded = true);
    widget.onExpand?.call(true);
    widget.onToggleFull?.call(true);
  }

  void closeFull() {
    setState(() => _expanded = false);
    widget.onExpand?.call(false);
    widget.onToggleFull?.call(false);
  }

  /// Source touch / enabled-date helpers (Batch I).
  DateTime? findFirstEnabledDate([dynamic from]) {
    var d = from is DateTime
        ? DateTime(from.year, from.month, from.day)
        : (_parse(from) ?? _selected);
    for (var i = 0; i < 366; i++) {
      if (_inRange(d)) return d;
      d = d.add(const Duration(days: 1));
    }
    return null;
  }

  void onTouchStart([dynamic event]) {
    if (!widget.fullCalendar) return;
    final point = _touchPoint(event);
    if (point == null) return;
    touchStartX = point.$1;
    touchStartY = point.$2;
  }

  void onTouchEnd([dynamic event]) {
    if (!widget.fullCalendar) return;
    final point = _touchPoint(event);
    if (point == null) return;
    final deltaX = point.$1 - touchStartX;
    final deltaY = point.$2 - touchStartY;
    final threshold =
        (num.tryParse('${widget.pullDownThreshold}') ?? 40).toDouble();
    if (deltaY.abs() < threshold || deltaY.abs() <= deltaX.abs()) {
      return;
    }
    if (deltaY > 0 && !_expanded) {
      setFullVisible(true);
    } else if (deltaY < 0 && _expanded) {
      setFullVisible(false);
    }
  }

  (double, double)? _touchPoint(dynamic event) {
    if (event == null) return null;
    if (event is Offset) return (event.dx, event.dy);
    if (event is Map) {
      final touches = event['changedTouches'] ?? event['touches'];
      dynamic p = event;
      if (touches is List && touches.isNotEmpty) p = touches.first;
      if (p is Map) {
        final x = num.tryParse('${p['clientX'] ?? p['x'] ?? p['dx'] ?? ''}');
        final y = num.tryParse('${p['clientY'] ?? p['y'] ?? p['dy'] ?? ''}');
        if (x != null && y != null) return (x.toDouble(), y.toDouble());
      }
      final x = num.tryParse(
          '${event['clientX'] ?? event['x'] ?? event['dx'] ?? ''}');
      final y = num.tryParse(
          '${event['clientY'] ?? event['y'] ?? event['dy'] ?? ''}');
      if (x != null && y != null) return (x.toDouble(), y.toDouble());
    }
    return null;
  }

  /// Source `getDateId`.
  String getDateId([dynamic date]) {
    final d = date is DateTime
        ? DateTime(date.year, date.month, date.day)
        : (_parse(date) ?? _selected);
    return _fmtDate(d);
  }

  /// Source `dayStyle`.
  Map dayStyle([dynamic date]) {
    final d = date is DateTime
        ? DateTime(date.year, date.month, date.day)
        : _parse(date);
    if (d == null) return const {};
    final selected = _sameDay(d, _selected);
    final disabled = !_inRange(d);
    final today = _sameDay(d, DateTime.now());
    return {
      'selected': selected,
      'disabled': disabled,
      'today': today,
      'date': _fmtDate(d),
    };
  }

  /// Source `scrollToDate`.
  void scrollToDate([dynamic date]) {
    final d = date is DateTime
        ? DateTime(date.year, date.month, date.day)
        : _parse(date);
    if (d == null) return;
    setState(() {
      _currentMonth = DateTime(d.year, d.month, 1);
      if (_inRange(d)) _selected = d;
    });
  }

  /// Source `syncByValue`.
  void syncByValue([dynamic value]) {
    final d = value is DateTime
        ? DateTime(value.year, value.month, value.day)
        : _parse(value ?? widget.value);
    if (d == null) return;
    setState(() {
      _selected = d;
      _currentMonth = DateTime(d.year, d.month, 1);
    });
  }

  /// Source `getMonths`.
  List getMonths([dynamic _]) {
    return [
      for (var m = 1; m <= 12; m++)
        {
          'month': m,
          'label': _fmtMonth(DateTime(_currentMonth.year, m, 1)),
        },
    ];
  }

  /// Source date helpers.
  bool dateSame(dynamic a, dynamic b) {
    final da = a is DateTime ? a : _parse(a);
    final db = b is DateTime ? b : _parse(b);
    if (da == null || db == null) return false;
    return _sameDay(da, db);
  }

  DateTime? normalizeDate([dynamic date]) {
    if (date is DateTime) return DateTime(date.year, date.month, date.day);
    return _parse(date);
  }

  DateTime? clampDate([dynamic date]) {
    final d = normalizeDate(date) ?? _selected;
    final min = _parse(widget.minDate);
    final max = _parse(widget.maxDate);
    if (min != null && d.isBefore(min)) return min;
    if (max != null && d.isAfter(max)) return max;
    return d;
  }

  bool isDateDisabled([dynamic date]) {
    final d = normalizeDate(date);
    if (d == null) return true;
    return !_inRange(d);
  }

  /// Source `switchMonth`.
  void switchMonth([dynamic delta]) {
    final step = int.tryParse('$delta') ?? 1;
    if (step < 0) {
      for (var i = 0; i < -step; i++) {
        prevMonth();
      }
    } else {
      for (var i = 0; i < step; i++) {
        nextMonth();
      }
    }
  }

  /// Source `onDayTap`.
  void onDayTap([dynamic date]) => setSelectedDate(date, confirm: true);

  /// Source `setSelectedDate`.
  void setSelectedDate(dynamic date, {bool confirm = true}) {
    final d = date is DateTime
        ? DateTime(date.year, date.month, date.day)
        : _parse(date);
    if (d == null) return;
    _select(d, confirm: confirm);
  }

  /// Source `setFullVisible`.
  void setFullVisible(bool visible) {
    if (visible) {
      openFull();
    } else {
      closeFull();
    }
  }

  /// Source `onPanelConfirm` — confirm selected / provided date.
  void onPanelConfirm([dynamic date]) {
    final d = date == null
        ? _selected
        : (date is DateTime
            ? DateTime(date.year, date.month, date.day)
            : _parse(date));
    if (d == null) return;
    _select(d, confirm: true);
    if (_expanded) closeFull();
  }

  /// Source `getWeekLabel`.
  String getWeekLabel(dynamic date) {
    final d = date is DateTime ? date : _parse(date);
    if (d == null) return '';
    return _weekLabel(d);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final active = UPUtils.parseColor(widget.color) ?? tokens.primary;
    final today = DateTime.now();

    Widget strip = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: _prevDisabled ? null : prevMonth,
                child: Text(
                  '‹',
                  style: TextStyle(
                    fontSize: 22,
                    color: _prevDisabled
                        ? tokens.disabledColor
                        : tokens.contentColor,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  _fmtMonth(_currentMonth),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: tokens.mainColor,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _nextDisabled ? null : nextMonth,
                child: Text(
                  '›',
                  style: TextStyle(
                    fontSize: 22,
                    color: _nextDisabled
                        ? tokens.disabledColor
                        : tokens.contentColor,
                  ),
                ),
              ),
              if (widget.fullCalendar)
                GestureDetector(
                  onTap: () => toggleFull('button'),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      '▾',
                      style: TextStyle(fontSize: 16, color: tokens.tipsColor),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 68,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _monthDays.length,
            itemBuilder: (context, index) {
              final d = _monthDays[index];
              final selected = _sameDay(d, _selected);
              final isToday = widget.showToday && _sameDay(d, today);
              final enabled = _inRange(d);
              return GestureDetector(
                onTap: enabled ? () => _select(d) : null,
                child: Container(
                  width: 52,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: selected ? active : const Color(0x00000000),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        isToday && !selected ? Border.all(color: active) : null,
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${d.day}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: !enabled
                              ? tokens.disabledColor
                              : selected
                                  ? const Color(0xFFFFFFFF)
                                  : tokens.mainColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _weekLabel(d),
                        style: TextStyle(
                          fontSize: 11,
                          color: !enabled
                              ? tokens.disabledColor
                              : selected
                                  ? const Color(0xFFFFFFFF)
                                  : tokens.tipsColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.fullCalendar && !_expanded)
          GestureDetector(
            onTap: () => toggleFull('hint'),
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Text(
                widget.expandHint,
                style: TextStyle(fontSize: 12, color: tokens.tipsColor),
              ),
            ),
          ),
      ],
    );

    Widget root;
    if (_expanded && widget.fullCalendar) {
      final props = widget.fullCalendarProps;
      root = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UPCalendar(
            show: true,
            pageInline: true,
            showTitle: props['showTitle'] == true,
            showSubtitle: props['showSubtitle'] == true,
            showConfirm: false,
            mode: 'single',
            defaultDate: _selected,
            minDate: widget.minDate,
            maxDate: widget.maxDate,
            monthNum: int.tryParse('${widget.fullMonthNum}') ?? 1,
            readonly: widget.readonly,
            showToday: widget.showToday,
            color: widget.color,
            onChange: (list) {
              if (list.isEmpty) return;
              _select(list.first, confirm: true);
              closeFull();
            },
          ),
          GestureDetector(
            onTap: () => toggleFull('hint'),
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 8),
              child: Text(
                widget.collapseHint,
                style: TextStyle(fontSize: 12, color: tokens.tipsColor),
              ),
            ),
          ),
        ],
      );
    } else {
      root = Container(
        color: tokens.cardBgColor,
        child: strip,
      );
    }

    return root;
  }
}
