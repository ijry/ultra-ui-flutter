import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../config/up_config.dart';
import '../utils/up_utils.dart';

/// 1:1 port of u-sticky.
///
/// Pins content via [Overlay] once its top edge crosses
/// `offsetTop + customNavHeight`. Prefer passing [scrollController] when the
/// parent scroll view is known; otherwise the nearest [Scrollable] is used.
class UPSticky extends StatefulWidget {
  const UPSticky({
    super.key,
    this.offsetTop = 0,
    this.customNavHeight = 0,
    this.disabled = false,
    this.bgColor = 'transparent',
    this.zIndex = '',
    this.index = '',
    this.scrollController,
    this.onFixed,
    this.onUnfixed,
    required this.child,
    this.customStyle,
  });

  final dynamic offsetTop;
  final dynamic customNavHeight;
  final bool disabled;
  final dynamic bgColor;
  final dynamic zIndex;
  final dynamic index;
  final ScrollController? scrollController;
  final VoidCallback? onFixed;
  final VoidCallback? onUnfixed;
  final Widget child;
  final BoxDecoration? customStyle;

  /// Source computed: uZindex.
  dynamic get uZindex {
    if (zIndex != null && '$zIndex'.trim().isNotEmpty) {
      return int.tryParse('$zIndex') ?? zIndex;
    }
    return UPZIndexData().sticky;
  }

  /// Source computed: style.
  dynamic get style {
    final style = <String, dynamic>{
      'backgroundColor': bgColor,
    };
    if (!disabled) {
      // Flutter host uses sticky path by default for API map.
      style['position'] = 'sticky';
      style['zIndex'] = uZindex;
      style['top'] = UPUtils.addUnit(
        UPUtils.getPx(offsetTop) + UPUtils.getPx(customNavHeight),
      );
    } else {
      style['position'] = 'static';
    }
    return style;
  }

  /// Source computed: stickyContent.
  dynamic get stickyContent {
    // cssSticky path leaves content style empty on host map.
    return <String, dynamic>{};
  }

  @override
  State<UPSticky> createState() => UPStickyState();
}

class UPStickyState extends State<UPSticky> {
  /// Source host helper.
  dynamic resolve([dynamic v]) => v;

