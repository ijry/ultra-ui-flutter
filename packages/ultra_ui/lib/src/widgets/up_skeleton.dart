import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';

final Expando<Map<String, dynamic>> _upSkeletonState =
    Expando<Map<String, dynamic>>('upSkeletonState');

/// 1:1 port of u-skeleton defaults and layout rules.
class UPSkeleton extends StatefulWidget {
  const UPSkeleton({
    super.key,
    this.loading = true,
    this.animate = true,
    this.rows = 0,
    this.rowsWidth = '100%',
    this.rowsHeight = 18,
    this.title = true,
    this.titleWidth = '50%',
    this.titleHeight = 18,
    this.avatar = false,
    this.avatarSize = 32,
    this.avatarShape = 'circle',
    this.styles,
    this.customStyle,
    this.child,
  });

  final bool loading;
  final bool animate;
  final dynamic rows;
  final dynamic rowsWidth;
  final dynamic rowsHeight;
  final bool title;
  final dynamic titleWidth;
  final dynamic titleHeight;
  final bool avatar;
  final dynamic avatarSize;
  final String avatarShape;

  /// Source retained styles map.
  final dynamic styles;
  final BoxDecoration? customStyle;
  final Widget? child;

  /// Source measured content width (updated by state when available).
  /// Host/const widgets keep 0 until measured.
  Map<String, dynamic> get _state =>
      _upSkeletonState[this] ??= <String, dynamic>{'width': 0.0};
  dynamic get width => (_state['width'] as num?)?.toDouble() ?? 0;

  /// Source computed: rowsArray.
  dynamic get rowsArray {
    final total = int.tryParse('$rows') ?? 0;
    final parentW = num.tryParse('$width')?.toDouble() ?? 0;
    final rowsOut = <Map<String, dynamic>>[];
    for (var i = 0; i < total; i++) {
      dynamic rowWidth;
      if (rowsWidth is List) {
        final list = rowsWidth as List;
        rowWidth =
            i < list.length ? list[i] : (i == total - 1 ? '70%' : '100%');
      } else {
        rowWidth = i == total - 1 ? '70%' : rowsWidth;
      }
      dynamic rowHeight;
      if (rowsHeight is List) {
        final list = rowsHeight as List;
        rowHeight = i < list.length ? list[i] : 18;
      } else {
        rowHeight = rowsHeight;
      }
      final item = <String, dynamic>{
        'marginTop': !title && i == 0 ? 0 : (title && i == 0 ? '20px' : '12px'),
      };
      final rw = '$rowWidth';
      if (rw.endsWith('%')) {
        final pct = double.tryParse(rw.replaceAll('%', '')) ?? 100;
        item['width'] = UPUtils.addUnit(parentW * pct / 100);
      } else {
        item['width'] = UPUtils.addUnit(rowWidth);
      }
      item['height'] = UPUtils.addUnit(rowHeight);
      rowsOut.add(item);
    }
    return rowsOut;
  }

  /// Source computed: uTitleWidth.
  dynamic get uTitleWidth {
    final parentW = num.tryParse('$width')?.toDouble() ?? 0;
    final tw = '$titleWidth';
    dynamic tWidth;
    if (tw.endsWith('%')) {
      final pct = double.tryParse(tw.replaceAll('%', '')) ?? 50;
      tWidth = UPUtils.addUnit(parentW * pct / 100);
    } else {
      tWidth = UPUtils.addUnit(titleWidth);
    }
    return UPUtils.addUnit(tWidth);
  }

  @override
  State<UPSkeleton> createState() => UPSkeletonState();
}

