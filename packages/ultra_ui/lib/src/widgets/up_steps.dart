import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';

final Expando<Map<String, dynamic>> _upStepsState =
    Expando<Map<String, dynamic>>('upStepsState');
final Expando<Map<String, dynamic>> _upStepsItemState =
    Expando<Map<String, dynamic>>('upStepsItemState');

/// 1:1 port of u-steps + u-steps-item.
class UPSteps extends StatelessWidget {
  const UPSteps({
    super.key,
    this.direction = 'row',
    this.current = 0,
    this.modelValue,
    this.activeColor = '#3c9cff',
    this.inactiveColor = '#969799',
    this.activeIcon = '',
    this.inactiveIcon = '',
    this.dot = false,
    this.options = const [],
    this.customStyle,
    this.onUpdateCurrent,
    this.onUpdateModelValue,
    required this.children,
  });

  final String direction;
  final dynamic current;

  /// Source v-model / modelValue alias for current.
  final dynamic modelValue;
  final dynamic activeColor;
  final dynamic inactiveColor;
  final String activeIcon;
  final String inactiveIcon;
  final bool dot;

  /// Source retained options list (host data mode).
  final List options;
  final BoxDecoration? customStyle;
  final ValueChanged<int>? onUpdateCurrent;
  final ValueChanged<dynamic>? onUpdateModelValue;
  dynamic get effectiveCurrent => modelValue ?? current;
  final List<Widget> children;

  /// Source `updateChildData` — parent props snapshot for children.
  dynamic updateChildData([dynamic _]) => parentDataCpu;

  /// Source `updateFromChild` — accept child status ping; returns current.
  dynamic updateFromChild([dynamic _]) => effectiveCurrent;

  /// Source parent helpers (Batch J + BI).
  Map<String, dynamic> get _state => _upStepsState[this] ??= <String, dynamic>{
        'initialized': false,
        'childrenVersion': 0
      };
  bool get initialized => _state['initialized'] == true;
  int get childrenVersion => (_state['childrenVersion'] as int?) ?? 0;
  void init([dynamic _]) {
    _state['initialized'] = true;
  }

  void updateParentData([dynamic _]) {
    _state['initialized'] = true;
    _state['childrenVersion'] = childrenVersion + 1;
  }

  void setCurrent(dynamic next) {
    final i = int.tryParse('$next') ?? 0;
    onUpdateCurrent?.call(i);
    onUpdateModelValue?.call(i);
  }

  /// Source computed: parentDataCpu.
  dynamic get parentDataCpu => <dynamic>[
        effectiveCurrent,
        direction,
        activeColor,
        inactiveColor,
        activeIcon,
        inactiveIcon,
        dot,
      ];

  @override
  Widget build(BuildContext context) {
    final len = children.length;
    final errorFlags = [
      for (final child in children) child is UPStepsItem ? child.error : false,
    ];
    final content = _UPStepsScope(
      current: int.tryParse('$effectiveCurrent') ?? 0,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      activeIcon: activeIcon,
      inactiveIcon: inactiveIcon,
      dot: dot,
      direction: direction,
      childLength: len,
      errorFlags: errorFlags,
      child: direction == 'column'
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < len; i++)
                  _UPStepIndex(index: i, child: children[i]),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < len; i++)
                  Expanded(child: _UPStepIndex(index: i, child: children[i])),
              ],
            ),
    );
    return content;
  }
}

class _UPStepsScope extends InheritedWidget {
  const _UPStepsScope({
    required this.current,
    required this.activeColor,
    required this.inactiveColor,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.dot,
    required this.direction,
    required this.childLength,
    required this.errorFlags,
    required super.child,
  });

  final int current;
  final dynamic activeColor;
  final dynamic inactiveColor;
  final String activeIcon;
  final String inactiveIcon;
  final bool dot;
  final String direction;
  final int childLength;
  final List<bool> errorFlags;

  static _UPStepsScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_UPStepsScope>();

  @override
  bool updateShouldNotify(covariant _UPStepsScope oldWidget) {
    return current != oldWidget.current ||
        activeColor != oldWidget.activeColor ||
        inactiveColor != oldWidget.inactiveColor ||
        activeIcon != oldWidget.activeIcon ||
        inactiveIcon != oldWidget.inactiveIcon ||
        dot != oldWidget.dot ||
        direction != oldWidget.direction ||
        childLength != oldWidget.childLength ||
        errorFlags != oldWidget.errorFlags;
  }
}

class _UPStepIndex extends InheritedWidget {
  const _UPStepIndex({required this.index, required super.child});
  final int index;

  static int of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_UPStepIndex>()?.index ?? 0;

  @override
  bool updateShouldNotify(covariant _UPStepIndex oldWidget) =>
      index != oldWidget.index;
}

