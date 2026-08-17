import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_input.dart';
import 'up_loading_icon.dart';
import 'up_popup.dart';
import 'up_toolbar.dart';

/// 1:1 API-compatible shell of u-picker.
class UPPicker extends StatefulWidget {
  const UPPicker({
    super.key,
    this.value = const [],
    this.modelValue,
    this.hasInput = false,
    this.inputProps = const {},
    this.inputBorder = 'surround',
    this.disabled = false,
    this.disabledColor = '',
    this.placeholder = '请选择',
    this.show = false,
    this.popupMode = 'bottom',
    this.showToolbar = true,
    this.title = '',
    this.columns = const [],
    this.loading = false,
    this.itemHeight = 44,
    this.cancelText = '取消',
    this.confirmText = '确认',
    this.cancelColor = '#909193',
    this.confirmColor = '',
    this.visibleItemCount = 5,
    this.keyName = 'text',
    this.valueName = 'value',
    this.closeOnClickOverlay = false,
    this.defaultIndex = const [],
    this.immediateChange = true,
    this.toolbarRightSlot = false,
    this.toolbarRight,
    this.toolbarBottom,
    this.zIndex = 10076,
    this.bgColor = '',
    this.round = 0,
    this.duration = 300,
    this.overlayOpacity = 0.5,
    this.maskStyle,
    this.maskClass = '',
    this.pageInline = false,
    this.onClose,
    this.onCancel,
    this.onConfirm,
    this.onChange,
    this.onUpdateShow,
    this.onUpdateValue,
    this.onUpdateModelValue,
    this.trigger,
    this.customStyle,
  });

  final List value;
  final List? modelValue;
  final bool hasInput;
  final Map inputProps;
  final String inputBorder;
  final bool disabled;
  final dynamic disabledColor;
  final String placeholder;
  final bool show;
  final String popupMode;
  final bool showToolbar;
  final String title;
  final List columns;
  final bool loading;
  final dynamic itemHeight;
  final String cancelText;
  final String confirmText;
  final dynamic cancelColor;
  final dynamic confirmColor;
  final dynamic visibleItemCount;
  final String keyName;
  final String valueName;
  final bool closeOnClickOverlay;
  final List defaultIndex;
  final bool immediateChange;
  final bool toolbarRightSlot;
  final Widget? toolbarRight;
  final Widget? toolbarBottom;
  final dynamic zIndex;
  final dynamic bgColor;
  final dynamic round;
  final dynamic duration;
  final dynamic overlayOpacity;
  final dynamic maskStyle;
  final String maskClass;
  final bool pageInline;
  final VoidCallback? onClose;
  final VoidCallback? onCancel;
  final void Function(List values, List indexes)? onConfirm;
  final void Function(List values, List indexes, int columnIndex)? onChange;
  final ValueChanged<bool>? onUpdateShow;
  final ValueChanged<List>? onUpdateValue;
  final ValueChanged<List>? onUpdateModelValue;
  final Widget? trigger;
  final BoxDecoration? customStyle;

  List get effectiveValue => modelValue ?? value;

  /// Source host helper: testArray.
  dynamic testArray([dynamic v]) => null;

  @override
  State<UPPicker> createState() => UPPickerState();
}

class UPPickerState extends State<UPPicker> {
  /// Source data.
  List get innerIndex => List.from(indexes);
  bool showByClickInput = false;

  late List<int> indexes;
  late List innerColumns;
  late List _columnsSnapshot;
  late List _defaultIndexSnapshot;
  late List _effectiveValueSnapshot;
  List<int> lastIndex = <int>[];
  List<int> currentActiveValue = <int>[];
  bool innerShow = false;
  int? _pendingChangeColumn;
  int _lastChangedColumn = 0;
  int _popupRevision = 0;

  @override
  void initState() {
    super.initState();
    innerColumns = _cloneColumns(widget.columns);
    _columnsSnapshot = _cloneColumns(widget.columns);
    _defaultIndexSnapshot = _cloneColumns(widget.defaultIndex);
    _effectiveValueSnapshot = _cloneColumns(widget.effectiveValue);
    indexes = _initIndexes();
    setLastIndex(indexes);
  }

