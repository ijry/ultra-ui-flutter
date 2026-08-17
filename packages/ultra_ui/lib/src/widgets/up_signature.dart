import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';
import 'up_slider.dart';

/// Port of u-signature (canvas pen + toolbar).
class UPSignature extends StatefulWidget {
  const UPSignature({
    super.key,
    this.width = 300,
    this.height = 200,
    this.bgColor = '#ffffff',
    this.color = '#000000',
    this.thickness = 3,
    this.showToolbar = true,
    this.onChange,
    this.onClear,
    this.onExport,
    this.onConfirm,
    this.onError,
    this.controller,
    this.customStyle,
  });

  final dynamic width;
  final dynamic height;
  final dynamic bgColor;
  final dynamic color;
  final dynamic thickness;
  final bool showToolbar;
  final ValueChanged<bool>? onChange;
  final VoidCallback? onClear;
  final ValueChanged<Map>? onExport;

  /// Source emit alias.
  final ValueChanged<Map>? onConfirm;

  /// Source emit.
  final ValueChanged<dynamic>? onError;
  final UPSignatureController? controller;

  final BoxDecoration? customStyle;

  /// Source computed: resolvedBgColor.
  dynamic get resolvedBgColor {
    final c = '$bgColor';
    return c == '#ffffff' ? '#ffffff' : bgColor;
  }

  /// Source computed: iconDefaultColor.
  dynamic get iconDefaultColor => '#999999';

  /// Source computed: iconDisabledColor.
  dynamic get iconDisabledColor => '#c8c9cc';

  @override
  State<UPSignature> createState() => UPSignatureState();
}

class UPSignatureController {
  UPSignatureState? _state;
  void clear() => _state?.clear();
  void clearCanvas() => _state?.clearCanvas();
  void undo() => _state?.undo();
  bool get isEmpty => _state?.isEmpty ?? true;
  Future<ui.Image?> toImage() => _state?.toImage() ?? Future.value(null);
  Future<Map> export({double pixelRatio = 2}) =>
      _state?.export(pixelRatio: pixelRatio) ??
      Future.value(
          {'errMsg': 'not ready', 'tempFilePath': '', 'isEmpty': true});
}

class _Stroke {
  _Stroke(this.color, this.width);
  final Color color;
  final double width;
  final points = <Offset>[];
}

class UPSignatureState extends State<UPSignature> {
  /// Source method: exportSignature.
  Future<dynamic> exportSignature({double pixelRatio = 2}) async {
    return export(pixelRatio: pixelRatio);
  }

  final paths = <_Stroke>[];
  _Stroke? current;
  late Color strokeColor;
  late double strokeWidth;
  final boundaryKey = GlobalKey();
  bool showBrushSettings = false;
  bool showColorSettings = false;

  /// Source data.
  String canvasId = 'up-signature';
  dynamic canvasInstance;
  double canvasWidth = 0;
  double canvasHeight = 0;
  bool isDrawing = false;
  dynamic lastPoint;
  dynamic currentPath;
  List pathStack = [];
  dynamic get lineColor => strokeColor;
  double get lineWidth => strokeWidth;

  static const presetColors = [
    Color(0xFF000000),
    Color(0xFFFF0000),
    Color(0xFF00FF00),
    Color(0xFF0000FF),
    Color(0xFFFFFF00),
    Color(0xFF00FFFF),
    Color(0xFFFF00FF),
    Color(0xFFFFFFFF),
  ];

