import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_tag.dart';

/// Port of u-coupon / up-coupon.
class UPCoupon extends StatelessWidget {
  const UPCoupon({
    super.key,
    this.amount = '',
    this.unit = '￥',
    this.unitPosition = 'left',
    this.limit = '',
    this.title = '优惠券',
    this.desc = '',
    this.time = '',
    this.actionText = '使用',
    this.shape = 'coupon',
    this.size = 'medium',
    this.circle = false,
    this.disabled = false,
    this.bgColor = '',
    this.color = '',
    this.type = '',
    this.onClick,
    this.unitBuilder,
    this.amountBuilder,
    this.limitBuilder,
    this.titleBuilder,
    this.descBuilder,
    this.timeBuilder,
    this.actionBuilder,
    this.actionSlot,
    this.child,
    this.customStyle,
  });

  final dynamic amount;
  final String unit;
  final String unitPosition;
  final String limit;
  final String title;
  final String desc;
  final String time;
  final String actionText;
  final String shape;
  final String size;
  final bool circle;
  final bool disabled;
  final dynamic bgColor;
  final dynamic color;
  final String type;
  final VoidCallback? onClick;

  /// Source `handleClick`.
  void handleClick() {
    if (disabled) return;
    onClick?.call();
  }

  /// Slot-like builders matching source named slots.
  final Widget Function(String unit, String unitPosition)? unitBuilder;
  final Widget Function(dynamic amount)? amountBuilder;
  final Widget Function(String limit)? limitBuilder;
  final Widget Function(String title)? titleBuilder;
  final Widget Function(String desc)? descBuilder;
  final Widget Function(String time)? timeBuilder;
  final Widget Function(String actionText, bool circle)? actionBuilder;

  /// Backward-compatible action slot alias.
  final Widget? actionSlot;
  final Widget? child;
  final BoxDecoration? customStyle;

  double get _height {
    switch (size) {
      case 'small':
        return 80;
      case 'large':
        return 110;
      default:
        return 90;
    }
  }

  /// Source computed: couponStyle.
  dynamic get couponStyle {
    final style = <String, dynamic>{};
    if ('$bgColor'.trim().isNotEmpty) style['background'] = bgColor;
    if ('$color'.trim().isNotEmpty) style['color'] = color;
    return style;
  }

  /// Source computed: dotCount.
  dynamic get dotCount {
    switch (size) {
      case 'small':
        return 8;
      case 'large':
        return 12;
      case 'medium':
      default:
        return 10;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final bg = UPUtils.parseColor(bgColor) ?? const Color(0xFFFFEBF0);
    final fg = UPUtils.parseColor(color) ?? tokens.mainColor;
    final amountColor =
        type.isNotEmpty ? tokens.typeColor(type) : const Color(0xFFEB433D);

    Widget unitWidget(String pos) {
      if (unitBuilder != null) return unitBuilder!(unit, pos);
      return Text(
        unit,
        style: TextStyle(color: amountColor, fontSize: 12, height: 1),
      );
    }

    final amountWidget = amountBuilder?.call(amount) ??
        Text(
          '$amount',
          style: TextStyle(
            color: amountColor,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        );

    final limitWidget = limit.isEmpty
        ? null
        : (limitBuilder?.call(limit) ??
            Text(
              limit,
              style: TextStyle(
                color: fg.withOpacity(0.7),
                fontSize: 12,
              ),
            ));

    final titleWidget = titleBuilder?.call(title) ??
        Text(
          title,
          style: TextStyle(
            color: fg,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        );

    final descWidget = desc.isEmpty
        ? null
        : (descBuilder?.call(desc) ??
            Text(
              desc,
              style: TextStyle(
                color: fg.withOpacity(0.75),
                fontSize: 12,
              ),
            ));

    final timeWidget = time.isEmpty
        ? null
        : (timeBuilder?.call(time) ??
            Text(
              time,
              style: TextStyle(
                color: fg.withOpacity(0.55),
                fontSize: 10,
              ),
            ));

    final actionWidget = actionBuilder?.call(actionText, circle) ??
        actionSlot ??
        UPTag(
          text: actionText,
          type: type.isNotEmpty ? type : 'error',
          bgColor: type.isNotEmpty ? 'transparent' : '#eb433d',
          borderColor: type.isNotEmpty ? '#eee' : '#eb433d',
          color: type.isNotEmpty ? '' : '#ffffff',
          shape: circle ? 'circle' : 'circle',
          borderRadius: '6px',
          size: 'medium',
        );

    Widget root = Opacity(
      opacity: disabled ? 0.5 : 1,
      child: GestureDetector(
        onTap: disabled ? null : onClick,
        behavior: HitTestBehavior.opaque,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: _height,
            width: double.infinity,
            color: bg,
            child: Stack(
              children: [
                if (shape == 'coupon') ...[
                  Positioned(
                    left: -12,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -12,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
                if (shape == 'envelope')
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 10,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFD000), Color(0xFFFFA000)],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 88,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (unitPosition == 'left')
                                    unitWidget('left'),
                                  amountWidget,
                                  if (unitPosition == 'right')
                                    unitWidget('right'),
                                ],
                              ),
                            ),
                            if (limitWidget != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: limitWidget,
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              titleWidget,
                              if (descWidget != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: descWidget,
                                ),
                              if (timeWidget != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: timeWidget,
                                ),
                            ],
                          ),
                        ),
                      ),
                      actionWidget,
                    ],
                  ),
                ),
                if (child != null) Positioned.fill(child: child!),
              ],
            ),
          ),
        ),
      ),
    );
    return root;
  }
}
