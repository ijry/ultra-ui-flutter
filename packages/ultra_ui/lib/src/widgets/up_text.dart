import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';
import 'up_link.dart';

class UPText extends StatelessWidget {
  const UPText({
    super.key,
    this.type = '',
    this.show = true,
    this.text = '',
    this.prefixIcon = '',
    this.suffixIcon = '',
    this.iconStyle,
    this.mode = '',
    this.href = '',
    this.format = '',
    this.call = false,
    this.openType = '',
    this.bold = false,
    this.block = false,
    this.lines,
    this.color = '',
    this.size = 15,
    this.decoration = 'none',
    this.margin = 0,
    this.lineHeight,
    this.align = 'left',
    this.wordWrap = 'normal',
    this.flex1 = true,
    this.customStyle,
    this.child,
    this.onClick,
  });

  final String type;
  final bool show;
  final dynamic text;
  final String prefixIcon;
  final String suffixIcon;
  final dynamic iconStyle;
  final String mode;
  final String href;
  final dynamic format;
  final bool call;
  final String openType;
  final bool bold;
  final bool block;
  final dynamic lines;
  final dynamic color;
  final dynamic size;
  final String decoration;
  final dynamic margin;
  final dynamic lineHeight;
  final String align;
  final String wordWrap;
  final bool flex1;
  final BoxDecoration? customStyle;
  final Widget? child;
  final VoidCallback? onClick;

  /// Source `clickHandler`.
  void clickHandler([dynamic _]) => onClick?.call();

  /// Source `onClick` method alias.
  void onClickHandler([dynamic _]) => clickHandler(_);

  /// Source method: formatName (name encrypt).
  dynamic formatName([dynamic name]) {
    final raw = '${name ?? text}';
    if (raw.length == 2) return '${raw.substring(0, 1)}*';
    if (raw.length > 2) {
      final middle = '*' * (raw.length - 2);
      return '${raw.substring(0, 1)}$middle${raw.substring(raw.length - 1)}';
    }
    return raw;
  }

  /// Source value formatting used by mode/format.
  dynamic get displayValue {
    final raw = text;
    final modeName = mode;
    final fmt = format;
    if (modeName == 'price') {
      if (fmt is Function) return Function.apply(fmt, [raw]);
      return _priceFormat(raw, 2);
    }
    if (modeName == 'date') {
      if (fmt is Function) return Function.apply(fmt, [raw]);
      return _timeFormat(
          raw, fmt is String && fmt.isNotEmpty ? fmt : 'yyyy-mm-dd');
    }
    if (modeName == 'phone') {
      if (fmt is Function) return Function.apply(fmt, [raw]);
      final s = '$raw';
      if (fmt == 'encrypt' && s.length >= 7) {
        return '${s.substring(0, 3)}****${s.substring(7)}';
      }
      return raw;
    }
    if (modeName == 'name') {
      if (fmt is Function) return Function.apply(fmt, [raw]);
      if (fmt == 'encrypt') return formatName(raw);
      return raw;
    }
    return raw;
  }

