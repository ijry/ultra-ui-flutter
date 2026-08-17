import 'package:flutter/material.dart';

import '../utils/up_utils.dart';
import 'up_icon.dart';
import 'up_layout.dart';
import 'up_status_bar.dart';

/// Port of u-navbar-mini.
class UPNavbarMini extends StatelessWidget {
  const UPNavbarMini({
    super.key,
    this.safeAreaInsetTop = true,
    this.fixed = true,
    this.leftIcon = 'arrow-leftward',
    this.bgColor = 'rgba(0,0,0,.15)',
    this.height = '32px',
    this.iconSize = '20px',
    this.iconColor = '#fff',
    this.autoBack = true,
    this.homeUrl = '',
    this.leftSlot,
    this.centerSlot,
    this.onLeftClick,
    this.onHomeClick,
    this.customStyle,
  });

  final bool safeAreaInsetTop;
  final bool fixed;
  final String leftIcon;
  final dynamic bgColor;
  final dynamic height;
  final dynamic iconSize;
  final dynamic iconColor;
  final bool autoBack;
  final String homeUrl;
  final Widget? leftSlot;
  final Widget? centerSlot;
  final VoidCallback? onLeftClick;
  final VoidCallback? onHomeClick;
  final BoxDecoration? customStyle;

  /// Source `leftClick` alias.
  void leftClick([dynamic _]) => onLeftClick?.call();

  /// Source `homeClick` alias.
  void homeClick([dynamic _]) => onHomeClick?.call();

  @override
  Widget build(BuildContext context) {
    final h = UPUtils.getPx(height);
    final bg = UPUtils.parseColor(bgColor) ?? const Color(0x26000000);
    final ic = UPUtils.parseColor(iconColor) ?? const Color(0xFFFFFFFF);
    final isz = UPUtils.getPx(iconSize);

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (safeAreaInsetTop) const UPStatusBar(),
        Container(
          height: h,
          color: bg,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  onLeftClick?.call();
                  if (autoBack && onLeftClick == null) {
                    final nav = Navigator.maybeOf(context);
                    if (nav != null && nav.canPop()) nav.pop();
                  }
                },
                child: leftSlot ?? UPIcon(name: leftIcon, size: isz, color: ic),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: UPLine(
                  direction: 'col',
                  color: '#fff',
                  length: '16px',
                  hairline: true,
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onHomeClick,
                child: centerSlot ?? UPIcon(name: 'home', size: isz, color: ic),
              ),
            ],
          ),
        ),
      ],
    );

    return content;
  }
}
