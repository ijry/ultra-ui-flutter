import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

/// Port of pages/template/wxCenter — a WeChat-style profile page.
class WxCenterPage extends StatelessWidget {
  const WxCenterPage({super.key});

  static const String _pic =
      'https://uview-plus.jiangruyi.com/h5/static/uview/common/logo.png';

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: '仿微信个人中心',
      child: Container(
        key: const ValueKey('example-page-template/wxCenter/index'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Source navbar carries only a trailing camera button. Its page also
            // passes `is-back` and `border-bottom`, which are leftovers from
            // uView 1.x — u-navbar's props.js declares neither, so they are
            // inert there and have no equivalent here.
            UPNavbar(
              fixed: false,
              title: '　',
              border: false,
              safeAreaInsetTop: false,
              rightSlot: const SizedBox(
                width: 54,
                height: 44,
                child: Center(
                  child: UPIcon(
                    name: 'camera-fill',
                    color: Color(0xFF000000),
                    size: 24,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 10, 15),
              child: Row(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: UPAvatar(src: _pic, size: 70),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'uview plus',
                            style: TextStyle(
                              fontSize: 18,
                              color: tokens.mainColor,
                            ),
                          ),
                        ),
                        Text(
                          '微信号:test',
                          style: TextStyle(
                            fontSize: 14,
                            color: tokens.tipsColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(5),
                    child: UPIcon(
                      name: 'scan',
                      color: Color(0xFF969799),
                      size: 14,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(5),
                    child: UPIcon(
                      name: 'arrow-right',
                      color: Color(0xFF969799),
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Source separates the cell groups with 20rpx gaps.
            const SizedBox(height: 10),
            const UPCellGroup(
              children: <Widget>[
                UPCell(icon: 'rmb-circle', title: '支付'),
              ],
            ),
            const SizedBox(height: 10),
            const UPCellGroup(
              children: <Widget>[
                UPCell(icon: 'star', title: '收藏'),
                UPCell(icon: 'photo', title: '相册'),
                UPCell(icon: 'coupon', title: '卡券'),
                UPCell(icon: 'heart', title: '关注'),
              ],
            ),
            const SizedBox(height: 10),
            const UPCellGroup(
              children: <Widget>[
                UPCell(icon: 'setting', title: '设置'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
