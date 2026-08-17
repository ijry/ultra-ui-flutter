import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';

/// Host interceptor for navbar left click, mirrors config.interceptor.navbarLeftClick.
typedef UPNavbarLeftClickInterceptor = void Function(
  BuildContext context,
  UPNavbar navbar,
);

/// 1:1 port of u-navbar.
class UPNavbar extends StatelessWidget implements PreferredSizeWidget {
  const UPNavbar({
    super.key,
    this.safeAreaInsetTop = true,
    this.placeholder = false,
    this.fixed = false,
    this.border = false,
    this.leftIcon = 'arrow-left',
    this.leftText = '',
    this.rightText = '',
    this.rightIcon = '',
    this.title = '',
    this.titleColor = '',
    this.bgColor = '',
    this.statusBarBgColor = '',
    this.titleWidth = '400rpx',
    this.height = '44px',
    this.leftIconSize = 20,
    this.leftIconColor = '',
    this.autoBack = false,
    this.titleStyle,
    this.customStyle,
    this.leftSlot,
    this.centerSlot,
    this.rightSlot,
    this.onLeftClick,
    this.onRightClick,
  });

  /// Optional global left-click interceptor (app router host).
  static UPNavbarLeftClickInterceptor? leftClickInterceptor;

  final bool safeAreaInsetTop;
  final bool placeholder;
  final bool fixed;
  final bool border;
  final String leftIcon;
  final String leftText;
  final String rightText;
  final String rightIcon;
  final dynamic title;
  final dynamic titleColor;
  final dynamic bgColor;
  final dynamic statusBarBgColor;
  final dynamic titleWidth;
  final dynamic height;
  final dynamic leftIconSize;
  final dynamic leftIconColor;
  final bool autoBack;
  final TextStyle? titleStyle;
  final BoxDecoration? customStyle;
  final Widget? leftSlot;
  final Widget? centerSlot;
  final Widget? rightSlot;
  final VoidCallback? onLeftClick;
  final VoidCallback? onRightClick;

  double _barHeight(BuildContext context) => UPUtils.getPx(height);

  @override
  Size get preferredSize {
    // PreferredSizeWidget requires constant-ish height; include typical status bar.
    // Actual build still uses MediaQuery for precise inset.
    final h = UPUtils.getPx(height);
    return Size.fromHeight(h + (safeAreaInsetTop ? 24 : 0));
  }

  /// Source `leftClick`.
  void leftClick([BuildContext? context]) {
    if (context != null) {
      _leftTap(context);
      return;
    }
    onLeftClick?.call();
  }

  /// Source `rightClick`.
  void rightClick() => onRightClick?.call();

  void _leftTap(BuildContext context) {
    onLeftClick?.call();
    final interceptor = leftClickInterceptor;
    if (interceptor != null) {
      interceptor(context, this);
      return;
    }
    if (autoBack && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  /// Source computed: navbarBgColor.
  dynamic get navbarBgColor {
    if (bgColor != null && '$bgColor'.trim().isNotEmpty) return bgColor;
    return '#ffffff';
  }

  /// Source computed: navbarTitleColor.
  dynamic get navbarTitleColor {
    if (titleColor != null && '$titleColor'.trim().isNotEmpty)
      return titleColor;
    return '#303133';
  }

  /// Source computed: navbarLeftIconColor.
  dynamic get navbarLeftIconColor {
    if (leftIconColor != null && '$leftIconColor'.trim().isNotEmpty) {
      return leftIconColor;
    }
    return '#303133';
  }

  /// Source computed: navbarRightColor.
  dynamic get navbarRightColor => '#303133';

  /// Source computed: navbarInnerStyle.
  dynamic get navbarInnerStyle => <String, dynamic>{
        'background': navbarBgColor,
      };

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final h = _barHeight(context);
    final bg = UPUtils.parseColor(bgColor) ?? tokens.cardBgColor;
    final statusBg = UPUtils.parseColor(statusBarBgColor) ?? bg;
    final tColor = UPUtils.parseColor(titleColor) ?? tokens.mainColor;
    final iconColor = UPUtils.parseColor(leftIconColor) ?? tokens.mainColor;
    final topInset = safeAreaInsetTop ? MediaQuery.paddingOf(context).top : 0.0;
    final titleW = UPUtils.getPx(
      titleWidth,
      screenWidth: MediaQuery.sizeOf(context).width,
    );
    final titleText = '$title';

    final bar = SizedBox(
      height: h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // left
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () => _leftTap(context),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: leftSlot ??
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (leftIcon.isNotEmpty)
                          UPIcon(
                            name: leftIcon,
                            size: leftIconSize,
                            color: iconColor,
                          ),
                        if (leftText.isNotEmpty) ...[
                          const SizedBox(width: 3),
                          Text(
                            leftText,
                            style: TextStyle(color: iconColor, fontSize: 15),
                          ),
                        ],
                      ],
                    ),
              ),
            ),
          ),
          // center title (IgnorePointer so side hit targets stay clickable)
          IgnorePointer(
            child: centerSlot ??
                (titleText.isEmpty
                    ? const SizedBox.shrink()
                    : SizedBox(
                        width: titleW,
                        child: Text(
                          titleText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: tColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ).merge(titleStyle),
                        ),
                      )),
          ),
          // right
          if (rightSlot != null || rightIcon.isNotEmpty || rightText.isNotEmpty)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: onRightClick,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: rightSlot ??
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (rightIcon.isNotEmpty)
                            UPIcon(
                              name: rightIcon,
                              size: 20,
                              color: tColor,
                            ),
                          if (rightText.isNotEmpty) ...[
                            if (rightIcon.isNotEmpty) const SizedBox(width: 3),
                            Text(
                              rightText,
                              style: TextStyle(color: tColor, fontSize: 15),
                            ),
                          ],
                        ],
                      ),
                ),
              ),
            ),
        ],
      ),
    );

    Widget inner = Container(
      decoration: BoxDecoration(
        color: bg,
        border: border
            ? Border(
                bottom: BorderSide(color: tokens.borderColor, width: 0.5),
              )
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (safeAreaInsetTop)
            SizedBox(height: topInset, child: ColoredBox(color: statusBg)),
          bar,
        ],
      ),
    );

    final totalH = h + topInset;
    if (fixed) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (placeholder) SizedBox(height: totalH),
          // For fixed usage inside body trees; host can also put in Stack.
          Material(
            color: Colors.transparent,
            elevation: 0,
            child: inner,
          ),
        ],
      );
    }
    return inner;
  }
}
