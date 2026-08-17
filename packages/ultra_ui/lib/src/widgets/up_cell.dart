import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';
import 'up_layout.dart';
import 'up_link.dart';

class UPCellGroup extends StatelessWidget {
  const UPCellGroup({
    super.key,
    this.title = '',
    this.border = true,
    this.customStyle,
    this.children = const <Widget>[],
  });

  final String title;
  final bool border;
  final BoxDecoration? customStyle;
  final List<Widget> children;

  /// Source computed: groupStyle.
  dynamic get groupStyle => const <String, dynamic>{
        'backgroundColor': '#ffffff',
      };

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final sourceDecoration = BoxDecoration(color: tokens.cardBgColor);
    final callerDecoration = customStyle;
    final decoration = callerDecoration == null
        ? sourceDecoration
        : BoxDecoration(
            color: callerDecoration.gradient == null
                ? callerDecoration.color ?? sourceDecoration.color
                : null,
            image: callerDecoration.image ?? sourceDecoration.image,
            border: callerDecoration.border ?? sourceDecoration.border,
            borderRadius: callerDecoration.shape == BoxShape.circle
                ? null
                : callerDecoration.borderRadius ??
                    sourceDecoration.borderRadius,
            boxShadow: callerDecoration.boxShadow ?? sourceDecoration.boxShadow,
            gradient: callerDecoration.gradient ?? sourceDecoration.gradient,
            backgroundBlendMode: callerDecoration.backgroundBlendMode ??
                sourceDecoration.backgroundBlendMode,
            shape: callerDecoration.shape,
          );
    return Container(
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                title,
                style: TextStyle(
                  color: tokens.mainColor,
                  fontSize: 15,
                  height: 16 / 15,
                ),
              ),
            ),
          Column(
            children: [
              if (border) UPLine(color: tokens.borderColor),
              ...children,
            ],
          ),
        ],
      ),
    );
  }
}

/// Host-injectable page open hook for cell [url] navigation.
typedef UPOpenPageHandler = Future<void> Function(
  String url, {
  String linkType,
});

/// 1:1 port of u-cell.
class UPCell extends StatelessWidget {
  const UPCell({
    super.key,
    this.title = '',
    this.label = '',
    this.value = '',
    this.icon = '',
    this.disabled = false,
    this.border = true,
    this.center = false,
    this.url = '',
    this.linkType = 'navigateTo',
    this.clickable = false,
    this.isLink = false,
    this.required = false,
    this.arrowDirection = '',
    this.rightIcon = 'arrow-right',
    this.size = '',
    this.stop = true,
    this.name = '',
    this.titleStyle,
    this.iconStyle,
    this.rightIconStyle,
    this.titleSlot,
    this.valueSlot,
    this.labelSlot,
    this.iconSlot,
    this.rightIconSlot,
    this.onClick,
    this.customStyle,
  });

  /// Optional host page open handler (app router).
  static UPOpenPageHandler? openPageHandler;

  final dynamic title;
  final dynamic label;
  final dynamic value;
  final String icon;
  final bool disabled;
  final bool border;
  final bool center;
  final String url;
  final String linkType;
  final bool clickable;
  final bool isLink;
  final bool required;
  final String arrowDirection;
  final String rightIcon;
  final String size;
  final bool stop;
  final dynamic name;
  final TextStyle? titleStyle;
  final TextStyle? iconStyle;
  final TextStyle? rightIconStyle;
  final Widget? titleSlot;
  final Widget? valueSlot;
  final Widget? labelSlot;
  final Widget? iconSlot;
  final Widget? rightIconSlot;

  /// Accepts `void Function()` or `void Function(dynamic name|{name})`.
  final dynamic onClick;
  final BoxDecoration? customStyle;

  bool get _hasValue {
    if (value == null) return false;
    if (value is String) return value.toString().isNotEmpty;
    return true;
  }

  Future<void> _handleTap() async {
    if (disabled) return;
    final cb = onClick;
    if (cb is void Function(dynamic)) {
      cb({'name': name});
    } else if (cb is VoidCallback) {
      cb();
    } else if (cb is Function) {
      try {
        cb({'name': name});
      } catch (_) {
        try {
          cb(name);
        } catch (_) {
          cb();
        }
      }
    }
    if (url.isNotEmpty) {
      final pageHandler = openPageHandler;
      if (pageHandler != null) {
        await pageHandler(url, linkType: linkType);
      } else if (UPLink.openLinkHandler != null) {
        await UPLink.openLinkHandler!(url);
      }
    }
  }

  double get _arrowTurns {
    switch (arrowDirection) {
      case 'left':
        return 0.5;
      case 'up':
        return -0.25;
      case 'down':
        return 0.25;
      default:
        return 0;
    }
  }

  /// Source `clickHandler`.
  void clickHandler() {
    // Fire tap path without awaiting navigation for API compatibility.
    // ignore: discarded_futures
    _handleTap();
  }

