import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';
import 'up_loading_icon.dart';

/// Imperative toast host similar to u-toast / $u.toast.
class UPToast {
  static bool typeof(dynamic v, [String type = ""]) => type.isEmpty
      ? v != null
      : v.runtimeType.toString().toLowerCase().contains(type.toLowerCase());

  /// Source data.
  static bool complete = true;
  static bool get isShow => _entry != null;
  UPToast._();

  static OverlayEntry? _entry;
  static Timer? _timer;

  /// Source retained config fields.
  static Map config = <String, dynamic>{};
  static Map params = <String, dynamic>{};
  static Map tmpConfig = <String, dynamic>{};

  static void show(
    BuildContext context, {
    String message = '',
    String type = '',
    String icon = '',
    bool loading = false,
    String loadingMode = '',
    bool overlay = false,
    String position = 'center',
    int duration = 2000,
    int zIndex = 10090,
  }) {
    hide();
    final isLoading = loading || type == 'loading';
    params = {
      'message': message,
      'type': type,
      'icon': icon,
      'loading': isLoading,
      'position': position,
      'duration': duration,
      'zIndex': zIndex,
    };
    tmpConfig = Map<String, dynamic>.from(params);
    if (config.isNotEmpty) {
      tmpConfig = {...config, ...tmpConfig};
    }
    final overlayState = Overlay.of(context, rootOverlay: true);
    final tokens = UPThemeTokens.of(context);
    tmpConfig['windowHeight'] = MediaQuery.sizeOf(context).height;
    final resolvedIcon = icon.isNotEmpty
        ? icon
        : (type == 'success'
            ? 'checkmark-circle'
            : type == 'error'
                ? 'close-circle'
                : type == 'warning'
                    ? 'error-circle'
                    : '');
    final alignment = position == 'top'
        ? Alignment.topCenter
        : position == 'bottom'
            ? Alignment.bottomCenter
            : Alignment.center;

    _entry = OverlayEntry(
      builder: (ctx) {
        return Stack(
          children: [
            if (overlay)
              Positioned.fill(
                child: ColoredBox(
                  color: Color.fromRGBO(0, 0, 0, 0.3),
                ),
              ),
            Align(
              alignment: alignment,
              child: Padding(
                padding: EdgeInsets.only(
                  top: position == 'top' ? 80 : 0,
                  bottom: position == 'bottom' ? 80 : 0,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 260),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xCC000000),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLoading)
                          const UPLoadingIcon(
                            mode: 'circle',
                            color: '#ffffff',
                            size: 24,
                          )
                        else if (resolvedIcon.isNotEmpty)
                          UPIcon(
                            name: resolvedIcon,
                            size: 28,
                            color: '#ffffff',
                          ),
                        if ((isLoading || resolvedIcon.isNotEmpty) &&
                            message.isNotEmpty)
                          const SizedBox(height: 8),
                        if (message.isNotEmpty)
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.3,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    overlayState.insert(_entry!);
    if (duration != -1) {
      _timer = Timer(Duration(milliseconds: duration), hide);
    }
    // Keep tokens referenced for theme parity / future styling.
    tokens.primary;
  }

  /// Source timer aliases.
  static void clearTimer() {
    _timer?.cancel();
    _timer = null;
  }

  static void clearTimeout() => clearTimer();

  /// Source icon helper (Batch K).
  static String iconName([String type = 'default']) {
    switch (type) {
      case 'success':
        return 'checkmark-circle';
      case 'error':
        return 'close-circle';
      case 'warning':
        return 'error-circle';
      case 'loading':
        return 'loading';
      default:
        return 'info-circle';
    }
  }

  static void hide() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }

  /// Source computed: overlayStyle.
  static dynamic get overlayStyle => const <String, dynamic>{
        'justifyContent': 'center',
        'alignItems': 'center',
        'display': 'flex',
        'backgroundColor': 'rgba(0, 0, 0, 0)',
      };

  /// Source computed: iconStyle.
  static dynamic get iconStyle => const <String, dynamic>{
        'marginRight': '4px',
      };

  /// Source computed: loadingIconColor.
  static dynamic get loadingIconColor => 'rgb(255, 255, 255)';

  /// Source computed: contentStyle (Y offset from position + window height).
  static dynamic get contentStyle {
    final style = <String, dynamic>{};
    final position =
        '${tmpConfig['position'] ?? params['position'] ?? 'center'}';
    final windowHeight =
        double.tryParse('${tmpConfig['windowHeight'] ?? 0}') ?? 0.0;
    var value = 0.0;
    if (position == 'top') {
      value = -windowHeight * 0.25;
    } else if (position == 'bottom') {
      value = windowHeight * 0.25;
    }
    style['transform'] = 'translateY(${value}px)';
    return style;
  }
}
