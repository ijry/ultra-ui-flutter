import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_loading_icon.dart';
import 'up_overlay.dart';

/// 1:1 port of u-modal defaults and async-close behavior.
class UPModal extends StatefulWidget {
  const UPModal({
    super.key,
    this.show = false,
    this.title = '',
    this.content = '',
    this.confirmText = '确认',
    this.cancelText = '取消',
    this.showConfirmButton = true,
    this.showCancelButton = false,
    this.confirmColor = '#2979ff',
    this.cancelColor = '#606266',
    this.buttonReverse = false,
    this.zoom = true,
    this.asyncClose = false,
    this.closeOnClickOverlay = false,
    this.negativeTop = 0,
    this.width = '650rpx',
    this.confirmButtonShape = '',
    this.duration = 400,
    this.contentTextAlign = 'left',
    this.asyncCloseTip = '操作中...',
    this.asyncCancelClose = false,
    this.contentStyle,
    this.onConfirm,
    this.onCancel,
    this.onCancelOnAsync,
    this.onClose,
    this.onUpdateShow,
    this.confirmButton,
    this.popupBottom,
    this.child,
    this.customStyle,
  });

  final bool show;
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final bool showConfirmButton;
  final bool showCancelButton;
  final dynamic confirmColor;
  final dynamic cancelColor;
  final bool buttonReverse;
  final bool zoom;
  final bool asyncClose;
  final bool closeOnClickOverlay;
  final dynamic negativeTop;
  final dynamic width;
  final String confirmButtonShape;
  final dynamic duration;
  final String contentTextAlign;
  final String asyncCloseTip;
  final bool asyncCancelClose;
  final EdgeInsetsGeometry? contentStyle;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onCancelOnAsync;
  final VoidCallback? onClose;
  final ValueChanged<bool>? onUpdateShow;
  final Widget? confirmButton;
  final Widget? popupBottom;
  final Widget? child;

  final BoxDecoration? customStyle;

  /// Source computed: contentStyleCpu.
  dynamic get contentStyleCpu {
    final style = <String, dynamic>{};
    // contentStyle is EdgeInsetsGeometry on Flutter host; expose paddingTop parity.
    style['paddingTop'] = title.isNotEmpty ? '12px' : '25px';
    return style;
  }

  @override
  State<UPModal> createState() => UPModalState();
}

class UPModalState extends State<UPModal> {
  bool loading = false;
  bool? _forcedShow;

  int get _ms => int.tryParse('${widget.duration}') ?? 400;

  bool get isLoading => loading;
  bool get isShown => _forcedShow ?? widget.show;

  void open() {
    _forcedShow = true;
    widget.onUpdateShow?.call(true);
    if (mounted) setState(() {});
  }

  void close() {
    _forcedShow = false;
    widget.onUpdateShow?.call(false);
    widget.onClose?.call();
    if (mounted) setState(() {});
  }

  void toggle() => isShown ? close() : open();

  void resetLoading() {
    if (mounted) setState(() => loading = false);
  }

  @override
  void didUpdateWidget(covariant UPModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.show != widget.show) {
      _forcedShow = null;
    }
    if (!oldWidget.show && widget.show && loading) {
      loading = false;
    }
  }

  /// Source `confirmHandler`.
  void confirmHandler() => _confirm();

  /// Source `cancelHandler`.
  void cancelHandler() => _cancel();

  /// Source `clickHandler` — default closes when overlay-like click.
  void clickHandler() => close();

  void _confirm() {
    if (widget.asyncClose) {
      setState(() => loading = true);
    } else {
      widget.onUpdateShow?.call(false);
      _forcedShow = false;
    }
    widget.onConfirm?.call();
  }

  void _cancel() {
    if (widget.asyncClose && loading) {
      widget.onCancelOnAsync?.call();
      widget.onCancel?.call();
      return;
    }
    if (!widget.asyncCancelClose) {
      widget.onUpdateShow?.call(false);
      _forcedShow = false;
    }
    widget.onCancel?.call();
  }

  void _overlayClick() {
    if (!widget.closeOnClickOverlay) return;
    close();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final w = UPUtils.getPx(
      widget.width,
      screenWidth: MediaQuery.sizeOf(context).width,
    );
    final confirmC =
        UPUtils.parseColor(widget.confirmColor) ?? const Color(0xFF2979FF);
    final cancelC =
        UPUtils.parseColor(widget.cancelColor) ?? tokens.contentColor;
    final align = widget.contentTextAlign == 'center'
        ? TextAlign.center
        : widget.contentTextAlign == 'right'
            ? TextAlign.right
            : TextAlign.left;

    final actions = <Widget>[];
    final showCancel =
        widget.confirmButtonShape.isEmpty && widget.showCancelButton;
    final cancelBtn = Expanded(
      child: InkWell(
        onTap: _cancel,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Text(
            widget.cancelText,
            style: TextStyle(color: cancelC, fontSize: 16),
          ),
        ),
      ),
    );
    final confirmBtn = Expanded(
      child: InkWell(
        onTap: _confirm,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: loading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UPLoadingIcon(size: 16, color: confirmC),
                    const SizedBox(width: 6),
                    Text(
                      widget.asyncCloseTip,
                      style: TextStyle(color: confirmC, fontSize: 15),
                    ),
                  ],
                )
              : Text(
                  widget.confirmText,
                  style: TextStyle(color: confirmC, fontSize: 16),
                ),
        ),
      ),
    );

    if (showCancel && widget.showConfirmButton) {
      if (widget.buttonReverse) {
        actions.addAll([confirmBtn, cancelBtn]);
      } else {
        actions.addAll([cancelBtn, confirmBtn]);
      }
    } else if (widget.showConfirmButton) {
      actions.add(confirmBtn);
    } else if (showCancel) {
      actions.add(cancelBtn);
    }

    final panel = Material(
      color: tokens.cardBgColor,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: tokens.mainColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Padding(
              padding: widget.contentStyle ??
                  EdgeInsets.fromLTRB(
                    24,
                    widget.title.isNotEmpty ? 12 : 25,
                    24,
                    25,
                  ),
              child: widget.child ??
                  Text(
                    widget.content,
                    textAlign: align,
                    style: TextStyle(
                      color: tokens.contentColor,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
            ),
            if (widget.confirmButton != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 0, 25, 15),
                child: widget.confirmButton,
              )
            else ...[
              Divider(height: 1, thickness: 0.5, color: tokens.borderColor),
              if (actions.isNotEmpty)
                SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      for (var i = 0; i < actions.length; i++) ...[
                        if (i > 0)
                          Container(width: 0.5, color: tokens.borderColor),
                        actions[i],
                      ],
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );

    Widget root = Stack(
      children: [
        Positioned.fill(
          child: UPOverlay(
            show: isShown,
            duration: _ms,
            opacity: 0.5,
            rootOverlay: false,
            onClick: widget.closeOnClickOverlay ? _overlayClick : null,
          ),
        ),
        AnimatedOpacity(
          duration: Duration(milliseconds: _ms),
          opacity: isShown ? 1 : 0,
          child: AnimatedScale(
            duration: Duration(milliseconds: _ms),
            scale: widget.zoom ? (isShown ? 1 : 0.85) : 1,
            child: IgnorePointer(
              ignoring: !isShown,
              child: Align(
                alignment:
                    Alignment(0, -UPUtils.getPx(widget.negativeTop) / 100),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    panel,
                    if (widget.popupBottom != null) widget.popupBottom!,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return root;
  }
}
