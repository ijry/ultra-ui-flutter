import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';
import 'up_layout.dart';

final Expando<Map<String, dynamic>> _upFormItemState =
    Expando<Map<String, dynamic>>('upFormItemState');

/// Lightweight form validator (subset of async-validator used by uview-plus).
class UPForm extends StatefulWidget {
  const UPForm({
    super.key,
    this.model = const {},
    this.rules = const {},
    this.errorType = 'message',
    this.borderBottom = true,
    this.labelPosition = 'left',
    this.labelWidth = 45,
    this.labelAlign = 'left',
    this.labelStyle = const {},
    this.customStyle,
    required this.children,
  });

  final Map model;
  final Map rules;
  final String errorType;
  final bool borderBottom;
  final String labelPosition;
  final dynamic labelWidth;
  final String labelAlign;
  final Map labelStyle;
  final BoxDecoration? customStyle;
  final List<Widget> children;

  /// Source computed `propsChange` — watched layout/label props snapshot.
  dynamic propsChange([dynamic _]) => [
        errorType,
        borderBottom,
        labelPosition,
        labelWidth,
        labelAlign,
        labelStyle,
      ];

  @override
  State<UPForm> createState() => UPFormState();
}

class UPFormState extends State<UPForm> {
  /// Source host helper.
  dynamic resolve([dynamic v]) => v;

  /// Source host helper.
  dynamic reject([dynamic e]) => e;

  late Map _model;
  late Map _rules;
  Map? _originalModel;

  /// Source data.
  Map? get originalModel => _originalModel;
  final Map<String, String> _messages = {};
  final Map<String, UPFormItemState> _items = {};

  Map get model => _model;
  Map get rules => _rules;

  /// Source internal `formRules` alias.
  Map get formRules => _rules;
  Map<String, String> get messages => Map.unmodifiable(_messages);

  @override
  void initState() {
    super.initState();
    _model = Map<dynamic, dynamic>.from(widget.model);
    _rules = Map<dynamic, dynamic>.from(widget.rules);
    _originalModel = Map<dynamic, dynamic>.from(widget.model);
  }

