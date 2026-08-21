import 'dart:async';

import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';
import 'up_link.dart';

final Expando<Map<String, dynamic>> _upRowNoticeState =
    Expando<Map<String, dynamic>>('upRowNoticeState');

typedef UPNoticeOpenPageHandler = Future<void> Function(
  String url, {
  String linkType,
});

/// Port of u-notice-bar.
class UPNoticeBar extends StatefulWidget {
  const UPNoticeBar({
    super.key,
    this.text = const [],
    this.direction = 'row',
    this.step = false,
    this.icon = 'volume',
    this.mode = '',
    this.color = '#f9ae3d',
    this.bgColor = '#fdf6ec',
    this.speed = 80,
    this.fontSize = 14,
    this.duration = 2000,
    this.disableTouch = true,
    this.url = '',
    this.linkType = 'navigateTo',
    this.justifyContent = 'flex-start',
    this.onClick,
    this.onClose,
    this.customStyle,
  });

  final dynamic text;
  final String direction;
  final bool step;
  final String icon;
  final String mode;
  final dynamic color;
  final dynamic bgColor;
  final dynamic speed;
  final dynamic fontSize;
  final dynamic duration;
  final bool disableTouch;
  final String url;
  final String linkType;
  final String justifyContent;
  final ValueChanged<int>? onClick;
  final VoidCallback? onClose;
  final BoxDecoration? customStyle;

  /// Optional host page-open hook for [url] navigation.
  static UPNoticeOpenPageHandler? openPageHandler;

  /// Source computed: resolvedColor.
  dynamic get resolvedColor {
    if (color != null && '$color'.trim().isNotEmpty) return color;
    return '#f9ae3d';
  }

  /// Source computed: resolvedBgColor.
  dynamic get resolvedBgColor {
    if (bgColor != null && '$bgColor'.trim().isNotEmpty) return bgColor;
    return '#fdf6ec';
  }

  @override
  State<UPNoticeBar> createState() => UPNoticeBarState();
}

class UPNoticeBarState extends State<UPNoticeBar> {
  bool closed = false;
  bool animating = false;
  dynamic lastNotice;

  bool get isClosed => closed;

  /// Source closable mode / programmatic hide.
  void close({bool emit = true}) {
    if (closed) return;
    setState(() => closed = true);
    if (emit) widget.onClose?.call();
  }

  /// Re-show a previously closed bar.
  void open() {
    if (!closed) return;
    setState(() => closed = false);
  }

  /// Toggle closed state.
  void toggle({bool emit = true}) {
    if (closed) {
      open();
    } else {
      close(emit: emit);
    }
  }

  Future<void> _handleClick(int index) async {
    widget.onClick?.call(index);
    if (widget.url.isEmpty || widget.linkType.isEmpty) return;
    final pageHandler = UPNoticeBar.openPageHandler;
    if (pageHandler != null) {
      await pageHandler(widget.url, linkType: widget.linkType);
    } else if (UPLink.openLinkHandler != null) {
      await UPLink.openLinkHandler!(widget.url);
    }
  }

  /// Source notice helpers (Batch J).
  void init([dynamic _]) {
    if (closed) open();
  }

  Future<void> clickHandler([dynamic index = 0]) async {
    final i = index is int ? index : int.tryParse('$index') ?? 0;
    await click(i);
  }

  void loopAnimation([dynamic _]) {
    // Flutter animation controllers live in child notice widgets.
    animating = true;
    if (mounted) setState(() {});
  }

