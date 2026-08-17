import 'package:flutter/widgets.dart';

import '../utils/up_utils.dart';

/// 1:1 port of u-view convenience container.
class UPView extends StatelessWidget {
  const UPView({
    super.key,
    this.backgroundColor = '',
    this.color = '',
    this.flexDirection = '',
    this.justifyContent = '',
    this.alignItems = '',
    this.flex1 = '',
    this.width = '',
    this.height = '',
    this.padding = '',
    this.margin = '',
    this.borderColor = '',
    this.onClick,
    this.child,
    this.children = const [],
    this.customStyle,
  });

  final dynamic backgroundColor;
  final dynamic color;
  final String flexDirection;
  final String justifyContent;
  final String alignItems;
  final dynamic flex1;
  final dynamic width;
  final dynamic height;
  final dynamic padding;
  final dynamic margin;
  final dynamic borderColor;
  final VoidCallback? onClick;
  final Widget? child;
  final List<Widget> children;

  final BoxDecoration? customStyle;

  /// Source `clickHandler` / `onClick` method aliases.
  void clickHandler([dynamic _]) => onClick?.call();
  void onClickHandler([dynamic _]) => clickHandler(_);

  MainAxisAlignment get _main {
    switch (justifyContent) {
      case 'center':
        return MainAxisAlignment.center;
      case 'flex-end':
      case 'end':
        return MainAxisAlignment.end;
      case 'space-between':
      case 'between':
        return MainAxisAlignment.spaceBetween;
      case 'space-around':
      case 'around':
        return MainAxisAlignment.spaceAround;
      case 'space-evenly':
      case 'evenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  CrossAxisAlignment get _cross {
    switch (alignItems) {
      case 'center':
        return CrossAxisAlignment.center;
      case 'flex-end':
      case 'end':
        return CrossAxisAlignment.end;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      default:
        return CrossAxisAlignment.start;
    }
  }

  EdgeInsets _edge(dynamic value) {
    if (value == null || '$value'.isEmpty) return EdgeInsets.zero;
    if (value is EdgeInsets) return value;
    final parts = '$value'.trim().split(RegExp(r'\s+'));
    final nums = parts.map(UPUtils.getPx).toList();
    if (nums.length == 1) return EdgeInsets.all(nums[0]);
    if (nums.length == 2) {
      return EdgeInsets.symmetric(vertical: nums[0], horizontal: nums[1]);
    }
    if (nums.length == 3) {
      return EdgeInsets.only(
        top: nums[0],
        left: nums[1],
        right: nums[1],
        bottom: nums[2],
      );
    }
    if (nums.length >= 4) {
      return EdgeInsets.only(
        top: nums[0],
        right: nums[1],
        bottom: nums[2],
        left: nums[3],
      );
    }
    return EdgeInsets.zero;
  }

  /// Source computed: valueStyle (source empty body => empty map host).
  dynamic get valueStyle => const <String, dynamic>{};

  @override
  Widget build(BuildContext context) {
    final isRow = flexDirection == 'row' || flexDirection == 'row-reverse';
    final isReverse =
        flexDirection == 'row-reverse' || flexDirection == 'column-reverse';
    final kids = child != null ? [child!] : children;
    Widget content = kids.isEmpty
        ? const SizedBox.shrink()
        : (isRow
            ? Row(
                mainAxisAlignment: _main,
                crossAxisAlignment: _cross,
                textDirection:
                    isReverse ? TextDirection.rtl : TextDirection.ltr,
                children: kids,
              )
            : Column(
                mainAxisAlignment: _main,
                crossAxisAlignment: _cross,
                verticalDirection:
                    isReverse ? VerticalDirection.up : VerticalDirection.down,
                children: kids,
              ));

    final bg = UPUtils.parseColor(backgroundColor);
    final border = UPUtils.parseColor(borderColor);
    content = Container(
      width: '$width'.isEmpty ? null : UPUtils.getPx(width),
      height: '$height'.isEmpty ? null : UPUtils.getPx(height),
      padding: _edge(padding),
      margin: _edge(margin),
      decoration: BoxDecoration(
        color: bg,
        border: border == null ? null : Border.all(color: border, width: 0.5),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: UPUtils.parseColor(color)),
        child: content,
      ),
    );

    if ('$flex1' == '1' || flex1 == true || flex1 == 1) {
      content = Expanded(child: content);
    }
    return content;
  }
}
