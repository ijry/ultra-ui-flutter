import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import 'up_icon.dart';

/// 1:1 port of u-car-keyboard.
class UPCarKeyboard extends StatefulWidget {
  const UPCarKeyboard({
    super.key,
    this.random = false,
    this.autoChange = false,
    this.onChange,
    this.onBackspace,
    this.customStyle,
  });

  final bool random;
  final bool autoChange;
  final ValueChanged<dynamic>? onChange;
  final VoidCallback? onBackspace;

  final BoxDecoration? customStyle;
  @override
  State<UPCarKeyboard> createState() => UPCarKeyboardState();
}

class UPCarKeyboardState extends State<UPCarKeyboard> {
  bool abc = false;
  Timer? timer;

  bool get isAbc => abc;
  bool get isArea => !abc;

  void switchToAbc() {
    if (abc) return;
    setState(() => abc = true);
  }

  void switchToArea() {
    if (!abc) return;
    setState(() => abc = false);
  }

  void toggleMode() => setState(() => abc = !abc);

  /// Source key tap equivalent.
  void input(dynamic key) {
    widget.onChange?.call(key);
    if (!abc && widget.autoChange) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => abc = true);
      });
    }
  }

  void backspace() => widget.onBackspace?.call();

  /// Source `carInputClick`.
  void carInputClick(dynamic key) => input(key);

  /// Source `changeCarInputMode`.
  void changeCarInputMode([bool? toAbc]) {
    if (toAbc == null) {
      toggleMode();
      return;
    }
    if (toAbc) {
      switchToAbc();
    } else {
      switchToArea();
    }
  }

  /// Source `backspaceClick`.
  void backspaceClick() => backspace();

  /// Source `clearTimer`.
  /// Source clearInterval alias (Batch J).
  void clearInterval([dynamic _]) => clearTimer();

  void clearTimer() {
    timer?.cancel();
    timer = null;
  }

  List<List<dynamic>> get areaList {
    var data = <dynamic>[
      '京',
      '沪',
      '粤',
      '津',
      '冀',
      '豫',
      '云',
      '辽',
      '黑',
      '湘',
      '皖',
      '鲁',
      '苏',
      '浙',
      '赣',
      '鄂',
      '桂',
      '甘',
      '晋',
      '陕',
      '蒙',
      '吉',
      '闽',
      '贵',
      '渝',
      '川',
      '青',
      '琼',
      '宁',
      '挂',
      '藏',
      '港',
      '澳',
      '新',
      '使',
      '学',
    ];
    if (widget.random) data = List<dynamic>.from(data)..shuffle(Random());
    return [
      data.sublist(0, 10),
      data.sublist(10, 20),
      data.sublist(20, 30),
      data.sublist(30, 36),
    ];
  }

  List<List<dynamic>> get engKeyBoardList {
    var data = <dynamic>[
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      0,
      'Q',
      'W',
      'E',
      'R',
      'T',
      'Y',
      'U',
      'I',
      'O',
      'P',
      'A',
      'S',
      'D',
      'F',
      'G',
      'H',
      'J',
      'K',
      'L',
      'Z',
      'X',
      'C',
      'V',
      'B',
      'N',
      'M',
    ];
    // keep same slice pattern as source even if random
    if (widget.random) data = List<dynamic>.from(data)..shuffle(Random());
    // source expects fixed lengths; pad if needed after shuffle
    while (data.length < 36) {
      data.add('');
    }
    return [
      data.sublist(0, 10),
      data.sublist(10, 20),
      data.sublist(20, 30),
      data.sublist(30, 36),
    ];
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
    final groups = abc ? engKeyBoardList : areaList;

    Widget keyBtn(dynamic text,
        {VoidCallback? onTap, Widget? child, double w = 32}) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: w,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [
              BoxShadow(color: Color(0xFF999992), offset: Offset(0, 1)),
            ],
          ),
          child: child ??
              Text(
                '$text',
                style: TextStyle(color: tokens.mainColor, fontSize: 16),
              ),
        ),
      );
    }

    Widget root = Container(
      color: const Color(0xFFE0E4E6),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (var i = 0; i < groups.length; i++)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (i == 3)
                  GestureDetector(
                    onTap: () => setState(() => abc = !abc),
                    child: Container(
                      width: 44,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC8CAD2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        abc ? '英' : '中',
                        style: TextStyle(color: tokens.primary, fontSize: 14),
                      ),
                    ),
                  ),
                for (final item in groups[i])
                  if ('$item'.isNotEmpty)
                    keyBtn(
                      item,
                      onTap: () {
                        widget.onChange?.call(item);
                        if (!abc && widget.autoChange) {
                          Future.delayed(const Duration(milliseconds: 200), () {
                            if (mounted) setState(() => abc = true);
                          });
                        }
                      },
                    ),
                if (i == 3)
                  GestureDetector(
                    onTapDown: (_) => _backspaceDown(),
                    onTapUp: (_) => _backspaceUp(),
                    onTapCancel: _backspaceUp,
                    child: keyBtn(
                      '',
                      w: 44,
                      child: UPIcon(
                        name: 'backspace',
                        size: 28,
                        color: tokens.mainColor,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
    return root;
  }
}
