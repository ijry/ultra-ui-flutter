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
///   * the fill **and** the specular rim are painted with a `CustomPainter`
///     via `Canvas.drawPath`. This deliberately avoids `ShapeDecoration(shape:
///     <custom border>) + gradient`: on the Skia backend that combination
///     paints as a solid red rectangle. Hand-rolling the paint avoids it.
///   * the **specular rim is its own layer drawn *on top* of the blurred body**
///     (not beneath it) so the backdrop filter does not smear the bright edge
///     into a washed-out band — that was the earlier "looks like a soft box,
///     not glass" failure.
///   * **light vs dark edges differ on purpose**: a white edge is invisible
///     against the near-white light backdrop, so light mode uses a subtle dark
///     hairline to define the shape (the way iOS light glass is outlined), while
///     dark mode uses a bright edge. Both get a top sheen + bottom inner shade.
///   * the backdrop is blurred, and [refraction] very slightly magnifies it
///     to mimic light bending through the material's edge.
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
    // In the `regular` variant, cap the fill alpha so the blurred backdrop
    // stays visible through the glass — otherwise it reads as a flat box.
    final double baseA = baseTint.a / 255.0;
    final double fillA =
        _isClear ? baseA * 0.4 : (baseA > 0.72 ? 0.72 : baseA);
    final Color fill = baseTint.withValues(alpha: fillA);
    // Dark inner edge at the bottom, faking the glass thickness.
    final Color rimShadow = isDark
        ? Colors.black.withValues(alpha: 0.35)
        : const Color(0x33000000);

    // iOS lights the top edge and lets the bottom fall into shade; in dark
    // mode the "light" is a faint sheen rather than white.
    final rimTop = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : tokens.glassBorderColor;
    final rimBottom = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.16);
    final innerShade = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : const Color(0x1A0F1B2E);
    // Outline colour: a bright edge on dark, a subtle-but-present dark hairline
    // on light (a white edge is invisible against the near-white light
    // backdrop — iOS light glass is outlined this way). Strong enough to read
    // as a crisp edge so the panel does not dissolve into a soft blob.
    final Color edgeColor = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : const Color(0x4D000000);

    // The squircle fill + (optional) drop shadow are painted with a
    // `CustomPainter` using `Canvas.drawPath`. The blurred body + content is the
    // `child`, clipped to the squircle. The specular rim is painted with a
    // **foreground** painter — i.e. *on top of* the child — so the backdrop
    // filter never smears the bright edge into a washed-out band (that was the
    // earlier "no glass, just a soft box" miss). This also avoids a second
    // `Positioned.fill` layer, which the Skia backend here drops entirely.
    // iOS vs light edges differ on purpose: a white edge is invisible against
    // the near-white light backdrop, so light mode uses a subtle dark hairline
    // (the way iOS light glass is outlined) while dark mode uses a bright edge.
    final Widget body = ClipPath(
      clipper: _SuperellipseClipper(radius),
      child: _maybeBlur(
        Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            // Specular sheen across the top — brightest at the very edge.
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: const Alignment(0, 0.55),
                      colors: <Color>[
                        rimTop,
                        rimTop.withValues(alpha: 0),
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
                      begin: const Alignment(0, 0.5),
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
    );

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
        foregroundPainter: _GlassRimPainter(
          radius: radius,
          edge: edgeColor,
          top: rimTop,
          bottom: rimBottom,
          shadow: rimShadow,
        ),
        child: body,
      ),
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
      // A soft, lifted shadow so the glass separates from the backdrop even
      // when the fill is near-white (light mode). The theme token is faint, so
      // we deepen it locally to keep the panel from dissolving into the
      // near-white backdrop.
      final double sa = (shadowColor.a / 255.0 * 1.7).clamp(0.0, 1.0);
      final Paint shadowPaint = Paint()
        ..color = shadowColor.withValues(alpha: sa)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
      canvas.save();
      canvas.translate(0, 9);
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

/// Crisp specular rim painted as strokes along the superellipse edge, drawn on
/// top of the blurred body so the backdrop filter does not smear it:
///   1. a 1px hairline outline — bright on dark, subtle dark on light;
///   2. a bright top sheen (strongest at the very top edge);
///   3. a dark bottom inner edge, faking the glass thickness.
class _GlassRimPainter extends CustomPainter {
  const _GlassRimPainter({
    required this.radius,
    required this.edge,
    required this.top,
    required this.bottom,
    required this.shadow,
  });

  final double radius;
  final Color edge;
  final Color top;
  final Color bottom;
  final Color shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = _superellipsePath(Offset.zero & size, radius);
    final Rect rect = Offset.zero & size;

    // 1) Hairline outline defining the shape.
    final Paint outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = edge;
    canvas.drawPath(path, outline);

    // 2) Bright specular sheen at the top edge, gone by 40% down.
    final Paint sheen = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: const Alignment(0, 0.4),
        colors: <Color>[top, top.withValues(alpha: 0)],
      ).createShader(rect);
    canvas.drawPath(path, sheen);

    // 3) Dark inner edge at the bottom, suggesting thickness.
    final Paint dark = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = LinearGradient(
        begin: const Alignment(0, 0.6),
        end: Alignment.bottomCenter,
        colors: <Color>[shadow.withValues(alpha: 0), shadow],
      ).createShader(rect);
    canvas.drawPath(path, dark);
  }

  @override
  bool shouldRepaint(covariant _GlassRimPainter old) =>
      old.radius != radius ||
      old.edge != edge ||
      old.top != top ||
      old.bottom != bottom ||
      old.shadow != shadow;
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
