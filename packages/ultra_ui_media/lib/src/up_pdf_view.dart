import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart' as pdfrx;

import 'file_probe.dart';

/// Recovers the real document target from the pdf.js viewer URL that
/// [UPPdfReader] hands to its `viewerBuilder`.
///
/// The reader builds `<base>?file=<encoded target>` so a web host can point an
/// iframe at pdf.js. A native renderer needs the target itself, so unwrap the
/// `file` query parameter when it is present and fall back to the raw value.
String resolvePdfTarget(String viewerUrl) {
  if (viewerUrl.isEmpty) return '';
  final parsed = Uri.tryParse(viewerUrl);
  final file = parsed?.queryParameters['file'];
  if (file != null && file.isNotEmpty) return file;
  return viewerUrl;
}

/// Renders a PDF with pdfrx (PDFium), for use as [UPPdfReader.viewerBuilder].
///
/// Accepts an http(s) URL, a `file://` URI, a bundled asset path, or a plain
/// filesystem path, matching the range of values the source component's `src`
/// accepts across platforms.
class UPPdfView extends StatefulWidget {
  const UPPdfView({
    super.key,
    required this.target,
    this.initialPage = 1,
    this.backgroundColor,
    this.onReady,
    this.onError,
  });

  /// Document location. Pass the value from `viewerBuilder` through
  /// [resolvePdfTarget] first when it is a pdf.js viewer URL.
  final String target;
  final int initialPage;
  final Color? backgroundColor;
  final VoidCallback? onReady;
  final ValueChanged<String>? onError;

  @override
  State<UPPdfView> createState() => _UPPdfViewState();
}

class _UPPdfViewState extends State<UPPdfView> {
  late Future<void> _ready;

  @override
  void initState() {
    super.initState();
    _ready = pdfrx.pdfrxFlutterInitialize();
  }

  Widget _buildViewer() {
    final params = pdfrx.PdfViewerParams(
      backgroundColor: widget.backgroundColor ?? const Color(0xFF323639),
      onViewerReady: (_, __) => widget.onReady?.call(),
      errorBannerBuilder: (context, error, stack, ref) {
        widget.onError?.call('$error');
        return _Message(text: '$error');
      },
    );

    final target = widget.target;
    if (target.startsWith('http://') || target.startsWith('https://')) {
      return pdfrx.PdfViewer.uri(
        Uri.parse(target),
        params: params,
        initialPageNumber: widget.initialPage,
      );
    }
    if (target.startsWith('file://')) {
      return pdfrx.PdfViewer.file(
        Uri.parse(target).toFilePath(),
        params: params,
        initialPageNumber: widget.initialPage,
      );
    }
    // A path that exists on disk is a file; anything else is a bundled asset.
    // Asset paths cannot be probed synchronously, so this ordering keeps the
    // common `assets/...` case working without a redundant IO round-trip.
    if (!kIsWeb && localFileExists(target)) {
      return pdfrx.PdfViewer.file(
        target,
        params: params,
        initialPageNumber: widget.initialPage,
      );
    }
    return pdfrx.PdfViewer.asset(
      target,
      params: params,
      initialPageNumber: widget.initialPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.target.isEmpty) return const _Message(text: '请传入 PDF 地址');
    return FutureBuilder<void>(
      future: _ready,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final message = '${snapshot.error}';
          widget.onError?.call(message);
          return _Message(text: message);
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildViewer();
      },
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(text, textAlign: TextAlign.center),
        ),
      );
}
