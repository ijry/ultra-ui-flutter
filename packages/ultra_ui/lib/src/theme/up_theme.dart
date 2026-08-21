import 'package:flutter/material.dart';

@immutable
class UPThemeTokens extends ThemeExtension<UPThemeTokens> {
  const UPThemeTokens({
    required this.mainColor,
    required this.contentColor,
    required this.tipsColor,
    required this.lightColor,
    required this.borderColor,
    required this.bgColor,
    required this.pageBgColor,
    required this.cardBgColor,
    required this.disabledColor,
    required this.primary,
    required this.primaryDark,
    required this.primaryDisabled,
    required this.primaryLight,
    required this.warning,
    required this.warningDark,
    required this.warningDisabled,
    required this.warningLight,
    required this.success,
    required this.successDark,
    required this.successDisabled,
    required this.successLight,
    required this.error,
    required this.errorDark,
    required this.errorDisabled,
    required this.errorLight,
    required this.info,
    required this.infoDark,
    required this.infoDisabled,
    required this.infoLight,
    required this.hoverBgColor,
    required this.navbarBgColor,
    required this.gapBgColor,
    required this.skeletonBgColor,
    required this.skeletonShimmerColor,
    required this.swipeActionButtonBgColor,
    required this.indexListIndicatorBgColor,
    required this.table2HeaderBgColor,
    required this.table2ZebraBgColor,
    required this.table2HighlightBgColor,
  });

  final Color mainColor;
  final Color contentColor;
  final Color tipsColor;
  final Color lightColor;
  final Color borderColor;
  final Color bgColor;
  final Color pageBgColor;
  final Color cardBgColor;
  final Color disabledColor;
  final Color primary;
  final Color primaryDark;
  final Color primaryDisabled;
  final Color primaryLight;
  final Color warning;
  final Color warningDark;
  final Color warningDisabled;
  final Color warningLight;
  final Color success;
  final Color successDark;
  final Color successDisabled;
  final Color successLight;
  final Color error;
  final Color errorDark;
  final Color errorDisabled;
  final Color errorLight;
  final Color info;
  final Color infoDark;
  final Color infoDisabled;
  final Color infoLight;

  /// Component-scoped tokens from the source's theme-vars-core.scss. They are
  /// separate variables there rather than reuses of the generic colors, so a
  /// component must not substitute e.g. bgColor for skeletonBgColor.
  final Color hoverBgColor;
  final Color navbarBgColor;
  final Color gapBgColor;
  final Color skeletonBgColor;
  final Color skeletonShimmerColor;
  final Color swipeActionButtonBgColor;
  final Color indexListIndicatorBgColor;
  final Color table2HeaderBgColor;
  final Color table2ZebraBgColor;
  final Color table2HighlightBgColor;

  factory UPThemeTokens.light() {
    return const UPThemeTokens(
      mainColor: Color(0xFF303133),
      contentColor: Color(0xFF606266),
      tipsColor: Color(0xFF909193),
      lightColor: Color(0xFFC0C4CC),
      borderColor: Color(0xFFDADBDE),
      bgColor: Color(0xFFF3F4F6),
      pageBgColor: Color(0xFFF3F4F6),
      cardBgColor: Color(0xFFFFFFFF),
      disabledColor: Color(0xFFC8C9CC),
      primary: Color(0xFF3C9CFF),
      primaryDark: Color(0xFF398ADE),
      primaryDisabled: Color(0xFF9ACAFC),
      primaryLight: Color(0xFFECF5FF),
      warning: Color(0xFFF9AE3D),
      warningDark: Color(0xFFF1A532),
      warningDisabled: Color(0xFFF9D39B),
      warningLight: Color(0xFFFDF6EC),
      success: Color(0xFF5AC725),
      successDark: Color(0xFF53C21D),
      successDisabled: Color(0xFFA9E08F),
      successLight: Color(0xFFF5FFF0),
      error: Color(0xFFF56C6C),
      errorDark: Color(0xFFE45656),
      errorDisabled: Color(0xFFF7B2B2),
      errorLight: Color(0xFFFEF0F0),
      info: Color(0xFF909399),
      infoDark: Color(0xFF767A82),
      infoDisabled: Color(0xFFC4C6C9),
      infoLight: Color(0xFFF4F4F5),
      hoverBgColor: Color(0xFFE7EBF0),
      navbarBgColor: Color(0xFFFFFFFF),
      gapBgColor: Color(0xFFF3F4F6),
      skeletonBgColor: Color(0xFFF1F2F4),
      skeletonShimmerColor: Color(0xFFE6E6E6),
      swipeActionButtonBgColor: Color(0xFFC7C6CD),
      indexListIndicatorBgColor: Color(0xFFC9C9C9),
      table2HeaderBgColor: Color(0xFFF5F7FA),
      table2ZebraBgColor: Color(0xFFFAFAFA),
      table2HighlightBgColor: Color(0xFFF5F7FA),
    );
  }

