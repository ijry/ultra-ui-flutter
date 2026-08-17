import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_button.dart';
import 'up_icon.dart';
import 'up_image.dart';

final Expando<Map<String, dynamic>> _upCropperState =
    Expando<Map<String, dynamic>>('upCropperState');

/// Port of u-cropper / up-cropper.
///
/// Gestures / area / confirm payload stay API-compatible.
/// Optional [imageProvider] / [imageLoader] enables real pixel export via
/// [toImage] without adding package image-codec deps.
class UPCropper extends StatefulWidget {
  const UPCropper({
    super.key,
    this.imageSrc = '',
    this.imgSrc = '',
    this.imgStyle,
    this.selStyle,
    this.minScale = 0.3,
    this.maxScale = 4,
    this.canScale = true,
    this.canRotate = true,
    this.canChangeSize = false,
    this.lockWidth = '',
    this.lockHeight = '',
    this.stretch = '',
    this.lock = '',
    this.index,
    this.areaWidth = '300rpx',
    this.areaHeight = '300rpx',
    this.exportWidth = '260rpx',
    this.exportHeight = '260rpx',
    this.fillColor = 'transparent',
    this.quality = 0.9,
    this.noTab = true,
    this.inner = false,
    this.onConfirm,
    this.onCancel,
    this.onAvtinit,

    /// Host-provided image for real export. Prefer this over network decode.
    this.imageProvider,

    /// Async loader by src when [imageProvider] is null.
    this.imageLoader,
    this.customStyle,
  });

  final String imageSrc;

  /// Source alias of [imageSrc].
  final String imgSrc;
  final dynamic imgStyle;
  final dynamic selStyle;
  final dynamic minScale;
  final dynamic maxScale;
  final bool canScale;
  final bool canRotate;
  final bool canChangeSize;
  final dynamic lockWidth;
  final dynamic lockHeight;
  final dynamic stretch;
  final dynamic lock;

  /// Source host index for multi-cropper flows.
  final dynamic index;
  final dynamic areaWidth;
  final dynamic areaHeight;
  final dynamic exportWidth;
  final dynamic exportHeight;
  final dynamic fillColor;
  final dynamic quality;
  final bool noTab;
  final bool inner;
  final ValueChanged<Map>? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onAvtinit;
  final ui.Image? imageProvider;
  final Future<ui.Image?> Function(String src)? imageLoader;

  final BoxDecoration? customStyle;

  /// Prefer non-empty [imgSrc] then [imageSrc].
  String get effectiveImageSrc => imgSrc.isNotEmpty ? imgSrc : imageSrc;

  /// Source data defaults (runtime filled after measure).
  Map<String, dynamic> get _state =>
      _upCropperState[this] ??= <String, dynamic>{
        'arHeight': '',
        'arWidth': '',
        'expHeight': '',
        'expWidth': '',
        'safeAreaInsetsBottom': 0.0,
      };
  dynamic get arHeight => _state['arHeight'] ?? '';
  dynamic get arWidth => _state['arWidth'] ?? '';
  dynamic get btnDsp => 'flex';
  dynamic get btnWidth => '19%';
  dynamic get expHeight => _state['expHeight'] ?? '';
  dynamic get expWidth => _state['expWidth'] ?? '';
  dynamic get letChangeSize => canChangeSize;
  dynamic get safeAreaInsetsBottom =>
      (_state['safeAreaInsetsBottom'] as num?)?.toDouble() ?? 0;

  @override
  State<UPCropper> createState() => UPCropperState();
}

class UPCropperState extends State<UPCropper> {
  dynamic lastResult;
  bool lastSuccess = false;
  bool canvasReady = false;
  void _syncMeasuredLayout(BuildContext context) {
    final bottom = MediaQuery.maybeOf(context)?.padding.bottom ?? 0;
    widget._state['safeAreaInsetsBottom'] = bottom;
    widget._state['arWidth'] = '${widget.areaWidth}';
    widget._state['arHeight'] = '${widget.areaHeight}';
    widget._state['expWidth'] = '${widget.exportWidth}';
    widget._state['expHeight'] = '${widget.exportHeight}';
  }

