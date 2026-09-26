import 'package:flutter/material.dart';

import '../utils/up_utils.dart';

/// Cross-platform glass options. Accepted for API parity; NOT rendered on
/// Flutter yet (glass is iOS/Android-first per the shared contract).
class UPFlexGlass {
  const UPFlexGlass({
    this.enabled = false,
    this.variant = 'regular',
    this.tint,
    this.interactive = false,
    this.cornerRadius,
  });

  final bool enabled;
  final String variant;
  final String? tint;
  final bool interactive;
  final dynamic cornerRadius;
}

/// General flexbox container — the native-side counterpart of a
/// `<view class="flex ...">` node. Distinct from the 12-col [UPRow]/[UPCol].
class UPFlex extends StatelessWidget {
  const UPFlex({
    super.key,
    this.direction = 'row',
    this.justify = 'flex-start',
    this.align = 'stretch',
    this.wrap = false,
    this.gap = 0,
    this.onClick,
    this.customStyle,
    this.glass,
    required this.children,
  });

  final String direction;
  final String justify;
  final String align;
  final bool wrap;
  final dynamic gap;
  final VoidCallback? onClick;
  final BoxDecoration? customStyle;
  final UPFlexGlass? glass;
  final List<Widget> children;

  bool get _isHorizontal =>
      direction == 'row' || direction == 'row-reverse';
  bool get _isReverse =>
      direction == 'row-reverse' || direction == 'column-reverse';
  Axis get _axis => _isHorizontal ? Axis.horizontal : Axis.vertical;
  List<Widget> get _ordered =>
      _isReverse ? children.reversed.toList() : children;

  MainAxisAlignment get _main {
    switch (justify) {
      case 'end':
      case 'flex-end':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'space-between':
        return MainAxisAlignment.spaceBetween;
      case 'space-around':
        return MainAxisAlignment.spaceAround;
      case 'space-evenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  CrossAxisAlignment get _cross {
    switch (align) {
      case 'flex-end':
        return CrossAxisAlignment.end;
      case 'center':
        return CrossAxisAlignment.center;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      default: // 'flex-start' and 'baseline' (degraded) → start
        return CrossAxisAlignment.start;
    }
  }

  WrapAlignment get _wrapMain {
    switch (justify) {
      case 'end':
      case 'flex-end':
        return WrapAlignment.end;
      case 'center':
        return WrapAlignment.center;
      case 'space-between':
        return WrapAlignment.spaceBetween;
      case 'space-around':
        return WrapAlignment.spaceAround;
      case 'space-evenly':
        return WrapAlignment.spaceEvenly;
      default:
        return WrapAlignment.start;
    }
  }

  WrapCrossAlignment get _wrapCross {
    switch (align) {
      case 'flex-end':
        return WrapCrossAlignment.end;
      case 'center':
        return WrapCrossAlignment.center;
      default:
        return WrapCrossAlignment.start;
    }
  }

  List<Widget> _withGap(List<Widget> items, double g) {
    if (items.length < 2) return items;
    final box = _isHorizontal ? SizedBox(width: g) : SizedBox(height: g);
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) out.add(box);
      out.add(items[i]);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final raw = UPUtils.getPx(gap);
    final g = raw is num ? raw.toDouble() : 0.0;
    Widget layout;
    if (wrap) {
      layout = Wrap(
        direction: _axis,
        alignment: _wrapMain,
        runAlignment: _wrapMain,
        crossAxisAlignment: _wrapCross,
        spacing: g,
        runSpacing: g,
        children: _ordered,
      );
    } else {
      layout = Flex(
        direction: _axis,
        mainAxisAlignment: _main,
        crossAxisAlignment: _cross,
        mainAxisSize: _isHorizontal ? MainAxisSize.max : MainAxisSize.min,
        children: g > 0 ? _withGap(_ordered, g) : _ordered,
      );
    }
    Widget root = layout;
    if (customStyle != null) {
      root = DecoratedBox(decoration: customStyle!, child: root);
    }
    if (onClick != null) {
      root = GestureDetector(
        onTap: onClick,
        behavior: HitTestBehavior.opaque,
        child: root,
      );
    }
    return root;
  }
}
