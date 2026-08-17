import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';

class UPTooltip extends StatefulWidget {
  const UPTooltip({
    super.key,
    this.text = '',
    this.copyText = '',
    this.size = 14,
    this.color = '#606266',
    this.bgColor = 'transparent',
    this.direction = 'top',
    this.placement = '',
    this.zIndex = 10071,
    this.showCopy = true,
    this.buttons = const [],
    this.overlay = true,
    this.showToast = true,
    this.popupBgColor = '',
    this.triggerMode = 'longpress',
    this.forcePosition = const {},
    this.show = false,
    this.singleton = false,
    this.tooltipInfo,
    this.triggerInfo,
    this.indicatorStyle,
    this.tooltipStyle,
    this.onClick,
    this.onOpen,
    this.onClose,
    this.onUpdateShow,
    this.child,
    this.content,
    this.customStyle,
  });

  final dynamic text;
  final dynamic copyText;
  final dynamic size;
  final dynamic color;
  final dynamic bgColor;
  final String direction;

  /// Source alias of [direction].
  final String placement;
  final dynamic zIndex;
  final bool showCopy;
  final List buttons;
  final bool overlay;
  final bool showToast;
  final dynamic popupBgColor;
  final String triggerMode;
  final Map forcePosition;
  final bool show;
  final bool singleton;

  /// Source retained layout/info fields.
  final dynamic tooltipInfo;
  final dynamic triggerInfo;
  final dynamic indicatorStyle;
  final dynamic tooltipStyle;
  final ValueChanged<int>? onClick;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;

  /// Source update:show alias.
  final ValueChanged<bool>? onUpdateShow;
  final Widget? child;

  /// Slot: content. When set, replaces default text/copy body.
  final Widget? content;
  final BoxDecoration? customStyle;

  /// Source computed `propsChange` — text/buttons deps for remeasure.
  dynamic propsChange([dynamic _]) => [text, buttons];

  /// Source computed: tooltipStyleCpu.
  dynamic get tooltipStyleCpu {
    if (calcReacted != true) return <String, dynamic>{};
    final style = <String, dynamic>{};
    if (direction == 'top' || direction == 'bottom') {
      style['transform'] =
          'translateY(${direction == 'top' ? '-100%' : '100%'})';
      if (direction == 'top') {
        style['marginTop'] = '-10px';
      } else {
        style['marginBottom'] = '-10px';
      }
    }
    if (forcePosition.isNotEmpty) {
      style.addAll(Map<String, dynamic>.from(forcePosition));
    }
    return style;
  }

  /// Source data defaults.
  dynamic get calcReacted => false;
  dynamic get indicatorWidth => 14;
  dynamic get screenGap => 12;

  @override
  State<UPTooltip> createState() => UPTooltipState();
}

class UPTooltipState extends State<UPTooltip> {
  static UPTooltipState? _activeSingletonTooltip;

