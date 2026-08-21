import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../utils/up_utils.dart';

/// Canvas gradient style object assignable via setFillStyle / setStrokeStyle.
class UPCanvasGradient {
  UPCanvasGradient._(this._shaderBuilder);

  final ui.Shader Function() _shaderBuilder;
  final List<double> _stops = <double>[];
  final List<Color> _colors = <Color>[];

  void addColorStop(dynamic offset, dynamic color) {
    final o = (num.tryParse('$offset') ?? 0).toDouble().clamp(0.0, 1.0);
    final c = color is Color
        ? color
        : (UPUtils.parseColor(color) ?? const Color(0xFF000000));
    _stops.add(o);
    _colors.add(c);
  }

  ui.Shader createShader() {
    if (_colors.isEmpty) {
      _colors.addAll(const [Color(0xFF000000), Color(0xFFFFFFFF)]);
      _stops.addAll(const [0.0, 1.0]);
    } else if (_colors.length == 1) {
      _colors.add(_colors.first);
      _stops.add(1.0);
    }
    return _shaderBuilder();
  }

  List<Color> get colors => List<Color>.from(_colors);
  List<double> get stops => List<double>.from(_stops);
}

/// Port of u-canvas / up-canvas with a uni-canvas style drawing API.
class UPCanvasController {
  /// Source host helper.
  dynamic reject([dynamic e]) => e;

  /// Source host helper.
  dynamic lastAppliedFont;
  void applyFont([dynamic font]) {
    lastAppliedFont = font;
    if (font != null) {
      setFont('$font');
    }
  }

  UPCanvasState? _state;

  void _attach(UPCanvasState state) => _state = state;
  void _detach(UPCanvasState state) {
    if (identical(_state, state)) _state = null;
  }

  /// Source `getCanvasElement`.
  dynamic getCanvasElement([dynamic _]) => _state;

  /// Source `getRawContext` / `getCanvasContext`.
  dynamic getRawContext([dynamic _]) => canvas;
  dynamic getCanvasContext([dynamic _]) => canvas;

  /// Source `getWidth` / `getHeight`.
  double getWidth([dynamic _]) => width;
  double getHeight([dynamic _]) => height;

  /// Source `callContext` — invoke named drawing helper if present.
  dynamic callContext(String method, [List args = const []]) {
    switch (method) {
      case 'beginPath':
        beginPath();
        return null;
      case 'closePath':
        closePath();
        return null;
      case 'fill':
        fill();
        return null;
      case 'stroke':
        stroke();
        return null;
      case 'clear':
      case 'clearCanvas':
        clear();
        return null;
      case 'draw':
        draw(args.isEmpty ? true : args.first == true);
        return null;
      case 'save':
        save();
        return null;
      case 'restore':
        restore();
        return null;
      case 'clip':
        clip();
        return null;
      case 'resetTransform':
        resetTransform();
        return null;
      case 'getLineDash':
        return getLineDash();
      case 'setLineDash':
        setLineDash(args.isEmpty
            ? const <dynamic>[]
            : (args.first is List ? args.first as List : args));
        return null;
      default:
        return _callContextWithArgs(method, args);
    }
  }

  /// Numeric-argument half of [callContext], split out to keep each switch
  /// readable.
  dynamic _callContextWithArgs(String method, List args) {
    double at(int i, [double fallback = 0]) {
      if (i >= args.length) return fallback;
      return (num.tryParse('${args[i]}') ?? fallback).toDouble();
    }

    bool flag(int i) => i < args.length && args[i] == true;

    switch (method) {
      case 'moveTo':
        moveTo(at(0), at(1));
      case 'lineTo':
        lineTo(at(0), at(1));
      case 'rect':
        rect(at(0), at(1), at(2), at(3));
      case 'arc':
        arc(at(0), at(1), at(2), at(3), at(4), flag(5));
      case 'arcTo':
        arcTo(at(0), at(1), at(2), at(3), at(4));
      case 'bezierCurveTo':
        bezierCurveTo(at(0), at(1), at(2), at(3), at(4), at(5));
      case 'quadraticCurveTo':
        quadraticCurveTo(at(0), at(1), at(2), at(3));
      case 'ellipse':
        ellipse(at(0), at(1), at(2), at(3), at(4), at(5), at(6), flag(7));
      case 'translate':
        translate(at(0), at(1));
      case 'rotate':
        rotate(at(0));
      case 'scale':
        scale(at(0), at(1, at(0)));
      case 'setTransform':
        setTransform(at(0), at(1), at(2), at(3), at(4), at(5));
      case 'transform':
        transform(at(0), at(1), at(2), at(3), at(4), at(5));
      case 'setMiterLimit':
        setMiterLimit(at(0, 10));
      case 'setGlobalCompositeOperation':
        setGlobalCompositeOperation(args.isEmpty ? '' : '${args.first}');
      default:
        return null;
    }
    return null;
  }

  /// Source `getImageData`.
  Future<Map> getImageData([
    dynamic x = 0,
    dynamic y = 0,
    dynamic w,
    dynamic h,
  ]) async {
    final image = await toImage();
    final ww = (w is num ? w.toDouble() : double.tryParse('$w')) ?? width;
    final hh = (h is num ? h.toDouble() : double.tryParse('$h')) ?? height;
    return {
      'x': x,
      'y': y,
      'width': ww,
      'height': hh,
      'image': image,
      'data': image,
    };
  }