  @override
  void didUpdateWidget(covariant UPForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.model, widget.model)) {
      _model = Map<dynamic, dynamic>.from(widget.model);
      _originalModel ??= Map<dynamic, dynamic>.from(widget.model);
    }
    if (!identical(oldWidget.rules, widget.rules)) {
      setRules(widget.rules);
    }
  }

  void registerItem(String prop, UPFormItemState item) {
    if (prop.isEmpty) return;
    _items[prop] = item;
  }

  void unregisterItem(String prop, UPFormItemState item) {
    if (_items[prop] == item) _items.remove(prop);
  }

  void setRules(Map rules) {
    _rules = Map<dynamic, dynamic>.from(rules);
  }

  /// Source `formRules` setter alias.
  void setFormRules(Map rules) => setRules(rules);

  /// Source `setProperty` alias.
  void setProperty(String prop, dynamic value) => setModelValue(prop, value);

  /// Source `resetModel` alias of [resetFields].
  void resetModel() => resetFields();

  /// Source error helper (cached message snapshot).
  String error([String prop = '']) {
    if (prop.isEmpty) {
      if (_messages.isEmpty) return '';
      return _messages.values.first;
    }
    return _messages[prop] ?? messages[prop] ?? '';
  }

  void setModelValue(String prop, dynamic value) {
    _setProperty(_model, prop, value);
    setState(() {});
  }

  dynamic getModelValue(String prop) => _getProperty(_model, prop);

  void resetFields() {
    if (_originalModel == null) return;
    setState(() {
      _model = Map<dynamic, dynamic>.from(_originalModel!);
      _messages.clear();
    });
    for (final item in _items.values) {
      item.setMessage('');
    }
  }

  /// Restore a single field to original model value and clear its message.
  void resetField(String prop) {
    if (prop.isEmpty || _originalModel == null) return;
    final value = _getProperty(_originalModel!, prop);
    _setProperty(_model, prop, value);
    setState(() {
      _messages.remove(prop);
    });
    _items[prop]?.setMessage('');
  }

  void clearValidate([dynamic props]) {
    final list = props == null
        ? _items.keys.toList()
        : (props is List ? props : [props]).map((e) => '$e').toList();
    setState(() {
      for (final p in list) {
        _messages.remove(p);
        _items[p]?.setMessage('');
      }
    });
  }

  /// Validate all or given fields. Returns true when no errors.
  Future<bool> validate({List<String>? props, bool showErrorMsg = true}) async {
    final targets = props ??
        {
          ..._rules.keys.map((e) => '$e'),
          ..._items.keys,
        }.toList();
    final errors = <Map>[];
    for (final prop in targets) {
      final fieldErrors = await validateField(prop, showErrorMsg: showErrorMsg);
      errors.addAll(fieldErrors);
    }
    return errors.isEmpty;
  }

  Future<List<Map>> validateField(
    String prop, {
    String? event,
    bool showErrorMsg = true,
  }) async {
    final item = _items[prop];
    List ruleSrc = const [];
    if (item != null && item.effectiveRules.isNotEmpty) {
      ruleSrc = item.effectiveRules;
    } else if (_rules[prop] != null) {
      ruleSrc = _rules[prop] is List
          ? List.from(_rules[prop] as List)
          : [_rules[prop]];
    }
    if (ruleSrc.isEmpty) {
      if (showErrorMsg) {
        _messages.remove(prop);
        item?.setMessage('');
      }
      return const [];
    }

    final value = _getProperty(_model, prop);
    final errors = <Map>[];
    for (final raw in ruleSrc) {
      if (raw is! Map) continue;
      final rule = Map<dynamic, dynamic>.from(raw);
      if (event != null) {
        final trigger = rule['trigger'];
        final triggers = trigger is List
            ? trigger.map((e) => '$e').toList()
            : (trigger == null ? <String>[] : ['$trigger']);
        if (triggers.isNotEmpty && !triggers.contains(event)) {
          continue;
        }
      }
      final msg = _checkRule(rule, value, prop);
      if (msg != null) {
        errors.add({'message': msg, 'prop': prop, 'field': prop});
        break;
      }
    }

    final message = errors.isEmpty ? '' : '${errors.first['message']}';
    if (showErrorMsg) {
      setState(() {
        if (message.isEmpty) {
          _messages.remove(prop);
        } else {
          _messages[prop] = message;
        }
      });
      item?.setMessage(message);
    }
    return errors;
  }

  String? _checkRule(Map rule, dynamic value, String prop) {
    final required = rule['required'] == true;
    final empty = _isEmpty(value);
    if (required && empty) {
      return '${rule['message'] ?? '$prop is required'}';
    }
    if (empty) return null;

    if (rule['type'] != null) {
      final t = '${rule['type']}';
      if (t == 'string' && value is! String) {
        return '${rule['message'] ?? '$prop type error'}';
      }
      if (t == 'number' && value is! num && num.tryParse('$value') == null) {
        return '${rule['message'] ?? '$prop type error'}';
      }
      if (t == 'array' && value is! List) {
        return '${rule['message'] ?? '$prop type error'}';
      }
      if (t == 'email' &&
          !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch('$value')) {
        return '${rule['message'] ?? 'email invalid'}';
      }
      if (t == 'url' &&
          !RegExp(r'^https?://', caseSensitive: false).hasMatch('$value')) {
        return '${rule['message'] ?? 'url invalid'}';
      }
    }

    if (rule['pattern'] != null) {
      final p = rule['pattern'];
      RegExp? re;
      if (p is RegExp) {
        re = p;
      } else {
        try {
          re = RegExp('$p');
        } catch (_) {}
      }
      if (re != null && !re.hasMatch('$value')) {
        return '${rule['message'] ?? '$prop pattern mismatch'}';
      }
    }

    if (rule['min'] != null || rule['max'] != null) {
      final min = rule['min'] is num
          ? rule['min'] as num
          : num.tryParse('${rule['min']}');
      final max = rule['max'] is num
          ? rule['max'] as num
          : num.tryParse('${rule['max']}');
      num len;
      if (value is String || value is List) {
        len = (value as dynamic).length as num;
      } else {
        len = num.tryParse('$value') ?? 0;
      }
      if (min != null && len < min) {
        return '${rule['message'] ?? '$prop min $min'}';
      }
      if (max != null && len > max) {
        return '${rule['message'] ?? '$prop max $max'}';
      }
    }

    final validator = rule['validator'];
    if (validator is Function) {
      try {
        final res = validator(rule, value, null);
        if (res is String && res.isNotEmpty) return res;
        if (res == false) return '${rule['message'] ?? '$prop invalid'}';
      } catch (_) {}
    }
    return null;
  }

  bool _isEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    if (value is Iterable) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    return false;
  }

  dynamic _getProperty(Map model, String prop) {
    if (prop.isEmpty) return null;
    final parts = prop.split('.');
    dynamic cur = model;
    for (final p in parts) {
      if (cur is Map && cur.containsKey(p)) {
        cur = cur[p];
      } else {
        return null;
      }
    }
    return cur;
  }

  void _setProperty(Map model, String prop, dynamic value) {
    final parts = prop.split('.');
    dynamic cur = model;
    for (var i = 0; i < parts.length - 1; i++) {
      final p = parts[i];
      if (cur is Map) {
        cur[p] ??= <dynamic, dynamic>{};
        cur = cur[p];
      }
    }
    if (cur is Map) {
      cur[parts.last] = value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _UPFormScope(
      state: this,
      model: _model,
      rules: _rules,
      errorType: widget.errorType,
      borderBottom: widget.borderBottom,
      labelPosition: widget.labelPosition,
      labelWidth: widget.labelWidth,
      labelAlign: widget.labelAlign,
      labelStyle: widget.labelStyle,
      messages: _messages,
      child: Column(children: widget.children),
    );
  }
}