  @override
  void didUpdateWidget(covariant UPPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final columnsChanged = !_valuesEqual(_columnsSnapshot, widget.columns);
    final defaultIndexChanged =
        !_valuesEqual(_defaultIndexSnapshot, widget.defaultIndex);
    final effectiveValueChanged =
        !_valuesEqual(_effectiveValueSnapshot, widget.effectiveValue);

    if (columnsChanged) {
      setColumns(widget.columns, rebuild: false);
      _columnsSnapshot = _cloneColumns(widget.columns);
    }

    if (defaultIndexChanged) {
      indexes = _defaultIndexes();
      setLastIndex(indexes);
      _defaultIndexSnapshot = _cloneColumns(widget.defaultIndex);
    }
    if (effectiveValueChanged) {
      final valueIndexes = _valueIndexes();
      if (valueIndexes != null) {
        indexes = valueIndexes;
        setLastIndex(indexes);
      }
      _effectiveValueSnapshot = _cloneColumns(widget.effectiveValue);
    }
  }

  List _cloneColumns(List columns) {
    return [for (final column in columns) _cloneValue(column)];
  }

  dynamic _cloneValue(dynamic value) {
    if (value is List) {
      return [for (final item in value) _cloneValue(item)];
    }
    if (value is Map) {
      return {
        for (final entry in value.entries) entry.key: _cloneValue(entry.value),
      };
    }
    return value;
  }

