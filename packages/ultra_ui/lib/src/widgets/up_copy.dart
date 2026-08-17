import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'up_toast.dart';

final Expando<Map<String, dynamic>> _upCopyState =
    Expando<Map<String, dynamic>>('upCopyState');

/// 1:1 port of u-copy / up-copy.
class UPCopy extends StatelessWidget {
  const UPCopy({
    super.key,
    this.content = '',
    this.alertStyle = 'toast',
    this.notice = '复制成功',
    this.onSuccess,
    this.child,
    this.customStyle,
  });

  final dynamic content;
  final String alertStyle;
  final String notice;
  final VoidCallback? onSuccess;
  final Widget? child;
  final BoxDecoration? customStyle;

  /// Source `handleClick`.
  Future<void> handleClick(BuildContext context) => _handle(context);

  Future<void> _handle(BuildContext context) async {
    if (_isSourceFalsey(content)) {
      if (context.mounted) {
        UPToast.show(context, message: '内容为空', position: 'center');
      }
      return;
    }
    try {
      await Clipboard.setData(ClipboardData(text: '$content'));
      onSuccess?.call();
      if (!context.mounted) return;
      if (alertStyle == 'modal') {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('提示'),
            content: Text(notice),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('确定'),
              ),
            ],
          ),
        );
      } else if (alertStyle != 'none') {
        try {
          UPToast.show(context, message: notice, position: 'center');
        } catch (_) {}
      }
    } catch (_) {
      if (!context.mounted) return;
      try {
        UPToast.show(context, message: '复制失败', position: 'center');
      } catch (_) {}
    }
  }

  /// Mirrors the source `if (!content)` guard for dynamic Dart inputs.
  static bool _isSourceFalsey(dynamic value) {
    if (value == null || value is String && value.isEmpty) return true;
    if (value is bool) return !value;
    if (value is num) return value == 0 || value.isNaN;
    return false;
  }

  /// Source result helpers (Batch J).
  Map<String, dynamic> get _state => _upCopyState[this] ??= <String, dynamic>{
        'lastResult': null,
        'lastSuccess': false
      };
  dynamic get lastResult => _state['lastResult'];
  bool get lastSuccess => _state['lastSuccess'] == true;
  void success([dynamic payload]) {
    _state['lastSuccess'] = true;
    _state['lastResult'] = payload ?? true;
  }

  void fail([dynamic payload]) {
    _state['lastSuccess'] = false;
    _state['lastResult'] = payload ?? false;
  }

  @override
  Widget build(BuildContext context) {
    Widget root = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _handle(context),
      child: child ?? const Text('复制'),
    );
    return root;
  }
}
