import 'package:flutter/material.dart';

import '../utils/up_utils.dart';
import 'up_icon.dart';
import 'up_image.dart';
import 'up_text.dart';

final Expando<Map<String, dynamic>> _upAvatarState =
    Expando<Map<String, dynamic>>('upAvatarState');

/// Port of u-avatar / up-avatar.
class UPAvatar extends StatelessWidget {
  const UPAvatar({
    super.key,
    this.src = '',
    this.shape = 'circle',
    this.size = 40,
    this.mode = 'scaleToFill',
    this.text = '',
    this.bgColor = '#c0c4cc',
    this.color = '#ffffff',
    this.fontSize = 18,
    this.icon = '',
    this.mpAvatar = false,
    this.randomBgColor = false,
    this.defaultUrl = '',
    this.colorIndex = '',
    this.name = '',
    this.customStyle,
    this.onClick,
  });

  final String src;
  final String shape;
  final dynamic size;
  final String mode;
  final String text;
  final dynamic bgColor;
  final dynamic color;
  final dynamic fontSize;
  final String icon;
  final bool mpAvatar;
  final bool randomBgColor;
  final String defaultUrl;
  final dynamic colorIndex;
  final String name;
  final BoxDecoration? customStyle;

  /// Source data.
  bool get allowMp => false;
  String get avatarUrl => src;

  final ValueChanged<String>? onClick;

  static const colors = [
    '#ffb34b',
    '#f2bba9',
    '#f7a196',
    '#f18080',
    '#88a867',
    '#bfbf39',
    '#89c152',
    '#94d554',
    '#f19ec2',
    '#afaae4',
    '#e1b0df',
    '#c38cc1',
    '#72dcdc',
    '#9acdcb',
    '#77b1cc',
    '#448aca',
    '#86cefa',
    '#98d1ee',
    '#73d1f1',
    '#80a7dc',
  ];

  double _sizePx() {
    final raw = '$size';
    switch (raw) {
      case 'large':
        return 64;
      case 'default':
        return 40;
      case 'mini':
        return 28;
      default:
        final n = UPUtils.getPx(size);
        return n > 0 ? n : 40;
    }
  }

  Color _bg() {
    final useRandom = randomBgColor && (text.isNotEmpty || icon.isNotEmpty);
    if (useRandom) {
      final idx = int.tryParse('$colorIndex');
      final i = (idx == null || idx < 0 || idx > 19)
          ? (name.isNotEmpty ? name.hashCode.abs() % 20 : 0)
          : idx;
      return UPUtils.parseColor(colors[i]) ?? const Color(0xFFC0C4CC);
    }
    if (text.isNotEmpty || icon.isNotEmpty) {
      return UPUtils.parseColor(bgColor) ?? const Color(0xFFC0C4CC);
    }
    return const Color(0x00000000);
  }

  Map<String, dynamic> get _state => _upAvatarState[this] ??= <String, dynamic>{
        'initialized': false,
        'lastError': null,
        'isError': false
      };

  /// Source `init`.
  void init() {
    _state['initialized'] = true;
    _state['isError'] = false;
  }

  bool get initialized => _state['initialized'] == true;
  bool get isError => _state['isError'] == true;
  dynamic get lastError => _state['lastError'];

  /// Source `isImg`.
  bool isImg() => src.contains('/');

  /// Source `errorHandler` (host image error path).
  void errorHandler([dynamic err]) {
    _state['isError'] = true;
    _state['lastError'] = err ?? true;
  }

  /// Source `clickHandler`.
  void clickHandler([dynamic _]) => onClick?.call(name);

  /// Source computed: imageStyle.
  dynamic get imageStyle => <String, dynamic>{};

  @override
  Widget build(BuildContext context) {
    final s = _sizePx();
    final radius = shape == 'square' ? 4.0 : 1000.0;
    final fg = UPUtils.parseColor(color) ?? const Color(0xFFFFFFFF);
    final fs = UPUtils.getPx(fontSize);
    final imageSrc =
        src.isNotEmpty ? src : (defaultUrl.isNotEmpty ? defaultUrl : '');

    Widget child;
    if (icon.isNotEmpty) {
      child = UPIcon(name: icon, size: fs > 0 ? fs : 18, color: fg);
    } else if (text.isNotEmpty) {
      child = UPText(
        text: text,
        size: fs > 0 ? fs : 18,
        color: fg,
        align: 'center',
      );
    } else {
      child = UPImage(
        src: imageSrc,
        width: s,
        height: s,
        shape: shape == 'circle' ? 'circle' : 'square',
        radius: shape == 'square' ? 4 : 0,
        mode: mode,
        showLoading: false,
        showError: true,
        bgColor: '#c0c4cc',
      );
    }

    final baseDecoration = BoxDecoration(
      color: _bg(),
      borderRadius: BorderRadius.circular(radius),
    );
    final callerDecoration = customStyle;
    final decoration = callerDecoration == null
        ? baseDecoration
        : BoxDecoration(
            color: callerDecoration.gradient == null
                ? callerDecoration.color ?? baseDecoration.color
                : null,
            image: callerDecoration.image ?? baseDecoration.image,
            border: callerDecoration.border ?? baseDecoration.border,
            borderRadius: callerDecoration.shape == BoxShape.circle
                ? null
                : callerDecoration.borderRadius ?? baseDecoration.borderRadius,
            boxShadow: callerDecoration.boxShadow ?? baseDecoration.boxShadow,
            gradient: callerDecoration.gradient ?? baseDecoration.gradient,
            backgroundBlendMode: callerDecoration.backgroundBlendMode ??
                baseDecoration.backgroundBlendMode,
            shape: callerDecoration.shape,
          );

    return GestureDetector(
      onTap: () => onClick?.call(name),
      child: Container(
        width: s,
        height: s,
        alignment: Alignment.center,
        decoration: decoration,
        clipBehavior: Clip.hardEdge,
        child: child,
      ),
    );
  }
}