class _UPFormScope extends InheritedWidget {
  const _UPFormScope({
    required this.state,
    required this.model,
    required this.rules,
    required this.errorType,
    required this.borderBottom,
    required this.labelPosition,
    required this.labelWidth,
    required this.labelAlign,
    required this.labelStyle,
    required this.messages,
    required super.child,
  });

  final UPFormState state;
  final Map model;
  final Map rules;
  final String errorType;
  final bool borderBottom;
  final String labelPosition;
  final dynamic labelWidth;
  final String labelAlign;
  final Map labelStyle;
  final Map<String, String> messages;

  static _UPFormScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_UPFormScope>();

  @override
  bool updateShouldNotify(covariant _UPFormScope oldWidget) {
    return model != oldWidget.model ||
        rules != oldWidget.rules ||
        borderBottom != oldWidget.borderBottom ||
        labelPosition != oldWidget.labelPosition ||
        labelWidth != oldWidget.labelWidth ||
        messages != oldWidget.messages ||
        errorType != oldWidget.errorType ||
        labelStyle != oldWidget.labelStyle;
  }
}

class UPFormItem extends StatefulWidget {
  const UPFormItem({
    super.key,
    this.label = '',
    this.prop = '',
    this.rules = const [],
    this.borderBottom = '',
    this.labelPosition = '',
    this.labelWidth = '',
    this.rightIcon = '',
    this.leftIcon = '',
    this.required = false,
    this.leftIconStyle = '',
    this.errorMessage = '',
    this.customStyle,
    this.rightSlot,
    this.labelSlot,
    this.onClick,
    this.child,
  });

  final String label;
  final String prop;
  final List rules;
  final dynamic borderBottom;
  final String labelPosition;
  final dynamic labelWidth;
  final String rightIcon;
  final String leftIcon;
  final bool required;
  final dynamic leftIconStyle;
  final String errorMessage;
  final BoxDecoration? customStyle;
  final Widget? rightSlot;
  final Widget? labelSlot;
  final VoidCallback? onClick;
  final Widget? child;

  /// Source computed: labelDynamicStyle.
  dynamic get labelDynamicStyle => <String, dynamic>{
        'color': required ? '#f56c6c' : '#303133',
        if (label.isNotEmpty) 'content': label,
      };

