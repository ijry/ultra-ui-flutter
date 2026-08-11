import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class DatetimePickerPage extends StatefulWidget {
  const DatetimePickerPage({super.key});

  @override
  State<DatetimePickerPage> createState() => _DatetimePickerPageState();
}

class _DatetimePickerPageState extends State<DatetimePickerPage> {
  static final int _fixedDate = DateTime(2026, 8, 11).millisecondsSinceEpoch;
  static final int _fixedDatetime =
      DateTime(2026, 8, 11, 14, 30).millisecondsSinceEpoch;
  static const String _fixedTime = '05:28';
  static const int _minDate = 1767225600000;
  static const int _maxDate = 1798761540000;

  static const List<String> _titles = <String>[
    '完整日期时间',
    '年月日',
    '年月',
    '时间',
    '过滤器(保留偶数年)',
    '格式化',
    '限制最大最小值',
  ];

  int? _activeIndex;
  String _result = '结果：未选择';

  void _open(int index) {
    if (!mounted) return;
    setState(() => _activeIndex = index);
  }

  void _close(int index) {
    if (!mounted || _activeIndex != index) return;
    setState(() => _activeIndex = null);
  }

  void _confirm(dynamic payload) {
    if (!mounted) return;
    final value = payload is Map ? payload['value'] : payload;
    final mode = payload is Map ? '${payload['mode'] ?? ''}' : '';
    setState(() {
      _result = '结果：${_formatResult(value, mode)}';
      _activeIndex = null;
    });
  }

  String _formatResult(dynamic value, String mode) {
    if (mode == 'time') {
      if (value is String) return value;
      final date = _toDateTime(value);
      return date == null ? '$value' : _formatTime(date);
    }
    final date = _toDateTime(value);
    if (date == null) return '$value';
    switch (mode) {
      case 'date':
        return _formatDate(date);
      case 'year-month':
        return '${date.year}-${date.month.toString().padLeft(2, '0')}';
      case 'datetime':
      default:
        return '${_formatDate(date)} ${_formatTime(date)}';
    }
  }

  DateTime? _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    final text = '$value';
    if (text.isEmpty) return null;
    return DateTime.tryParse(text.replaceAll('/', '-'));
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _row(int index) {
    return UPCell(
      key: ValueKey('datetime-picker-page-open-$index'),
      title: _titles[index],
      iconSlot: const Padding(
        padding: EdgeInsets.only(right: 4),
        child: Icon(Icons.access_time_outlined, size: 20),
      ),
      isLink: true,
      clickable: true,
      onClick: () => _open(index),
    );
  }

  Widget _picker(int index) {
    switch (index) {
      case 0:
        return UPDatetimePicker(
          key: const ValueKey('datetime-picker-page-widget-0'),
          show: _activeIndex == index,
          mode: 'datetime',
          value: _fixedDatetime,
          closeOnClickOverlay: true,
          toolbarRightSlot: true,
          toolbarRight: const Text('右侧'),
          onConfirm: _confirm,
          onCancel: () => _close(index),
          onClose: () => _close(index),
        );
      case 1:
        return UPDatetimePicker(
          key: const ValueKey('datetime-picker-page-widget-1'),
          show: _activeIndex == index,
          mode: 'date',
          value: _fixedDate,
          closeOnClickOverlay: true,
          onConfirm: _confirm,
          onCancel: () => _close(index),
          onClose: () => _close(index),
        );
      case 2:
        return UPDatetimePicker(
          key: const ValueKey('datetime-picker-page-widget-2'),
          show: _activeIndex == index,
          mode: 'year-month',
          value: _fixedDate,
          closeOnClickOverlay: true,
          onConfirm: _confirm,
          onCancel: () => _close(index),
          onClose: () => _close(index),
        );
      case 3:
        return UPDatetimePicker(
          key: const ValueKey('datetime-picker-page-widget-3'),
          show: _activeIndex == index,
          mode: 'time',
          value: _fixedTime,
          closeOnClickOverlay: true,
          onConfirm: _confirm,
          onCancel: () => _close(index),
          onClose: () => _close(index),
        );
      case 4:
        return UPDatetimePicker(
          key: const ValueKey('datetime-picker-page-widget-4'),
          show: _activeIndex == index,
          mode: 'date',
          value: _fixedDate,
          closeOnClickOverlay: true,
          filter: (type, options) => type == 'year'
              ? options.where((value) => int.parse('$value').isEven).toList()
              : options,
          onConfirm: _confirm,
          onCancel: () => _close(index),
          onClose: () => _close(index),
        );
      case 5:
        return UPDatetimePicker(
          key: const ValueKey('datetime-picker-page-widget-5'),
          show: _activeIndex == index,
          mode: 'date',
          value: _fixedDate,
          closeOnClickOverlay: true,
          formatter: (type, value) {
            if (type == 'year') return '${value}年';
            if (type == 'month') return '${value}月';
            if (type == 'day') return '${value}日';
            return value;
          },
          onConfirm: _confirm,
          onCancel: () => _close(index),
          onClose: () => _close(index),
        );
      case 6:
        return UPDatetimePicker(
          key: const ValueKey('datetime-picker-page-widget-6'),
          show: _activeIndex == index,
          mode: 'datetime',
          value: _fixedDatetime,
          minDate: _minDate,
          maxDate: _maxDate,
          closeOnClickOverlay: true,
          onConfirm: _confirm,
          onCancel: () => _close(index),
          onClose: () => _close(index),
        );
      default:
        throw StateError('Unknown datetime picker index: $index');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      key: const ValueKey(
        'example-page-componentsC/datetimePicker/datetimePicker',
      ),
      title: 'datetimePicker 时间日期选择器',
      scrollable: false,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: <Widget>[
                  UPCellGroup(
                    children: <Widget>[
                      for (var i = 0; i < _titles.length; i++) _row(i),
                    ],
                  ),
                  ExampleDemoBlock(
                    title: '输入模式',
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: UPDatetimePicker(
                        key: const ValueKey('datetime-picker-page-input'),
                        hasInput: true,
                        value: _fixedDatetime,
                        placeholder: '请选择日期',
                        inputProps: const <String, dynamic>{
                          'border': 'surround',
                          'suffixIcon': 'calendar',
                        },
                      ),
                    ),
                  ),
                  ExampleDemoBlock(
                    title: '页面内联',
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: UPDatetimePicker(
                        key: const ValueKey('datetime-picker-page-inline'),
                        pageInline: true,
                        show: true,
                        mode: 'datetime',
                        showToolbar: false,
                        value: _fixedDatetime,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _result,
                        key: const ValueKey('datetime-picker-page-result'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          for (var i = 0; i < _titles.length; i++)
            Positioned.fill(child: _picker(i)),
        ],
      ),
    );
  }
}
