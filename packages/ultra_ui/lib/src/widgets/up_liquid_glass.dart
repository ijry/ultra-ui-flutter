import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';

/// iOS-style "Liquid Glass" surface for Flutter.
///
/// Mirrors the shared `glass` contract on `UPFlex` (see
/// `contracts/up-flex.contract.json`): [variant] is `regular` / `clear`,
/// [tint] washes a colour over the blur, and [interactive] adds the press
/// response iOS gives to controls that sit on glass.
///
/// Rendering is deliberately an *approximation* of UIKit/SwiftUI:
///   * shape uses a **continuous-curvature squircle** — the signature iOS
///     "superellipse" corner. Flutter's `RoundedSuperellipseBorder` fills
///     through `Canvas.drawRSuperellipse`, which the Skia backend does not
///     render (this app pins Skia for the H.264 SurfaceTexture preview, so a
///     superellipse would come out blank). We instead build the same shape with
///     a `Path` of cubic béziers, which Skia draws fine.
///   * the fill **and** the 1px specular rim are painted with a `CustomPainter`
///     via `Canvas.drawPath`. This deliberately avoids `ShapeDecoration(shape:
///     <custom border>) + gradient`: on the Skia backend that combination
///     paints as a solid red rectangle. Hand-rolling the paint avoids it.
///   * the backdrop is blurred, and [refraction] very slightly magnifies it
///     to mimic light bending through the material's edge;
///   * a specular rim (bright top, dim bottom) plus an inner bottom shade
///     fake the thickness that makes the material read as glass.
///
/// Backdrop blur costs a per-frame GPU pass: leave [refraction] off and keep
/// blurred surfaces out of long scrolling lists.
class UPLiquidGlass extends StatelessWidget {
  const UPLiquidGlass({
    super.key,
    required this.child,
    this.variant = 'regular',
    this.tint,
    this.interactive = false,
    this.cornerRadius,
    this.blur,
    this.gradient,
    this.refraction = 0,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.width,
    this.height,
    this.shadow = true,
    this.onTap,
  });

  final Widget child;

  /// `regular` (tinted) or `clear` (nearly pure blur).
  final String variant;

  /// Colour washed over the blur; falls back to the theme glass fill.
  final Color? tint;

  /// Adds press feedback (slight scale + rim brightening).
  final bool interactive;

  /// Defaults to a control-sized squircle (22px).
  final dynamic cornerRadius;

  /// Backdrop blur sigma; defaults per [variant].
  final double? blur;

  /// Painted over the fill — the tinted-glass wash (e.g. a primary-colour
  /// diagonal) that gives an otherwise neutral surface its accent.
  final Gradient? gradient;

  /// Extra backdrop magnification (1.0 = none). Cheap way to suggest the
  /// refraction at the material's edge.
  final double refraction;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool shadow;
  final VoidCallback? onTap;

  bool get _isClear => variant == 'clear';

  double get _radius => cornerRadius == null
      ? 22
      : UPUtils.getPx(cornerRadius).clamp(0, 1000).toDouble();

  double get _blur => blur ?? (_isClear ? 26 : 20);

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final radius = _radius;

    final baseTint = tint ?? tokens.glassBgColor;
    final fill = _isClear
        ? baseTint.withValues(alpha: baseTint.a * 0.4)
        : baseTint;

    // iOS lights the top edge and lets the bottom fall into shade; in dark
    // mode the "light" is a faint sheen rather than white.
    final rimTop = isDark
        ? Colors.white.withValues(alpha: 0.32)
        : tokens.glassBorderColor;
    final rimBottom = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.16);
    final innerShade = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : const Color(0x1A0F1B2E);

    // The squircle fill + (optional) drop shadow are painted with a
    // CustomPainter using `Canvas.drawPath`. This deliberately avoids
    // `ShapeDecoration` together with a `gradient`: on the Skia backend (this
    // app pins Skia for the H.264 SurfaceTexture preview) that combination
    // renders as a solid red rectangle instead of the glass surface.
    const double kRimInset = 1;
    Widget surface = SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _GlassSurfacePainter(
          radius: radius,
          fill: fill,
          gradient: gradient,
          shadow: shadow,
          shadowColor: tokens.glassShadowColor,
        ),
        child: ClipPath(
          clipper: _SuperellipseClipper(radius),
          child: _maybeBlur(
            Stack(
              fit: StackFit.passthrough,
              children: <Widget>[
                // Specular sheen across the top half — brighter at the very edge.
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: const Alignment(0, 0.62),
                          colors: <Color>[
                            tokens.glassHighlightColor,
                            tokens.glassHighlightColor.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Inner bottom shade: the material's far edge.
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: const Alignment(0, 0.55),
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            innerShade.withValues(alpha: 0),
                            innerShade,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(padding: padding, child: child),
              ],
            ),
          ),
        ),
      ),
    );

    // Specular rim: a 1px gradient stroke. Painted as a slightly larger
    // squircle underneath, with the surface sitting 1px inside it.
    surface = _GlassRim(
      radius: radius + kRimInset,
      top: rimTop,
      bottom: rimBottom,
      child: surface,
    );

    if (onTap != null || interactive) {
      surface = _GlassPressable(
        interactive: interactive && onTap != null,
        onTap: onTap,
        child: surface,
      );
    }

    return Container(margin: margin, child: surface);
  }

  ImageFilter _backdropFilter() {
    final blurFilter = ImageFilter.blur(sigmaX: _blur, sigmaY: _blur);
    if (refraction <= 0) return blurFilter;
    final scale = 1 + refraction;
    return ImageFilter.compose(
      outer: blurFilter,
      inner: ImageFilter.matrix(
        Matrix4.identity().scaledByDouble(scale, scale, 1, 1).storage,
      ),
    );
  }

  /// Only installs a backdrop filter when there is an actual blur to apply.
  Widget _maybeBlur(Widget child) {
    if (_blur <= 0) return child;
    return BackdropFilter(filter: _backdropFilter(), child: child);
  }
}