  /// Source computed: propsLine (defProps.line defaults).
  dynamic get propsLine => const <String, dynamic>{
        'color': '#d6d7d9',
        'length': '100%',
        'direction': 'row',
        'hairline': true,
        'margin': 0,
        'dashed': false,
      };

  /// Source data defaults (runtime filled from form scope during build).
  Map<String, dynamic> get _state =>
      _upFormItemState[this] ??= <String, dynamic>{
        'itemRules': const <dynamic>[],
        'parentData': const <String, dynamic>{
          'labelPosition': 'left',
          'labelAlign': 'left',
          'labelStyle': <String, dynamic>{},
          'labelWidth': 45,
          'errorType': 'message',
        },
      };
  dynamic get itemRules => _state['itemRules'] ?? const <dynamic>[];
  dynamic get parentData =>
      _state['parentData'] ??
      const <String, dynamic>{
        'labelPosition': 'left',
        'labelAlign': 'left',
        'labelStyle': <String, dynamic>{},
        'labelWidth': 45,
        'errorType': 'message',
      };

  @override
  State<UPFormItem> createState() => UPFormItemState();
}

class UPFormItemState extends State<UPFormItem> {
  String _message = '';
  UPFormState? _formState;
  List? _itemRules;

  /// Current validation message (source `message`).
  String get message => _message;

  /// Rules used for this item: local [setRules] override or widget.rules.
  List get effectiveRules => (_itemRules != null && _itemRules!.isNotEmpty)
      ? _itemRules!
      : widget.rules;

  /// Alias of source `init` — rebind parent form registration.
  void init() {
    final scope = _UPFormScope.of(context);
    _formState = scope?.state;
    _formState?.registerItem(widget.prop, this);
  }

  /// Manually set item-level rules (source `setRules`).
  void setRules(List rules) {
    _itemRules = List.from(rules);
  }

  void clearValidate() {
    if (widget.prop.isNotEmpty) {
      _formState?.clearValidate(widget.prop);
    } else {
      setMessage('');
    }
  }

  /// Reset field value to form original model and clear validation.
  void resetField() {
    if (widget.prop.isNotEmpty) {
      _formState?.resetField(widget.prop);
    } else {
      clearValidate();
    }
  }

  void clickHandler() {
    widget.onClick?.call();
  }

  @override
  void initState() {
    super.initState();
    _message = widget.errorMessage;
    if (widget.rules.isNotEmpty) {
      _itemRules = List.from(widget.rules);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = _UPFormScope.of(context);
    _formState = scope?.state;
    _formState?.registerItem(widget.prop, this);
    if (widget.errorMessage.isEmpty &&
        scope != null &&
        scope.messages[widget.prop] != null) {
      _message = scope.messages[widget.prop]!;
    }
  }

  @override
  void didUpdateWidget(covariant UPFormItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.prop != widget.prop) {
      _formState?.unregisterItem(oldWidget.prop, this);
      _formState?.registerItem(widget.prop, this);
    }
    if (oldWidget.errorMessage != widget.errorMessage &&
        widget.errorMessage.isNotEmpty) {
      _message = widget.errorMessage;
    }
  }

  @override
  void dispose() {
    _formState?.unregisterItem(widget.prop, this);
    super.dispose();
  }

  void setMessage(String message) {
    if (!mounted) return;
    setState(() => _message = message);
  }

  TextStyle _labelTextStyle(UPThemeTokens tokens, Map labelStyle) {
    final base = TextStyle(
      color: tokens.mainColor,
      fontSize: 15,
    );
    if (labelStyle.isEmpty) return base;
    Color? color;
    if (labelStyle['color'] != null) {
      color = UPUtils.parseColor(labelStyle['color']);
    }
    double? fontSize;
    if (labelStyle['fontSize'] != null) {
      fontSize = UPUtils.getPx(labelStyle['fontSize']);
    }
    FontWeight? weight;
    final fw = labelStyle['fontWeight'];
    if (fw != null) {
      final text = '$fw'.toLowerCase();
      if (text.contains('bold') || text == '700') {
        weight = FontWeight.w700;
      } else if (text == '500' || text.contains('medium')) {
        weight = FontWeight.w500;
      } else if (text == '600') {
        weight = FontWeight.w600;
      }
    }
    return base.copyWith(
      color: color ?? base.color,
      fontSize: fontSize ?? base.fontSize,
      fontWeight: weight ?? base.fontWeight,
      height: labelStyle['lineHeight'] is num
          ? (labelStyle['lineHeight'] as num).toDouble()
          : null,
    );
  }

