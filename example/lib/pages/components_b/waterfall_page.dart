import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

class WaterfallPage extends StatefulWidget {
  const WaterfallPage({super.key});

  @override
  State<WaterfallPage> createState() => _WaterfallPageState();
}

class _WaterfallPageState extends State<WaterfallPage> {
  final GlobalKey<UPWaterfallState> _waterfallKey =
      GlobalKey<UPWaterfallState>();
  final List<Map<String, dynamic>> _flowList = <Map<String, dynamic>>[];
  int _cursor = 0;
  String _loadStatus = 'loadmore';

  static const List<Map<String, dynamic>> _seedProducts =
      <Map<String, dynamic>>[
    <String, dynamic>{
      'price': 35,
      'title': '北国风光，千里冰封，万里雪飘',
      'shop': '李白杜甫白居易旗舰店',
      'image': 'assets/uview/swiper/swiper1.png',
      'height': 245,
    },
    <String, dynamic>{
      'price': 75,
      'title': '望长城内外，惟余莽莽',
      'shop': '李白杜甫白居易旗舰店',
      'image': 'assets/uview/swiper/swiper2.png',
      'height': 265,
    },
    <String, dynamic>{
      'price': 385,
      'title': '大河上下，顿失滔滔',
      'shop': '李白杜甫白居易旗舰店',
      'image': 'assets/uview/swiper/swiper3.png',
      'height': 286,
    },
    <String, dynamic>{
      'price': 784,
      'title': '欲与天公试比高',
      'shop': '李白杜甫白居易旗舰店',
      'image': 'assets/uview/swiper/swiper1.png',
      'height': 238,
    },
    <String, dynamic>{
      'price': 7891,
      'title': '须晴日，看红装素裹，分外妖娆',
      'shop': '李白杜甫白居易旗舰店',
      'image': 'assets/uview/swiper/swiper2.png',
      'height': 270,
    },
    <String, dynamic>{
      'price': 2341,
      'title': '江山如此多娇，引无数英雄竞折腰',
      'shop': '李白杜甫白居易旗舰店',
      'image': 'assets/uview/swiper/swiper3.png',
      'height': 292,
    },
    <String, dynamic>{
      'price': 661,
      'title': '惜秦皇汉武，略输文采',
      'shop': '李白杜甫白居易旗舰店',
      'image': 'assets/uview/swiper/swiper1.png',
      'height': 240,
    },
    <String, dynamic>{
      'price': 1654,
      'title': '唐宗宋祖，稍逊风骚',
      'shop': '李白杜甫白居易旗舰店',
      'image': 'assets/uview/swiper/swiper2.png',
      'height': 260,
    },
    <String, dynamic>{
      'price': 1678,
      'title': '一代天骄，成吉思汗',
      'shop': '李白杜甫白居易旗舰店',
      'image': 'assets/uview/swiper/swiper3.png',
      'height': 284,
    },
    <String, dynamic>{
      'price': 924,
      'title': '只识弯弓射大雕',
      'shop': '李白杜甫白居易旗舰店',
      'image': 'assets/uview/swiper/swiper1.png',
      'height': 236,
    },
    <String, dynamic>{
      'price': 8243,
      'title': '俱往矣，数风流人物，还看今朝',
      'shop': '李白杜甫白居易旗舰店',
      'image': 'assets/uview/swiper/swiper2.png',
      'height': 272,
    },
  ];

  @override
  void initState() {
    super.initState();
    _appendItems(10, rebuild: false);
  }

  void _appendItems(int count, {bool rebuild = true}) {
    void append() {
      for (var i = 0; i < count; i++) {
        final seed = _seedProducts[_cursor % _seedProducts.length];
        _flowList.add(<String, dynamic>{
          ...seed,
          'id': 'waterfall-${_cursor + 1}',
        });
        _cursor++;
      }
      _loadStatus = 'loadmore';
    }

    if (rebuild) {
      setState(append);
    } else {
      append();
    }
  }

  void _loadMore() {
    setState(() => _loadStatus = 'loading');
    _appendItems(10);
  }

  void _removeProduct(dynamic id) {
    _waterfallKey.currentState?.remove(id);
    setState(() {
      _flowList.removeWhere((item) => item['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '瀑布流',
      child: Container(
        key: const ValueKey('example-page-componentsB/waterfall/waterfall'),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              '商品数量：${_flowList.length}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            UPWaterfall(
              key: _waterfallKey,
              value: _flowList,
              columns: 'auto',
              itemBuilder: (context, item, itemIndex, colIndex) {
                final product = Map<String, dynamic>.from(item as Map);
                return _ProductCard(
                  product: product,
                  onRemove: () => _removeProduct(product['id']),
                );
              },
            ),
            UPLoadmore(
              status: _loadStatus,
              loadmoreText: '加载更多',
              onLoadmore: _loadMore,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onRemove,
  });

  final Map<String, dynamic> product;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = UPThemeTokens.of(context);
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.cardBgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  product['image'] as String,
                  width: double.infinity,
                  height: ((product['height'] as num).toDouble() - 115)
                      .clamp(120, 180)
                      .toDouble(),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                product['title'] as String,
                style: TextStyle(
                  color: theme.mainColor,
                  fontSize: 15,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${product['price']}元',
                style: TextStyle(
                  color: theme.error,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: <Widget>[
                  _Tag(
                    text: '自营',
                    color: theme.error,
                    textColor: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  _Tag(
                    text: '放心购',
                    color: Colors.transparent,
                    textColor: theme.primary,
                    borderColor: theme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                product['shop'] as String,
                style: TextStyle(color: theme.tipsColor, fontSize: 11),
              ),
            ],
          ),
          Positioned(
            top: -10,
            right: -4,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRemove,
              child: const SizedBox(
                width: 32,
                height: 32,
                child: Center(
                  child: UPIcon(
                    name: 'close-circle-fill',
                    color: '#fa3534',
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.text,
    required this.color,
    required this.textColor,
    this.borderColor,
  });

  final String text;
  final Color color;
  final Color textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          height: 1,
        ),
      ),
    );
  }
}
