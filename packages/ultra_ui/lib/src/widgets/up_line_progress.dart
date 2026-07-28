import 'package:flutter/widgets.dart';

import '../utils/up_utils.dart';

final Expando<Map<String, dynamic>> _upLineProgressState =
    Expando<Map<String, dynamic>>('upLineProgressState');

/// 1:1 port of u-line-progress.
class UPLineProgress extends StatelessWidget {
  /// Source host helper.
  Future<void> sleep([int ms = 0]) async =>
      Future<void>.delayed(Duration(milliseconds: ms));

  const UPLineProgress({
    super.key,
    this.activeColor = '#19be6b',
    this.inactiveColor = '#ececec',
    this.percentage = 0,
    this.showText = true,
    this.height = 12,
    this.fromRight = false,
    this.customStyle,
    this.child,
  });

  final dynamic activeColor;
  final dynamic inactiveColor;
  final dynamic percentage;
  final bool showText;
  final dynamic height;
  final bool fromRight;
  final BoxDecoration? customStyle;

  /// Source data. It starts as zero and is updated to a CSS pixel string
  /// after the track is measured.
  dynamic get lineWidth => _state['lineWidth'] ?? 0;

  final Widget? child;

  /// Source `init`.
  Map<String, dynamic> get _state =>
      _upLineProgressState[this] ??= <String, dynamic>{
        'initialized': false,
        'lineWidth': 0,
      };
  bool get initialized => _state['initialized'] == true;
  void init([dynamic _]) {
    _state['initialized'] = true;
  }

  /// Source `getProgressWidth` — fraction 0..1 of active track.
  double getProgressWidth([dynamic totalWidth]) {
    final p = UPUtils.range(0, 100, num.tryParse('$percentage') ?? 0);
    final total = totalWidth == null
        ? 100.0
        : (num.tryParse('$totalWidth') ?? 100).toDouble();
    return total * (p / 100);
  }

  /// Current percentage clamped 0-100.
  double getPercentage() =>
      UPUtils.range(0, 100, num.tryParse('$percentage') ?? 0).toDouble();

  /// Source `resizeProgressWidth`. Flutter retains its numeric return value
  /// while updating the source-equivalent CSS width state.
  double resizeProgressWidth([dynamic totalWidth]) {
    final width = getProgressWidth(totalWidth);
    _state['lineWidth'] = '${_formatPercentage(width)}px';
    return width;
  }

  String _formatPercentage(double value) {
    if (value == value.roundToDouble()) return '${value.round()}';
    return '$value';
  }

  /// Source computed: progressStyle.
  dynamic get progressStyle {
    final style = <String, dynamic>{
      'width': lineWidth,
      'backgroundColor': activeColor,
      'height': UPUtils.addUnit(height),
    };
    if (fromRight) {
      style['right'] = 0;
    } else {
      style['left'] = 0;
    }
    return style;
  }

  /// Source computed: innserPercentage (source spelling).
  dynamic get innserPercentage =>
      UPUtils.range(0, 100, num.tryParse('$percentage') ?? 0);

  @override
  Widget build(BuildContext context) {
    final p = UPUtils.range(0, 100, num.tryParse('$percentage') ?? 0);
    final h = UPUtils.getPx(height);
    final active = UPUtils.parseColor(activeColor) ?? const Color(0xFF19BE6B);
    final inactive =
        UPUtils.parseColor(inactiveColor) ?? const Color(0xFFECECEC);
    final showPercentText = showText && p >= 10;
    final sourceDecoration =
        BoxDecoration(borderRadius: BorderRadius.circular(100));
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
    final radiusGeometry = decoration.borderRadius ?? BorderRadius.zero;
    final radius = radiusGeometry.resolve(Directionality.of(context));

    return Container(
      height: h,
      width: double.infinity,
      decoration: decoration,
      clipBehavior: Clip.hardEdge,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final full = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          final width = full * (p / 100);
          return Stack(
            children: [
              Positioned.fill(child: ColoredBox(color: inactive)),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease,
                top: 0,
                bottom: 0,
                left: fromRight ? null : 0,
                right: fromRight ? 0 : null,
                width: width,
                child: Container(
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: active,
                    borderRadius: radius,
                  ),
                  child: child ??
                      (showPercentText
                          ? Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Transform.scale(
                                scale: 0.9,
                                child: Text(
                                  '${_formatPercentage(p)}%',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 10,
                                    height: 1,
                                  ),
                                ),
                              ),
                            )
                          : null),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
