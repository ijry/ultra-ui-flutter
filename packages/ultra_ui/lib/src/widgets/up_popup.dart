import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';
import 'up_overlay.dart';

/// 1:1 port of u-popup defaults and layout modes.
class UPPopup extends StatefulWidget {
  const UPPopup({
    super.key,
    this.show = false,
    this.overlay = true,
    this.mode = 'bottom',
    this.duration = 300,
    this.closeable = false,
    this.closeOnClickOverlay = true,
    this.zIndex = 10075,
    this.safeAreaInsetBottom = true,
    this.safeAreaInsetTop = false,
    this.closeIconPos = 'top-right',
    this.round = '20px',
    this.zoom = true,
    this.bgColor = '',
    this.overlayOpacity = 0.5,
    this.overlayStyle,
    this.pageInline = false,
    this.touchable = false,
    this.minHeight = '200px',
    this.maxHeight = '600px',
    this.onClose,
    this.onClosed,
    this.onUpdateShow,
    this.onOpen,
    this.child,
    this.customStyle,
  });

  final bool show;
  final bool overlay;
  final String mode;
  final dynamic duration;
  final bool closeable;
  final bool closeOnClickOverlay;
  final dynamic zIndex;
  final bool safeAreaInsetBottom;
  final bool safeAreaInsetTop;
  final String closeIconPos;
  final dynamic round;
  final bool zoom;
  final dynamic bgColor;
  final dynamic overlayOpacity;
  final dynamic overlayStyle;
  final bool pageInline;
  final bool touchable;
  final dynamic minHeight;
  final dynamic maxHeight;
  final VoidCallback? onClose;

  /// Source emit `closed` — fires after the leave animation, when the popup has
  /// actually disappeared, unlike [onClose] which fires at dismissal.
  final VoidCallback? onClosed;

  /// Source update:show alias.
  final ValueChanged<bool>? onUpdateShow;
  final VoidCallback? onOpen;
  final Widget? child;
  final BoxDecoration? customStyle;

  /// Source computed: transitionStyle.
  dynamic get transitionStyle {
    final style = <String, dynamic>{
      'display': 'flex',
    };
    if (!pageInline) {
      style['zIndex'] = zIndex;
      style['position'] = 'fixed';
    }
    style[mode] = 0;
    switch (mode) {
      case 'left':
      case 'right':
        style.addAll({'bottom': 0, 'top': 0});
        break;
      case 'top':
      case 'bottom':
        style.addAll({'left': 0, 'right': 0});
        break;
      case 'center':
        style.addAll({
          'alignItems': 'center',
          'justify-content': 'center',
          'top': 0,
          'left': 0,
          'right': 0,
          'bottom': 0,
        });
        break;
    }
    return style;
  }

  /// Source computed: closeIconColor.
  dynamic get closeIconColor => '#606266';

  /// Source computed: indicatorStyle.
  dynamic get indicatorStyle => const <String, dynamic>{
        'backgroundColor': '#c0c4cc',
      };

  /// Source computed: contentStyle.
  dynamic get contentStyle {
    final style = <String, dynamic>{};
    if (mode != 'center') {
      style['flex'] = 1;
    }
    style['backgroundColor'] =
        (bgColor != null && '$bgColor'.trim().isNotEmpty) ? bgColor : '#ffffff';
    if (round != null && '$round'.trim().isNotEmpty && '$round' != '0') {
      final value = UPUtils.addUnit(round);
      if (mode == 'top') {
        style['borderBottomLeftRadius'] = value;
        style['borderBottomRightRadius'] = value;
      } else if (mode == 'bottom') {
        style['borderTopLeftRadius'] = value;
        style['borderTopRightRadius'] = value;
      } else if (mode == 'center') {
        style['borderRadius'] = value;
      }
    }
    return style;
  }

  /// Source computed: contentStyleWrap (widget-level; height filled by state when resized).
  dynamic contentStyleWrap([dynamic _]) {
    final style = <String, dynamic>{};
    if (mode == 'bottom' && touchable) {
      if (maxHeight != null && '$maxHeight'.trim().isNotEmpty) {
        style['maxHeight'] = UPUtils.addUnit(maxHeight);
      }
      if (minHeight != null && '$minHeight'.trim().isNotEmpty) {
        style['minHeight'] = UPUtils.addUnit(minHeight);
      }
    }
    return style;
  }

  /// Source computed: position transition name.
  dynamic get position {
    switch (mode) {
      case 'center':
        return zoom ? 'fade-zoom' : 'fade';
      case 'left':
        return 'slide-left';
      case 'right':
        return 'slide-right';
      case 'bottom':
        return 'slide-up';
      case 'top':
        return 'slide-down';
      default:
        return mode;
    }
  }