  /// Source host helper.
  Future<void> setTimeout([dynamic cb, int ms = 0]) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
    if (cb is Function) cb();
  }

  /// Source host helper.
  dynamic resolve([dynamic v]) => v;

  /// Source host helper.
  dynamic reject([dynamic e]) => e;

  String get _src => widget.effectiveImageSrc;
  double scale = 1;
  double angle = 0;
  Offset offset = Offset.zero;
  double areaW = 200;
  double areaH = 200;
  Offset? _lastFocal;
  double _startScale = 1;
  final boundaryKey = GlobalKey();
  ui.Image? _loadedImage;

  /// Source data used by canvas/oper layout.
  String cvsStyleHeight = '0px';
  String styleDisplay = 'none';
  String styleTop = '-10000px';
  String prvTop = '0px';
  bool showOper = false;
  final String instanceId = 'cropper';

  /// Source window resize helper.
  void windowResize([dynamic _]) {
    cvsStyleHeight = '${areaH.round()}px';
  }

  double get minScale => (num.tryParse('${widget.minScale}') ?? 0.3).toDouble();
  double get maxScale => (num.tryParse('${widget.maxScale}') ?? 4).toDouble();

  double get exportW {
    final v = UPUtils.getPx(widget.exportWidth);
    return v <= 0 ? areaW : v;
  }

  double get exportH {
    final v = UPUtils.getPx(widget.exportHeight);
    return v <= 0 ? areaH : v;
  }

  @override
  void initState() {
    super.initState();
    areaW = UPUtils.getPx(widget.areaWidth);
    areaH = UPUtils.getPx(widget.areaHeight);
    if (areaW <= 0) areaW = 200;
    if (areaH <= 0) areaH = 200;
    _loadedImage = widget.imageProvider;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onAvtinit?.call();
      _ensureImage();
    });
  }

  @override
  void didUpdateWidget(covariant UPCropper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.areaWidth != widget.areaWidth ||
        oldWidget.areaHeight != widget.areaHeight) {
      areaW = UPUtils.getPx(widget.areaWidth);
      areaH = UPUtils.getPx(widget.areaHeight);
      if (areaW <= 0) areaW = 200;
      if (areaH <= 0) areaH = 200;
    }
    if (oldWidget.imageProvider != widget.imageProvider) {
      _loadedImage = widget.imageProvider;
    }
    if (oldWidget.effectiveImageSrc != widget.effectiveImageSrc) {
      _ensureImage();
    }
  }

  Future<void> _ensureImage() async {
    if (widget.imageProvider != null) {
      _loadedImage = widget.imageProvider;
      return;
    }
    if (widget.imageLoader != null && _src.isNotEmpty) {
      final img = await widget.imageLoader!(_src);
      if (!mounted) return;
      setState(() => _loadedImage = img);
    }
  }

  void rotate([double delta = 90]) => _rotate(delta);

  void _rotate([double delta = 90]) {
    if (!widget.canRotate) return;
    setState(() => angle = (angle + delta) % 360);
  }

  /// Public helpers for tests / host.
  void setScale(double v) =>
      setState(() => scale = v.clamp(minScale, maxScale));
  void setAngle(double v) => setState(() => angle = v % 360);
  void setOffset(Offset v) => setState(() => offset = v);

  /// Source `select` / choose image entry.
  ///
  /// Flutter host should pass [path] or [provider]; without platform picker
  /// this remains a no-op when both are null.
  Future<void> select({String? path, ImageProvider? provider}) async {
    if (path == null && provider == null) return;
    // Host-driven image swap via public setters already available on widget props.
    // Keep method for source API compatibility / future platform pickers.
    if (provider != null) {
      setState(() {
        // no local imageProvider override field; re-ensure via loader path
      });
    }
    await _ensureImage();
  }

  /// Source `chooseImage` alias.
  Future<void> chooseImage({String? path, ImageProvider? provider}) =>
      select(path: path, provider: provider);

  Map _confirmPayload({ui.Image? image, String? tempPath}) {
    return {
      'avatar': tempPath ?? _src,
      'path': tempPath ?? _src,
      'imageSrc': _src,
      'scale': scale,
      'angle': angle,
      'rotate': angle,
      'offsetX': offset.dx,
      'offsetY': offset.dy,
      'areaWidth': areaW,
      'areaHeight': areaH,
      'exportWidth': exportW,
      'exportHeight': exportH,
      'quality': num.tryParse('${widget.quality}') ?? 0.9,
      'index': widget.index,
      if (image != null) 'image': image,
      if (tempPath != null) 'tempFilePath': tempPath,
      'data': {
        'scale': scale,
        'angle': angle,
        'offset': {'x': offset.dx, 'y': offset.dy},
        'exportWidth': exportW,
        'exportHeight': exportH,
      },
    };
  }

  /// Capture crop area via RepaintBoundary (UI-level snapshot).
  Future<ui.Image?> captureBoundary({double pixelRatio = 1}) async {
    final boundary = boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;
    return boundary.toImage(pixelRatio: pixelRatio);
  }

  /// Pixel-accurate export using provided/loaded [ui.Image].
  ///
  /// Draws fill + transformed image into an offscreen canvas of export size.
  Future<ui.Image?> exportImage() async {
    final src = _loadedImage ?? widget.imageProvider;
    final expW = exportW.round().clamp(1, 4096);
    final expH = exportH.round().clamp(1, 4096);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final fill = UPUtils.parseColor(widget.fillColor);
    if (fill != null && fill.alpha > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, expW.toDouble(), expH.toDouble()),
        Paint()..color = fill,
      );
    } else {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, expW.toDouble(), expH.toDouble()),
        Paint()..color = const Color(0x00000000),
      );
    }

    if (src != null) {
      // Map crop-area transform into export coordinates.
      final sx = expW / areaW;
      final sy = expH / areaH;
      canvas.save();
      canvas.scale(sx, sy);
      canvas.translate(areaW / 2 + offset.dx, areaH / 2 + offset.dy);
      canvas.rotate(angle * math.pi / 180);
      canvas.scale(scale, scale);
      final srcRect = Rect.fromLTWH(
        0,
        0,
        src.width.toDouble(),
        src.height.toDouble(),
      );
      // Cover-fit into area before user transform (aspectFill).
      final cover = _coverRect(Size(areaW, areaH), srcRect.size);
      canvas.drawImageRect(
        src,
        srcRect,
        Rect.fromCenter(
          center: Offset.zero,
          width: cover.width,
          height: cover.height,
        ),
        Paint()..filterQuality = FilterQuality.high,
      );
      canvas.restore();
    } else {
      // Fallback: boundary capture then scale.
      final snap = await captureBoundary(pixelRatio: 1);
      if (snap != null) {
        canvas.drawImageRect(
          snap,
          Rect.fromLTWH(0, 0, snap.width.toDouble(), snap.height.toDouble()),
          Rect.fromLTWH(0, 0, expW.toDouble(), expH.toDouble()),
          Paint()..filterQuality = FilterQuality.high,
        );
      }
    }

    final picture = recorder.endRecording();
    return picture.toImage(expW, expH);
  }

  Size _coverRect(Size box, Size image) {
    if (image.width <= 0 || image.height <= 0) return box;
    final scale = math.max(box.width / image.width, box.height / image.height);
    return Size(image.width * scale, image.height * scale);
  }

  Future<void> confirm() async {
    ui.Image? image;
    try {
      image = await exportImage();
    } catch (_) {
      image = null;
    }
    final tempPath = image != null
        ? 'memory://crop_${DateTime.now().millisecondsSinceEpoch}.png'
        : _src;
    widget.onConfirm?.call(_confirmPayload(image: image, tempPath: tempPath));
  }

  /// Source `close` / cancel alias.
  void close() {
    styleDisplay = 'none';
    styleTop = '-10000px';
    showOper = false;
    widget.onCancel?.call();
  }

  /// Source gesture/result helpers.
  void move([Offset? delta]) {
    if (delta != null) setOffset(offset + delta);
  }

  void end([dynamic _]) {
    // Gesture end: keep current transform; host may query offset/scale.
    if (mounted) setState(() {});
  }

  Future<Map> complete() async {
    try {
      await confirm();
      final payload = await preview();
      success(payload);
      return payload;
    } catch (e) {
      fail(e);
      rethrow;
    }
  }

  void success([dynamic payload]) {
    lastSuccess = true;
    lastResult = payload ?? true;
  }

  void fail([dynamic payload]) {
    lastSuccess = false;
    lastResult = payload ?? false;
  }

  double btop([dynamic _]) => offset.dy;
  bool imageResized = false;
  dynamic lastImageResize;
  Future<void> imageResize([dynamic payload]) async {
    lastImageResize = payload ?? true;
    imageResized = true;
    await _ensureImage();
    if (mounted) setState(() {});
  }

  String get avatarSrc => _src;

  /// Source `start` — reset transform + ensure image loaded.
  /// Source `start` — reset transform + ensure image loaded.
  Future<void> start() async {
    setState(() {
      scale = 1;
      angle = 0;
      offset = Offset.zero;
      styleDisplay = 'flex';
      styleTop = '0';
      prvTop = '0px';
      cvsStyleHeight = '${areaH.round()}px';
      showOper = true;
    });
    await _ensureImage();
  }

  /// Source `preview` — return current confirm-like payload without emit.
  Future<Map> preview() async {
    ui.Image? image;
    try {
      image = await exportImage();
    } catch (_) {
      image = null;
    }
    final tempPath = image != null
        ? 'memory://crop_preview_${DateTime.now().millisecondsSinceEpoch}.png'
        : _src;
    return _confirmPayload(image: image, tempPath: tempPath);
  }

  /// Source `getImgData` alias of [exportImage].
  Future<ui.Image?> getImgData() => exportImage();

  /// Source `hideImg`.
  /// Source canvas/draw helpers (Batch J + BH).
  void initCanvasRefs([dynamic _]) {
    canvasReady = true;
  }

  void drawInit([dynamic _]) {
    canvasReady = true;
    if (mounted) setState(() {});
  }

  Future<void> drawImage([dynamic _]) async {
    await _ensureImage();
    canvasReady = true;
    if (mounted) setState(() {});
  }

  void colorChange([dynamic color]) {
    // Host may pass fill color override; keep style field for parity.
    if (color != null && mounted) {
      setState(() {});
    }
  }

  Future<void> prvUpload([dynamic _]) async {
    await confirm();
  }

  void hideImg([dynamic _]) {
    styleDisplay = 'none';
    styleTop = '-10000px';
    showOper = false;
  }

  @override
  Widget build(BuildContext context) {
    _syncMeasuredLayout(context);
    final tokens = UPThemeTokens.of(context);
    final fill = UPUtils.parseColor(widget.fillColor) ?? Colors.transparent;
    final showTab = !widget.noTab || widget.inner;

    Widget root = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: areaW + (widget.canChangeSize ? 24 : 0),
          height: areaH + (widget.canChangeSize ? 24 : 0),
          color: fill == Colors.transparent ? const Color(0xFF111111) : fill,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Dim mask around crop area.
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _CropMaskPainter(
                      area: Size(areaW, areaH),
                      color: const Color(0x99000000),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onScaleStart: (details) {
                  if (!widget.canScale && details.pointerCount > 1) return;
                  _lastFocal = details.focalPoint;
                  _startScale = scale;
                },
                onScaleUpdate: (details) {
                  setState(() {
                    if (widget.canScale && details.pointerCount > 1) {
                      scale = (_startScale * details.scale)
                          .clamp(minScale, maxScale);
                    }
                    if (_lastFocal != null) {
                      final delta = details.focalPoint - _lastFocal!;
                      offset += delta;
                      _lastFocal = details.focalPoint;
                    }
                  });
                },
                onScaleEnd: (_) => _lastFocal = null,
                child: RepaintBoundary(
                  key: boundaryKey,
                  child: ClipRect(
                    child: SizedBox(
                      width: areaW,
                      height: areaH,
                      child: Transform.translate(
                        offset: offset,
                        child: Transform.rotate(
                          angle: angle * math.pi / 180,
                          child: Transform.scale(
                            scale: scale,
                            child: _src.isEmpty && _loadedImage == null
                                ? Container(
                                    color:
                                        tokens.bgColor.withValues(alpha: 0.2),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      '裁剪区域',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                : (_loadedImage != null
                                    ? RawImage(
                                        image: _loadedImage,
                                        width: areaW,
                                        height: areaH,
                                        fit: BoxFit.cover,
                                      )
                                    : UPImage(
                                        src: _src,
                                        width: areaW,
                                        height: areaH,
                                        mode: 'aspectFill',
                                      )),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                child: Container(
                  width: areaW,
                  height: areaH,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFFFF4D4F), width: 1),
                    color: Colors.transparent,
                  ),
                  child: Stack(
                    children: [
                      // corner marks
                      _corner(Alignment.topLeft),
                      _corner(Alignment.topRight),
                      _corner(Alignment.bottomLeft),
                      _corner(Alignment.bottomRight),
                    ],
                  ),
                ),
              ),
              if (widget.canChangeSize)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onPanUpdate: (d) {
                      setState(() {
                        areaW = (areaW + d.delta.dx).clamp(80, 400);
                        areaH = (areaH + d.delta.dy).clamp(80, 400);
                      });
                    },
                    child: Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      color: const Color(0x88FFFFFF),
                      child: const UPIcon(
                        name: 'arrow-downward',
                        size: 14,
                        color: Color(0xFF303133),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (widget.canScale)
          Slider(
            value: scale.clamp(minScale, maxScale),
            min: minScale,
            max: maxScale,
            onChanged: (v) => setState(() => scale = v),
          ),
        if (widget.canRotate)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => _rotate(-90),
                child: const Text('旋转-'),
              ),
              TextButton(
                onPressed: () => _rotate(90),
                child: const Text('旋转+'),
              ),
            ],
          ),
        if (showTab)
          Row(
            children: [
              Expanded(
                child: UPButton(
                  text: '取消',
                  type: 'info',
                  plain: true,
                  onClick: widget.onCancel,
                ),
              ),
              if (widget.canRotate) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: UPButton(
                    text: '旋转',
                    type: 'info',
                    plain: true,
                    onClick: () => _rotate(90),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Expanded(
                child: UPButton(
                  text: '完成',
                  type: 'primary',
                  onClick: () {
                    confirm();
                  },
                ),
              ),
            ],
          ),
      ],
    );
    return root;
  }

  Widget _corner(Alignment align) {
    return Align(
      alignment: align,
      child: SizedBox(
        width: 18,
        height: 18,
        child: CustomPaint(
          painter: _CornerPainter(align: align, color: const Color(0xFFFF4D4F)),
        ),
      ),
    );
  }
}

class _CropMaskPainter extends CustomPainter {
  _CropMaskPainter({required this.area, required this.color});
  final Size area;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Path()..addRect(Offset.zero & size);
    final inner = Path()
      ..addRect(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: area.width,
          height: area.height,
        ),
      );
    final path = Path.combine(PathOperation.difference, outer, inner);
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _CropMaskPainter old) =>
      old.area != area || old.color != color;
}

class _CornerPainter extends CustomPainter {
  _CornerPainter({required this.align, required this.color});
  final Alignment align;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    if (align == Alignment.topLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (align == Alignment.topRight) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (align == Alignment.bottomLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter old) =>
      old.align != align || old.color != color;
}
