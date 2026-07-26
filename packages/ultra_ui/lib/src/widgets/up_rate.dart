import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';

/// 1:1 port of u-rate defaults and visual metrics.
class UPRate extends StatefulWidget {
  const UPRate({
    super.key,
    this.value = 1,
    this.count = 5,
    this.disabled = false,
    this.readonly = false,
    this.size = 18,
    this.inactiveColor = '',
    this.activeColor = '',
    this.gutter = 4,
    this.minCount = 1,
    this.allowHalf = false,
    this.activeIcon = 'star-fill',
    this.inactiveIcon = 'star',
    this.touchable = true,
    this.customStyle,
    this.onChange,
    this.onInput,
    this.onUpdateValue,
    this.onUpdateModelValue,
  });

  final dynamic value;
  final dynamic count;
  final bool disabled;
  final bool readonly;
  final dynamic size;
  final dynamic inactiveColor;
  final dynamic activeColor;
  final dynamic gutter;
  final dynamic minCount;
  final bool allowHalf;
  final String activeIcon;
  final String inactiveIcon;
  final bool touchable;
  final BoxDecoration? customStyle;
  final ValueChanged<num>? onChange;

  /// Source emit alias: input.
  final ValueChanged<num>? onInput;

  /// Source `update:modelValue` / v-model alias.
  final ValueChanged<num>? onUpdateValue;
  final ValueChanged<num>? onUpdateModelValue;

  /// Source computed: disabledColorInner.
  dynamic get disabledColorInner => '#c8c9cc';

  /// Source computed: activeColorInner.
  dynamic get activeColorInner {
    if (activeColor != null && '$activeColor'.trim().isNotEmpty)
      return activeColor;
    return '#FA3534';
  }

  /// Source computed: inactiveColorInner.
  dynamic get inactiveColorInner {
    if (inactiveColor != null && '$inactiveColor'.trim().isNotEmpty) {
      return inactiveColor;
    }
    return '#b2b2b2';
  }

  @override
  State<UPRate> createState() => UPRateState();
}

