import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_empty.dart';

/// Port of u-pdf-reader / up-pdf-reader.
///
/// Uses a platform-view/webview style placeholder by default. Host apps can
/// inject a real viewer via [viewerBuilder] without adding package deps.
class UPPdfReader extends StatefulWidget {
  const UPPdfReader({
    super.key,
    this.src = '',
    this.url = '',
    this.path = '',
    this.height,
    this.width,
    this.showToolbar = true,
    this.baseUrl = '',
    this.viewerBuilder,
    this.onLoad,
    this.onError,
    this.onToolbarAction,
    this.customStyle,
  });

  final String src;
  final String url;
  final String path;
  final dynamic height;
  final dynamic width;
  final bool showToolbar;
  final String baseUrl;

  /// Host-injectable viewer. Receives the resolved pdf.js style viewer URL.
  final Widget Function(String viewerUrl)? viewerBuilder;
  final VoidCallback? onLoad;
  final ValueChanged<String>? onError;

  /// Toolbar action hook. Built-in action is `copy`.
  final ValueChanged<String>? onToolbarAction;

  final BoxDecoration? customStyle;
  @override
  State<UPPdfReader> createState() => UPPdfReaderState();
}

class UPPdfReaderState extends State<UPPdfReader> {
  /// Source data.
  String baseUrlInner = '';

  String get target => widget.src.isNotEmpty
      ? widget.src
      : (widget.url.isNotEmpty ? widget.url : widget.path);

  String get viewerUrl {
    if (target.isEmpty) return '';
    final base = widget.baseUrl.isNotEmpty
        ? widget.baseUrl
        : 'https://mozilla.github.io/pdf.js/web/viewer.html';
    if (target.contains('viewer.html')) return target;
    return '$base?file=${Uri.encodeComponent(target)}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => notify());
  }

  @override
  void didUpdateWidget(covariant UPPdfReader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.src != widget.src ||
        oldWidget.url != widget.url ||
        oldWidget.path != widget.path) {
      WidgetsBinding.instance.addPostFrameCallback((_) => notify());
    }
  }

  void notify() {
    if (target.isEmpty) {
      widget.onError?.call('empty src');
    } else {
      widget.onLoad?.call();
    }
  }

  /// Source `load` — re-emit load/error for current target.
  void load() => notify();

  /// Reload alias.
  void reload() => notify();

  Future<void> openExternal() async {
    // Host-owned action. Default package stays free of url_launcher/clipboard
    // platform channels that can hang under test bindings.
    widget.onToolbarAction?.call('copy');
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final w = UPUtils.getPx(widget.width);
    final h = UPUtils.getPx(widget.height);
    final resolvedViewer = viewerUrl;
    Widget root = Container(
      width: w > 0 ? w : double.infinity,
      height: h > 0 ? h : 320,
      color: tokens.bgColor,
      child: Column(
        children: [
          if (widget.showToolbar)
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              color: tokens.cardBgColor,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      target.isEmpty ? 'PDF Reader' : target,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: tokens.mainColor),
                    ),
                  ),
                  if (target.isNotEmpty)
                    TextButton(
                      onPressed: openExternal,
                      child: const Text('复制链接'),
                    ),
                ],
              ),
            ),
          Expanded(
            child: target.isEmpty
                ? const ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topCenter,
                      minHeight: 0,
                      maxHeight: double.infinity,
                      child: UPEmpty(mode: 'data', text: '请传入 PDF 地址'),
                    ),
                  )
                : (widget.viewerBuilder != null
                    ? KeyedSubtree(
                        key: ValueKey('pdf-viewer-$resolvedViewer'),
                        child: widget.viewerBuilder!(resolvedViewer),
                      )
                    : Container(
                        width: double.infinity,
                        color: const Color(0xFFF7F8FA),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              size: 48,
                              color: tokens.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              kIsWeb ? 'PDF Web 预览' : 'PDF 预览占位',
                              style: TextStyle(color: tokens.contentColor),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              resolvedViewer,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: tokens.tipsColor,
                              ),
                            ),
                          ],
                        ),
                      )),
          ),
        ],
      ),
    );
    return root;
  }
}