class UPSkeletonState extends State<UPSkeleton>
    with SingleTickerProviderStateMixin {
  /// Source `getComponentWidth` — measured host width when laid out.
  Future<double> getComponentWidth() async {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return 0;
    final w = box.size.width;
    widget._state['width'] = w;
    return w;
  }

  double get width => (widget._state['width'] as num?)?.toDouble() ?? 0;

  /// Source host helper (nvue-only animation path).
  bool nvueAnimating = false;
  void setNvueAnimation([dynamic value]) {
    if (value is bool) {
      nvueAnimating = value;
    } else if (value == null) {
      nvueAnimating = true;
    } else {
      final s = '$value'.toLowerCase();
      nvueAnimating = s != 'false' && s != '0' && s.isNotEmpty;
    }
    if (nvueAnimating) {
      startAnimate();
    } else {
      stopAnimate();
    }
  }

  AnimationController? _controller;
  bool? _localLoading;

  bool get isLoading => _localLoading ?? widget.loading;
  bool get isAnimating => _controller?.isAnimating ?? false;

  /// Source `init` — ensure loading skeleton + animation path.
  void init() {
    show();
    if (widget.animate) startAnimate();
  }

  void show() {
    if (isLoading) return;
    setState(() => _localLoading = true);
    _syncAnim();
  }

  void hide() {
    if (!isLoading) return;
    setState(() => _localLoading = false);
    _syncAnim();
  }

  void startAnimate() {
    if (!isLoading) return;
    _controller ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (!(_controller?.isAnimating ?? false)) {
      _controller?.repeat();
      setState(() {});
    }
  }

  void stopAnimate() {
    _controller?.stop();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _syncAnim();
  }

  @override
  void didUpdateWidget(covariant UPSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loading != widget.loading) {
      _localLoading = null;
    }
    if (oldWidget.animate != widget.animate ||
        oldWidget.loading != widget.loading) {
      _syncAnim();
    }
  }

  void _syncAnim() {
    if (widget.animate && isLoading) {
      _controller ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1800),
      )..repeat();
      if (!(_controller?.isAnimating ?? false)) {
        _controller?.repeat();
      }
    } else {
      _controller?.stop();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  double _widthOf(dynamic value, double parentWidth) {
    final s = '$value';
    if (s.endsWith('%')) {
      final p = double.tryParse(s.replaceAll('%', '')) ?? 100;
      return parentWidth * p / 100;
    }
    return UPUtils.getPx(value);
  }

  dynamic _rowWidthAt(int i, int total) {
    final rw = widget.rowsWidth;
    if (rw is List) {
      if (i < rw.length) return rw[i];
      return i == total - 1 ? '70%' : '100%';
    }
    // Source: last row defaults to 70% when not using array.
    return i == total - 1 ? '70%' : rw;
  }

  dynamic _rowHeightAt(int i) {
    final rh = widget.rowsHeight;
    if (rh is List) {
      if (i < rh.length) return rh[i];
      return 18;
    }
    return rh;
  }

  Widget _bone(double width, double height, {double radius = 3}) {
    final base = UPThemeTokens.of(context).bgColor;
    final shimmer = const Color(0x1FFFFFFF);
    if (!widget.animate || _controller == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }
    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, _) {
        final t = _controller!.value;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * t, 0),
              end: Alignment(1.0 + 2.0 * t, 0),
              colors: [
                base,
                Color.lerp(base, shimmer, 0.55) ?? base,
                base,
              ],
              stops: const [0.25, 0.37, 0.50],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      getComponentWidth();
    });
    if (!isLoading) return widget.child ?? const SizedBox.shrink();
    final rows = int.tryParse('${widget.rows}') ?? 0;
    final avatarSize = UPUtils.getPx(widget.avatarSize);
    final titleH = UPUtils.getPx(widget.titleHeight);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Content width excludes avatar, matching source measure on content.
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final contentW =
            widget.avatar ? (maxW - avatarSize - 15).clamp(0.0, maxW) : maxW;

        Widget body = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.avatar)
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: _bone(
                  avatarSize,
                  avatarSize,
                  radius: widget.avatarShape == 'square' ? 4 : 100,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.title)
                    _bone(_widthOf(widget.titleWidth, contentW), titleH),
                  for (var i = 0; i < rows; i++) ...[
                    SizedBox(
                      height: (!widget.title && i == 0)
                          ? 0
                          : (widget.title && i == 0 ? 20 : 12),
                    ),
                    _bone(
                      _widthOf(_rowWidthAt(i, rows), contentW),
                      UPUtils.getPx(_rowHeightAt(i)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
        return body;
      },
    );
  }
}
