import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';

class UPSwipeAction extends StatefulWidget {
  const UPSwipeAction({
    super.key,
    this.autoClose = true,
    this.opendItem = false,
    this.onOpendItemUpdate,
    required this.children,
    this.customStyle,
  });

  final bool autoClose;
  final bool opendItem;
  final ValueChanged<bool>? onOpendItemUpdate;
  final List<Widget> children;
  final BoxDecoration? customStyle;

  @override
  State<UPSwipeAction> createState() => UPSwipeActionState();
}

class UPSwipeActionState extends State<UPSwipeAction> {
  final Set<UPSwipeActionItemState> _items = {};

  void register(UPSwipeActionItemState item) => _items.add(item);
  void unregister(UPSwipeActionItemState item) => _items.remove(item);

  @override
  void didUpdateWidget(covariant UPSwipeAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.opendItem != widget.opendItem && widget.opendItem == false) {
      closeAll();
    }
  }

  void setOpened(UPSwipeActionItemState item) {
    widget.onOpendItemUpdate?.call(true);
  }

  void closeOther(UPSwipeActionItemState item) {
    if (!widget.autoClose) return;
    for (final other in _items) {
      if (other != item) other.close();
    }
  }

  void closeAll() {
    for (final item in _items) {
      item.close();
    }
  }

  /// Source `setOpendItem`.
  void setOpendItem([UPSwipeActionItemState? _]) {
    widget.onOpendItemUpdate?.call(true);
  }

  /// Source children count helper.
  int get itemCount => _items.length;

  @override
  Widget build(BuildContext context) {
    Widget root = _UPSwipeActionScope(
      state: this,
      child: Column(children: widget.children),
    );
    return root;
  }
}

class _UPSwipeActionScope extends InheritedWidget {
  const _UPSwipeActionScope({required this.state, required super.child});
  final UPSwipeActionState state;
  static UPSwipeActionState? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_UPSwipeActionScope>()?.state;
  @override
  bool updateShouldNotify(covariant _UPSwipeActionScope oldWidget) => false;
}

class UPSwipeActionItem extends StatefulWidget {
  const UPSwipeActionItem({
    super.key,
    this.show = false,
    this.closeOnClick = true,
    this.name = '',
    this.disabled = false,
    this.autoClose = true,
    this.threshold = 20,
    this.options = const [],
    this.duration = 300,
    this.onClick,
    this.onOpen,
    this.onClose,
    this.onUpdateShow,
    this.button,
    required this.child,
    this.customStyle,
  });

  final bool show;
  final bool closeOnClick;
  final dynamic name;
  final bool disabled;
  final bool autoClose;
  final num threshold;
  final List options;
  final dynamic duration;
  final void Function(Map payload)? onClick;
  final ValueChanged<dynamic>? onOpen;
  final ValueChanged<dynamic>? onClose;
  final ValueChanged<bool>? onUpdateShow;
  final Widget? button;
  final Widget child;
  final BoxDecoration? customStyle;

  @override
  State<UPSwipeActionItem> createState() => UPSwipeActionItemState();
}

class UPSwipeActionItemState extends State<UPSwipeActionItem> {
  double _offset = 0;
  double _actionsWidth = 0;
  bool _open = false;
  bool _dragging = false;
  bool _dragStartedOpen = false;
  double _dragDeltaX = 0;
  bool bindingUnbound = false;
  UPSwipeActionState? _parent;

  @override
  void initState() {
    super.initState();
    _open = widget.show;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final parent = _UPSwipeActionScope.of(context);
    if (parent != _parent) {
      _parent?.unregister(this);
      _parent = parent;
      _parent?.register(this);
    }
  }