  /// Source `checkSupportCssSticky` — Flutter platforms that support sticky layout.
  /// Mirrors uview-plus: iOS always, Android modern, HarmonyOS, desktop/web.
  bool checkSupportCssSticky([dynamic _]) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        cssSticky = true;
        return true;
      case TargetPlatform.android:
        // Source treats Android > 8 as sticky-capable; Flutter targets modern Android.
        cssSticky = true;
        return true;
    }
  }

  /// Source data.
  bool cssSticky = false;
  String elId = 'up-sticky';

  static final Expando<_UPStickyRegistry> _registries =
      Expando<_UPStickyRegistry>('up-sticky-registries');

  _UPStickyRegistry? _registry;
  OverlayEntry? _entry;
  ScrollPosition? _position;
  VoidCallback? _controllerListener;
  bool _fixed = false;
  double _height = 0;
  double _width = 0;
  double _left = 0;
  bool _overlayRefreshScheduled = false;
  bool _overlayRearrangeScheduled = false;

  /// Whether the sticky content is currently pinned.
  bool get isFixed => _fixed;

  /// Current sticky top offset (`offsetTop + customNavHeight`).
  double get stickyTop => _stickyTop;

  /// Measured host height used as the unfixed placeholder.
  double get contentHeight => _height;

  double get _stickyTop =>
      UPUtils.getPx(widget.offsetTop) + UPUtils.getPx(widget.customNavHeight);

  int get _zIndex {
    final parsed = int.tryParse('${widget.zIndex}');
    return parsed ?? UPZIndexData().sticky;
  }

  Color get _bg =>
      UPUtils.parseColor(widget.bgColor, fallback: const Color(0x00000000)) ??
      const Color(0x00000000);

  BoxDecoration get _rootDecoration {
    final sourceDecoration = BoxDecoration(color: _bg);
    final callerDecoration = widget.customStyle;
    if (callerDecoration == null) return sourceDecoration;
    return BoxDecoration(
      // `style` is deep-merged after customStyle in the source, so bgColor
      // wins over a caller's plain color. A caller gradient remains visible
      // because Flutter cannot paint it alongside a BoxDecoration color.
      color: callerDecoration.gradient == null ? sourceDecoration.color : null,
      image: callerDecoration.image ?? sourceDecoration.image,
      border: callerDecoration.border ?? sourceDecoration.border,
      borderRadius: callerDecoration.shape == BoxShape.circle
          ? null
          : callerDecoration.borderRadius ?? sourceDecoration.borderRadius,
      boxShadow: callerDecoration.boxShadow ?? sourceDecoration.boxShadow,
      gradient: callerDecoration.gradient ?? sourceDecoration.gradient,
      backgroundBlendMode: callerDecoration.backgroundBlendMode ??
          sourceDecoration.backgroundBlendMode,
      shape: callerDecoration.shape,
    );
  }

  void _scheduleUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateFixed();
    });
  }

  void _scheduleOverlayRefresh({bool rearrange = false}) {
    _overlayRearrangeScheduled |= rearrange;
    if (_overlayRefreshScheduled) return;
    _overlayRefreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overlayRefreshScheduled = false;
      final shouldRearrange = _overlayRearrangeScheduled;
      _overlayRearrangeScheduled = false;
      if (!mounted || !_fixed) return;
      _entry?.markNeedsBuild();
      if (shouldRearrange) _registry?.rearrange();
    });
  }

  void _detachScroll() {
    _position?.removeListener(_onScroll);
    _position = null;
    final controller = widget.scrollController;
    if (_controllerListener != null && controller != null) {
      controller.removeListener(_controllerListener!);
    }
    _controllerListener = null;
  }

  void _attachScroll() {
    final controller = widget.scrollController;
    if (controller != null) {
      _controllerListener ??= _onScroll;
      // Avoid duplicate listener registration.
      controller.removeListener(_controllerListener!);
      controller.addListener(_controllerListener!);
      if (controller.hasClients) {
        final pos = controller.position;
        if (!identical(pos, _position)) {
          _position?.removeListener(_onScroll);
          _position = pos;
          _position?.addListener(_onScroll);
        }
      }
      return;
    }

    final scrollable = Scrollable.maybeOf(context);
    final next = scrollable?.position;
    if (identical(next, _position)) return;
    _position?.removeListener(_onScroll);
    _position = next;
    _position?.addListener(_onScroll);
  }

  void _onScroll() => _scheduleUpdate();

  /// Source sticky helpers.
  double getStickyTop() => stickyTop;
  void initObserveContent() => init();
  void observeContent() => refresh();
  void disconnectObserver([dynamic _]) {
    _position?.removeListener(_onScroll);
    _position = null;
  }

  /// Source host helper — computedStyle probe not available; use platform result.
  Future<bool> checkComputedStyle([dynamic _]) async => checkSupportCssSticky();

  /// Source host helper — H5 sniff; Flutter desktop/web treated as supported.
  bool checkCssStickyForH5([dynamic _]) => checkSupportCssSticky();

  /// Source `init` equivalent: re-measure and re-evaluate fixed state.
  void init() => _scheduleUpdate();

  /// Re-check sticky state after external layout changes.
  void refresh() => _scheduleUpdate();

  /// Source `setFixed(top)`, with bool support retained for Flutter callers.
  ///
  /// A numeric value is interpreted as the observed content top; the item pins
  /// when that top is at or above [stickyTop]. When omitted, geometry is
  /// re-evaluated from the current host layout.
  void setFixed([dynamic value]) {
    if (value == null) {
      _updateFixed();
      return;
    }
    dynamic fixed = value;
    if (value is Map) {
      final detail = value['detail'];
      fixed = value['top'] ?? (detail is Map ? detail['top'] : null);
    }
    if (fixed is bool) {
      if (widget.disabled && fixed) return;
      _setFixed(fixed);
      return;
    }
    final top = double.tryParse('$fixed');
    if (top == null) return;
    _setFixed(!widget.disabled && top <= stickyTop);
  }

  void _syncOverlay() {
    if (!_fixed) {
      _removeOverlay();
      return;
    }
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (identical(_registry?.overlay, overlay)) {
      _entry?.markNeedsBuild();
      _registry?.rearrange();
      return;
    }
    _registry?.remove(this);
    _registry = null;
    _entry?.remove();
    _entry = null;
    if (overlay == null) return;
    final registry = _registries[overlay] ??= _UPStickyRegistry(overlay);
    _entry = OverlayEntry(builder: _buildOverlay);
    overlay.insert(_entry!);
    registry.add(this);
    _registry = registry;
  }

  void _removeOverlay() {
    _registry?.remove(this);
    _registry = null;
    _entry?.remove();
    _entry = null;
  }

  Widget _buildOverlay(BuildContext _) {
    return Stack(
      children: [
        Positioned(
          top: _stickyTop,
          left: _left,
          width: _width > 0 ? _width : null,
          child: ColoredBox(
            color: _bg,
            child: widget.child,
          ),
        ),
        if (_zIndex < 0) const SizedBox.shrink(),
      ],
    );
  }

  void _setFixed(bool value) {
    if (value == _fixed) return;
    setState(() => _fixed = value);
    if (value) {
      widget.onFixed?.call();
    } else {
      widget.onUnfixed?.call();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncOverlay();
    });
  }

  void _updateFixed() {
    if (!mounted) return;
    _attachScroll();

    if (widget.disabled) {
      if (_fixed) _setFixed(false);
      return;
    }

    final hostBox = context.findRenderObject() as RenderBox?;
    if (hostBox == null || !hostBox.hasSize) return;
    final hostTop = hostBox.localToGlobal(Offset.zero).dy;
    final hostOrigin = hostBox.localToGlobal(Offset.zero);
    final hostSize = hostBox.size;

    if (!_fixed) {
      if (hostSize.height > 0) {
        _height = hostSize.height;
        _width = hostSize.width;
        _left = hostOrigin.dx;
      }
      if (hostTop <= _stickyTop + 0.5) {
        _setFixed(true);
      }
      return;
    }

    // Keep geometry in sync while fixed.
    if ((hostOrigin.dx - _left).abs() > 0.5 ||
        (hostSize.width - _width).abs() > 0.5) {
      _left = hostOrigin.dx;
      _width = hostSize.width;
      _entry?.markNeedsBuild();
    }
    if (hostTop > _stickyTop + 0.5) {
      _setFixed(false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachScroll();
    _scheduleUpdate();
  }

  @override
  void didUpdateWidget(covariant UPSticky oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      if (_controllerListener != null && oldWidget.scrollController != null) {
        oldWidget.scrollController!.removeListener(_controllerListener!);
      }
      _controllerListener = null;
      _attachScroll();
    }
    if (widget.disabled && _fixed) {
      _setFixed(false);
    } else {
      final positionChanged = oldWidget.offsetTop != widget.offsetTop ||
          oldWidget.customNavHeight != widget.customNavHeight ||
          oldWidget.bgColor != widget.bgColor;
      final zIndexChanged = oldWidget.zIndex != widget.zIndex;
      if (_fixed && (positionChanged || zIndexChanged)) {
        _scheduleOverlayRefresh(rearrange: zIndexChanged);
      }
      _scheduleUpdate();
    }
  }

  @override
  void dispose() {
    _detachScroll();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _attachScroll();
    return Container(
      decoration: _rootDecoration,
      child: SizedBox(
        height: _fixed && _height > 0 ? _height : null,
        width: double.infinity,
        child: _fixed ? const SizedBox.shrink() : widget.child,
      ),
    );
  }
}

