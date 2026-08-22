import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

/// Source `dataList` — five store orders reused to fill each tab.
const List<Map<String, Object>> _dataList = <Map<String, Object>>[
  <String, Object>{
    'id': 1,
    'store': '夏日流星限定贩卖',
    'deal': '交易成功',
    'goodsList': <Map<String, Object>>[
      <String, Object>{
        'goodsUrl':
            'https://img13.360buyimg.com/n7/jfs/t1/103005/7/17719/314825/5e8c19faEb7eed50d/5b81ae4b2f7f3bb7.jpg',
        'title': '【冬日限定】现货 原创jk制服女2020冬装新款小清新宽松软糯毛衣外套女开衫短款百搭日系甜美风',
        'type': '灰色;M',
        'deliveryTime': '付款后30天内发货',
        'price': '348.58',
        'number': 2,
      },
      <String, Object>{
        'goodsUrl':
            'https://img12.360buyimg.com/n7/jfs/t1/102191/19/9072/330688/5e0af7cfE17698872/c91c00d713bf729a.jpg',
        'title': '【葡萄藤】现货 小清新学院风制服格裙百褶裙女短款百搭日系甜美风原创jk制服女2020新款',
        'type': '45cm;S',
        'deliveryTime': '付款后30天内发货',
        'price': '135.00',
        'number': 1,
      },
    ],
  },
  <String, Object>{
    'id': 2,
    'store': '江南皮革厂',
    'deal': '交易失败',
    'goodsList': <Map<String, Object>>[
      <String, Object>{
        'goodsUrl':
            'https://img14.360buyimg.com/n7/jfs/t1/60319/15/6105/406802/5d43f68aE9f00db8c/0affb7ac46c345e2.jpg',
        'title': '【冬日限定】现货 原创jk制服女2020冬装新款小清新宽松软糯毛衣外套女开衫短款百搭日系甜美风',
        'type': '粉色;M',
        'deliveryTime': '付款后7天内发货',
        'price': '128.05',
        'number': 1,
      },
    ],
  },
  <String, Object>{
    'id': 3,
    'store': '三星旗舰店',
    'deal': '交易失败',
    'goodsList': <Map<String, Object>>[
      <String, Object>{
        'goodsUrl':
            'https://img11.360buyimg.com/n7/jfs/t1/94448/29/2734/524808/5dd4cc16E990dfb6b/59c256f85a8c3757.jpg',
        'title':
            '三星（SAMSUNG）京品家电 UA65RUF70AJXXZ 65英寸4K超高清 HDR 京东微联 智能语音 教育资源液晶电视机',
        'type': '4K，广色域',
        'deliveryTime': '保质5年',
        'price': '1998',
        'number': 3,
      },
      <String, Object>{
        'goodsUrl':
            'https://img14.360buyimg.com/n7/jfs/t6007/205/4099529191/294869/ae4e6d4f/595dcf19Ndce3227d.jpg!q90.jpg',
        'title':
            '美的(Midea)639升 对开门冰箱 19分钟急速净味 一级能效冷藏双开门杀菌智能家用双变频节能 BCD-639WKPZM(E)',
        'type': '容量大，速冻',
        'deliveryTime': '保质5年',
        'price': '2354',
        'number': 1,
      },
    ],
  },
  <String, Object>{
    'id': 4,
    'store': '三星旗舰店',
    'deal': '交易失败',
    'goodsList': <Map<String, Object>>[
      <String, Object>{
        'goodsUrl':
            'https://img10.360buyimg.com/n7/jfs/t22300/31/1505958241/171936/9e201a89/5b2b12ffNe6dbb594.jpg!q90.jpg',
        'title': '法国进口红酒 拉菲（LAFITE）传奇波尔多干红葡萄酒750ml*6整箱装',
        'type': '4K，广色域',
        'deliveryTime': '珍藏10年好酒',
        'price': '1543',
        'number': 3,
      },
      <String, Object>{
        'goodsUrl':
            'https://img10.360buyimg.com/n7/jfs/t1/107598/17/3766/525060/5e143aacE9a94d43c/03573ae60b8bf0ee.jpg',
        'title': '蓝妹（BLUE GIRL）酷爽啤酒 清啤 原装进口啤酒 罐装 500ml*9听 整箱装',
        'type': '一打',
        'deliveryTime': '口感好',
        'price': '120',
        'number': 1,
      },
    ],
  },
  <String, Object>{
    'id': 5,
    'store': '三星旗舰店',
    'deal': '交易成功',
    'goodsList': <Map<String, Object>>[
      <String, Object>{
        'goodsUrl':
            'https://img12.360buyimg.com/n7/jfs/t1/52408/35/3554/78293/5d12e9cfEfd118ba1/ba5995e62cbd747f.jpg!q90.jpg',
        'title': '企业微信 中控人脸指纹识别考勤机刷脸机 无线签到异地多店打卡机WX108',
        'type': '识别效率高',
        'deliveryTime': '使用方便',
        'price': '451',
        'number': 9,
      },
    ],
  },
];

const List<Map<String, Object>> _tabs = <Map<String, Object>>[
  <String, Object>{'name': '待付款'},
  <String, Object>{'name': '待发货'},
  <String, Object>{'name': '待收货'},
  <String, Object>{'name': '待评价', 'count': 12},
];

