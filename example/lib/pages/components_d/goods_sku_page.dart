import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

const Map<String, Object> _goodsInfo = <String, Object>{
  'image': 'https://uview-plus.jiangruyi.com/uview/ext/200.jpg',
  'price': 99.00,
  'stock': 100,
};

const List<Map<String, Object>> _skuTree = <Map<String, Object>>[
  <String, Object>{
    'label': '颜色',
    'name': 'color',
    'children': <Map<String, Object>>[
      <String, Object>{'id': 1, 'name': '红色'},
      <String, Object>{'id': 2, 'name': '蓝色'},
      <String, Object>{'id': 3, 'name': '黑色'},
    ],
  },
  <String, Object>{
    'label': '尺寸',
    'name': 'size',
    'children': <Map<String, Object>>[
      <String, Object>{'id': 1, 'name': 'S'},
      <String, Object>{'id': 2, 'name': 'M'},
      <String, Object>{'id': 3, 'name': 'L'},
      <String, Object>{'id': 4, 'name': 'XL'},
    ],
  },
];

const List<Map<String, Object>> _skuList = <Map<String, Object>>[
  <String, Object>{'id': 1, 'color': 1, 'size': 1, 'price': 99.00, 'stock': 50},
  <String, Object>{'id': 2, 'color': 1, 'size': 2, 'price': 99.00, 'stock': 40},
  <String, Object>{
    'id': 3,
    'color': 2,
    'size': 1,
    'price': 109.00,
    'stock': 30
  },
  <String, Object>{
    'id': 4,
    'color': 2,
    'size': 3,
    'price': 109.00,
    'stock': 20
  },
  <String, Object>{'id': 5, 'color': 3, 'size': 4, 'price': 89.00, 'stock': 60},
];

class GoodsSkuPage extends StatefulWidget {
  const GoodsSkuPage({super.key});

  @override
  State<GoodsSkuPage> createState() => _GoodsSkuPageState();
}

class _GoodsSkuPageState extends State<GoodsSkuPage> {
  String _result = '';

  void _confirmSku(Map payload) {
    final sku = payload['sku'];
    final price = sku is Map ? sku['price'] : '';
    setState(() {
      _result = '选择了: ${payload['selectedText']}, '
          '数量: ${payload['num']}, 价格: $price';
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: '商品SKU',
      child: Container(
        key: const ValueKey('example-page-componentsD/goodsSku/goodsSku'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '基本使用',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: UPGoodsSku(
                  key: const ValueKey('goods-sku-page-basic'),
                  goodsInfo: _goodsInfo,
                  skuTree: _skuTree,
                  skuList: _skuList,
                  onConfirm: _confirmSku,
                  trigger: const UPButton(
                    stop: false,
                    type: 'primary',
                    text: '打开SKU弹窗',
                  ),
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '自定义最大购买数量',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: UPGoodsSku(
                  key: const ValueKey('goods-sku-page-max-buy'),
                  goodsInfo: _goodsInfo,
                  skuTree: _skuTree,
                  skuList: _skuList,
                  maxBuy: 10,
                  onConfirm: _confirmSku,
                  trigger: const UPButton(
                    stop: false,
                    type: 'error',
                    text: '打开SKU弹窗(最大购买10件)',
                  ),
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '自定义确认按钮文字',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: UPGoodsSku(
                  key: const ValueKey('goods-sku-page-confirm-text'),
                  goodsInfo: _goodsInfo,
                  skuTree: _skuTree,
                  skuList: _skuList,
                  confirmText: '立即购买',
                  onConfirm: _confirmSku,
                  trigger: const UPButton(
                    stop: false,
                    type: 'warning',
                    text: '打开SKU弹窗',
                  ),
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '无弹窗页面模式',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: UPGoodsSku(
                  key: const ValueKey('goods-sku-page-inline'),
                  goodsInfo: _goodsInfo,
                  skuTree: _skuTree,
                  skuList: _skuList,
                  pageInline: true,
                  confirmText: '立即购买',
                  onConfirm: _confirmSku,
                ),
              ),
            ),
            if (_result.isNotEmpty)
              ExampleDemoBlock(
                title: '选择结果',
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _result,
                    style: TextStyle(color: tokens.contentColor, fontSize: 13),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