  /// Source parent data helper (Batch J + BI).
  bool parentSynced = false;
  dynamic parentSnapshot;
  void updateParentData([dynamic data]) {
    parentSynced = true;
    parentSnapshot = data ??
        {
          'prop': widget.prop,
          'label': widget.label,
          'required': widget.required,
          'borderBottom': widget.borderBottom,
          'labelPosition': widget.labelPosition,
          'labelWidth': widget.labelWidth,
        };
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scope = _UPFormScope.of(context);
    final tokens = UPThemeTokens.of(context);
    final pos = widget.labelPosition.isNotEmpty
        ? widget.labelPosition
        : (scope?.labelPosition ?? 'left');
    final lw = widget.labelWidth == '' || widget.labelWidth == null
        ? UPUtils.getPx(scope?.labelWidth ?? 45)
        : UPUtils.getPx(widget.labelWidth);
    final showBorder = widget.borderBottom == '' || widget.borderBottom == null
        ? (scope?.borderBottom ?? true)
        : '${widget.borderBottom}' == 'true' || widget.borderBottom == true;
    final errorType = scope?.errorType ?? 'message';
    final labelAlign = scope?.labelAlign ?? 'left';
    final message = _message.isNotEmpty
        ? _message
        : (scope?.messages[widget.prop] ?? widget.errorMessage);
    widget._state['itemRules'] = List<dynamic>.from(effectiveRules);
    widget._state['parentData'] = <String, dynamic>{
      'labelPosition': pos,
      'labelAlign': labelAlign,
      'labelStyle': scope?.labelStyle ?? const <String, dynamic>{},
      'labelWidth': scope?.labelWidth ?? 45,
      'errorType': errorType,
    };

    TextAlign align;
    switch (labelAlign) {
      case 'center':
        align = TextAlign.center;
        break;
      case 'right':
        align = TextAlign.right;
        break;
      default:
        align = TextAlign.left;
    }

    final labelWidget = widget.labelSlot ??
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.required)
              const Text(
                '*',
                style: TextStyle(color: Color(0xFFF56C6C), fontSize: 14),
              ),
            if (widget.leftIcon.isNotEmpty) ...[
              UPIcon(
                name: widget.leftIcon,
                size: 16,
                color: tokens.contentColor,
              ),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                widget.label,
                textAlign: align,
                style: _labelTextStyle(tokens, scope?.labelStyle ?? const {}),
              ),
            ),
          ],
        );

    final content = Expanded(
      child: Row(
        children: [
          Expanded(child: widget.child ?? const SizedBox.shrink()),
          if (widget.rightSlot != null) widget.rightSlot!,
          if (widget.rightIcon.isNotEmpty)
            UPIcon(name: widget.rightIcon, size: 15, color: tokens.tipsColor),
        ],
      ),
    );

    Widget body;
    if (pos == 'top') {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          labelWidget,
          const SizedBox(height: 5),
          Row(children: [content]),
        ],
      );
    } else {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: lw, child: labelWidget),
          content,
        ],
      );
    }

    final borderColor = (message.isNotEmpty && errorType == 'border-bottom')
        ? const Color(0xFFF56C6C)
        : tokens.borderColor;

    final styledBody = GestureDetector(
      onTap: clickHandler,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: widget.customStyle,
        child: body,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        styledBody,
        if (message.isNotEmpty && errorType == 'message')
          Padding(
            padding: EdgeInsets.only(left: pos == 'top' ? 0 : lw, top: 5),
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFF56C6C), fontSize: 12),
            ),
          ),
        if (showBorder)
          Padding(
            padding: EdgeInsets.only(
              top: message.isNotEmpty && errorType == 'message' ? 5 : 0,
            ),
            child: UPLine(color: borderColor, hairline: true, margin: 0),
          ),
      ],
    );
  }
}
