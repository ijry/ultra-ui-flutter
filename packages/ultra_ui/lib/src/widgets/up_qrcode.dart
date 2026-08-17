import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../utils/up_utils.dart';

final Expando<Map<String, dynamic>> _upQrcodeState =
    Expando<Map<String, dynamic>>('upQrcodeState');

/// Port of u-qrcode / up-qrcode.
///
/// Byte-mode QR matrix with Reed-Solomon ECC (versions 1-10).
class UPQrcode extends StatelessWidget {
  const UPQrcode({
    super.key,
    this.cid = '',
    this.size = 200,
    this.unit = 'px',
    this.show = true,
    this.val = '',
    this.background = '#ffffff',
    this.foreground = '#000000',
    this.pdground = '#000000',
    this.icon = '',
    this.iconSize = 40,
    this.lv = 3,
    this.quietZone = 0,
    this.onval = true,
    this.loadMake = true,
    this.usingComponents = true,
    this.showLoading = true,
    this.loadingText = '生成中',
    this.allowPreview = false,
    this.useRootHeightAndWidth = false,
    this.onComplete,
    this.onPreview,
    this.onResult,
    this.onLongpressCallback,
    this.customStyle,
  });

  /// Source host helper.
  dynamic _result([dynamic v]) {
    onResult?.call(v);
    return v;
  }

  /// Source host helper.
  void empty([dynamic payload]) {
    _state['emptyCount'] = ((_state['emptyCount'] as int?) ?? 0) + 1;
    _state['lastEmpty'] = payload;
  }

  int get emptyCount => (_state['emptyCount'] as int?) ?? 0;
  dynamic get lastEmpty => _state['lastEmpty'];

  final String cid;
  final dynamic size;
  final String unit;
  final bool show;
  final String val;
  final dynamic background;
  final dynamic foreground;
  final dynamic pdground;
  final String icon;
  final dynamic iconSize;
  final int lv;
  final dynamic quietZone;
  final bool onval;
  final bool loadMake;
  final bool usingComponents;
  final bool showLoading;
  final String loadingText;
  final bool allowPreview;

  /// Source data defaults.
  List get list => const [
        {'name': '保存二维码'},
      ];

  /// Source data `loading` (runtime may flip during paint).
  bool get loading => _state['loading'] == true;
  String get name => cid;
  bool get popupShow => _state['popupShow'] == true;

  /// Source data `result` (generated image path). Method `result()` is emit alias.
  String get resultData => '${_state['resultData'] ?? ''}';

  /// Source host helpers.
  Map<String, dynamic> get _state => _upQrcodeState[this] ??= <String, dynamic>{
        'cleared': false,
        'fillStyle': null,
        'strokeStyle': null,
        'lineWidth': null,
        'lastAlert': null,
        'lastDrawImage': null,
        'lastRoundedRect': null,
        'loading': false,
        'popupShow': false,
        'resultData': '',
        'canvasHost': null,
        'ctx': null,
        'emptyCount': 0,
        'lastEmpty': null,
      };
  void alert([dynamic payload]) {
    _state['lastAlert'] = payload ?? true;
  }

  /// Source emit alias for `result` event.
  dynamic result([dynamic v]) => _result(v);

  /// Source emit alias.
  void longpressCallback([dynamic e]) => onLongpressCallback?.call(e);
  void drawImage([dynamic payload]) {
    _state['lastDrawImage'] = payload ?? true;
  }

  bool get cleared => _state['cleared'] == true;
  dynamic get fillStyle => _state['fillStyle'];
  dynamic get strokeStyle => _state['strokeStyle'];
  dynamic get lineWidth => _state['lineWidth'];
  dynamic getRootNode([dynamic _]) => null;
  dynamic resolve([dynamic v]) => v;

  final bool useRootHeightAndWidth;
  final ValueChanged<String>? onComplete;

  /// Source emit alias: preview.
  final ValueChanged<dynamic>? onPreview;

  /// Source emit alias: result.
  final ValueChanged<dynamic>? onResult;

  /// Source emit alias: longpressCallback.
  final ValueChanged<dynamic>? onLongpressCallback;

  final BoxDecoration? customStyle;

  /// Encode QR matrix modules for host inspection / tests.
  static List<List<int>> encodeMatrix(String text, [int lv = 3]) {
    return _QrEncoder.encode(text, _QrPainter._ecLevel(lv));
  }

