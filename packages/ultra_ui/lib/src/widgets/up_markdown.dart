import 'package:flutter/widgets.dart';
import 'package:markdown/markdown.dart' as md;

import 'up_parse.dart';

/// Port of u-markdown / up-markdown.
class UPMarkdown extends StatelessWidget {
  const UPMarkdown({
    super.key,
    this.content = '',
    this.previewImg = true,
    this.copyLink = true,
    this.domain = '',
    this.showLineNumber = false,
    this.theme = 'light',
    this.onLinkTap,
    this.onLoad,
    this.onReady,
    this.onImgTap,
    this.onError,
    this.onPlay,
    this.customStyle,
  });

  final String content;
  final bool previewImg;
  final dynamic copyLink;
  final String domain;
  final bool showLineNumber;
  final String theme;
  final ValueChanged<String>? onLinkTap;
  final VoidCallback? onLoad;
  final VoidCallback? onReady;
  final ValueChanged<String>? onImgTap;

  /// Source emit.
  final ValueChanged<dynamic>? onError;

  /// Source emit.
  final ValueChanged<dynamic>? onPlay;

  /// Source emit alias: imgtap.
  ValueChanged<String>? get onImgtap => onImgTap;

  /// Source emit alias: linktap.
  ValueChanged<String>? get onLinktap => onLinkTap;
  final BoxDecoration? customStyle;

  /// Source data.
  String get parsedContent => content;

  static final Expando<String> _appliedThemeExpando =
      Expando<String>('up_markdown_applied_theme');

  /// Runtime theme override from source `applyTheme`.
  String? get appliedTheme => _appliedThemeExpando[this];

  /// Exposed for tests / host reuse.
  static String toHtml(String md, {bool showLineNumber = false}) {
    return UPMarkdown(content: md, showLineNumber: showLineNumber)._toHtml(md);
  }

  /// Source `parseMarkdown`.
  String parseMarkdown([String? md]) {
    final src = md ?? content;
    if (src.isEmpty) return '';
    return _toHtml(src);
  }

  /// Source `handleCodeBlock`.
  String handleCodeBlock(String code, [String lang = '']) {
    var body = code
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
    if (showLineNumber) {
      final lines = body.split('\n');
      if (lines.isNotEmpty && lines.last.isEmpty) lines.removeLast();
      final numbered = [
        for (var i = 0; i < lines.length; i++) '${i + 1}| ${lines[i]}',
      ].join('\n');
      body = numbered;
    }
    final cls = lang.isEmpty ? '' : ' class="language-$lang"';
    return '<pre><code$cls>$body</code></pre>';
  }

  /// Source `applyTheme`.
  void applyTheme([dynamic theme]) {
    if (theme == null) {
      _appliedThemeExpando[this] = null;
    } else {
      _appliedThemeExpando[this] = '$theme';
    }
  }

  /// Source emit helpers.
  void emitLoad([dynamic event]) => onLoad?.call();
  void emitReady([dynamic event]) => onReady?.call();
  void emitImgtap([dynamic event]) {
    if (event is String) {
      onImgTap?.call(event);
    } else if (event is Map) {
      onImgTap?.call('${event['src'] ?? event['url'] ?? ''}');
    }
  }

  void emitLinktap([dynamic event]) {
    if (event is String) {
      onLinkTap?.call(event);
    } else if (event is Map) {
      onLinkTap?.call('${event['href'] ?? event['url'] ?? ''}');
    }
  }

  void emitPlay([dynamic event]) => onPlay?.call(event ?? true);
  void emitError([dynamic event]) => onError?.call(event ?? true);

  /// Markdown -> HTML.
  ///
  /// The source component delegates parsing to the `marked` library and only
  /// post-processes code blocks, so this uses the Dart `markdown` package the
  /// same way rather than hand-rolling a parser. `gitHubFlavored` is the
  /// extension set whose output matches the source bundle's: GFM tables,
  /// strikethrough, fenced code and task lists, with no heading anchor ids.
  String _toHtml(String source) {
    if (source.isEmpty) return '';
    final html = md.markdownToHtml(
      source,
      extensionSet: md.ExtensionSet.gitHubFlavored,
    );
    return showLineNumber ? _numberCodeBlocks(html) : html;
  }

  /// Source `handleCodeBlock`'s line-number pass, applied to parser output.
  static String _numberCodeBlocks(String html) {
    return html.replaceAllMapped(
      RegExp(r'<pre><code([^>]*)>([\s\S]*?)</code></pre>'),
      (m) {
        final attrs = m.group(1) ?? '';
        final body = m.group(2) ?? '';
        final lines = body.split('\n');
        // Drop the trailing empty entry produced by the final newline.
        if (lines.isNotEmpty && lines.last.isEmpty) lines.removeLast();
        final numbered = <String>[
          for (var i = 0; i < lines.length; i++) '${i + 1}| ${lines[i]}',
        ].join('\n');
        return '<pre><code$attrs>$numbered</code></pre>';
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return UPParse(
      content: _toHtml(content),
      previewImg: previewImg,
      copyLink: copyLink == true || copyLink == 'true',
      domain: domain,
      onLinkTap: onLinkTap,
      onImgTap: onImgTap,
      onLoad: onLoad,
      onReady: onReady,
    );
  }
}