  bool _valuesEqual(dynamic a, dynamic b) {
    if (identical(a, b)) return true;
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (!_valuesEqual(a[i], b[i])) return false;
      }
      return true;
    }
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final entry in a.entries) {
        if (!b.containsKey(entry.key) ||
            !_valuesEqual(entry.value, b[entry.key])) {
          return false;
        }
      }
      return true;
    }
    return a == b;
  }

  List<int> _initIndexes() {
    return _valueIndexes() ?? _defaultIndexes();
  }

  List<int> _defaultIndexes() {
    return [
      for (var i = 0; i < innerColumns.length; i++)
        i < widget.defaultIndex.length
            ? int.tryParse('${widget.defaultIndex[i]}') ?? 0
            : 0
    ];
  }

  List<int>? _valueIndexes() {
    if (widget.effectiveValue.isEmpty) return null;
    final indexes = _defaultIndexes();
    var matchedValue = false;
    for (var i = 0; i < innerColumns.length; i++) {
      final col = _asList(innerColumns[i]);
      if (i < widget.effectiveValue.length) {
        final target = widget.effectiveValue[i];
        for (var j = 0; j < col.length; j++) {
          if (_itemValue(col[j]) == target) {
            indexes[i] = j;
            matchedValue = true;
            break;
          }
        }
      }
    }
    return matchedValue ? indexes : null;
  }

  List _asList(dynamic col) {
    if (col is List) return col;
    return const [];
  }

  String _itemText(dynamic item) {
    if (item is Map) {
      return '${item[widget.keyName] ?? ''}';
    }
    return '$item';
  }

  dynamic _itemValue(dynamic item) {
    if (item is Map) {
      return item[widget.valueName];
    }
    return item;
  }

  List _currentValues() {
    final values = <dynamic>[];
    for (var i = 0; i < innerColumns.length; i++) {
      final col = _asList(innerColumns[i]);
      final idx = i < indexes.length ? indexes[i] : 0;
      if (col.isEmpty) {
        values.add(null);
      } else {
        values.add(_itemValue(col[idx.clamp(0, col.length - 1)]));
      }
    }
    return values;
  }

  List _currentItems() {
    final items = <dynamic>[];
    for (var i = 0; i < innerColumns.length; i++) {
      final col = _asList(innerColumns[i]);
      final idx = i < indexes.length ? indexes[i] : 0;
      items.add(col.isEmpty ? null : col[idx.clamp(0, col.length - 1)]);
    }
    return items;
  }

  void _setShow(bool v) {
    setState(() {
      if (widget.hasInput) {
        showByClickInput = v;
      } else {
        innerShow = v;
      }
      if (!v && widget.show) _popupRevision++;
    });
    widget.onUpdateShow?.call(v);
  }

  void _onPick(int column, int index, {bool defer = false}) {
    setState(() {
      if (column < indexes.length) indexes[column] = index;
      _lastChangedColumn = _sourceChangedColumn();
      currentActiveValue = List<int>.from(indexes);
    });
    if (defer && !widget.immediateChange) {
      _pendingChangeColumn = column;
      return;
    }
    _emitChange(column);
  }

  int _sourceChangedColumn() {
    for (var i = 0; i < indexes.length; i++) {
      if (indexes[i] != (i < lastIndex.length ? lastIndex[i] : 0)) return i;
    }
    return 0;
  }

  void _emitChange(int _) {
    widget.onChange?.call(
      _currentItems(),
      List<int>.from(indexes),
      _lastChangedColumn,
    );
  }

  bool _onWheelScrollEnd(ScrollNotification notification, int column) {
    if (!widget.immediateChange && _pendingChangeColumn == column) {
      _pendingChangeColumn = null;
      _emitChange(column);
    }
    return false;
  }

  List getValues() {
    return [
      for (var i = 0; i < innerColumns.length; i++)
        _asList(innerColumns[i]).isEmpty
            ? null
            : _asList(innerColumns[i])[(i < indexes.length ? indexes[i] : 0)
                .clamp(0, _asList(innerColumns[i]).length - 1)]
    ];
  }

  List<int> getIndexs() => List<int>.from(indexes);

  List getColumnValues(int columnIndex) {
    if (columnIndex < 0 || columnIndex >= innerColumns.length) return const [];
    return List<dynamic>.from(_asList(innerColumns[columnIndex]));
  }

  void setColumns(List columns, {bool rebuild = true}) {
    void update() {
      innerColumns = _cloneColumns(columns);
      if (indexes.length != innerColumns.length) {
        indexes = List<int>.filled(innerColumns.length, 0);
      }
      for (var i = 0; i < indexes.length; i++) {
        final col = _asList(innerColumns[i]);
        if (col.isEmpty) {
          indexes[i] = 0;
        } else {
          indexes[i] = indexes[i].clamp(0, col.length - 1);
        }
      }
    }

    if (rebuild) {
      setState(update);
    } else {
      update();
    }
  }

  void setColumnValues(int columnIndex, List values) {
    if (columnIndex < 0) return;
    setState(() {
      while (innerColumns.length <= columnIndex) {
        innerColumns.add(const []);
        indexes.add(0);
      }
      innerColumns[columnIndex] = [
        for (final item in values)
          item is Map ? Map<dynamic, dynamic>.from(item) : item
      ];
      lastIndex = indexes.take(columnIndex).toList();
      for (var i = _lastChangedColumn + 1; i < indexes.length; i++) {
        indexes[i] = 0;
      }
      final col = _asList(innerColumns[columnIndex]);
      indexes[columnIndex] =
          col.isEmpty ? 0 : indexes[columnIndex].clamp(0, col.length - 1);
    });
  }

  void setIndexs(List index, [bool setLast = false]) {
    setState(() {
      indexes = [
        for (var i = 0; i < innerColumns.length; i++)
          i < index.length ? int.tryParse('${index[i]}') ?? 0 : 0
      ];
      for (var i = 0; i < indexes.length; i++) {
        final col = _asList(innerColumns[i]);
        indexes[i] = col.isEmpty ? 0 : indexes[i].clamp(0, col.length - 1);
      }
      if (setLast) lastIndex = List<int>.from(indexes);
    });
  }

  void setLastIndex(List index) {
    lastIndex = index.map((e) => int.tryParse('$e') ?? 0).toList();
  }

  void setDefault() {
    final next = lastIndex.isNotEmpty
        ? List<int>.from(lastIndex)
        : (widget.defaultIndex.length == innerColumns.length
            ? widget.defaultIndex.map((e) => int.tryParse('$e') ?? 0).toList()
            : List<int>.filled(innerColumns.length, 0));
    setIndexs(next, true);
  }

  bool get isShown =>
      widget.show || innerShow || (widget.hasInput && showByClickInput);

  /// Source input/mask helpers (Batch K).
  List get inputValue => _currentValues();
  String get inputLabel {
    final confirmed = widget.effectiveValue;
    if (innerColumns.isEmpty || confirmed.isEmpty) return '';
    final firstColumn = _asList(innerColumns.first);
    if (firstColumn.isNotEmpty && firstColumn.first is Map) {
      final labels = <String>[];
      for (final item in firstColumn) {
        if (confirmed.contains(_itemValue(item))) labels.add(_itemText(item));
      }
      return labels.join('/');
    }
    return confirmed.map((item) => '$item').join('/');
  }

  Map get inputPropsInner => <String, dynamic>{
        'border': widget.inputBorder,
        'placeholder': widget.placeholder,
        'disabled': widget.disabled,
        'disabledColor': widget.disabledColor,
        ...Map<String, dynamic>.from(widget.inputProps),
      };
  dynamic get maskStyleInner => widget.maskStyle ?? '';

  BoxDecoration? _maskDecoration(BuildContext context) {
    final style = widget.maskStyle;
    if (style is BoxDecoration) return style;
    if (style is Color) return BoxDecoration(color: style);
    if (style is Map) {
      final background = style['backgroundColor'] ?? style['color'];
      final color = UPUtils.parseColor(background);
      final gradient = style['gradient'];
      final border = style['border'];
      return BoxDecoration(
        color: gradient is Gradient ? null : color,
        gradient: gradient is Gradient ? gradient : null,
        border: border is BoxBorder ? border : null,
      );
    }
    if (style is String && style.trim().isNotEmpty) {
      final color = UPUtils.parseColor(style);
      if (color != null) return BoxDecoration(color: color);
      return null;
    }
    if (style != null || Theme.of(context).brightness != Brightness.dark) {
      return null;
    }

    const strong = Color(0xF21C1C1E);
    const weak = Color(0x991C1C1E);
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [strong, weak, Color(0x001C1C1E), weak, strong],
        stops: [0, 0.2, 0.5, 0.8, 1],
      ),
    );
  }

  /// Source `open` / `onShowByClickInput`.
  void open() => _setShow(true);
  void onShowByClickInput() {
    if (widget.disabled) return;
    setState(() => showByClickInput = !showByClickInput);
  }

  /// Source `closeHandler` / `cancel` / `confirm`.
  void closeHandler() {
    if (widget.closeOnClickOverlay) _close();
  }

  void cancel() => _cancel();
  void confirm() => _confirm();
  void close() => _close();

  /// Source `getItemText`.
  String getItemText(dynamic item) => _itemText(item);

  /// Source `changeHandler`.
  void changeHandler(int column, int index) => _onPick(column, index);

  void _confirm() {
    if (currentActiveValue.isEmpty) {
      setDefault();
    }
    final items = _currentItems();
    final modelValues = _currentValues();
    widget.onConfirm?.call(items, List<int>.from(indexes));
    widget.onUpdateValue?.call(modelValues);
    widget.onUpdateModelValue?.call(modelValues);
    setLastIndex(indexes);
    if (widget.hasInput) showByClickInput = false;
    _setShow(false);
  }

  void _cancel() {
    setDefault();
    if (widget.hasInput) showByClickInput = false;
    widget.onCancel?.call();
    _setShow(false);
  }

  void _close() {
    if (widget.closeOnClickOverlay) setDefault();
    if (widget.hasInput) showByClickInput = false;
    widget.onClose?.call();
    _setShow(false);
  }

  Widget _column(
    int columnIndex,
    List col,
    double itemH,
    Color textColor,
  ) {
    final initial = columnIndex < indexes.length
        ? indexes[columnIndex].clamp(0, col.isEmpty ? 0 : col.length - 1)
        : 0;
    final controller = FixedExtentScrollController(initialItem: initial);
    return Expanded(
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            return _onWheelScrollEnd(notification, columnIndex);
          }
          return false;
        },
        child: ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: itemH,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: (i) => _onPick(
            columnIndex,
            i,
            defer: true,
          ),
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: col.length,
            builder: (context, index) {
              final selected =
                  columnIndex < indexes.length && indexes[columnIndex] == index;
              return Container(
                height: itemH,
                alignment: Alignment.center,
                child: Text(
                  _itemText(col[index]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: textColor,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final itemH = UPUtils.getPx(widget.itemHeight);
    final visible = int.tryParse('${widget.visibleItemCount}') ?? 5;
    final height = itemH * visible;
    final show = isShown;
    final maskDecoration = _maskDecoration(context);

    final pickerBody = Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showToolbar)
              UPToolbar(
                title: widget.title,
                cancelText: widget.cancelText,
                confirmText: widget.confirmText,
                cancelColor: widget.cancelColor,
                confirmColor: widget.confirmColor,
                rightSlot: widget.toolbarRightSlot,
                right: widget.toolbarRight,
                onCancel: _cancel,
                onConfirm: _confirm,
              ),
            if (widget.toolbarBottom != null) widget.toolbarBottom!,
            SizedBox(
              height: height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < innerColumns.length; i++)
                        _column(
                          i,
                          _asList(innerColumns[i]),
                          itemH,
                          tokens.mainColor,
                        ),
                    ],
                  ),
                  if (maskDecoration != null)
                    IgnorePointer(
                      child: DecoratedBox(
                        key: const ValueKey('up-picker-wheel-mask'),
                        decoration: maskDecoration,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (widget.loading)
          Positioned.fill(
            child: Container(
              color: tokens.cardBgColor,
              alignment: Alignment.center,
              child: const UPLoadingIcon(mode: 'circle'),
            ),
          ),
      ],
    );

    Widget? trigger;
    if (widget.hasInput) {
      final props = inputPropsInner;
      final inputDisabled = props['disabled'] is bool
          ? props['disabled'] as bool
          : widget.disabled;
      trigger = GestureDetector(
        onTap: widget.disabled ? null : onShowByClickInput,
        child: widget.trigger ??
            UPInput(
              value: inputLabel,
              readonly: true,
              border: '${props['border'] ?? widget.inputBorder}',
              placeholder: '${props['placeholder'] ?? widget.placeholder}',
              disabled: inputDisabled,
              disabledColor:
                  '${props['disabledColor'] ?? widget.disabledColor}',
            ),
      );
    }

    final popup = UPPopup(
      key: ValueKey(_popupRevision),
      show: show,
      mode: widget.popupMode,
      zIndex: widget.zIndex,
      bgColor: widget.bgColor,
      round: widget.round,
      duration: widget.duration,
      overlayOpacity: widget.overlayOpacity,
      pageInline: widget.pageInline,
      closeOnClickOverlay: widget.closeOnClickOverlay,
      onClose: _close,
      child: pickerBody,
    );

    Widget root = trigger == null
        ? popup
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [trigger, popup],
          );
    return root;
  }
}