  String _priceFormat(dynamic value, int decimals) {
    final normalized = '$value'.replaceAll(RegExp(r'[^0-9+\-Ee.]'), '');
    final number = num.tryParse(normalized) ?? 0;
    final fixed = number.toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final integer = parts.first.replaceFirstMapped(
      RegExp(r'^([+-]?)(\d+)$'),
      (match) {
        final digits = match.group(2)!;
        return '${match.group(1)}${digits.replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ',',
        )}';
      },
    );
    return parts.length == 1 ? integer : '$integer.${parts[1]}';
  }

  String _timeFormat(dynamic value, String format) {
    final date = _parseSourceDate(value);
    final values = <String, String>{
      'y': '${date.year}',
      'm': date.month.toString().padLeft(2, '0'),
      'd': date.day.toString().padLeft(2, '0'),
      'h': date.hour.toString().padLeft(2, '0'),
      'M': date.minute.toString().padLeft(2, '0'),
      's': date.second.toString().padLeft(2, '0'),
    };

    var result = format;
    for (final key in ['y', 'm', 'd', 'h', 'M', 's']) {
      final match = RegExp('$key+').firstMatch(result);
      if (match == null) continue;
      final token = match.group(0)!;
      final start = key == 'y' && token.length == 2 ? 2 : 0;
      result = result.replaceFirst(token, values[key]!.substring(start));
    }
    return result;
  }

  DateTime _parseSourceDate(dynamic value) {
    final raw = '$value'.trim();
    if (raw.isEmpty || value == null || value == false || value == 0) {
      return DateTime.now();
    }
    if (RegExp(r'^\d{10}$').hasMatch(raw)) {
      return DateTime.fromMillisecondsSinceEpoch(int.parse(raw) * 1000);
    }
    if (value is String && RegExp(r'^\d+$').hasMatch(raw)) {
      return DateTime.fromMillisecondsSinceEpoch(int.parse(raw));
    }
    return DateTime.tryParse(raw) ??
        DateTime.tryParse(raw.replaceAll('/', '-')) ??
        DateTime.now();
  }

  /// Source computed: isNvue.
  dynamic get isNvue => false;

  /// Source computed: isMp.
  dynamic get isMp => false;

  /// Source computed: wrapStyle.
  dynamic get wrapStyle {
    final style = <String, dynamic>{
      'margin': margin,
      'justifyContent': align == 'left'
          ? 'flex-start'
          : (align == 'center' ? 'center' : 'flex-end'),
    };
    if (flex1) {
      style['flex'] = 1;
      style['width'] = '100%';
    }
    return style;
  }

  /// Source computed: valueStyle.
  dynamic get valueStyle {
    final style = <String, dynamic>{
      'textDecoration': decoration,
      'fontWeight': bold ? 'bold' : 'normal',
      'wordWrap': wordWrap,
      'fontSize': UPUtils.addUnit(size),
    };
    if (type.isEmpty) {
      style['color'] =
          (color != null && '$color'.trim().isNotEmpty) ? color : '#606266';
    }
    if (lineHeight != null && '$lineHeight'.trim().isNotEmpty) {
      style['lineHeight'] = UPUtils.addUnit(lineHeight);
    }
    if (!isNvue && block) style['display'] = 'block';
    return style;
  }

  Map<String, dynamic> get _iconStyleMap {
    if (iconStyle is Map) {
      return (iconStyle as Map).map(
        (key, value) => MapEntry('$key', value),
      );
    }
    if (iconStyle is! String) return const <String, dynamic>{};

    final style = <String, dynamic>{};
    for (final declaration in (iconStyle as String).split(';')) {
      final separator = declaration.indexOf(':');
      if (separator < 0) continue;
      final key = declaration.substring(0, separator).trim();
      final value = declaration.substring(separator + 1).trim();
      if (key.isEmpty || value.isEmpty) continue;
      style[switch (key) {
        'font-size' => 'fontSize',
        'font-weight' => 'fontWeight',
        _ => key,
      }] = value;
    }
    return style;
  }

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();
    final tokens = UPThemeTokens.of(context);
    final fontSize = UPUtils.getPx(size);
    Color textColor = tokens.contentColor;
    if (type.isNotEmpty) {
      textColor = tokens.typeColor(type);
    }
    final parsed = UPUtils.parseColor(color);
    if (parsed != null) textColor = parsed;

    final iconStyles = _iconStyleMap;
    final iconSize = iconStyles['fontSize'] ??
        iconStyles['font-size'] ??
        iconStyles['size'] ??
        fontSize;
    final iconColor = iconStyles['color'] ?? textColor;
    final iconWeight = iconStyles['fontWeight'] ?? iconStyles['font-weight'];
    final numericIconWeight = num.tryParse('$iconWeight');
    final iconBold = iconStyles['bold'] == true ||
        '$iconWeight'.toLowerCase() == 'bold' ||
        (numericIconWeight != null && numericIconWeight >= 600);
    final iconTop = iconStyles['top'] ?? 0;

    TextAlign textAlign;
    switch (align) {
      case 'center':
        textAlign = TextAlign.center;
        break;
      case 'right':
        textAlign = TextAlign.right;
        break;
      default:
        textAlign = TextAlign.left;
    }

    TextDecoration dec;
    switch (decoration) {
      case 'underline':
        dec = TextDecoration.underline;
        break;
      case 'line-through':
        dec = TextDecoration.lineThrough;
        break;
      default:
        dec = TextDecoration.none;
    }

    final maxLines =
        lines == null || '$lines'.isEmpty ? null : int.tryParse('$lines');

    final displayText = displayValue == null ? '' : '$displayValue';
    final textWidget = Text(
      child == null ? displayText : '',
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines == null ? TextOverflow.visible : TextOverflow.ellipsis,
      style: TextStyle(
        color: textColor,
        fontSize: fontSize,
        height: lineHeight == null || '$lineHeight'.isEmpty
            ? null
            : UPUtils.getPx(lineHeight) / fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        decoration: dec,
      ),
    );

    Widget valueWidget = mode == 'link'
        ? UPLink(
            text: displayText,
            href: href,
            underLine: true,
            customStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          )
        : child ?? textWidget;
    if (mode != 'link' && customStyle != null) {
      valueWidget = DecoratedBox(
        key: const ValueKey('up-text-value'),
        decoration: customStyle!,
        child: valueWidget,
      );
    }

    Widget priceWidget = Text(
      '￥',
      style: TextStyle(
        color: textColor,
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        decoration: dec,
      ),
    );
    if (mode == 'price' && customStyle != null) {
      priceWidget = DecoratedBox(
        key: const ValueKey('up-text-price'),
        decoration: customStyle!,
        child: priceWidget,
      );
    }

    final row = Row(
      mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (mode == 'price') priceWidget,
        if (prefixIcon.isNotEmpty) ...[
          UPIcon(
            name: prefixIcon,
            size: iconSize,
            color: iconColor,
            bold: iconBold,
            top: iconTop,
          ),
          const SizedBox(width: 4),
        ],
        Flexible(child: valueWidget),
        if (suffixIcon.isNotEmpty) ...[
          const SizedBox(width: 4),
          UPIcon(
            name: suffixIcon,
            size: iconSize,
            color: iconColor,
            bold: iconBold,
            top: iconTop,
          ),
        ],
      ],
    );

    Widget body = GestureDetector(
      onTap: onClick,
      child: Padding(
        padding: EdgeInsets.all(UPUtils.getPx(margin)),
        child: row,
      ),
    );

    return body;
  }
}
