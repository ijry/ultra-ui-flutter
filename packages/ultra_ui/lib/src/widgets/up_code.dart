import 'dart:async';

import 'package:flutter/widgets.dart';

/// Logic-only port of u-code (verification countdown helper).
class UPCode extends StatefulWidget {
  const UPCode({
    super.key,
    this.seconds = 60,
    this.startText = '获取验证码',
    this.changeText = 'X秒重新获取',
    this.endText = '重新获取',
    this.keepRunning = false,
    this.uniqueKey = '',
    this.onChange,
    this.onStart,
    this.onEnd,
    this.controller,
    this.customStyle,
  });

  final dynamic seconds;
  final String startText;
  final String changeText;
  final String endText;
  final bool keepRunning;
  final String uniqueKey;
  final ValueChanged<String>? onChange;
  final VoidCallback? onStart;
  final VoidCallback? onEnd;
  final UPCodeController? controller;
  final BoxDecoration? customStyle;

  @override
  State<UPCode> createState() => UPCodeState();
}

class UPCodeController {
  UPCodeState? _state;

  /// Source clearInterval alias (Batch J).
  void clearInterval([dynamic _]) => reset();

  void start() => _state?.start();
  void reset() => _state?.reset();
  void checkKeepRunning() => _state?.checkKeepRunning();
  bool get canGetCode => _state?.canGetCode ?? true;
}

class UPCodeState extends State<UPCode> {
  static final Map<String, int> _keepRunningStorage = <String, int>{};

  late int secNum;
  Timer? timer;
  bool canGetCode = true;

  String get _storageKey => '${widget.uniqueKey}_\$uCountDownTimestamp';

  @override
  void initState() {
    super.initState();
    secNum = int.tryParse('${widget.seconds}') ?? 60;
    widget.controller?._state = this;
    checkKeepRunning();
  }

  @override
  void didUpdateWidget(covariant UPCode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
    if ('${oldWidget.seconds}' != '${widget.seconds}') {
      secNum = int.tryParse('${widget.seconds}') ?? 60;
    }
  }

  /// Source `changeEvent`.
  void changeEvent([String? text]) {
    if (text != null) _emit(text);
  }

  /// Source keep-running storage helper alias.
  void setTimeToStorage([dynamic _]) => _setTimeToStorage();

  /// Source clearInterval alias (Batch J).
  void clearInterval([dynamic _]) => reset();

  void start() {
    if (timer != null) {
      timer!.cancel();
      timer = null;
    }
    widget.onStart?.call();
    canGetCode = false;
    _emit(widget.changeText.replaceAll(RegExp(r'[xX]'), '$secNum'));
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (--secNum > 0) {
        _emit(widget.changeText.replaceAll(RegExp(r'[xX]'), '$secNum'));
        _setTimeToStorage();
      } else {
        timer?.cancel();
        timer = null;
        _clearStorage();
        _emit(widget.endText);
        secNum = int.tryParse('${widget.seconds}') ?? 60;
        canGetCode = true;
        widget.onEnd?.call();
      }
    });
    _setTimeToStorage();
  }

  void reset() {
    canGetCode = true;
    timer?.cancel();
    timer = null;
    _clearStorage();
    secNum = int.tryParse('${widget.seconds}') ?? 60;
    _emit(widget.endText);
  }

  void _emit(String text) {
    widget.onChange?.call(text);
  }

  void checkKeepRunning() {
    final lastTimestamp = _keepRunningStorage[_storageKey] ?? 0;
    if (widget.keepRunning && lastTimestamp > 0) {
      final nowTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (lastTimestamp > nowTimestamp) {
        secNum = lastTimestamp - nowTimestamp;
        _clearStorage();
        start();
        return;
      }
      _clearStorage();
    }
    _emit(widget.startText);
  }

  void _setTimeToStorage() {
    if (!widget.keepRunning || timer == null) return;
    if (secNum > 0 && secNum <= (int.tryParse('${widget.seconds}') ?? 60)) {
      final nowTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      _keepRunningStorage[_storageKey] = nowTimestamp + secNum;
    }
  }

  void _clearStorage() {
    _keepRunningStorage.remove(_storageKey);
  }

  @override
  void dispose() {
    _setTimeToStorage();
    timer?.cancel();
    widget.controller?._state = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
