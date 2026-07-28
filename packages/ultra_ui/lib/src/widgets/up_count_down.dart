import 'dart:async';

import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';

class UPCountDownTimeData {
  const UPCountDownTimeData({
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.milliseconds,
  });

  final int days;
  final int hours;
  final int minutes;
  final int seconds;
  final int milliseconds;
}

class UPCountDown extends StatefulWidget {
  const UPCountDown({
    super.key,
    this.time = 0,
    this.format = 'HH:mm:ss',
    this.autoStart = true,
    this.millisecond = false,
    this.onChange,
    this.onStart,
    this.onFinish,
    this.customStyle,
  });

  final dynamic time;
  final String format;
  final bool autoStart;
  final bool millisecond;
  final ValueChanged<UPCountDownTimeData>? onChange;
  final VoidCallback? onStart;
  final VoidCallback? onFinish;

  final BoxDecoration? customStyle;
  @override
  State<UPCountDown> createState() => UPCountDownState();
}

class UPCountDownState extends State<UPCountDown> {
  Timer? _timer;
  late int _remain;
  late int _endAt;
  bool _running = false;

  bool get isRunning => _running;

  int get remainTime => _remain;

  /// Source data.
  int get endTime => _endAt;
  bool get runing => _running; // source spelling
  dynamic timer;
  Map get formattedTime {
    final d = parseTimeData(_remain);
    return {
      'days': d.days,
      'hours': d.hours,
      'minutes': d.minutes,
      'seconds': d.seconds,
      'milliseconds': d.milliseconds,
    };
  }

  /// Source `init`.
  void init() => reset();

  /// Source `getRemainTime`.
  int getRemainTime() => _remain;

  /// Source `setRemainTime`.
  void setRemainTime(int ms) {
    pause();
    setState(() => _remain = ms < 0 ? 0 : ms);
    widget.onChange?.call(parseTimeData(_remain));
  }

  /// Source `clearTimeout`.
  void clearTimeout() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void initState() {
    super.initState();
    _remain = (num.tryParse('${widget.time}') ?? 0).round();
    _endAt = DateTime.now().millisecondsSinceEpoch + _remain;
    if (widget.autoStart) start();
  }

  @override
  void didUpdateWidget(covariant UPCountDown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ('${oldWidget.time}' != '${widget.time}') {
      reset();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void start() {
    if (_running) return;
    _timer?.cancel();
    _running = true;
    widget.onStart?.call();
    _endAt = DateTime.now().millisecondsSinceEpoch + _remain;
    final period = widget.millisecond
        ? const Duration(milliseconds: 30)
        : const Duration(milliseconds: 200);
    _timer = Timer.periodic(period, (_) => _tick());
    _tick();
  }

  void pause() {
    _running = false;
    _timer?.cancel();
  }

  void reset() {
    pause();
    setState(() {
      _remain = (num.tryParse('${widget.time}') ?? 0).round();
    });
    widget.onChange?.call(parseTimeData(_remain));
    if (widget.autoStart) start();
  }

  /// Source tick aliases (Batch I).
  void toTick([dynamic _]) => _tick();
  void macroTick([dynamic _]) => _tick();
  void microTick([dynamic _]) => _tick();

  void _tick() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final next = (_endAt - now).clamp(0, 1 << 62);
    final data = parseTimeData(next);
    widget.onChange?.call(data);
    if (!mounted) return;
    setState(() => _remain = next);
    if (next <= 0) {
      pause();
      widget.onFinish?.call();
    }
  }

  static UPCountDownTimeData parseTimeData(int time) {
    const second = 1000;
    const minute = 60 * second;
    const hour = 60 * minute;
    const day = 24 * hour;
    final days = time ~/ day;
    final hours = (time % day) ~/ hour;
    final minutes = (time % hour) ~/ minute;
    final seconds = (time % minute) ~/ second;
    final milliseconds = time % second;
    return UPCountDownTimeData(
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
    );
  }

  static String padZero(int num, [int targetLength = 2]) {
    var str = '$num';
    while (str.length < targetLength) {
      str = '0$str';
    }
    return str;
  }

  static String parseFormat(String format, UPCountDownTimeData timeData) {
    var result = format;
    var days = timeData.days;
    var hours = timeData.hours;
    var minutes = timeData.minutes;
    var seconds = timeData.seconds;
    var milliseconds = timeData.milliseconds;

    if (!result.contains('DD')) {
      hours += days * 24;
    } else {
      result = result.replaceAll('DD', padZero(days));
    }
    if (!result.contains('HH')) {
      minutes += hours * 60;
    } else {
      result = result.replaceAll('HH', padZero(hours));
    }
    if (!result.contains('mm')) {
      seconds += minutes * 60;
    } else {
      result = result.replaceAll('mm', padZero(minutes));
    }
    if (!result.contains('ss')) {
      milliseconds += seconds * 1000;
    } else {
      result = result.replaceAll('ss', padZero(seconds));
    }
    return result.replaceAll('SSS', padZero(milliseconds, 3));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final data = parseTimeData(_remain);
    final text = parseFormat(widget.format, data);
    Widget root = Text(
      text,
      style: TextStyle(
        color: tokens.contentColor,
        fontSize: 15,
      ),
    );
    return root;
  }
}
