import 'package:flutter/widgets.dart';

import '../utils/up_utils.dart';
import 'up_tag.dart';

/// Port of u-choose / up-choose.
class UPChoose extends StatelessWidget {
  const UPChoose({
    super.key,
    this.options = const [],
    this.value,
    this.modelValue,
    this.type = 'radio',
    this.itemWidth = 'auto',
    this.itemHeight = '50px',
    this.itemPadding = '8px',
    this.labelName = 'title',
    this.valueName = 'value',
    this.customClick = false,
    this.wrap = true,
    this.onChange,
    this.onCustomClick,
    this.itemBuilder,
    this.customStyle,
    this.onUpdateValue,
    this.onUpdateModelValue,
  });

  final List options;

  /// Current selected index (source `modelValue` / Flutter `value`).
  final dynamic value;

  /// Source v-model alias of [value].
  final dynamic modelValue;
  final String type;
  final dynamic itemWidth;
  final dynamic itemHeight;
  final dynamic itemPadding;
  final String labelName;
  final String valueName;
  final bool customClick;
  final bool wrap;
  final ValueChanged<dynamic>? onChange;
  final ValueChanged<int>? onCustomClick;
  final Widget Function(
      BuildContext context, dynamic item, int index, bool active)? itemBuilder;
  final BoxDecoration? customStyle;

  /// Source data — selected index from value/modelValue when numeric.
  int get currentIndex {
    final c = _current;
    if (c is int) return c;
    if (c is num) return c.toInt();
    return int.tryParse('$c') ?? 0;
  }

  final ValueChanged<dynamic>? onUpdateValue;
  final ValueChanged<dynamic>? onUpdateModelValue;

  dynamic get _current => modelValue ?? value;

  String _labelOf(dynamic item) {
    if (item is Map) {
      return '${item[labelName] ?? item['label'] ?? item['name'] ?? ''}';
    }
    return '$item';
  }

  /// Source `change`.
  void change(int index) => _emit(index);

  void _emit(int index) {
    if (customClick) {
      onCustomClick?.call(index);
      return;
    }
    onChange?.call(index);
    onUpdateValue?.call(index);
    onUpdateModelValue?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final current = _current;
    final widthAuto =
        itemWidth == null || '${itemWidth}'.isEmpty || '${itemWidth}' == 'auto';
    final width = widthAuto ? null : UPUtils.getPx(itemWidth);

    final children = <Widget>[];
    for (var i = 0; i < options.length; i++) {
      final item = options[i];
      final active =
          current == i || current == (item is Map ? item[valueName] : item);
      Widget child;
      if (itemBuilder != null) {
        child = itemBuilder!(context, item, i, active);
      } else {
        child = UPTag(
          text: _labelOf(item),
          type: active ? 'primary' : 'info',
          size: 'large',
          plain: !active,
          height: itemHeight,
          padding: itemPadding,
          onClick: () => _emit(i),
        );
      }

      // Source wraps each item in inline-block with optional fixed width.
      child = Container(
        width: width,
        margin: EdgeInsets.only(
          right: wrap ? 0 : 0,
          bottom: wrap ? 0 : 0,
        ),
        padding: EdgeInsets.only(
          right: wrap ? 8 : 8,
          bottom: wrap ? 8 : 0,
        ),
        child: child,
      );
      children.add(
        GestureDetector(
          onTap: itemBuilder != null ? () => _emit(i) : null,
          child: child,
        ),
      );
    }

    Widget root = !wrap
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: children,
            ),
          )
        : Wrap(children: children);
    return root;
  }
}
