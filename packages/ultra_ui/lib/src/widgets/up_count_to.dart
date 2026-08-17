import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../utils/up_utils.dart';

class UPCountTo extends StatefulWidget {
  const UPCountTo({
    super.key,
    this.startVal = 0,
    this.endVal = 0,
    this.duration = 2000,
    this.autoplay = true,
    this.decimals = 0,
    this.useEasing = true,
    this.decimal = '.',
    this.color = '#606266',
    this.fontSize = 22,
    this.bold = false,
    this.separator = '',
    this.onEnd,
    this.customStyle,
  });

  final dynamic startVal;
  final dynamic endVal;
  final dynamic duration;
  final bool autoplay;
  final dynamic decimals;
  final bool useEasing;
  final String decimal;
  final dynamic color;
  final dynamic fontSize;
  final bool bold;
  final String separator;
  final VoidCallback? onEnd;

  final BoxDecoration? customStyle;
  @override
  State<UPCountTo> createState() => UPCountToState();
}

class UPCountToState extends State<UPCountTo> {
  Timer? _timer;
  late double _display;
  late double _from;
  late int _durationMs;
  int _elapsedMs = 0;
  int _remainingMs = 0;
  bool _paused = false;

  bool get isPaused => _paused;
  bool get isRunning => !_paused && _remainingMs > 0;

  double get currentValue => _display;

  /// Source data.
  double get displayValue => _display;
  double get printVal => _display;
  double get localStartVal => _from;
  int get localDuration => _durationMs;
  bool get paused => _paused;
  int get remaining => _remainingMs;
  int lastTime = 0;
  int startTime = 0;
  int timestamp = 0;
  dynamic rAF;

  /// Source animation helpers.
  void countDown([dynamic _]) => start();
  double easingFn(double t, double b, double c, double d) =>
      _easing(t, b, c, d);
  void requestAnimationFrame([void Function()? cb]) {
    Future.microtask(() => cb?.call());
  }

  void cancelAnimationFrame([dynamic _]) {
    _timer?.cancel();
    _timer = null;
  }

  /// Source `count` — current display value.
  /// Source `count` — current display value.
  double count() => _display;

  /// Source `formatNumber`.
  String formatNumber([double? value]) {
    final v = value ?? _display;
    final decimals = int.tryParse('${widget.decimals}') ?? 0;
    var text = v.toStringAsFixed(decimals < 0 ? 0 : decimals);
    // apply decimal separator
    if (widget.decimal != '.' && text.contains('.')) {
      text = text.replaceFirst('.', widget.decimal);
    }
    if (widget.separator.isNotEmpty) {
      final parts = text.split(widget.decimal == '' ? '.' : widget.decimal);
      final intPart = parts[0];
      final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
      final grouped = intPart.replaceAllMapped(reg, (m) => widget.separator);
      if (parts.length > 1) {
        text = '$grouped${widget.decimal}${parts[1]}';
      } else {
        text = grouped;
      }
    }
    return text;
  }

  /// Source `isNumber`.
  bool isNumber(dynamic v) => num.tryParse('$v') != null;

  /// Source `destroyed`.
  void destroyed() {
    _timer?.cancel();
    _timer = null;
  }

  double get _start => (num.tryParse('${widget.startVal}') ?? 0).toDouble();
  double get _end => (num.tryParse('${widget.endVal}') ?? 0).toDouble();

  @override
  void initState() {
    super.initState();
    _display = _start;
    _from = _start;
    _durationMs = int.tryParse('${widget.duration}') ?? 2000;
    _remainingMs = _durationMs;
    if (widget.autoplay) start();
  }

  @override
  void didUpdateWidget(covariant UPCountTo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ('${oldWidget.startVal}' != '${widget.startVal}' ||
        '${oldWidget.endVal}' != '${widget.endVal}' ||
        '${oldWidget.duration}' != '${widget.duration}') {
      if (widget.autoplay) start();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Source finish/timer aliases (Batch J).
  void callback([dynamic _]) => widget.onEnd?.call();
  void clearTimeout([dynamic _]) => cancelAnimationFrame();

  void start() {
    _timer?.cancel();
    _from = _start;
    _display = _start;
    _durationMs = int.tryParse('${widget.duration}') ?? 2000;
    _remainingMs = _durationMs;
    _elapsedMs = 0;
    _paused = false;
    _startTimer();
  }

  void reset() {
    _timer?.cancel();
    _paused = false;
    _elapsedMs = 0;
    _remainingMs = int.tryParse('${widget.duration}') ?? 2000;
    setState(() => _display = _start);
  }

  void stop() {
    if (_timer == null) return;
    _timer?.cancel();
    _timer = null;
    _remainingMs = (_durationMs - _elapsedMs).clamp(0, _durationMs);
    _paused = true;
  }

  void resume() {
    if (!_paused || _remainingMs <= 0) return;
    _from = _display;
    _durationMs = _remainingMs;
    _elapsedMs = 0;
    _paused = false;
    _startTimer();
  }

  void reStart() {
    if (_paused) {
      resume();
    } else {
      stop();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
  }

  void _tick() {
    _elapsedMs += 16;
    final elapsed = _elapsedMs.toDouble();
    final d = _durationMs.toDouble();
    final c = _end - _from;
    double value;
    if (elapsed >= d) {
      value = _end;
      _timer?.cancel();
      _timer = null;
      _remainingMs = 0;
      callback();
    } else if (widget.useEasing) {
      value = _easing(elapsed, _from, c, d);
    } else {
      value = _from + c * (elapsed / d);
    }
    if (!mounted) return;
    setState(() => _display = value);
  }

  double _easing(double t, double b, double c, double d) {
    return (c * (-math.pow(2, (-10 * t) / d) + 1) * 1024) / 1023 + b;
  }

  String _format(double value) {
    final decimals = int.tryParse('${widget.decimals}') ?? 0;
    final fixed = value.toStringAsFixed(decimals);
    if (widget.separator.isEmpty && widget.decimal == '.') return fixed;

    final parts = fixed.split('.');
    var intPart = parts[0];
    final buf = StringBuffer();
    final negative = intPart.startsWith('-');
    if (negative) intPart = intPart.substring(1);
    for (var i = 0; i < intPart.length; i++) {
      final reverseIndex = intPart.length - i;
      buf.write(intPart[i]);
      if (reverseIndex > 1 &&
          reverseIndex % 3 == 1 &&
          widget.separator.isNotEmpty) {
        buf.write(widget.separator);
      }
    }
    final outInt = '${negative ? '-' : ''}${buf.toString()}';
    if (decimals <= 0) return outInt;
    return '$outInt${widget.decimal}${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final color = UPUtils.parseColor(widget.color) ?? const Color(0xFF606266);
    final fs = UPUtils.getPx(widget.fontSize);
    Widget root = Text(
      _format(_display),
      style: TextStyle(
        color: color,
        fontSize: fs,
        fontWeight: widget.bold ? FontWeight.w700 : FontWeight.w400,
      ),
    );
    return root;
  }
}
