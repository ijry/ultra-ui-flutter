import 'package:flutter/widgets.dart';

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

  String _toHtml(String md) {
    if (md.isEmpty) return '';
    var s = md.replaceAll('\r\n', '\n');

    // fenced code
    s = s.replaceAllMapped(RegExp(r'```([\w+-]*)\n([\s\S]*?)```'), (m) {
      var code = (m.group(2) ?? '')
          .replaceAll('&', '&amp;')
          .replaceAll('<', '&lt;')
          .replaceAll('>', '&gt;');
      if (showLineNumber) {
        final lines = code.split('\n');
        // drop trailing empty from final newline
        if (lines.isNotEmpty && lines.last.isEmpty) {
          lines.removeLast();
        }
        final numbered = <String>[];
        for (var i = 0; i < lines.length; i++) {
          numbered.add('${i + 1}| ${lines[i]}');
        }
        code = numbered.join('\n');
      }
      final lang = (m.group(1) ?? '').trim();
      final cls = lang.isEmpty ? '' : ' class="language-$lang"';
      return '<pre><code$cls>$code</code></pre>';
    });

    // tables (GFM simple)
    s = s.replaceAllMapped(
      RegExp(
        r'(?:^|\n)(\|[^\n]+\|\n\|[-:\s|]+\|\n(?:\|[^\n]+\|\n?)*)',
        multiLine: true,
      ),
      (m) {
        final block = m.group(1)!.trim();
        final lines =
            block.split('\n').where((e) => e.trim().isNotEmpty).toList();
        if (lines.length < 2) return m.group(0)!;
        final rows = <String>[];
        for (var i = 0; i < lines.length; i++) {
          if (i == 1) continue; // separator
          final cells = lines[i]
              .split('|')
              .where((c) => c.trim().isNotEmpty || c.isNotEmpty)
              .toList();
          // split('|') yields empty ends
          final cleaned = lines[i]
              .trim()
              .replaceAll(RegExp(r'^\|'), '')
              .replaceAll(RegExp(r'\|$'), '')
              .split('|')
              .map((c) => c.trim())
              .toList();
          final tag = i == 0 ? 'th' : 'td';
          final tds = cleaned.map((c) => '<$tag>$c</$tag>').join();
          rows.add('<tr>$tds</tr>');
        }
        return '\n<table>${rows.join()}</table>\n';
      },
    );

    // headings
    s = s.replaceAllMapped(
      RegExp(r'^###### (.+)$', multiLine: true),
      (m) => '<h6>${m.group(1)}</h6>',
    );
    s = s.replaceAllMapped(
      RegExp(r'^##### (.+)$', multiLine: true),
      (m) => '<h5>${m.group(1)}</h5>',
    );
    s = s.replaceAllMapped(
      RegExp(r'^#### (.+)$', multiLine: true),
      (m) => '<h4>${m.group(1)}</h4>',
    );
    s = s.replaceAllMapped(
      RegExp(r'^### (.+)$', multiLine: true),
      (m) => '<h3>${m.group(1)}</h3>',
    );
    s = s.replaceAllMapped(
      RegExp(r'^## (.+)$', multiLine: true),
      (m) => '<h2>${m.group(1)}</h2>',
    );
    s = s.replaceAllMapped(
      RegExp(r'^# (.+)$', multiLine: true),
      (m) => '<h1>${m.group(1)}</h1>',
    );

    // hr
    s = s.replaceAllMapped(
      RegExp(r'^(?:---|\*\*\*|___)\s*$', multiLine: true),
      (_) => '<hr/>',
    );

    // blockquote
    s = s.replaceAllMapped(
      RegExp(r'^> (.+)$', multiLine: true),
      (m) => '<blockquote>${m.group(1)}</blockquote>',
    );

    // task lists
    s = s.replaceAllMapped(
      RegExp(r'^- \[(x|X| )\] (.+)$', multiLine: true),
      (m) {
        final checked = m.group(1)!.toLowerCase() == 'x';
        return '<li data-task="${checked ? '1' : '0'}">${m.group(2)}</li>';
      },
    );

    // images / links
    s = s.replaceAllMapped(
      RegExp(r'!\[([^\]]*)\]\(([^)]+)\)'),
      (m) => '<img src="${m.group(2)}" alt="${m.group(1) ?? ''}"/>',
    );
    s = s.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\(([^)]+)\)'),
      (m) => '<a href="${m.group(2)}">${m.group(1)}</a>',
    );

    // strike / bold / italic / code
    s = s.replaceAllMapped(
      RegExp(r'~~([^~]+)~~'),
      (m) => '<del>${m.group(1)}</del>',
    );
    s = s.replaceAllMapped(
      RegExp(r'\*\*([^*]+)\*\*'),
      (m) => '<strong>${m.group(1)}</strong>',
    );
    s = s.replaceAllMapped(
      RegExp(r'__([^_]+)__'),
      (m) => '<strong>${m.group(1)}</strong>',
    );
    s = s.replaceAllMapped(
      RegExp(r'(?<!\*)\*([^*]+)\*(?!\*)'),
      (m) => '<em>${m.group(1)}</em>',
    );
    s = s.replaceAllMapped(
      RegExp(r'(?<!_)_([^_]+)_(?!_)'),
      (m) => '<em>${m.group(1)}</em>',
    );
    s = s.replaceAllMapped(
      RegExp(r'`([^`]+)`'),
      (m) => '<code>${m.group(1)}</code>',
    );

    // ordered / unordered lists (simple consecutive lines)
    s = s.replaceAllMapped(
      RegExp(r'(?:^|\n)((?:\d+\. .+\n?)+)'),
      (m) {
        final body = m.group(1)!;
        final items = RegExp(r'\d+\. (.+)')
            .allMatches(body)
            .map((x) => '<li>${x.group(1)}</li>')
            .join();
        return '\n<ol>$items</ol>\n';
      },
    );
    s = s.replaceAllMapped(
      RegExp(r'(?:^|\n)((?:(?:- |\* )(?!\[).+\n?)+)'),
      (m) {
        final body = m.group(1)!;
        final items = RegExp(r'[-*] (.+)')
            .allMatches(body)
            .map((x) => '<li>${x.group(1)}</li>')
            .join();
        return '\n<ul>$items</ul>\n';
      },
    );
    // wrap bare task lis
    s = s.replaceAllMapped(
      RegExp(r'(?:^|\n)((?:<li data-task="[01]">.*?</li>\n?)+)'),
      (m) => '\n<ul>${m.group(1)}</ul>\n',
    );

    // paragraphs
    s = s.split(RegExp(r'\n{2,}')).map((p) {
      final t = p.trim();
      if (t.isEmpty) return '';
      if (t.startsWith('<h') ||
          t.startsWith('<pre') ||
          t.startsWith('<ul') ||
          t.startsWith('<ol') ||
          t.startsWith('<blockquote') ||
          t.startsWith('<hr') ||
          t.startsWith('<img') ||
          t.startsWith('<table') ||
          t.startsWith('<li')) {
        return t;
      }
      return '<p>${t.replaceAll('\n', '<br/>')}</p>';
    }).join('\n');
    return s;
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
