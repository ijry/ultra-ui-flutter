import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../utils/up_utils.dart';

final Expando<Map<String, dynamic>> _upCircleProgressState =
    Expando<Map<String, dynamic>>('upCircleProgressState');

/// Flutter-complete circle progress.
/// Source u-circle-progress is marked TODO incomplete; this keeps API parity
/// with percentage / width / borderWidth / colors / child.
class UPCircleProgress extends StatelessWidget {
  const UPCircleProgress({
    super.key,
    this.percentage = 30,
    this.width = 100,
    this.borderWidth = 5,
    this.activeColor = const Color(0xFF42B983),
    this.inactiveColor = const Color(0xFFC8C8C8),
    this.duration = 300,
    this.child,
    this.styles,
    this.customStyle,
  });

  final dynamic percentage;
  final dynamic width;
  final dynamic borderWidth;
  final dynamic activeColor;
  final dynamic inactiveColor;
  final dynamic duration;
  final Widget? child;

  /// Source retained styles map.
  final dynamic styles;
  final BoxDecoration? customStyle;

  /// Source data.
  dynamic get leftBorderColor => activeColor;
  dynamic get rightBorderColor => inactiveColor;

  /// Source `init` (animation is driven by TweenAnimationBuilder).
  Map<String, dynamic> get _state =>
      _upCircleProgressState[this] ??= <String, dynamic>{'initialized': false};
  bool get initialized => _state['initialized'] == true;
  void init([dynamic _]) {
    _state['initialized'] = true;
  }

  /// Current percentage clamped 0-100.
  double getProgress() =>
      UPUtils.range(0, 100, num.tryParse('$percentage') ?? 0).toDouble();

  /// Source computed: leftSyle.
  dynamic get leftSyle => <String, dynamic>{
        'borderTopColor': leftBorderColor,
        'borderRightColor': leftBorderColor,
      };

  /// Source computed: rightSyle.
  dynamic get rightSyle => <String, dynamic>{
        'borderLeftColor': rightBorderColor,
        'borderBottomColor': rightBorderColor,
      };

  @override
  Widget build(BuildContext context) {
    final p = UPUtils.range(0, 100, num.tryParse('$percentage') ?? 0) / 100;
    final size = UPUtils.getPx(width);
    final stroke = UPUtils.getPx(borderWidth);
    final active = UPUtils.parseColor(activeColor) ?? const Color(0xFF42B983);
    final inactive =
        UPUtils.parseColor(inactiveColor) ?? const Color(0xFFC8C8C8);
    final ms = int.tryParse('$duration') ?? 300;

    Widget body = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: p),
            duration: Duration(milliseconds: ms),
            curve: Curves.easeOut,
            builder: (context, value, _) {
              return CustomPaint(
                size: Size.square(size),
                painter: _CircleProgressPainter(
                  progress: value,
                  strokeWidth: stroke,
                  activeColor: active,
                  inactiveColor: inactive,
                ),
              );
            },
          ),
          if (child != null) child!,
        ],
      ),
    );
    return body;
  }
}

class _CircleProgressPainter extends CustomPainter {
  _CircleProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.activeColor,
    required this.inactiveColor,
  });

  final double progress;
  final double strokeWidth;
  final Color activeColor;
  final Color inactiveColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final bg = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    final fg = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bg);
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, fg);
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        strokeWidth != oldDelegate.strokeWidth ||
        activeColor != oldDelegate.activeColor ||
        inactiveColor != oldDelegate.inactiveColor;
  }
}
