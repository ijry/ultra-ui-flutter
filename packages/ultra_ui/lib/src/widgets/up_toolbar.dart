import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';

class UPToolbar extends StatelessWidget {
  const UPToolbar({
    super.key,
    this.show = true,
    this.cancelText = '取消',
    this.confirmText = '确认',
    this.cancelColor = '#909193',
    this.confirmColor = '',
    this.title = '',
    this.rightSlot = false,
    this.right,
    this.onCancel,
    this.onConfirm,
    this.customStyle,
  });

  final bool show;
  final String cancelText;
  final String confirmText;
  final dynamic cancelColor;
  final dynamic confirmColor;
  final String title;
  final bool rightSlot;
  final Widget? right;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  final BoxDecoration? customStyle;

  /// Source `cancel`.
  void cancel() => onCancel?.call();

  /// Source `confirm`.
  void confirm() => onConfirm?.call();

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();
    final tokens = UPThemeTokens.of(context);
    final cancelC = UPUtils.parseColor(cancelColor) ?? tokens.tipsColor;
    final confirmC = UPUtils.parseColor(
          confirmColor == '' ? null : confirmColor,
          fallback: tokens.primary,
        ) ??
        tokens.primary;

    Widget root = SizedBox(
      height: 42,
      child: Row(
        children: [
          GestureDetector(
            onTap: onCancel,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                cancelText,
                style: TextStyle(color: cancelC, fontSize: 15),
              ),
            ),
          ),
          Expanded(
            child: title.isEmpty
                ? const SizedBox.shrink()
                : Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: tokens.mainColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          if (rightSlot)
            right ?? const SizedBox.shrink()
          else
            GestureDetector(
              onTap: onConfirm,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  confirmText,
                  style: TextStyle(color: confirmC, fontSize: 15),
                ),
              ),
            ),
        ],
      ),
    );

    return root;
  }
}