  /// Source `putImageData`.
  Future<bool> putImageData(dynamic image,
      [dynamic dx = 0, dynamic dy = 0]) async {
    if (image is ui.Image) {
      return drawImage(image, dx, dy);
    }
    if (image is Map && image['image'] is ui.Image) {
      return drawImage(image['image'] as ui.Image, dx, dy);
    }
    return false;
  }

  Canvas? get canvas => _state?._recording;
  Size get size => _state?._size ?? Size.zero;
  double get width => size.width;
  double get height => size.height;

  /// Source data.
  dynamic get ctx => this;
  double dpr = 1;
  double get heightLocal => height;
  double get widthLocal => width;

  /// Source host helpers.
  dynamic parseSize([dynamic v]) => v;
  dynamic resolve([dynamic v]) => v;
  void setNewSize([dynamic w, dynamic h]) {
    final ww = (w is num ? w.toDouble() : double.tryParse('$w'));
    final hh = (h is num ? h.toDouble() : double.tryParse('$h'));
    _state?._setNewSize(ww, hh);
  }

  Future<void> setTimeout([dynamic cb, int ms = 0]) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
    if (cb is Function) cb();
  }

  String rootId = 'up-canvas';

  void clear() => _state?._clear();
  void clearCanvas() => clear();
  void refresh() => _state?._commit();
  void draw([bool reserve = true]) => _state?._commit(reserve: reserve);

  void beginPath() => _state?._beginPath();
  void closePath() => _state?._closePath();
  void moveTo(double x, double y) => _state?._moveTo(x, y);
  void lineTo(double x, double y) => _state?._lineTo(x, y);
  void rect(double x, double y, double w, double h) =>
      _state?._rect(x, y, w, h);
  void arc(
    double x,
    double y,
    double radius,
    double startAngle,
    double endAngle, [
    bool anticlockwise = false,
  ]) =>
      _state?._arc(x, y, radius, startAngle, endAngle, anticlockwise);
  void bezierCurveTo(
    double cp1x,
    double cp1y,
    double cp2x,
    double cp2y,
    double x,
    double y,
  ) =>
      _state?._bezier(cp1x, cp1y, cp2x, cp2y, x, y);
  void quadraticCurveTo(double cpx, double cpy, double x, double y) =>
      _state?._quadratic(cpx, cpy, x, y);

  void fill() => _state?._fill();
  void stroke() => _state?._stroke();
  void clip() => _state?._clip();
  void clearRect(double x, double y, double w, double h) =>
      _state?._clearRect(x, y, w, h);
  void fillRect(double x, double y, double w, double h) =>
      _state?._fillRect(x, y, w, h);
  void strokeRect(double x, double y, double w, double h) =>
      _state?._strokeRect(x, y, w, h);
  void fillText(dynamic text, double x, double y) =>
      _state?._fillText('$text', x, y);
  void strokeText(dynamic text, double x, double y) =>
      _state?._strokeText('$text', x, y);

  void save() => _state?._save();
  void restore() => _state?._restore();
  void translate(double x, double y) => _state?._translate(x, y);
  void rotate(double angle) => _state?._rotate(angle);
  void scale(double x, [double? y]) => _state?._scale(x, y ?? x);

  /// Source `arcTo`.
  void arcTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double radius,
  ) =>
      _state?._arcTo(x1, y1, x2, y2, radius);

  /// Source `ellipse`.
  void ellipse(
    double x,
    double y,
    double radiusX,
    double radiusY,
    double rotation,
    double startAngle,
    double endAngle, [
    bool anticlockwise = false,
  ]) =>
      _state?._ellipse(
        x,
        y,
        radiusX,
        radiusY,
        rotation,
        startAngle,
        endAngle,
        anticlockwise,
      );

  /// Source `setTransform` — replaces the current matrix.
  void setTransform(
    double a,
    double b,
    double c,
    double d,
    double e,
    double f,
  ) =>
      _state?._setTransform(a, b, c, d, e, f);

  /// Source `transform` — multiplies into the current matrix.
  void transform(
    double a,
    double b,
    double c,
    double d,
    double e,
    double f,
  ) =>
      _state?._transform(a, b, c, d, e, f);

  /// Source `resetTransform`.
  void resetTransform() => _state?._resetTransform();

  /// Source `setLineDash`.
  void setLineDash([List<dynamic> segments = const <dynamic>[]]) {
    _state?._setLineDash(<double>[
      for (final s in segments) (num.tryParse('$s') ?? 0).toDouble(),
    ]);
  }

  /// Source `getLineDash`.
  List<double> getLineDash() => _state?._getLineDash() ?? <double>[];

  /// Source `setMiterLimit`.
  void setMiterLimit(dynamic miterLimit) =>
      _state?._setMiterLimit((num.tryParse('$miterLimit') ?? 10).toDouble());

  /// Source `setGlobalCompositeOperation`.
  void setGlobalCompositeOperation(String operation) =>
      _state?._setGlobalCompositeOperation(operation);

  /// The composite operation currently set, for host inspection.
  String get globalCompositeOperation =>
      _state?._getGlobalCompositeOperation() ?? 'source-over';

  /// Source `createPattern`.
  ///
  /// Returns an image shader usable as a fill or stroke style, mirroring the
  /// source's canvas pattern object.
  ui.ImageShader? createPattern(dynamic image, [String repetition = 'repeat']) {
    final resolved = image is ui.Image
        ? image
        : (image is Map && image['image'] is ui.Image
            ? image['image'] as ui.Image
            : null);
    if (resolved == null) return null;
    final tile = switch (repetition) {
      'repeat-x' || 'repeat-y' || 'repeat' => ui.TileMode.repeated,
      'no-repeat' => ui.TileMode.clamp,
      _ => ui.TileMode.repeated,
    };
    return ui.ImageShader(
      resolved,
      tile,
      tile,
      Matrix4.identity().storage,
    );
  }

  /// Source `estimateTextWidth` — synchronous measurement helper.
  double estimateTextWidth(dynamic text, [dynamic fontSize]) =>
      _state?._estimateTextWidth(
        '${text ?? ''}',
        fontSize == null ? null : (num.tryParse('$fontSize'))?.toDouble(),
      ) ??
      0;

  /// Source `measureTextAsync` — the source awaits a webview round trip; on
  /// Flutter measurement is already synchronous, so this resolves immediately.
  Future<Map<String, dynamic>> measureTextAsync(
    dynamic text, [
    dynamic fontSize,
  ]) async =>
      <String, dynamic>{'width': estimateTextWidth(text, fontSize)};

  /// Source `onWebViewMessage` — the source's nvue/webview canvas bridge.
  ///
  /// Flutter draws directly, so there is no bridge to receive from; the payload
  /// is recorded for host inspection and API compatibility.
  dynamic lastWebViewMessage;
  void onWebViewMessage([dynamic event]) {
    lastWebViewMessage = event;
  }

  /// Source `onWebViewTouch`.
  dynamic lastWebViewTouch;
  void onWebViewTouch([dynamic message]) {
    lastWebViewTouch = message;
  }

  /// Source `readNvueFileAsDataURL` — nvue-only file bridge.
  ///
  /// Flutter has no nvue file layer, so this resolves to null rather than
  /// pretending to produce a data URL.
  Future<String?> readNvueFileAsDataURL([dynamic path]) async => null;

  void setFillStyle(dynamic color) => _state?._setFill(color);
  void setStrokeStyle(dynamic color) => _state?._setStroke(color);
  void setLineWidth(dynamic width) =>
      _state?._setLineWidth((num.tryParse('$width') ?? 1).toDouble());
  void setLineCap(String lineCap) => _state?._setLineCap(lineCap);
  void setLineJoin(String lineJoin) => _state?._setLineJoin(lineJoin);
  void setGlobalAlpha(dynamic alpha) =>
      _state?._setGlobalAlpha((num.tryParse('$alpha') ?? 1).toDouble());
  void setFontSize(dynamic size) =>
      _state?._setFontSize((num.tryParse('$size') ?? 14).toDouble());
  void setFont(String font) => _state?._setFont(font);
  void setTextAlign(String align) => _state?._setTextAlign(align);
  void setTextBaseline(String baseline) => _state?._setTextBaseline(baseline);
  void setShadow(
    dynamic offsetX,
    dynamic offsetY,
    dynamic blur,
    dynamic color,
  ) =>
      _state?._setShadow(offsetX, offsetY, blur, color);
  void setLineStyle(dynamic lineColor, dynamic lineWidth) {
    setLineCap('round');
    setLineJoin('round');
    setStrokeStyle(lineColor);
    setLineWidth(lineWidth);
  }

  UPCanvasGradient createLinearGradient(
    double x0,
    double y0,
    double x1,
    double y1,
  ) {
    late UPCanvasGradient gradient;
    gradient = UPCanvasGradient._(() {
      return ui.Gradient.linear(
        Offset(x0, y0),
        Offset(x1, y1),
        gradient.colors,
        gradient.stops,
      );
    });
    return gradient;
  }

  UPCanvasGradient createRadialGradient(
    double x0,
    double y0,
    double r0,
    double x1,
    double y1,
    double r1,
  ) {
    late UPCanvasGradient gradient;
    // Flutter radial gradient uses one center/radius; approximate with outer.
    final center = Offset(x1, y1);
    final radius = r1 <= 0 ? (r0 <= 0 ? 1.0 : r0) : r1;
    gradient = UPCanvasGradient._(() {
      return ui.Gradient.radial(
        center,
        radius,
        gradient.colors,
        gradient.stops,
      );
    });
    return gradient;
  }

  /// Host may pre-register images: `controller.putImage(src, uiImage)`.
  void putImage(String src, ui.Image image) => _state?._putImage(src, image);

  Future<ui.Image?> loadImage(dynamic source) =>
      _state?._loadImage(source) ?? Future.value(null);

  /// Canvas-compatible drawImage overloads:
  /// - drawImage(image, dx, dy)
  /// - drawImage(image, dx, dy, dWidth, dHeight)
  /// - drawImage(image, sx, sy, sWidth, sHeight, dx, dy, dWidth, dHeight)
  Future<bool> drawImage(dynamic source,
      [dynamic a,
      dynamic b,
      dynamic c,
      dynamic d,
      dynamic e,
      dynamic f,
      dynamic g,
      dynamic h]) async {
    return await _state?._drawImage(source, a, b, c, d, e, f, g, h) ?? false;
  }

  Map measureText(dynamic text) {
    final width = _state?._measureText('$text') ?? ('$text'.length * 8.4);
    return {'width': width};
  }

  Future<ui.Image?> toImage({double pixelRatio = 1}) =>
      _state?._toImage(pixelRatio: pixelRatio) ?? Future.value(null);

  /// The committed picture, or null before the first `draw`.
  ///
  /// Exposed for tests and hosts that need the drawn output without going
  /// through [toImage], which relies on `RenderRepaintBoundary` and therefore
  /// cannot complete under `flutter_test`.
  ui.Picture? get recordedPicture => _state?.picture;

  /// Bounding box of the path built so far, for inspection and testing.
  Rect get currentPathBounds => _state?._path.getBounds() ?? Rect.zero;

  /// Sizes the recording surface without waiting for a paint pass.
  ///
  /// See [UPCanvasState.ensureSize].
  void ensureSize(double width, double height) =>
      _state?.ensureSize(Size(width, height));

  Future<Map> toTempFilePath({
    double? x,
    double? y,
    double? width,
    double? height,
    double? destWidth,
    double? destHeight,
    String fileType = 'png',
    double quality = 1,
  }) async {
    final image = await toImage(pixelRatio: 1);
    if (image == null) {
      return {'errMsg': 'canvas empty', 'tempFilePath': ''};
    }
    return {
      'errMsg': 'ok',
      'tempFilePath':
          'memory://canvas_${DateTime.now().millisecondsSinceEpoch}.$fileType',
      'width': destWidth ?? width ?? image.width.toDouble(),
      'height': destHeight ?? height ?? image.height.toDouble(),
      'fileType': fileType,
      'quality': quality,
      'image': image,
    };
  }
}