  Map getNvueRect([dynamic _]) {
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

  void noticeChange([dynamic text]) {
    lastNotice = text ?? widget.text;
    // Re-open if previously closed so content can show.
    if (closed) open();
    if (mounted) setState(() {});
  }

  /// Source `click` alias.
  Future<void> click([int index = 0]) => _handleClick(index);

  @override
  Widget build(BuildContext context) {
    if (closed) return const SizedBox.shrink();
    // Source only honors bgColor when it differs from the prop default;
    // otherwise --up-notice-bar-bg-color applies, which has a dark value.
    final bgText = '${widget.bgColor}'.trim().toLowerCase();
    final hasCustomBg = bgText.isNotEmpty && bgText != '#fdf6ec';
    final bg = hasCustomBg
        ? (UPUtils.parseColor(widget.bgColor) ??
            UPThemeTokens.of(context).noticeBarBgColor)
        : UPThemeTokens.of(context).noticeBarBgColor;
    final isColumn = widget.direction == 'column' || widget.step;
    return Container(
      decoration: (widget.customStyle ?? BoxDecoration(color: bg)).copyWith(
        color: widget.customStyle?.color ?? bg,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: isColumn
          ? UPColumnNotice(
              text:
                  widget.text is List ? widget.text : ['${widget.text ?? ''}'],
              icon: widget.icon,
              mode: widget.mode,
              color: widget.color,
              fontSize: widget.fontSize,
              duration: widget.duration,
              disableTouch: widget.disableTouch,
              step: widget.step,
              justifyContent: widget.justifyContent,
              onClick: (i) => _handleClick(i),
              onClose: () {
                setState(() => closed = true);
                widget.onClose?.call();
              },
            )
          : UPRowNotice(
              text: widget.text is List
                  ? (widget.text as List).map((e) => '$e').join(' ')
                  : '${widget.text ?? ''}',
              icon: widget.icon,
              mode: widget.mode,
              color: widget.color,
              fontSize: widget.fontSize,
              speed: widget.speed,
              onClick: () => _handleClick(0),
              onClose: () {
                setState(() => closed = true);
                widget.onClose?.call();
              },
            ),
    );
  }
}

/// Port of u-row-notice.
class UPRowNotice extends StatelessWidget {
  const UPRowNotice({
    super.key,
    this.text = '',
    this.icon = 'volume',
    this.mode = '',
    this.color = '#f9ae3d',
    this.fontSize = 14,
    this.speed = 80,
    this.onClick,
    this.onClose,
    this.customStyle,
    this.iconSlot,
  });

  final String text;
  final String icon;
  final String mode;
  final dynamic color;
  final dynamic fontSize;
  final dynamic speed;
  final VoidCallback? onClick;
  final VoidCallback? onClose;
  final BoxDecoration? customStyle;
  final Widget? iconSlot;

  /// Source computed: animationStyle.
  dynamic get animationStyle => <String, dynamic>{
        'animationDuration': animationDuration,
        'animationPlayState': animationPlayState,
      };

  /// Source computed: innerText (split long text into 20-char chunks).
  dynamic get innerText {
    final result = <String>[];
    const len = 20;
    final textArr = text.split('');
    for (var i = 0; i < textArr.length; i += len) {
      final end = (i + len) > textArr.length ? textArr.length : i + len;
      result.add(textArr.sublist(i, end).join());
    }
    return result;
  }

  /// Source computed: textStyle.
  dynamic get textStyle => <String, dynamic>{
        'whiteSpace': 'nowrap !important',
        'color': color,
        'fontSize': UPUtils.addUnit(fontSize),
      };

  /// Source host helper: nvue.
  dynamic nvue([dynamic v]) => v;

  /// Source host helper: vue.
  dynamic vue([dynamic v]) => v;

  /// Source data defaults (runtime filled when measured text length is available).
  Map<String, dynamic> get _state =>
      _upRowNoticeState[this] ??= <String, dynamic>{
        'animationDuration': '0',
        'animationPlayState': 'paused',
        'nvueInit': true,
      };
  dynamic get animationDuration => _state['animationDuration'] ?? '0';
  dynamic get animationPlayState => _state['animationPlayState'] ?? 'paused';
  dynamic get nvueInit => _state['nvueInit'] ?? true;

  @override
  Widget build(BuildContext context) {
    final c = UPUtils.parseColor(color) ?? const Color(0xFFF9AE3D);
    final fs = UPUtils.getPx(fontSize);
    final sp = num.tryParse('$speed')?.toDouble() ?? 80;
    final durationMs =
        text.isEmpty || sp <= 0 ? 0 : ((text.length * 16) / sp * 1000).round();
    _state['animationDuration'] = '${durationMs}ms';
    _state['animationPlayState'] = text.isEmpty ? 'paused' : 'running';
    _state['nvueInit'] = true;
    Widget body = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onClick,
      child: Row(
        children: [
          if (iconSlot != null)
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: iconSlot,
            )
          else if (icon.isNotEmpty) ...[
            UPIcon(name: icon, size: 19, color: c),
            const SizedBox(width: 5),
          ],
          Expanded(
            child: _MarqueeText(
              text: text,
              color: c,
              fontSize: fs,
              speed: (num.tryParse('$speed') ?? 80).toDouble(),
            ),
          ),
          if (mode == 'link') ...[
            const SizedBox(width: 5),
            UPIcon(name: 'arrow-right', size: 17, color: c),
          ] else if (mode == 'closable') ...[
            const SizedBox(width: 5),
            GestureDetector(
              onTap: onClose,
              child: UPIcon(name: 'close', size: 16, color: c),
            ),
          ],
        ],
      ),
    );
    return body;
  }
}

