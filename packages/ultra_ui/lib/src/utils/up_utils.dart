import 'dart:async';

import 'package:flutter/widgets.dart';

class UPUtils {
  UPUtils._();

  static double range(num min, num max, num value) {
    final v = value.toDouble();
    final lo = min.toDouble();
    final hi = max.toDouble();
    if (v < lo) return lo;
    if (v > hi) return hi;
    return v;
  }

  static double rpx2px(num value, {double? screenWidth}) {
    final width = screenWidth ?? 375.0;
    return value.toDouble() * width / 750.0;
  }

  /// Port of uview-plus getPx.
  /// Accepts number / "12" / "12px" / "24rpx" / "24upx".
  static double getPx(
    dynamic value, {
    bool unit = false,
    double? screenWidth,
  }) {
    if (value == null || value == '') return 0;
    if (value is num) {
      return value.toDouble();
    }
    final text = value.toString().trim();
    final rpxMatch = RegExp(r'([+-]?\d+(\.\d+)?)(rpx|upx)$').firstMatch(text);
    if (rpxMatch != null) {
      final n = double.parse(rpxMatch.group(1)!);
      return rpx2px(n, screenWidth: screenWidth);
    }
    final numMatch = RegExp(r'([+-]?\d+(\.\d+)?)').firstMatch(text);
    if (numMatch != null) {
      return double.parse(numMatch.group(1)!);
    }
    return 0;
  }

  static Future<void> sleep([int ms = 30]) {
    return Future<void>.delayed(Duration(milliseconds: ms));
  }

  static Color? parseColor(dynamic value, {Color? fallback}) {
    if (value == null) return fallback;
    if (value is Color) return value;
    final text = value.toString().trim();
    if (text.isEmpty) return fallback;
    if (text.startsWith('#')) {
      var hex = text.substring(1);
      if (hex.length == 3) {
        hex = hex.split('').map((c) => '$c$c').join();
      }
      if (hex.length == 6) {
        return Color(int.parse(hex, radix: 16) + 0xFF000000);
      }
      if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    }
    final rgb = RegExp(
      r'rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)(?:\s*,\s*([0-9.]+))?\s*\)',
    ).firstMatch(text);
    if (rgb != null) {
      final r = int.parse(rgb.group(1)!);
      final g = int.parse(rgb.group(2)!);
      final b = int.parse(rgb.group(3)!);
      final a = rgb.group(4) == null ? 1.0 : double.parse(rgb.group(4)!);
      return Color.fromRGBO(r, g, b, a);
    }
    return fallback;
  }

  /// Port of uview-plus genLightColor(textColor, lightness=95).
  static Color? genLightColor(dynamic textColor, [num lightness = 95]) {
    final color = parseColor(textColor);
    if (color == null) return null;
    final r = ((color.value >> 16) & 0xFF) / 255.0;
    final g = ((color.value >> 8) & 0xFF) / 255.0;
    final b = (color.value & 0xFF) / 255.0;
    final maxc = r > g ? (r > b ? r : b) : (g > b ? g : b);
    final minc = r < g ? (r < b ? r : b) : (g < b ? g : b);
    var h = 0.0;
    var s = 0.0;
    final l = (maxc + minc) / 2.0;
    if (maxc != minc) {
      final d = maxc - minc;
      s = l > 0.5 ? d / (2.0 - maxc - minc) : d / (maxc + minc);
      if (maxc == r) {
        h = (g - b) / d + (g < b ? 6.0 : 0.0);
      } else if (maxc == g) {
        h = (b - r) / d + 2.0;
      } else {
        h = (r - g) / d + 4.0;
      }
      h *= 60.0;
    }
    final targetL =
        (lightness.toDouble() > 95 ? 95.0 : lightness.toDouble()) / 100.0;
    final a =
        s * 100.0 * (targetL < 1 - targetL ? targetL : 1 - targetL) / 100.0;
    int channel(num n) {
      final k = (n + h / 30.0) % 12.0;
      var m = k - 3.0;
      final m2 = 9.0 - k;
      if (m2 < m) m = m2;
      if (m > 1) m = 1;
      if (m < -1) m = -1;
      final v = targetL - a * m;
      return (255 * v).round().clamp(0, 255);
    }

    return Color.fromARGB(0xFF, channel(0), channel(8), channel(4));
  }

  static bool isImage(dynamic value) {
    final text = '$value'.split('?').first;
    return RegExp(
      r'\.(jpeg|jpg|gif|png|svg|webp|jfif|bmp|dpg)$',
      caseSensitive: false,
    ).hasMatch(text);
  }

