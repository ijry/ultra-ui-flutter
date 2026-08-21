import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:qr/qr.dart' as qr;

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

/// QR encoding, delegated to the `qr` package.
///
/// This replaces a hand-rolled byte-mode encoder that was capped at version 10
/// and used an admittedly approximate capacity formula. Cross-checking against
/// the reference implementation showed it selected the wrong version for every
/// sampled payload and silently clamped longer input into a symbol too small to
/// hold it, so the resulting codes could not be scanned. See
/// test/tools/qr_crosscheck_test.dart and qr_defect_probe_test.dart.
///
/// The public API (`UPQrcode.encodeMatrix`, `makeCode`, ...) is unchanged: a
/// square matrix of 0/1 modules.
class _QrEncoder {
  /// [ec] is the QR standard's error-correction index (M=0, L=1, H=2, Q=3),
  /// matching what `_QrPainter._ecLevel` returns.
  static List<List<int>> encode(String text, int ec) {
    if (text.isEmpty) return const <List<int>>[];
    final image = qr.QrImage(
      qr.QrCode(
        payload: qr.QrPayload.fromString(text),
        errorCorrectLevel: _level(ec),
      ),
    );
    return <List<int>>[
      for (var y = 0; y < image.moduleCount; y++)
        <int>[
          for (var x = 0; x < image.moduleCount; x++)
            image.isDark(y, x) ? 1 : 0,
        ],
    ];
  }

  static qr.QrErrorCorrectLevel _level(int ec) => switch (ec) {
        0 => qr.QrErrorCorrectLevel.medium,
        1 => qr.QrErrorCorrectLevel.low,
        2 => qr.QrErrorCorrectLevel.high,
        _ => qr.QrErrorCorrectLevel.quartile,
      };
}
