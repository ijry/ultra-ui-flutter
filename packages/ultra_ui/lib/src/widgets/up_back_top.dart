import 'package:flutter/widgets.dart';

import '../utils/up_utils.dart';
import 'up_icon.dart';
import 'up_transition.dart';

final Expando<Object> _upBackTopLastError =
    Expando<Object>('upBackTopLastError');

/// Port of u-back-top.
class UPBackTop extends StatelessWidget {
  /// Source host helper.
  dynamic get lastError => _upBackTopLastError[this];
  void error([dynamic payload]) {
    _upBackTopLastError[this] = payload;
  }

  const UPBackTop({
    super.key,
    this.mode = 'circle',
    this.icon = 'arrow-upward',
    this.text = '',
    this.duration = 100,
    this.scrollTop = 0,
    this.top = 400,
    this.bottom = 100,
    this.right = 20,
    this.zIndex = 9,
    this.iconStyle,
    this.customStyle,
    this.scrollController,
    this.child,
    this.onClick,
  });

  final String mode;
  final String icon;
  final String text;
  final dynamic duration;
  final dynamic scrollTop;
  final dynamic top;
  final dynamic bottom;
  final dynamic right;
  final dynamic zIndex;
  final Map<String, dynamic>? iconStyle;
  final BoxDecoration? customStyle;
  final ScrollController? scrollController;
  final Widget? child;
  final VoidCallback? onClick;

  /// Source `backToTop`.
  void backToTop() => _backToTop();

  void _backToTop() {
    final ms = int.tryParse('$duration') ?? 100;
    final c = scrollController;
    if (c != null && c.hasClients) {
      c.animateTo(
        0,
        duration: Duration(milliseconds: ms < 0 ? 0 : ms),
        curve: Curves.easeOut,
      );
    }
    onClick?.call();
  }

  /// Source computed: backTopStyle.
  dynamic get backTopStyle => <String, dynamic>{
        'bottom': UPUtils.addUnit(bottom),
        'right': UPUtils.addUnit(right),
        'width': '40px',
        'height': '40px',
        'position': 'fixed',
        'zIndex': 10,
      };

  /// Source computed: show.
  bool get show => UPUtils.getPx(scrollTop) > UPUtils.getPx(top);

  /// Source computed: contentStyle.
  dynamic get contentStyle {
    final radius = mode == 'circle' ? '100px' : '4px';
    return <String, dynamic>{
      'borderTopLeftRadius': radius,
      'borderTopRightRadius': radius,
      'borderBottomLeftRadius': radius,
      'borderBottomRightRadius': radius,
    };
  }

  @override
  Widget build(BuildContext context) {
    final st = UPUtils.getPx(scrollTop);
    final showTop = UPUtils.getPx(top);
    final show = st > showTop;
    final b = UPUtils.getPx(bottom);
    final r = UPUtils.getPx(right);
    final radius = mode == 'circle' ? 100.0 : 4.0;
    final iconColor =
        iconStyle == null ? '#909399' : (iconStyle!['color'] ?? '#909399');
    final iconSize =
        iconStyle == null ? 19.0 : UPUtils.getPx(iconStyle!['fontSize'] ?? 19);
    final defaultDecoration = BoxDecoration(
      color: const Color(0xFFE1E1E1),
      borderRadius: BorderRadius.circular(radius),
    );
    final callerDecoration = customStyle;
    final decoration = callerDecoration == null
        ? defaultDecoration
        : BoxDecoration(
            color: callerDecoration.gradient == null
                ? callerDecoration.color ?? defaultDecoration.color
                : null,
            image: callerDecoration.image ?? defaultDecoration.image,
            border: callerDecoration.border ?? defaultDecoration.border,
            borderRadius: callerDecoration.shape == BoxShape.circle
                ? null
                : callerDecoration.borderRadius ??
                    defaultDecoration.borderRadius,
            boxShadow:
                callerDecoration.boxShadow ?? defaultDecoration.boxShadow,
            gradient: callerDecoration.gradient ?? defaultDecoration.gradient,
            backgroundBlendMode: callerDecoration.backgroundBlendMode ??
                defaultDecoration.backgroundBlendMode,
            shape: callerDecoration.shape,
          );

    final content = child ??
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: decoration,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              UPIcon(name: icon, size: iconSize, color: iconColor),
              if (text.isNotEmpty)
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF909399),
                    height: 1,
                  ),
                ),
            ],
          ),
        );

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: EdgeInsets.only(right: r, bottom: b),
        child: SizedBox(
          width: 40,
          height: 40,
          child: UPTransition(
            show: show,
            mode: 'fade',
            child: GestureDetector(
              onTap: _backToTop,
              behavior: HitTestBehavior.opaque,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
