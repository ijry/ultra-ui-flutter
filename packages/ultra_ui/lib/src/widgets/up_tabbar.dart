import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_badge.dart';
import 'up_icon.dart';
import 'up_safe_bottom.dart';

final Expando<Map<String, dynamic>> _upTabbarState =
    Expando<Map<String, dynamic>>('upTabbarState');
final Expando<Map<String, dynamic>> _upTabbarItemState =
    Expando<Map<String, dynamic>>('upTabbarItemState');
final Expando<Object> _upTabbarItemActive =
    Expando<Object>('upTabbarItemActive');
final Expando<Map<String, dynamic>> _upTabbarItemParentData =
    Expando<Map<String, dynamic>>('upTabbarItemParentData');

class UPTabbar extends StatelessWidget {
  const UPTabbar({
    super.key,
    this.value,
    this.modelValue,
    this.safeAreaInsetBottom = true,
    this.border = true,
    this.zIndex = 1,
    this.activeColor = '#1989fa',
    this.inactiveColor = '#7d7e80',
    this.fixed = true,
    this.placeholder = true,
    this.borderColor = '',
    this.backgroundColor = '',
    this.styleType = 'default',
    this.animationType = 'none',
    this.activeBackgroundColor = '',
    this.inactiveBackgroundColor = '',
    this.itemShape = 'default',
    this.iconScale = 1.1,
    this.textMode = 'always',
    this.onChange,
    this.onUpdateValue,
    this.onUpdateModelValue,
    required this.children,
    this.customStyle,
  });

  /// Source data `placeholderHeight` — default measured height when fixed+placeholder.
  double get placeholderHeight => (fixed && placeholder) ? 50 : 0;
  final dynamic value;

  /// Source v-model / modelValue alias.
  final dynamic modelValue;
  final bool safeAreaInsetBottom;
  final bool border;
  final dynamic zIndex;
  final dynamic activeColor;
  final dynamic inactiveColor;
  final bool fixed;
  final bool placeholder;
  final dynamic borderColor;
  final dynamic backgroundColor;
  final String styleType;
  final String animationType;
  final dynamic activeBackgroundColor;
  final dynamic inactiveBackgroundColor;
  final String itemShape;
  final dynamic iconScale;
  final String textMode;
  final ValueChanged<dynamic>? onChange;

  /// Source update:value alias.
  final ValueChanged<dynamic>? onUpdateValue;

  /// Source update:modelValue alias.
  final ValueChanged<dynamic>? onUpdateModelValue;
  dynamic get effectiveValue => modelValue ?? value;
  final List<Widget> children;

  final BoxDecoration? customStyle;

  /// Source `updateChildren` (InheritedWidget rebuild handles sync).
  Map<String, dynamic> get _state =>
      _upTabbarState[this] ??= <String, dynamic>{'childrenVersion': 0};
  int get childrenVersion => (_state['childrenVersion'] as int?) ?? 0;
  void updateChildren([dynamic _]) {
    _state['childrenVersion'] = childrenVersion + 1;
  }

  /// Source `updateChild` alias.
  void updateChild([dynamic _]) => updateChildren(_);

  /// Source `updatePlaceholder` — returns current placeholder height.
  double updatePlaceholder([dynamic _]) => placeholderHeight;

  /// Source `setPlaceholderHeight` — host default content height when fixed.
  Future<double> setPlaceholderHeight() async {
    if (!fixed || !placeholder) return 0;
    return placeholderHeight;
  }