class UPCanvas extends StatefulWidget {
  const UPCanvas({
    super.key,
    this.canvasId = '',
    this.width = 300,
    this.height = 300,
    this.unit = 'px',
    this.useRootHeightAndWidth = false,
    this.bgColor = '#ffffff',
    this.disableScroll = false,
    this.controller,
    this.onReady,
    this.onTouchStart,
    this.onTouchMove,
    this.onTouchEnd,

    /// Optional host image loader for string sources (network/asset).
    this.imageLoader,
    this.customStyle,
  });

  final String canvasId;
  final dynamic width;
  final dynamic height;
  final String unit;
  final bool useRootHeightAndWidth;
  final dynamic bgColor;
  final bool disableScroll;
  final UPCanvasController? controller;
  final ValueChanged<UPCanvasController>? onReady;
  final ValueChanged<Offset>? onTouchStart;
  final ValueChanged<Offset>? onTouchMove;
  final ValueChanged<Offset>? onTouchEnd;

  /// Source emit alias: touchstart.
  ValueChanged<Offset>? get onTouchstart => onTouchStart;

  /// Source emit alias: touchmove.
  ValueChanged<Offset>? get onTouchmove => onTouchMove;

  /// Source emit alias: touchend.
  ValueChanged<Offset>? get onTouchend => onTouchEnd;
  final Future<ui.Image?> Function(String src)? imageLoader;