  /// Source `_makeCode` / generate.
  List<List<int>> makeCode([String? value]) {
    _state['loading'] = true;
    final data = value ?? val;
    final matrix = encodeMatrix(data, lv);
    _state['resultData'] = data;
    _state['loading'] = false;
    _state['canvasHost'] = {'cid': cid, 'size': size, 'val': data};
    _state['ctx'] = {'type': 'qrcode', 'modules': matrix.length};
    return matrix;
  }

  /// Source `_clearCode`.
  void clearCode() {
    _state['cleared'] = true;
    _state['resultData'] = '';
    _state['loading'] = false;
    _state['popupShow'] = false;
  }

  void _clearCode() => clearCode();

  /// Source `_saveCode` (host-owned persistence).
  String saveCode() => val;
  String _saveCode() => saveCode();

  /// Source `preview`.
  void preview([dynamic e]) {
    _state['popupShow'] = true;
    onPreview?.call(e ?? {'val': val});
  }

  void setPopupShow([bool show = true]) {
    _state['popupShow'] = show;
  }

  void setLoading([bool value = true]) {
    _state['loading'] = value;
  }

  /// Source canvas helpers (paint path is CustomPainter; keep drawing API parity).
  List<int> getUTF8Bytes([String? value]) {
    final s = value ?? val;
    return utf8.encode(s);
  }

  List<int> unicodeFormat8([String? value]) => getUTF8Bytes(value);

  void setFillStyle([dynamic style]) {
    _state['fillStyle'] = style;
  }

  void setStrokeStyle([dynamic style]) {
    _state['strokeStyle'] = style;
  }

  void setLineWidth([dynamic width]) {
    _state['lineWidth'] = width;
  }

  void drawRoundedRect(
      [dynamic x, dynamic y, dynamic w, dynamic h, dynamic r]) {
    _state['lastRoundedRect'] = {'x': x, 'y': y, 'w': w, 'h': h, 'r': r};
  }

  /// Source `getUPCanvasContext` — no separate canvas host in Flutter paint path.
  dynamic getUPCanvasContext() => {
        'val': val,
        'size': size,
        'modules': makeCode().length,
      };

  /// Source `selectClick` (0=save).
  void selectClick([int index = 0]) {
    if (index == 0) {
      saveCode();
    }
  }

  /// Source `toTempFilePath` — returns export metadata (host owns real file IO).
  Future<Map<String, dynamic>> toTempFilePath({
    void Function(Map<String, dynamic> res)? success,
    void Function(Object err)? fail,
  }) async {
    final modules = makeCode();
    final res = <String, dynamic>{
      'tempFilePath': '',
      'val': val,
      'size': size,
      'modules': modules.length,
      'width': size,
      'height': size,
    };
    success?.call(res);
    return res;
  }

  /// Source `longpress`.
  Future<void> longpress() async => preview();

  /// Source `setNewSize` — re-emit complete with current size.
  Future<void> setNewSize([dynamic next]) async {
    onComplete?.call(val);
  }

  /// Source `initCanvas`.
  Future<bool> initCanvas([bool force = false]) async {
    makeCode();
    return true;
  }

  /// Source data defaults.
  dynamic get canvasHost => _state['canvasHost'];