/// Port of u-column-notice.
class UPColumnNotice extends StatefulWidget {
  const UPColumnNotice({
    super.key,
    this.text = const [],
    this.icon = 'volume',
    this.mode = '',
    this.color = '#f9ae3d',
    this.fontSize = 14,
    this.duration = 1500,
    this.disableTouch = true,
    this.step = false,
    this.justifyContent = 'flex-start',
    this.onClick,
    this.onClose,
    this.customStyle,
    this.iconSlot,
  });

  final dynamic text;
  final String icon;
  final String mode;
  final dynamic color;
  final dynamic fontSize;
  final dynamic duration;
  final bool disableTouch;
  final bool step;
  final String justifyContent;
  final ValueChanged<int>? onClick;
  final VoidCallback? onClose;
  final BoxDecoration? customStyle;
  final Widget? iconSlot;

  /// Source computed: textStyle.
  dynamic get textStyle => <String, dynamic>{
        'color': color,
        'fontSize': UPUtils.addUnit(fontSize),
      };

  @override
  State<UPColumnNotice> createState() => _UPColumnNoticeState();
}

class _UPColumnNoticeState extends State<UPColumnNotice> {
  int index = 0;
  Timer? timer;

  List<String> get texts {
    final t = widget.text;
    if (t is List) return t.map((e) => '$e').toList();
    final s = '$t';
    return s.isEmpty ? const <String>[] : [s];
  }

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant UPColumnNotice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ('${oldWidget.text}' != '${widget.text}' ||
        oldWidget.duration != widget.duration) {
      timer?.cancel();
      index = 0;
      _start();
    }
  }

  void _start() {
    if (texts.length <= 1) return;
    final ms = int.tryParse('${widget.duration}') ?? 1500;
    timer = Timer.periodic(Duration(milliseconds: ms), (_) {
      if (!mounted) return;
      setState(() => index = (index + 1) % texts.length);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  MainAxisAlignment get _align {
    switch (widget.justifyContent) {
      case 'center':
        return MainAxisAlignment.center;
      case 'flex-end':
      case 'end':
        return MainAxisAlignment.end;
      case 'space-between':
        return MainAxisAlignment.spaceBetween;
      default:
        return MainAxisAlignment.start;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = UPUtils.parseColor(widget.color) ?? const Color(0xFFF9AE3D);
    final fs = UPUtils.getPx(widget.fontSize);
    final content =
        texts.isEmpty ? '' : texts[index.clamp(0, texts.length - 1)];
    Widget body = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onClick?.call(index),
      child: Row(
        children: [
          if (widget.iconSlot != null)
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: widget.iconSlot,
            )
          else if (widget.icon.isNotEmpty) ...[
            UPIcon(name: widget.icon, size: 19, color: c),
            const SizedBox(width: 5),
          ],
          Expanded(
            child: SizedBox(
              height: 16,
              child: Row(
                mainAxisAlignment: _align,
                children: [
                  Flexible(
                    child: Text(
                      content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: c, fontSize: fs, height: 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.mode == 'link') ...[
            const SizedBox(width: 5),
            UPIcon(name: 'arrow-right', size: 17, color: c),
          ] else if (widget.mode == 'closable') ...[
            const SizedBox(width: 5),
            GestureDetector(
              onTap: widget.onClose,
              child: UPIcon(name: 'close', size: 16, color: c),
            ),
          ],
        ],
      ),
    );
    return body;
  }
}

class _MarqueeText extends StatefulWidget {
  const _MarqueeText({
    required this.text,
    required this.color,
    required this.fontSize,
    required this.speed,
  });

  final String text;
  final Color color;
  final double fontSize;
  final double speed;

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  double textWidth = 0;
  double boxWidth = 0;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndRun());
  }

  @override
  void didUpdateWidget(covariant _MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.fontSize != widget.fontSize ||
        oldWidget.speed != widget.speed) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndRun());
    }
  }

  void _measureAndRun() {
    if (!mounted) return;
    final painter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: TextStyle(fontSize: widget.fontSize),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    textWidth = painter.width;
    final speed = widget.speed <= 0 ? 80.0 : widget.speed;
    final distance = textWidth + (boxWidth > 0 ? boxWidth : textWidth);
    final seconds = (distance / speed).clamp(2.0, 60.0);
    controller
      ..duration = Duration(milliseconds: (seconds * 1000).round())
      ..repeat();
    setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(color: widget.color, fontSize: widget.fontSize);
    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if ((boxWidth - constraints.maxWidth).abs() > 0.5) {
            boxWidth = constraints.maxWidth;
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _measureAndRun());
          }
          return AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final start = boxWidth;
              final end = -textWidth;
              final dx = start + (end - start) * controller.value;
              return IgnorePointer(
                child: Transform.translate(
                  offset: Offset(dx, 0),
                  child: Text(
                    widget.text,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: style,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
