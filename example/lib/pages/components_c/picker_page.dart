import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class _PickerStateCapture extends UPPicker {
  const _PickerStateCapture({
    super.key,
    required this.onStateReady,
    this.show = false,
    this.loading = false,
    this.columns = const [],
    this.onChange,
    this.onConfirm,
    this.onCancel,
    this.onClose,
    this.onUpdateShow,
  }) : super(
          show: show,
          loading: loading,
          columns: columns,
          onChange: onChange,
          onConfirm: onConfirm,
          onCancel: onCancel,
          onClose: onClose,
          onUpdateShow: onUpdateShow,
        );

  final ValueChanged<UPPickerState> onStateReady;
  final bool show;
  final bool loading;
  final List columns;
  final void Function(List values, List indexes, int columnIndex)? onChange;
  final void Function(List values, List indexes)? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onClose;
  final ValueChanged<bool>? onUpdateShow;

  @override
  State<UPPicker> createState() {
    final state = UPPickerState();
    onStateReady(state);
    return state;
  }
}

class PickerPage extends StatefulWidget {
  const PickerPage({super.key});

  @override
  State<PickerPage> createState() => _PickerPageState();
}

class _PickerPageState extends State<PickerPage> {
  static const List<String> _countries = <String>['中国', '美国', '日本'];
  static const List<String> _cities = <String>['深圳', '厦门', '上海', '拉萨'];
  static const List<Map<String, dynamic>> _fruitOptions =
      <Map<String, dynamic>>[
    <String, dynamic>{'label': '苹果', 'value': 1},
    <String, dynamic>{'label': '橘子', 'value': 2},
    <String, dynamic>{'label': '香蕉', 'value': 3},
  ];

  UPPickerState? _linkedPickerState;
  UPPickerState? _loadingPickerState;

  int? _activePicker;
  String _confirmedValue = '';
  String _defaultConfirmedValue = '';
  String _linkedValue = '';
  String _linkedColumnLabel = _cities.first;
  bool _loading = false;

  void _open(int index) {
    if (!mounted) return;
    setState(() => _activePicker = index);
  }

  void _updateShow(int index, bool show) {
    if (!mounted || show || _activePicker != index) return;
    setState(() => _activePicker = null);
  }

  void _close(int index) {
    if (!mounted || _activePicker != index) return;
    setState(() => _activePicker = null);
  }

  void _confirmBasic(List values, List indexes) {
    if (!mounted) return;
    setState(() {
      _confirmedValue = values.isEmpty ? '' : '${values.first}';
      _activePicker = null;
    });
  }

  void _confirmDefault(List values, List indexes) {
    if (!mounted) return;
    setState(() {
      _defaultConfirmedValue = values.isEmpty ? '' : '${values.first}';
      _activePicker = null;
    });
  }

  void _onLinkedChange(List values, List indexes, int columnIndex) {
    if (!mounted) return;
    if (columnIndex == 0) {
      _linkedPickerState?.setColumnValues(1, _cities);
    }
    setState(() {
      _linkedColumnLabel = values.length > 1 ? '${values[1]}' : _cities.first;
    });
  }

  void _confirmLinked(List values, List indexes) {
    if (!mounted) return;
    setState(() {
      _linkedValue = values.map((value) => '$value').join('/');
      _linkedColumnLabel = values.length > 1 ? '${values[1]}' : _cities.first;
      _activePicker = null;
    });
  }