/// Port of u-picker-column (host shell; columns render inside UPPicker).
class UPPickerColumn extends StatelessWidget {
  const UPPickerColumn({
    super.key,
    this.child,
    this.customStyle,
  });

  final Widget? child;
  final BoxDecoration? customStyle;

  @override
  Widget build(BuildContext context) {
    return child ?? const SizedBox.shrink();
  }
}

/// Port of u-picker-data — input trigger + single-column picker.
class UPPickerData extends StatefulWidget {
  const UPPickerData({
    super.key,
    this.modelValue = '',
    this.value,
    this.title = '',
    this.description = '',
    this.options = const [],
    this.valueKey = 'id',
    this.labelKey = 'name',
    this.trigger,
    this.onUpdateModelValue,
    this.onUpdateValue,
    this.onConfirm,
    this.onCancel,
    this.onClose,
    this.customStyle,
  });

  final dynamic modelValue;

  /// Alias of [modelValue].
  final dynamic value;
  final String title;
  final String description;
  final List options;
  final String valueKey;
  final String labelKey;
  final Widget? trigger;
  final ValueChanged<dynamic>? onUpdateModelValue;
  final ValueChanged<dynamic>? onUpdateValue;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onClose;
  final BoxDecoration? customStyle;

  dynamic get effectiveValue => modelValue != '' && modelValue != null
      ? modelValue
      : (value ?? modelValue);

