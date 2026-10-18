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
///   * shape uses [RoundedSuperellipseBorder] — the continuous-corner
///     "squircle" that iOS actually draws, not a circular-arc corner;
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

  double get _blur => blur ?? (_isClear ? 26 : 18);

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final radius = _radius;

    final baseTint = tint ?? tokens.glassBgColor;
    final fill = _isClear
        ? baseTint.withValues(alpha: baseTint.a * 0.45)
        : baseTint;

    // iOS lights the top edge and lets the bottom fall into shade; in dark
    // mode the "light" is a faint sheen rather than white.
    final rimTop = isDark
        ? tokens.glassHighlightColor.withValues(alpha: 0.55)
        : tokens.glassHighlightColor;
    final rimBottom = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.25);
    final innerShade = isDark
        ? Colors.black.withValues(alpha: 0.28)
        : const Color(0x1A0F1B2E);

    // NOTE: iOS draws a "squircle" (RoundedSuperellipseBorder). Flutter's
    // implementation fills through `Canvas.drawRSuperellipse`, which the Skia
    // backend does not render — this app pins Skia on purpose (the H.264
    // preview needs SurfaceTexture), so a superellipse surface comes out
    // blank. Rounded-rect path is visually close and renders everywhere.
    final borderRadius = BorderRadius.circular(radius);

    Widget surface = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: fill,
        gradient: gradient,
        boxShadow: shadow
            ? <BoxShadow>[
                BoxShadow(
                  color: tokens.glassShadowColor,
                  blurRadius: 26,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        // `blur: 0` must NOT install a BackdropFilter: a sigma-0 blur still
        // promotes the subtree to its own composited layer, which both costs
        // a per-frame pass and breaks stacking against sliding siblings
        // (e.g. swipe-action buttons showing through the card).
        child: _maybeBlur(
          Stack(
            fit: StackFit.passthrough,
            children: <Widget>[
              // Specular sheen across the top half.
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: const Alignment(0, 0.75),
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
                      borderRadius: borderRadius,
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
    );

    // Specular rim: a 1px gradient stroke. `BoxDecoration.border` cannot hold
    // a gradient, so it is painted as a slightly larger shape underneath.
    surface = _GlassRim(
      radius: radius + 1,
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

/// Paints the 1px specular stroke by sitting just outside the surface.
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
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[top, bottom],
        ),
      ),
      child: Padding(padding: const EdgeInsets.all(1), child: child),
    );
  }
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
