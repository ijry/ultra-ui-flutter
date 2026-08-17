import 'package:flutter/widgets.dart';

import '../utils/up_utils.dart';

/// Port of u-status-bar.
class UPStatusBar extends StatefulWidget {
  const UPStatusBar({
    super.key,
    this.bgColor = 'transparent',
    this.height = 0,
    this.customStyle,
    this.onHeight,
    this.onUpdateHeight,
    this.child,
  });

  final dynamic bgColor;
  final dynamic height;
  final BoxDecoration? customStyle;
  final ValueChanged<double>? onHeight;

  /// Source update:height alias.
  final ValueChanged<double>? onUpdateHeight;
  final Widget? child;

  /// Source computed: style.
  dynamic get style {
    // uview-plus accepts `height`, but derives the rendered height from the
    // host status bar rather than using the prop as an override.
    return <String, dynamic>{
      'backgroundColor': bgColor,
    };
  }

  @override
  State<UPStatusBar> createState() => UPStatusBarState();
}

class UPStatusBarState extends State<UPStatusBar> {
  /// Source data.
  bool isH5 = false;

  double? _emitted;
  double _height = 0;

  double get statusHeight => _height;

  /// Re-emit current height via [onHeight].
  void refreshHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onHeight?.call(_height);
      widget.onUpdateHeight?.call(_height);
    });
  }

  /// Source-compatible init alias.
  void init() => refreshHeight();

  /// Force recompute from MediaQuery / prop.
  void updateHeight() {
    if (!mounted) return;
    setState(() {});
    refreshHeight();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.maybeOf(context);
    final top = mq?.padding.top ?? 0;
    final h = top;
    isH5 = h == 0;
    _height = h;
    final color =
        UPUtils.parseColor(widget.bgColor, fallback: const Color(0x00000000));
    if (_emitted != h) {
      _emitted = h;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onHeight?.call(h);
        widget.onUpdateHeight?.call(h);
      });
    }
    return Container(
      width: double.infinity,
      height: h,
      decoration: (widget.customStyle ?? const BoxDecoration()).copyWith(
        color: widget.customStyle?.color ?? color,
      ),
      child: widget.child,
    );
  }
}
