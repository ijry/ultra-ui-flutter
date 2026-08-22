import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class CouponPage extends StatelessWidget {
  const CouponPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '优惠券',
      child: Container(
        key: const ValueKey('example-page-componentsD/coupon/coupon'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const ExampleDemoBlock(
              title: '基础优惠券',
              child: Padding(
                padding: EdgeInsets.all(12),
                child: UPCoupon(
                  key: ValueKey('coupon-page-basic'),
                  amount: 100,
                  title: '满减券',
                  color: '#333',
                  limit: '满200可用',
                  time: '2023-12-31前使用',
                ),
              ),
            ),
            const ExampleDemoBlock(
              title: '小尺寸',
              child: Padding(
                padding: EdgeInsets.all(12),
                child: UPCoupon(
                  key: ValueKey('coupon-page-small'),
                  amount: 20,
                  title: '满减券',
                  size: 'small',
                  actionText: '去使用',
                ),
              ),
            ),
            const ExampleDemoBlock(
              title: '大尺寸',
              child: Padding(
                padding: EdgeInsets.all(12),
                child: UPCoupon(
                  key: ValueKey('coupon-page-large'),
                  amount: 200,
                  unit: '￥',
                  title: '大额优惠券',
                  desc: '仅限VIP用户',
                  limit: '满500可用',
                  time: '有效期至2023-12-31',
                  size: 'large',
                  type: 'error',
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '自定义内容',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: UPCoupon(
                  key: const ValueKey('coupon-page-custom'),
                  amount: 66,
                  title: '自定义样式',
                  desc: '通过插槽自定义内容',
                  shape: 'card',
                  // Source overrides the amount, title and action slots.
                  amountBuilder: (amount) => Text(
                    '$amount',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF0000),
                    ),
                  ),
                  titleBuilder: (title) => Text(
                    '$title',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  actionBuilder: (actionText, circle) => UPButton(
                    type: 'success',
                    size: 'mini',
                    hairline: false,
                    text: '立即使用',
                  ),
                ),
              ),
            ),
            const ExampleDemoBlock(
              title: '圆形按钮',
              child: Padding(
                padding: EdgeInsets.all(12),
                child: UPCoupon(
                  key: ValueKey('coupon-page-circle'),
                  amount: 30,
                  title: '限时优惠',
                  desc: '今日专享',
                  circle: true,
                  actionText: '抢购',
                ),
              ),
            ),
            const ExampleDemoBlock(
              title: '禁用状态',
              child: Padding(
                padding: EdgeInsets.all(12),
                child: UPCoupon(
                  key: ValueKey('coupon-page-disabled'),
                  amount: 50,
                  title: '已过期',
                  desc: '活动已结束',
                  time: '2023-01-01至2023-01-31',
                  disabled: true,
                ),
              ),
            ),
            const ExampleDemoBlock(
              title: '红包样式',
              child: Padding(
                padding: EdgeInsets.all(12),
                child: UPCoupon(
                  key: ValueKey('coupon-page-envelope'),
                  amount: 50,
                  unit: '元',
                  title: '新人红包',
                  desc: '限时专享',
                  shape: 'envelope',
                  type: 'warning',
                ),
              ),
            ),
            const ExampleDemoBlock(
              title: '卡片样式',
              child: Padding(
                padding: EdgeInsets.all(12),
                child: UPCoupon(
                  key: ValueKey('coupon-page-card'),
                  amount: 88,
                  unit: '折',
                  title: '折扣券',
                  desc: '全场通用',
                  shape: 'card',
                  type: 'success',
                  actionText: '立即领取',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