class UPStepsItem extends StatelessWidget {
  const UPStepsItem({
    super.key,
    this.title = '',
    this.desc = '',
    this.iconSize = 17,
    this.error = false,
    this.iconWidget,
    this.titleWidget,
    this.descWidget,
    this.contentWidget,
    this.itemStyle,
  });
  final dynamic itemStyle;

  final String title;
  final String desc;
  final dynamic iconSize;
  final bool error;
  final Widget? iconWidget;
  final Widget? titleWidget;
  final Widget? descWidget;
  final Widget? contentWidget;

  String _statusClass(int index, int current) {
    if (current == index) return error ? 'error' : 'process';
    if (error) return 'error';
    if (current > index) return 'finish';
    return 'wait';
  }

  /// Source item helpers (Batch J + BI) + runtime index/parent/size.
  Map<String, dynamic> get _state =>
      _upStepsItemState[this] ??= <String, dynamic>{
        'initialized': false,
        'fromParent': null,
        'index': 0,
        'size': const <String, dynamic>{'width': 0.0, 'height': 0.0},
        'parentData': const <String, dynamic>{
          'current': 0,
          'direction': 'row',
          'activeColor': '#3c9cff',
          'inactiveColor': '#969799',
          'dot': false,
        },
      };
  bool get initialized => _state['initialized'] == true;
  dynamic get fromParent => _state['fromParent'];
  void init([dynamic _]) {
    _state['initialized'] = true;
  }

  void updateParentData([dynamic data]) {
    _state['initialized'] = true;
    if (data != null) _state['fromParent'] = data;
  }

  void updateFromParent([dynamic data]) {
    _state['fromParent'] = data ?? parentData;
    _state['initialized'] = true;
  }

  Map getStepsItemRect([dynamic _]) => const {
        'width': 0.0,
        'height': 0.0,
        'left': 0.0,
        'top': 0.0,
      };

  /// Source data defaults (runtime filled by parent scope).
  dynamic get parentData =>
      _state['parentData'] ??
      const <String, dynamic>{
        'current': 0,
        'direction': 'row',
        'activeColor': '#3c9cff',
        'inactiveColor': '#969799',
        'dot': false,
      };

  dynamic get index => _state['index'] ?? 0;

  /// Measured size shell used by lineStyle.
  dynamic get size =>
      _state['size'] ?? const <String, dynamic>{'width': 0.0, 'height': 0.0};

  /// Source computed: statusClass.
  dynamic get statusClass {
    final current =
        int.tryParse('${parentData is Map ? parentData['current'] : 0}') ?? 0;
    final i = int.tryParse('$index') ?? 0;
    if (current == i) return error ? 'error' : 'process';
    if (error) return 'error';
    if (current > i) return 'finish';
    return 'wait';
  }

  /// Source computed: activeStepTextColor.
  dynamic get activeStepTextColor => '#ffffff';

  /// Source computed: contentStyle.
  dynamic get contentStyle {
    final direction = parentData is Map ? parentData['direction'] : 'row';
    final isDot = parentData is Map ? parentData['dot'] == true : false;
    if (direction == 'column') {
      return <String, dynamic>{
        'marginLeft': isDot ? '2px' : '6px',
        'marginTop': isDot ? '0px' : '6px',
      };
    }
    return <String, dynamic>{
      'marginTop': isDot ? '2px' : '6px',
      'marginLeft': isDot ? '2px' : '6px',
    };
  }

  /// Source computed: itemStyleInner.
  dynamic get itemStyleInner {
    if (itemStyle is Map) return Map<String, dynamic>.from(itemStyle as Map);
    return <String, dynamic>{};
  }

  /// Source computed: lineStyle.
  dynamic get lineStyle {
    final style = <String, dynamic>{};
    final direction = parentData is Map ? parentData['direction'] : 'row';
    final w =
        num.tryParse('${size is Map ? size['width'] : 0}')?.toDouble() ?? 0;
    final h =
        num.tryParse('${size is Map ? size['height'] : 0}')?.toDouble() ?? 0;
    if (direction == 'row') {
      style['width'] = '${w}px';
      style['left'] = '${w / 2}px';
    } else {
      style['height'] = '${h}px';
    }
    final current =
        int.tryParse('${parentData is Map ? parentData['current'] : 0}') ?? 0;
    final i = int.tryParse('$index') ?? 0;
    final active = parentData is Map ? parentData['activeColor'] : '#3c9cff';
    final inactive =
        parentData is Map ? parentData['inactiveColor'] : '#969799';
    style['backgroundColor'] = i < current ? active : inactive;
    return style;
  }

