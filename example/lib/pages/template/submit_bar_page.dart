import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

/// Port of pages/template/submitBar — a goods-detail action bar.
class SubmitBarPage extends StatelessWidget {
  const SubmitBarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: '提交订单栏',
      child: Container(
        key: const ValueKey('example-page-template/submitBar/index'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Source pushes the bar down by 100rpx before showing it.
            const SizedBox(height: 50),
            Container(
              decoration: BoxDecoration(
                color: tokens.cardBgColor,
                border: Border.all(color: tokens.borderColor),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: <Widget>[
                  _action(tokens, 'server-fill', '客服'),
                  _action(tokens, 'home', '店铺'),
                  _action(tokens, 'shopping-cart', '购物车', badgeCount: 9),
                  const Spacer(),
                  // Flexible, because the two pill buttons plus three actions
                  // exceed a 320px phone. The source's labels carry `u-line-1`,
                  // so truncating them rather than overflowing matches it.
                  Flexible(child: _button('加入购物车', const Color(0xFFED3F14))),
                  const SizedBox(width: 15),
                  Flexible(child: _button('立即购买', const Color(0xFFFF7900))),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Source `.left .item`: 20rpx label under a 20px icon, 20rpx side margins.
  Widget _action(
    UPThemeTokens tokens,
    String icon,
    String label, {
    int? badgeCount,
  }) {
    Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        UPIcon(name: icon, size: 20, color: tokens.contentColor),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 10, color: tokens.contentColor),
        ),
      ],
    );
    if (badgeCount != null) {
      // Source offsets the badge out of the icon's top-right corner.
      body = Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          body,
          Positioned(
            top: -5,
            right: -5,
            child: UPBadge(value: '$badgeCount', type: 'error'),
          ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: body,
    );
  }

  /// Source `.btn`: 66rpx line height, 30rpx side padding, 36rpx pill radius.
  Widget _button(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      height: 33,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}