  /// Source computed: tabbarStyle.
  dynamic get tabbarStyle {
    final style = <String, dynamic>{
      'zIndex': zIndex,
      'backgroundColor':
          (backgroundColor != null && '$backgroundColor'.trim().isNotEmpty)
              ? backgroundColor
              : '#ffffff',
      '--up-tabbar-active-bg': (activeBackgroundColor != null &&
              '$activeBackgroundColor'.trim().isNotEmpty)
          ? activeBackgroundColor
          : 'transparent',
      '--up-tabbar-inactive-bg': (inactiveBackgroundColor != null &&
              '$inactiveBackgroundColor'.trim().isNotEmpty)
          ? inactiveBackgroundColor
          : 'transparent',
      '--up-tabbar-icon-scale': '$iconScale',
    };
    if (borderColor != null && '$borderColor'.trim().isNotEmpty) {
      style['borderColor'] = '$borderColor !important';
    } else {
      style['borderColor'] = '#dadbde';
    }
    if (const {'pill', 'card', 'glow', 'convex'}.contains(styleType)) {
      style['padding'] = '8rpx 12rpx 12rpx';
    }
    return style;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final bg =
        UPUtils.parseColor(backgroundColor, fallback: tokens.cardBgColor) ??
            tokens.cardBgColor;
    final bc = UPUtils.parseColor(borderColor, fallback: tokens.borderColor) ??
        tokens.borderColor;
    final baseDecoration = BoxDecoration(
      color: bg,
      border: border ? Border(top: BorderSide(color: bc, width: 0.5)) : null,
    );
    final customDecoration = customStyle;
    final contentDecoration = customDecoration == null
        ? baseDecoration
        : BoxDecoration(
            color: customDecoration.gradient == null
                ? customDecoration.color ?? baseDecoration.color
                : null,
            image: customDecoration.image ?? baseDecoration.image,
            border: customDecoration.border ?? baseDecoration.border,
            borderRadius: customDecoration.shape == BoxShape.circle
                ? null
                : customDecoration.borderRadius ?? baseDecoration.borderRadius,
            boxShadow: customDecoration.boxShadow ?? baseDecoration.boxShadow,
            gradient: customDecoration.gradient ?? baseDecoration.gradient,
            backgroundBlendMode: customDecoration.backgroundBlendMode ??
                baseDecoration.backgroundBlendMode,
            shape: customDecoration.shape,
          );

    final bar = _UPTabbarScope(
      value: effectiveValue,
      activeColor: UPUtils.parseColor(activeColor) ?? const Color(0xFF1989FA),
      inactiveColor:
          UPUtils.parseColor(inactiveColor) ?? const Color(0xFF7D7E80),
      textMode: textMode,
      iconScale: (num.tryParse('$iconScale') ?? 1.1).toDouble(),
      onChange: (v) {
        onChange?.call(v);
        onUpdateValue?.call(v);
        onUpdateModelValue?.call(v);
      },
      child: Container(
        key: const ValueKey('up-tabbar-content'),
        decoration: contentDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 50,
              child: Row(
                children: children
                    .map((c) => Expanded(child: c))
                    .toList(growable: false),
              ),
            ),
            if (safeAreaInsetBottom) const UPSafeBottom(),
          ],
        ),
      ),
    );

    Widget root = !fixed
        ? bar
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (placeholder) const SizedBox(height: 50),
              bar,
            ],
          );
    return root;
  }
}

class _UPTabbarScope extends InheritedWidget {
  const _UPTabbarScope({
    required this.value,
    required this.activeColor,
    required this.inactiveColor,
    required this.textMode,
    required this.iconScale,
    required this.onChange,
    required super.child,
  });

  final dynamic value;
  final Color activeColor;
  final Color inactiveColor;
  final String textMode;
  final double iconScale;
  final ValueChanged<dynamic>? onChange;

  static _UPTabbarScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_UPTabbarScope>();

  @override
  bool updateShouldNotify(covariant _UPTabbarScope oldWidget) {
    return value != oldWidget.value ||
        activeColor != oldWidget.activeColor ||
        inactiveColor != oldWidget.inactiveColor ||
        textMode != oldWidget.textMode;
  }
}

class UPTabbarItem extends StatelessWidget {
  const UPTabbarItem({
    super.key,
    this.name,
    this.icon = '',
    this.activeIcon = '',
    this.inactiveIcon = '',
    this.badge,
    this.dot = false,
    this.text = '',
    this.badgeStyle = 'top: 6px;right:2px;',
    this.mode = '',
    this.activeClass = '',
    this.inactiveClass = '',
    this.midButtonBgColor = '',
    this.midButtonIconColor = '',
    this.midButtonIconSize = 26,
    this.midButtonBoxShadow = '',
    this.midButtonInnerBoxShadow = '',
    this.midButtonOffsetY = -10,
    this.customStyle,
    this.onClick,
  });

  final dynamic name;
  final String icon;
  final String activeIcon;
  final String inactiveIcon;
  final dynamic badge;
  final bool dot;
  final String text;
  final String badgeStyle;
  final String mode;
  final String activeClass;
  final String inactiveClass;
  final dynamic midButtonBgColor;
  final dynamic midButtonIconColor;
  final dynamic midButtonIconSize;
  final dynamic midButtonBoxShadow;
  final dynamic midButtonInnerBoxShadow;
  final dynamic midButtonOffsetY;
  final BoxDecoration? customStyle;
  final VoidCallback? onClick;