  /// Source data: canvasObj mirrors host/ctx snapshot used by export/draw.
  dynamic get canvasObj => <String, dynamic>{
        'canvasHost': canvasHost,
        'ctx': ctx,
        'cid': cid,
        'size': size,
        'rootId': rootId,
      };
  dynamic get ctx => _state['ctx'];
  dynamic get isNvue => false;
  dynamic get rootId => 'rootId0';
  dynamic get sizeLocal => size;

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();
    final s = UPUtils.getPx(size);
    final bg = UPUtils.parseColor(background) ?? const Color(0xFFFFFFFF);
    final fg = UPUtils.parseColor(foreground) ?? const Color(0xFF000000);
    final pd = UPUtils.parseColor(pdground) ?? fg;
    final qz = UPUtils.getPx(quietZone);
    // Fire complete asynchronously-looking via post frame is not needed here;
    // callers often only care about paint. Keep callback optional.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onComplete?.call(val);
    });
    Widget root = GestureDetector(
      onTap: allowPreview ? () {} : null,
      child: Container(
        width: s,
        height: s,
        color: bg,
        padding: EdgeInsets.all(qz),
        child: CustomPaint(
          painter: _QrPainter(data: val, fg: fg, pd: pd, lv: lv),
          child: icon.isEmpty
              ? null
              : Center(
                  child: Container(
                    width: UPUtils.getPx(iconSize),
                    height: UPUtils.getPx(iconSize),
                    color: bg,
                    alignment: Alignment.center,
                    child: Text(
                      icon,
                      style:
                          TextStyle(fontSize: UPUtils.getPx(iconSize) * 0.45),
                    ),
                  ),
                ),
        ),
      ),
    );
    return root;
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter({
    required this.data,
    required this.fg,
    required this.pd,
    required this.lv,
  });
  final String data;
  final Color fg;
  final Color pd;
  final int lv;

  @override
  void paint(Canvas canvas, Size size) {
    final matrix = _QrEncoder.encode(data, _ecLevel(lv));
    final n = matrix.length;
    if (n == 0 || size.width <= 0) return;
    final cell = size.width / n;
    final paint = Paint();
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (matrix[y][x] == 0) continue;
        final isFinder = _isFinderArea(x, y, n);
        paint.color = isFinder ? pd : fg;
        canvas.drawRect(
          Rect.fromLTWH(x * cell, y * cell, cell + 0.2, cell + 0.2),
          paint,
        );
      }
    }
  }

  static bool _isFinderArea(int x, int y, int n) {
    final inTL = x < 8 && y < 8;
    final inTR = x >= n - 8 && y < 8;
    final inBL = x < 8 && y >= n - 8;
    return inTL || inTR || inBL;
  }

  /// Map uview lv (1-4) to QR EC: 1=L 2=M 3=Q 4=H; default Q-like.
  static int _ecLevel(int lv) {
    switch (lv.clamp(1, 4)) {
      case 1:
        return 1; // L
      case 2:
        return 0; // M
      case 4:
        return 2; // H
      default:
        return 3; // Q
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter old) =>
      old.data != data || old.fg != fg || old.pd != pd || old.lv != lv;
}