  factory UPThemeTokens.dark() {
    return const UPThemeTokens(
      mainColor: Color(0xFFF5F5F5),
      contentColor: Color(0xFFD1D5DB),
      tipsColor: Color(0xFF9CA3AF),
      lightColor: Color(0xFF6B7280),
      borderColor: Color(0xFF3A3A3C),
      bgColor: Color(0xFF1F1F1F),
      pageBgColor: Color(0xFF1F1F1F),
      cardBgColor: Color(0xFF1C1C1E),
      disabledColor: Color(0xFF4B5563),
      primary: Color(0xFF3C9CFF),
      primaryDark: Color(0xFF5AA8FF),
      primaryDisabled: Color(0xFF4C6F92),
      primaryLight: Color(0xFF10243A),
      warning: Color(0xFFF9AE3D),
      warningDark: Color(0xFFFFBF66),
      warningDisabled: Color(0xFF8A6A3A),
      warningLight: Color(0xFF3D2F1B),
      success: Color(0xFF5AC725),
      successDark: Color(0xFF7AD94B),
      successDisabled: Color(0xFF5F7F4F),
      successLight: Color(0xFF1F3316),
      error: Color(0xFFF56C6C),
      errorDark: Color(0xFFFF8A8A),
      errorDisabled: Color(0xFF8D5858),
      errorLight: Color(0xFF3A2222),
      info: Color(0xFF909399),
      infoDark: Color(0xFFB0B3B8),
      infoDisabled: Color(0xFF5F6368),
      infoLight: Color(0xFF2F3238),
      hoverBgColor: Color(0xFF343741),
      navbarBgColor: Color(0xFF1C1C1E),
      gapBgColor: Color(0xFF111111),
      skeletonBgColor: Color(0xFF2F3135),
      // rgba(255, 255, 255, 0.12) -> alpha byte 31.
      skeletonShimmerColor: Color(0x1FFFFFFF),
      swipeActionButtonBgColor: Color(0xFF4B5563),
      indexListIndicatorBgColor: Color(0xFF4B5563),
      table2HeaderBgColor: Color(0xFF2A2D33),
      table2ZebraBgColor: Color(0xFF23262B),
      table2HighlightBgColor: Color(0xFF2F3440),
    );
  }

  Color typeColor(String type) {
    switch (type) {
      case 'primary':
        return primary;
      case 'success':
        return success;
      case 'warning':
        return warning;
      case 'error':
        return error;
      case 'info':
      default:
        return info;
    }
  }

  @override
  UPThemeTokens copyWith({
    Color? mainColor,
    Color? contentColor,
    Color? tipsColor,
    Color? lightColor,
    Color? borderColor,
    Color? bgColor,
    Color? pageBgColor,
    Color? cardBgColor,
    Color? disabledColor,
    Color? primary,
    Color? primaryDark,
    Color? primaryDisabled,
    Color? primaryLight,
    Color? warning,
    Color? warningDark,
    Color? warningDisabled,
    Color? warningLight,
    Color? success,
    Color? successDark,
    Color? successDisabled,
    Color? successLight,
    Color? error,
    Color? errorDark,
    Color? errorDisabled,
    Color? errorLight,
    Color? info,
    Color? infoDark,
    Color? infoDisabled,
    Color? infoLight,
    Color? hoverBgColor,
    Color? navbarBgColor,
    Color? gapBgColor,
    Color? skeletonBgColor,
    Color? skeletonShimmerColor,
    Color? swipeActionButtonBgColor,
    Color? indexListIndicatorBgColor,
    Color? table2HeaderBgColor,
    Color? table2ZebraBgColor,
    Color? table2HighlightBgColor,
  }) {
    return UPThemeTokens(
      mainColor: mainColor ?? this.mainColor,
      contentColor: contentColor ?? this.contentColor,
      tipsColor: tipsColor ?? this.tipsColor,
      lightColor: lightColor ?? this.lightColor,
      borderColor: borderColor ?? this.borderColor,
      bgColor: bgColor ?? this.bgColor,
      pageBgColor: pageBgColor ?? this.pageBgColor,
      cardBgColor: cardBgColor ?? this.cardBgColor,
      disabledColor: disabledColor ?? this.disabledColor,
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryDisabled: primaryDisabled ?? this.primaryDisabled,
      primaryLight: primaryLight ?? this.primaryLight,
      warning: warning ?? this.warning,
      warningDark: warningDark ?? this.warningDark,
      warningDisabled: warningDisabled ?? this.warningDisabled,
      warningLight: warningLight ?? this.warningLight,
      success: success ?? this.success,
      successDark: successDark ?? this.successDark,
      successDisabled: successDisabled ?? this.successDisabled,
      successLight: successLight ?? this.successLight,
      error: error ?? this.error,
      errorDark: errorDark ?? this.errorDark,
      errorDisabled: errorDisabled ?? this.errorDisabled,
      errorLight: errorLight ?? this.errorLight,
      info: info ?? this.info,
      infoDark: infoDark ?? this.infoDark,
      infoDisabled: infoDisabled ?? this.infoDisabled,
      infoLight: infoLight ?? this.infoLight,
      hoverBgColor: hoverBgColor ?? this.hoverBgColor,
      navbarBgColor: navbarBgColor ?? this.navbarBgColor,
      gapBgColor: gapBgColor ?? this.gapBgColor,
      skeletonBgColor: skeletonBgColor ?? this.skeletonBgColor,
      skeletonShimmerColor: skeletonShimmerColor ?? this.skeletonShimmerColor,
      swipeActionButtonBgColor:
          swipeActionButtonBgColor ?? this.swipeActionButtonBgColor,
      indexListIndicatorBgColor:
          indexListIndicatorBgColor ?? this.indexListIndicatorBgColor,
      table2HeaderBgColor: table2HeaderBgColor ?? this.table2HeaderBgColor,
      table2ZebraBgColor: table2ZebraBgColor ?? this.table2ZebraBgColor,
      table2HighlightBgColor:
          table2HighlightBgColor ?? this.table2HighlightBgColor,
    );
  }

