import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

const List<List<Map<String, String>>> _cityGroups = <List<Map<String, String>>>[
  <Map<String, String>>[
    <String, String>{'name': '北京', 'value': 'beijing'},
    <String, String>{'name': '上海', 'value': 'shanghai'},
    <String, String>{'name': '广州', 'value': 'guangzhou'},
  ],
  <Map<String, String>>[
    <String, String>{'name': '北京', 'value': 'beijing'},
    <String, String>{'name': '上海', 'value': 'shanghai'},
    <String, String>{'name': '广州', 'value': 'guangzhou'},
    <String, String>{'name': '深圳', 'value': 'shenzhen'},
    <String, String>{'name': '杭州', 'value': 'hangzhou'},
  ],
];

class CityLocatePage extends StatefulWidget {
  const CityLocatePage({super.key});

  @override
  State<CityLocatePage> createState() => _CityLocatePageState();
}

class _CityLocatePageState extends State<CityLocatePage> {
  String _currentCity = '';
  String _selectedCity = '未选择';

  Future<Map?> _resolveLocation(String locationType) async {
    return <String, dynamic>{
      'locationType': locationType,
      'locationCity': '南京',
    };
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '城市定位',
      child: Container(
        key: const ValueKey('example-page-componentsD/cityLocate/cityLocate'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '基础用法',
              child: SizedBox(
                height: 420,
                child: UPCityLocate(
                  key: const ValueKey('city-locate-page-basic'),
                  indexList: const <String>['🔥', '所有城市'],
                  cityList: _cityGroups,
                  currentCity: _currentCity,
                  locationHandler: _resolveLocation,
                  onLocationSuccess: (result) {
                    final city = '${result['locationCity'] ?? '南京'}';
                    if (mounted) setState(() => _currentCity = city);
                  },
                  onSelectCity: (result) {
                    final city = '${result['locationCity'] ?? ''}';
                    if (mounted) setState(() => _selectedCity = city);
                  },
                ),
              ),
            ),
            Padding(
              key: const ValueKey('city-locate-page-selection'),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('当前定位：$_currentCity'),
                  const SizedBox(height: 8),
                  Text('已选择：$_selectedCity'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
