import 'package:flutter/widgets.dart';

import '../config/up_config.dart';
import 'up_transition.dart';

/// 1:1 port of u-overlay.
///
/// uView overlays are `position: fixed`; their numeric `z-index` is global to
/// the page rather than constrained by the component's local layout stack.
class UPOverlay extends StatefulWidget {
  const UPOverlay({
    super.key,
    this.show = false,
    this.onUpdateShow,
    this.zIndex,
    this.duration = 300,
    this.opacity = 0.5,
    this.customStyle,
    this.onClick,
    this.child,
    this.rootOverlay = true,
  });

  final bool show;
  final ValueChanged<bool>? onUpdateShow;
  final dynamic zIndex;
  final dynamic duration;
  final dynamic opacity;
  final BoxDecoration? customStyle;
  final VoidCallback? onClick;
  final Widget? child;

  /// Set false when an owning component must keep its mask behind local content.
  final bool rootOverlay;

  /// Source `clickHandler`.
  void clickHandler() => onClick?.call();

  /// Source computed: overlayStyle.
  dynamic get overlayStyle {
    final op = double.tryParse('$opacity') ?? 0.5;
    final z = int.tryParse('${zIndex ?? ''}') ?? UPZIndexData().mask;
    return <String, dynamic>{
      'position': 'fixed',
      'top': 0,
      'left': 0,
      'right': 0,
      'zIndex': z,
      'bottom': 0,
      'background-color': 'rgba(0, 0, 0, $op)',
    };
  }

  @override
  State<UPOverlay> createState() => _UPOverlayState();
}

class _UPOverlayState extends State<UPOverlay> {
  static final Expando<_UPOverlayRegistry> _registries =
      Expando<_UPOverlayRegistry>('up-overlay-registries');

  _UPOverlayRegistry? _registry;
  bool _rootOverlaySyncScheduled = false;
  bool _usesRootOverlay = false;

  int get _zIndex =>
      int.tryParse('${widget.zIndex ?? ''}') ?? UPZIndexData().mask;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleRootOverlaySync();
  }

  @override
  void didUpdateWidget(covariant UPOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rootOverlay && !widget.rootOverlay) {
      _registry?.remove(this);
      _registry = null;
      _usesRootOverlay = false;
      return;
    }
    _scheduleRootOverlaySync();
    _registry?.markNeedsBuild();
  }

  @override
  void dispose() {
    _registry?.remove(this);
    super.dispose();
  }

  void _scheduleRootOverlaySync() {
    if (!widget.rootOverlay) return;
    if (_rootOverlaySyncScheduled) return;
    _rootOverlaySyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rootOverlaySyncScheduled = false;
      if (mounted) _syncRootOverlay();
    });
  }

  void _syncRootOverlay() {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (identical(_registry?.overlay, overlay)) {
      _registry?.markNeedsBuild();
      return;
    }

    _registry?.remove(this);
    _registry = null;
    if (overlay == null) {
      if (_usesRootOverlay && mounted) {
        setState(() => _usesRootOverlay = false);
      }
      return;
    }

    final registry = _registries[overlay] ??= _UPOverlayRegistry(overlay);
    registry.add(this);
    _registry = registry;
    if (!_usesRootOverlay && mounted) {
      setState(() => _usesRootOverlay = true);
    }
  }

  Widget _buildLayer() {
    final ms = int.tryParse('${widget.duration}') ?? 300;
    final op = double.tryParse('${widget.opacity}') ?? 0.5;
    final baseDecoration = BoxDecoration(
      color: Color.fromRGBO(0, 0, 0, op),
    );
    final customDecoration = widget.customStyle;
    final maskDecoration = customDecoration == null
        ? baseDecoration
        : BoxDecoration(
            color: customDecoration.gradient == null
                ? customDecoration.color ?? baseDecoration.color
                : null,
            image: customDecoration.image ?? baseDecoration.image,
            border: customDecoration.border ?? baseDecoration.border,
            borderRadius: customDecoration.shape == BoxShape.circle
                ? null
                : customDecoration.borderRadius ?? baseDecoration.borderRadius,
            boxShadow: customDecoration.boxShadow ?? baseDecoration.boxShadow,
            gradient: customDecoration.gradient ?? baseDecoration.gradient,
            backgroundBlendMode: customDecoration.backgroundBlendMode ??
                baseDecoration.backgroundBlendMode,
            shape: customDecoration.shape,
          );

    return UPTransition(
      show: widget.show,
      mode: 'fade',
      duration: ms,
      child: IgnorePointer(
        ignoring: !widget.show,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: widget.onClick,
                behavior: HitTestBehavior.opaque,
                child: DecoratedBox(
                  key: const ValueKey('up-overlay-mask'),
                  decoration: maskDecoration,
                ),
              ),
            ),
            if (widget.child != null) widget.child!,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Keep the local layer for the first frame, then move into the root
    // overlay after its entry was safely inserted at the end of that frame.
    if (!widget.rootOverlay || !_usesRootOverlay) {
      return _buildLayer();
    }
    return const SizedBox.shrink();
  }
}

class _UPOverlayRegistry {
  _UPOverlayRegistry(this.overlay);

  final OverlayState overlay;
  final List<_UPOverlayState> _layers = <_UPOverlayState>[];
  final Map<_UPOverlayState, int> _insertionOrder = <_UPOverlayState, int>{};
  OverlayEntry? _entry;
  bool _entryInserted = false;
  int _nextInsertionOrder = 0;
  bool _flushScheduled = false;

  void add(_UPOverlayState layer) {
    if (_layers.contains(layer)) return;
    _layers.add(layer);
    _insertionOrder[layer] = _nextInsertionOrder++;
    _flush();
  }

  void remove(_UPOverlayState layer) {
    if (!_layers.remove(layer)) return;
    _insertionOrder.remove(layer);
    _scheduleFlush();
  }

  void markNeedsBuild() => _scheduleFlush();

  void _scheduleFlush() {
    if (_flushScheduled) return;
    _flushScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _flushScheduled = false;
      _flush();
    });
  }

  void _flush() {
    if (_layers.isEmpty) {
      _entry?.remove();
      _entry = null;
      _entryInserted = false;
      return;
    }
    _entry ??= OverlayEntry(builder: _build);
    if (!_entryInserted) {
      overlay.insert(_entry!);
      _entryInserted = true;
    } else {
      _entry!.markNeedsBuild();
    }
  }

  Widget _build(BuildContext context) {
    final layers = List<_UPOverlayState>.of(_layers)
      ..sort((a, b) {
        final zIndexOrder = a._zIndex.compareTo(b._zIndex);
        if (zIndexOrder != 0) return zIndexOrder;
        return _insertionOrder[a]!.compareTo(_insertionOrder[b]!);
      });
    return Stack(
      fit: StackFit.expand,
      children: [
        for (final layer in layers)
          KeyedSubtree(
            key: ValueKey<_UPOverlayState>(layer),
            child: layer._buildLayer(),
          ),
      ],
    );
  }
}
