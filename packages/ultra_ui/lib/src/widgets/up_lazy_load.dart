import 'package:flutter/widgets.dart';

import '../utils/up_utils.dart';
import 'up_image.dart';

/// Port of u-lazy-load (viewport-aware image load).
class UPLazyLoad extends StatefulWidget {
  const UPLazyLoad({
    super.key,
    this.index,
    this.image = '',
    this.imgMode = 'widthFix',
    this.loadingImg = '',
    this.errorImg = '',
    this.threshold = 100,
    this.duration = 500,
    this.effect = 'ease-in-out',
    this.isEffect = true,
    this.borderRadius = 0,
    this.height = '200',
    this.width,
    this.onClick,
    this.onLoad,
    this.onError,
    this.customStyle,
  });

  final dynamic index;
  final String image;
  final String imgMode;
  final String loadingImg;
  final String errorImg;
  final dynamic threshold;
  final dynamic duration;
  final String effect;

  /// Source retained effect enable flag.
  final bool isEffect;
  final dynamic borderRadius;
  final dynamic height;
  final dynamic width;
  final VoidCallback? onClick;
  final VoidCallback? onLoad;
  final VoidCallback? onError;
  final BoxDecoration? customStyle;

  /// Source `getThreshold` — rpx/px threshold with sign preserved.
  dynamic getThreshold([dynamic screenWidth]) {
    final raw = threshold;
    final sw = screenWidth is num ? screenWidth.toDouble() : null;
    if (raw is String) {
      final text = raw.trim();
      final hasUnit = RegExp(r'(px|rpx|upx)$').hasMatch(text);
      if (hasUnit) {
        // Explicit unit: convert via getPx (rpx/upx -> px, px stays px).
        final signed = RegExp(r'^-').hasMatch(text);
        final px = UPUtils.getPx(text.replaceFirst('-', ''), screenWidth: sw);
        return signed ? -px : px;
      }
      final n = double.tryParse(text) ?? 0.0;
      final thr = UPUtils.rpx2px(n.abs(), screenWidth: sw);
      return n < 0 ? -thr : thr;
    }
    final n = raw is num ? raw.toDouble() : double.tryParse('$raw') ?? 0.0;
    // Bare numbers follow source: treat as rpx.
    final thr = UPUtils.rpx2px(n.abs(), screenWidth: sw);
    return n < 0 ? -thr : thr;
  }

  /// Source computed: imgHeight.
  dynamic get imgHeight => UPUtils.addUnit(height);

  @override
  State<UPLazyLoad> createState() => UPLazyLoadState();
}

class UPLazyLoadState extends State<UPLazyLoad> {
  bool _visible = false;
  int _retries = 0;

  bool get isVisible => _visible;

  /// Source data.
  bool get isShow => _visible;
  bool isError = false;
  String loadStatus = '';
  dynamic elIndex;
  int time = 0;

  /// Source `init` alias of [recheck]/loadNow.
  void init() => recheck();

  /// Source image click helper.
  void clickImg() => widget.onClick?.call();

  /// Source `imgLoaded` — mark successful image load.
  void imgLoaded([dynamic _]) {
    isError = false;
    loadStatus = 'loaded';
    time = DateTime.now().millisecondsSinceEpoch;
    if (mounted) setState(() {});
  }

  /// Source `errorImgLoaded` — fallback error image finished.
  void errorImgLoaded([dynamic _]) {
    isError = true;
    loadStatus = 'error';
    time = DateTime.now().millisecondsSinceEpoch;
    if (mounted) setState(() {});
  }

  /// Source `loadError` — primary image failed.
  void loadError([dynamic _]) {
    isError = true;
    loadStatus = 'error';
    time = DateTime.now().millisecondsSinceEpoch;
    widget.onError?.call();
    if (mounted) setState(() {});
  }

  /// Source `disconnectObserver` — cancel pending viewport checks.
  void disconnectObserver() {
    _retries = 99;
  }

  void loadNow() {
    if (_visible) return;
    setState(() => _visible = true);
    widget.onLoad?.call();
  }

  void recheck() {
    _retries = 0;
    _check();
  }

  @override
  void initState() {
    elIndex = widget.index;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (!mounted || _visible) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      if (_retries++ < 8) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _check());
      } else {
        setState(() => _visible = true);
      }
      return;
    }
    final pos = box.localToGlobal(Offset.zero);
    final size = box.size;
    final screen = MediaQuery.sizeOf(context);
    final thr = UPUtils.getPx(widget.threshold);
    final inView = pos.dy < screen.height + thr && pos.dy + size.height > -thr;
    if (inView || _retries >= 8) {
      setState(() => _visible = true);
      widget.onLoad?.call();
    } else {
      _retries++;
      if (_retries < 12) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _check());
      } else {
        setState(() => _visible = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final w =
        widget.width == null ? double.infinity : UPUtils.getPx(widget.width);
    final h = UPUtils.getPx(widget.height);
    final r = UPUtils.getPx(widget.borderRadius);
    final ms = int.tryParse('${widget.duration}') ?? 500;

    Widget root;
    if (!_visible) {
      root = Container(
        width: w.isFinite ? w : null,
        height: h,
        color: const Color(0xFFF3F4F6),
      );
    } else {
      root = GestureDetector(
        onTap: widget.onClick,
        child: AnimatedOpacity(
          opacity: 1,
          duration: Duration(milliseconds: ms),
          curve: Curves.easeInOut,
          child: UPImage(
            src: widget.image,
            width: w.isFinite ? w : 300,
            height: h,
            radius: r,
            mode: widget.imgMode == 'widthFix' ? 'widthFix' : widget.imgMode,
            showLoading: true,
            onClick: widget.onClick,
          ),
        ),
      );
    }
    return root;
  }
}
