import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import 'up_image.dart';

final Expando<Map<String, dynamic>> _upParseState =
    Expando<Map<String, dynamic>>('upParseState');

/// Port of u-parse / up-parse (richer HTML subset).
class UPParse extends StatelessWidget {
  const UPParse({
    super.key,
    this.content = '',
    this.containerStyle,
    this.copyLink = true,
    this.domain = '',
    this.errorImg = '',
    this.lazyLoad = false,
    this.loadingImg = '',
    this.pauseVideo = true,
    this.previewImg = true,
    this.scrollTable = false,
    this.selectable = false,
    this.setTitle = true,
    this.showImgMenu = true,
    this.tagStyle = const {},
    this.useAnchor,
    this.entities = const {},
    this.svgDict = const {},
    this.onLinkTap,
    this.onImgTap,
    this.onLoad,
    this.onReady,
    this.onClick,
    this.onError,
    this.onPlay,
    this.imageSourceResolver,
    this.customStyle,
  });

  /// Source host helper.
  Future<void> setTimeout([dynamic cb, int ms = 0]) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
    if (cb is Function) cb();
  }

  /// Source host helper.
  dynamic resolve([dynamic v]) => v;

  /// Source host helper.
  dynamic reject([dynamic e]) => e;

  /// Source host helper.
  void set([dynamic payload]) {
    _runtime['lastSet'] = payload;
    _runtime['setCount'] = ((_runtime['setCount'] as int?) ?? 0) + 1;
  }

  /// Source host helper.
  void onMessage([dynamic payload]) {
    _runtime['lastMessage'] = payload;
    _runtime['messageCount'] = ((_runtime['messageCount'] as int?) ?? 0) + 1;
  }

  /// Source host helper.
  void hook([dynamic payload]) {
    _runtime['lastHook'] = payload;
    _runtime['hookCount'] = ((_runtime['hookCount'] as int?) ?? 0) + 1;
  }

  dynamic get lastSet => _runtime['lastSet'];
  dynamic get lastMessage => _runtime['lastMessage'];
  dynamic get lastHook => _runtime['lastHook'];
  int get setCount => (_runtime['setCount'] as int?) ?? 0;
  int get messageCount => (_runtime['messageCount'] as int?) ?? 0;
  int get hookCount => (_runtime['hookCount'] as int?) ?? 0;

  final String content;
  final String? containerStyle;
  final bool copyLink;
  final String domain;
  final String errorImg;
  final bool lazyLoad;
  final String loadingImg;
  final bool pauseVideo;
  final bool previewImg;
  final bool scrollTable;
  final bool selectable;
  final bool setTitle;
  final bool showImgMenu;
  final Map tagStyle;
  final bool? useAnchor;

  /// Source retained entity/svg dictionaries.
  final Map entities;
  final Map svgDict;
  final ValueChanged<String>? onLinkTap;
  final ValueChanged<String>? onImgTap;
  final VoidCallback? onLoad;
  final VoidCallback? onReady;

  /// Source emit.
  final VoidCallback? onClick;

  /// Source emit.
  final ValueChanged<dynamic>? onError;

  /// Source emit.
  final ValueChanged<dynamic>? onPlay;

  /// Optionally replaces a normalized HTML image source before it is rendered.
  ///
  /// Leaving this unset preserves the parsed source URL.
  final String Function(String source)? imageSourceResolver;

  /// Source emit alias: imgtap.
  ValueChanged<String>? get onImgtap => onImgTap;

  /// Source emit alias: linktap.
  ValueChanged<String>? get onLinktap => onLinkTap;
  final BoxDecoration? customStyle;

  /// Source `setContent` — returns normalized/parsed content for host reuse.
  String setContent([String? html, bool append = false]) {
    final next = html ?? content;
    if (append && content.isNotEmpty) {
      return '$content$next';
    }
    return next;
  }

  /// Source `getText` — strip tags roughly.
  String getText([String? html]) {
    final raw = html ?? content;
    return raw
        .replaceAll(
            RegExp(r'<script[\s\S]*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<style[\s\S]*?</style>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  /// Source `normalizeHref`.
  String normalizeHref(String href) {
    final h = href.trim();
    if (h.isEmpty) return h;
    if (h.startsWith('//')) return 'https:$h';
    if (h.startsWith('/') && domain.isNotEmpty) {
      final d = domain.endsWith('/')
          ? domain.substring(0, domain.length - 1)
          : domain;
      return '$d$h';
    }
    if (!h.contains('://') &&
        domain.isNotEmpty &&
        !h.startsWith('#') &&
        !h.startsWith('mailto:')) {
      final d = domain.endsWith('/') ? domain : '$domain/';
      return '$d$h';
    }
    return h;
  }

  /// Source `isExternalLink`.
  bool isExternalLink(String href) {
    final h = href.trim().toLowerCase();
    if (h.startsWith('http://') ||
        h.startsWith('https://') ||
        h.startsWith('//')) {
      return true;
    }
    if (h.startsWith('mailto:') || h.startsWith('tel:')) return true;
    return false;
  }

  /// Source `openExternalLink` — normalize then emit linktap.
  Future<void> openExternalLink(String href) async {
    final n = normalizeHref(href);
    if (n.isEmpty) return;
    onLinkTap?.call(n);
  }

  /// Source `navigateTo` (anchor).
  Future<bool> navigateTo([String? id, double offset = 0]) async {
    if (useAnchor == false) return false;
    final target = (id ?? '').trim();
    if (target.isEmpty) return false;
    // Anchor scroll is host-owned; report success when id present.
    return true;
  }

  /// Source `getRect` — accepts optional measured map from host layout.
  Future<Map<String, double>> getRect([Map? measured]) async {
    double numOf(dynamic v) =>
        (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0;
    if (measured != null) {
      return {
        'width': numOf(measured['width']),
        'height': numOf(measured['height']),
        'top': numOf(measured['top'] ?? measured['y']),
        'left': numOf(measured['left'] ?? measured['x']),
      };
    }
    return {'width': 0, 'height': 0, 'top': 0, 'left': 0};
  }

  Map<String, dynamic> get _runtime =>
      _upParseState[this] ??= <String, dynamic>{
        'mediaPaused': false,
        'playbackRate': 1.0,
        'lastFail': null,
        'lastSet': null,
        'lastMessage': null,
        'lastHook': null,
        'setCount': 0,
        'messageCount': 0,
        'hookCount': 0,
      };

  bool get mediaPaused => _runtime['mediaPaused'] == true;
  num get playbackRate => (_runtime['playbackRate'] as num?) ?? 1;
  dynamic get lastFail => _runtime['lastFail'];

  /// Source `pauseMedia` — no media player host in pure parse tree.
  void pauseMedia([dynamic _]) {
    _runtime['mediaPaused'] = true;
  }

  /// Source `setPlaybackRate` — retained for media host wiring.
  void setPlaybackRate([num rate = 1]) {
    _runtime['playbackRate'] = rate;
    _runtime['mediaPaused'] = false;
  }

  /// Source parse helpers (Batch J).
  void fail([dynamic payload]) {
    _runtime['lastFail'] = payload;
    onError?.call(payload);
  }

  void traversal([dynamic nodes, void Function(dynamic)? visitor]) {
    if (nodes is! List || visitor == null) return;
    for (final n in nodes) {
      visitor(n);
      if (n is Map && n['children'] is List) {
        traversal(n['children'], visitor);
      }
    }
  }

  /// Source residual helpers (Batch L).
  String decodeEntity([String? text]) {
    final raw = text ?? content;
    return raw
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }

  Map makeMap([dynamic list, dynamic key = 'name']) {
    final out = <String, dynamic>{};
    if (list is! List) return out;
    for (final item in list) {
      if (item is Map) {
        final k = '${item[key] ?? item['type'] ?? item['name'] ?? ''}';
        if (k.isNotEmpty) out[k] = item;
      } else {
        out['$item'] = item;
      }
    }
    return out;
  }

  List mergeNodes([dynamic a, dynamic b]) {
    final out = <dynamic>[];
    if (a is List) out.addAll(a);
    if (b is List) out.addAll(b);
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final blocks = _parseBlocks(content, domain);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onLoad?.call();
      onReady?.call();
    });
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (final b in blocks) _blockWidget(tokens, b)],
    );
    Widget root = selectable ? SelectionArea(child: child) : child;
    return root;
  }

  Widget _blockWidget(UPThemeTokens tokens, _Block b) {
    switch (b.kind) {
      case 'h1':
      case 'h2':
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
        final size = switch (b.kind) {
          'h1' => 22.0,
          'h2' => 18.0,
          'h3' => 16.0,
          'h4' => 15.0,
          'h5' => 14.0,
          _ => 13.0,
        };
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Text.rich(
            TextSpan(children: _spans(tokens, b.spans)),
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w600,
              color: tokens.mainColor,
              height: 1.4,
            ),
          ),
        );
      case 'quote':
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          decoration: BoxDecoration(
            color: tokens.bgColor,
            border: Border(left: BorderSide(color: tokens.primary, width: 3)),
          ),
          child: Text.rich(
            TextSpan(children: _spans(tokens, b.spans)),
            style: TextStyle(
              fontSize: 14,
              color: tokens.contentColor,
              height: 1.6,
            ),
          ),
        );
      case 'code':
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: tokens.bgColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: tokens.borderColor),
          ),
          child: Text(
            b.text,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: tokens.contentColor,
              height: 1.5,
            ),
          ),
        );
      case 'li':
        final bullet = b.task
            ? (b.taskChecked ? '☑' : '☐')
            : (b.ordered ? '${b.index}.' : '•');
        return Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                child: Text(
                  bullet,
                  key: b.task
                      ? ValueKey(
                          'parse-task-${b.taskChecked ? 1 : 0}-${b.index}',
                        )
                      : null,
                  style: TextStyle(fontSize: 14, color: tokens.mainColor),
                ),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(children: _spans(tokens, b.spans)),
                  style: TextStyle(
                    fontSize: 14,
                    color: tokens.mainColor,
                    height: 1.6,
                    decoration: b.taskChecked
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        );
      case 'img':
        final src = b.href ?? '';
        final imageSrc = imageSourceResolver?.call(src) ?? src;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: previewImg ? () => (onImgTap ?? onLinkTap)?.call(src) : null,
            child: UPImage(
              src: imageSrc,
              mode: 'widthFix',
              showLoading: lazyLoad,
              width: double.infinity,
            ),
          ),
        );
      case 'video':
        final src = b.href ?? '';
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            key: ValueKey('parse-video-$src'),
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: tokens.borderColor),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  pauseVideo
                      ? Icons.play_circle_outline
                      : Icons.pause_circle_outline,
                  size: 56,
                  color: Colors.white70,
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 10,
                  child: Text(
                    src.isEmpty ? 'video' : src,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      case 'hr':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Divider(height: 1, color: tokens.borderColor),
        );
      case 'table':
        final rows = _normalizedTableRows(b.rows);
        final table = Table(
          border: TableBorder.all(color: tokens.borderColor, width: 0.5),
          children: [
            for (final row in rows)
              TableRow(
                children: [
                  for (final cell in row)
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Text.rich(
                        TextSpan(children: _spans(tokens, cell)),
                        style: TextStyle(fontSize: 13, color: tokens.mainColor),
                      ),
                    ),
                ],
              ),
          ],
        );
        final wrapped = scrollTable
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: table,
              )
            : table;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: wrapped,
        );
      default:
        if (b.spans.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text.rich(
            TextSpan(children: _spans(tokens, b.spans)),
            style:
                TextStyle(fontSize: 14, color: tokens.mainColor, height: 1.6),
          ),
        );
    }
  }

  List<InlineSpan> _spans(UPThemeTokens tokens, List<_Span> items) {
    return [
      for (final n in items)
        if (n.href != null)
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onLinkTap?.call(n.href!),
              child: Text(
                n.text,
                style: TextStyle(
                  fontSize: 14,
                  color: tokens.primary,
                  decoration: TextDecoration.underline,
                  fontWeight: n.bold ? FontWeight.w600 : FontWeight.normal,
                  fontStyle: n.italic ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
          )
        else
          TextSpan(
            text: n.text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: n.bold ? FontWeight.w600 : FontWeight.normal,
              fontStyle: n.italic ? FontStyle.italic : FontStyle.normal,
              decoration:
                  n.strike ? TextDecoration.lineThrough : TextDecoration.none,
              color: n.code ? tokens.contentColor : tokens.mainColor,
              fontFamily: n.code ? 'monospace' : null,
              backgroundColor: n.code ? tokens.bgColor : null,
            ),
          ),
    ];
  }
}

