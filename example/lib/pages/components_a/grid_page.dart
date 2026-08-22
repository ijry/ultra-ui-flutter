import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class GridPage extends StatelessWidget {
  const GridPage({super.key});

  static const List<String> _icons = <String>[
    'photo',
    'lock',
    'star',
    'hourglass',
    'home',
    'volume',
    'gift',
    'scan',
  ];

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '宫格',
      child: Container(
        key: const ValueKey('example-page-componentsA/grid/grid'),
        child: Column(
          children: <Widget>[
            _GridBlock('基本案例', _grid(context, border: false)),
            _GridBlock('显示边框', _grid(context, border: true)),
            _GridBlock('绑定点击事件&自定义列数', _grid(context, border: false, col: 4)),
            _GridBlock('自定义图标大小', _grid(context, border: true, iconSize: 30)),
            _GridBlock('正方形宫格', _grid(context, border: true, square: true)),
            // Source's 可滑动 demo: two swiper pages, each a bordered 9-cell grid
            // over its own icon list, with the second page's indices offset by 9.
            _GridBlock(
              '可滑动',
              SizedBox(
                height: 210,
                child: UPSwiper(
                  key: const ValueKey('grid-page-swiper'),
                  list: const <int>[0, 9],
                  autoplay: false,
                  indicator: true,
                  height: 210,
                  itemBuilder: (context, item, index) =>
                      _swiperGrid(context, offset: item is int ? item : 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Source `swiperList`: a separate icon set for the 可滑动 demo.
  static const List<String> _swiperIcons = <String>[
    'integral',
    'kefu-ermai',
    'coupon',
    'gift',
    'scan',
    'pause-circle',
    'wifi',
    'email',
    'list',
  ];

  /// One swiper page of the 可滑动 demo. [offset] is the source's index shift so
  /// the second page reports 10..18 rather than repeating 1..9.
  Widget _swiperGrid(BuildContext context, {required int offset}) {
    return UPGrid(
      border: true,
      col: 3,
      align: 'center',
      children: List<Widget>.generate(_swiperIcons.length, (index) {
        final number = offset + index + 1;
        return UPGridItem(
          name: number,
          onClick: (_) => UPToast.show(context, message: '点击了第$number个'),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 10),
              UPIcon(name: _swiperIcons[index], size: 22),
              const SizedBox(height: 8),
              Text('宫格$number',
                  style: const TextStyle(color: Color(0xFF909399))),
            ],
          ),
        );
      }),
    );
  }

  Widget _grid(
    BuildContext context, {
    required bool border,
    int col = 3,
    double iconSize = 22,
    bool square = false,
  }) {
    return UPGrid(
      border: border,
      col: col,
      align: 'center',
      children: List<Widget>.generate(_icons.length, (index) {
        final number = index + 1;
        return UPGridItem(
          name: number,
          onClick: (_) => UPToast.show(context, message: '点击了宫格$number'),
          child: AspectRatio(
            aspectRatio: square ? 1 : 1.35,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                UPIcon(name: _icons[index], size: iconSize),
                const SizedBox(height: 8),
                Text('宫格$number',
                    style: const TextStyle(color: Color(0xFF909399))),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _GridBlock extends StatelessWidget {
  const _GridBlock(this.title, this.grid);

  final String title;
  final Widget grid;

  @override
  Widget build(BuildContext context) {
    return ExampleDemoBlock(title: title, child: grid);
  }
}