  @override
  UPThemeTokens lerp(ThemeExtension<UPThemeTokens>? other, double t) {
    if (other is! UPThemeTokens) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return UPThemeTokens(
      mainColor: l(mainColor, other.mainColor),
      contentColor: l(contentColor, other.contentColor),
      tipsColor: l(tipsColor, other.tipsColor),
      lightColor: l(lightColor, other.lightColor),
      borderColor: l(borderColor, other.borderColor),
      bgColor: l(bgColor, other.bgColor),
      pageBgColor: l(pageBgColor, other.pageBgColor),
      cardBgColor: l(cardBgColor, other.cardBgColor),
      disabledColor: l(disabledColor, other.disabledColor),
      primary: l(primary, other.primary),
      primaryDark: l(primaryDark, other.primaryDark),
      primaryDisabled: l(primaryDisabled, other.primaryDisabled),
      primaryLight: l(primaryLight, other.primaryLight),
      warning: l(warning, other.warning),
      warningDark: l(warningDark, other.warningDark),
      warningDisabled: l(warningDisabled, other.warningDisabled),
      warningLight: l(warningLight, other.warningLight),
      success: l(success, other.success),
      successDark: l(successDark, other.successDark),
      successDisabled: l(successDisabled, other.successDisabled),
      successLight: l(successLight, other.successLight),
      error: l(error, other.error),
      errorDark: l(errorDark, other.errorDark),
      errorDisabled: l(errorDisabled, other.errorDisabled),
      errorLight: l(errorLight, other.errorLight),
      info: l(info, other.info),
      infoDark: l(infoDark, other.infoDark),
      infoDisabled: l(infoDisabled, other.infoDisabled),
      infoLight: l(infoLight, other.infoLight),
      hoverBgColor: l(hoverBgColor, other.hoverBgColor),
      navbarBgColor: l(navbarBgColor, other.navbarBgColor),
      gapBgColor: l(gapBgColor, other.gapBgColor),
      skeletonBgColor: l(skeletonBgColor, other.skeletonBgColor),
      skeletonShimmerColor: l(skeletonShimmerColor, other.skeletonShimmerColor),
      swipeActionButtonBgColor:
          l(swipeActionButtonBgColor, other.swipeActionButtonBgColor),
      indexListIndicatorBgColor:
          l(indexListIndicatorBgColor, other.indexListIndicatorBgColor),
      table2HeaderBgColor: l(table2HeaderBgColor, other.table2HeaderBgColor),
      table2ZebraBgColor: l(table2ZebraBgColor, other.table2ZebraBgColor),
      table2HighlightBgColor:
          l(table2HighlightBgColor, other.table2HighlightBgColor),
    );
  }

  static UPThemeTokens of(BuildContext context) {
    return Theme.of(context).extension<UPThemeTokens>() ??
        UPThemeTokens.light();
  }
}