class _Span {
  _Span(
    this.text, {
    this.bold = false,
    this.italic = false,
    this.code = false,
    this.strike = false,
    this.href,
  });
  final String text;
  final bool bold;
  final bool italic;
  final bool code;
  final bool strike;
  final String? href;
}

class _Block {
  _Block(
    this.kind, {
    this.spans = const [],
    this.text = '',
    this.href,
    this.ordered = false,
    this.index = 1,
    this.rows = const [],
    this.task = false,
    this.taskChecked = false,
  });
  final String kind;
  final List<_Span> spans;
  final String text;
  final String? href;
  final bool ordered;
  final int index;
  final List<List<_Span>> rows;
  final bool task;
  final bool taskChecked;
}

List<List<_Span>> _splitCells(List<_Span> row) {
  final cells = <List<_Span>>[];
  var cur = <_Span>[];
  for (final s in row) {
    if (s.text == '\u0001') {
      cells.add(cur);
      cur = <_Span>[];
    } else {
      cur.add(s);
    }
  }
  cells.add(cur);
  return cells.where((c) => c.isNotEmpty).toList();
}

/// Flutter [Table] requires a rectangular grid. HTML permits colspan and
/// rowspan, so source rows can contain fewer explicit cells. Fill the omitted
/// slots after parsing to retain the source cell content without invalidating
/// the Flutter layout contract.
List<List<List<_Span>>> _normalizedTableRows(List<List<_Span>> rows) {
  final cellsByRow = <List<List<_Span>>>[
    for (final row in rows) _splitCells(row),
  ];
  final columnCount = cellsByRow.fold<int>(
    0,
    (maxColumns, cells) =>
        cells.length > maxColumns ? cells.length : maxColumns,
  );
  if (columnCount == 0) return const <List<List<_Span>>>[];

  return <List<List<_Span>>>[
    for (final cells in cellsByRow)
      <List<_Span>>[
        ...cells,
        for (var index = cells.length; index < columnCount; index++)
          const <_Span>[],
      ],
  ];
}

