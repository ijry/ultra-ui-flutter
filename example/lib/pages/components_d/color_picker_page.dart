import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

const List<String> _commonColors = <String>[
  '#ff0000',
  '#00ff00',
  '#0000ff',
  '#ffff00',
  '#00ffff',
  '#ff00ff',
  '#ffffff',
  '#000000',
];

class ColorPickerPage extends StatefulWidget {
  const ColorPickerPage({super.key});

  @override
  State<ColorPickerPage> createState() => _ColorPickerPageState();
}

class _ColorPickerPageState extends State<ColorPickerPage> {
  String _selectedColor = '#ff0000';
  String _selectedColor2 = '#00ff00';

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: '颜色选择器',
      child: Container(
        key: const ValueKey('example-page-componentsD/colorPicker/colorPicker'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '颜色选择器示例',
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    UPColorPicker(
                      key: const ValueKey('color-picker-page-basic'),
                      modelValue: _selectedColor,
                      onConfirm: (color) =>
                          setState(() => _selectedColor = color),
                      // Source default slot: the tappable preview swatch.
                      child: _preview(_selectedColor, tokens),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        '点击上方色块选择颜色',
                        style: TextStyle(color: tokens.tipsColor, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '带常用颜色的示例',
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    UPColorPicker(
                      key: const ValueKey('color-picker-page-common'),
                      modelValue: _selectedColor2,
                      commonColors: _commonColors,
                      onConfirm: (color) =>
                          setState(() => _selectedColor2 = color),
                      child: _preview(_selectedColor2, tokens),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        '包含常用颜色选项',
                        style: TextStyle(color: tokens.tipsColor, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Source preview row: a 80rpx swatch plus the hex string.
  Widget _preview(String color, UPThemeTokens tokens) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: tokens.bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: UPUtils.parseColor(color) ?? const Color(0xFFFF0000),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: tokens.borderColor),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              color,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: tokens.contentColor, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