/// Port of pages/template/order — a tabbed order list with infinite scroll.
class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  int _current = 0;

  /// Four tabs' order lists. Source seeds 0, 1 and 3 in onLoad, leaving tab 2
  /// deliberately empty so the empty state is visible.
  final List<List<Map<String, Object>>> _orderList =
      <List<Map<String, Object>>>[[], [], [], []];
  final List<String> _loadStatus = <String>[
    'loadmore',
    'loadmore',
    'loadmore',
    'loadmore'
  ];

  /// Source picks entries at random; a rotating index is used instead so the
  /// page renders the same thing every time and the layout test is stable.
  int _seed = 0;

  @override
  void initState() {
    super.initState();
    _getOrderList(0);
    _getOrderList(1);
    _getOrderList(3);
  }

  void _getOrderList(int idx) {
    for (var i = 0; i < 5; i++) {
      final data = _dataList[_seed % _dataList.length];
      _seed += 1;
      _orderList[idx].add(data);
    }
    _loadStatus[idx] = 'loadmore';
  }

  /// Source `priceInt` / `priceDecimal`.
  ///
  /// Both compare a *string* price with `parseInt` using `!==`, which is always
  /// true — so a whole-number price like '1998' takes the decimal branch and
  /// `slice(-2)` yields '98', rendering ￥1998.98. Verified by running the source
  /// helpers under node. That is upstream's bug, not a porting slip; splitting on
  /// '.' here shows ￥1998.00, which is what the data means.
  String _priceInt(String value) => value.split('.').first;

  String _priceDecimal(String value) {
    final parts = value.split('.');
    if (parts.length < 2) return '00';
    return parts[1].padRight(2, '0').substring(0, 2);
  }

  /// Source `totalPrice` sums `price` but never multiplies by `number`, so its
  /// "合计" undercounts any line with a quantity above 1 (2×348.58 + 135 shows as
  /// 483.58 rather than 832.16). Quantity is honoured here.
  String _totalPrice(List goods) {
    var total = 0.0;
    for (final item in goods) {
      if (item is! Map) continue;
      final price = double.tryParse('${item['price']}') ?? 0;
      final number = int.tryParse('${item['number']}') ?? 1;
      total += price * number;
    }
    return total.toStringAsFixed(2);
  }

  int _totalNum(List goods) {
    var num = 0;
    for (final item in goods) {
      if (item is Map) num += int.tryParse('${item['number']}') ?? 0;
    }
    return num;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: '订单列表',
      // Each tab owns its own scroll view.
      scrollable: false,
      child: Container(
        key: const ValueKey('example-page-template/order/index'),
        color: tokens.bgColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              color: tokens.cardBgColor,
              child: UPTabs(
                key: const ValueKey('order-page-tabs'),
                list: _tabs,
                current: _current,
                scrollable: false,
                lineColor: '#f29100',
                onChange: (index) => setState(() {
                  _current = index;
                  _getOrderList(index);
                }),
              ),
            ),
            Expanded(
              child: ListView(
                key: ValueKey('order-page-list-$_current'),
                padding: const EdgeInsets.only(bottom: 10),
                children: <Widget>[
                  for (final order in _orderList[_current])
                    _order(tokens, order),
                  UPLoadmore(status: _loadStatus[_current]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _order(UPThemeTokens tokens, Map<String, Object> order) {
    final goods = order['goodsList'];
    final list = goods is List ? goods : const <Object>[];
    return Container(
      margin: const EdgeInsets.only(top: 10),
      color: tokens.cardBgColor,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const UPIcon(
                name: 'home',
                size: 15,
                color: Color(0xFF5E5E5E),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '${order['store']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: tokens.mainColor),
                ),
              ),
              const UPIcon(
                name: 'arrow-right',
                size: 13,
                color: Color(0xFFCBCBCB),
              ),
              const Spacer(),
              Text(
                '${order['deal']}',
                style: TextStyle(fontSize: 13, color: tokens.tipsColor),
              ),
            ],
          ),
          for (final item in list) _goodsItem(tokens, item),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  '共${_totalNum(list)}件商品 合计:',
                  style: TextStyle(fontSize: 13, color: tokens.contentColor),
                ),
                Text(
                  '￥${_totalPrice(list)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: tokens.mainColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                const UPIcon(
                  name: 'more-dot-fill',
                  size: 14,
                  color: Color(0xFFCBCBCB),
                ),
                const Spacer(),
                _btn(tokens, '查看物流'),
                _btn(tokens, '卖了换钱'),
                _btn(tokens, '评价'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _goodsItem(UPThemeTokens tokens, dynamic raw) {
    final item = raw is Map ? raw : const <String, Object>{};
    final price = '${item['price']}';
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          UPImage(
            src: '${item['goodsUrl'] ?? ''}',
            width: 60,
            height: 60,
            mode: 'aspectFill',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${item['title']}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: tokens.mainColor),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${item['type']}',
                    style: TextStyle(fontSize: 12, color: tokens.tipsColor),
                  ),
                ),
                Text(
                  '发货时间 ${item['deliveryTime']}',
                  style: TextStyle(fontSize: 12, color: tokens.tipsColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              // Source renders the decimal part smaller than the integer part.
              Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 14, color: tokens.mainColor),
                  children: <InlineSpan>[
                    TextSpan(text: '￥${_priceInt(price)}'),
                    TextSpan(
                      text: '.${_priceDecimal(price)}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              Text(
                'x${item['number']}',
                style: TextStyle(fontSize: 12, color: tokens.tipsColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _btn(UPThemeTokens tokens, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: tokens.borderColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 12, color: tokens.contentColor),
        ),
      ),
    );
  }
}
