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
    this.mode = 'default',
    this.scrollTop = 0,
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

  /// Source prop `mode`: 'default' or 'ios' (large frosted title).
  final String mode;

  /// Source prop `scrollTop`: page scroll offset, driving the iOS-mode
  /// compression. The source receives it from the page's `onPageScroll`; on
  /// Flutter the host passes its own scroll offset.
  final dynamic scrollTop;

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

  /// Source `LARGE_TITLE_HEIGHT`.
  ///
  /// Also the denominator of [navbarProgress], so changing it changes the
  /// scroll range over which the large title compresses.
  static const double kLargeTitleHeight = 52;

  /// Source computed: isIosMode.
  ///
  /// The source disables ios mode on nvue, which lacks the filter pipeline and
  /// reliable page scrolling. Flutter has neither limitation, so the mode is
  /// available whenever it is requested.
  bool get isIosMode => mode == 'ios';

  /// Source computed: largeTitleHeight — collapses to 0 with no title.
  double get largeTitleHeight => title.isNotEmpty ? kLargeTitleHeight : 0;

  /// Source computed: navbarProgress.
  ///
  /// 1 means the large title has just fully receded into the bar.
  double get navbarProgress {
    if (!isIosMode) return 1;
    final height = largeTitleHeight;
    if (height <= 0) return 1;
    final offset = UPUtils.getPx(scrollTop);
    return (offset / height).clamp(0.0, 1.0).toDouble();
  }

  /// Source computed: navbarGlassOpacity.
  ///
  /// The frost completes over the first half of the scroll, laying an opaque
  /// base before the centred title appears.
  double get navbarGlassOpacity {
    if (!isIosMode) return 0;
    return (navbarProgress / 0.5).clamp(0.0, 1.0).toDouble();
  }

  /// Source computed: navbarCenterOpacity.
  ///
  /// The centred title only starts appearing in the last quarter, once the
  /// glass is fully opaque, so it never bleeds through the large title.
  double get navbarCenterOpacity {
    if (!isIosMode) return 1;
    return ((navbarProgress - 0.75) / 0.25).clamp(0.0, 1.0).toDouble();
  }

  /// Source `CENTER_TITLE_RISE` — how far the centred title travels upward as
  /// it fades in.
  static const double kCenterTitleRise = 12;

  /// Source computed: navbarCenterStyle.
  ///
  /// The centred title rises into place over the same stretch as its fade, so
  /// the offset reaches zero exactly when it becomes fully opaque.
  Map<String, dynamic> get navbarCenterStyle {
    if (!isIosMode) return const <String, dynamic>{};
    final opacity = navbarCenterOpacity;
    return <String, dynamic>{
      'opacity': opacity,
      'transform': 'translateY(${(1 - opacity) * kCenterTitleRise}px)',
    };
  }

  /// Vertical offset the centred title is drawn at, from [navbarCenterStyle].
  double get navbarCenterTranslateY =>
      isIosMode ? (1 - navbarCenterOpacity) * kCenterTitleRise : 0;

  /// Source computed: navbarFlowSpacerHeight — in-flow spacer that reserves
  /// room for the fixed layer. Needs the context for the status-bar inset.
  double navbarFlowSpacerHeight(BuildContext context) {
    final statusBarHeight =
        safeAreaInsetTop ? MediaQuery.paddingOf(context).top : 0.0;
    return UPUtils.getPx(
          height,
          screenWidth: MediaQuery.sizeOf(context).width,
        ) +
        statusBarHeight;
  }

  /// Source computed: navbarGlassBgColor.
  ///
  /// The source's 0.82 opacity is a readability floor: where the backdrop blur
  /// does not apply, that alpha alone has to keep text legible over content.
  Color navbarGlassBgColor(BuildContext context) {
    final explicit = UPUtils.parseColor(bgColor);
    if (explicit != null) return explicit;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const Color(0xD11C1C1E) // rgba(28, 28, 30, 0.82)
        : const Color(0xD1FFFFFF); // rgba(255, 255, 255, 0.82)
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
  ///
  /// In ios mode the fixed layer must be transparent, or the backdrop filter
  /// samples its own background and blurs nothing; the glass layer supplies the
  /// background instead, fading in with scroll.
  dynamic get navbarInnerStyle => <String, dynamic>{
        'background': isIosMode ? 'transparent' : navbarBgColor,
      };

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final h = _barHeight(context);
    // Source uses a dedicated --up-navbar-bg-color; it currently matches
    // card-bg-color in both palettes, but reading the right token keeps this
    // correct if they diverge upstream.
    final bg = UPUtils.parseColor(bgColor) ?? tokens.navbarBgColor;
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
            child: Transform.translate(
              // Source navbarCenterStyle: rises as it fades in.
              offset: Offset(0, navbarCenterTranslateY),
              child: Opacity(
                // Source binds opacity here; in default mode this is always 1.
                opacity: navbarCenterOpacity,
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
            ),
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
        // Source: the fixed layer goes transparent in ios mode so the glass
        // layer below supplies the background.
        color: isIosMode ? Colors.transparent : bg,
        border: border && !isIosMode
            ? Border(
                bottom: BorderSide(color: tokens.borderColor, width: 0.5),
              )
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (safeAreaInsetTop)
            SizedBox(
              height: topInset,
              child: ColoredBox(
                color: isIosMode ? Colors.transparent : statusBg,
              ),
            ),
          bar,
        ],
      ),
    );

    final totalH = h + topInset;

    if (isIosMode) {
      // Source ios layout: an in-flow layer carrying the spacer and the large
      // title, with the bar fixed above it behind a scroll-driven glass layer.
      return Stack(
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: navbarFlowSpacerHeight(context)),
              if (titleText.isNotEmpty)
                SizedBox(
                  height: largeTitleHeight,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      child: Text(
                        titleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: tColor,
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                        ).merge(titleStyle),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: navbarGlassOpacity,
                      child: ColoredBox(color: navbarGlassBgColor(context)),
                    ),
                  ),
                ),
                inner,
              ],
            ),
          ),
        ],
      );
    }

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