  /// Source `init`.
  Map<String, dynamic> get _state =>
      _upTabbarItemState[this] ??= <String, dynamic>{'initialized': false};
  bool get initialized => _state['initialized'] == true;
  void init() {
    updateParentData();
  }

  /// Source `updateParentData` / `updateFromParent`.
  void updateParentData() {
    _state['initialized'] = true;
  }

  void updateFromParent() {
    updateParentData();
  }

  /// Source `clickHandler`.
  void clickHandler([BuildContext? context]) {
    onClick?.call();
    if (context != null) {
      _UPTabbarScope.of(context)?.onChange?.call(name);
    }
  }

  /// Source data defaults (filled by parent scope at runtime).
  dynamic get isActive => _upTabbarItemActive[this] == true;

  /// Source data: parentData (runtime filled from parent scope).
  dynamic get parentData =>
      _upTabbarItemParentData[this] ??
      const <String, dynamic>{
        'activeColor': '#1989fa',
        'inactiveColor': '#7d7e80',
        'styleType': 'default',
        'animationType': 'none',
        'itemShape': 'default',
        'activeBackgroundColor': '',
        'inactiveBackgroundColor': '',
        'textMode': 'always',
      };

  /// Source computed: isMidButton.
  bool get isMidButton => mode == 'midButton';

  /// Source computed: resolvedActiveColor.
  dynamic get resolvedActiveColor {
    final c = parentData is Map ? parentData['activeColor'] : null;
    if (c == null || '$c' == '' || '$c' == '#1989fa') return '#1989fa';
    return c;
  }

  /// Source computed: resolvedInactiveColor.
  dynamic get resolvedInactiveColor {
    final c = parentData is Map ? parentData['inactiveColor'] : null;
    if (c == null || '$c' == '' || '$c' == '#7d7e80') return '#7d7e80';
    return c;
  }

  /// Source computed: resolvedStyleType.
  dynamic get resolvedStyleType {
    final v = parentData is Map ? parentData['styleType'] : null;
    return (v == null || '$v' == '') ? 'default' : v;
  }

  /// Source computed: resolvedAnimationType.
  dynamic get resolvedAnimationType {
    final v = parentData is Map ? parentData['animationType'] : null;
    return (v == null || '$v' == '') ? 'none' : v;
  }

  /// Source computed: resolvedItemShape.
  dynamic get resolvedItemShape {
    final v = parentData is Map ? parentData['itemShape'] : null;
    return (v == null || '$v' == '') ? 'default' : v;
  }

  /// Source computed: resolvedIconName.
  dynamic get resolvedIconName {
    if (isActive == true) {
      return activeIcon.isNotEmpty ? activeIcon : icon;
    }
    return inactiveIcon.isNotEmpty ? inactiveIcon : icon;
  }

  /// Source computed: resolvedMidButtonIconColor.
  dynamic get resolvedMidButtonIconColor {
    if (midButtonIconColor != null && '$midButtonIconColor'.trim().isNotEmpty) {
      return midButtonIconColor;
    }
    return isMidButton ? '#3c9cff' : resolvedActiveColor;
  }

  /// Source computed: midButtonIconStyle.
  ///
  /// Lifts the mid-button icon above the notch cut-out.
  Map<String, dynamic> get midButtonIconStyle => isMidButton
      ? <String, dynamic>{'position': 'relative', 'zIndex': 2}
      : const <String, dynamic>{};

  /// Source computed: hasMidButtonText.
  bool get hasMidButtonText => text.isNotEmpty;

  /// Source computed: resolvedMidButtonOffsetY — defaults to -10 when the prop
  /// is not a finite number.
  double get resolvedMidButtonOffsetY {
    final offset = double.tryParse('$midButtonOffsetY');
    return (offset != null && offset.isFinite) ? offset : -10;
  }

  /// Source computed: midButtonTranslateY.
  String get midButtonTranslateY => '${resolvedMidButtonOffsetY}px';

  /// Source computed: midButtonBorderClipHeight.
  ///
  /// How much of the ring's border is clipped by the bar. The base differs with
  /// text because a labelled mid button sits lower in the bar; raising the
  /// button (a more negative offset) exposes more of the ring, and the result is
  /// clamped to 0..64.
  String get midButtonBorderClipHeight {
    final clipBaseHeight = hasMidButtonText ? 15.5 : 7.0;
    final clipHeight = clipBaseHeight - resolvedMidButtonOffsetY;
    return '${clipHeight.clamp(0.0, 64.0)}px';
  }

