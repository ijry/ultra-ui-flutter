import 'package:flutter/widgets.dart';

import '../utils/up_utils.dart';
import 'up_icon.dart';

/// 1:1 port of u-float-button.
class UPFloatButton extends StatefulWidget {
  const UPFloatButton({
    super.key,
    this.backgroundColor = '#2979ff',
    this.color = '#fff',
    this.width = '50px',
    this.height = '50px',
    this.borderColor = '',
    this.right = '30px',
    this.top = '',
    this.bottom = '',
    this.isMenu = false,
    this.list = const [],
    this.onClick,
    this.onItemClick,
    this.child,
    this.listSlot,
    this.customStyle,
  });

  final dynamic backgroundColor;
  final dynamic color;
  final dynamic width;
  final dynamic height;
  final dynamic borderColor;
  final dynamic right;
  final dynamic top;
  final dynamic bottom;
  final bool isMenu;
  final List list;
  final VoidCallback? onClick;
  final void Function(Map item, int index)? onItemClick;
  final Widget? child;
  final Widget? listSlot;

  final BoxDecoration? customStyle;
  @override
  State<UPFloatButton> createState() => UPFloatButtonState();
}

class UPFloatButtonState extends State<UPFloatButton> {
  bool showList = false;

  bool get isOpen => showList;

  void open() {
    if (!widget.isMenu || showList) return;
    setState(() => showList = true);
  }

  void close() {
    if (!showList) return;
    setState(() => showList = false);
  }

  void toggle() {
    if (!widget.isMenu) {
      widget.onClick?.call();
      return;
    }
    setState(() => showList = !showList);
    widget.onClick?.call();
  }

  Color get _bg =>
      UPUtils.parseColor(widget.backgroundColor) ?? const Color(0xFF2979FF);
  Color get _fg => UPUtils.parseColor(widget.color) ?? const Color(0xFFFFFFFF);
  double get _w => UPUtils.getPx(widget.width);
  double get _h => UPUtils.getPx(widget.height);

  /// Source `clickHandler`.
  void clickHandler() => _mainClick();

  /// Source `itemClick`.
  void itemClick(int index) {
    if (index < 0 || index >= widget.list.length) return;
    final item = widget.list[index];
    final map = item is Map
        ? Map<String, dynamic>.from(item)
        : <String, dynamic>{'value': item};
    widget.onItemClick?.call(map, index);
  }

  void _mainClick() {
    if (widget.isMenu) {
      setState(() => showList = !showList);
      widget.onClick?.call();
      return;
    }
    widget.onClick?.call();
  }

  Widget _circle({
    required Color bg,
    Color? border,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _w,
        height: _h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: border == null ? null : Border.all(color: border, width: 1),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final border = '${widget.borderColor}'.isEmpty
        ? null
        : UPUtils.parseColor(widget.borderColor);
    final right = UPUtils.getPx(widget.right);
    final hasTop = '${widget.top}'.isNotEmpty;
    final hasBottom = '${widget.bottom}'.isNotEmpty;
    final top = hasTop ? UPUtils.getPx(widget.top) : null;
    final bottom =
        hasBottom ? UPUtils.getPx(widget.bottom) : (hasTop ? null : 30.0);

    final items = <Widget>[];
    if (showList) {
      if (widget.listSlot != null) {
        items.add(widget.listSlot!);
      } else {
        for (var i = 0; i < widget.list.length; i++) {
          final raw = widget.list[i];
          final map = raw is Map
              ? Map<String, dynamic>.from(raw)
              : <String, dynamic>{'name': '$raw'};
          final itemBg = UPUtils.parseColor(map['backgroundColor']) ?? _bg;
          final itemFg = UPUtils.parseColor(map['color']) ?? _fg;
          final itemBorder = map['borderColor'] == null
              ? border
              : UPUtils.parseColor(map['borderColor']);
          items.add(
            Padding(
              key: ValueKey('up-float-item-$i'),
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: _circle(
                bg: itemBg,
                border: itemBorder,
                onTap: () => widget.onItemClick?.call(map, i),
                child: UPIcon(
                  name: '${map['name'] ?? 'plus'}',
                  color: itemFg,
                  size: 16,
                ),
              ),
            ),
          );
        }
      }
    }

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showList) ...items,
        _circle(
          bg: _bg,
          border: border,
          onTap: _mainClick,
          child: AnimatedRotation(
            turns: showList ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: widget.child ?? UPIcon(name: 'plus', color: _fg, size: 18),
          ),
        ),
      ],
    );

    final root = Positioned(
      right: right,
      top: top,
      bottom: bottom,
      child: SizedBox(
        width: _w,
        child: content,
      ),
    );

    return root;
  }
}
