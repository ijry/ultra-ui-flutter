import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';

/// 1:1 port of u-empty defaults.
class UPEmpty extends StatelessWidget {
  const UPEmpty({
    super.key,
    this.icon = '',
    this.text = '',
    this.textColor = '#c0c4cc',
    this.textSize = 14,
    this.iconColor = '#c0c4cc',
    this.iconSize = 90,
    this.mode = 'data',
    this.width = 160,
    this.height = 160,
    this.show = true,
    this.marginTop = 0,
    this.customStyle,
    this.child,
  });

  final String icon;
  final String text;
  final dynamic textColor;
  final dynamic textSize;
  final dynamic iconColor;
  final dynamic iconSize;
  final String mode;
  final dynamic width;
  final dynamic height;
  final bool show;
  final dynamic marginTop;
  final BoxDecoration? customStyle;

  /// Source data — localized empty-text values keyed by mode.
  Map<String, String> get icons => const {
        'car': '购物车为空',
        'page': '页面不存在',
        'search': '没有搜索结果',
        'address': '没有收货地址',
        'wifi': '没有WiFi',
        'order': '订单为空',
        'coupon': '没有优惠券',
        'favor': '暂无收藏',
        'permission': '无权限',
        'history': '无历史记录',
        'news': '无新闻列表',
        'message': '暂无消息',
        'list': '列表为空',
        'data': '数据为空',
        'comment': '暂无评论',
      };

  final Widget? child;

  bool get _isSrc => icon.contains('/');

  String get _modeIcon {
    // The source only uses icon to choose the image branch. Non-path icon
    // values still render the mode-derived built-in icon.
    if (mode == 'message') return 'chat';
    return 'empty-$mode';
  }

  String get _modeText {
    if (text.isNotEmpty) return text;
    return icons[mode] ?? '';
  }

  /// Source computed: emptyStyle.
  dynamic get emptyStyle => <String, dynamic>{
        'marginTop': UPUtils.addUnit(marginTop),
      };

  /// Source computed: textStyle.
  dynamic get textStyle => <String, dynamic>{
        'color': textColor,
        'fontSize': UPUtils.addUnit(textSize),
      };

  /// Source computed: isSrc.
  bool get isSrc => icon.contains('/');

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();
    final tokens = UPThemeTokens.of(context);
    final iColor = UPUtils.parseColor(iconColor) ?? tokens.lightColor;
    final tColor = UPUtils.parseColor(textColor) ?? tokens.lightColor;
    final iconW = UPUtils.getPx(width);
    final iconH = UPUtils.getPx(height);

    Widget iconWidget;
    if (_isSrc) {
      final isNetworkIcon =
          icon.startsWith('http://') || icon.startsWith('https://');
      iconWidget = SizedBox(
        width: iconW > 0 ? iconW : 160,
        height: iconH > 0 ? iconH : 160,
        child: isNetworkIcon
            ? Image.network(
                icon,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => UPIcon(
                  name: 'photo',
                  size: iconSize,
                  color: iColor,
                ),
              )
            : Image.asset(
                icon,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => UPIcon(
                  name: 'photo',
                  size: iconSize,
                  color: iColor,
                ),
              ),
      );
    } else {
      iconWidget = UPIcon(
        name: _modeIcon,
        size: iconSize,
        color: iColor,
      );
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: UPUtils.getPx(marginTop)),
      decoration: customStyle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          SizedBox(height: UPUtils.getPx('20rpx')),
          Text(
            _modeText,
            style: TextStyle(
              color: tColor,
              fontSize: UPUtils.getPx(textSize),
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}