  @override
  void didUpdateWidget(covariant UPSwipeActionItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.show != widget.show) {
      if (widget.show) {
        open();
      } else {
        close();
      }
    }
  }

  @override
  void dispose() {
    _parent?.unregister(this);
    super.dispose();
  }

  int get _ms => int.tryParse('${widget.duration}') ?? 300;

  void open() {
    if (widget.disabled) return;
    final wasOpen = _open;
    if (wasOpen && _offset == -_actionsWidth) return;
    setState(() {
      _open = true;
      _offset = -_actionsWidth;
    });
    if (wasOpen) return;
    _parent?.setOpened(this);
    widget.onUpdateShow?.call(true);
    widget.onOpen?.call(widget.name);
  }

  void close() {
    if (!_open && _offset == 0) return;
    final wasOpen = _open;
    setState(() {
      _open = false;
      _offset = 0;
    });
    if (!wasOpen) return;
    widget.onUpdateShow?.call(false);
    widget.onClose?.call(widget.name);
  }

  /// Source open/close handlers.
  void openHandler() => open();
  void closeHandler() => close();
  bool get isOpen => _open;
  bool get show => _open;

  /// Source swipe helpers (Batch I).
  void init([dynamic _]) => initialize();
  void initialize([dynamic _]) {
    if (widget.show) {
      open();
    } else {
      close();
    }
  }

  void openSwipeAction([dynamic _]) => open();
  void closeSwipeAction([dynamic _]) => close();
  void setStatus([dynamic status]) {
    final s = '$status'.toLowerCase();
    if (s == 'open' || s == 'true' || s == '1') {
      open();
    } else {
      close();
    }
  }

  void moveSwipeAction([num? offset]) {
    if (widget.disabled || _actionsWidth <= 0) return;
    final next = (offset?.toDouble() ?? _offset).clamp(-_actionsWidth, 0.0);
    setState(() {
      _offset = next;
    });
  }

  void buttonClickHandler([int index = 0]) {
    if (index < 0 || index >= widget.options.length) {
      widget.onClick?.call({'index': index, 'name': widget.name});
    } else {
      widget.onClick?.call({'index': index, 'name': widget.name});
    }
    if (widget.closeOnClick) close();
  }

  void clickHandler([dynamic _]) => buttonClickHandler(0);
  Map queryRect([dynamic _]) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return {'width': 0.0, 'height': 0.0, 'left': 0.0, 'top': 0.0};
    }
    final o = box.localToGlobal(Offset.zero);
    return {
      'width': box.size.width,
      'height': box.size.height,
      'left': o.dx,
      'top': o.dy,
    };
  }

  dynamic getContentRef([dynamic _]) => this;
  int getDuration([dynamic _]) => _ms;
  Future<void> sleep([int ms = 0]) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
  }

  Future<Map> getRectByDom([dynamic _]) async => queryRect();
  void onTouchstart([dynamic event]) {
    _beginDrag();
  }

  void onTouchmove([dynamic event]) {
    if (widget.disabled || _actionsWidth <= 0) return;
    if (!_dragging) _beginDrag();
    double? dx;
    if (event is Offset) {
      dx = event.dx;
    } else if (event is num) {
      dx = event.toDouble();
    } else if (event is Map) {
      final raw =
          event['deltaX'] ?? event['x'] ?? event['clientX'] ?? event['dx'];
      dx = double.tryParse('$raw');
    }
    if (dx == null) return;
    _updateDrag(dx);
  }

  void onTouchend([dynamic _]) {
    _endDrag();
  }

  void touchstart([dynamic _]) => onTouchstart(_);
  void touchmove([dynamic _]) => onTouchmove(_);
  void touchend([dynamic _]) => onTouchend(_);
  void moveCellByAnimation([dynamic offset]) {
    if (offset == null) {
      if (_open) {
        open();
      } else {
        close();
      }
      return;
    }
    final next = (num.tryParse('$offset') ?? 0).toDouble();
    if (next.abs() > widget.threshold.toDouble()) {
      open();
    } else if (next == 0) {
      close();
    } else {
      moveSwipeAction(next);
    }
  }

  void unbindBindingX([dynamic _]) {
    // Flutter uses GestureDetector; nothing to unbind.
    bindingUnbound = true;
  }

  /// Source `updateParentData` — re-sync open state from props.
  void updateParentData() {
    if (widget.show) {
      open();
    } else {
      close();
    }
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (widget.disabled || _actionsWidth <= 0) return;
    if (!_dragging) _beginDrag();
    _updateDrag(_dragDeltaX + d.delta.dx);
  }

  void _onDragEnd(DragEndDetails d) {
    _endDrag();
  }

  void _beginDrag() {
    if (widget.disabled || _dragging) return;
    _dragging = true;
    _dragStartedOpen = _open;
    _dragDeltaX = 0;
    _parent?.closeOther(this);
  }

  void _updateDrag(double deltaX) {
    if (!_dragging || _actionsWidth <= 0) return;
    _dragDeltaX = deltaX;
    final next = _dragStartedOpen
        ? (-_actionsWidth + deltaX.clamp(0.0, _actionsWidth))
        : deltaX.clamp(-_actionsWidth, 0.0);
    setState(() => _offset = next);
  }

  void _endDrag() {
    if (widget.disabled || !_dragging) return;
    final deltaX = _dragDeltaX;
    final startedOpen = _dragStartedOpen;
    _dragging = false;
    _dragDeltaX = 0;

    if (startedOpen) {
      if (deltaX < 0 || deltaX.abs() < widget.threshold.toDouble()) {
        open();
      } else {
        close();
      }
      return;
    }

    if (deltaX < 0 && deltaX.abs() >= widget.threshold.toDouble()) {
      open();
    } else {
      close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final actions = widget.button ??
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.options.length; i++)
              _buildOption(widget.options[i], i),
          ],
        );

    Widget root = Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerRight,
            child: _MeasureWidth(
              onChange: (w) {
                if ((w - _actionsWidth).abs() > 0.5) {
                  setState(() {
                    _actionsWidth = w;
                    if (_open) _offset = -w;
                  });
                }
              },
              child: actions,
            ),
          ),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: _ms),
          transform: Matrix4.translationValues(_offset, 0, 0),
          child: GestureDetector(
            onHorizontalDragStart: (_) => _beginDrag(),
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            onTap: () {
              if (_open) close();
            },
            child: Container(
              width: double.infinity,
              color: tokens.cardBgColor,
              child: widget.child,
            ),
          ),
        ),
      ],
    );
    return root;
  }

  Widget _buildOption(dynamic item, int index) {
    final map = item is Map ? item : {'text': '$item'};
    final style = map['style'] is Map
        ? Map<dynamic, dynamic>.from(map['style'] as Map)
        : <dynamic, dynamic>{};
    final hasRadius = style['borderRadius'] != null &&
        '${style['borderRadius']}'.trim().isNotEmpty;
    final radius = hasRadius ? UPUtils.getPx(style['borderRadius']) : 0.0;
    final bg = UPUtils.parseColor(
          style['backgroundColor'],
          fallback: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF4B5563)
              : const Color(0xFFC7C6CD),
        ) ??
        (Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF4B5563)
            : const Color(0xFFC7C6CD));
    final color =
        UPUtils.parseColor(style['color'], fallback: const Color(0xFFFFFFFF)) ??
            const Color(0xFFFFFFFF);
    final fontSize =
        style['fontSize'] != null ? UPUtils.getPx(style['fontSize']) : 16.0;
    final iconSize = map['iconSize'] != null
        ? UPUtils.getPx(map['iconSize'])
        : style['fontSize'] != null
            ? fontSize * 1.2
            : 17.0;
    final text = '${map['text'] ?? ''}';
    final icon = '${map['icon'] ?? ''}';

    final content = Container(
      alignment: Alignment.center,
      padding: hasRadius
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: hasRadius ? BorderRadius.circular(radius) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon.isNotEmpty) ...[
            UPIcon(name: icon, size: iconSize, color: color),
            if (text.isNotEmpty) const SizedBox(width: 2),
          ],
          if (text.isNotEmpty)
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: fontSize,
                height: 1,
              ),
            ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () {
        widget.onClick?.call({'index': index, 'name': widget.name});
        if (widget.closeOnClick) close();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        padding: hasRadius
            ? const EdgeInsets.symmetric(horizontal: 15)
            : EdgeInsets.zero,
        child: content,
      ),
    );
  }
}

class _MeasureWidth extends StatefulWidget {
  const _MeasureWidth({required this.onChange, required this.child});
  final ValueChanged<double> onChange;
  final Widget child;
  @override
  State<_MeasureWidth> createState() => _MeasureWidthState();
}

class _MeasureWidthState extends State<_MeasureWidth> {
  double? _old;
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = context.size;
      if (size != null && size.width != _old) {
        _old = size.width;
        widget.onChange(size.width);
      }
    });
    return widget.child;
  }
}
