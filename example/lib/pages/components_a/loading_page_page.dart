import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

class LoadingPagePage extends StatefulWidget {
  const LoadingPagePage({super.key});

  @override
  State<LoadingPagePage> createState() => _LoadingPagePageState();
}

class _LoadingPagePageState extends State<LoadingPagePage> {
  static const _LoadingPagePreset _defaultPreset = _LoadingPagePreset();

  Timer? _hideTimer;
  bool _loading = false;
  _LoadingPagePreset _preset = _defaultPreset;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _showPreset(_LoadingPagePreset preset) {
    _hideTimer?.cancel();
    setState(() {
      _preset = _defaultPreset.merge(preset);
      _loading = true;
    });
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '加载页',
      scrollable: false,
      child: Stack(
        children: <Widget>[
          Container(
            key: const ValueKey(
                'example-page-componentsA/loading-page/loading-page'),
            padding: const EdgeInsets.only(top: 20),
            child: UPCellGroup(
              children: <Widget>[
                _LoadingPageCell(
                  title: '自定义提示内容',
                  asset: 'assets/uview/demo/loading-page/promptContent.png',
                  onClick: () => _showPreset(const _LoadingPagePreset(
                    loadingText: 'Hello uview-plus',
                    loadingMode: 'semicircle',
                  )),
                ),
                _LoadingPageCell(
                  title: '自定义图片',
                  asset: 'assets/uview/demo/loading-page/customPicture.png',
                  onClick: () => _showPreset(const _LoadingPagePreset(
                    loadingText: 'uview-plus',
                    image: 'assets/uview/common/logo.png',
                    iconSize: 40,
                  )),
                ),
                _LoadingPageCell(
                  title: '自定义加载动画模式',
                  asset: 'assets/uview/demo/loading-page/customMode.png',
                  onClick: () => _showPreset(const _LoadingPagePreset(
                    loadingText: 'uview-plus',
                    loadingMode: 'circle',
                  )),
                ),
                _LoadingPageCell(
                  title: '自定义背景色',
                  asset: 'assets/uview/demo/loading-page/customBgColor.png',
                  onClick: () => _showPreset(const _LoadingPagePreset(
                    loadingText: 'uview-plus',
                    loadingMode: 'spinner',
                    bgColor: '#4D000000',
                    color: '#eeeeee',
                    loadingColor: '#dddddd',
                  )),
                ),
              ],
            ),
          ),
          if (_loading)
            UPLoadingPage(
              loading: true,
              loadingText: _preset.loadingText,
              image: _preset.image,
              iconSize: _preset.iconSize,
              loadingMode: _preset.loadingMode,
              bgColor: _preset.bgColor,
              color: _preset.color,
              loadingColor: _preset.loadingColor,
            ),
        ],
      ),
    );
  }
}

class _LoadingPagePreset {
  const _LoadingPagePreset({
    this.loadingText = '',
    this.image = '',
    this.loadingMode = '',
    this.bgColor = '',
    this.iconSize = 28,
    this.color = '',
    this.loadingColor = '#C8C8C8',
  });

  final String loadingText;
  final String image;
  final String loadingMode;
  final String bgColor;
  final double iconSize;
  final String color;
  final String loadingColor;

  _LoadingPagePreset merge(_LoadingPagePreset value) => _LoadingPagePreset(
        loadingText: value.loadingText,
        image: value.image,
        loadingMode: value.loadingMode,
        bgColor: value.bgColor,
        iconSize: value.iconSize,
        color: value.color,
        loadingColor: value.loadingColor,
      );
}

class _LoadingPageCell extends StatelessWidget {
  const _LoadingPageCell({
    required this.title,
    required this.asset,
    required this.onClick,
  });

  final String title;
  final String asset;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return UPCell(
      title: title,
      titleStyle: const TextStyle(fontWeight: FontWeight.w500),
      isLink: true,
      clickable: true,
      iconSlot: Image.asset(asset, width: 48, height: 30, fit: BoxFit.contain),
      onClick: onClick,
    );
  }
}
