import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_image.dart';
import 'up_qrcode.dart';

/// Port of u-poster / up-poster.
///
/// Renders painter JSON (`css` + `views`) with text / image / qrcode / rect.
/// Long-press or [UPPosterState.export] emits snapshot metadata (+ optional image).
class UPPoster extends StatefulWidget {
  const UPPoster({
    super.key,
    this.json = const {},
    this.onExport,
    this.onReady,
    this.customStyle,
  });

  final Map json;
  final ValueChanged<Map>? onExport;
  final VoidCallback? onReady;

  final BoxDecoration? customStyle;
  @override
  State<UPPoster> createState() => UPPosterState();
}

class UPPosterState extends State<UPPoster> {
  /// Source host helper.
  Future<void> setTimeout([dynamic cb, int ms = 0]) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
    if (cb is Function) cb();
  }

  /// Source host helper.
  dynamic resolve([dynamic v]) => v;

  /// Source host helper.
  dynamic reject([dynamic e]) => e;

  /// Source data.
  String canvasId = 'up-poster';
  double canvasWidth = 0;
  double canvasHeight = 0;
  bool showCanvas = true;
  Map qrCodeMap = const {};
  bool qrCodeShow = false;
  double qrCodeSize = 0;
  dynamic qrCodeValue;

  final boundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onReady?.call();
    });
  }

  double _px(dynamic v) {
    if (v == null) return 0;
    return UPUtils.getPx(v);
  }

  /// Source `getRpxRatio` — px per 1rpx.
  ///
  /// The source needs this because `uni.upx2px` picks a different base width
  /// per value on very wide screens, which made poster width and height use
  /// different scales and skewed the aspect ratio. [UPUtils.rpx2px] already
  /// applies one uniform ratio, so that hazard does not arise here; the method
  /// is exposed for call compatibility and to report the ratio in use.
  double getRpxRatio() => UPUtils.rpx2px(1000) / 1000;

  /// Source poster helpers (Batch J + BI).
  dynamic getPosterCanvas([dynamic _]) => this;
  final List lastDrawOps = <dynamic>[];
  dynamic lastDrawItem;
  Future<void> drawItem([dynamic item]) async {
    lastDrawItem = item;
    lastDrawOps.add({'op': 'drawItem', 'item': item});
  }

  Future<ui.Image?> capture({double pixelRatio = 1}) async {
    final boundary = boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;
    return boundary.toImage(pixelRatio: pixelRatio);
  }

  Future<Map> export({double pixelRatio = 1}) async {
    final css = (widget.json['css'] is Map)
        ? Map<String, dynamic>.from(widget.json['css'] as Map)
        : <String, dynamic>{};
    final width = _px(css['width'] ?? '300px');
    final height = _px(css['height'] ?? '400px');
    ui.Image? image;
    try {
      image = await capture(pixelRatio: pixelRatio);
    } catch (_) {
      image = null;
    }
    final path = image == null
        ? ''
        : 'memory://poster_${DateTime.now().millisecondsSinceEpoch}.png';
    final payload = {
      'width': width <= 0 ? 300.0 : width,
      'height': height <= 0 ? 400.0 : height,
      'json': widget.json,
      'tempFilePath': path,
      // source exportImage keys
      'path': path,
      if (image != null) 'image': image,
      'errMsg': image == null ? 'capture failed' : 'ok',
    };
    widget.onExport?.call(payload);
    return payload;
  }

  /// Source drawing helpers (layout-oriented).
  Map getTextStyle([Map? css]) {
    final s = css ?? const {};
    return {
      'fontSize': _px(s['fontSize'] ?? 14),
      'color': s['color'] ?? '#303133',
      'fontWeight': s['fontWeight'] ?? 'normal',
      'textAlign': s['textAlign'] ?? 'left',
      'lineHeight': s['lineHeight'],
      'maxLines': s['maxLines'] ?? s['lineClamp'],
    };
  }

  double convertRpxToPx([dynamic v]) => _px(v);

  Future<Map> generateQRCode([dynamic content, Map? options]) async {
    return {
      'content': content,
      'options': options ?? const {},
      'errMsg': 'ok',
    };
  }

  void drawRoundRect([dynamic payload]) {
    lastDrawOps.add({'op': 'drawRoundRect', 'payload': payload});
  }

  void clipRoundRect([dynamic payload]) {
    lastDrawOps.add({'op': 'clipRoundRect', 'payload': payload});
  }

  void drawTextWithLineClamp([dynamic payload]) {
    lastDrawOps.add({'op': 'drawTextWithLineClamp', 'payload': payload});
  }

  void drawGradientBackground([dynamic payload]) {
    lastDrawOps.add({'op': 'drawGradientBackground', 'payload': payload});
  }

  dynamic dataURLToBlob([dynamic dataUrl]) => dataUrl;

  /// Source `exportImage` alias.
  /// Source `exportImage` alias.
  Future<Map> exportImage({double pixelRatio = 1}) =>
      export(pixelRatio: pixelRatio);

  /// Generate / export alias used by some call sites.
  Future<Map> generate({double pixelRatio = 1}) =>
      export(pixelRatio: pixelRatio);

  /// Source-compatible name for capture.
  Future<ui.Image?> generateImage({double pixelRatio = 1}) =>
      capture(pixelRatio: pixelRatio);

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final css = (widget.json['css'] is Map)
        ? Map<String, dynamic>.from(widget.json['css'] as Map)
        : <String, dynamic>{};
    final views = (widget.json['views'] is List)
        ? widget.json['views'] as List
        : const [];
    final width = _px(css['width'] ?? '300px');
    final height = _px(css['height'] ?? '400px');
    final bg =
        UPUtils.parseColor(css['background'] ?? css['backgroundColor']) ??
            tokens.cardBgColor;
    final radius = _px(css['borderRadius'] ?? 0);
    final borderColor = UPUtils.parseColor(css['borderColor']);
    final borderWidth = _px(css['borderWidth'] ?? 0);

    Widget root = GestureDetector(
      onLongPress: () {
        export();
      },
      child: RepaintBoundary(
        key: boundaryKey,
        child: Container(
          width: width <= 0 ? 300 : width,
          height: height <= 0 ? 400 : height,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(radius),
            border: borderWidth > 0 && borderColor != null
                ? Border.all(color: borderColor, width: borderWidth)
                : null,
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              for (final raw in views) _view(tokens, raw),
            ],
          ),
        ),
      ),
    );
    return root;
  }

  Widget _view(UPThemeTokens tokens, dynamic raw) {
    if (raw is! Map) return const SizedBox.shrink();
    final item = Map<String, dynamic>.from(raw);
    final type = '${item['type'] ?? 'text'}'.toLowerCase();
    final style = (item['css'] is Map)
        ? Map<String, dynamic>.from(item['css'] as Map)
        : <String, dynamic>{};
    final left = _px(style['left'] ?? 0);
    final top = _px(style['top'] ?? 0);
    final w = style['width'] != null ? _px(style['width']) : null;
    final h = style['height'] != null ? _px(style['height']) : null;
    final rotate = (num.tryParse('${style['rotate'] ?? 0}') ?? 0).toDouble();

    Widget child;
    switch (type) {
      case 'image':
      case 'img':
        final src = '${item['url'] ?? item['src'] ?? item['path'] ?? ''}';
        child = UPImage(
          src: src,
          width: w ?? 80,
          height: h ?? 80,
          mode: '${style['mode'] ?? style['objectFit'] ?? 'aspectFill'}',
          radius: _px(style['borderRadius'] ?? 0),
        );
        break;
      case 'qrcode':
      case 'qr':
        final val = '${item['content'] ?? item['text'] ?? item['val'] ?? ''}';
        final size = w ?? h ?? 80;
        child = UPQrcode(
          val: val,
          size: size,
          showLoading: false,
          background: style['background'] ?? '#ffffff',
          foreground: style['color'] ?? style['foreground'] ?? '#000000',
          quietZone: style['quietZone'] ?? 0,
        );
        break;
      case 'rect':
      case 'view':
        child = Container(
          width: w ?? 40,
          height: h ?? 40,
          decoration: BoxDecoration(
            color: UPUtils.parseColor(
                    style['background'] ?? style['backgroundColor']) ??
                Colors.transparent,
            borderRadius:
                BorderRadius.circular(_px(style['borderRadius'] ?? 0)),
            border: Border.all(
              color: UPUtils.parseColor(style['borderColor']) ??
                  tokens.borderColor,
              width: _px(style['borderWidth'] ?? 0).clamp(0, 20),
            ),
          ),
        );
        break;
      case 'line':
        child = Container(
          width: w ?? 100,
          height: h ?? 1,
          color: UPUtils.parseColor(style['color'] ?? style['background']) ??
              tokens.borderColor,
        );
        break;
      default:
        final maxLines =
            int.tryParse('${style['maxLines'] ?? style['lineClamp'] ?? 0}');
        child = SizedBox(
          width: w,
          height: h,
          child: Text(
            '${item['text'] ?? item['content'] ?? ''}',
            maxLines: (maxLines == null || maxLines <= 0) ? null : maxLines,
            overflow: (maxLines != null && maxLines > 0)
                ? TextOverflow.ellipsis
                : TextOverflow.visible,
            textAlign: _textAlign('${style['textAlign'] ?? 'left'}'),
            style: TextStyle(
              color: UPUtils.parseColor(style['color']) ?? tokens.mainColor,
              fontSize: _px(style['fontSize'] ?? 14),
              height: (num.tryParse('${style['lineHeight'] ?? 1.2}') ?? 1.2)
                  .toDouble(),
              fontWeight: _fontWeight('${style['fontWeight'] ?? ''}'),
              fontStyle: '${style['fontStyle']}' == 'italic'
                  ? FontStyle.italic
                  : FontStyle.normal,
              decoration: '${style['textDecoration']}'.contains('line-through')
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
        );
    }

    if (rotate != 0) {
      child = Transform.rotate(
        angle: rotate * 3.141592653589793 / 180,
        child: child,
      );
    }

    return Positioned(left: left, top: top, child: child);
  }

  TextAlign _textAlign(String v) {
    switch (v) {
      case 'center':
        return TextAlign.center;
      case 'right':
      case 'end':
        return TextAlign.right;
      default:
        return TextAlign.left;
    }
  }

  FontWeight _fontWeight(String v) {
    final lower = v.toLowerCase();
    if (lower == 'bold' || lower == '700' || lower == '600') {
      return FontWeight.w700;
    }
    if (lower == '500') return FontWeight.w500;
    return FontWeight.normal;
  }
}
