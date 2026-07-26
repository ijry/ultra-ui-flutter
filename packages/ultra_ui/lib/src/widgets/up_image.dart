import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';

final Expando<Map<String, dynamic>> _upImageLoadState =
    Expando<Map<String, dynamic>>('upImageLoadState');

class UPImage extends StatelessWidget {
  const UPImage({
    super.key,
    this.src = '',
    this.mode = 'aspectFill',
    this.width = '300',
    this.height = '225',
    this.shape = 'square',
    this.radius = 0,
    this.lazyLoad = true,
    this.showMenuByLongpress = true,
    this.loadingIcon = 'photo',
    this.errorIcon = 'error-circle',
    this.loadingWidget,
    this.errorWidget,
    this.showLoading = true,
    this.showError = true,
    this.fade = true,
    this.webp = false,
    this.duration = 500,
    this.bgColor = '#f3f4f6',
    this.backgroundStyle,
    this.customStyle,
    this.onClick,
    this.onLoad,
    this.onError,
  });

  final String src;
  final String mode;
  final dynamic width;
  final dynamic height;
  final String shape;
  final dynamic radius;
  final bool lazyLoad;
  final bool showMenuByLongpress;
  final String loadingIcon;
  final String errorIcon;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final bool showLoading;
  final bool showError;
  final bool fade;
  final bool webp;
  final num duration;
  final dynamic bgColor;

  /// Source retained background style map.
  final dynamic backgroundStyle;
  final BoxDecoration? customStyle;

  /// Source data (host-readable defaults).
  int get durationTime => int.tryParse('$duration') ?? 500;
  Map<String, dynamic> get _state =>
      _upImageLoadState[this] ??= <String, dynamic>{
        'isError': false,
        'loading': true,
        'lastLoad': null,
        'lastError': null,
      };
  bool get isError => _state['isError'] == true;
  bool get loading => _state['loading'] != false;
  dynamic get lastLoadEvent => _state['lastLoad'];
  dynamic get lastErrorEvent => _state['lastError'];
  double get opacity => 1;
  bool get show => true;

  final VoidCallback? onClick;

  /// Source load/error emits.
  final ValueChanged<dynamic>? onLoad;
  final ValueChanged<dynamic>? onError;

  /// Source `clickHandler`.
  void clickHandler([dynamic _]) => onClick?.call();

  /// Source `onClickHandler` alias.
  void onClickHandler([dynamic _]) => clickHandler(_);

  /// Source load/error handlers (network/asset use errorBuilder internally).
  void onLoadHandler([dynamic event]) {
    final s = _state;
    s['loading'] = false;
    s['isError'] = false;
    s['lastLoad'] = event ?? true;
    onLoad?.call(event ?? true);
    removeBgColor();
  }

  void onErrorHandler([dynamic err]) {
    final s = _state;
    s['loading'] = false;
    s['isError'] = true;
    s['lastError'] = err ?? true;
    onError?.call(err ?? true);
  }

  void errorHandler([dynamic e]) => onErrorHandler(e);
  void loadHandler([dynamic e]) => onLoadHandler(e);

  /// Source `removeBgColor` — returns transparent for host to re-apply after load.
  dynamic removeBgColor([dynamic _]) => 'transparent';

  BoxFit get _fit {
    switch (mode) {
      case 'aspectFit':
      case 'contain':
        return BoxFit.contain;
      case 'widthFix':
      case 'heightFix':
      case 'scaleToFill':
        return BoxFit.fill;
      case 'aspectFill':
      case 'cover':
      default:
        return BoxFit.cover;
    }
  }

  /// Source computed: resolvedSizeStyle.
  dynamic get resolvedSizeStyle {
    final style = <String, dynamic>{};
    // Flutter host follows non-nvue rules.
    if (loading || isError || '$width' == '100%' || mode != 'heightFix') {
      style['width'] = UPUtils.addUnit(width);
    } else {
      style['width'] = 'fit-content';
    }
    if (loading || isError || '$height' == '100%' || mode != 'widthFix') {
      style['height'] = UPUtils.addUnit(height);
    } else {
      style['height'] = 'fit-content';
    }
    return style;
  }

  /// Source computed: transStyle.
  dynamic get transStyle {
    final style = <String, dynamic>{
      ...Map<String, dynamic>.from(resolvedSizeStyle as Map),
      'flexShrink': 0,
      'boxSizing': 'border-box',
      'maxWidth': '100%',
    };
    return style;
  }

  /// Source computed: wrapStyle.
  dynamic get wrapStyle {
    final style = <String, dynamic>{
      ...Map<String, dynamic>.from(resolvedSizeStyle as Map),
      'flexShrink': 0,
      'boxSizing': 'border-box',
      'maxWidth': '100%',
    };
    final widthText = '${style['width'] ?? ''}';
    final heightText = '${style['height'] ?? ''}';
    if (widthText.isNotEmpty &&
        widthText != 'fit-content' &&
        !widthText.contains('%')) {
      style['minWidth'] = widthText;
    }
    if (heightText.isNotEmpty &&
        heightText != 'fit-content' &&
        !heightText.contains('%')) {
      style['minHeight'] = heightText;
    }
    style['borderRadius'] =
        shape == 'circle' ? '10000px' : UPUtils.addUnit(radius);
    final radiusNumber =
        double.tryParse(RegExp(r'[\d.-]+').stringMatch('$radius') ?? '') ?? 0;
    final hasRadius = shape == 'circle' || radiusNumber > 0;
    style['overflow'] = hasRadius || mode == 'aspectFill' || mode == 'aspectFit'
        ? 'hidden'
        : 'visible';
    return style;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final w = UPUtils.getPx(width);
    final h = UPUtils.getPx(height);
    final r = shape == 'circle' ? 1000.0 : UPUtils.getPx(radius);
    final bg = UPUtils.parseColor(bgColor) ?? tokens.bgColor;
    final sourceDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(r),
    );
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
    final shouldClip = shape == 'circle' ||
        r > 0 ||
        mode == 'aspectFill' ||
        mode == 'aspectFit';
    final loadingChild = showLoading
        ? loadingWidget ??
            UPIcon(name: loadingIcon, size: 24, color: tokens.tipsColor)
        : null;
    final errorChild = showError
        ? errorWidget ??
            UPIcon(name: errorIcon, size: 24, color: tokens.tipsColor)
        : null;

    Widget image;
    if (src.isEmpty) {
      image = Container(
        width: w,
        height: h,
        color: bg,
        alignment: Alignment.center,
        child: errorWidget ?? loadingChild,
      );
    } else {
      final isNetwork = src.startsWith('http://') || src.startsWith('https://');
      image = isNetwork
          ? Image.network(
              src,
              width: w,
              height: h,
              fit: _fit,
              frameBuilder: fade
                  ? (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded || frame != null) {
                        return child;
                      }
                      return Container(
                        width: w,
                        height: h,
                        color: bg,
                        alignment: Alignment.center,
                        child: loadingChild,
                      );
                    }
                  : null,
              errorBuilder: (_, __, ___) => Container(
                width: w,
                height: h,
                color: bg,
                alignment: Alignment.center,
                child: errorChild,
              ),
            )
          : Image.asset(
              src,
              width: w,
              height: h,
              fit: _fit,
              errorBuilder: (_, __, ___) => Container(
                width: w,
                height: h,
                color: bg,
                alignment: Alignment.center,
                child: errorChild,
              ),
            );
    }

    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: w,
        height: h,
        decoration: decoration,
        clipBehavior: shouldClip ? Clip.hardEdge : Clip.none,
        child: image,
      ),
    );
  }
}
