import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

/// Port of pages/template/address/addSite — the new-address form.
class AddSitePage extends StatefulWidget {
  const AddSitePage({super.key});

  @override
  State<AddSitePage> createState() => _AddSitePageState();
}

class _AddSitePageState extends State<AddSitePage> {
  bool _show = false;
  bool _isDefault = false;
  String _region = '';

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: '新建收货地址',
      child: Container(
        key: const ValueKey('example-page-template/address/addSite'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              color: tokens.cardBgColor,
              child: Column(
                children: <Widget>[
                  _row(tokens, '收货人',
                      const UPInput(placeholder: '请填写收货人姓名', border: 'none')),
                  _row(tokens, '手机号码',
                      const UPInput(placeholder: '请填写收货人手机号', border: 'none')),
                  // Source opens a region picker from this row.
                  GestureDetector(
                    key: const ValueKey('add-site-page-region'),
                    onTap: () => setState(() => _show = true),
                    behavior: HitTestBehavior.opaque,
                    child: _row(
                      tokens,
                      '所在地区',
                      Text(
                        _region.isEmpty ? '省市区县、乡镇等' : _region,
                        style: TextStyle(
                          color: _region.isEmpty
                              ? tokens.tipsColor
                              : tokens.mainColor,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  _row(
                    tokens,
                    '详细地址',
                    const UPTextarea(placeholder: '街道、楼牌等', border: 'none'),
                    alignTop: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              color: tokens.cardBgColor,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 80,
                          child: Text('标签',
                              style: TextStyle(color: tokens.mainColor)),
                        ),
                        for (final tag in const <String>['家', '公司', '学校'])
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: tokens.bgColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: tokens.contentColor,
                                ),
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: tokens.bgColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const UPIcon(name: 'plus', size: 11),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('设置默认地址',
                                  style: TextStyle(color: tokens.mainColor)),
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '提醒：每次下单会默认推荐该地址',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: tokens.tipsColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        UPSwitch(
                          key: const ValueKey('add-site-page-default'),
                          value: _isDefault,
                          activeColor: '#ff0000',
                          onChange: (value) =>
                              setState(() => _isDefault = value == true),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            UPPicker(
              key: const ValueKey('add-site-page-picker'),
              show: _show,
              // Source uses `mode="region"`; UPPicker takes explicit columns, so
              // the region data is supplied here rather than being built in.
              columns: const <List<String>>[
                <String>['广东省', '江苏省'],
                <String>['深圳市', '广州市'],
                <String>['宝安区', '南山区'],
              ],
              onClose: () => setState(() => _show = false),
              onCancel: () => setState(() => _show = false),
              onConfirm: (values, indexes) => setState(() {
                _show = false;
                _region = values.join('-');
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Source `.item`: an 80px label beside the field.
  Widget _row(
    UPThemeTokens tokens,
    String label,
    Widget field, {
    bool alignTop = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        crossAxisAlignment:
            alignTop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: tokens.mainColor)),
          ),
          Expanded(child: field),
        ],
      ),
    );
  }
}
