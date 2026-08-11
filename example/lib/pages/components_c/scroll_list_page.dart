import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class ScrollListPage extends StatefulWidget {
  const ScrollListPage({super.key});

  @override
  State<ScrollListPage> createState() => _ScrollListPageState();
}

class _ScrollListPageState extends State<ScrollListPage> {
  int _moreCount = 0;
  int _leftCount = 0;
  int _rightCount = 0;

  void _showMore() {
    if (!mounted) return;
    setState(() => _moreCount += 1);
  }

  void _onLeft() {
    if (!mounted) return;
    setState(() => _leftCount += 1);
  }

  void _onRight() {
    if (!mounted) return;
    setState(() => _rightCount += 1);
  }

  @override
  Widget build(BuildContext context) {
    final goodsChildren = <Widget>[
      for (var i = 0; i < _goods.length; i++) _goodsCard(_goods[i]),
      _moreCard(),
    ];

    return ExamplePageScaffold(
      key: const ValueKey('example-page-componentsC/scrollList/scrollList'),
      title: '横向滚动列表',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ExampleDemoBlock(
            title: '基础使用',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                UPScrollList(
                  key: const ValueKey('scroll-list-page-basic'),
                  indicatorColor: '#fff0f0',
                  indicatorActiveColor: '#f56c6c',
                  onLeft: _onLeft,
                  onRight: _onRight,
                  children: goodsChildren,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                  child: Text('查看更多次数：$_moreCount'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                  child: Text('左侧触发次数：$_leftCount'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Text('右侧触发次数：$_rightCount'),
                ),
              ],
            ),
          ),
          ExampleDemoBlock(
            title: '多菜单扩展',
            child: UPScrollList(
              key: const ValueKey('scroll-list-page-menu'),
              children: <Widget>[
                for (final row in _menuRows)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        for (final item in row) _menuCard(item),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _goodsCard(_Goods item) {
    return Container(
      width: 82,
      margin: const EdgeInsets.only(right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              item.image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '￥${item.price}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xfff56c6c),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _moreCard() {
    return GestureDetector(
      key: const ValueKey('scroll-list-page-more'),
      onTap: _showMore,
      child: Container(
        width: 40,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xfffff0f0),
          borderRadius: BorderRadius.circular(3),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '查看更多',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xfff56c6c),
                fontSize: 12,
                height: 1.35,
              ),
            ),
            UPIcon(
              name: 'arrow-leftward',
              color: Color(0xfff56c6c),
              size: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(_MenuItem item) {
    return Container(
      width: 76,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset(
            item.image,
            width: 61,
            height: 48,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 5),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xff606266),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _Goods {
  const _Goods(this.price, this.image);

  final String price;
  final String image;
}

class _MenuItem {
  const _MenuItem(this.name, this.image);

  final String name;
  final String image;
}

const _image1 = 'assets/uview/swiper/swiper1.png';
const _image2 = 'assets/uview/swiper/swiper2.png';
const _image3 = 'assets/uview/swiper/swiper3.png';

const List<_Goods> _goods = <_Goods>[
  _Goods('230.5', _image1),
  _Goods('74.1', _image2),
  _Goods('8457', _image3),
  _Goods('1442', _image1),
  _Goods('541', _image2),
  _Goods('234', _image3),
  _Goods('562', _image1),
  _Goods('251.5', _image2),
];

const List<List<_MenuItem>> _menuRows = <List<_MenuItem>>[
  <_MenuItem>[
    _MenuItem('天猫新品', _image1),
    _MenuItem('今日爆款', _image2),
    _MenuItem('天猫国际', _image3),
    _MenuItem('饿了么', _image1),
    _MenuItem('天猫超市', _image2),
    _MenuItem('分类', _image3),
    _MenuItem('天猫美食', _image1),
    _MenuItem('阿里健康', _image2),
    _MenuItem('口碑生活', _image3),
  ],
  <_MenuItem>[
    _MenuItem('充值中心', _image1),
    _MenuItem('机票酒店', _image2),
    _MenuItem('金币庄园', _image3),
    _MenuItem('阿里拍卖', _image1),
    _MenuItem('淘宝吃货', _image2),
    _MenuItem('闲鱼', _image3),
    _MenuItem('会员中心', _image1),
    _MenuItem('造点新货', _image2),
    _MenuItem('土货鲜食', _image3),
  ],
];