  @override
  State<UPPopup> createState() => UPPopupState();
}

class UPPopupState extends State<UPPopup> {
  /// Source host helper.
  Future<void> sleep([int ms = 0]) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
  }

  /// Source host helper.
  double parseFloat([dynamic v]) => double.tryParse('$v') ?? 0;

  bool? _localShow;

  /// Pending `closed` emission, cancelled if the popup reopens first.
  Timer? _closedTimer;

  bool get isShown => _localShow ?? widget.show;

  /// Source data.
  double currentHeight = 0;
  bool isTouching = false;
  double overlayDuration = 0;
  double touchStartHeight = 0;
  double touchStartY = 0;
  double touchDeltaY = 0;
  bool entered = false;
  int rectRetryCount = 0;
  int noopCount = 0;

  /// Source style helpers (Batch K + BO).
  String get position => widget.mode;

  /// Source computed: contentStyleWrap (runtime height from touch resize).
  Map contentStyleWrap([dynamic _]) {
    final style = <String, dynamic>{};
    if (widget.mode == 'bottom' && widget.touchable) {
      // Source keeps currentHeight as 'auto' until user resizes; 0 means auto here.
      if (currentHeight > 0) {
        style['height'] = UPUtils.addUnit(currentHeight);
      }
      if (widget.maxHeight != null && '${widget.maxHeight}'.trim().isNotEmpty) {
        style['maxHeight'] = UPUtils.addUnit(widget.maxHeight);
      }
      if (widget.minHeight != null && '${widget.minHeight}'.trim().isNotEmpty) {
        style['minHeight'] = UPUtils.addUnit(widget.minHeight);
      }
    }
    return style;
  }

  void open({bool emit = true}) {
    if (isShown) return;
    setState(() => _localShow = true);
    if (emit) {
      widget.onOpen?.call();
      widget.onUpdateShow?.call(true);
    }
  }

  void close({bool emit = true}) {
    if (!isShown) return;
    setState(() => _localShow = false);
    if (emit) {
      widget.onClose?.call();
      widget.onUpdateShow?.call(false);
    }
    // `closed` follows the leave animation regardless of how the popup was
    // dismissed, including a silent programmatic close.
    _scheduleClosed();
  }

  void toggle({bool emit = true}) {
    if (isShown) {
      close(emit: emit);
    } else {
      open(emit: emit);
    }
  }

  /// Source `overlayClick`.
  void overlayClick() {
    if (!widget.closeOnClickOverlay) return;
    close();
  }

  /// Source `clickHandler`.
  void clickHandler() => close();

  /// Source `afterEnter`.
  void afterEnter([dynamic _]) {
    entered = true;
    if (mounted) setState(() {});
  }

  /// Source `afterLeave` — the leave animation finished and the popup is gone.
  ///
  /// Distinct from `close`, which fires the moment dismissal is requested.
  void afterLeave([dynamic _]) {
    entered = false;
    widget.onClosed?.call();
  }

  /// Schedules [afterLeave] for when the leave transition ends.
  ///
  /// The source gets this from its transition's own `afterLeave`; in
  /// `pageInline` mode no leave animation runs, so it re-emits after the
  /// configured duration instead. Both paths land here.
  void _scheduleClosed() {
    _closedTimer?.cancel();
    final ms = int.tryParse('${widget.duration}') ?? 300;
    if (ms <= 0) {
      afterLeave();
      return;
    }
    _closedTimer = Timer(Duration(milliseconds: ms), () {
      if (mounted) afterLeave();
    });
  }

  double _eventY(dynamic e) {
    if (e is num) return e.toDouble();
    if (e is Offset) return e.dy;
    if (e is Map) {
      final y = e['clientY'] ?? e['pageY'] ?? e['y'] ?? e['dy'];
      if (y is num) return y.toDouble();
      return double.tryParse('$y') ?? 0;
    }
    return 0;
  }

  double _heightPx(dynamic value, Size viewport) {
    final text = '${value ?? ''}'.trim();
    if (text.endsWith('%')) {
      final percent = double.tryParse(text.substring(0, text.length - 1)) ?? 0;
      return viewport.height * percent / 100;
    }
    return UPUtils.getPx(value);
  }

  ({double min, double max}) _touchHeightBounds() {
    final viewport = MediaQuery.sizeOf(context);
    final min = _heightPx(widget.minHeight, viewport);
    final configuredMax = _heightPx(widget.maxHeight, viewport);
    final max = configuredMax > 0 ? configuredMax : viewport.height * 0.8;
    return (min: min, max: max < min ? min : max);
  }

  double _currentPanelHeight() {
    final renderObject = _panelKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      return renderObject.size.height;
    }
    return 0;
  }

  /// Source touch helpers for bottom resize mode.
  void onTouchStart([dynamic e]) {
    isTouching = true;
    touchStartY = _eventY(e);
    // uview reads the transition element's live height. Preserve an
    // explicitly supplied currentHeight for imperative compatibility.
    touchStartHeight =
        currentHeight > 0 ? currentHeight : _currentPanelHeight();
    if (touchStartHeight <= 0) {
      touchStartHeight = _touchHeightBounds().min;
    }
    touchDeltaY = 0;
  }

  void onTouchMove([dynamic e]) {
    if (!isTouching) return;
    final y = _eventY(e);
    touchDeltaY = y - touchStartY;
    if (widget.mode == 'bottom') {
      var next = touchStartHeight - touchDeltaY;
      if (widget.touchable) {
        final bounds = _touchHeightBounds();
        next = next.clamp(bounds.min, bounds.max);
      } else {
        // Historical Flutter port callers invoke the public helpers directly
        // even when touchable is false; retain that behavior without layout
        // constraints while the actual touch area remains touchable-only.
        next = next.clamp(0.0, double.infinity);
      }
      currentHeight = next.toDouble();
      if (mounted) setState(() {});
    }
  }

  void onTouchEnd([dynamic e]) {
    // Source closes after a sufficiently large downward drag.
    final shouldClose = widget.mode == 'bottom' && touchDeltaY > 100;
    isTouching = false;
    touchDeltaY = 0;
    if (shouldClose) {
      close();
    } else if (mounted) {
      setState(() {});
    }
  }

  void noop([dynamic _]) {
    noopCount += 1;
  }

  void retryComputedComponentRect([dynamic _]) {
    rectRetryCount += 1;
  }

  /// Source `getWindowInfo`.
  Map getWindowInfo() {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    return {
      'windowWidth': size.width,
      'windowHeight': size.height,
      'screenWidth': size.width,
      'screenHeight': size.height,
      'statusBarHeight': padding.top,
      'safeArea': {
        'left': padding.left,
        'right': padding.right,
        'top': padding.top,
        'bottom': padding.bottom,
      },
    };
  }

  @override
  void didUpdateWidget(covariant UPPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.show != widget.show) {
      _localShow = null;
      if (widget.show) {
        // Reopened before the previous leave finished: cancel the pending emit.
        _closedTimer?.cancel();
      } else {
        // Source watcher re-emits for an external show -> false, so `closed`
        // is observable no matter how the popup was dismissed.
        _scheduleClosed();
      }
    }
  }

  @override
  void dispose() {
    _closedTimer?.cancel();
    super.dispose();
  }

  Alignment get _alignment {
    switch (widget.mode) {
      case 'top':
        return Alignment.topCenter;
      case 'left':
        return Alignment.centerLeft;
      case 'right':
        return Alignment.centerRight;
      case 'center':
        return Alignment.center;
      case 'bottom':
      default:
        return Alignment.bottomCenter;
    }
  }

  BorderRadius _radius(double r) {
    switch (widget.mode) {
      case 'top':
        return BorderRadius.vertical(bottom: Radius.circular(r));
      case 'bottom':
        return BorderRadius.vertical(top: Radius.circular(r));
      case 'center':
        return BorderRadius.circular(r);
      default:
        return BorderRadius.zero;
    }
  }

  final GlobalKey _panelKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final ms = int.tryParse('${widget.duration}') ?? 300;
    final r = UPUtils.getPx(widget.round);
    final bg = UPUtils.parseColor(widget.bgColor) ?? tokens.cardBgColor;
    final media = MediaQuery.of(context);
    final baseDecoration = BoxDecoration(
      color: bg,
      borderRadius: _radius(r),
    );
    final customDecoration = widget.customStyle;
    final panelDecoration = customDecoration == null
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

    Widget panel = Container(
      decoration: panelDecoration,
      child: KeyedSubtree(
        key: const ValueKey('up-popup-panel'),
        child: Material(
          key: _panelKey,
          color: Colors.transparent,
          borderRadius: _radius(r),
          child: SafeArea(
            top: widget.safeAreaInsetTop,
            bottom: widget.safeAreaInsetBottom,
            left: false,
            right: false,
            child: Stack(
              children: [
                if (widget.child != null) widget.child!,
                if (widget.touchable && widget.mode == 'bottom')
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: UPUtils.rpx2px(42, screenWidth: media.size.width),
                    child: GestureDetector(
                      key: const ValueKey('up-popup-touch-area'),
                      behavior: HitTestBehavior.opaque,
                      onVerticalDragStart: (details) =>
                          onTouchStart(details.globalPosition),
                      onVerticalDragUpdate: (details) =>
                          onTouchMove(details.globalPosition),
                      onVerticalDragEnd: (details) =>
                          onTouchEnd(details.globalPosition),
                      onVerticalDragCancel: () => onTouchEnd(),
                      child: Center(
                        child: Container(
                          width: 100,
                          height: 5,
                          decoration: BoxDecoration(
                            color: tokens.lightColor,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (widget.closeable)
                  Positioned(
                    top: widget.closeIconPos.contains('top') ? 12 : null,
                    bottom: widget.closeIconPos.contains('bottom') ? 12 : null,
                    left: widget.closeIconPos.contains('left') ? 12 : null,
                    right: widget.closeIconPos.contains('right') ? 12 : null,
                    child: GestureDetector(
                      onTap: close,
                      child: UPIcon(
                        name: 'close',
                        size: 18,
                        bold: true,
                        color: tokens.contentColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.mode == 'left' || widget.mode == 'right') {
      panel = SizedBox(
        width: media.size.width * 0.8,
        height: double.infinity,
        child: panel,
      );
    } else if (widget.mode == 'top' || widget.mode == 'bottom') {
      final minHeight = _heightPx(widget.minHeight, media.size);
      final maxHeight = _heightPx(widget.maxHeight, media.size);
      final constraints = BoxConstraints(
        minHeight: minHeight,
        maxHeight: maxHeight > 0 ? maxHeight : double.infinity,
        minWidth: double.infinity,
      );
      final resizedHeight =
          widget.mode == 'bottom' && widget.touchable && currentHeight > 0
              ? currentHeight.clamp(
                  constraints.minHeight,
                  constraints.maxHeight,
                )
              : null;
      panel = ConstrainedBox(
        constraints: constraints,
        child: resizedHeight == null
            ? panel
            : SizedBox(height: resizedHeight, child: panel),
      );
    } else {
      panel = ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: media.size.width * 0.85,
        ),
        child: panel,
      );
    }

    if (widget.pageInline) {
      return _UPPopupLifecycle(
        show: isShown,
        duration: ms,
        onOpen: widget.onOpen,
        child: isShown ? panel : const SizedBox.shrink(),
      );
    }

    final root = _UPPopupLifecycle(
      show: isShown,
      duration: ms,
      onOpen: widget.onOpen,
      child: Stack(
        children: [
          if (widget.overlay)
            Positioned.fill(
              child: UPOverlay(
                show: isShown,
                duration: ms + 50,
                opacity: widget.overlayOpacity,
                zIndex: widget.zIndex,
                customStyle: widget.overlayStyle is BoxDecoration
                    ? widget.overlayStyle as BoxDecoration
                    : null,
                rootOverlay: false,
                onClick: widget.closeOnClickOverlay ? close : null,
              ),
            ),
          AnimatedAlign(
            duration: Duration(milliseconds: ms),
            alignment: _alignment,
            curve: Curves.easeOut,
            child: AnimatedSlide(
              duration: Duration(milliseconds: ms),
              offset: isShown
                  ? Offset.zero
                  : (widget.mode == 'top'
                      ? const Offset(0, -1)
                      : widget.mode == 'left'
                          ? const Offset(-1, 0)
                          : widget.mode == 'right'
                              ? const Offset(1, 0)
                              : widget.mode == 'center'
                                  ? Offset.zero
                                  : const Offset(0, 1)),
              child: AnimatedOpacity(
                duration: Duration(milliseconds: ms),
                opacity: isShown ? 1 : 0,
                child: AnimatedScale(
                  duration: Duration(milliseconds: ms),
                  scale: widget.mode == 'center' && widget.zoom
                      ? (isShown ? 1 : 0.8)
                      : 1,
                  child: IgnorePointer(
                    ignoring: !isShown,
                    child: panel,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return root;
  }
}

class _UPPopupLifecycle extends StatefulWidget {
  const _UPPopupLifecycle({
    required this.show,
    required this.duration,
    required this.child,
    this.onOpen,
  });

  final bool show;
  final int duration;
  final Widget child;
  final VoidCallback? onOpen;

  @override
  State<_UPPopupLifecycle> createState() => _UPPopupLifecycleState();
}

class _UPPopupLifecycleState extends State<_UPPopupLifecycle> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.show) _scheduleOpen();
  }

  @override
  void didUpdateWidget(covariant _UPPopupLifecycle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.show && widget.show) {
      _scheduleOpen();
    } else if (oldWidget.show && !widget.show) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _scheduleOpen() {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: widget.duration), () {
      if (mounted) widget.onOpen?.call();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
