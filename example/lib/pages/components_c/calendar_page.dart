import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  static const List<String> _titles = <String>[
    '单个日期',
    '多个日期',
    '日期范围',
    '自定义主题颜色',
    '自定义文案',
    '日期最大范围',
    '显示农历',
    '默认日期',
    '日期最小范围',
    '单月切换-单选',
    '单月切换-日期区间',
    '单月切换-多选',
  ];

  int? _activeIndex;
  final List<String> _values = List<String>.filled(_titles.length, '');

  void _open(int index) {
    if (!mounted) return;
    setState(() => _activeIndex = index);
  }

  void _close(int index) {
    if (!mounted || _activeIndex != index) return;
    setState(() => _activeIndex = null);
  }

  void _confirm(int index, List<DateTime> dates) {
    if (!mounted || dates.isEmpty) return;
    final formatted = dates.map(_formatDate).toList();
    final value = switch (index) {
      0 || 5 || 6 || 8 || 9 => formatted.first,
      1 || 7 || 11 => formatted.join(';'),
      _ => '${formatted.first}~${formatted.last}',
    };
    setState(() {
      _values[index] = value;
      _activeIndex = null;
    });
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Widget _row(int index) {
    return UPCell(
      key: ValueKey('calendar-page-open-$index'),
      title: _titles[index],
      label: _values[index],
      iconSlot: const Padding(
        padding: EdgeInsets.only(right: 4),
        child: Icon(Icons.calendar_month_outlined, size: 20),
      ),
      isLink: true,
      clickable: true,
      onClick: () => _open(index),
    );
  }

  UPCalendar _calendar(int index) {
    final common = <String, dynamic>{
      'key': ValueKey('calendar-page-widget-$index'),
      'show': _activeIndex == index,
      'onConfirm': (List<DateTime> dates) => _confirm(index, dates),
      'onClose': () => _close(index),
    };

    switch (index) {
      case 0:
        return UPCalendar(
          key: common['key'] as Key,
          show: common['show'] as bool,
          defaultDate: '2026-08-11',
          onConfirm: common['onConfirm'] as ValueChanged<List<DateTime>>,
          onClose: common['onClose'] as VoidCallback,
        );
      case 1:
        return UPCalendar(
          key: common['key'] as Key,
          show: common['show'] as bool,
          mode: 'multiple',
          defaultDate: const ['2026-08-11', '2026-08-12', '2026-08-13'],
          onConfirm: common['onConfirm'] as ValueChanged<List<DateTime>>,
          onClose: common['onClose'] as VoidCallback,
        );
      case 2:
        return UPCalendar(
          key: common['key'] as Key,
          show: common['show'] as bool,
          mode: 'range',
          defaultDate: const ['2026-08-11'],
          onConfirm: common['onConfirm'] as ValueChanged<List<DateTime>>,
          onClose: common['onClose'] as VoidCallback,
        );
      case 3:
        return UPCalendar(
          key: common['key'] as Key,
          show: common['show'] as bool,
          mode: 'range',
          color: '#f56c6c',
          defaultDate: const ['2026-08-11', '2026-08-15'],
          onConfirm: common['onConfirm'] as ValueChanged<List<DateTime>>,
          onClose: common['onClose'] as VoidCallback,
        );
      case 4:
        return UPCalendar(
          key: common['key'] as Key,
          show: common['show'] as bool,
          mode: 'range',
          startText: '住店',
          endText: '离店',
          confirmDisabledText: '请选择离店日期',
          defaultDate: const ['2026-08-11'],
          onConfirm: common['onConfirm'] as ValueChanged<List<DateTime>>,
          onClose: common['onClose'] as VoidCallback,
        );
      case 5:
        return UPCalendar(
          key: common['key'] as Key,
          show: common['show'] as bool,
          maxDate: '2026-08-21',
          defaultDate: '2026-08-11',
          onConfirm: common['onConfirm'] as ValueChanged<List<DateTime>>,
          onClose: common['onClose'] as VoidCallback,
        );
      case 6:
        return UPCalendar(
          key: common['key'] as Key,
          show: common['show'] as bool,
          showLunar: true,
          defaultDate: '2026-08-11',
          onConfirm: common['onConfirm'] as ValueChanged<List<DateTime>>,
          onClose: common['onClose'] as VoidCallback,
        );
      case 7:
        return UPCalendar(
          key: common['key'] as Key,
          show: common['show'] as bool,
          mode: 'multiple',
          defaultDate: const ['2026-08-11', '2026-08-12', '2026-08-13'],
          onConfirm: common['onConfirm'] as ValueChanged<List<DateTime>>,
          onClose: common['onClose'] as VoidCallback,
        );
      case 8:
        return UPCalendar(
          key: common['key'] as Key,
          show: common['show'] as bool,
          minDate: '2026-08-01',
          maxDate: '2026-08-21',
          defaultDate: '2026-08-11',
          onConfirm: common['onConfirm'] as ValueChanged<List<DateTime>>,
          onClose: common['onClose'] as VoidCallback,
        );
      case 9:
        return UPCalendar(
          key: common['key'] as Key,
          show: common['show'] as bool,
          defaultDate: '2026-08-15',
          monthNum: 36,
          monthSwitch: true,
          minDate: '2026-01-01',
          maxDate: '2026-12-31',
          onConfirm: common['onConfirm'] as ValueChanged<List<DateTime>>,
          onClose: common['onClose'] as VoidCallback,
        );
      case 10:
        return UPCalendar(
          key: common['key'] as Key,
          show: common['show'] as bool,
          mode: 'range',
          defaultDate: const ['2026-06-15', '2026-06-20'],
          monthNum: 36,
          monthSwitch: true,
          onConfirm: common['onConfirm'] as ValueChanged<List<DateTime>>,
          onClose: common['onClose'] as VoidCallback,
        );
      case 11:
        return UPCalendar(
          key: common['key'] as Key,
          show: common['show'] as bool,
          mode: 'multiple',
          defaultDate: const ['2026-06-15', '2026-07-15', '2026-08-15'],
          monthNum: 36,
          monthSwitch: true,
          onConfirm: common['onConfirm'] as ValueChanged<List<DateTime>>,
          onClose: common['onClose'] as VoidCallback,
        );
      default:
        throw StateError('Unknown calendar index: $index');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      key: const ValueKey('example-page-componentsC/calendar/calendar'),
      title: '日历',
      scrollable: false,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: UPCellGroup(
                children: <Widget>[
                  for (var i = 0; i < _titles.length; i++) _row(i),
                  const UPAlert(description: '页面行内模式'),
                  const UPCalendar(
                    key: ValueKey('calendar-page-inline'),
                    show: true,
                    pageInline: true,
                    showTitle: false,
                    showConfirm: false,
                    defaultDate: '2026-08-11',
                  ),
                  const UPAlert(
                    description: '单行日历（支持切月、下拉展开完整月历）',
                  ),
                  UPCalendarStrip(
                    key: const ValueKey('calendar-page-strip'),
                    value: '2026-08-11',
                    minDate: '2026-01-01',
                    maxDate: '2026-12-31',
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                    child: Text(
                      '2026-08-11',
                      key: const ValueKey('calendar-page-strip-value'),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_activeIndex != null)
            Positioned.fill(child: _calendar(_activeIndex!)),
        ],
      ),
    );
  }
}