  /// Source host helper.
  Future<void> sleep([int ms = 0]) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
  }

  /// Source host helper.
  dynamic resolve([dynamic v]) => v;

  /// Source `clickHander` (source typo retained) — open on click trigger.
  void clickHander([dynamic _]) {
    if (widget.triggerMode == 'click') {
      open();
    }
  }

  bool visible = false;

  /// Source data.
  bool get showTooltip => visible;
  bool calcReacted = false;
  String textId = 'up-tooltip-text';
  String tooltipId = 'up-tooltip';
  double tooltipTop = 0;

  String get _direction {
    if (widget.placement.isNotEmpty) return widget.placement;
    return widget.direction;
  }

  @override
  void initState() {
    super.initState();
    visible = widget.show;
  }

  @override
  void didUpdateWidget(covariant UPTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.show != widget.show) {
      final next = widget.show;
      if (next != visible) {
        visible = next;
        if (next) {
          widget.onOpen?.call();
          widget.onUpdateShow?.call(true);
        } else {
          widget.onClose?.call();
          widget.onUpdateShow?.call(false);
        }
      }
    }
  }

  @override
  void dispose() {
    if (identical(_activeSingletonTooltip, this)) {
      _activeSingletonTooltip = null;
    }
    super.dispose();
  }

  Future<void> _copy() async {
    final text = '${widget.copyText}'.isNotEmpty
        ? '${widget.copyText}'
        : '${widget.text}';
    await Clipboard.setData(ClipboardData(text: text));
  }

  void open() {
    final active = _activeSingletonTooltip;
    if (widget.singleton && active != null && !identical(active, this)) {
      active.close();
    }
    if (widget.singleton) _activeSingletonTooltip = this;
    if (visible) return;
    setState(() => visible = true);
    _markCalcReacted();
    widget.onOpen?.call();
    widget.onUpdateShow?.call(true);
  }

  void close() {
    if (!visible) return;
    if (identical(_activeSingletonTooltip, this)) {
      _activeSingletonTooltip = null;
    }
    setState(() => visible = false);
    widget.onClose?.call();
    widget.onUpdateShow?.call(false);
  }

  bool get isShown => visible;

  /// Source retained info/style fields.
  dynamic get effectiveTooltipInfo => widget.tooltipInfo;
  dynamic get effectiveTriggerInfo => widget.triggerInfo;
  dynamic get effectiveIndicatorStyle => widget.indicatorStyle;
  dynamic get effectiveTooltipStyle => widget.tooltipStyle;

  void toggle() => _toggle();

  /// Source `setClipboardData` / copy helper.
  Future<void> setClipboardData() => _copy();

  void clearActiveTooltip() => close();

  /// Source `overlayClickHandler` — close on overlay tap.
  void overlayClickHandler() => close();

  /// Source `btnClickHandler` — button index click + close.
  /// When [showCopy] is true, emitted index is offset by 1 (copy sits at 0).
  void btnClickHandler(int index) {
    close();
    widget.onClick?.call(widget.showCopy ? index + 1 : index);
  }

  /// Source `init`.
  void init() {
    visible = widget.show;
    _markCalcReacted();
    if (mounted) setState(() {});
  }

  void _markCalcReacted([bool value = true]) {
    if (calcReacted == value) return;
    calcReacted = value;
  }

  /// Source `getElRect` — returns current size if laid out.
  Map getElRect() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return {
        'width': 0.0,
        'height': 0.0,
        'left': 0.0,
        'top': 0.0,
        'right': 0.0,
        'bottom': 0.0,
      };
    }
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;
    _markCalcReacted(true);
    return {
      'width': size.width,
      'height': size.height,
      'left': offset.dx,
      'top': offset.dy,
      'right': offset.dx + size.width,
      'bottom': offset.dy + size.height,
    };
  }

  /// Source `longpressHandler`.
  void longpressHandler([dynamic _]) {
    if (widget.triggerMode == 'longpress') open();
  }

  /// Source `queryRect` alias of [getElRect].
  Map queryRect([dynamic _]) => getElRect();

  void _toggle() {
    if (visible) {
      close();
    } else {
      open();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final textColor = UPUtils.parseColor(widget.color) ?? tokens.contentColor;
    final bg =
        UPUtils.parseColor(widget.bgColor, fallback: const Color(0x00000000));
    final popupBg = UPUtils.parseColor(
          widget.popupBgColor == '' ? null : widget.popupBgColor,
          fallback: const Color(0xFF303133),
        ) ??
        const Color(0xFF303133);
    final fs = UPUtils.getPx(widget.size);
    final dir = _direction;
    final mode = widget.triggerMode;

    final trigger = GestureDetector(
      onTap: mode == 'click' ? open : null,
      onLongPress: mode == 'longpress' ? open : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: bg,
        child: widget.child ??
            Text(
              '${widget.text}',
              style: TextStyle(color: textColor, fontSize: fs),
            ),
      ),
    );

    if (!visible) {
      Widget root = trigger;
      if (widget.customStyle != null) {
        root = Container(decoration: widget.customStyle, child: root);
      }
      return root;
    }

    final actions = <Widget>[
      if (widget.showCopy)
        GestureDetector(
          onTap: () async {
            close();
            widget.onClick?.call(0);
            await _copy();
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text('复制',
                style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 13)),
          ),
        ),
      for (var i = 0; i < widget.buttons.length; i++)
        GestureDetector(
          onTap: () => btnClickHandler(i),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              '${widget.buttons[i]}',
              style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 13),
            ),
          ),
        ),
    ];

    Widget bubbleChild;
    if (widget.content != null) {
      bubbleChild = DefaultTextStyle.merge(
        style: TextStyle(color: textColor),
        child: widget.content!,
      );
    } else if (actions.isNotEmpty) {
      bubbleChild = Row(mainAxisSize: MainAxisSize.min, children: actions);
    } else {
      bubbleChild = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          '${widget.text}',
          style: TextStyle(color: const Color(0xFFFFFFFF), fontSize: fs),
        ),
      );
    }

    final bubble = Container(
      margin: EdgeInsets.only(
        bottom: dir == 'top' ? 6 : 0,
        top: dir == 'bottom' ? 6 : 0,
        left: dir == 'right' ? 6 : 0,
        right: dir == 'left' ? 6 : 0,
      ),
      padding: widget.content != null
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
          : const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: popupBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: bubbleChild,
    );

    Widget root;
    if (dir == 'left' || dir == 'right') {
      root = Row(
        mainAxisSize: MainAxisSize.min,
        children: dir == 'left' ? [bubble, trigger] : [trigger, bubble],
      );
    } else {
      root = Column(
        mainAxisSize: MainAxisSize.min,
        children: dir == 'bottom' ? [trigger, bubble] : [bubble, trigger],
      );
    }
    if (widget.customStyle != null) {
      root = Container(decoration: widget.customStyle, child: root);
    }
    return root;
  }
}