class _UPStickyRegistry {
  _UPStickyRegistry(this.overlay);

  final OverlayState overlay;
  final List<UPStickyState> _layers = <UPStickyState>[];
  final Map<UPStickyState, int> _insertionOrder = <UPStickyState, int>{};
  int _nextInsertionOrder = 0;
  bool _flushScheduled = false;

  void add(UPStickyState layer) {
    if (_layers.contains(layer)) return;
    _layers.add(layer);
    _insertionOrder[layer] = _nextInsertionOrder++;
    _scheduleRearrange();
  }

  void remove(UPStickyState layer) {
    if (!_layers.remove(layer)) return;
    _insertionOrder.remove(layer);
    _scheduleRearrange();
  }

  void rearrange() => _scheduleRearrange();

  void _scheduleRearrange() {
    if (_flushScheduled) return;
    _flushScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _flushScheduled = false;
      final layers = List<UPStickyState>.of(_layers)
        ..sort((a, b) {
          final zIndexOrder = a._zIndex.compareTo(b._zIndex);
          if (zIndexOrder != 0) return zIndexOrder;
          return _insertionOrder[a]!.compareTo(_insertionOrder[b]!);
        });
      final entries = [
        for (final layer in layers)
          if (layer._entry != null) layer._entry!,
      ];
      if (entries.isNotEmpty) {
        // Keep the app route below the pinned entries while sorting the
        // sticky entries from low to high zIndex.
        overlay.rearrange(entries, below: entries.first);
      }
    });
  }
}
