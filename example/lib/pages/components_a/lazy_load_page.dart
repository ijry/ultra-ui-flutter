import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

class LazyLoadPage extends StatefulWidget {
  const LazyLoadPage({super.key});

  @override
  State<LazyLoadPage> createState() => _LazyLoadPageState();
}

class _LazyLoadPageState extends State<LazyLoadPage> {
  static const List<String> _sourceImages = <String>[
    'assets/uview/swiper/swiper1.png',
    'assets/uview/swiper/swiper2.png',
    'assets/uview/swiper/swiper3.png',
    'assets/uview/swiper/swiper1.png',
    'assets/uview/swiper/swiper2.png',
    'assets/uview/swiper/swiper3.png',
    'assets/uview/swiper/swiper1.png',
    'assets/uview/swiper/swiper2.png',
    'assets/uview/swiper/swiper3.png',
  ];

  List<String> _images = _sourceImages.take(3).toList();

  void _loadMore() {
    final nextEnd = (_images.length + 3).clamp(0, _sourceImages.length);
    setState(() {
      _images = <String>[
        ..._images,
        ..._sourceImages.sublist(_images.length, nextEnd)
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final exhausted = _images.length == _sourceImages.length;
    return ExamplePageScaffold(
      title: '懒加载',
      child: Container(
        key: const ValueKey('example-page-componentsA/lazyLoad/lazyLoad'),
        padding: const EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            for (var index = 0; index < _images.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: UPLazyLoad(
                  index: index,
                  image: _images[index],
                  threshold: -450,
                  height: '100px',
                  imgMode: 'aspectFill',
                  borderRadius: 10,
                ),
              ),
            UPLoadmore(
              status: exhausted ? 'nomore' : 'loadmore',
              onLoadmore: _loadMore,
            ),
          ],
        ),
      ),
    );
  }
}