  bool get isEmpty => paths.isEmpty;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    strokeColor = UPUtils.parseColor(widget.color) ?? const Color(0xFF000000);
    strokeWidth = UPUtils.getPx(widget.thickness);
    if (strokeWidth <= 0) strokeWidth = 3;
  }

  @override
  void didUpdateWidget(covariant UPSignature oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller?._state = this;
    if (oldWidget.color != widget.color) {
      strokeColor = UPUtils.parseColor(widget.color) ?? const Color(0xFF000000);
    }
    if (oldWidget.thickness != widget.thickness) {
      final n = UPUtils.getPx(widget.thickness);
      strokeWidth = n > 0 ? n : 3;
    }
  }

  @override
  void dispose() {
    if (widget.controller?._state == this) widget.controller?._state = null;
    super.dispose();
  }

  /// Source `resolveStrokeColor`.
  Color resolveStrokeColor([dynamic color]) {
    if (color is Color) return color;
    return UPUtils.parseColor(color) ?? strokeColor;
  }

  /// Source `getCanvasInstance`.
  dynamic getCanvasInstance([dynamic _]) => this;

  /// Source `getCanvasPoint`.
  Offset getCanvasPoint(dynamic x, [dynamic y]) {
    if (x is Offset) return x;
    return Offset(
      (num.tryParse('$x') ?? 0).toDouble(),
      (num.tryParse('$y') ?? 0).toDouble(),
    );
  }

  /// Source alias.
  void clearCanvas() => clear();

  /// Source touch aliases.
  void touchStart(Offset p) => start(p);
  void touchMove(Offset p) => move(p);
  void touchEnd() => end();

  /// Source `selectColor`.
  void selectColor(dynamic color) {
    final c = color is Color ? color : UPUtils.parseColor(color);
    if (c != null) setBrushColor(c);
  }

  /// Source `redraw`.
  void redraw() {
    if (mounted) setState(() {});
  }

  void clear() {
    setState(() {
      paths.clear();
      current = null;
    });
    widget.onClear?.call();
    widget.onChange?.call(true);
  }

  void undo() {
    if (paths.isEmpty) return;
    setState(() => paths.removeLast());
    widget.onChange?.call(paths.isEmpty);
  }

  void setBrushWidth(double width) {
    setState(() => strokeWidth = width.clamp(1, 20));
  }

  void setBrushColor(Color color) {
    setState(() => strokeColor = color);
  }

  void toggleBrushSettings() {
    setState(() {
      showBrushSettings = !showBrushSettings;
      if (showBrushSettings) showColorSettings = false;
    });
  }

  void toggleColorSettings() {
    setState(() {
      showColorSettings = !showColorSettings;
      if (showColorSettings) showBrushSettings = false;
    });
  }

  Future<ui.Image?> toImage({double pixelRatio = 2}) async {
    final boundary = boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;
    return boundary.toImage(pixelRatio: pixelRatio);
  }

  Future<Map> export({double pixelRatio = 2}) async {
    ui.Image? image;
    if (!isEmpty) {
      try {
        image = await toImage(pixelRatio: pixelRatio);
      } catch (_) {
        image = null;
      }
    }
    final payload = {
      'isEmpty': isEmpty,
      'width': UPUtils.getPx(widget.width),
      'height': UPUtils.getPx(widget.height),
      'tempFilePath': image == null
          ? ''
          : 'memory://signature_${DateTime.now().millisecondsSinceEpoch}.png',
      if (image != null) 'image': image,
      'errMsg': isEmpty ? 'empty' : (image == null ? 'capture failed' : 'ok'),
    };
    widget.onExport?.call(payload);
    widget.onConfirm?.call(payload);
    return payload;
  }

  void start(Offset p) {
    isDrawing = true;
    lastPoint = p;
    current = _Stroke(strokeColor, strokeWidth)..points.add(p);
    setState(() => paths.add(current!));
  }

  void move(Offset p) {
    if (current == null) return;
    setState(() => current!.points.add(p));
  }

  void end() {
    isDrawing = false;
    current = null;
    widget.onChange?.call(paths.isEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final w = UPUtils.getPx(widget.width);
    final h = UPUtils.getPx(widget.height);
    final bg = UPUtils.parseColor(widget.bgColor) ?? tokens.cardBgColor;
    final iconColor = tokens.contentColor;
    final disabled = tokens.tipsColor;

    Widget root = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RepaintBoundary(
          key: boundaryKey,
          child: Container(
            width: w,
            height: h,
            color: bg,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (e) => start(e.localPosition),
              onPointerMove: (e) {
                if (e.down) move(e.localPosition);
              },
              onPointerUp: (_) => end(),
              onPointerCancel: (_) => end(),
              child: CustomPaint(
                key: const ValueKey('sig-canvas'),
                size: Size(w, h),
                painter: _SignaturePainter(paths),
              ),
            ),
          ),
        ),
        if (widget.showToolbar) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              _tool(
                'arrow-leftward',
                onTap: undo,
                color: isEmpty ? disabled : iconColor,
                keyName: 'sig-undo',
              ),
              _tool(
                'trash',
                onTap: clear,
                color: iconColor,
                keyName: 'sig-clear',
              ),
              _tool(
                'edit-pen',
                onTap: toggleBrushSettings,
                color: iconColor,
                keyName: 'sig-brush',
              ),
              _tool(
                'grid',
                onTap: toggleColorSettings,
                color: iconColor,
                keyName: 'sig-color',
              ),
              _tool(
                'checkmark',
                onTap: () {
                  export();
                },
                color: isEmpty ? disabled : iconColor,
                keyName: 'sig-export',
              ),
            ],
          ),
          if (showBrushSettings)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Text('笔触:', style: TextStyle(color: tokens.contentColor)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: UPSlider(
                      value: strokeWidth,
                      min: 1,
                      max: 20,
                      step: 1,
                      onChange: (v) => setBrushWidth(v.toDouble()),
                    ),
                  ),
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${strokeWidth.round()}',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: tokens.mainColor),
                    ),
                  ),
                ],
              ),
            ),
          if (showColorSettings)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Text('颜色:', style: TextStyle(color: tokens.contentColor)),
                  const SizedBox(width: 8),
                  for (var i = 0; i < presetColors.length; i++)
                    GestureDetector(
                      key: ValueKey('sig-color-$i'),
                      onTap: () => setBrushColor(presetColors[i]),
                      child: Container(
                        width: 22,
                        height: 22,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: presetColors[i],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: strokeColor == presetColors[i]
                                ? tokens.primary
                                : const Color(0xFFDADBDE),
                            width: strokeColor == presetColors[i] ? 2 : 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ],
    );
    return root;
  }

  Widget _tool(
    String icon, {
    required VoidCallback onTap,
    required Color color,
    required String keyName,
  }) {
    final red = (color.r * 255).round().clamp(0, 255).toInt();
    final green = (color.g * 255).round().clamp(0, 255).toInt();
    final blue = (color.b * 255).round().clamp(0, 255).toInt();
    final hex =
        '#${red.toRadixString(16).padLeft(2, '0')}${green.toRadixString(16).padLeft(2, '0')}${blue.toRadixString(16).padLeft(2, '0')}';
    return GestureDetector(
      key: ValueKey(keyName),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: UPIcon(name: icon, size: 22, color: hex),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.paths);
  final List<_Stroke> paths;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in paths) {
      if (stroke.points.isEmpty) continue;
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      if (stroke.points.length == 1) {
        canvas.drawCircle(
          stroke.points.first,
          stroke.width / 2,
          paint..style = PaintingStyle.fill,
        );
        continue;
      }
      final path = Path()
        ..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (var i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
