import 'package:flutter/widgets.dart';

import '../utils/up_utils.dart';
import 'up_icon.dart';

/// 1:1 port of u-read-more.
class UPReadMore extends StatefulWidget {
  const UPReadMore({
    super.key,
    this.showHeight = 400,
    this.toggle = false,
    this.closeText = '展开阅读全文',
    this.openText = '收起',
    this.color = '#2979ff',
    this.fontSize = 14,
    this.shadowStyle,
    this.textIndent = '2em',
    this.name = '',
    this.customStyle,
    this.onOpen,
    this.onClose,
    this.toggleBuilder,
    required this.child,
  });

  final dynamic showHeight;
  final bool toggle;
  final String closeText;
  final String openText;
  final dynamic color;
  final dynamic fontSize;
  final Map<String, dynamic>? shadowStyle;
  final String textIndent;
  final dynamic name;
  final BoxDecoration? customStyle;
  final ValueChanged<dynamic>? onOpen;
  final ValueChanged<dynamic>? onClose;
  final WidgetBuilder? toggleBuilder;
  final Widget child;

  /// Source computed: innerShadowStyle (closed default).
  dynamic get innerShadowStyle => shadowStyle == null
      ? <String, dynamic>{}
      : Map<String, dynamic>.from(shadowStyle!);

  @override
  State<UPReadMore> createState() => UPReadMoreState();
}

class UPReadMoreState extends State<UPReadMore> {
  final GlobalKey _contentMeasureKey = GlobalKey();
  int _initEpoch = 0;

  /// Source host helper.
  dynamic resolve([dynamic v]) => v;

  /// Source data.
  String elId = 'up-read-more';

  /// close | open
  String status = 'close';

  bool get isOpen => status == 'open';
  bool get isClosed => status == 'close';
  bool get canToggle => isLongContent && !_forceHideToggle;

  void open() {
    if (status == 'open' || !isLongContent) return;
    setState(() {
      status = 'open';
      if (widget.toggle == false) {
        isLongContent = false;
        _forceHideToggle = true;
      }
    });
    widget.onOpen?.call(widget.name);
  }

  void close() {
    if (status == 'close') return;
    if (_forceHideToggle && widget.toggle == false) return;
    setState(() => status = 'close');
    widget.onClose?.call(widget.name);
  }

  void toggle() => _toggle();

  /// Source `toggleReadMore` alias.
  void toggleReadMore() => toggle();

  /// Source `init`.
  void init() {
    final epoch = ++_initEpoch;
    status = 'close';
    isLongContent = false;
    contentHeight = 0;
    _forceHideToggle = false;
    if (!mounted) return;
    setState(() {});
    // Source waits before querying content size. Re-measure even when the
    // widget's natural size did not change since the previous initialization.
    Future<void>.delayed(const Duration(milliseconds: 30), () {
      if (!mounted || epoch != _initEpoch) return;
      final box =
          _contentMeasureKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) _onContentSize(box.size);
    });
  }

  /// Source `getContentHeight`.
  double getContentHeight() => contentHeight;

  bool isLongContent = false;
  double contentHeight = 0;

  /// After expand with toggle=false, hide control permanently until remount.
  bool _forceHideToggle = false;

  void _onContentSize(Size size) {
    final maxH = UPUtils.getPx(widget.showHeight);
    final nextLong = size.height > maxH + 0.5;
    if (nextLong == isLongContent && size.height == contentHeight) return;
    setState(() {
      contentHeight = size.height;
      if (!_forceHideToggle) {
        isLongContent = nextLong;
      }
      if (!nextLong) {
        status = 'close';
        isLongContent = false;
        _forceHideToggle = false;
      }
    });
  }

  void _toggle() {
    final next = status == 'close' ? 'open' : 'close';
    setState(() {
      status = next;
      // Source: when toggle=false, hide control after expanding.
      if (widget.toggle == false && next == 'open') {
        isLongContent = false;
        _forceHideToggle = true;
      }
    });
    if (next == 'open') {
      widget.onOpen?.call(widget.name);
    } else {
      widget.onClose?.call(widget.name);
    }
  }

  Widget _buildShadowOverlay() {
    final style = widget.shadowStyle ??
        const {
          'paddingTop': 100.0,
          'marginTop': -100.0,
        };
    final padTop = UPUtils.getPx(style['paddingTop'] ?? 100).abs();
    final marginTop = UPUtils.getPx(style['marginTop'] ?? -100);
    final pull = marginTop < 0 ? -marginTop : 0.0;
    final layoutHeight = (padTop + marginTop).clamp(0.0, double.infinity);
    return IgnorePointer(
      child: SizedBox(
        height: layoutHeight,
        child: OverflowBox(
          minHeight: padTop,
          maxHeight: padTop,
          alignment: Alignment.topCenter,
          child: Transform.translate(
            offset: Offset(0, -pull),
            child: Container(
              height: padTop,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00FFFFFF),
                    Color(0xFFFFFFFF),
                  ],
                  stops: [0.0, 0.8],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxH = UPUtils.getPx(widget.showHeight);
    final color = UPUtils.parseColor(widget.color) ?? const Color(0xFF2979FF);
    final fs = UPUtils.getPx(widget.fontSize);
    final collapsed = isLongContent && status == 'close';
    final indent = widget.textIndent;
    double indentPx = 0;
    if (indent.endsWith('em')) {
      final n = double.tryParse(indent.replaceAll('em', '')) ?? 0;
      indentPx = n * fs;
    } else if (indent.isNotEmpty) {
      indentPx = UPUtils.getPx(indent);
    }

    final content = Padding(
      padding: EdgeInsets.only(left: indentPx),
      child: widget.child,
    );

    Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: 1,
            child: SizedBox(
              height:
                  collapsed ? maxH : (contentHeight > 0 ? contentHeight : null),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                // A scroll view lays out its child at natural height, so this
                // measures the single rendered child without duplicating keys.
                child: _MeasureBox(
                  key: _contentMeasureKey,
                  onChange: _onContentSize,
                  child: content,
                ),
              ),
            ),
          ),
        ),
        if (isLongContent)
          Column(
            children: [
              if (status == 'close') _buildShadowOverlay(),
              if (widget.toggleBuilder != null)
                GestureDetector(
                  onTap: _toggle,
                  behavior: HitTestBehavior.opaque,
                  child: widget.toggleBuilder!(context),
                )
              else
                GestureDetector(
                  onTap: _toggle,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          status == 'close'
                              ? widget.closeText
                              : widget.openText,
                          style: TextStyle(
                            color: color,
                            fontSize: fs,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 5),
                        UPIcon(
                          name: status == 'close' ? 'arrow-down' : 'arrow-up',
                          size: fs + 2,
                          color: color,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
      ],
    );

    return body;
  }
}

class _MeasureBox extends StatefulWidget {
  const _MeasureBox({super.key, required this.onChange, required this.child});
  final ValueChanged<Size> onChange;
  final Widget child;

  @override
  State<_MeasureBox> createState() => _MeasureBoxState();
}

class _MeasureBoxState extends State<_MeasureBox> {
  Size? _old;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = context.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      final size = box.size;
      if (_old != size) {
        _old = size;
        widget.onChange(size);
      }
    });
    return widget.child;
  }
}