  @override
  Widget build(BuildContext context) {
    final scope = _UPStepsScope.of(context);
    final index = _UPStepIndex.of(context);
    _state['index'] = index;
    _state['parentData'] = <String, dynamic>{
      'current': scope?.current ?? 0,
      'direction': scope?.direction ?? 'row',
      'activeColor': scope?.activeColor ?? '#3c9cff',
      'inactiveColor': scope?.inactiveColor ?? '#969799',
      'dot': scope?.dot ?? false,
    };
    final render = context.findRenderObject();
    if (render is RenderBox && render.hasSize) {
      _state['size'] = {
        'width': render.size.width,
        'height': render.size.height,
      };
    }
    final current = scope?.current ?? 0;
    final childLength = scope?.childLength ?? 0;
    final active =
        UPUtils.parseColor(scope?.activeColor) ?? const Color(0xFF3C9CFF);
    final inactive =
        UPUtils.parseColor(scope?.inactiveColor) ?? const Color(0xFF969799);
    final tokens = UPThemeTokens.of(context);
    final status = _statusClass(index, current);
    final isColumn = scope?.direction == 'column';
    final size = UPUtils.getPx(iconSize);
    // Source circle/dot wrappers are fixed 20x20; iconSize applies to icon mode.
    const markerBox = 20.0;
    final isDot = scope?.dot == true;

    Color statusColor;
    switch (status) {
      case 'finish':
        statusColor = active;
        break;
      case 'error':
        statusColor = tokens.error;
        break;
      case 'process':
        statusColor = isDot ? active : const Color(0x00000000);
        break;
      default:
        statusColor = inactive;
    }

    Widget marker;
    if (iconWidget != null) {
      marker = iconWidget!;
    } else if (isDot) {
      marker = Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
      );
    } else if ((scope?.activeIcon.isNotEmpty == true) ||
        (scope?.inactiveIcon.isNotEmpty == true)) {
      final name = index <= current
          ? (scope!.activeIcon.isNotEmpty
              ? scope.activeIcon
              : 'checkmark-circle-fill')
          : (scope!.inactiveIcon.isNotEmpty
              ? scope.inactiveIcon
              : 'checkmark-circle');
      marker = UPIcon(
        name: name,
        size: size,
        color: index <= current ? active : inactive,
      );
    } else {
      final circleBg = status == 'process' ? active : const Color(0x00000000);
      final borderCol = status == 'error'
          ? tokens.error
          : (status == 'finish' || status == 'process' ? active : inactive);
      marker = Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: circleBg,
          shape: BoxShape.circle,
          border: Border.all(color: borderCol, width: 1),
        ),
        child: status == 'finish'
            ? UPIcon(name: 'checkmark', size: 12, color: active)
            : status == 'error'
                ? UPIcon(name: 'close', size: 12, color: tokens.error)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: status == 'process'
                          ? const Color(0xFFFFFFFF)
                          : inactive,
                      fontSize: 11,
                      height: 1.0,
                    ),
                  ),
      );
    }

    final titleStyleSize = current == index ? 14.0 : 13.0;
    final titleColor =
        current == index ? tokens.mainColor : tokens.contentColor;

    final texts = contentWidget ??
        Column(
          crossAxisAlignment:
              isColumn ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            titleWidget ??
                Text(
                  title,
                  textAlign: isColumn ? TextAlign.left : TextAlign.center,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: titleStyleSize,
                    height: 20 / titleStyleSize,
                    fontWeight:
                        current == index ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
            if (descWidget != null || desc.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: descWidget ??
                    Text(
                      desc,
                      textAlign: isColumn ? TextAlign.left : TextAlign.center,
                      style: TextStyle(color: tokens.tipsColor, fontSize: 12),
                    ),
              ),
          ],
        );

    final showLine = index + 1 < childLength;
    final nextError = index + 1 < (scope?.errorFlags.length ?? 0) &&
        (scope?.errorFlags[index + 1] == true);
    final lineColor =
        nextError ? tokens.error : (index < current ? active : inactive);

    if (isColumn) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: markerBox,
              child: Column(
                children: [
                  SizedBox(
                    height: markerBox,
                    child: Center(child: marker),
                  ),
                  if (showLine)
                    Expanded(
                      child: Container(
                        width: 1,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: lineColor,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: isDot ? 2 : 6),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: isDot ? 0 : 6, bottom: 16),
                child: texts,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return SizedBox(
              height: markerBox,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  if (showLine)
                    Positioned(
                      left: w / 2,
                      width: w,
                      top: (markerBox - 1) / 2,
                      child: Container(height: 1, color: lineColor),
                    ),
                  marker,
                ],
              ),
            );
          },
        ),
        SizedBox(height: isDot ? 2 : 6),
        texts,
      ],
    );
  }
}
