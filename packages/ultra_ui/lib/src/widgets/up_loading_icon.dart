import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';

final Expando<Map<String, dynamic>> _upLoadingIconState =
    Expando<Map<String, dynamic>>('upLoadingIconState');

/// Minimal 1:1-oriented port of u-loading-icon used by UPButton.
class UPLoadingIcon extends StatefulWidget {
  const UPLoadingIcon({
    super.key,
    this.mode = 'spinner',
    this.size = 24,
    this.color,
    this.text = '',
    this.textSize = 15,
    this.vertical = false,
    this.show = true,
    this.inactiveColor,
    this.textColor,
    this.timingFunction = 'ease-in-out',
    this.styles,
    this.customStyle,
  });

  final String mode;
  final dynamic size;
  final dynamic color;
  final String text;
  final dynamic textSize;
  final bool vertical;
  final bool show;
  final dynamic inactiveColor;
  final dynamic textColor;
  final String timingFunction;

  /// Source retained styles map.
  final dynamic styles;
  final BoxDecoration? customStyle;

  /// Source computed: otherBorderColor.
  dynamic get otherBorderColor {
    if (mode == 'circle') {
      if (inactiveColor != null && '$inactiveColor'.trim().isNotEmpty) {
        return inactiveColor;
      }
      final start = color ?? '#909399';
      final light = UPUtils.colorGradient(start, '#ffffff', 100);
      return light.length > 80 ? light[80] : '#ffffff';
    }
    return 'transparent';
  }

  /// Source data defaults.
  dynamic get aniAngel => 360;
  Map<String, dynamic> get _state =>
      _upLoadingIconState[this] ??= <String, dynamic>{
        'webviewHide': false,
        'loading': false,
      };
  dynamic get webviewHide => _state['webviewHide'] == true;
  dynamic get loading => _state['loading'] == true;

  @override
  State<UPLoadingIcon> createState() => UPLoadingIconState();
}

class UPLoadingIconState extends State<UPLoadingIcon>
    with SingleTickerProviderStateMixin {
  /// Source host helper.
  Future<void> setTimeout([dynamic cb, int ms = 0]) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
    if (cb is Function) cb();
  }

  /// Source data.
  List get array12 => List.generate(12, (i) => i);
  int get length => 12;

  late final AnimationController _controller;

  bool get isAnimating => _controller.isAnimating;

  void start() {
    widget._state['loading'] = true;
    widget._state['webviewHide'] = false;
    if (!_controller.isAnimating) {
      _controller.repeat();
      setState(() {});
    }
  }

  void stop() {
    widget._state['loading'] = false;
    _controller.stop();
    setState(() {});
  }

  /// Source `init` / `startAnimate`.
  void init() => start();
  void startAnimate() => start();

  /// Host-only webview listener retained for API parity.
  bool listenerAttached = false;
  bool get webviewHide => widget.webviewHide == true;
  bool get loading => widget.loading == true || isAnimating;
  void addEventListenerToWebview([dynamic _]) {
    listenerAttached = true;
    widget._state['webviewHide'] = true;
  }

  void nvueAnimate() => start();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    if (widget.show) {
      widget._state['loading'] = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show) return const SizedBox.shrink();
    final tokens = UPThemeTokens.of(context);
    final size = UPUtils.getPx(widget.size);
    final color =
        UPUtils.parseColor(widget.color, fallback: tokens.tipsColor) ??
            tokens.tipsColor;

    final spinner = SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: CustomPaint(
              painter: _SpinnerPainter(color: color),
            ),
          );
        },
      ),
    );

    Widget body;
    if (widget.text.isEmpty) {
      body = spinner;
    } else {
      final textWidget = Text(
        widget.text,
        style: TextStyle(
          color: color,
          fontSize: UPUtils.getPx(widget.textSize),
          height: 1.0,
        ),
      );
      if (widget.vertical) {
        body = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            spinner,
            const SizedBox(height: 4),
            textWidget,
          ],
        );
      } else {
        body = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            spinner,
            const SizedBox(width: 4),
            textWidget,
          ],
        );
      }
    }

    if (widget.customStyle != null) {
      body = Container(decoration: widget.customStyle, child: body);
    }
    return body;
  }
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, size.shortestSide / 8)
      ..strokeCap = StrokeCap.round
      ..color = color;
    final rect = Offset.zero & size;
    canvas.drawArc(
      rect.deflate(paint.strokeWidth),
      -math.pi / 2,
      math.pi * 1.4,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