  /// Convert Color/dynamic color to #rrggbb when possible.
  static String? colorToHex(dynamic color) {
    if (color == null) return null;
    if (color is String) {
      final t = color.trim();
      if (t.isEmpty) return null;
      if (t.startsWith('#')) return t;
      return t;
    }
    if (color is Color) {
      final r = color.red.toRadixString(16).padLeft(2, '0');
      final g = color.green.toRadixString(16).padLeft(2, '0');
      final b = color.blue.toRadixString(16).padLeft(2, '0');
      return '#$r$g$b';
    }
    final parsed = parseColor(color);
    return parsed == null ? null : colorToHex(parsed);
  }

  /// Port of uview-plus colorGradient(startColor, endColor, step).
  static List<String> colorGradient(
    dynamic startColor, [
    dynamic endColor = '#ffffff',
    int step = 10,
  ]) {
    final start = parseColor(startColor) ?? const Color(0xFF000000);
    final end = parseColor(endColor) ?? const Color(0xFFFFFFFF);
    final n = step <= 0 ? 1 : step;
    final out = <String>[];
    final sR = start.red.toDouble();
    final sG = start.green.toDouble();
    final sB = start.blue.toDouble();
    final eR = end.red.toDouble();
    final eG = end.green.toDouble();
    final eB = end.blue.toDouble();
    final dR = (eR - sR) / n;
    final dG = (eG - sG) / n;
    final dB = (eB - sB) / n;
    for (var i = 0; i < n; i++) {
      final r = (sR + dR * i).round().clamp(0, 255);
      final g = (sG + dG * i).round().clamp(0, 255);
      final b = (sB + dB * i).round().clamp(0, 255);
      final hex = '#${r.toRadixString(16).padLeft(2, '0')}'
          '${g.toRadixString(16).padLeft(2, '0')}'
          '${b.toRadixString(16).padLeft(2, '0')}';
      out.add(hex);
    }
    // Ensure first equals start when possible.
    final startHex = colorToHex(start);
    if (startHex != null && out.isNotEmpty) out[0] = startHex;
    return out;
  }

  /// Port of uview-plus addUnit(value, unit='px').
  static dynamic addUnit(dynamic value, [String unit = 'px']) {
    if (value == null) return value;
    if (value is String) {
      final text = value.trim();
      if (text.isEmpty || text == 'auto') return text.isEmpty ? value : text;
      // already has unit
      if (RegExp(r'[a-zA-Z%]$').hasMatch(text)) return text;
      if (RegExp(r'^[+-]?\d+(\.\d+)?$').hasMatch(text)) {
        return '$text$unit';
      }
      return text;
    }
    if (value is num) {
      return '$value$unit';
    }
    final text = '$value';
    if (RegExp(r'^[+-]?\d+(\.\d+)?$').hasMatch(text)) {
      return '$text$unit';
    }
    return value;
  }
}

class UPTest {
  bool email(dynamic value) {
    return RegExp(
      r'^\w+((-\w+)|(\.\w+))*@[A-Za-z0-9]+((\.|-)[A-Za-z0-9]+)*\.[A-Za-z0-9]+$',
    ).hasMatch('$value');
  }

  bool mobile(dynamic value) {
    return RegExp(r'^1[23456789]\d{9}$').hasMatch('$value');
  }

  bool url(dynamic value) {
    return RegExp(
      r"^((https|http|ftp|rtsp|mms):\/\/)(([0-9a-zA-Z_!~*'().&=+$%-]+: )?[0-9a-zA-Z_!~*'().&=+$%-]+@)?(([0-9]{1,3}.){3}[0-9]{1,3}|([0-9a-zA-Z_!~*'()-]+.)*([0-9a-zA-Z][0-9a-zA-Z-]{0,61})?[0-9a-zA-Z].[a-zA-Z]{2,6})(:[0-9]{1,4})?((\/?)|(\/[0-9a-zA-Z_!~*'().;?:@&=+$,%#-]+)+\/?)$",
    ).hasMatch('$value');
  }

  bool number(dynamic value) {
    return RegExp(r'^[\+-]?(\d+\.?\d*|\.\d+|\d\.\d+e\+\d+)$')
        .hasMatch('$value');
  }

  bool digits(dynamic value) {
    return RegExp(r'^\d+$').hasMatch('$value');
  }

  bool empty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.isEmpty;
    if (value is Iterable) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    return false;
  }

  bool idCard(dynamic value) {
    return RegExp(
      r'^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}([0-9]|X)$',
      caseSensitive: false,
    ).hasMatch('$value');
  }
}

typedef UPVoidCallback = void Function();

class UPDebounce {
  UPDebounce(this.wait);
  final int wait;
  Timer? _timer;

  void call(UPVoidCallback fn) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: wait), fn);
  }

  void dispose() => _timer?.cancel();
}

class UPThrottle {
  UPThrottle(this.wait);
  final int wait;
  DateTime? _last;

  void call(UPVoidCallback fn) {
    final now = DateTime.now();
    if (_last == null || now.difference(_last!).inMilliseconds >= wait) {
      _last = now;
      fn();
    }
  }
}
