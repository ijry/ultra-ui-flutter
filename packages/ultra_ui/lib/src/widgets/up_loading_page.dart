import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_image.dart';
import 'up_loading_icon.dart';
import 'up_overlay.dart';

/// 1:1 port of u-loading-page.
class UPLoadingPage extends StatelessWidget {
  const UPLoadingPage({
    super.key,
    this.loadingText = '正在加载',
    this.image = '',
    this.loadingMode = 'circle',
    this.loading = false,
    this.bgColor = '',
    this.color = '#C8C8C8',
    this.fontSize = 19,
    // Source props.js resolves its default from loadingPage.fontSize.
    this.iconSize = 19,
    this.loadingColor = '#C8C8C8',
    this.zIndex = 10,
    this.customStyle,
    this.child,
  });

  final dynamic loadingText;
  final String image;
  final String loadingMode;
  final bool loading;
  final dynamic bgColor;
  final dynamic color;
  final dynamic fontSize;
  final dynamic iconSize;
  final dynamic loadingColor;
  final dynamic zIndex;
  final BoxDecoration? customStyle;
  final Widget? child;

  /// Source computed: overlayStyle.
  dynamic get overlayStyle {
    final style = <String, dynamic>{
      'position': 'fixed',
      'top': 0,
      'left': 0,
      'right': 0,
      'bottom': 0,
      'backgroundColor': (bgColor != null && '$bgColor'.trim().isNotEmpty)
          ? bgColor
          : '#f3f4f6',
      'display': 'flex',
      'zIndex': zIndex,
    };
    if (customStyle != null) {
      style.addAll(<String, dynamic>{
        if (customStyle!.color != null) 'color': customStyle!.color,
      });
    }
    return style;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final bg = UPUtils.parseColor(bgColor, fallback: tokens.pageBgColor) ??
        tokens.pageBgColor;
    final textColor =
        UPUtils.parseColor(color, fallback: const Color(0xFFC8C8C8)) ??
            const Color(0xFFC8C8C8);
    final fs = UPUtils.getPx(fontSize);
    final sourceDecoration = BoxDecoration(color: bg);
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

    return UPOverlay(
      show: loading,
      zIndex: zIndex,
      duration: 300,
      opacity: 0,
      child: Positioned.fill(
        child: Container(
          decoration: decoration,
          alignment: Alignment.center,
          child: Transform.translate(
            offset: const Offset(0, -150),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (image.isNotEmpty)
                  UPImage(
                    src: image,
                    width: iconSize,
                    height: iconSize,
                  )
                else
                  UPLoadingIcon(
                    mode: loadingMode,
                    size: iconSize,
                    color: loadingColor,
                  ),
                const SizedBox(height: 10),
                child ??
                    Text(
                      '$loadingText',
                      style: TextStyle(color: textColor, fontSize: fs),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