  /// Source computed: midButtonBorderCircleStyle — the ring only takes the
  /// parent's border color, so it stays flush with the bar's own border.
  Map<String, dynamic> get midButtonBorderCircleStyle {
    final borderColor = parentData is Map ? parentData['borderColor'] : null;
    if (!isMidButton || borderColor == null || '$borderColor'.isEmpty) {
      return const <String, dynamic>{};
    }
    return <String, dynamic>{'borderColor': borderColor};
  }

  /// Source computed: itemClassNames.
  dynamic get itemClassNames {
    final list = <String>[
      isActive == true ? 'u-tabbar-item--active' : 'u-tabbar-item--inactive',
      if (isMidButton) 'u-tabbar-item--mid-button',
      'u-tabbar-item--$resolvedStyleType',
      if (resolvedAnimationType != 'none' && isActive == true)
        'u-tabbar-item--anim-$resolvedAnimationType',
      if (resolvedItemShape != 'default')
        'u-tabbar-item--shape-$resolvedItemShape',
      isActive == true ? activeClass : inactiveClass,
    ];
    return list.where((e) => e.isNotEmpty).join(' ');
  }

  /// Source computed: iconClassNames.
  dynamic get iconClassNames {
    final list = <String>[
      if (isMidButton) 'u-tabbar-item__icon--mid-button',
      'u-tabbar-item__icon--$resolvedStyleType',
      if (isActive == true && resolvedAnimationType != 'none')
        'u-tabbar-item__icon--anim-$resolvedAnimationType',
    ];
    return list.where((e) => e.isNotEmpty).join(' ');
  }

  /// Source computed: contentClassNames.
  dynamic get contentClassNames {
    final list = <String>[
      'u-tabbar-item__content--$resolvedStyleType',
      if (isMidButton) 'u-tabbar-item__content--mid-button',
    ];
    return list.where((e) => e.isNotEmpty).join(' ');
  }

  /// Source computed: bubbleClassNames.
  dynamic get bubbleClassNames {
    final list = <String>[
      'u-tabbar-item__bubble--$resolvedStyleType',
      if (isActive == true) 'u-tabbar-item__bubble--active',
      if (isMidButton) 'u-tabbar-item__bubble--mid-button',
    ];
    return list.where((e) => e.isNotEmpty).join(' ');
  }

  /// Source computed: textClassNames.
  dynamic get textClassNames {
    final textMode = parentData is Map ? parentData['textMode'] : 'always';
    final list = <String>[
      'u-tabbar-item__text--$resolvedStyleType',
      if (textMode == 'active' && isActive != true)
        'u-tabbar-item__text--muted',
    ];
    return list.where((e) => e.isNotEmpty).join(' ');
  }