  void _onLoadingChange(List values, List indexes, int columnIndex) {
    if (!mounted || columnIndex != 0) return;
    setState(() => _loading = true);
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 120), () {
        if (!mounted) return;
        _loadingPickerState?.setColumnValues(1, _cities);
        setState(() => _loading = false);
      }),
    );
  }

  Widget _row({
    required int index,
    required String title,
    String value = '点击选择',
  }) {
    return UPCell(
      key: ValueKey('picker-page-open-$index'),
      title: title,
      value: value,
      isLink: true,
      clickable: true,
      onClick: () => _open(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      key: const ValueKey('example-page-componentsC/picker/picker'),
      title: '选择器',
      scrollable: false,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: <Widget>[
                  ExampleDemoBlock(
                    title: '基础使用',
                    child: _row(index: 0, title: '打开选择器'),
                  ),
                  ExampleDemoBlock(
                    title: '设置默认项',
                    child: _row(index: 1, title: '打开选择器'),
                  ),
                  ExampleDemoBlock(
                    title: '多列联动',
                    child: _row(index: 2, title: '打开选择器'),
                  ),
                  ExampleDemoBlock(
                    title: '加载中状态(切换第一列)',
                    child: _row(index: 3, title: '打开选择器'),
                  ),
                  ExampleDemoBlock(
                    title: '设置标题',
                    child: _row(index: 4, title: '打开选择器'),
                  ),
                  ExampleDemoBlock(
                    title: '允许点击遮罩关闭',
                    child: _row(index: 5, title: '打开选择器'),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('基础确认值：$_confirmedValue'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('默认确认值：$_defaultConfirmedValue'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('联动列：$_linkedColumnLabel'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('联动确认值：$_linkedValue'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('加载状态：${_loading ? '加载中' : '已完成'}'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(child: _basicPicker()),
          Positioned.fill(child: _defaultPicker()),
          Positioned.fill(child: _linkedPicker()),
          Positioned.fill(child: _loadingPicker()),
          Positioned.fill(child: _titlePicker()),
          Positioned.fill(child: _overlayPicker()),
        ],
      ),
    );
  }

  Widget _basicPicker() {
    return UPPicker(
      key: const ValueKey('picker-page-basic'),
      show: _activePicker == 0,
      columns: <List<dynamic>>[_countries],
      toolbarRightSlot: true,
      toolbarRight: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Text('右侧'),
      ),
      pageInline: false,
      onConfirm: _confirmBasic,
      onCancel: () => _close(0),
      onClose: () => _close(0),
      onUpdateShow: (show) => _updateShow(0, show),
    );
  }

  Widget _defaultPicker() {
    return UPPicker(
      key: const ValueKey('picker-page-default'),
      show: _activePicker == 1,
      columns: <List<dynamic>>[_countries],
      defaultIndex: const <int>[1],
      onConfirm: _confirmDefault,
      onCancel: () => _close(1),
      onClose: () => _close(1),
      onUpdateShow: (show) => _updateShow(1, show),
    );
  }

  Widget _linkedPicker() {
    return _PickerStateCapture(
      key: const ValueKey('picker-page-linked'),
      onStateReady: (state) => _linkedPickerState = state,
      show: _activePicker == 2,
      columns: <List<dynamic>>[_countries, _cities],
      onChange: _onLinkedChange,
      onConfirm: _confirmLinked,
      onCancel: () => _close(2),
      onClose: () => _close(2),
      onUpdateShow: (show) => _updateShow(2, show),
    );
  }

  Widget _loadingPicker() {
    return _PickerStateCapture(
      key: const ValueKey('picker-page-loading'),
      onStateReady: (state) => _loadingPickerState = state,
      show: _activePicker == 3,
      loading: _loading,
      columns: <List<dynamic>>[_countries, _cities],
      onChange: _onLoadingChange,
      onConfirm: (_, __) => _close(3),
      onCancel: () => _close(3),
      onClose: () => _close(3),
      onUpdateShow: (show) => _updateShow(3, show),
    );
  }

  Widget _titlePicker() {
    return UPPicker(
      key: const ValueKey('picker-page-title'),
      show: _activePicker == 4,
      title: '标题太长就会显示省略号',
      value: const <dynamic>['日本'],
      columns: <List<dynamic>>[_countries],
      toolbarBottom: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text('对象值示例：${_fruitOptions.first['label']}'),
      ),
      onConfirm: (_, __) => _close(4),
      onCancel: () => _close(4),
      onClose: () => _close(4),
      onUpdateShow: (show) => _updateShow(4, show),
    );
  }

  Widget _overlayPicker() {
    return UPPicker(
      key: const ValueKey('picker-page-overlay'),
      show: _activePicker == 5,
      columns: <List<dynamic>>[_countries],
      closeOnClickOverlay: true,
      onConfirm: (_, __) => _close(5),
      onCancel: () => _close(5),
      onClose: () => _close(5),
      onUpdateShow: (show) => _updateShow(5, show),
    );
  }
}
