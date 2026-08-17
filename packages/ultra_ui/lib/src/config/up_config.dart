import 'package:flutter/material.dart';

/// Mutable runtime config store, mirroring uview-plus setConfig.
class UPConfig extends ChangeNotifier {
  UPConfigData config = UPConfigData();
  UPColorData color = UPColorData();
  UPZIndexData zIndex = UPZIndexData();
  UPPropsData props = UPPropsData();

  void merge({
    UPConfigData? config,
    UPColorData? color,
    UPZIndexData? zIndex,
    UPPropsData? props,
  }) {
    if (config != null) this.config = this.config.merge(config);
    if (color != null) this.color = this.color.merge(color);
    if (zIndex != null) this.zIndex = this.zIndex.merge(zIndex);
    if (props != null) this.props = this.props.merge(props);
    notifyListeners();
  }
}

class UPConfigData {
  const UPConfigData({
    this.version = '3',
    this.unit = 'px',
    this.iconUrl =
        'https://at.alicdn.com/t/font_2225171_8kdcwk4po24.ttf',
    this.loadFontOnce = false,
    this.nativeThemeSync = false,
  });

  final String version;
  final String unit;
  final String iconUrl;
  final bool loadFontOnce;
  final bool nativeThemeSync;

  static const type = <String>[
    'primary',
    'success',
    'info',
    'error',
    'warning',
  ];

  UPConfigData merge(UPConfigData other) {
    return UPConfigData(
      version: other.version,
      unit: other.unit,
      iconUrl: other.iconUrl,
      loadFontOnce: other.loadFontOnce,
      nativeThemeSync: other.nativeThemeSync,
    );
  }
}

class UPColorData {
  const UPColorData({
    this.primary = const Color(0xFF3C9CFF),
    this.info = const Color(0xFF909399),
    this.warning = const Color(0xFFF9AE3D),
    this.error = const Color(0xFFF56C6C),
    this.success = const Color(0xFF5AC725),
    this.mainColor = const Color(0xFF303133),
    this.contentColor = const Color(0xFF606266),
    this.tipsColor = const Color(0xFF909399),
    this.lightColor = const Color(0xFFC0C4CC),
    this.borderColor = const Color(0xFFE4E7ED),
  });

  final Color primary;
  final Color info;
  final Color warning;
  final Color error;
  final Color success;
  final Color mainColor;
  final Color contentColor;
  final Color tipsColor;
  final Color lightColor;
  final Color borderColor;

  Color byType(String type) {
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

  UPColorData merge(UPColorData other) => other;
}

class UPZIndexData {
  const UPZIndexData({
    this.toast = 10090,
    this.noNetwork = 10080,
    this.popup = 10075,
    this.mask = 10070,
    this.navbar = 980,
    this.topTips = 975,
    this.sticky = 970,
    this.indexListSticky = 965,
  });

  final int toast;
  final int noNetwork;
  final int popup;
  final int mask;
  final int navbar;
  final int topTips;
  final int sticky;
  final int indexListSticky;

  UPZIndexData merge(UPZIndexData other) => other;
}

class UPPropsData {
  const UPPropsData({
    this.button = const UPButtonProps(),
    this.icon = const UPIconProps(),
    this.loadingIcon = const UPLoadingIconProps(),
  });

  final UPButtonProps button;
  final UPIconProps icon;
  final UPLoadingIconProps loadingIcon;

  UPPropsData merge(UPPropsData other) {
    return UPPropsData(
      button: other.button,
      icon: other.icon,
      loadingIcon: other.loadingIcon,
    );
  }
}

class UPButtonProps {
  const UPButtonProps({
    this.hairline = false,
    this.type = 'info',
    this.size = 'normal',
    this.shape = 'square',
    this.plain = false,
    this.disabled = false,
    this.loading = false,
    this.loadingText = '',
    this.loadingMode = 'spinner',
    this.loadingSize = 15,
    this.throttleTime = 0,
    this.hoverStartTime = 0,
    this.hoverStayTime = 200,
    this.text = '',
    this.icon = '',
    this.iconColor = '',
    this.color = '',
    this.stop = true,
  });

  final bool hairline;
  final String type;
  final String size;
  final String shape;
  final bool plain;
  final bool disabled;
  final bool loading;
  final String loadingText;
  final String loadingMode;
  final num loadingSize;
  final num throttleTime;
  final num hoverStartTime;
  final num hoverStayTime;
  final String text;
  final String icon;
  final String iconColor;
  final String color;
  final bool stop;
}

class UPIconProps {
  const UPIconProps({
    this.name = '',
    this.color,
    this.size = '16px',
    this.bold = false,
    this.index = '',
    this.customPrefix = 'uicon',
    this.label = '',
    this.labelPos = 'right',
    this.labelSize = '15px',
    this.labelColor,
    this.space = '3px',
    this.width = '',
    this.height = '',
    this.top = 0,
    this.stop = false,
  });

  final String name;
  final Color? color;
  final dynamic size;
  final bool bold;
  final dynamic index;
  final String customPrefix;
  final dynamic label;
  final String labelPos;
  final dynamic labelSize;
  final Color? labelColor;
  final dynamic space;
  final dynamic width;
  final dynamic height;
  final dynamic top;
  final bool stop;
}

class UPLoadingIconProps {
  const UPLoadingIconProps({
    this.mode = 'spinner',
    this.size = 24,
    this.color,
    this.text = '',
    this.textSize = 15,
    this.vertical = false,
  });

  final String mode;
  final num size;
  final Color? color;
  final String text;
  final num textSize;
  final bool vertical;
}