List<_Block> _parseBlocks(String html, String domain) {
  if (html.trim().isEmpty) return const [];
  var s = html.replaceAll('\r\n', '\n');
  final out = <_Block>[];

  String absUrl(String src) {
    if (src.isEmpty) return src;
    if (src.startsWith('http') ||
        src.startsWith('data:') ||
        src.startsWith('//')) {
      return src;
    }
    if (domain.isEmpty) return src;
    return src.startsWith('/') ? '$domain$src' : '$domain/$src';
  }

  String decode(String t) => t
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&nbsp;', ' ');

  String? attr(String attrs, String name) {
    final dq = RegExp(
      name + r'\s*=\s*"([^"]+)"',
      caseSensitive: false,
    ).firstMatch(attrs);
    if (dq != null) return dq.group(1);
    final sq = RegExp(
      name + r"\s*=\s*'([^']+)'",
      caseSensitive: false,
    ).firstMatch(attrs);
    return sq?.group(1);
  }

  List<_Span> inlines(String raw) {
    final t = raw
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n');
    final nodes = <_Span>[];
    final re = RegExp(
      r'<(a|b|strong|i|em|code|del|s|strike)([^>]*)>([\s\S]*?)</\1>|([^<]+)',
      caseSensitive: false,
    );
    for (final m in re.allMatches(t)) {
      if (m.group(4) != null) {
        final text = decode(m.group(4)!);
        if (text.isNotEmpty) nodes.add(_Span(text));
        continue;
      }
      final tag = (m.group(1) ?? '').toLowerCase();
      final attrs = m.group(2) ?? '';
      final inner = decode(
        (m.group(3) ?? '').replaceAll(RegExp(r'<[^>]+>'), ''),
      );
      if (inner.isEmpty) continue;
      nodes.add(
        _Span(
          inner,
          bold: tag == 'b' || tag == 'strong',
          italic: tag == 'i' || tag == 'em',
          code: tag == 'code',
          strike: tag == 'del' || tag == 's' || tag == 'strike',
          href: tag == 'a' ? absUrl(attr(attrs, 'href') ?? '') : null,
        ),
      );
    }
    if (nodes.isEmpty) {
      final text = decode(t.replaceAll(RegExp(r'<[^>]+>'), ''));
      if (text.isNotEmpty) nodes.add(_Span(text));
    }
    return nodes;
  }

  s = s.replaceAllMapped(
    RegExp(
      r'<pre[^>]*>\s*<code[^>]*>([\s\S]*?)</code>\s*</pre>|<pre[^>]*>([\s\S]*?)</pre>',
      caseSensitive: false,
    ),
    (m) {
      out.add(
        _Block(
          'code',
          text: decode(
            (m.group(1) ?? m.group(2) ?? '').replaceAll(RegExp(r'<[^>]+>'), ''),
          ).trimRight(),
        ),
      );
      return '\n';
    },
  );

  s = s.replaceAllMapped(
    RegExp(r'<table[^>]*>([\s\S]*?)</table>', caseSensitive: false),
    (m) {
      final trueRows = <List<_Span>>[];
      for (final rm in RegExp(
        r'<tr[^>]*>([\s\S]*?)</tr>',
        caseSensitive: false,
      ).allMatches(m.group(1) ?? '')) {
        final rowSpans = <_Span>[];
        var first = true;
        for (final cm in RegExp(
          r'<t[hd][^>]*>([\s\S]*?)</t[hd]>',
          caseSensitive: false,
        ).allMatches(rm.group(1) ?? '')) {
          if (!first) rowSpans.add(_Span('\u0001'));
          rowSpans.addAll(inlines(cm.group(1) ?? ''));
          first = false;
        }
        if (rowSpans.isNotEmpty) trueRows.add(rowSpans);
      }
      out.add(_Block('table', rows: trueRows));
      return '\n';
    },
  );

  s = s.replaceAllMapped(
    RegExp(r'<img\b([^>]*)/?>', caseSensitive: false),
    (m) {
      out.add(_Block('img', href: absUrl(attr(m.group(1) ?? '', 'src') ?? '')));
      return '\n';
    },
  );

  s = s.replaceAllMapped(
    RegExp(
      r'<video\b([^>]*)>([\s\S]*?)</video>|<video\b([^>]*)/?>',
      caseSensitive: false,
    ),
    (m) {
      final attrs = m.group(1) ?? m.group(3) ?? '';
      var src = attr(attrs, 'src') ?? '';
      if (src.isEmpty) {
        final source = RegExp(
          r'<source\b([^>]*)/?>',
          caseSensitive: false,
        ).firstMatch(m.group(2) ?? '');
        if (source != null) {
          src = attr(source.group(1) ?? '', 'src') ?? '';
        }
      }
      out.add(_Block('video', href: absUrl(src)));
      return '\n';
    },
  );

  s = s.replaceAllMapped(RegExp(r'<hr\s*/?>', caseSensitive: false), (m) {
    out.add(_Block('hr'));
    return '\n';
  });

  for (final lvl in [1, 2, 3, 4, 5, 6]) {
    s = s.replaceAllMapped(
      RegExp('<h$lvl[^>]*>([\\s\\S]*?)</h$lvl>', caseSensitive: false),
      (m) {
        out.add(_Block('h$lvl', spans: inlines(m.group(1) ?? '')));
        return '\n';
      },
    );
  }

  s = s.replaceAllMapped(
    RegExp(
      r'<blockquote[^>]*>([\s\S]*?)</blockquote>',
      caseSensitive: false,
    ),
    (m) {
      out.add(_Block('quote', spans: inlines(m.group(1) ?? '')));
      return '\n';
    },
  );

  s = s.replaceAllMapped(
    RegExp(r'<(ul|ol)[^>]*>([\s\S]*?)</\1>', caseSensitive: false),
    (m) {
      final ordered = (m.group(1) ?? '').toLowerCase() == 'ol';
      var i = 1;
      for (final lm in RegExp(
        r'<li([^>]*)>([\s\S]*?)</li>',
        caseSensitive: false,
      ).allMatches(m.group(2) ?? '')) {
        final attrs = lm.group(1) ?? '';
        final body = lm.group(2) ?? '';
        final taskAttr = attr(attrs, 'data-task');
        final hasCheckbox = RegExp(
          'type\\s*=\\s*["\']checkbox["\']',
          caseSensitive: false,
        ).hasMatch(body);
        final task = taskAttr != null || hasCheckbox;
        var checked = taskAttr == '1' || taskAttr == 'true';
        if (hasCheckbox) {
          checked = checked ||
              RegExp(r'\bchecked\b', caseSensitive: false).hasMatch(body);
        }
        final cleaned = body.replaceAll(
          RegExp(r'<input\b[^>]*>', caseSensitive: false),
          '',
        );
        out.add(
          _Block(
            'li',
            spans: inlines(cleaned),
            ordered: ordered && !task,
            index: i++,
            task: task,
            taskChecked: checked,
          ),
        );
      }
      return '\n';
    },
  );

  final chunks = s.split(
    RegExp(r'</p>|<p[^>]*>|\n{2,}', caseSensitive: false),
  );
  for (final c in chunks) {
    final spans = inlines(c);
    if (spans.isNotEmpty && spans.any((e) => e.text.trim().isNotEmpty)) {
      out.add(_Block('p', spans: spans));
    }
  }

  if (out.isEmpty) {
    final spans = inlines(html);
    if (spans.isNotEmpty) out.add(_Block('p', spans: spans));
  }
  return out;
}