  final BoxDecoration? customStyle;

  /// Source method: rgba helper.
  dynamic rgba([dynamic color, dynamic alpha]) {
    final parsed = UPUtils.parseColor(color) ?? const Color(0x00000000);
    final a = alpha == null
        ? parsed.a
        : (num.tryParse('$alpha') ?? parsed.a).toDouble().clamp(0.0, 1.0);
    int channel(double value) => (value * 255).round().clamp(0, 255).toInt();
    return 'rgba(${channel(parsed.r)},${channel(parsed.g)},${channel(parsed.b)},$a)';
  }

  /// Source computed: actualWidth.
  dynamic get actualWidth => width;

  /// Source computed: actualHeight.
  dynamic get actualHeight => height;

  @override
  State<UPCanvas> createState() => UPCanvasState();
}

class UPCanvasState extends State<UPCanvas> {
  final repaint = ValueNotifier<int>(0);
  final boundaryKey = GlobalKey();
  final Map<String, ui.Image> _imageCache = {};
  ui.Picture? picture;
  Canvas? _recording;
  ui.PictureRecorder? recorder;
  Path _path = Path();

  /// The path's current point, which Path itself does not expose.
  Offset? _currentPoint;
  Size _size = Size.zero;
  Color fill = const Color(0xFF000000);
  Color stroke = const Color(0xFF000000);
  ui.Shader? fillShader;
  ui.Shader? strokeShader;
  double _lineWidth = 1;

  /// Canvas 2D dash pattern from `setLineDash`.
  List<double> _lineDash = <double>[];

  /// Canvas 2D `miterLimit`.
  double _miterLimit = 10;

