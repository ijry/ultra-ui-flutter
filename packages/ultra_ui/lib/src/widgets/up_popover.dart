import 'package:flutter/widgets.dart';

import '../utils/up_utils.dart';
import 'up_tooltip.dart';

/// 1:1 port of u-popover (based on UPTooltip).
class UPPopover extends StatefulWidget {
  const UPPopover({
    super.key,
    this.text = '',
    this.color = '#333',
    this.bgColor = '#f7f7f7',
    this.popupBgColor = '#f7f7f7',
    this.placement = 'top',
    this.triggerMode = 'click',
    this.show = false,
    this.zIndex = 10070,
    this.forcePosition = const {},
    this.direction = 'top',
    this.onOpen,
    this.onClose,
    this.onClick,
    this.onUpdateShow,
    this.trigger,
    this.content,
    this.customStyle,
  });

  final dynamic text;
  final dynamic color;
  final dynamic bgColor;
  final dynamic popupBgColor;
  final String placement;
  final String triggerMode;
  final bool show;
  final dynamic zIndex;
  final Map forcePosition;
  final String direction;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;
  final VoidCallback? onClick;
  final ValueChanged<bool>? onUpdateShow;
  final Widget? trigger;
  final Widget? content;
  final BoxDecoration? customStyle;

  @override
  State<UPPopover> createState() => UPPopoverState();
}

class UPPopoverState extends State<UPPopover> {
  bool visible = false;

  @override
  void initState() {
    super.initState();
    visible = widget.triggerMode == 'manual' && widget.show;
  }

  @override
  void didUpdateWidget(covariant UPPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.triggerMode == 'manual' && oldWidget.show != widget.show) {
      if (widget.show) {
        open();
      } else {
        close();
      }
    }
  }

  void open() {
    if (visible) return;
    setState(() => visible = true);
    widget.onOpen?.call();
  }

  void close() {
    if (!visible) return;
    setState(() => visible = false);
    widget.onClose?.call();
  }

  void toggle() {
    if (visible) {
      close();
    } else {
      open();
    }
  }

  /// Source method aliases that only emit callbacks.
  void onOpen() => widget.onOpen?.call();
  void onClose() => widget.onClose?.call();
  void onClick() => widget.onClick?.call();

  void _onTriggerTap() {
    if (widget.triggerMode == 'click' || widget.triggerMode == 'longpress') {
      open();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dir = widget.direction;
    final content = widget.content ??
        DefaultTextStyle.merge(
          style: TextStyle(
            color: UPUtils.parseColor(widget.color) ?? const Color(0xFF333333),
          ),
          child: Text('${widget.text}'),
        );

    final triggerChild = widget.trigger ?? const SizedBox.shrink();
    final trigger = widget.triggerMode == 'click'
        ? Listener(
            behavior: HitTestBehavior.opaque,
            onPointerUp: (_) => _onTriggerTap(),
            child: triggerChild,
          )
        : GestureDetector(
            onTap: widget.triggerMode == 'longpress' ? null : _onTriggerTap,
            onLongPress:
                widget.triggerMode == 'longpress' ? _onTriggerTap : null,
            behavior: HitTestBehavior.opaque,
            child: triggerChild,
          );

    Widget root = UPTooltip(
      text: widget.text,
      color: widget.color,
      // Popover always supplies Tooltip's trigger slot, so Tooltip's text
      // fallback (and its bgColor branch) is inactive in the source template.
      bgColor: 'transparent',
      popupBgColor: widget.popupBgColor,
      direction: dir,
      placement: '',
      // Popover owns open/close to avoid nested gesture competition.
      triggerMode: 'manual',
      show: visible,
      showCopy: false,
      zIndex: widget.zIndex,
      forcePosition: widget.forcePosition,
      // Popover already emits open/close; avoid double callbacks from tooltip.
      content: content,
      child: trigger,
    );
    return root;
  }
}