  /// Source computed: optionsInner.
  dynamic get optionsInner => [List<dynamic>.from(options)];

  @override
  State<UPPickerData> createState() => UPPickerDataState();
}

class UPPickerDataState extends State<UPPickerData> {
  bool show = false;
  String current = '';
  List defaultIndex = const [];

  @override
  void initState() {
    super.initState();
    _syncFromValue(widget.effectiveValue);
  }

  @override
  void didUpdateWidget(covariant UPPickerData oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.effectiveValue != widget.effectiveValue) {
      _syncFromValue(widget.effectiveValue);
    }
  }

  void _syncFromValue(dynamic value) {
    if (_isSourceFalsey(value)) {
      clear();
      return;
    }
    for (var index = 0; index < widget.options.length; index++) {
      final ele = widget.options[index];
      if (ele is Map && '${ele[widget.valueKey]}' == '$value') {
        current = '${ele[widget.labelKey] ?? ''}';
        defaultIndex = [index];
        return;
      }
    }
  }

  bool _isSourceFalsey(dynamic value) {
    if (value == null || value == false) return true;
    if (value is String) return value.isEmpty;
    if (value is num) return value == 0 || value.isNaN;
    return false;
  }

  /// Source `hideKeyboard`.
  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void clear() {
    current = '';
    defaultIndex = const [];
  }

  void open() => setState(() => show = true);
  void close() => widget.onClose?.call();

  void cancel() {
    setState(() => show = false);
    widget.onCancel?.call();
  }

  void confirm(List values, List indexes) {
    setState(() => show = false);
    dynamic selected;
    if (values.isNotEmpty) {
      selected = values[0];
    }
    final next = selected is Map ? selected[widget.valueKey] : selected;
    if (selected != null) {
      if (selected is Map) {
        current = '${selected[widget.labelKey] ?? ''}';
        defaultIndex = indexes.isEmpty ? const [] : [indexes.first];
      }
      for (var i = 0; i < widget.options.length; i++) {
        final ele = widget.options[i];
        if (ele is Map && '${ele[widget.valueKey]}' == '$next') {
          current = '${ele[widget.labelKey] ?? ''}';
          defaultIndex = [i];
          break;
        }
      }
      if (current.isEmpty) current = '$next';
    }
    widget.onUpdateModelValue?.call(next);
    widget.onUpdateValue?.call(next);
    widget.onConfirm?.call();
  }

  @override
  Widget build(BuildContext context) {
    final triggerChild = widget.trigger ??
        UPInput(
          value: current,
          disabled: true,
          disabledColor: '#ffffff',
          placeholder: widget.title,
          border: 'none',
        );

    Widget root = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            triggerChild,
            Positioned.fill(
              child: GestureDetector(
                key: const ValueKey('up-picker-data-trigger-cover'),
                behavior: HitTestBehavior.opaque,
                onTap: open,
              ),
            ),
          ],
        ),
        UPPicker(
          show: show,
          columns: [widget.options],
          keyName: widget.labelKey,
          valueName: widget.valueKey,
          title: widget.title,
          defaultIndex: defaultIndex,
          onConfirm: confirm,
          onCancel: cancel,
          onClose: () {
            close();
          },
        ),
      ],
    );
    return root;
  }
}
