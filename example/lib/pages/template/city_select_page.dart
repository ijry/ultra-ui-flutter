import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';
import 'region_data.dart';

/// Port of pages/template/citySelect and its page-local `u-city-select.vue`.
///
/// The picker is not a library component upstream either — it lives beside the
/// demo page, so it is reproduced here as a page-local widget rather than added
/// to `packages/ultra_ui`.
class CitySelectPage extends StatefulWidget {
  const CitySelectPage({super.key});

  @override
  State<CitySelectPage> createState() => _CitySelectPageState();
}

class _CitySelectPageState extends State<CitySelectPage> {
  bool _show = false;
  String _result = '';

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: '城市选择',
      child: Container(
        key: const ValueKey('example-page-template/citySelect/index'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    '演示效果',
                    style: TextStyle(color: tokens.contentColor),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      // Source shows 'Picker值' until a city is chosen.
                      _result.isEmpty ? 'Picker值' : _result,
                      style: TextStyle(color: tokens.mainColor),
                    ),
                  ),
                  UPButton(
                    key: const ValueKey('city-select-page-open'),
                    text: '打开Picker',
                    onClick: () => setState(() => _show = true),
                  ),
                ],
              ),
            ),
            _CitySelect(
              show: _show,
              onClose: () => setState(() => _show = false),
              onCityChange: (province, city, area) => setState(() {
                _show = false;
                // Source joins the three labels with '-'.
                _result = '${province['label']}-${city['label']}-'
                    '${area['label']}';
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Port of the demo's local `u-city-select.vue`: a bottom popup with a tab strip
/// and three cascading columns.
class _CitySelect extends StatefulWidget {
  const _CitySelect({
    required this.show,
    required this.onClose,
    required this.onCityChange,
  });

  final bool show;
  final VoidCallback onClose;
  final void Function(
    Map<String, String> province,
    Map<String, String> city,
    Map<String, String> area,
  ) onCityChange;

  @override
  State<_CitySelect> createState() => _CitySelectState();
}

class _CitySelectState extends State<_CitySelect> {
  int _province = 0;
  int _city = 0;
  int _area = 0;
  bool _chosenProvince = false;
  bool _chosenCity = false;
  bool _chosenArea = false;
  int _tabsIndex = 0;

  /// Source `genTabsList`: one tab per level chosen so far, plus a trailing
  /// "请选择" for the level still to pick.
  List<Map<String, Object>> get _tabsList {
    final list = <Map<String, Object>>[
      <String, Object>{'name': '请选择'},
    ];
    if (_chosenProvince) {
      list[0] = <String, Object>{'name': provinces[_province]['label']!};
      list.add(<String, Object>{'name': '请选择'});
    }
    if (_chosenCity) {
      list[1] = <String, Object>{'name': _citys[_city]['label']!};
      list.add(<String, Object>{'name': '请选择'});
    }
    if (_chosenArea) {
      list[2] = <String, Object>{'name': _areas[_area]['label']!};
    }
    return list;
  }

  List<Map<String, String>> get _citys => citys[_province];

  List<Map<String, String>> get _areas =>
      _chosenProvince && _city < areas[_province].length
          ? areas[_province][_city]
          : const <Map<String, String>>[];

  void _provinceChange(int index) {
    setState(() {
      _chosenProvince = true;
      _chosenCity = false;
      _chosenArea = false;
      _province = index;
      _city = 0;
      _tabsIndex = 1;
    });
  }

  void _cityChange(int index) {
    setState(() {
      _chosenCity = true;
      _chosenArea = false;
      _city = index;
      _tabsIndex = 2;
    });
  }

  void _areaChange(int index) {
    setState(() {
      _chosenArea = true;
      _area = index;
    });
    widget.onCityChange(
      provinces[_province],
      _citys[_city],
      _areas[index],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return UPPopup(
      show: widget.show,
      mode: 'bottom',
      closeable: true,
      safeAreaInsetBottom: true,
      onClose: widget.onClose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          UPTabs(
            list: _tabsList,
            current: _tabsIndex,
            scrollable: true,
            onChange: (index) => setState(() => _tabsIndex = index),
          ),
          // Source `.area-box`: a fixed 800rpx tall three-column strip that
          // slides left as you descend; here the active column is shown instead,
          // which is the same interaction without the horizontal translate.
          SizedBox(
            height: 400,
            child: _column(
              tokens,
              _tabsIndex == 0
                  ? provinces
                  : _tabsIndex == 1
                      ? (_chosenProvince
                          ? _citys
                          : const <Map<String, String>>[])
                      : (_chosenCity ? _areas : const <Map<String, String>>[]),
              selectedIndex: _tabsIndex == 0
                  ? (_chosenProvince ? _province : -1)
                  : _tabsIndex == 1
                      ? (_chosenCity ? _city : -1)
                      : (_chosenArea ? _area : -1),
              onTap: _tabsIndex == 0
                  ? _provinceChange
                  : _tabsIndex == 1
                      ? _cityChange
                      : _areaChange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _column(
    UPThemeTokens tokens,
    List<Map<String, String>> items, {
    required int selectedIndex,
    required ValueChanged<int> onTap,
  }) {
    return Container(
      color: tokens.bgColor,
      padding: const EdgeInsets.all(5),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => UPCell(
          title: '${items[index]['label']}',
          // Source passes `:arrow="false"`, which u-cell's props.js does not
          // declare — a uView 1.x leftover. isLink is the real prop and already
          // defaults false, so no arrow is drawn.
          clickable: true,
          onClick: () => onTap(index),
          // Source marks the chosen row with a check in the right-icon slot.
          rightIconSlot: selectedIndex == index
              ? const UPIcon(name: 'checkbox-mark', size: 17)
              : null,
        ),
      ),
    );
  }
}
