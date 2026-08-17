import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import 'up_icon.dart';

/// 1:1 port of u-number-keyboard.
class UPNumberKeyboard extends StatefulWidget {
  const UPNumberKeyboard({
    super.key,
    this.mode = 'number',
    this.dotDisabled = false,
    this.random = false,
    this.onChange,
    this.onBackspace,
    this.customStyle,
  });

  final String mode; // number | card
  final bool dotDisabled;
  final bool random;
  final ValueChanged<dynamic>? onChange;
  final VoidCallback? onBackspace;

  final BoxDecoration? customStyle;

  /// Source computed: itemStyle(index).
  dynamic itemStyle([dynamic index]) {
    final i = int.tryParse('$index') ?? -1;
    final style = <String, dynamic>{};
    if (mode == 'number' && dotDisabled && i == 9) {
      style['width'] = '464rpx';
    }
    return style;
  }

  /// Source computed: btnBgGray(index).
  dynamic btnBgGray([dynamic index]) {
    final i = int.tryParse('$index') ?? -1;
    if (!random &&
        i == 9 &&
        (mode != 'number' || (mode == 'number' && !dotDisabled))) {
      return true;
    }
    return false;
  }

  @override
  State<UPNumberKeyboard> createState() => UPNumberKeyboardState();
}

class UPNumberKeyboardState extends State<UPNumberKeyboard> {
  /// Source host helper.
  bool intervalCleared = false;
  void clearInterval([dynamic _]) {
    intervalCleared = true;
  }

  /// Source data.
  String cardX = 'X';
  String get dot => '.';

  Timer? timer;

  List<dynamic> get keys => numList;

  void input(dynamic key) {
    final v = key;
    if (v != '.' && v != 'X') {
      widget.onChange?.call(v is num ? v : int.tryParse('$v') ?? v);
    } else {
      widget.onChange?.call(v);
    }
  }

  void backspace() => widget.onBackspace?.call();

  /// Source `keyboardClick`.
  void keyboardClick(dynamic key) => input(key);

  /// Source `backspaceClick`.
  void backspaceClick() => backspace();

  /// Source `clearTimer`.
  void clearTimer() {
    timer?.cancel();
    timer = null;
  }

  List<dynamic> get numList {
    List<dynamic> tmp;
    if (widget.mode == 'card') {
      tmp = [1, 2, 3, 4, 5, 6, 7, 8, 9, 'X', 0];
    } else if (widget.dotDisabled) {
      tmp = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0];
    } else {
      tmp = [1, 2, 3, 4, 5, 6, 7, 8, 9, '.', 0];
    }
    if (widget.random) {
      tmp = List<dynamic>.from(tmp)..shuffle(Random());
    }
    return tmp;
  }

  void _backspaceDown() {
    widget.onBackspace?.call();
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      widget.onBackspace?.call();
    });
  }

  void _backspaceUp() {
    timer?.cancel();
    timer = null;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final keys = numList;
    final wideZero = widget.mode == 'number' && widget.dotDisabled;

    Widget root = Container(
      color: const Color(0xFFE0E4E6),
      padding: const EdgeInsets.fromLTRB(5, 8, 5, 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 8,
        children: [
          for (var i = 0; i < keys.length; i++)
            _key(
              text: '${keys[i]}',
              width: wideZero && i == keys.length - 1 ? 232 : 111,
              gray: !widget.random &&
                  i == 9 &&
                  (widget.mode != 'number' || !widget.dotDisabled),
              color: tokens.mainColor,
              onTap: () {
                final v = keys[i];
                if (v != '.' && v != 'X') {
                  widget.onChange?.call(v is num ? v : int.tryParse('$v') ?? v);
                } else {
                  widget.onChange?.call(v);
                }
              },
            ),
          GestureDetector(
            onTapDown: (_) => _backspaceDown(),
            onTapUp: (_) => _backspaceUp(),
            onTapCancel: _backspaceUp,
            child: Container(
              width: 111,
              height: 45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFC8CAD2),
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFBBBCBE), offset: Offset(0, 2)),
                ],
              ),
              child:
                  UPIcon(name: 'backspace', size: 28, color: tokens.mainColor),
            ),
          ),
        ],
      ),
    );

    return root;
  }

  Widget _key({
    required String text,
    required double width,
    required bool gray,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: gray ? const Color(0xFFC8CAD2) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(color: Color(0xFFBBBCBE), offset: Offset(0, 2)),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ),
    );
  }
}
