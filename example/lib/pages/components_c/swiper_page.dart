import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class SwiperPage extends StatefulWidget {
  const SwiperPage({super.key});

  @override
  State<SwiperPage> createState() => _SwiperPageState();
}

class _SwiperPageState extends State<SwiperPage> {
  int _current = 0;
  int _clicks = 0;
  int _customCurrent = 0;

  void _onChange(int index) {
    if (!mounted) return;
    setState(() => _current = index);
  }

  void _onCustomChange(int index) {
    if (!mounted) return;
    setState(() => _customCurrent = index);
  }

  void _onClick(int index) {
    if (!mounted) return;
    setState(() => _clicks += 1);
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      key: const ValueKey('example-page-componentsC/swiper/swiper'),
      title: '轮播',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ExampleDemoBlock(
            title: '基础功能',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                UPSwiper(
                  key: const ValueKey('swiper-page-basic'),
                  list: _swiperImages,
                  autoplay: false,
                  onChange: _onChange,
                  onClick: _onClick,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                  child: Text('当前索引：$_current'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Text('点击次数：$_clicks'),
                ),
              ],
            ),
          ),
          const ExampleDemoBlock(
            title: '纵向滑动',
            child: UPSwiper(
              key: ValueKey('swiper-page-vertical'),
              list: _swiperImages,
              vertical: true,
              indicator: true,
              indicatorMode: 'dot',
              autoplay: false,
              height: 200,
            ),
          ),
          const ExampleDemoBlock(
            title: '带标题',
            child: UPSwiper(
              key: ValueKey('swiper-page-title'),
              list: _swiperTitles,
              keyName: 'image',
              showTitle: true,
              autoplay: false,
              circular: true,
            ),
          ),
          const ExampleDemoBlock(
            title: '带指示器',
            child: UPSwiper(
              key: ValueKey('swiper-page-indicator'),
              list: _swiperImages,
              indicator: true,
              circular: true,
              autoplay: false,
            ),
          ),
          const ExampleDemoBlock(
            title: '加载中',
            child: UPSwiper(
              key: ValueKey('swiper-page-loading'),
              list: _swiperImages,
              loading: true,
              autoplay: false,
            ),
          ),
          const ExampleDemoBlock(
            title: '嵌入视频',
            child: UPSwiper(
              key: ValueKey('swiper-page-video'),
              list: _swiperVideos,
              keyName: 'url',
              autoplay: false,
            ),
          ),
          const ExampleDemoBlock(
            title: '自定义内容',
            child: UPSwiper(
              key: ValueKey('swiper-page-custom'),
              list: _swiperTitles,
              keyName: 'image',
              showTitle: true,
              autoplay: false,
              circular: true,
              itemBuilder: _customItemBuilder,
            ),
          ),
          ExampleDemoBlock(
            title: '自定义指示器',
            child: Column(
              children: <Widget>[
                UPSwiper(
                  key: const ValueKey('swiper-page-custom-indicator'),
                  list: _swiperImages,
                  autoplay: false,
                  onChange: _onCustomChange,
                  indicatorSlot: Container(
                    key: const ValueKey('swiper-page-custom-indicator-slot'),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0x59000000),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: UPSwiperIndicator(
                      length: _swiperImages.length,
                      current: _customCurrent,
                      indicatorMode: 'dot',
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                UPSwiper(
                  list: _swiperImages,
                  autoplay: false,
                  indicatorStyle: const <String, dynamic>{'right': 20},
                  indicatorSlot: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x59000000),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_customCurrent + 1}/${_swiperImages.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const ExampleDemoBlock(
            title: '卡片式',
            child: UPSwiper(
              key: ValueKey('swiper-page-card'),
              list: _swiperImages,
              previousMargin: 30,
              nextMargin: 30,
              circular: true,
              autoplay: false,
              radius: 5,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _customItemBuilder(BuildContext context, dynamic item, int index) {
  final image = item is Map ? '${item['image'] ?? ''}' : '';
  return Image.asset(
    image,
    fit: BoxFit.cover,
    width: double.infinity,
    height: double.infinity,
  );
}

const List<String> _swiperImages = <String>[
  'assets/uview/swiper/swiper1.png',
  'assets/uview/swiper/swiper2.png',
  'assets/uview/swiper/swiper3.png',
];

const List<Map<String, dynamic>> _swiperTitles = <Map<String, dynamic>>[
  <String, dynamic>{
    'image': 'assets/uview/swiper/swiper2.png',
    'title': '昨夜星辰昨夜风，画楼西畔桂堂东',
    'type': 'image',
  },
  <String, dynamic>{
    'image': 'assets/uview/swiper/swiper1.png',
    'title': '身无彩凤双飞翼，心有灵犀一点通',
  },
  <String, dynamic>{
    'image': 'assets/uview/swiper/swiper3.png',
    'title': '谁念西风独自凉，萧萧黄叶闭疏窗，沉思往事立残阳',
  },
];

const List<Map<String, dynamic>> _swiperVideos = <Map<String, dynamic>>[
  <String, dynamic>{
    'url': 'assets/uview/swiper/swiper1.png',
    'poster': 'assets/uview/swiper/swiper1.png',
    'type': 'video',
    'title': '昨夜星辰昨夜风，画楼西畔桂堂东',
  },
  <String, dynamic>{
    'url': 'assets/uview/swiper/swiper2.png',
    'type': 'image',
    'title': '身无彩凤双飞翼，心有灵犀一点通',
  },
  <String, dynamic>{
    'url': 'assets/uview/swiper/swiper3.png',
    'type': 'image',
    'title': '谁念西风独自凉，萧萧黄叶闭疏窗，沉思往事立残阳',
  },
];