class UPRateState extends State<UPRate> {
  /// Source host helper.
  Future<void> setTimeout([dynamic cb, int ms = 0]) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
    if (cb is Function) cb();
  }

  /// Source host helper.
  Future<void> sleep([int ms = 0]) async =>
      Future<void>.delayed(Duration(milliseconds: ms));

  num? _local;

  int get _count => int.tryParse('${widget.count}') ?? 5;

  /// Source data.
  bool moving = false;
  double rateWidth = 0;
  double rateBoxLeft = 0;
  String elClass = 'up-rate';
  String elId = 'up-rate';

  num get _minCount => num.tryParse('${widget.minCount}') ?? 1;
  num get value => _local ?? (num.tryParse('${widget.value}') ?? 1);

  @override
  void didUpdateWidget(covariant UPRate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _local = null;
    }
  }

  /// Source `init` — re-sync from props.
  void init() {
    setState(() => _local = null);
  }

  void setValue(num next, {bool emit = true}) {
    var v = next;
    if (v < _minCount) v = _minCount;
    if (v > _count) v = _count;
    setState(() => _local = v);
    if (emit) {
      widget.onChange?.call(v);
      widget.onInput?.call(v);
      widget.onUpdateValue?.call(v);
      widget.onUpdateModelValue?.call(v);
    }
  }

  /// Source `emitEvent` — emit change/update with current or provided value.
  void emitEvent([num? next]) {
    final v = next ?? value;
    widget.onChange?.call(v);
    widget.onInput?.call(v);
    widget.onUpdateValue?.call(v);
    widget.onUpdateModelValue?.call(v);
  }

  /// Source rect helpers.
  Map getElRect() {
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

  Map getIconRect() => getElRect();

  /// Source `clickHandler` index is 0-based icon index.
  void clickHandler(int index, {bool half = false}) {
    if (widget.disabled || widget.readonly) return;
    final next = half ? index + 0.5 : (index + 1).toDouble();
    setValue(next);
  }

  /// Source `normalizeActiveIndex`.
  num normalizeActiveIndex([num? raw]) {
    var v = raw ?? value;
    if (v < _minCount) v = _minCount;
    if (v > _count) v = _count;
    if (!widget.allowHalf) v = v.roundToDouble();
    return v;
  }

  /// Source `getFallbackRateWidth`.
  double getFallbackRateWidth([dynamic _]) {
    final size = UPUtils.getPx(widget.size);
    final gap = UPUtils.getPx(widget.gutter);
    return _count * (size + gap);
  }

  /// Source `getRateIconWrapRect`.
  Map getRateIconWrapRect([dynamic _]) => getElRect();

  /// Source `ensureRateMetrics` — ensure rateWidth/rateBoxLeft usable.
  bool ensureRateMetrics([dynamic _]) {
    if (!rateBoxLeft.isFinite) {
      rateBoxLeft = 0;
    }
    if (!rateWidth.isFinite || rateWidth <= 0) {
      rateWidth = getFallbackRateWidth();
      // Prefer live layout when available.
      final rect = getElRect();
      final w = rect['width'];
      if (w is num && w > 0) {
        rateWidth = w.toDouble() / _count;
        final left = rect['left'];
        if (left is num && left.isFinite) rateBoxLeft = left.toDouble();
      }
    }
    return rateWidth.isFinite && rateWidth > 0;
  }

  /// Source touch helpers.
  /// Source rate helpers (Batch J).
  Map getRateItemRect([dynamic _]) => getIconRect();
  double toNumber([dynamic raw]) {
    if (raw is num) return raw.toDouble();
    return double.tryParse('$raw') ?? 0;
  }

  void touchMove([double? x]) {
    if (x != null) getActiveIndex(x);
  }

  void touchEnd([double? x]) {
    if (x != null) getActiveIndex(x);
  }

  /// Source `getCountValue`.
  int getCountValue() => _count;

  /// Source `getMinCountValue`.
  num getMinCountValue() => _minCount;

  /// Source `getActiveIndex` — when [x] is given, map x-position to rate value.
  /// Without [x], returns current value.
  num getActiveIndex([double? x, bool isClick = false]) {
    if (x == null) return value;
    if (widget.disabled || widget.readonly) return value;
    final count = getCountValue();
    if (count <= 0) return value;
    final size = UPUtils.getPx(widget.size);
    final gap = UPUtils.getPx(widget.gutter);
    final unit = size + gap;
    if (unit <= 0) return value;
    var idx = x / unit;
    if (idx < 0) idx = 0;
    num next;
    if (widget.allowHalf) {
      next = (idx * 2).ceil() / 2;
      if (next < 0.5) next = 0.5;
    } else {
      next = idx.ceil().toDouble();
      if (next < 1) next = 1;
    }
    if (next < getMinCountValue()) next = getMinCountValue();
    if (next > count) next = count.toDouble();
    setValue(next);
    return next;
  }

  void _select(num next) {
    if (widget.disabled || widget.readonly) return;
    setValue(next);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final iconSize = UPUtils.getPx(widget.size);
    final gap = UPUtils.getPx(widget.gutter);
    final active =
        UPUtils.parseColor(widget.activeColor) ?? const Color(0xFFFA3534);
    final inactive =
        UPUtils.parseColor(widget.inactiveColor) ?? const Color(0xFFB2B2B2);
    final disabledColor = tokens.disabledColor;
    final activeIndex = value;

    Widget body = GestureDetector(
      onHorizontalDragUpdate: (!widget.touchable ||
              widget.disabled ||
              widget.readonly)
          ? null
          : (details) {
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;
              final local = box.globalToLocal(details.globalPosition);
              final itemW = iconSize + gap;
              if (itemW <= 0) return;
              var index = (local.dx / itemW) + 1;
              if (widget.allowHalf) {
                final frac = index - index.floor();
                index =
                    frac <= 0.5 ? index.floor() + 0.5 : index.ceil().toDouble();
              } else {
                index = index.ceilToDouble();
              }
              _select(index);
            },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_count, (index) {
          // Source: floor(activeIndex) > index => full active
          final full = activeIndex.floor() > index;
          // Source half overlay: ceil(activeIndex) > index
          final half = widget.allowHalf &&
              !full &&
              activeIndex.ceil() > index &&
              activeIndex > index;
          final baseActive = full;
          final baseColor = widget.disabled
              ? disabledColor
              : (baseActive ? active : inactive);
          final baseIcon = baseActive ? widget.activeIcon : widget.inactiveIcon;
          final halfColor = widget.disabled ? disabledColor : active;

          return GestureDetector(
            onTapDown: (details) {
              if (!widget.touchable || widget.disabled || widget.readonly) {
                return;
              }
              if (widget.allowHalf) {
                final local = details.localPosition;
                final next = local.dx <= iconSize / 2
                    ? index + 0.5
                    : (index + 1).toDouble();
                _select(next);
              } else {
                _select(index + 1);
              }
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: gap / 2),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  UPIcon(
                    name: baseIcon,
                    size: iconSize,
                    color: baseColor,
                  ),
                  if (half)
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.5,
                        child: UPIcon(
                          name: widget.activeIcon,
                          size: iconSize,
                          color: halfColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );

    if (widget.customStyle != null) {
      body = Container(decoration: widget.customStyle, child: body);
    }
    return body;
  }
}