  /// Source computed: itemInlineStyle.
  dynamic get itemInlineStyle {
    final activeBg =
        parentData is Map ? parentData['activeBackgroundColor'] : '';
    final inactiveBg =
        parentData is Map ? parentData['inactiveBackgroundColor'] : '';
    return <String, dynamic>{
      'backgroundColor': isActive == true
          ? ((activeBg != null && '$activeBg'.trim().isNotEmpty)
              ? activeBg
              : 'transparent')
          : ((inactiveBg != null && '$inactiveBg'.trim().isNotEmpty)
              ? inactiveBg
              : 'transparent'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final scope = _UPTabbarScope.of(context);
    final parent = context.findAncestorWidgetOfExactType<UPTabbar>();
    final active = scope?.value == name;
    _upTabbarItemActive[this] = active;
    _upTabbarItemParentData[this] = <String, dynamic>{
      'activeColor': parent?.activeColor ?? '#1989fa',
      'inactiveColor': parent?.inactiveColor ?? '#7d7e80',
      'styleType': parent?.styleType ?? 'default',
      'animationType': parent?.animationType ?? 'none',
      'itemShape': parent?.itemShape ?? 'default',
      'activeBackgroundColor': parent?.activeBackgroundColor ?? '',
      'inactiveBackgroundColor': parent?.inactiveBackgroundColor ?? '',
      'textMode': parent?.textMode ?? scope?.textMode ?? 'always',
      // Source midButtonBorderCircleStyle reads the parent's border color so
      // the mid-button ring stays flush with the bar's own border.
      'borderColor': parent?.borderColor ?? '',
    };
    final color = active
        ? (scope?.activeColor ?? const Color(0xFF1989FA))
        : (scope?.inactiveColor ?? const Color(0xFF7D7E80));
    final iconName = active
        ? (activeIcon.isNotEmpty
            ? activeIcon
            : (icon.isNotEmpty ? icon : inactiveIcon))
        : (inactiveIcon.isNotEmpty
            ? inactiveIcon
            : (icon.isNotEmpty ? icon : activeIcon));
    final iconSize = 22.0 * (active ? (scope?.iconScale ?? 1.1) : 1.0);
    final showText = scope?.textMode != 'active' || active;
    final activeBackground = active
        ? (parent?.activeBackgroundColor ?? '')
        : (parent?.inactiveBackgroundColor ?? '');
    final baseDecoration = BoxDecoration(
      color: UPUtils.parseColor(activeBackground) ?? const Color(0x00000000),
    );
    final customDecoration = customStyle;
    final itemDecoration = customDecoration == null
        ? baseDecoration
        : BoxDecoration(
            color: customDecoration.gradient == null
                ? customDecoration.color ?? baseDecoration.color
                : null,
            image: customDecoration.image ?? baseDecoration.image,
            border: customDecoration.border ?? baseDecoration.border,
            borderRadius: customDecoration.shape == BoxShape.circle
                ? null
                : customDecoration.borderRadius ?? baseDecoration.borderRadius,
            boxShadow: customDecoration.boxShadow ?? baseDecoration.boxShadow,
            gradient: customDecoration.gradient ?? baseDecoration.gradient,
            backgroundBlendMode: customDecoration.backgroundBlendMode ??
                baseDecoration.backgroundBlendMode,
            shape: customDecoration.shape,
          );

    Widget iconWidget = iconName.isEmpty
        ? const SizedBox(width: 22, height: 22)
        : UPIcon(name: iconName, size: iconSize, color: color);

    if (dot || badge != null) {
      iconWidget = UPBadge(
        isDot: dot,
        value: badge,
        child: iconWidget,
      );
    }

    Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        iconWidget,
        if (showText && text.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 11),
          ),
        ],
      ],
    );

    if (isMidButton) {
      // Source mid-button: a raised circle straddling the bar's top edge, with
      // a ring in the bar's own border color and the icon lifted above it.
      final midBg =
          UPUtils.parseColor(midButtonBgColor) ?? const Color(0xFFFFFFFF);
      final ringColor = UPUtils.parseColor(
        (parentData is Map ? parentData['borderColor'] : null) ??
            midButtonBorderCircleStyle['borderColor'],
      );
      const diameter = 50.0;
      // The raised circle plus its label is taller than the 50px bar. The
      // source lets it overflow the bar via CSS; on Flutter the subtree needs
      // its own unbounded vertical constraint, or the Column overflows.
      content = Transform.translate(
        // Negative offset raises the button out of the bar.
        offset: Offset(0, resolvedMidButtonOffsetY),
        child: OverflowBox(
          alignment: Alignment.center,
          maxHeight: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  color: midBg,
                  shape: BoxShape.circle,
                  border:
                      ringColor == null ? null : Border.all(color: ringColor),
                  boxShadow: UPUtils.parseColor(midButtonBoxShadow) == null
                      ? null
                      : <BoxShadow>[
                          BoxShadow(
                            color: UPUtils.parseColor(midButtonBoxShadow)!,
                            blurRadius: 4,
                          ),
                        ],
                ),
                child: Center(
                  child: iconName.isEmpty
                      ? const SizedBox.shrink()
                      : UPIcon(
                          name: iconName,
                          size: UPUtils.getPx(midButtonIconSize),
                          color:
                              UPUtils.parseColor(resolvedMidButtonIconColor) ??
                                  color,
                        ),
                ),
              ),
              if (hasMidButtonText && showText) ...[
                const SizedBox(height: 2),
                Text(text, style: TextStyle(color: color, fontSize: 11)),
              ],
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        onClick?.call();
        scope?.onChange?.call(name);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        key: ValueKey('up-tabbar-item-$name'),
        decoration: itemDecoration,
        // Mid-button content overflows the bar, so it must not be clipped.
        clipBehavior: Clip.none,
        child: content,
      ),
    );
  }
}