  /// Source computed: titleTextStyle (addStyle(titleStyle)).
  dynamic get titleTextStyle {
    if (titleStyle == null) return const <String, dynamic>{};
    final s = titleStyle!;
    return <String, dynamic>{
      if (s.color != null) 'color': UPUtils.colorToHex(s.color),
      if (s.fontSize != null) 'fontSize': s.fontSize,
      if (s.fontWeight != null) 'fontWeight': s.fontWeight.toString(),
      if (s.height != null) 'lineHeight': s.height,
    };
  }

  /// Source computed: cellDisabledColor.
  dynamic get cellDisabledColor => '#c8c9cc';

  /// Source computed: cellTitleDynamicStyle.
  dynamic get cellTitleDynamicStyle {
    final style = <String, dynamic>{
      'color': disabled ? cellDisabledColor : '#303133',
    };
    final ts = titleTextStyle;
    if (ts is Map) style.addAll(Map<String, dynamic>.from(ts));
    return style;
  }

  /// Source computed: cellLabelDynamicStyle.
  dynamic get cellLabelDynamicStyle => <String, dynamic>{
        'color': disabled ? cellDisabledColor : '#909399',
      };

  /// Source computed: cellValueDynamicStyle.
  dynamic get cellValueDynamicStyle => <String, dynamic>{
        'color': disabled ? cellDisabledColor : '#606266',
      };

  /// Source host helper: testEmpty.
  dynamic testEmpty([dynamic v]) => null;

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final isLarge = size == 'large';
    final titleSize = isLarge ? 16.0 : 15.0;
    final valueSize = isLarge ? 15.0 : 14.0;
    final labelSize = isLarge ? 14.0 : 12.0;
    final leftIconSize = isLarge ? 22.0 : 18.0;
    final rightIconSize = isLarge ? 18.0 : 16.0;
    final canTap =
        !disabled && (clickable || isLink || onClick != null || url.isNotEmpty);

    final body = Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      color: customStyle == null ? tokens.cardBgColor : Colors.transparent,
      child: Row(
        crossAxisAlignment:
            center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (iconSlot != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: iconSlot,
                  )
                else if (icon.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: UPUtils.isImage(icon)
                        ? Image.network(
                            icon,
                            width: leftIconSize,
                            height: leftIconSize,
                            errorBuilder: (_, __, ___) => UPIcon(
                              name: 'photo',
                              size: leftIconSize,
                              color: tokens.contentColor,
                            ),
                          )
                        : UPIcon(
                            name: icon,
                            size: leftIconSize,
                            color: iconStyle?.color ?? tokens.contentColor,
                          ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (titleSlot != null)
                        titleSlot!
                      else if ('$title'.isNotEmpty)
                        Text(
                          '$title',
                          style: TextStyle(
                            color: disabled
                                ? tokens.disabledColor
                                : tokens.mainColor,
                            fontSize: titleSize,
                            height: 22 / titleSize,
                          ).merge(titleStyle),
                        ),
                      if (labelSlot != null || '$label'.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        labelSlot ??
                            Text(
                              '$label',
                              style: TextStyle(
                                color: disabled
                                    ? tokens.disabledColor
                                    : tokens.tipsColor,
                                fontSize: labelSize,
                                height: 18 / labelSize,
                              ),
                            ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (valueSlot != null)
            valueSlot!
          else if (_hasValue)
            Text(
              '$value',
              style: TextStyle(
                color: disabled ? tokens.disabledColor : tokens.contentColor,
                fontSize: valueSize,
                height: 24 / valueSize,
              ),
            ),
          if (rightIconSlot != null)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: rightIconSlot,
            )
          else if (isLink)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Transform.rotate(
                angle: _arrowTurns * 3.141592653589793 * 2,
                child: UPIcon(
                  name: rightIcon.isEmpty ? 'arrow-right' : rightIcon,
                  size: rightIconSize,
                  color: disabled
                      ? tokens.disabledColor
                      : (rightIconStyle?.color ?? tokens.lightColor),
                ),
              ),
            ),
        ],
      ),
    );

    // required star via Stack overlay like source ::before
    final withRequired = required
        ? Stack(
            children: [
              body,
              const Positioned(
                left: 8,
                top: 14,
                child: Text(
                  '*',
                  style: TextStyle(color: Color(0xFFF56C6C), fontSize: 14),
                ),
              ),
            ],
          )
        : body;

    return Container(
      decoration: customStyle,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: canTap ? () => _handleTap() : null,
              splashColor: const Color(0xFFF1F1F1),
              highlightColor: const Color(0xFFF1F1F1),
              child: withRequired,
            ),
          ),
          if (border)
            UPLine(
              color: tokens.borderColor,
              hairline: true,
              margin: 0,
            ),
        ],
      ),
    );
  }
}
