import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

/// Port of pages/template/coupon — three hand-styled coupon cards imitating
/// Meituan, JD and Taobao. The source hardcodes every value in its template
/// rather than driving them from data, so this does the same.
class CouponTemplatePage extends StatelessWidget {
  const CouponTemplatePage({super.key});

  static const Color _red = Color(0xFFFA3534);

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: '优惠券',
      child: Container(
        key: const ValueKey('example-page-template/coupon/index'),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _meituan(tokens),
            const SizedBox(height: 10),
            _jingdong(tokens),
            const SizedBox(height: 10),
            _taobao(tokens),
          ],
        ),
      ),
    );
  }

  /// Amount block: a small ￥ beside a large figure, with a caption under it.
  Widget _amount(String value, String caption, {Color color = _red}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text('￥', style: TextStyle(fontSize: 12, color: color)),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        Text(caption, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }

  Widget _useButton(String text, {bool round = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _red,
        borderRadius: BorderRadius.circular(round ? 20 : 4),
      ),
      child: Text(
        text,
        maxLines: 1,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _meituan(UPThemeTokens tokens) {
    return Container(
      decoration: BoxDecoration(
        color: tokens.cardBgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: <Widget>[
                _amount('8', '抵用券'),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '【洗牙】8元无门槛红包',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: tokens.mainColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '今日到期',
                          style: TextStyle(
                            fontSize: 12,
                            color: tokens.tipsColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _useButton('立即使用'),
              ],
            ),
          ),
          // Source draws a dashed separator with a notch punched out each side.
          Container(height: 1, color: tokens.borderColor),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '满8.1元可用、限最新版本客户端使用',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: tokens.tipsColor),
                  ),
                ),
                Text(
                  '使用规则',
                  style: TextStyle(fontSize: 12, color: tokens.tipsColor),
                ),
                const UPIcon(name: 'arrow-right', size: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _jingdong(UPThemeTokens tokens) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tokens.cardBgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _amount('100', '满149元可用'),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        border: Border.all(color: _red),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Text(
                        '限品类东券',
                        style: TextStyle(fontSize: 10, color: _red),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '仅可购买个人护理部分商品',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: tokens.contentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          '2020.01.01-2020.01.31',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: tokens.tipsColor,
                          ),
                        ),
                      ),
                      _useButton('立即使用', round: false),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: <Widget>[
                      // Source uses its own `zhuanfa` (forward) glyph.
                      const UPIcon(name: 'zhuanfa', size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '可赠送',
                        style: TextStyle(
                          fontSize: 11,
                          color: tokens.tipsColor,
                        ),
                      ),
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

  Widget _taobao(UPThemeTokens tokens) {
    return Container(
      decoration: BoxDecoration(
        color: tokens.cardBgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: <Widget>[
                // Source leaves this image's src empty, so nothing loads; a
                // placeholder box keeps the row's shape.
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: tokens.bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '袜子精保护协会',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: tokens.mainColor),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: tokens.borderColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '进店',
                    style: TextStyle(
                      fontSize: 11,
                      color: tokens.contentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: tokens.borderColor),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: <Widget>[
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: tokens.bgColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          const Text('￥',
                              style: TextStyle(fontSize: 12, color: _red)),
                          const Text(
                            '3',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _red,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '满88减3',
                            style: TextStyle(
                              fontSize: 12,
                              color: tokens.contentColor,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '店铺优惠券',
                        style: TextStyle(
                          fontSize: 12,
                          color: tokens.tipsColor,
                        ),
                      ),
                      Text(
                        '2019.11.28-2020.1.24',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: tokens.tipsColor,
                        ),
                      ),
                    ],
                  ),
                ),
                _useButton('去使用'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
