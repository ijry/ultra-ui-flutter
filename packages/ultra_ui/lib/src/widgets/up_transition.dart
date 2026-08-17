import 'dart:async';

import 'package:flutter/widgets.dart';

/// 1:1-oriented port of u-transition.
///
/// Supported modes: fade, zoom, fade-zoom, fade-up/down/left/right,
/// slide-up/down/left/right, and none.
class UPTransition extends StatefulWidget {
  const UPTransition({
    super.key,
    this.show = false,
    this.onUpdateShow,
    this.mode = 'fade',
    this.duration = '300',
    this.timingFunction = 'ease-out',
    this.onClick,
    this.onBeforeEnter,
    this.onEnter,
    this.onAfterEnter,
    this.onBeforeLeave,
    this.onLeave,
    this.onAfterLeave,
    this.child,
    this.viewStyle,
    this.customStyle,
  });

  final bool show;

  /// Source update:show alias.
  final ValueChanged<bool>? onUpdateShow;
  final String mode;
  final dynamic duration;
  final String timingFunction;
  final VoidCallback? onClick;
  final VoidCallback? onBeforeEnter;
  final VoidCallback? onEnter;
  final VoidCallback? onAfterEnter;
  final VoidCallback? onBeforeLeave;
  final VoidCallback? onLeave;
  final VoidCallback? onAfterLeave;
  final Widget? child;

  /// Source retained view style map.
  final dynamic viewStyle;
  final BoxDecoration? customStyle;

  @override
  State<UPTransition> createState() => UPTransitionState();
}

class UPTransitionState extends State<UPTransition> {
  /// Source retained class list.
  List get classes => [
        'up-transition',
        if (isShown) 'up-transition--show',
        'up-transition--${widget.mode}',
      ];
  Timer? _callbackTimer;
  bool? _localShow;

  bool get isShown => _localShow ?? widget.show;

  /// Source data.
  String get display => isShown ? 'flex' : 'none';
  bool inited = true;
  bool transitionEnded = true;

  /// Programmatic show (source enter path).
  /// Source `clickHandler`.
  void clickHandler() => widget.onClick?.call();

  /// Source enter/leave class helpers (Batch I).
  List getClassNames([String status = 'enter']) {
    final mode = widget.mode;
    if (status == 'leave') {
      return ['up-$mode-leave', 'up-$mode-leave-to', 'up-$mode-leave-active'];
    }
    return ['up-$mode-enter', 'up-$mode-enter-to', 'up-$mode-enter-active'];
  }

  void vueEnter([dynamic _]) => open();
  void vueLeave([dynamic _]) => close();
  void nvueEnter([dynamic _]) => open();
  void nvueLeave([dynamic _]) => close();
  void onTransitionEnd([dynamic _]) {
    if (isShown) {
      widget.onAfterEnter?.call();
    } else {
      widget.onAfterLeave?.call();
    }
  }

  Future<void> waitTick([int ms = 0]) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
  }

  /// Source residual helpers (Batch L).
  Map mergeStyle([dynamic a, dynamic b]) {
    final out = <String, dynamic>{};
    if (a is Map) out.addAll(Map<String, dynamic>.from(a));
    if (b is Map) out.addAll(Map<String, dynamic>.from(b));
    return out;
  }

  Future<void> setTimeout([dynamic cb, int ms = 0]) async {
    if (ms > 0) {
      await Future<void>.delayed(Duration(milliseconds: ms));
    }
    if (cb is Function) {
      cb();
    }
  }

  void open({bool emit = true}) {
    if (isShown) return;
    setState(() => _localShow = true);
    if (emit) {
      _runEnter();
      widget.onUpdateShow?.call(true);
    }
  }

  /// Programmatic hide (source leave path).
  void close({bool emit = true}) {
    if (!isShown) return;
    setState(() => _localShow = false);
    if (emit) {
      _runLeave();
      widget.onUpdateShow?.call(false);
    }
  }

  void toggle({bool emit = true}) {
    if (isShown) {
      close(emit: emit);
    } else {
      open(emit: emit);
    }
  }

  int get _ms => int.tryParse('${widget.duration}') ?? 300;

  Curve get _curve {
    final tf = widget.timingFunction;
    if (tf.contains('linear')) return Curves.linear;
    if (tf.contains('in-out')) return Curves.easeInOut;
    if (tf.contains('in')) return Curves.easeIn;
    return Curves.easeOut;
  }

  bool get _hasFade => widget.mode == 'fade' || widget.mode.startsWith('fade-');

  bool get _hasZoom => widget.mode == 'zoom' || widget.mode == 'fade-zoom';

  Offset get _hiddenOffset {
    switch (widget.mode) {
      case 'fade-up':
      case 'slide-up':
        return const Offset(0, 1);
      case 'fade-down':
      case 'slide-down':
        return const Offset(0, -1);
      case 'fade-left':
      case 'slide-left':
        return const Offset(-1, 0);
      case 'fade-right':
      case 'slide-right':
        return const Offset(1, 0);
      default:
        return Offset.zero;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.show) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _runEnter());
    }
  }

  @override
  void didUpdateWidget(covariant UPTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.show == widget.show) return;
    _localShow = null;
    if (widget.show) {
      _runEnter();
    } else {
      _runLeave();
    }
  }

  @override
  void dispose() {
    _callbackTimer?.cancel();
    super.dispose();
  }

  void _runEnter() {
    _callbackTimer?.cancel();
    widget.onBeforeEnter?.call();
    widget.onEnter?.call();
    _callbackTimer = Timer(Duration(milliseconds: _ms), () {
      if (mounted) widget.onAfterEnter?.call();
    });
  }

  void _runLeave() {
    _callbackTimer?.cancel();
    widget.onBeforeLeave?.call();
    widget.onLeave?.call();
    _callbackTimer = Timer(Duration(milliseconds: _ms), () {
      if (mounted) widget.onAfterLeave?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = widget.child ?? const SizedBox.shrink();
    if (widget.customStyle != null) {
      content = DecoratedBox(
        decoration: widget.customStyle!,
        child: content,
      );
    }

    if (widget.mode == 'none') {
      content = isShown
          ? content
          : IgnorePointer(child: Opacity(opacity: 0, child: content));
      Widget root = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: isShown ? widget.onClick : null,
        child: content,
      );
      return root;
    }

    if (_hiddenOffset != Offset.zero) {
      content = AnimatedSlide(
        offset: isShown ? Offset.zero : _hiddenOffset,
        duration: Duration(milliseconds: _ms),
        curve: _curve,
        child: content,
      );
    }

    if (_hasZoom) {
      content = AnimatedScale(
        scale: isShown ? 1 : 0.95,
        duration: Duration(milliseconds: _ms),
        curve: _curve,
        child: content,
      );
    }

    if (_hasFade) {
      content = AnimatedOpacity(
        opacity: isShown ? 1 : 0,
        duration: Duration(milliseconds: _ms),
        curve: _curve,
        child: content,
      );
    } else if (!isShown) {
      content = IgnorePointer(
        child: content,
      );
    }

    Widget root = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: isShown ? widget.onClick : null,
      child: IgnorePointer(
        ignoring: !isShown,
        child: content,
      ),
    );
    return root;
  }
}
