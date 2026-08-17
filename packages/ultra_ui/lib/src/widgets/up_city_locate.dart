import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import 'up_index_list.dart';

/// Port of u-city-locate / up-city-locate.
class UPCityLocate extends StatefulWidget {
  const UPCityLocate({
    super.key,
    this.indexList = const ['🔥'],
    this.cityList = const [
      [
        {'name': '北京', 'value': 'beijing'},
        {'name': '上海', 'value': 'shanghai'},
        {'name': '广州', 'value': 'guangzhou'},
        {'name': '深圳', 'value': 'shenzhen'},
        {'name': '杭州', 'value': 'hangzhou'},
      ]
    ],
    this.locationType = 'wgs84',
    this.currentCity = '',
    this.nameKey = 'name',
    this.autoLocate = true,
    this.onLocationSuccess,
    this.onLocationFail,
    this.onSelectCity,
    this.onUpdateCurrent,
    this.onUpdateModelValue,
    this.onUpdateCurrentCity,
    this.locationHandler,
    this.customStyle,
  });

  final List indexList;
  final List cityList;
  final String locationType;
  final String currentCity;
  final String nameKey;

  /// Source mounts and auto-calls uni.getLocation. Keep true by default.
  final bool autoLocate;
  final ValueChanged<Map>? onLocationSuccess;
  final ValueChanged<Map>? onLocationFail;
  final ValueChanged<Map>? onSelectCity;

  /// Source update:currentCity / current alias.
  final ValueChanged<String>? onUpdateCurrent;

  /// Source-compatible modelValue alias for current city.
  final ValueChanged<String>? onUpdateModelValue;

  /// Source update:currentCity alias.
  final ValueChanged<String>? onUpdateCurrentCity;

  /// Host inject: resolve current location. Return map with locationCity.
  final Future<Map?> Function(String locationType)? locationHandler;

  final BoxDecoration? customStyle;
  @override
  State<UPCityLocate> createState() => UPCityLocateState();
}

class UPCityLocateState extends State<UPCityLocate> {
  late String locationCity;
  bool locating = false;

  /// Source-compatible current city text.
  String get currentCity => locationCity;
  bool get isLocating => locating;

  /// Source location result helpers (Batch J).
  void success([dynamic payload]) {
    if (payload is Map && payload['city'] != null) {
      setCurrentCity('${payload['city']}');
    } else if (payload != null && '$payload'.isNotEmpty) {
      setCurrentCity('$payload');
    }
  }

  dynamic lastFail;
  void fail([dynamic payload]) {
    lastFail = payload ?? true;
    if (!mounted) {
      locationCity = '定位失败';
      locating = false;
      return;
    }
    setState(() {
      locationCity = '定位失败';
      locating = false;
    });
    widget.onLocationFail?.call({
      'locationType': widget.locationType,
      'locationCity': locationCity,
      if (payload is Map) ...Map<String, dynamic>.from(payload),
      if (payload != null && payload is! Map) 'error': payload,
    });
  }

  void setCurrentCity(String city) {
    setState(() => locationCity = city);
    widget.onUpdateCurrent?.call(city);
    widget.onUpdateModelValue?.call(city);
    widget.onUpdateCurrentCity?.call(city);
  }

  @override
  void initState() {
    super.initState();
    locationCity = widget.currentCity.isEmpty ? '定位中....' : widget.currentCity;
    if (widget.autoLocate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) location();
      });
    }
  }

  @override
  void didUpdateWidget(covariant UPCityLocate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentCity != widget.currentCity &&
        widget.currentCity.isNotEmpty) {
      locationCity = widget.currentCity;
    }
  }

  String _nameOf(dynamic city) {
    if (city is Map) return '${city[widget.nameKey] ?? city['name'] ?? ''}';
    return '$city';
  }

  void selectedCity(dynamic city) {
    final name = _nameOf(city);
    setState(() => locationCity = name);
    widget.onSelectCity?.call({
      'locationCity': name,
      'city': city,
    });
  }

  /// Source method alias.
  Future<void> location() => _locate();

  Future<void> _locate() async {
    if (locating) return;
    setState(() {
      locating = true;
      locationCity = '定位中....';
    });
    try {
      Map? res;
      if (widget.locationHandler != null) {
        res = await widget.locationHandler!(widget.locationType);
      } else if (widget.currentCity.isNotEmpty) {
        res = {
          'locationType': widget.locationType,
          'locationCity': widget.currentCity,
        };
      }
      if (!mounted) return;
      if (res == null) {
        setState(() {
          locationCity = '定位失败';
          locating = false;
        });
        widget.onLocationFail?.call({
          'locationType': widget.locationType,
          'locationCity': locationCity,
        });
        return;
      }
      final city =
          '${res['locationCity'] ?? res['city'] ?? widget.currentCity}';
      setState(() {
        locationCity = city.isEmpty ? '定位成功' : city;
        locating = false;
      });
      widget.onLocationSuccess?.call({
        ...res,
        'locationType': widget.locationType,
        'locationCity': locationCity,
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        locationCity = '定位失败';
        locating = false;
      });
      widget.onLocationFail?.call({
        'locationType': widget.locationType,
        'locationCity': locationCity,
      });
    }
  }

  Widget _hotChip(String text, {required VoidCallback onTap, Color? color}) {
    final tokens = UPThemeTokens.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: tokens.cardBgColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: tokens.borderColor),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color ?? tokens.mainColor,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final letters = <String>[];
    final children = <UPIndexItem>[];

    for (var i = 0; i < widget.cityList.length; i++) {
      final group = widget.cityList[i];
      if (group is! List) continue;
      final letter = i < widget.indexList.length
          ? '${widget.indexList[i]}'
          : String.fromCharCode(65 + ((i - 1).clamp(0, 25)));
      letters.add(letter);
      if (i == 0) {
        children.add(
          UPIndexItem(
            anchor: UPIndexAnchor(text: letter),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Text(
                  '当前定位城市',
                  style: TextStyle(color: tokens.tipsColor, fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(7, 4, 7, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _hotChip(
                    locationCity,
                    color: tokens.primary,
                    onTap: () {
                      location();
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(7, 4, 7, 8),
                child: Wrap(
                  children: [
                    for (final c in group)
                      _hotChip(_nameOf(c), onTap: () => selectedCity(c)),
                  ],
                ),
              ),
            ],
          ),
        );
      } else {
        children.add(
          UPIndexItem(
            anchor: UPIndexAnchor(text: letter),
            children: [
              for (final c in group)
                ListTile(
                  dense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  title: Text(
                    _nameOf(c),
                    style: TextStyle(color: tokens.mainColor, fontSize: 14),
                  ),
                  onTap: () => selectedCity(c),
                ),
            ],
          ),
        );
      }
    }

    Widget root = UPIndexList(
      indexList: letters,
      children: children,
      header: null,
      footer: const SizedBox(height: 24),
    );
    return root;
  }
}
