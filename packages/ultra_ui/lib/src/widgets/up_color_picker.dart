import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_button.dart';
import 'up_popup.dart';
import 'up_subsection.dart';

/// Port of u-color-picker / up-color-picker.
///
/// Solid HSV (SV panel + hue bar) + linear gradient mode.
class UPColorPicker extends StatefulWidget {
  const UPColorPicker({
    super.key,
    this.modelValue = '#ff0000',
    this.value,
    this.commonColors = const [],
    this.show = false,
    this.onUpdateShow,
    this.onChange,
    this.onUpdateValue,
    this.onUpdateModelValue,
    this.onConfirm,
    this.onClose,
    this.onClosed,
    this.child,
    this.customStyle,
  });

  final String modelValue;
  final String? value;
  final List commonColors;
  final bool show;
  final ValueChanged<bool>? onUpdateShow;
  final ValueChanged<String>? onChange;

  /// Source update:value alias.
  final ValueChanged<String>? onUpdateValue;

  /// Source update:modelValue alias.
  final ValueChanged<String>? onUpdateModelValue;
  final ValueChanged<String>? onConfirm;
  final VoidCallback? onClose;

  /// Source emit `closed` — the nested popup finished its leave
  /// animation, unlike `close` which fires at dismissal.
  final VoidCallback? onClosed;

  /// Source default slot: the tap target that opens the picker. The source
  /// renders it inline and puts the picker itself in a `u-popup`, so without it
  /// there is no way to open the picker other than driving `show` from outside.
  final Widget? child;

  final BoxDecoration? customStyle;

  /// Source data default: previewType.
  dynamic get previewType => 'solid';

  @override
  State<UPColorPicker> createState() => UPColorPickerState();
}

class UPColorPickerState extends State<UPColorPicker> {
  /// Source touch phase for SV/hue/alpha/direction gestures.
  String touchPhase = 'idle';

  /// Source method: updateSolidColor.
  void updateSolidColor([dynamic raw]) {
    if (raw != null && '$raw'.trim().isNotEmpty) {
      setValue('$raw');
      return;
    }
    _emitSolid(hsv);
    setState(() {});
  }

  /// Source method: updateGradientColor.
  void updateGradientColor([dynamic raw]) {
    if (raw is Map) {
      final color = raw['color'];
      final percent = raw['percent'] ?? raw['pos'];
      final index = raw['index'] ?? editingGradientIndex;
      if (index is int && index >= 0 && index < gradientColors.length) {
        setState(() {
          gradientColors[index] = _GradStop(
            color: color != null ? '$color' : gradientColors[index].color,
            pos: percent == null
                ? gradientColors[index].pos
                : (num.tryParse('$percent') ?? gradientColors[index].pos)
                    .toDouble(),
          );
          editingGradientIndex = index;
        });
      }
    } else if (raw != null && '$raw'.trim().isNotEmpty) {
      setState(() {
        final i = editingGradientIndex.clamp(0, gradientColors.length - 1);
        gradientColors[i] =
            _GradStop(color: '$raw', pos: gradientColors[i].pos);
      });
    }
    _emitGradient();
  }

  /// Source method: selectCommonColor.
  void selectCommonColor([dynamic color]) {
    if (color == null || '$color'.trim().isEmpty) return;
    if (colorTypeIndex == 0) {
      setValue('$color');
    } else {
      updateGradientColor(color);
    }
  }

  late HSVColor hsv;
  late String current;
  int colorTypeIndex = 0; // 0 solid, 1 gradient
  final gradientColors = <_GradStop>[
    _GradStop(color: '#ff0000', pos: 0),
    _GradStop(color: '#0000ff', pos: 1),
  ];
  double directionDeg = 90;
  int editingGradientIndex = 0;

  /// Public for tests / host control.
  String get colorValue => current;

  /// Source data.
  String get currentColor => current;
  double lightness = 0.5;
  double alphaPosition = 1;
  double huePosition = 0;
  int draggingPointerIndex = -1;
  bool showDirectionPicker = false;
  HSVColor get hsvValue => hsv;
  bool? _localShow;