/// Compact QR encoder (byte mode, versions 1-10).
class _QrEncoder {
  static List<List<int>> encode(String text, int ec) {
    final data = text.codeUnits.map((c) => c & 0xff).toList();
    var version = 1;
    for (; version <= 10; version++) {
      final cap = _byteCapacity(version, ec);
      if (data.length <= cap) break;
    }
    if (version > 10) version = 10;

    final size = version * 4 + 17;
    final modules = List.generate(size, (_) => List.filled(size, -1));
    _drawFinders(modules);
    _drawTiming(modules);
    _drawAlignment(modules, version);
    _drawDarkModule(modules, version);
    _reserveFormat(modules);
    if (version >= 7) _reserveVersion(modules);

    final bits = _buildDataBits(data, version, ec);
    _placeData(modules, bits);
    final mask = _selectMask(modules);
    _applyMask(modules, mask);
    _drawFormat(modules, ec, mask);
    if (version >= 7) _drawVersion(modules, version);

    // normalize -1 -> 0
    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        if (modules[y][x] < 0) modules[y][x] = 0;
      }
    }
    return modules;
  }

  static int _byteCapacity(int version, int ec) {
    // Approximate data codeword capacity for byte mode.
    // total codewords - ecc codewords - mode/count overhead (~3)
    final total = _totalCodewords[version]!;
    final ecc = _eccCodewordsPerBlock[ec]![version]!;
    final blocks = _numBlocks[ec]![version]!;
    final dataCw = total - ecc * blocks;
    final overhead = version <= 9 ? 2 : 3; // mode(4)+count(8/16) rounded up
    return math.max(0, dataCw - overhead - 1);
  }

  static List<int> _buildDataBits(List<int> data, int version, int ec) {
    final total = _totalCodewords[version]!;
    final eccPerBlock = _eccCodewordsPerBlock[ec]![version]!;
    final blocks = _numBlocks[ec]![version]!;
    final dataCwCount = total - eccPerBlock * blocks;

    final bits = <int>[];
    void put(int value, int len) {
      for (var i = len - 1; i >= 0; i--) {
        bits.add((value >> i) & 1);
      }
    }

    put(0x4, 4); // byte mode
    put(data.length, version <= 9 ? 8 : 16);
    for (final b in data) {
      put(b, 8);
    }
    // terminator
    final capacityBits = dataCwCount * 8;
    final term = math.min(4, capacityBits - bits.length);
    if (term > 0) put(0, term);
    while (bits.length % 8 != 0) {
      bits.add(0);
    }
    final padBytes = [0xEC, 0x11];
    var pad = 0;
    while (bits.length < capacityBits) {
      put(padBytes[pad % 2], 8);
      pad++;
    }

    final dataCodewords = <int>[];
    for (var i = 0; i < bits.length; i += 8) {
      var v = 0;
      for (var j = 0; j < 8; j++) {
        v = (v << 1) | bits[i + j];
      }
      dataCodewords.add(v);
    }

    // split blocks
    final shortBlocks = blocks - (dataCwCount % blocks);
    final shortLen = dataCwCount ~/ blocks;
    final longLen = shortLen + 1;
    final dataBlocks = <List<int>>[];
    var offset = 0;
    for (var i = 0; i < blocks; i++) {
      final len = i < shortBlocks ? shortLen : longLen;
      dataBlocks.add(dataCodewords.sublist(offset, offset + len));
      offset += len;
    }
    final eccBlocks = dataBlocks
        .map((b) => _rsEncode(b, eccPerBlock))
        .toList(growable: false);

    final result = <int>[];
    final maxData = longLen;
    for (var i = 0; i < maxData; i++) {
      for (final b in dataBlocks) {
        if (i < b.length) result.add(b[i]);
      }
    }
    for (var i = 0; i < eccPerBlock; i++) {
      for (final b in eccBlocks) {
        result.add(b[i]);
      }
    }

    final outBits = <int>[];
    for (final cw in result) {
      for (var i = 7; i >= 0; i--) {
        outBits.add((cw >> i) & 1);
      }
    }
    return outBits;
  }

  // Galois RS
  static final _exp = List<int>.filled(512, 0);
  static final _log = List<int>.filled(256, 0);
  static bool _gfInit = false;

  static void _initGf() {
    if (_gfInit) return;
    var x = 1;
    for (var i = 0; i < 255; i++) {
      _exp[i] = x;
      _log[x] = i;
      x <<= 1;
      if (x & 0x100 != 0) x ^= 0x11d;
    }
    for (var i = 255; i < 512; i++) {
      _exp[i] = _exp[i - 255];
    }
    _gfInit = true;
  }

  static int _gfMul(int a, int b) {
    if (a == 0 || b == 0) return 0;
    return _exp[_log[a] + _log[b]];
  }

  static List<int> _rsEncode(List<int> data, int ecLen) {
    _initGf();
    final gen = <int>[1];
    for (var i = 0; i < ecLen; i++) {
      final next = List<int>.filled(gen.length + 1, 0);
      for (var j = 0; j < gen.length; j++) {
        next[j] ^= gen[j];
        next[j + 1] ^= _gfMul(gen[j], _exp[i]);
      }
      gen
        ..clear()
        ..addAll(next);
    }
    final res = List<int>.generate(ecLen, (_) => 0, growable: true);
    for (final b in data) {
      final factor = b ^ res[0];
      res.removeAt(0);
      res.add(0);
      if (factor != 0) {
        for (var i = 0; i < ecLen; i++) {
          res[i] ^= _gfMul(gen[i + 1], factor);
        }
      }
    }
    return res;
  }

  static void _drawFinders(List<List<int>> m) {
    final n = m.length;
    void finder(int ox, int oy) {
      for (var y = -1; y <= 7; y++) {
        for (var x = -1; x <= 7; x++) {
          final xx = ox + x;
          final yy = oy + y;
          if (xx < 0 || yy < 0 || xx >= n || yy >= n) continue;
          final edge = x == -1 || y == -1 || x == 7 || y == 7;
          final outer = x >= 0 &&
              x <= 6 &&
              y >= 0 &&
              y <= 6 &&
              (x == 0 || y == 0 || x == 6 || y == 6);
          final core = x >= 2 && x <= 4 && y >= 2 && y <= 4;
          if (edge) {
            m[yy][xx] = 0;
          } else if (outer || core) {
            m[yy][xx] = 1;
          } else {
            m[yy][xx] = 0;
          }
        }
      }
    }

    finder(0, 0);
    finder(n - 7, 0);
    finder(0, n - 7);
  }

  static void _drawTiming(List<List<int>> m) {
    final n = m.length;
    for (var i = 8; i < n - 8; i++) {
      final v = i.isEven ? 1 : 0;
      if (m[6][i] < 0) m[6][i] = v;
      if (m[i][6] < 0) m[i][6] = v;
    }
  }

  static void _drawDarkModule(List<List<int>> m, int version) {
    m[4 * version + 9][8] = 1;
  }

  static const _alignPos = <int, List<int>>{
    2: [6, 18],
    3: [6, 22],
    4: [6, 26],
    5: [6, 30],
    6: [6, 34],
    7: [6, 22, 38],
    8: [6, 24, 42],
    9: [6, 26, 46],
    10: [6, 28, 50],
  };

  static void _drawAlignment(List<List<int>> m, int version) {
    final pos = _alignPos[version];
    if (pos == null) return;
    final n = m.length;
    for (final y in pos) {
      for (final x in pos) {
        // skip finder corners
        if ((x == 6 && y == 6) ||
            (x == 6 && y == n - 7) ||
            (x == n - 7 && y == 6)) {
          continue;
        }
        for (var dy = -2; dy <= 2; dy++) {
          for (var dx = -2; dx <= 2; dx++) {
            final xx = x + dx;
            final yy = y + dy;
            if (xx < 0 || yy < 0 || xx >= n || yy >= n) continue;
            final edge = dx.abs() == 2 || dy.abs() == 2;
            final center = dx == 0 && dy == 0;
            m[yy][xx] = (edge || center) ? 1 : 0;
          }
        }
      }
    }
  }

  static void _reserveFormat(List<List<int>> m) {
    final n = m.length;
    for (var i = 0; i < 9; i++) {
      if (m[8][i] < 0) m[8][i] = 0;
      if (m[i][8] < 0) m[i][8] = 0;
    }
    for (var i = 0; i < 8; i++) {
      if (m[8][n - 1 - i] < 0) m[8][n - 1 - i] = 0;
      if (m[n - 1 - i][8] < 0) m[n - 1 - i][8] = 0;
    }
  }

  static void _reserveVersion(List<List<int>> m) {
    final n = m.length;
    for (var i = 0; i < 6; i++) {
      for (var j = 0; j < 3; j++) {
        m[i][n - 11 + j] = 0;
        m[n - 11 + j][i] = 0;
      }
    }
  }

  static void _placeData(List<List<int>> m, List<int> bits) {
    final n = m.length;
    var bit = 0;
    var upward = true;
    for (var x = n - 1; x > 0; x -= 2) {
      if (x == 6) x--; // skip timing
      for (var i = 0; i < n; i++) {
        final y = upward ? n - 1 - i : i;
        for (var dx = 0; dx < 2; dx++) {
          final xx = x - dx;
          if (m[y][xx] != -1) continue;
          final v = bit < bits.length ? bits[bit++] : 0;
          m[y][xx] = v;
        }
      }
      upward = !upward;
    }
  }

  static int _selectMask(List<List<int>> m) {
    // Prefer mask 0 for speed/stability; still apply scoring lite.
    var best = 0;
    var bestScore = 1 << 30;
    for (var mask = 0; mask < 8; mask++) {
      final clone = m.map((r) => List<int>.from(r)).toList();
      _applyMask(clone, mask);
      final s = _score(clone);
      if (s < bestScore) {
        bestScore = s;
        best = mask;
      }
    }
    return best;
  }

  static void _applyMask(List<List<int>> m, int mask) {
    final n = m.length;
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (m[y][x] < 0) continue;
        // only data modules are still free? We mark function modules as 0/1 already.
        // Use reserved detection: if original was -1 only. After placeData all set.
        // Apply mask only where not function: check pattern positions roughly.
        if (_isFunction(m, x, y)) continue;
        if (_mask(mask, x, y)) m[y][x] ^= 1;
      }
    }
  }

  static bool _isFunction(List<List<int>> m, int x, int y) {
    final n = m.length;
    // Finders + separators
    if (x <= 8 && y <= 8) return true;
    if (x >= n - 8 && y <= 8) return true;
    if (x <= 8 && y >= n - 8) return true;
    // timing
    if (x == 6 || y == 6) return true;
    // format
    if (y == 8 && (x <= 8 || x >= n - 8)) return true;
    if (x == 8 && (y <= 8 || y >= n - 7)) return true;
    return false;
  }

  static bool _mask(int mask, int x, int y) {
    switch (mask) {
      case 0:
        return (x + y) % 2 == 0;
      case 1:
        return y % 2 == 0;
      case 2:
        return x % 3 == 0;
      case 3:
        return (x + y) % 3 == 0;
      case 4:
        return (y ~/ 2 + x ~/ 3) % 2 == 0;
      case 5:
        return (x * y) % 2 + (x * y) % 3 == 0;
      case 6:
        return ((x * y) % 2 + (x * y) % 3) % 2 == 0;
      case 7:
        return ((x + y) % 2 + (x * y) % 3) % 2 == 0;
      default:
        return false;
    }
  }

  static int _score(List<List<int>> m) {
    final n = m.length;
    var score = 0;
    // simple dark balance
    var dark = 0;
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (m[y][x] == 1) dark++;
      }
    }
    final total = n * n;
    final pct = (100 * dark / total - 50).abs();
    score += (pct / 5).floor() * 10;
    return score;
  }

  static void _drawFormat(List<List<int>> m, int ec, int mask) {
    // Format info = (ec << 3) | mask, BCH(15,5)
    // our ec: 0=M,1=L,2=H,3=Q matches QR format EC bits (M=00,L=01,H=10,Q=11)
    var data = (ec.clamp(0, 3) << 3) | mask;
    var d = data << 10;
    for (var i = 14; i >= 10; i--) {
      if ((d >> i) & 1 == 1) d ^= 0x537 << (i - 10);
    }
    final format = ((data << 10) | d) ^ 0x5412;
    final bits = List<int>.generate(15, (i) => (format >> (14 - i)) & 1);

    final n = m.length;
    // horizontal near TL
    final pos1 = <List<int>>[
      [8, 0],
      [8, 1],
      [8, 2],
      [8, 3],
      [8, 4],
      [8, 5],
      [8, 7],
      [8, 8],
      [7, 8],
      [5, 8],
      [4, 8],
      [3, 8],
      [2, 8],
      [1, 8],
      [0, 8],
    ];
    for (var i = 0; i < 15; i++) {
      m[pos1[i][0]][pos1[i][1]] = bits[i];
    }
    // second copy
    final pos2 = <List<int>>[
      [n - 1, 8],
      [n - 2, 8],
      [n - 3, 8],
      [n - 4, 8],
      [n - 5, 8],
      [n - 6, 8],
      [n - 7, 8],
      [8, n - 8],
      [8, n - 7],
      [8, n - 6],
      [8, n - 5],
      [8, n - 4],
      [8, n - 3],
      [8, n - 2],
      [8, n - 1],
    ];
    for (var i = 0; i < 15; i++) {
      m[pos2[i][0]][pos2[i][1]] = bits[i];
    }
  }

  static void _drawVersion(List<List<int>> m, int version) {
    // BCH version info
    var d = version << 12;
    for (var i = 17; i >= 12; i--) {
      if ((d >> i) & 1 == 1) d ^= 0x1f25 << (i - 12);
    }
    final v = (version << 12) | d;
    final n = m.length;
    for (var i = 0; i < 18; i++) {
      final bit = (v >> i) & 1;
      final a = i ~/ 3;
      final b = i % 3;
      m[a][n - 11 + b] = bit;
      m[n - 11 + b][a] = bit;
    }
  }

  // total codewords per version
  static const _totalCodewords = {
    1: 26,
    2: 44,
    3: 70,
    4: 100,
    5: 134,
    6: 172,
    7: 196,
    8: 242,
    9: 292,
    10: 346,
  };
  // ecc codewords per block by ec level then version
  static const _eccCodewordsPerBlock = {
    0: {
      1: 10,
      2: 16,
      3: 26,
      4: 18,
      5: 24,
      6: 16,
      7: 18,
      8: 22,
      9: 22,
      10: 26
    }, // M
    1: {
      1: 7,
      2: 10,
      3: 15,
      4: 20,
      5: 26,
      6: 18,
      7: 20,
      8: 24,
      9: 30,
      10: 18
    }, // L
    2: {
      1: 17,
      2: 28,
      3: 22,
      4: 16,
      5: 22,
      6: 28,
      7: 26,
      8: 26,
      9: 24,
      10: 28
    }, // H
    3: {
      1: 13,
      2: 22,
      3: 18,
      4: 26,
      5: 18,
      6: 24,
      7: 18,
      8: 22,
      9: 20,
      10: 24
    }, // Q
  };
  static const _numBlocks = {
    0: {1: 1, 2: 1, 3: 1, 4: 2, 5: 2, 6: 4, 7: 4, 8: 4, 9: 5, 10: 5}, // M
    1: {1: 1, 2: 1, 3: 1, 4: 1, 5: 1, 6: 2, 7: 2, 8: 2, 9: 2, 10: 4}, // L
    2: {1: 1, 2: 1, 3: 2, 4: 4, 5: 4, 6: 4, 7: 5, 8: 6, 9: 8, 10: 8}, // H
    3: {1: 1, 2: 1, 3: 2, 4: 2, 5: 4, 6: 4, 7: 6, 8: 6, 9: 8, 10: 8}, // Q
  };
}