/// Continuous-curvature squircle outline, drawn with cubic béziers so it
/// renders on the Skia backend (unlike `RoundedSuperellipseBorder`).
Path _superellipsePath(Rect rect, double radius) {
  final double r = radius.clamp(0.0, rect.shortestSide / 2);
  if (r <= 0) return Path()..addRect(rect);
  // Control-point offset along each tangent. 0.5523·r ≈ circular corner;
  // smaller → tighter, more "squircle" continuous curvature (iOS-like).
  final double a = r * 0.45;
  final double l = rect.left;
  final double t = rect.top;
  final double rr = rect.right;
  final double b = rect.bottom;
  return Path()
    ..moveTo(l + r, t)
    ..lineTo(rr - r, t)
    ..cubicTo(rr - r + a, t, rr, t + r - a, rr, t + r)
    ..lineTo(rr, b - r)
    ..cubicTo(rr, b - r + a, rr - r + a, b, rr - r, b)
    ..lineTo(l + r, b)
    ..cubicTo(l + r - a, b, l, b - r + a, l, b - r)
    ..lineTo(l, t + r)
    ..cubicTo(l, t + r - a, l + r - a, t, l + r, t)
    ..close();
}

/// Clips children to the squircle outline.
class _SuperellipseClipper extends CustomClipper<Path> {
  const _SuperellipseClipper(this.radius);

  final double radius;

  @override
  Path getClip(Size size) => _superellipsePath(Offset.zero & size, radius);

  @override
  bool shouldReclip(covariant _SuperellipseClipper old) =>
      old.radius != radius;
}

/// Paints the squircle fill (and optional gradient / drop shadow) with
/// `Canvas.drawPath`. Using `CustomPainter` instead of `ShapeDecoration` keeps
/// a `gradient` fill working on the Skia backend, which otherwise paints the
/// `ShapeDecoration(shape: <custom border>) + gradient` combo as a solid red
/// rectangle.
class _GlassSurfacePainter extends CustomPainter {
  const _GlassSurfacePainter({
    required this.radius,
    required this.fill,
    required this.gradient,
    required this.shadow,
    required this.shadowColor,
  });

  final double radius;
  final Color fill;
  final Gradient? gradient;
  final bool shadow;
  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Path path = _superellipsePath(rect, radius);

    if (shadow) {
      final Paint shadowPaint = Paint()
        ..color = shadowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.save();
      canvas.translate(0, 6);
      canvas.drawPath(path, shadowPaint);
      canvas.restore();
    }

    final Paint fillPaint = Paint()..style = PaintingStyle.fill;
    if (gradient != null) {
      fillPaint.shader = gradient!.createShader(rect);
    } else {
      fillPaint.color = fill;
    }
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _GlassSurfacePainter old) =>
      old.radius != radius ||
      old.fill != fill ||
      old.gradient != gradient ||
      old.shadow != shadow ||
      old.shadowColor != shadowColor;
}

/// 1px specular stroke: a slightly larger squircle filled with a vertical
/// gradient, with the surface sitting 1px inside it so only the rim shows.
class _GlassRim extends StatelessWidget {
  const _GlassRim({
    required this.radius,
    required this.top,
    required this.bottom,
    required this.child,
  });

  final double radius;
  final Color top;
  final Color bottom;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RimPainter(radius, top, bottom),
      child: Padding(padding: const EdgeInsets.all(1), child: child),
    );
  }
}

class _RimPainter extends CustomPainter {
  const _RimPainter(this.radius, this.top, this.bottom);

  final double radius;
  final Color top;
  final Color bottom;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = _superellipsePath(Offset.zero & size, radius);
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[top, bottom],
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RimPainter old) =>
      old.radius != radius || old.top != top || old.bottom != bottom;
}

/// iOS controls on glass dip slightly and brighten when pressed.
class _GlassPressable extends StatefulWidget {
  const _GlassPressable({
    required this.interactive,
    required this.child,
    this.onTap,
  });

  final bool interactive;
  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_GlassPressable> createState() => _GlassPressableState();
}

class _GlassPressableState extends State<_GlassPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.interactive || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.88 : 1,
          duration: const Duration(milliseconds: 120),
          child: widget.child,
        ),
      ),
    );
  }
}
