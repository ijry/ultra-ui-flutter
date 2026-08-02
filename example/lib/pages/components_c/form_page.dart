import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final GlobalKey<UPFormState> _formKey = GlobalKey<UPFormState>();
  final UPCodeController _codeController = UPCodeController();

  late Map<String, dynamic> _model;
  String _name = '楼兰';
  String _sex = '';
  String _age = '0';
  String _fruit = '苹果';
  List<dynamic> _hobbies = <dynamic>[];
  String _intro = '';
  String _hotel = '';
  String _code = '';
  String _birthday = '';
  String _codeText = '';
  String _submitStatus = '未提交';
  bool _showSex = false;
  bool _showCalendar = false;
  bool _showBirthday = false;

  Map<String, dynamic> _initialModel() => <String, dynamic>{
        'userInfo': <String, dynamic>{
          'name': '楼兰',
          'sex': '',
          'age': '0',
          'birthday': '',
        },
        'radiovalue1': '苹果',
        'checkboxValue1': <dynamic>[],
        'intro': '',
        'hotel': '',
        'code': '',
      };

  Map<String, dynamic> get _rules => <String, dynamic>{
        'userInfo.name': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'string',
            'required': true,
            'message': '请填写姓名',
          },
          <String, dynamic>{
            'pattern': RegExp(r'^[\u4E00-\u9FFF]+$'),
            'message': '姓名必须为中文',
          },
        ],
        'userInfo.sex': <String, dynamic>{
          'type': 'string',
          'required': true,
          'max': 1,
          'message': '请选择男或女',
        },
        'userInfo.age': <String, dynamic>{
          'type': 'string',
          'required': true,
          'message': '请填写年龄',
        },
        'radiovalue1': <String, dynamic>{
          'type': 'string',
          'min': 1,
          'max': 2,
          'message': '橙子有毒',
        },
        'checkboxValue1': <String, dynamic>{
          'type': 'array',
          'min': 2,
          'required': true,
          'message': '不能太宅，至少选两项',
        },
        'intro': <String, dynamic>{
          'type': 'string',
          'min': 3,
          'required': true,
          'message': '不低于3个字',
        },
        'hotel': <String, dynamic>{
          'type': 'string',
          'min': 2,
          'required': true,
          'message': '请选择住店时间',
        },
        'code': <String, dynamic>{
          'type': 'string',
          'required': true,
          'len': 4,
          'message': '请填写4位验证码',
        },
        'userInfo.birthday': <String, dynamic>{
          'type': 'string',
          'required': true,
          'message': '请选择生日',
        },
      };

  @override
  void initState() {
    super.initState();
    _model = _initialModel();
  }

  void _setField(String prop, dynamic value, VoidCallback localUpdate) {
    setState(localUpdate);
    _formKey.currentState?.setModelValue(prop, value);
  }

  Future<void> _submit() async {
    final valid = await _formKey.currentState?.validate() ?? false;
    if (!mounted) return;
    setState(() => _submitStatus = valid ? '校验通过' : '校验失败');
    UPToast.show(context, message: valid ? '校验通过' : '校验失败');
  }

  void _reset() {
    _formKey.currentState?.resetFields();
    _formKey.currentState?.clearValidate();
    _codeController.reset();
    final defaults = _initialModel();
    for (final entry in <String, dynamic>{
      'userInfo.name': '楼兰',
      'userInfo.sex': '',
      'userInfo.age': '0',
      'radiovalue1': '苹果',
      'checkboxValue1': <dynamic>[],
      'intro': '',
      'hotel': '',
      'code': '',
      'userInfo.birthday': '',
    }.entries) {
      _formKey.currentState?.setModelValue(entry.key, entry.value);
    }
    setState(() {
      _model = defaults;
      _name = '楼兰';
      _sex = '';
      _age = '0';
      _fruit = '苹果';
      _hobbies = <dynamic>[];
      _intro = '';
      _hotel = '';
      _code = '';
      _birthday = '';
      _codeText = '';
      _submitStatus = '已重置';
    });
  }

  void _selectSex(dynamic item, int _) {
    final name = item is Map ? '${item['name'] ?? ''}' : '$item';
    _setField('userInfo.sex', name, () {
      _sex = name;
      _showSex = false;
    });
  }

  void _confirmHotel(List<DateTime> dates) {
    if (dates.isEmpty) return;
    final first = _formatDate(dates.first);
    final last = _formatDate(dates.last);
    _setField('hotel', '$first / $last', () {
      _hotel = '$first / $last';
      _showCalendar = false;
    });
  }

  void _confirmBirthday(dynamic payload) {
    final value = payload is Map ? payload['value'] : payload;
    final milliseconds = value is int ? value : int.tryParse('$value');
    if (milliseconds == null) return;
    final formatted = _formatDate(
      DateTime.fromMillisecondsSinceEpoch(milliseconds),
    );
    _setField('userInfo.birthday', formatted, () {
      _birthday = formatted;
      _showBirthday = false;
    });
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  void _getCode() {
    if (!_codeController.canGetCode) {
      UPToast.show(context, message: '倒计时结束后再发送');
      return;
    }
    UPToast.show(context, message: '验证码已发送');
    _codeController.start();
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '表单',
      scrollable: false,
      child: Stack(
        children: <Widget>[
          ListView(
            key: const ValueKey('example-page-componentsC/form/form'),
            padding: const EdgeInsets.only(bottom: 24),
            children: <Widget>[
              ExampleDemoBlock(
                title: '基础使用',
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      UPForm(
                        key: _formKey,
                        labelPosition: 'left',
                        labelWidth: 80,
                        model: _model,
                        rules: _rules,
                        children: <Widget>[
                          UPFormItem(
                            label: '姓名',
                            prop: 'userInfo.name',
                            child: UPInput(
                              value: _name,
                              border: 'none',
                              placeholder: '姓名,只能为中文',
                              onUpdateValue: (value) => _setField(
                                'userInfo.name',
                                value,
                                () => _name = value,
                              ),
                            ),
                          ),
                          UPFormItem(
                            key: const ValueKey('form-page-sex-trigger'),
                            label: '性别',
                            prop: 'userInfo.sex',
                            rightIcon: 'arrow-right',
                            onClick: () => setState(() => _showSex = true),
                            child: UPInput(
                              value: _sex,
                              disabled: true,
                              border: 'none',
                              placeholder: '请选择性别',
                            ),
                          ),
                          UPFormItem(
                            label: '年龄',
                            prop: 'userInfo.age',
                            child: UPInput(
                              value: _age,
                              type: 'number',
                              clearable: true,
                              placeholder: '请输入内容',
                              onUpdateValue: (value) => _setField(
                                'userInfo.age',
                                value,
                                () => _age = value,
                              ),
                            ),
                          ),
                          UPFormItem(
                            label: '水果',
                            prop: 'radiovalue1',
                            child: UPRadioGroup(
                              value: _fruit,
                              onUpdateValue: (value) => _setField(
                                'radiovalue1',
                                value,
                                () => _fruit = '$value',
                              ),
                              children: const <Widget>[
                                UPRadio(name: '苹果', label: '苹果'),
                                UPRadio(name: '香蕉', label: '香蕉'),
                                UPRadio(name: '毒橙子', label: '毒橙子'),
                              ],
                            ),
                          ),
                          UPFormItem(
                            label: '兴趣爱好',
                            prop: 'checkboxValue1',
                            labelWidth: 80,
                            child: UPCheckboxGroup(
                              value: _hobbies,
                              shape: 'square',
                              onUpdateValue: (value) => _setField(
                                'checkboxValue1',
                                value,
                                () => _hobbies = List<dynamic>.from(value),
                              ),
                              children: const <Widget>[
                                UPCheckbox(name: '羽毛球', label: '羽毛球'),
                                UPCheckbox(name: '跑步', label: '跑步'),
                                UPCheckbox(name: '爬山', label: '爬山'),
                              ],
                            ),
                          ),
                          UPFormItem(
                            label: '简介',
                            prop: 'intro',
                            child: UPTextarea(
                              value: _intro,
                              placeholder: '不低于3个字',
                              count: true,
                              onUpdateValue: (value) => _setField(
                                'intro',
                                value,
                                () => _intro = value,
                              ),
                            ),
                          ),
                          UPFormItem(
                            label: '住店时间',
                            prop: 'hotel',
                            labelWidth: 80,
                            rightIcon: 'arrow-right',
                            onClick: () => setState(() => _showCalendar = true),
                            child: UPInput(
                              value: _hotel,
                              disabled: true,
                              border: 'none',
                              placeholder: '请选择住店和离店时间',
                            ),
                          ),
                          UPFormItem(
                            label: '验证码',
                            prop: 'code',
                            labelWidth: 80,
                            rightSlot: SizedBox(
                              width: 118,
                              child: UPButton(
                                text: _codeText.isEmpty ? '获取验证码' : _codeText,
                                type: 'success',
                                size: 'mini',
                                disabled: !_codeController.canGetCode,
                                onClick: _getCode,
                              ),
                            ),
                            child: UPInput(
                              value: _code,
                              border: 'none',
                              placeholder: '请填写验证码',
                              onUpdateValue: (value) => _setField(
                                'code',
                                value,
                                () => _code = value,
                              ),
                            ),
                          ),
                          UPFormItem(
                            label: '生日',
                            prop: 'userInfo.birthday',
                            rightIcon: 'arrow-right',
                            onClick: () => setState(() => _showBirthday = true),
                            child: UPInput(
                              value: _birthday,
                              disabled: true,
                              border: 'none',
                              placeholder: '请选择生日',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('姓名：$_name'),
                      Text('性别：${_sex.isEmpty ? '未选择' : _sex}'),
                      Text('提交状态：$_submitStatus'),
                      const SizedBox(height: 16),
                      UPButton(type: 'primary', text: '提交', onClick: _submit),
                      const SizedBox(height: 10),
                      UPButton(type: 'error', text: '重置', onClick: _reset),
                    ],
                  ),
                ),
              ),
            ],
          ),
          UPActionSheet(
            show: _showSex,
            title: '请选择性别',
            description: '如果选择保密会报错',
            actions: const <Map<String, dynamic>>[
              <String, dynamic>{'name': '男'},
              <String, dynamic>{'name': '女'},
              <String, dynamic>{'name': '保密'},
            ],
            onSelect: _selectSex,
            onClose: () => setState(() => _showSex = false),
            onUpdateShow: (show) {
              if (!show) setState(() => _showSex = false);
            },
          ),
          UPCalendar(
            show: _showCalendar,
            mode: 'range',
            startText: '住店',
            endText: '离店',
            confirmDisabledText: '请选择离店日期',
            onConfirm: _confirmHotel,
            onClose: () => setState(() => _showCalendar = false),
            onUpdateShow: (show) {
              if (!show) setState(() => _showCalendar = false);
            },
          ),
          UPDatetimePicker(
            show: _showBirthday,
            value: DateTime(2000).millisecondsSinceEpoch,
            mode: 'date',
            closeOnClickOverlay: true,
            onConfirm: _confirmBirthday,
            onCancel: () => setState(() => _showBirthday = false),
            onClose: () => setState(() => _showBirthday = false),
          ),
          UPCode(
            controller: _codeController,
            seconds: 20,
            onChange: (text) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _codeText != text) {
                  setState(() => _codeText = text);
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
