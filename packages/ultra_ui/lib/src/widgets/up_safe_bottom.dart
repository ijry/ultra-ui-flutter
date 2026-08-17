import 'package:flutter/widgets.dart';

import '../utils/up_utils.dart';

final Expando<Map<String, dynamic>> _upSafeBottomState =
    Expando<Map<String, dynamic>>('upSafeBottomState');

class UPSafeBottom extends StatelessWidget {
  const UPSafeBottom({
    super.key,
    this.bgColor = 'transparent',
    this.customStyle,
  });

  final dynamic bgColor;
  final BoxDecoration? customStyle;

  /// Source data.
  bool get isNvue => false;
  Map<String, dynamic> get _state =>
      _upSafeBottomState[this] ??= <String, dynamic>{
        'safeAreaBottomHeight': 0.0,
      };
  double get safeAreaBottomHeight =>
      ((_state['safeAreaBottomHeight'] as num?) ?? 0).toDouble();

  /// Source computed: style.
  dynamic get style => <String, dynamic>{
        'height': UPUtils.addUnit(safeAreaBottomHeight),
      };

  void _rememberHeight(double bottom) {
    _state['safeAreaBottomHeight'] = bottom;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.maybeOf(context)?.padding.bottom ?? 0;
    _rememberHeight(bottom);
    // The source template only applies `customStyle`; retained `bgColor` is
    // not a declared source prop and remains inactive.
    return Container(
      height: bottom,
      decoration: customStyle,
    );
  }
}