  /// Canvas 2D `globalCompositeOperation`, retained for host inspection.
  String _globalCompositeOperation = 'source-over';
  double _globalAlpha = 1;
  double _fontSize = 14;
  String _fontFamily = 'sans-serif';
  FontWeight _fontWeight = FontWeight.normal;
  TextAlign _textAlign = TextAlign.left;
  TextBaseline _textBaseline = TextBaseline.alphabetic;
  StrokeCap _lineCap = StrokeCap.butt;
  StrokeJoin _lineJoin = StrokeJoin.miter;
  double _shadowOffsetX = 0;
  double _shadowOffsetY = 0;
  double _shadowBlur = 0;
  late final UPCanvasController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? UPCanvasController();
    controller._attach(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onReady?.call(controller);
    });
  }

  @override
  void dispose() {
    controller._detach(this);
    picture?.dispose();
    repaint.dispose();
    super.dispose();
  }

  Color _parsePaintColor(dynamic color) {
    if (color is Color) return color;
    return UPUtils.parseColor(color) ?? const Color(0xFF000000);
  }

  Paint _fillPaint() {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = _shadowBlur > 0
          ? MaskFilter.blur(BlurStyle.normal, _shadowBlur)
          : null;
    if (fillShader != null) {
      paint.shader = fillShader;
      paint.color = const Color(0xFFFFFFFF).withValues(alpha: _globalAlpha);
    } else {
      paint.color = fill.withValues(alpha: fill.a * _globalAlpha);
    }
    return paint;
  }

  Paint _strokePaint() {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _lineWidth
      ..strokeCap = _lineCap
      ..strokeJoin = _lineJoin
      ..strokeMiterLimit = _miterLimit
      ..maskFilter = _shadowBlur > 0
          ? MaskFilter.blur(BlurStyle.normal, _shadowBlur)
          : null;
    if (strokeShader != null) {
      paint.shader = strokeShader;
      paint.color = const Color(0xFFFFFFFF).withValues(alpha: _globalAlpha);
    } else {
      paint.color = stroke.withValues(alpha: stroke.a * _globalAlpha);
    }
    return paint;
  }

  void _ensure(Size size) {
    if (recorder != null && _size == size) return;
    _size = size;
    recorder = ui.PictureRecorder();
    _recording = Canvas(recorder!);
    final bg = UPUtils.parseColor(widget.bgColor) ?? const Color(0xFFFFFFFF);
    _recording!.drawRect(Offset.zero & size, Paint()..color = bg);
    _path = Path();
  }

  /// Source lifecycle / export helpers (Batch I).
  void initCanvas([dynamic _]) {
    if (_size != Size.zero) {
      _ensure(_size);
    }
  }

  /// Prepares the recording surface at an explicit size.
  ///
  /// Normally the size arrives from the painter's layout pass. Under
  /// `flutter_test` no paint occurs unless something forces it, so a caller
  /// that needs to draw before first paint can size the surface directly.
  void ensureSize(Size size) => _ensure(size);

  dynamic getCanvasElement([dynamic _]) => this;
  dynamic getCanvasNode([dynamic _]) => getCanvasElement();
  dynamic lastResult;
  bool lastSuccess = false;

  void onTouchStart([Offset? p]) => widget.onTouchStart?.call(p ?? Offset.zero);
  void onTouchMove([Offset? p]) => widget.onTouchMove?.call(p ?? Offset.zero);
  void onTouchEnd([Offset? p]) => widget.onTouchEnd?.call(p ?? Offset.zero);
  Future<ui.Image?> exportImage({double pixelRatio = 1}) =>
      _toImage(pixelRatio: pixelRatio);
  void complete([dynamic payload]) {
    success(payload ?? true);
  }

  void success([dynamic payload]) {
    lastSuccess = true;
    lastResult = payload ?? true;
  }

  void fail([dynamic payload]) {
    lastSuccess = false;
    lastResult = payload ?? false;
  }

  void _setNewSize(double? w, double? h) {
    final nw = w ?? (_size == Size.zero ? 300.0 : _size.width);
    final nh = h ?? (_size == Size.zero ? 150.0 : _size.height);
    _ensure(Size(nw, nh));
    if (mounted) setState(() {});
  }

  // Public State API aliases for GlobalKey callers.
  void clear() => _clear();
  void clearCanvas() => _clear();
  void refresh() => _commit();
  void draw([bool reserve = true]) => _commit(reserve: reserve);

  void _clear() {
    if (_size == Size.zero) return;
    recorder = ui.PictureRecorder();
    _recording = Canvas(recorder!);
    final bg = UPUtils.parseColor(widget.bgColor) ?? const Color(0xFFFFFFFF);
    _recording!.drawRect(Offset.zero & _size, Paint()..color = bg);
    _path = Path();
    _commit();
  }

  void _beginPath() {
    _path = Path();
    _currentPoint = null;
  }

  void _closePath() => _path.close();
  void _moveTo(double x, double y) {
    _path.moveTo(x, y);
    _currentPoint = Offset(x, y);
  }

  void _lineTo(double x, double y) {
    _path.lineTo(x, y);
    _currentPoint = Offset(x, y);
  }

  void _rect(double x, double y, double w, double h) =>
      _path.addRect(Rect.fromLTWH(x, y, w, h));
  void _arc(
    double x,
    double y,
    double radius,
    double startAngle,
    double endAngle,
    bool anticlockwise,
  ) {
    final sweep = anticlockwise
        ? -(2 * math.pi - (endAngle - startAngle)).abs()
        : (endAngle - startAngle);
    _path.addArc(
      Rect.fromCircle(center: Offset(x, y), radius: radius),
      startAngle,
      sweep,
    );
  }

  void _bezier(
    double cp1x,
    double cp1y,
    double cp2x,
    double cp2y,
    double x,
    double y,
  ) =>
      _cubicTo(cp1x, cp1y, cp2x, cp2y, x, y);

  void _cubicTo(
    double cp1x,
    double cp1y,
    double cp2x,
    double cp2y,
    double x,
    double y,
  ) {
    _path.cubicTo(cp1x, cp1y, cp2x, cp2y, x, y);
    _currentPoint = Offset(x, y);
  }

  void _quadratic(double cpx, double cpy, double x, double y) {
    _path.quadraticBezierTo(cpx, cpy, x, y);
    _currentPoint = Offset(x, y);
  }

  void _fill() => _recording?.drawPath(_path, _fillPaint());
  void _stroke() => _recording?.drawPath(_path, _strokePaint());
  void _clip() => _recording?.clipPath(_path);

  void _clearRect(double x, double y, double w, double h) {
    final bg = UPUtils.parseColor(widget.bgColor) ?? const Color(0xFFFFFFFF);
    _recording?.drawRect(Rect.fromLTWH(x, y, w, h), Paint()..color = bg);
  }

  void _fillRect(double x, double y, double w, double h) {
    final paint = _fillPaint();
    if (_shadowBlur > 0 || _shadowOffsetX != 0 || _shadowOffsetY != 0) {
      _recording?.save();
      _recording?.translate(_shadowOffsetX, _shadowOffsetY);
      _recording?.drawRect(Rect.fromLTWH(x, y, w, h), paint);
      _recording?.restore();
    }
    _recording?.drawRect(Rect.fromLTWH(x, y, w, h), paint);
  }

  void _strokeRect(double x, double y, double w, double h) {
    _recording?.drawRect(Rect.fromLTWH(x, y, w, h), _strokePaint());
  }

  TextPainter _textPainter(String text, {required bool strokeOnly}) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color:
              strokeOnly ? null : fill.withValues(alpha: fill.a * _globalAlpha),
          fontSize: _fontSize,
          fontFamily: _fontFamily,
          fontWeight: _fontWeight,
          foreground: strokeOnly ? _strokePaint() : null,
        ),
      ),
      textAlign: _textAlign,
      textDirection: TextDirection.ltr,
    )..layout();
  }

  Offset _textOffset(TextPainter painter, double x, double y) {
    var dx = x;
    var dy = y;
    if (_textAlign == TextAlign.center) dx -= painter.width / 2;
    if (_textAlign == TextAlign.right) dx -= painter.width;
    if (_textBaseline == TextBaseline.alphabetic) {
      dy -= painter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    } else if (_textBaseline == TextBaseline.ideographic) {
      dy -= painter.height;
    }
    return Offset(dx, dy);
  }

  void _fillText(String text, double x, double y) {
    final painter = _textPainter(text, strokeOnly: false);
    painter.paint(_recording!, _textOffset(painter, x, y));
  }

  void _strokeText(String text, double x, double y) {
    final painter = _textPainter(text, strokeOnly: true);
    painter.paint(_recording!, _textOffset(painter, x, y));
  }

  double _measureText(String text) {
    final painter = _textPainter(text, strokeOnly: false);
    return painter.width;
  }

  /// Source `estimateTextWidth` — measures at an overridden font size without
  /// disturbing the context's own.
  double _estimateTextWidth(String text, double? fontSize) {
    if (fontSize == null) return _measureText(text);
    final previous = _fontSize;
    _fontSize = fontSize;
    final width = _measureText(text);
    _fontSize = previous;
    return width;
  }

  void _save() => _recording?.save();
  void _restore() => _recording?.restore();
  void _translate(double x, double y) => _recording?.translate(x, y);
  void _rotate(double angle) => _recording?.rotate(angle);
  void _scale(double x, double y) => _recording?.scale(x, y);

  /// Canvas 2D `arcTo` — an arc of [radius] tangent to both the line from the
  /// current point to (x1,y1) and the line from (x1,y1) to (x2,y2).
  ///
  /// Not `Path.arcToPoint`, which arcs *to* the given point: the 2D operation
  /// fillets the corner at (x1,y1) and generally stops short of (x2,y2). It
  /// first draws a straight line to the arc's start tangent point.
  void _arcTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double radius,
  ) {
    // Path.computeMetrics reports nothing for a path that is only a moveTo, so
    // the current point is tracked alongside it.
    final p0 = _currentPoint;
    if (p0 == null) {
      // No current point: the spec makes this a moveTo.
      _moveTo(x1, y1);
      return;
    }
    final corner = Offset(x1, y1);
    final p2 = Offset(x2, y2);

    // Unit vectors from the corner back toward p0 and out toward p2.
    final v1 = p0 - corner;
    final v2 = p2 - corner;
    final len1 = v1.distance;
    final len2 = v2.distance;
    if (radius <= 0 || len1 == 0 || len2 == 0) {
      _lineTo(x1, y1);
      return;
    }
    final u1 = v1 / len1;
    final u2 = v2 / len2;

    // Half the angle at the corner; the tangent distance is r / tan(theta).
    final cosAngle = (u1.dx * u2.dx + u1.dy * u2.dy).clamp(-1.0, 1.0);
    final angle = math.acos(cosAngle);
    if (angle == 0 || angle == math.pi) {
      // Collinear: no arc is possible, so the corner is just a line.
      _lineTo(x1, y1);
      return;
    }
    final tangentDistance = radius / math.tan(angle / 2);
    if (tangentDistance > len1 || tangentDistance > len2) {
      // The fillet does not fit between the points; degrade to the corner.
      _lineTo(x1, y1);
      return;
    }

    final start = corner + u1 * tangentDistance;
    final end = corner + u2 * tangentDistance;
    // Cross product sign gives the turn direction.
    final clockwise = (u1.dx * u2.dy - u1.dy * u2.dx) < 0;

    _lineTo(start.dx, start.dy);
    _path.arcToPoint(
      end,
      radius: Radius.circular(radius),
      clockwise: clockwise,
    );
    _currentPoint = end;
  }

  /// Canvas 2D `ellipse`.
  void _ellipse(
    double x,
    double y,
    double radiusX,
    double radiusY,
    double rotation,
    double startAngle,
    double endAngle,
    bool anticlockwise,
  ) {
    final sweep = anticlockwise
        ? -(2 * math.pi - (endAngle - startAngle)).abs()
        : (endAngle - startAngle);
    final rect = Rect.fromCenter(
      center: Offset(x, y),
      width: radiusX * 2,
      height: radiusY * 2,
    );
    if (rotation == 0) {
      _path.addArc(rect, startAngle, sweep);
      return;
    }
    // Rotation is about the ellipse centre, so rotate around it rather than
    // the canvas origin.
    final rotated = Path()..addArc(rect, startAngle, sweep);
    final matrix = Matrix4.identity()
      ..translateByDouble(x, y, 0, 1)
      ..rotateZ(rotation)
      ..translateByDouble(-x, -y, 0, 1);
    _path.addPath(rotated.transform(matrix.storage), Offset.zero);
  }

  /// Canvas 2D `setTransform` — replaces the current matrix.
  ///
  /// Flutter's Canvas has no absolute-matrix setter, so the transform is
  /// reset to the recording's base state first, matching the 2D semantics.
  void _setTransform(
    double a,
    double b,
    double c,
    double d,
    double e,
    double f,
  ) {
    _resetTransform();
    _transform(a, b, c, d, e, f);
  }

  /// Canvas 2D `transform` — multiplies into the current matrix.
  void _transform(
    double a,
    double b,
    double c,
    double d,
    double e,
    double f,
  ) {
    // 2D order is [a c e / b d f], column-major into a 4x4.
    _recording?.transform(Float64List.fromList(<double>[
      a, b, 0, 0, //
      c, d, 0, 0, //
      0, 0, 1, 0, //
      e, f, 0, 1, //
    ]));
  }

  /// Canvas 2D `resetTransform`.
  ///
  /// Restores to the transform captured when recording began, which is the
  /// closest equivalent to resetting to the identity matrix.
  void _resetTransform() {
    _recording?.restore();
    _recording?.save();
  }

  void _setLineDash(List<double> segments) {
    _lineDash = List<double>.from(segments);
  }

  List<double> _getLineDash() => List<double>.from(_lineDash);

  void _setMiterLimit(double limit) => _miterLimit = limit;

  void _setGlobalCompositeOperation(String operation) {
    _globalCompositeOperation = operation;
  }

  String _getGlobalCompositeOperation() => _globalCompositeOperation;

  void _setFill(dynamic color) {
    if (color is UPCanvasGradient) {
      fillShader = color.createShader();
      fill = const Color(0xFF000000);
      return;
    }
    if (color is ui.Shader) {
      fillShader = color;
      fill = const Color(0xFF000000);
      return;
    }
    fillShader = null;
    fill = _parsePaintColor(color);
  }

  void _setStroke(dynamic color) {
    if (color is UPCanvasGradient) {
      strokeShader = color.createShader();
      stroke = const Color(0xFF000000);
      return;
    }
    if (color is ui.Shader) {
      strokeShader = color;
      stroke = const Color(0xFF000000);
      return;
    }
    strokeShader = null;
    stroke = _parsePaintColor(color);
  }

  void _setLineWidth(double w) => _lineWidth = w;
  void _setGlobalAlpha(double a) => _globalAlpha = a.clamp(0, 1);
  void _setFontSize(double size) => _fontSize = size;
  void _setFont(String font) {
    final matched = RegExp(r'(\d+(?:\.\d+)?)px').firstMatch(font);
    if (matched != null) {
      _fontSize = double.parse(matched.group(1)!);
    }
    if (font.toLowerCase().contains('bold')) {
      _fontWeight = FontWeight.w700;
    } else {
      _fontWeight = FontWeight.normal;
    }
    final family = font
        .replaceAll(RegExp(r'(bold|italic|normal)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\d+(?:\.\d+)?px'), '')
        .trim();
    if (family.isNotEmpty) _fontFamily = family;
  }

  void _setTextAlign(String align) {
    switch (align) {
      case 'center':
        _textAlign = TextAlign.center;
      case 'right':
      case 'end':
        _textAlign = TextAlign.right;
      default:
        _textAlign = TextAlign.left;
    }
  }

  void _setTextBaseline(String baseline) {
    switch (baseline) {
      case 'top':
      case 'hanging':
        _textBaseline = TextBaseline.ideographic;
      case 'middle':
        _textBaseline = TextBaseline.alphabetic;
      default:
        _textBaseline = TextBaseline.alphabetic;
    }
  }

  void _setLineCap(String lineCap) {
    switch (lineCap) {
      case 'round':
        _lineCap = StrokeCap.round;
      case 'square':
        _lineCap = StrokeCap.square;
      default:
        _lineCap = StrokeCap.butt;
    }
  }

  void _setLineJoin(String lineJoin) {
    switch (lineJoin) {
      case 'round':
        _lineJoin = StrokeJoin.round;
      case 'bevel':
        _lineJoin = StrokeJoin.bevel;
      default:
        _lineJoin = StrokeJoin.miter;
    }
  }

  void _setShadow(
    dynamic offsetX,
    dynamic offsetY,
    dynamic blur,
    dynamic color,
  ) {
    _shadowOffsetX = (num.tryParse('$offsetX') ?? 0).toDouble();
    _shadowOffsetY = (num.tryParse('$offsetY') ?? 0).toDouble();
    _shadowBlur = (num.tryParse('$blur') ?? 0).toDouble();
    _parsePaintColor(color);
  }

  void _putImage(String src, ui.Image image) {
    _imageCache[src] = image;
  }

  Future<ui.Image?> _loadImage(dynamic source) async {
    if (source is ui.Image) return source;
    if (source is String) {
      final cached = _imageCache[source];
      if (cached != null) return cached;
      if (widget.imageLoader != null) {
        final loaded = await widget.imageLoader!(source);
        if (loaded != null) {
          _imageCache[source] = loaded;
        }
        return loaded;
      }
      return null;
    }
    return null;
  }

  Future<bool> _drawImage(
    dynamic source, [
    dynamic a,
    dynamic b,
    dynamic c,
    dynamic d,
    dynamic e,
    dynamic f,
    dynamic g,
    dynamic h,
  ]) async {
    final image = await _loadImage(source);
    if (image == null || _recording == null) return false;

    final args = <double>[
      for (final v in [a, b, c, d, e, f, g, h])
        if (v != null) (num.tryParse('$v') ?? 0).toDouble()
    ];

    final paint = Paint()
      ..filterQuality = FilterQuality.medium
      ..isAntiAlias = true
      ..color = const Color(0xFFFFFFFF).withValues(alpha: _globalAlpha);

    if (args.length <= 2) {
      final dx = args.isNotEmpty ? args[0] : 0.0;
      final dy = args.length > 1 ? args[1] : 0.0;
      _recording!.drawImage(image, Offset(dx, dy), paint);
    } else if (args.length <= 4) {
      final dx = args[0];
      final dy = args[1];
      final dw = args[2];
      final dh = args[3];
      _recording!.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(dx, dy, dw, dh),
        paint,
      );
    } else if (args.length >= 8) {
      final sx = args[0];
      final sy = args[1];
      final sw = args[2];
      final sh = args[3];
      final dx = args[4];
      final dy = args[5];
      final dw = args[6];
      final dh = args[7];
      _recording!.drawImageRect(
        image,
        Rect.fromLTWH(sx, sy, sw, sh),
        Rect.fromLTWH(dx, dy, dw, dh),
        paint,
      );
    } else {
      return false;
    }
    return true;
  }

  void _commit({bool reserve = true}) {
    if (recorder == null) return;
    final next = recorder!.endRecording();
    if (!reserve) {
      picture?.dispose();
      picture = next;
    } else {
      final old = picture;
      final mergeRecorder = ui.PictureRecorder();
      final mergeCanvas = Canvas(mergeRecorder);
      if (old != null) mergeCanvas.drawPicture(old);
      mergeCanvas.drawPicture(next);
      picture?.dispose();
      picture = mergeRecorder.endRecording();
      next.dispose();
    }
    recorder = ui.PictureRecorder();
    _recording = Canvas(recorder!);
    if (picture != null) {
      _recording!.drawPicture(picture!);
    }
    repaint.value++;
  }

  Future<ui.Image?> _toImage({double pixelRatio = 1}) async {
    final boundary = boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;
    return boundary.toImage(pixelRatio: pixelRatio);
  }

  @override
  Widget build(BuildContext context) {
    final w = UPUtils.getPx(widget.width);
    final h = UPUtils.getPx(widget.height);
    final bg = UPUtils.parseColor(widget.bgColor) ?? const Color(0xFFFFFFFF);
    Widget root = Listener(
      onPointerDown: (e) => widget.onTouchStart?.call(e.localPosition),
      onPointerMove: (e) => widget.onTouchMove?.call(e.localPosition),
      onPointerUp: (e) => widget.onTouchEnd?.call(e.localPosition),
      onPointerCancel: (e) => widget.onTouchEnd?.call(e.localPosition),
      child: RepaintBoundary(
        key: boundaryKey,
        child: SizedBox(
          width: w,
          height: h,
          child: ColoredBox(
            color: bg,
            child: ValueListenableBuilder<int>(
              valueListenable: repaint,
              builder: (_, __, ___) {
                return CustomPaint(
                  size: Size(w, h),
                  painter: _PicturePainter(
                    picture: picture,
                    onLayout: (size) => _ensure(size),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    return root;
  }
}

class _PicturePainter extends CustomPainter {
  _PicturePainter({required this.picture, required this.onLayout});
  final ui.Picture? picture;
  final ValueChanged<Size> onLayout;

  @override
  void paint(Canvas canvas, Size size) {
    onLayout(size);
    if (picture != null) canvas.drawPicture(picture!);
  }

  @override
  bool shouldRepaint(covariant _PicturePainter old) => old.picture != picture;
}
