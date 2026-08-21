import 'package:flutter/widgets.dart';

import '../utils/up_utils.dart';

final Expando<Map<String, dynamic>> _upBarcodeState =
    Expando<Map<String, dynamic>>('upBarcodeState');

/// Port of u-barcode / up-barcode.
///
/// Real encoders: CODE128(A/B/C/auto), CODE39, EAN13, EAN8, UPC-A.
/// Other formats fall back to a deterministic visual pattern.
class UPBarcode extends StatelessWidget {
  const UPBarcode({
    super.key,
    required this.value,
    this.format = 'auto',
    this.width = 200,
    this.height = 80,
    this.displayValue = true,
    this.text,
    this.fontOptions = '',
    this.font = 'monospace',
    this.textAlign = 'center',
    this.textPosition = 'bottom',
    this.textMargin = 2,
    this.fontSize = 14,
    this.background = '#ffffff',
    this.lineColor = '#000000',
    this.margin = 10,
    this.marginTop,
    this.marginBottom,
    this.marginLeft,
    this.marginRight,
    this.useCanvas = true,
    this.onError,
    this.onRendered,
    this.customStyle,
  });

  /// Source host helper.
  Future<void> setTimeout([dynamic cb, int ms = 0]) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
    if (cb is Function) cb();
  }

  final dynamic value;
  final String format;
  final dynamic width;
  final dynamic height;
  final bool displayValue;
  final String? text;
  final String fontOptions;
  final String font;
  final String textAlign;
  final String textPosition;
  final dynamic textMargin;
  final dynamic fontSize;
  final dynamic background;
  final dynamic lineColor;
  final dynamic margin;
  final dynamic marginTop;
  final dynamic marginBottom;
  final dynamic marginLeft;
  final dynamic marginRight;

  /// Source canvas/image switch retained.
  final bool useCanvas;

  /// Source data (host-readable).
  String get canvasId => 'up-barcode';
  String get tempCanvasId => 'up-barcode-temp';
  double get canvasWidth => (num.tryParse('$width') ?? 0).toDouble();
  double get canvasHeight => (num.tryParse('$height') ?? 0).toDouble();
  bool get calcSizeDone => true;
  bool get showCanvas => useCanvas;
  Map<String, dynamic> get _state =>
      _upBarcodeState[this] ??= <String, dynamic>{
        'barcodeImage': null,
        'error': null,
      };
  dynamic get barcodeImage => _state['barcodeImage'];
  dynamic get error => _state['error'];

  final ValueChanged<Object>? onError;
  final ValueChanged<Map>? onRendered;
  final BoxDecoration? customStyle;

  /// Encode modules (0/1) for host inspection / tests.
  static List<int> encodeModules(String data, [String format = 'auto']) {
    return _BarcodePainter.encode(data, format);
  }

  /// Source encoder aliases.
  List<int> encodeCode128([dynamic data]) =>
      encodeModules('${data ?? value}', 'CODE128');
  List<int> encodeCode39([dynamic data]) =>
      encodeModules('${data ?? value}', 'CODE39');
  List<int> encodeEAN13([dynamic data]) =>
      encodeModules('${data ?? value}', 'EAN13');
  List<int> encodeEAN8([dynamic data]) =>
      encodeModules('${data ?? value}', 'EAN8');
  List<int> encodeUPCA([dynamic data]) =>
      encodeModules('${data ?? value}', 'UPCA');
  List<int> encodeUPC([dynamic data]) => encodeUPCA(data);
  List<int> getCode128Pattern([dynamic data]) => encodeCode128(data);

  /// Source `drawBarcode` alias of [generateBarcode].
  List<int> drawBarcode([dynamic data, String? fmt]) {
    if (data != null || fmt != null) {
      return encodeModules('${data ?? value}', fmt ?? format);
    }
    return generateBarcode();
  }

  /// Source `encodeBarcode`.
  List<int> encodeBarcode([dynamic data, String? fmt]) {
    return encodeModules('${data ?? value}', fmt ?? format);
  }

  /// Source `generateBarcode`.
  List<int> generateBarcode() {
    try {
      final modules = encodeBarcode(value, format);
      _state['barcodeImage'] = {
        'value': '$value',
        'format': format,
        'modules': modules.length,
      };
      _state['error'] = null;
      onRendered?.call({
        'value': '$value',
        'format': format,
        'modules': modules.length,
      });
      return modules;
    } catch (e) {
      _state['error'] = e;
      onError?.call(e);
      rethrow;
    }
  }

  void setError([dynamic payload]) {
    _state['error'] = payload;
    if (payload != null) onError?.call(payload);
  }

  /// Source `renderToCanvas` — encode modules for paint host.
  Future<List<int>> renderToCanvas([Map? options]) async {
    final v = options?['value'] ?? value;
    final f = options?['format'] ?? format;
    return encodeBarcode('$v', '$f');
  }

  /// Source `renderToImage` — metadata + modules for host export.
  Future<Map<String, dynamic>> renderToImage([Map? options]) async {
    final modules = await renderToCanvas(options);
    final size = calculateCanvasSize(options);
    final image = {
      'value': '${options?['value'] ?? value}',
      'format': '${options?['format'] ?? format}',
      'modules': modules.length,
      'width': size['width'],
      'height': size['height'],
      'lineColor': options?['lineColor'] ?? lineColor,
      'background': options?['background'] ?? background,
    };
    _state['barcodeImage'] = image;
    _state['error'] = null;
    return image;
  }

  /// Source `calculateCanvasSize`.
  Map<String, double> calculateCanvasSize([Map? options]) {
    final w = UPUtils.getPx(options?['width'] ?? width);
    var h = UPUtils.getPx(options?['height'] ?? height);
    final showText = options?['displayValue'] ?? displayValue;
    if (showText == true || showText == 'true') {
      h += UPUtils.getPx(options?['fontSize'] ?? fontSize) +
          UPUtils.getPx(options?['textMargin'] ?? textMargin);
    }
    final m = UPUtils.getPx(options?['margin'] ?? margin);
    return {
      'width': w + m * 2,
      'height': h + m * 2,
    };
  }

  /// Source `getCanvasRef` — returns host handle map (no native canvas).
  dynamic getCanvasRef([String refName = 'barcode']) => {
        'ref': refName,
        'value': value,
        'format': format,
        'width': width,
        'height': height,
      };

  /// Source encode aliases (Batch J).
  List<int> encodeEAN52([String? value]) => encodeEAN13(value ?? this.value);
  List<int> encodeUPCE([String? value]) => encodeUPCA(value ?? this.value);
  bool validator([String? value]) {
    final v = value ?? this.value;
    return v.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final w = UPUtils.getPx(width);
    final h = UPUtils.getPx(height);
    final bg = UPUtils.parseColor(background) ?? const Color(0xFFFFFFFF);
    final lc = UPUtils.parseColor(lineColor) ?? const Color(0xFF000000);
    final label = text ?? '$value';
    final textWidget = displayValue
        ? Padding(
            padding: EdgeInsets.only(
              top: textPosition == 'bottom' ? UPUtils.getPx(textMargin) : 0,
              bottom: textPosition == 'top' ? UPUtils.getPx(textMargin) : 0,
            ),
            child: Text(
              label,
              textAlign: textAlign == 'left'
                  ? TextAlign.left
                  : textAlign == 'right'
                      ? TextAlign.right
                      : TextAlign.center,
              style: TextStyle(
                fontSize: UPUtils.getPx(fontSize),
                color: lc,
                fontFamily: font == 'monospace' ? null : font,
                fontWeight: fontOptions.contains('bold')
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          )
        : null;

    final bar = SizedBox(
      width: w,
      height: h,
      child: CustomPaint(
        painter: _BarcodePainter(
          data: '$value',
          color: lc,
          format: format,
          onError: onError,
          onRendered: onRendered,
        ),
      ),
    );

    final children = <Widget>[];
    if (textPosition == 'top' && textWidget != null) children.add(textWidget);
    children.add(bar);
    if (textPosition != 'top' && textWidget != null) children.add(textWidget);

    Widget root = Container(
      color: bg,
      padding: EdgeInsets.only(
        top: UPUtils.getPx(marginTop ?? margin),
        bottom: UPUtils.getPx(marginBottom ?? margin),
        left: UPUtils.getPx(marginLeft ?? margin),
        right: UPUtils.getPx(marginRight ?? margin),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
    return root;
  }
}

class _BarcodePainter extends CustomPainter {
  _BarcodePainter({
    required this.data,
    required this.color,
    required this.format,
    this.onError,
    this.onRendered,
  });

  final String data;
  final Color color;
  final String format;
  final ValueChanged<Object>? onError;
  final ValueChanged<Map>? onRendered;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    List<int> modules;
    try {
      modules = encode(data, format);
    } catch (e) {
      onError?.call(e);
      modules = _fallback(data, format);
    }
    if (modules.isEmpty || size.width <= 0 || size.height <= 0) return;
    final unit = size.width / modules.length;
    for (var i = 0; i < modules.length; i++) {
      if (modules[i] == 1) {
        canvas.drawRect(
          Rect.fromLTWH(i * unit, 0, unit + 0.2, size.height),
          paint,
        );
      }
    }
    onRendered?.call({
      'type': 'canvas',
      'format': format,
      'value': data,
      'modules': modules.length,
    });
  }

  static List<int> encode(String data, String format) {
    final f = format.toUpperCase();
    switch (f) {
      case 'AUTO':
      case 'CODE128':
      case 'CODE128A':
      case 'CODE128B':
      case 'CODE128C':
        return _code128(data, f);
      case 'CODE39':
        return _code39(data);
      case 'EAN13':
        return _ean13(data);
      case 'EAN8':
        return _ean8(data);
      case 'UPC':
      case 'UPC-A':
      case 'UPCA':
        return _upca(data);
      case 'EAN5':
      case 'EAN2':
        return _eanAddon(data, f);
      default:
        return _fallback(data, format);
    }
  }

  // CODE128 patterns: 6 widths summing to 11, plus stop pattern.
  static const _patterns = <String>[
    '212222',
    '222122',
    '222221',
    '121223',
    '121322',
    '131222',
    '122213',
    '122312',
    '132212',
    '221213',
    '221312',
    '231212',
    '112232',
    '122132',
    '122231',
    '113222',
    '123122',
    '123221',
    '223211',
    '221132',
    '221231',
    '213212',
    '223112',
    '312131',
    '311222',
    '321122',
    '321221',
    '312212',
    '322112',
    '322211',
    '212123',
    '212321',
    '232121',
    '111323',
    '131123',
    '131321',
    '112313',
    '132113',
    '132311',
    '211313',
    '231113',
    '231311',
    '112133',
    '112331',
    '132131',
    '113123',
    '113321',
    '133121',
    '313121',
    '211331',
    '231131',
    '213113',
    '213311',
    '213131',
    '311123',
    '311321',
    '331121',
    '312113',
    '312311',
    '332111',
    '314111',
    '221411',
    '431111',
    '111224',
    '111422',
    '121124',
    '121421',
    '141122',
    '141221',
    '112214',
    '112412',
    '122114',
    '122411',
    '142112',
    '142211',
    '241211',
    '221114',
    '413111',
    '241112',
    '134111',
    '111242',
    '121142',
    '121241',
    '114212',
    '124112',
    '124211',
    '411212',
    '421112',
    '421211',
    '212141',
    '214121',
    '412121',
    '111143',
    '111341',
    '131141',
    '114113',
    '114311',
    '411113',
    '411311',
    '113141',
    '114131',
    '311141',
    '411131',
    '211412',
    '211214',
    '211232',
    '2331112',
  ];

  static List<int> _code128(String raw, String format) {
    if (raw.isEmpty) return const [];
    final useC = format == 'CODE128C' ||
        (format == 'AUTO' &&
            RegExp(r'^\d{2,}$').hasMatch(raw) &&
            raw.length % 2 == 0);
    final useA = format == 'CODE128A';
    final codes = <int>[];
    if (useC) {
      codes.add(105); // Start C
      for (var i = 0; i + 1 < raw.length; i += 2) {
        codes.add(int.parse(raw.substring(i, i + 2)));
      }
      if (raw.length.isOdd) {
        codes.add(100);
        codes.add(raw.codeUnitAt(raw.length - 1) - 32);
      }
    } else if (useA) {
      codes.add(103); // Start A
      for (final cu in raw.codeUnits) {
        if (cu >= 0 && cu < 32) {
          codes.add(cu + 64);
        } else if (cu >= 32 && cu <= 95) {
          codes.add(cu - 32);
        } else {
          codes.add(cu.clamp(32, 126) - 32);
        }
      }
    } else {
      codes.add(104); // Start B
      for (final cu in raw.codeUnits) {
        final v = cu < 32 ? 32 : (cu > 126 ? 32 : cu);
        codes.add(v - 32);
      }
    }
    var checksum = codes[0];
    for (var i = 1; i < codes.length; i++) {
      checksum += codes[i] * i;
    }
    codes.add(checksum % 103);
    codes.add(106); // Stop
    return _widthsToModules(
        [for (final c in codes) _patterns[c.clamp(0, _patterns.length - 1)]]);
  }

  static const _code39Map = <String, String>{
    '0': '111221211',
    '1': '211211112',
    '2': '112211112',
    '3': '212211111',
    '4': '111221112',
    '5': '211221111',
    '6': '112221111',
    '7': '111211212',
    '8': '211211211',
    '9': '112211211',
    'A': '211112112',
    'B': '112112112',
    'C': '212112111',
    'D': '111122112',
    'E': '211122111',
    'F': '112122111',
    'G': '111112212',
    'H': '211112211',
    'I': '112112211',
    'J': '111122211',
    'K': '211111122',
    'L': '112111122',
    'M': '212111121',
    'N': '111121122',
    'O': '211121121',
    'P': '112121121',
    'Q': '111111222',
    'R': '211111221',
    'S': '112111221',
    'T': '111121221',
    'U': '221111112',
    'V': '122111112',
    'W': '222111111',
    'X': '121121112',
    'Y': '221121111',
    'Z': '122121111',
    '-': '121111212',
    '.': '221111211',
    ' ': '122111211',
    '\$': '121212111',
    '/': '121211121',
    '+': '121112121',
    '%': '111212121',
    '*': '121121211',
  };

  static List<int> _code39(String raw) {
    final data = raw.toUpperCase();
    final parts = <String>[_code39Map['*']!];
    for (final ch in data.split('')) {
      final pat = _code39Map[ch];
      if (pat == null) {
        throw ArgumentError('Invalid character in CODE39: $ch');
      }
      parts.add(pat);
    }
    parts.add(_code39Map['*']!);
    // CODE39: narrow=1 wide=2, bar/space alternating, inter-char gap = 1 space
    final modules = <int>[];
    for (var i = 0; i < 10; i++) {
      modules.add(0);
    }
    for (var p = 0; p < parts.length; p++) {
      final pat = parts[p];
      var bar = true;
      for (var i = 0; i < pat.length; i++) {
        final n = int.parse(pat[i]);
        for (var k = 0; k < n; k++) {
          modules.add(bar ? 1 : 0);
        }
        bar = !bar;
      }
      if (p < parts.length - 1) {
        modules.add(0); // inter-character gap
      }
    }
    for (var i = 0; i < 10; i++) {
      modules.add(0);
    }
    return modules;
  }

  static const _eanLeftOdd = [
    '0001101',
    '0011001',
    '0010011',
    '0111101',
    '0100011',
    '0110001',
    '0101111',
    '0111011',
    '0110111',
    '0001011',
  ];
  static const _eanLeftEven = [
    '0100111',
    '0110011',
    '0011011',
    '0100001',
    '0011101',
    '0111001',
    '0000101',
    '0010001',
    '0001001',
    '0010111',
  ];
  static const _eanRight = [
    '1110010',
    '1100110',
    '1101100',
    '1000010',
    '1011100',
    '1001110',
    '1010000',
    '1000100',
    '1001000',
    '1110100',
  ];
  // First digit parity for EAN-13 left group.
  static const _ean13Parity = [
    'LLLLLL',
    'LLGLGG',
    'LLGGLG',
    'LLGGGL',
    'LGLLGG',
    'LGGLLG',
    'LGGGLL',
    'LGLGLG',
    'LGLGGL',
    'LGGLGL',
  ];

  static String _digitsOnly(String raw, int len, {bool padLeft = true}) {
    var d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.length > len) d = d.substring(d.length - len);
    if (padLeft) d = d.padLeft(len, '0');
    return d;
  }

  static int _eanChecksum(String body) {
    // body without check digit
    var sum = 0;
    for (var i = 0; i < body.length; i++) {
      final n = int.parse(body[body.length - 1 - i]);
      sum += i.isEven ? n * 3 : n;
    }
    return (10 - (sum % 10)) % 10;
  }

  static List<int> _bits(String bits) =>
      [for (final ch in bits.split('')) ch == '1' ? 1 : 0];

  static List<int> _ean13(String raw) {
    // Do not pad here: a 12-digit payload is a full EAN-13 body awaiting its
    // check digit, so left-padding it to 13 would shift every digit right and
    // then discard the real last digit as if it were the check digit.
    var d = _digitsOnly(raw, 13, padLeft: false);
    if (d.length < 12) d = d.padLeft(12, '0');
    // Always derive the check digit from the leading 12 digits, which also
    // corrects a wrong one supplied by the caller.
    final body = d.substring(0, 12);
    d = '$body${_eanChecksum(body)}';
    final first = int.parse(d[0]);
    final parity = _ean13Parity[first];
    final modules = <int>[
      ...List.filled(10, 0),
      ..._bits('101'),
    ];
    for (var i = 0; i < 6; i++) {
      final digit = int.parse(d[i + 1]);
      final set = parity[i];
      modules
          .addAll(_bits(set == 'L' ? _eanLeftOdd[digit] : _eanLeftEven[digit]));
    }
    modules.addAll(_bits('01010'));
    for (var i = 7; i < 13; i++) {
      final digit = int.parse(d[i]);
      modules.addAll(_bits(_eanRight[digit]));
    }
    modules.addAll(_bits('101'));
    modules.addAll(List.filled(10, 0));
    return modules;
  }

  static List<int> _ean8(String raw) {
    // Same reasoning as _ean13: 7 digits is a body awaiting its check digit,
    // so padding to 8 first would shift the digits and drop the last one.
    var d = _digitsOnly(raw, 8, padLeft: false);
    if (d.length < 7) d = d.padLeft(7, '0');
    final body = d.substring(0, 7);
    d = '$body${_eanChecksum(body)}';
    final modules = <int>[
      ...List.filled(10, 0),
      ..._bits('101'),
    ];
    for (var i = 0; i < 4; i++) {
      modules.addAll(_bits(_eanLeftOdd[int.parse(d[i])]));
    }
    modules.addAll(_bits('01010'));
    for (var i = 4; i < 8; i++) {
      modules.addAll(_bits(_eanRight[int.parse(d[i])]));
    }
    modules.addAll(_bits('101'));
    modules.addAll(List.filled(10, 0));
    return modules;
  }

  static List<int> _upca(String raw) {
    // 11 digits is a UPC-A body awaiting its check digit; padding it to 12
    // first would shift the digits, so keep the caller's length and let
    // _ean13 derive the check digit.
    final d = _digitsOnly(raw, 12, padLeft: false);
    // UPC-A is EAN-13 with leading 0.
    return _ean13('0$d');
  }

  static List<int> _eanAddon(String raw, String format) {
    final len = format == 'EAN5' ? 5 : 2;
    final d = _digitsOnly(raw, len);
    if (d.length != len) {
      throw ArgumentError('$format must be $len digits');
    }
    // Simplified binary patterns (left odd/even) for addon.
    const odd = [
      '0001101',
      '0011001',
      '0010011',
      '0111101',
      '0100011',
      '0110001',
      '0101111',
      '0111011',
      '0110111',
      '0001011',
    ];
    const even = [
      '0100111',
      '0110011',
      '0011011',
      '0100001',
      '0011101',
      '0111001',
      '0000101',
      '0010001',
      '0001001',
      '0010111',
    ];
    String structure;
    if (format == 'EAN5') {
      var checksum = 0;
      for (var i = 0; i < 5; i++) {
        final n = int.parse(d[i]);
        checksum += i.isEven ? n * 3 : n * 9;
      }
      const table = [
        'GGLLL',
        'GLGLL',
        'GLLGL',
        'GLLLG',
        'LGGLL',
        'LLGGL',
        'LLLGG',
        'LGLGL',
        'LGLLG',
        'LLGLG'
      ];
      structure = table[checksum % 10];
    } else {
      final v = int.parse(d) % 4;
      const table = ['LL', 'LG', 'GL', 'GG'];
      structure = table[v];
    }
    final modules = <int>[...List.filled(8, 0), ..._bits('1011')];
    for (var i = 0; i < d.length; i++) {
      if (i > 0) modules.addAll(_bits('01'));
      final digit = int.parse(d[i]);
      final set = structure[i];
      modules.addAll(_bits(set == 'L' ? odd[digit] : even[digit]));
    }
    modules.addAll(List.filled(8, 0));
    return modules;
  }

  static List<int> _widthsToModules(List<String> patterns) {
    final modules = <int>[];
    for (var i = 0; i < 10; i++) {
      modules.add(0);
    }
    for (final pat in patterns) {
      var bar = true;
      for (var i = 0; i < pat.length; i++) {
        final n = int.parse(pat[i]);
        for (var k = 0; k < n; k++) {
          modules.add(bar ? 1 : 0);
        }
        bar = !bar;
      }
    }
    for (var i = 0; i < 10; i++) {
      modules.add(0);
    }
    return modules;
  }

  static List<int> _fallback(String data, String format) {
    final seed = data.hashCode ^ format.hashCode;
    final modules = <int>[];
    for (var i = 0; i < 10; i++) {
      modules.add(0);
    }
    for (final b in [1, 0, 1]) {
      modules.add(b);
    }
    for (var i = 0; i < data.length; i++) {
      final c = data.codeUnitAt(i);
      final pattern = ((c + seed) & 0x1f) | 0x10;
      for (var b = 0; b < 5; b++) {
        final thick = ((pattern >> b) & 1) == 1 ? 2 : 1;
        final on = b.isEven;
        for (var t = 0; t < thick; t++) {
          modules.add(on ? 1 : 0);
        }
      }
      modules.add(0);
    }
    for (final b in [1, 0, 1]) {
      modules.add(b);
    }
    for (var i = 0; i < 10; i++) {
      modules.add(0);
    }
    return modules;
  }

  @override
  bool shouldRepaint(covariant _BarcodePainter old) =>
      old.data != data || old.color != color || old.format != format;
}
