import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

class ColorPage extends StatelessWidget {
  const ColorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '色彩',
      child: Container(
        key: const ValueKey('example-page-componentsB/color/color'),
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final section in _sections) _ColorSectionView(section),
          ],
        ),
      ),
    );
  }
}

class _ColorSectionView extends StatelessWidget {
  const _ColorSectionView(this.section);

  final _ColorSection section;

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return Padding(
      padding: EdgeInsets.only(top: section == _sections.first ? 0 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              section.title,
              style: TextStyle(
                color: tokens.contentColor,
                fontSize: 15,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 8.0;
              final width = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : MediaQuery.sizeOf(context).width - 30;
              final itemWidth = (width - gap * 3) / 4;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: <Widget>[
                  for (final swatch in section.swatches)
                    SizedBox(
                      width: itemWidth,
                      child: _ColorSwatch(swatch),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch(this.swatch);

  final _ColorSwatchData swatch;

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final textColor = swatch.darkText ? tokens.tipsColor : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: swatch.color,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            swatch.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
            ),
          ),
          Text(
            swatch.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorSection {
  const _ColorSection({required this.title, required this.swatches});

  final String title;
  final List<_ColorSwatchData> swatches;
}

class _ColorSwatchData {
  const _ColorSwatchData({
    required this.label,
    required this.value,
    required this.color,
    this.darkText = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool darkText;
}

const List<_ColorSection> _sections = <_ColorSection>[
  _ColorSection(
    title: '主色调',
    swatches: <_ColorSwatchData>[
      _ColorSwatchData(
        label: 'Primary',
        value: '#3c9cff',
        color: Color(0xFF3C9CFF),
      ),
      _ColorSwatchData(
        label: 'Dark',
        value: '#398ade',
        color: Color(0xFF398ADE),
      ),
      _ColorSwatchData(
        label: 'Disabled',
        value: '#9acafc',
        color: Color(0xFF9ACAFC),
      ),
      _ColorSwatchData(
        label: 'Light',
        value: '#ecf5ff',
        color: Color(0xFFECF5FF),
        darkText: true,
      ),
    ],
  ),
  _ColorSection(
    title: 'Error',
    swatches: <_ColorSwatchData>[
      _ColorSwatchData(
        label: 'Error',
        value: '#f56c6c',
        color: Color(0xFFF56C6C),
      ),
      _ColorSwatchData(
        label: 'Dark',
        value: '#e45656',
        color: Color(0xFFE45656),
      ),
      _ColorSwatchData(
        label: 'Disabled',
        value: '#f7b2b2',
        color: Color(0xFFF7B2B2),
      ),
      _ColorSwatchData(
        label: 'Light',
        value: '#fef0f0',
        color: Color(0xFFFEF0F0),
        darkText: true,
      ),
    ],
  ),
  _ColorSection(
    title: 'Warning',
    swatches: <_ColorSwatchData>[
      _ColorSwatchData(
        label: 'Warning',
        value: '#f9ae3d',
        color: Color(0xFFF9AE3D),
      ),
      _ColorSwatchData(
        label: 'Dark',
        value: '#f1a532',
        color: Color(0xFFF1A532),
      ),
      _ColorSwatchData(
        label: 'Disabled',
        value: '#f9d39b',
        color: Color(0xFFF9D39B),
      ),
      _ColorSwatchData(
        label: 'Light',
        value: '#fdf6ec',
        color: Color(0xFFFDF6EC),
        darkText: true,
      ),
    ],
  ),
  _ColorSection(
    title: 'Info',
    swatches: <_ColorSwatchData>[
      _ColorSwatchData(
        label: 'Info',
        value: '#909399',
        color: Color(0xFF909399),
      ),
      _ColorSwatchData(
        label: 'Dark',
        value: '#767a82',
        color: Color(0xFF767A82),
      ),
      _ColorSwatchData(
        label: 'Disabled',
        value: '#c4c6c9',
        color: Color(0xFFC4C6C9),
      ),
      _ColorSwatchData(
        label: 'Light',
        value: '#f4f4f5',
        color: Color(0xFFF4F4F5),
        darkText: true,
      ),
    ],
  ),
  _ColorSection(
    title: 'Success',
    swatches: <_ColorSwatchData>[
      _ColorSwatchData(
        label: 'Success',
        value: '#5ac725',
        color: Color(0xFF5AC725),
      ),
      _ColorSwatchData(
        label: 'Dark',
        value: '#53c21d',
        color: Color(0xFF53C21D),
      ),
      _ColorSwatchData(
        label: 'Disabled',
        value: '#a9e08f',
        color: Color(0xFFA9E08F),
      ),
      _ColorSwatchData(
        label: 'Light',
        value: '#f5fff0',
        color: Color(0xFFF5FFF0),
        darkText: true,
      ),
    ],
  ),
  _ColorSection(
    title: '文字颜色',
    swatches: <_ColorSwatchData>[
      _ColorSwatchData(
        label: '主要文字',
        value: '#303133',
        color: Color(0xFF303133),
      ),
      _ColorSwatchData(
        label: '常规文字',
        value: '#606266',
        color: Color(0xFF606266),
      ),
      _ColorSwatchData(
        label: '次要文字',
        value: '#909399',
        color: Color(0xFF909399),
      ),
      _ColorSwatchData(
        label: '占位文字',
        value: '#c0c4cc',
        color: Color(0xFFC0C4CC),
      ),
    ],
  ),
  _ColorSection(
    title: '边框颜色',
    swatches: <_ColorSwatchData>[
      _ColorSwatchData(
        label: '一级边框',
        value: '#9a9998',
        color: Color(0xFF9A9998),
      ),
      _ColorSwatchData(
        label: '二级边框',
        value: '#b4b3b1',
        color: Color(0xFFB4B3B1),
      ),
      _ColorSwatchData(
        label: '三级边框',
        value: '#ceccca',
        color: Color(0xFFCECCCA),
      ),
      _ColorSwatchData(
        label: '四级边框',
        value: '#e7e6e4',
        color: Color(0xFFE7E6E4),
        darkText: true,
      ),
    ],
  ),
  _ColorSection(
    title: '背景颜色',
    swatches: <_ColorSwatchData>[
      _ColorSwatchData(
        label: '背景颜色',
        value: '#f3f4f6',
        color: Color(0xFFF3F4F6),
        darkText: true,
      ),
    ],
  ),
];