  /// Pending `closed` emission.
  Timer? _closedTimer;

  bool get isShown => _localShow ?? widget.show;

  /// Source retained direction/state fields.
  double get currentDirection => directionDeg;
  Map get solidColorState => {
        'hex': current,
        'hsv': {
          'h': hsv.hue,
          's': hsv.saturation,
          'v': hsv.value,
        },
      };
  Map get gradientColorState => {
        'colors': [for (final g in gradientColors) g.color],
        'positions': [for (final g in gradientColors) g.pos],
        'direction': directionDeg,
      };
  Map get saturationPosition => {
        'x': hsv.saturation,
        'y': 1 - hsv.value,
      };
  Map get directionPointer => {
        'angle': directionDeg,
      };
  List get gradientDirections => const [
        {'label': '→', 'value': 90},
        {'label': '↓', 'value': 180},
        {'label': '←', 'value': 270},
        {'label': '↑', 'value': 0},
      ];

  void open({bool emit = true}) {
    if (isShown) return;
    setState(() => _localShow = true);
    if (emit) widget.onUpdateShow?.call(true);
  }

  /// Source `closed` — the source wraps this component in `u-popup`, whose
  /// leave animation runs for the popup default of 300ms before emitting.
  /// This port renders inline, so the timing is reproduced directly.
  void _emitClosed() {
    if (widget.onClosed == null) return;
    _closedTimer?.cancel();
    _closedTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) widget.onClosed?.call();
    });
  }

  @override
  void dispose() {
    _closedTimer?.cancel();
    super.dispose();
  }

  void close({bool emit = true}) {
    if (!isShown) return;
    setState(() => _localShow = false);
    if (emit) {
      widget.onUpdateShow?.call(false);
      widget.onClose?.call();
    }
    _emitClosed();
  }

  void toggle({bool emit = true}) {
    if (isShown) {
      close(emit: emit);
    } else {
      open(emit: emit);
    }
  }

  void setValue(String raw) {
    _fromValue(raw);
    setState(() {});
    widget.onChange?.call(current);
    widget.onUpdateValue?.call(current);
    widget.onUpdateModelValue?.call(current);
  }

  /// Source display helpers.
  String displayColor([dynamic _]) => current;
  Map gradientStyle([dynamic _]) => {
        'colors': [for (final g in gradientColors) g.color],
        'direction': directionDeg,
      };

  /// Source saturation/hue touch helpers.
  void initDirectionPointer([dynamic _]) =>
      setDirectionPointerByAngle(directionDeg);
  void onSaturationTouchStart([Offset? local, Size? size]) {
    if (local != null && size != null) _onSvLocal(local, size);
  }

  void onSaturationTouchMove([Offset? local, Size? size]) {
    if (local != null && size != null) _onSvLocal(local, size);
  }

  void onSaturationTouchEnd([dynamic _]) {
    touchPhase = 'saturation-end';
  }

  void updateSaturationPosition([Offset? local, Size? size]) {
    if (local != null && size != null) _onSvLocal(local, size);
  }

  void onHueTouchStart([Offset? local, double? width]) {
    if (local != null && width != null) _onHueLocal(local, width);
  }

  void onHueTouchMove([Offset? local, double? width]) {
    if (local != null && width != null) _onHueLocal(local, width);
  }

  void onHueTouchEnd([dynamic _]) {
    touchPhase = 'hue-end';
  }

  void updateHuePosition([Offset? local, double? width]) {
    if (local != null && width != null) _onHueLocal(local, width);
  }

  /// Source alpha / direction / hsl helpers.
  void initAlphaPosition([dynamic _]) {
    alphaPosition = hsv.alpha.clamp(0.0, 1.0);
  }

  void updateAlphaPosition([dynamic local, dynamic width]) {
    if (local is num && width is num) {
      _onAlphaLocal(local.toDouble(), width.toDouble());
      return;
    }
    if (local is Offset && width is num) {
      _onAlphaLocal(local.dx, width.toDouble());
      return;
    }
    if (local is Map) {
      final x = num.tryParse(
          '${local['x'] ?? local['dx'] ?? local['clientX'] ?? ''}');
      final w = width is num
          ? width.toDouble()
          : (num.tryParse('${local['width'] ?? ''}') ?? 0).toDouble();
      if (x != null && w > 0) _onAlphaLocal(x.toDouble(), w);
    }
  }

  void onAlphaTouchStart([dynamic local, dynamic width]) {
    updateAlphaPosition(local, width);
  }

  void onAlphaTouchMove([dynamic local, dynamic width]) {
    updateAlphaPosition(local, width);
  }

  void onAlphaTouchEnd([dynamic _]) {
    touchPhase = 'alpha-end';
  }

  void _onAlphaLocal(double x, double width) {
    if (width <= 0) return;
    final a = (x / width).clamp(0.0, 1.0);
    setAlpha(a);
  }

  void setAlpha(double alpha) {
    final a = alpha.clamp(0.0, 1.0);
    final next = hsv.withAlpha(a);
    alphaPosition = a;
    if (colorTypeIndex == 0) {
      _emitSolid(next);
    } else {
      setState(() => hsv = next);
      _emitGradient();
    }
  }

  void onDirectionTouchStart([dynamic _]) => initDirectionPointer();
  void onDirectionTouchMove([double? angle]) {
    if (angle != null) setDirectionPointerByAngle(angle);
  }

  void onDirectionTouchEnd([dynamic _]) {
    touchPhase = 'direction-end';
  }

  void updateDirection([dynamic direction]) {
    if (direction is num) {
      setDirectionPointerByAngle(direction.toDouble());
    } else if (direction != null) {
      setDirectionByName('$direction');
    }
  }

  void updateGradientDirection([dynamic direction]) =>
      updateDirection(direction);
  void confirmDirection([dynamic direction]) => updateDirection(direction);

  void onPointerTouchStart([Offset? local, Size? size]) =>
      onSaturationTouchStart(local, size);
  void onPointerTouchMove([Offset? local, Size? size]) =>
      onSaturationTouchMove(local, size);
  void onPointerTouchEnd([dynamic _]) => onSaturationTouchEnd();

  double round(num value, [int digits = 0]) {
    if (digits <= 0) return value.roundToDouble();
    final p = 10.0;
    var factor = 1.0;
    for (var i = 0; i < digits; i++) {
      factor *= p;
    }
    return (value * factor).round() / factor;
  }

  double hue2rgb(double p, double q, double t) {
    var tt = t;
    if (tt < 0) tt += 1;
    if (tt > 1) tt -= 1;
    if (tt < 1 / 6) return p + (q - p) * 6 * tt;
    if (tt < 1 / 2) return q;
    if (tt < 2 / 3) return p + (q - p) * (2 / 3 - tt) * 6;
    return p;
  }

  Map hslToRgb(num h, num s, num l) {
    final hh = (h.toDouble() % 360) / 360;
    final ss = s.toDouble().clamp(0.0, 1.0);
    final ll = l.toDouble().clamp(0.0, 1.0);
    double r, g, b;
    if (ss == 0) {
      r = g = b = ll;
    } else {
      final q = ll < 0.5 ? ll * (1 + ss) : ll + ss - ll * ss;
      final p = 2 * ll - q;
      r = hue2rgb(p, q, hh + 1 / 3);
      g = hue2rgb(p, q, hh);
      b = hue2rgb(p, q, hh - 1 / 3);
    }
    return {
      'r': (r * 255).round(),
      'g': (g * 255).round(),
      'b': (b * 255).round(),
    };
  }

  /// Source `changeColorType`.
  void changeColorType(int index) {
    setState(() => colorTypeIndex = index == 1 ? 1 : 0);
    if (colorTypeIndex == 0) {
      _emitSolid(hsv);
    } else {
      _emitGradient();
    }
  }

  /// Source `addGradientColor`.
  void addGradientColor([String? color]) {
    if (gradientColors.length >= 5) return;
    setState(() {
      gradientColors.add(
        _GradStop(color: color ?? _toHex(hsv.toColor()), pos: 1),
      );
      // re-normalize positions roughly
      if (gradientColors.length > 1) {
        for (var i = 0; i < gradientColors.length; i++) {
          gradientColors[i] = _GradStop(
            color: gradientColors[i].color,
            pos: i / (gradientColors.length - 1),
          );
        }
      }
      editingGradientIndex = gradientColors.length - 1;
    });
    _emitGradient();
  }

  /// Source `removeGradientColor`.
  void removeGradientColor([int? index]) {
    if (gradientColors.length <= 2) return;
    final i = index ?? editingGradientIndex;
    if (i < 0 || i >= gradientColors.length) return;
    setState(() {
      gradientColors.removeAt(i);
      editingGradientIndex =
          editingGradientIndex.clamp(0, gradientColors.length - 1);
    });
    _emitGradient();
  }

  void confirm() {
    widget.onConfirm?.call(current);
    close();
  }

  /// Source `initColor`.
  void initColor([String? raw]) {
    _fromValue(raw ?? widget.value ?? widget.modelValue);
    setState(() {});
  }

  /// Source `openColorPickerForGradient`.
  void openColorPickerForGradient(int index) {
    if (index < 0 || index >= gradientColors.length) return;
    setState(() {
      editingGradientIndex = index;
      colorTypeIndex = 0;
      final c = UPUtils.parseColor(gradientColors[index].color);
      if (c != null) {
        hsv = HSVColor.fromColor(c);
        current = gradientColors[index].color;
      }
    });
  }

  /// Source direction helpers.
  double getDirectionAngle([String? direction]) {
    switch (direction ?? 'to bottom') {
      case 'to right':
        return 0;
      case 'to bottom':
        return 90;
      case 'to left':
        return 180;
      case 'to top':
        return 270;
      case 'to bottom right':
        return 45;
      case 'to bottom left':
        return 135;
      case 'to top left':
        return 225;
      case 'to top right':
        return 315;
      default:
        return directionDeg;
    }
  }

  void setDirectionPointerByAngle(double angle) {
    setState(() => directionDeg = angle % 360);
    if (colorTypeIndex == 1) _emitGradient();
  }

  void setDirectionByName(String direction) {
    setDirectionPointerByAngle(getDirectionAngle(direction));
  }

  /// Source parse helpers.
  void parseSolidColor(String color) {
    setValue(color);
  }

  void parseGradientColor(String gradient) {
    setValue(gradient);
  }

  double getGradientPointerPosition(int index) {
    if (index < 0 || index >= gradientColors.length) return 0;
    return gradientColors[index].pos;
  }

  static const defaults = [
    '#ff0000',
    '#ff7a00',
    '#ffd100',
    '#19be6b',
    '#2979ff',
    '#8a2be2',
    '#000000',
    '#ffffff',
    '#909399',
    '#fa3534',
  ];

  @override
  void initState() {
    super.initState();
    _fromValue(widget.value ?? widget.modelValue);
  }

  @override
  void didUpdateWidget(covariant UPColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.show != widget.show) {
      _localShow = null;
    }
    final next = widget.value ?? widget.modelValue;
    if (next != current) _fromValue(next);
  }

  void _fromValue(String raw) {
    if (raw.trim().toLowerCase().startsWith('linear-gradient')) {
      colorTypeIndex = 1;
      current = raw;
      final deg = RegExp(r'([0-9.]+)deg').firstMatch(raw);
      if (deg != null) directionDeg = double.tryParse(deg.group(1)!) ?? 90;
      final stops = RegExp(
        r'(#[0-9a-fA-F]{3,8})\s+([0-9.]+)%',
      ).allMatches(raw).toList();
      if (stops.isNotEmpty) {
        gradientColors
          ..clear()
          ..addAll(
            stops.map(
              (m) => _GradStop(
                color: m.group(1)!,
                pos: (double.tryParse(m.group(2)!) ?? 0) / 100,
              ),
            ),
          );
      }
      final c = UPUtils.parseColor(gradientColors.first.color) ??
          const Color(0xFFFF0000);
      hsv = HSVColor.fromColor(c);
      return;
    }
    colorTypeIndex = 0;
    final c = UPUtils.parseColor(raw) ?? const Color(0xFFFF0000);
    hsv = HSVColor.fromColor(c);
    current = _toHex(c);
  }

  String _toHex(Color c) {
    final r = c.red.toRadixString(16).padLeft(2, '0');
    final g = c.green.toRadixString(16).padLeft(2, '0');
    final b = c.blue.toRadixString(16).padLeft(2, '0');
    return '#$r$g$b';
  }

  String _gradientCss() {
    final parts = gradientColors
        .map((e) => '${e.color} ${(e.pos * 100).toStringAsFixed(0)}%')
        .join(', ');
    return 'linear-gradient(${directionDeg.toStringAsFixed(0)}deg, $parts)';
  }

  void _emitSolid(HSVColor next) {
    setState(() {
      hsv = next;
      current = _toHex(next.toColor());
    });
    widget.onChange?.call(current);
    widget.onUpdateValue?.call(current);
    widget.onUpdateModelValue?.call(current);
  }

  void _emitGradient() {
    // Keep editing stop color in sync with current HSV when in gradient mode.
    if (editingGradientIndex >= 0 &&
        editingGradientIndex < gradientColors.length) {
      gradientColors[editingGradientIndex] = _GradStop(
        color: _toHex(hsv.toColor()),
        pos: gradientColors[editingGradientIndex].pos,
      );
    }
    setState(() => current = _gradientCss());
    widget.onChange?.call(current);
    widget.onUpdateValue?.call(current);
    widget.onUpdateModelValue?.call(current);
  }

  void setHue(double hue) {
    final next = hsv.withHue(hue.clamp(0, 360));
    if (colorTypeIndex == 0) {
      _emitSolid(next);
    } else {
      setState(() => hsv = next);
      _emitGradient();
    }
  }

  void setSV(double saturation, double value) {
    final next = hsv
        .withSaturation(saturation.clamp(0.0, 1.0))
        .withValue(value.clamp(0.0, 1.0));
    if (colorTypeIndex == 0) {
      _emitSolid(next);
    } else {
      setState(() => hsv = next);
      _emitGradient();
    }
  }

  void _onSvLocal(Offset local, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final s = (local.dx / size.width).clamp(0.0, 1.0);
    final v = 1 - (local.dy / size.height).clamp(0.0, 1.0);
    setSV(s, v);
  }

  void _onHueLocal(Offset local, double width) {
    if (width <= 0) return;
    final hue = (local.dx / width).clamp(0.0, 1.0) * 360;
    setHue(hue);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final colors = widget.commonColors.isEmpty ? defaults : widget.commonColors;
    final preview = colorTypeIndex == 0
        ? BoxDecoration(
            color: hsv.toColor(),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: tokens.borderColor),
          )
        : BoxDecoration(
            gradient: LinearGradient(
              begin: _begin,
              end: _end,
              colors: [
                for (final s in gradientColors)
                  UPUtils.parseColor(s.color) ?? Colors.red,
              ],
              stops: [for (final s in gradientColors) s.pos.clamp(0.0, 1.0)],
            ),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: tokens.borderColor),
          );

    final body = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.cardBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: const BoxConstraints(maxHeight: 640),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '选择颜色',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            UPSubsection(
              list: const [
                {'name': '纯色'},
                {'name': '渐变'},
              ],
              current: colorTypeIndex,
              onChange: (i) {
                setState(() {
                  colorTypeIndex = i;
                  if (i == 0) {
                    current = _toHex(hsv.toColor());
                  } else {
                    current = _gradientCss();
                  }
                });
                widget.onChange?.call(current);
                widget.onUpdateValue?.call(current);
                widget.onUpdateModelValue?.call(current);
              },
            ),
            const SizedBox(height: 12),
            Container(
              height: 40,
              decoration: preview,
              alignment: Alignment.center,
              child: Text(
                current.length > 28 ? '${current.substring(0, 28)}…' : current,
                style: TextStyle(
                  color: hsv.value < 0.5 ? Colors.white : Colors.black,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (colorTypeIndex == 1) ...[
              _gradientTrack(tokens),
              const SizedBox(height: 8),
              Row(
                children: [
                  UPButton(
                    text: '添加颜色',
                    type: 'primary',
                    size: 'mini',
                    plain: true,
                    onClick: () {
                      setState(() {
                        gradientColors.add(
                          _GradStop(color: _toHex(hsv.toColor()), pos: 0.5),
                        );
                        gradientColors.sort((a, b) => a.pos.compareTo(b.pos));
                        editingGradientIndex = gradientColors.length - 1;
                      });
                      _emitGradient();
                    },
                  ),
                  const SizedBox(width: 12),
                  Text('方向: ${directionDeg.toStringAsFixed(0)}°',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
              Slider(
                value: directionDeg.clamp(0, 360),
                min: 0,
                max: 360,
                onChanged: (v) {
                  setState(() => directionDeg = v);
                  _emitGradient();
                },
              ),
            ],
            // SV panel
            LayoutBuilder(
              builder: (context, c) {
                final size = Size(c.maxWidth, 120);
                return GestureDetector(
                  onPanDown: (d) => _onSvLocal(d.localPosition, size),
                  onPanUpdate: (d) => _onSvLocal(d.localPosition, size),
                  onTapDown: (d) => _onSvLocal(d.localPosition, size),
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: Stack(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor(),
                              ],
                            ),
                          ),
                          child: const SizedBox.expand(),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0x00000000), Color(0xFF000000)],
                            ),
                          ),
                          child: const SizedBox.expand(),
                        ),
                        Positioned(
                          left: (hsv.saturation * size.width - 8)
                              .clamp(0.0, size.width - 16),
                          top: ((1 - hsv.value) * size.height - 8)
                              .clamp(0.0, size.height - 16),
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hsv.toColor(),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0x55000000), blurRadius: 2),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // Hue bar
            LayoutBuilder(
              builder: (context, c) {
                final width = c.maxWidth;
                return GestureDetector(
                  onPanDown: (d) => _onHueLocal(d.localPosition, width),
                  onPanUpdate: (d) => _onHueLocal(d.localPosition, width),
                  onTapDown: (d) => _onHueLocal(d.localPosition, width),
                  child: SizedBox(
                    height: 18,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Container(
                          height: 12,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFF0000),
                                Color(0xFFFFFF00),
                                Color(0xFF00FF00),
                                Color(0xFF00FFFF),
                                Color(0xFF0000FF),
                                Color(0xFFFF00FF),
                                Color(0xFFFF0000),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: ((hsv.hue / 360) * width - 7)
                              .clamp(0.0, math.max(0.0, width - 14)),
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color:
                                  HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor(),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0x55000000), blurRadius: 2),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _slider('色相', hsv.hue / 360, (v) => setHue(v * 360)),
            _slider('饱和度', hsv.saturation, (v) => setSV(v, hsv.value)),
            _slider('亮度', hsv.value, (v) => setSV(hsv.saturation, v)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: colors.map((c) {
                final hex = '$c';
                return GestureDetector(
                  onTap: () {
                    if (colorTypeIndex == 0) {
                      _fromValue(hex);
                      setState(() {});
                      widget.onChange?.call(current);
                      widget.onUpdateValue?.call(current);
                      widget.onUpdateModelValue?.call(current);
                    } else {
                      setState(() {
                        if (gradientColors.isNotEmpty) {
                          final idx = editingGradientIndex.clamp(
                            0,
                            gradientColors.length - 1,
                          );
                          gradientColors[idx] = _GradStop(
                              color: hex, pos: gradientColors[idx].pos);
                          final parsed = UPUtils.parseColor(hex) ??
                              const Color(0xFFFF0000);
                          hsv = HSVColor.fromColor(parsed);
                        }
                      });
                      _emitGradient();
                    }
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: UPUtils.parseColor(hex) ?? Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: tokens.borderColor),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: UPButton(
                    text: '取消',
                    type: 'info',
                    plain: true,
                    onClick: () => close(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: UPButton(
                    text: '确定',
                    type: 'primary',
                    onClick: () {
                      final val = colorTypeIndex == 0
                          ? _toHex(hsv.toColor())
                          : _gradientCss();
                      current = val;
                      widget.onConfirm?.call(val);
                      close(emit: true);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // No trigger: render the picker where it is placed, which is what callers
    // driving `show` from the outside rely on.
    if (widget.child == null) {
      if (!isShown) return body;
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => close(),
              child: Container(color: const Color(0x66000000)),
            ),
          ),
          Center(
              child: Padding(padding: const EdgeInsets.all(24), child: body)),
        ],
      );
    }

    // Source keeps the trigger inline and puts the picker in a `u-popup`, so the
    // trigger stays visible and the overlay covers the page rather than just the
    // trigger's own box. UPPopup already routes its mask to the root overlay,
    // so it is used here instead of a local Stack, which a Stack sized to the
    // trigger could not do.
    //
    // The popup is mounted only while shown: UPPopup keeps a hidden child laid
    // out (slid offscreen) rather than unmounted, so keeping it always mounted
    // made the *closed* picker reserve the panel's full height below the
    // trigger and push the rest of the page down.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          // Source binds `@click="show = true"` on the wrapper.
          onTap: () => open(),
          behavior: HitTestBehavior.opaque,
          child: widget.child,
        ),
        if (isShown)
          UPPopup(
            show: true,
            mode: 'bottom',
            round: '10',
            closeOnClickOverlay: true,
            onClose: () => close(),
            child: body,
          ),
      ],
    );
  }

  Alignment get _begin {
    final rad = directionDeg * math.pi / 180;
    return Alignment(math.cos(rad + math.pi), math.sin(rad + math.pi));
  }

  Alignment get _end {
    final rad = directionDeg * math.pi / 180;
    return Alignment(math.cos(rad), math.sin(rad));
  }

  Widget _gradientTrack(UPThemeTokens tokens) {
    return SizedBox(
      height: 28,
      child: LayoutBuilder(
        builder: (context, c) {
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    colors: [
                      for (final s in gradientColors)
                        UPUtils.parseColor(s.color) ?? Colors.red,
                    ],
                    stops: [
                      for (final s in gradientColors) s.pos.clamp(0.0, 1.0)
                    ],
                  ),
                  border: Border.all(color: tokens.borderColor),
                ),
              ),
              for (var i = 0; i < gradientColors.length; i++)
                Positioned(
                  left:
                      gradientColors[i].pos.clamp(0.0, 1.0) * (c.maxWidth - 16),
                  child: GestureDetector(
                    onHorizontalDragUpdate: (d) {
                      setState(() {
                        final next =
                            (gradientColors[i].pos + d.delta.dx / c.maxWidth)
                                .clamp(0.0, 1.0);
                        gradientColors[i] = _GradStop(
                            color: gradientColors[i].color, pos: next);
                        gradientColors.sort((a, b) => a.pos.compareTo(b.pos));
                      });
                      _emitGradient();
                    },
                    onTap: () {
                      setState(() {
                        editingGradientIndex = i;
                        final parsed =
                            UPUtils.parseColor(gradientColors[i].color) ??
                                const Color(0xFFFF0000);
                        hsv = HSVColor.fromColor(parsed);
                      });
                    },
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: UPUtils.parseColor(gradientColors[i].color) ??
                            Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: editingGradientIndex == i
                              ? tokens.primary
                              : Colors.white,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Color(0x33000000), blurRadius: 2),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _slider(String label, double value, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(0.0, 1.0),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _GradStop {
  _GradStop({required this.color, required this.pos});
  final String color;
  final double pos;
}
