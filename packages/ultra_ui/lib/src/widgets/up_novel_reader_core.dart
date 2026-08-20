import 'dart:convert';

/// Pure logic ported from the u-novel-reader support modules:
/// `reader-core.js`, `content-normalizer.js`, `measure-adapter.js`,
/// `layout-engine.js` and `persistence.js`.
///
/// These are separate ES modules in the source, so they stay separate here and
/// are exported for host reuse and testing. Everything in this file is pure —
/// no widgets, no platform access.

// ---------------------------------------------------------------------------
// JS numeric semantics
// ---------------------------------------------------------------------------

/// Marker for a *missing* map key, which JS reads as `undefined`.
///
/// Dart has one `null` where JS distinguishes `undefined` from `null`, and the
/// source relies on the difference: `Number(undefined)` is `NaN` (not finite)
/// while `Number(null)` is `0` (finite). Reading an absent key through
/// [jsProp] yields this marker so [jsNumber] can reproduce both branches.
const Object jsUndefined = _JsUndefined();

class _JsUndefined {
  const _JsUndefined();
  @override
  String toString() => 'undefined';
}

/// Reads `map[key]` with JS property semantics: an absent key is `undefined`,
/// a present key holding null is `null`.
dynamic jsProp(Map<dynamic, dynamic>? map, String key) {
  if (map == null) return jsUndefined;
  return map.containsKey(key) ? map[key] : jsUndefined;
}

/// Models the source's `container && container.key` guard.
///
/// JS returns the falsy container itself when it is null/undefined, so a null
/// container yields `null` (and `Number(null)` is `0`, which is finite), while a
/// present container with an absent key yields `undefined` (`NaN`, not finite).
/// The two branches take different paths in `normalizeProgress`.
dynamic jsAndProp(Map<dynamic, dynamic>? map, String key) {
  if (map == null) return null;
  return jsProp(map, key);
}

/// JS `Number(value)`. Returns null where JS yields `NaN`.
num? jsNumber(dynamic value) {
  if (value is _JsUndefined) return null; // Number(undefined) === NaN
  if (value == null) return 0; // Number(null) === 0
  if (value is num) return value.isNaN ? null : value;
  if (value is bool) return value ? 1 : 0;
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 0; // Number('') === 0
    return num.tryParse(trimmed);
  }
  return null; // Number({}) === NaN
}

/// JS `Number.isFinite(Number(value))`.
bool jsIsFinite(dynamic value) {
  final n = jsNumber(value);
  return n != null && n.isFinite;
}

/// JS `Number(value) || fallback` — note 0 is falsy, so it also falls back.
num jsNumberOr(dynamic value, num fallback) {
  final n = jsNumber(value);
  if (n == null || !n.isFinite || n == 0) return fallback;
  return n;
}

/// JS `Number.parseFloat(value)`, used by `measure-adapter.js`.
num? jsParseFloat(dynamic value) {
  if (value is num) return value.isNaN ? null : value;
  if (value == null) return null;
  final match = RegExp(r'^[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?')
      .firstMatch('$value'.trim());
  if (match == null) return null;
  return num.tryParse(match.group(0)!);
}

/// JS truthiness, used to mirror `if (!value)` and `sources.filter(Boolean)`.
bool jsTruthy(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is num) return value != 0 && !value.isNaN;
  if (value is String) return value.isNotEmpty;
  return true;
}

/// Splits a string into JS-iteration units (code points), each carrying the
/// UTF-16 length JS reports for it.
List<String> jsChars(String text) =>
    text.runes.map((r) => String.fromCharCode(r)).toList();

// ---------------------------------------------------------------------------
// reader-core.js
// ---------------------------------------------------------------------------

/// Source `DEFAULT_READER_SETTINGS`.
const Map<String, dynamic> kDefaultReaderSettings = <String, dynamic>{
  'theme': 'day',
  'fontSize': 18,
  'lineHeight': 1.8,
  'paragraphSpacing': 16,
  'contentWidth': '92%',
  'fontFamily': 'system',
  'fontWeight': 400,
  'animation': true,
};

const List<String> kReaderSettingKeys = <String>[
  'theme',
  'fontSize',
  'lineHeight',
  'paragraphSpacing',
  'contentWidth',
  'fontFamily',
  'fontWeight',
  'animation',
];

const List<String> kAllowedReaderModes = <String>['scroll', 'page'];

num _clamp(dynamic value, num min, num max, num fallback) {
  final n = jsNumber(value);
  if (n == null || !n.isFinite) return fallback;
  if (n > max) return max;
  if (n < min) return min;
  return n;
}

dynamic _normalizeContentWidth(dynamic value) {
  if (value is num) return _clamp(value, 40, 100, 92);
  if (value is String && value.trim().isNotEmpty) return value.trim();
  return kDefaultReaderSettings['contentWidth'];
}

/// Source `mergeReaderSettings(...sources)`.
Map<String, dynamic> mergeReaderSettings(List<Map<String, dynamic>?> sources) {
  final result = Map<String, dynamic>.from(kDefaultReaderSettings);
  for (final source in sources) {
    if (source == null) continue;
    for (final key in kReaderSettingKeys) {
      if (source.containsKey(key) && source[key] != null) {
        result[key] = source[key];
      }
    }
  }
  result['fontSize'] = _clamp(
      result['fontSize'], 12, 48, kDefaultReaderSettings['fontSize'] as num);
  result['lineHeight'] = _clamp(
      result['lineHeight'], 1, 3, kDefaultReaderSettings['lineHeight'] as num);
  result['paragraphSpacing'] = _clamp(result['paragraphSpacing'], 0, 80,
      kDefaultReaderSettings['paragraphSpacing'] as num);
  result['contentWidth'] = _normalizeContentWidth(result['contentWidth']);
  // Source: result.fontWeight >= 600 ? 600 : 400 — a non-numeric compare is
  // false in JS, so anything unparseable lands on 400.
  final weight = jsNumber(result['fontWeight']);
  result['fontWeight'] =
      (weight != null && weight.isFinite && weight >= 600) ? 600 : 400;
  result['animation'] = result['animation'] != false;
  return result;
}

/// Source `normalizeMode`.
String normalizeReaderMode(dynamic mode) =>
    kAllowedReaderModes.contains(mode) ? '$mode' : 'scroll';

/// Source `createBookmark`.
Map<String, dynamic> createBookmark({
  dynamic chapterId,
  dynamic chapterIndex,
  dynamic charOffset,
  dynamic pageIndex,
  dynamic scrollTop,
  dynamic excerpt,
  dynamic createdAt,
  required int nowMs,
}) {
  final normalizedChapterId = chapterId == null ? '' : '$chapterId';
  final normalizedOffset = _maxZero(charOffset);
  return <String, dynamic>{
    'id': '$normalizedChapterId:$normalizedOffset',
    'chapterId': chapterId,
    'chapterIndex': _numberOrZero(chapterIndex),
    'charOffset': normalizedOffset,
    'pageIndex': _maxZero(pageIndex),
    'scrollTop': _maxZero(scrollTop),
    'excerpt': jsTruthy(excerpt) ? excerpt : '',
    'createdAt':
        _numberOrZero(createdAt) != 0 ? _numberOrZero(createdAt) : nowMs,
  };
}

/// Source `toggleBookmark`.
List<Map<String, dynamic>> toggleBookmark(
  List<Map<String, dynamic>>? bookmarks,
  Map<String, dynamic>? bookmark,
) {
  final list = List<Map<String, dynamic>>.from(bookmarks ?? const []);
  final id = bookmark?['id'];
  if (!jsTruthy(id)) return list;
  final existing = list.indexWhere((item) => item['id'] == id);
  if (existing == -1) return <Map<String, dynamic>>[...list, bookmark!];
  return <Map<String, dynamic>>[
    for (var i = 0; i < list.length; i++)
      if (i != existing) list[i],
  ];
}

// JS `Math.max(0, Number(x) || 0)`.
num _maxZero(dynamic value) {
  final n = jsNumber(value);
  if (n == null || !n.isFinite || n == 0) return 0;
  return n < 0 ? 0 : n;
}

// JS `Number(x) || 0`.
num _numberOrZero(dynamic value) {
  final n = jsNumber(value);
  if (n == null || !n.isFinite) return 0;
  return n;
}

// ---------------------------------------------------------------------------
// content-normalizer.js
// ---------------------------------------------------------------------------

final RegExp _lineBreakPattern = RegExp(r'\r\n|\r|\n');

/// One paragraph of normalized chapter content.
class UPNovelParagraph {
  const UPNovelParagraph({
    required this.index,
    required this.text,
    required this.startOffset,
    required this.endOffset,
  });

  final int index;
  final String text;
  final int startOffset;
  final int endOffset;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'index': index,
        'text': text,
        'startOffset': startOffset,
        'endOffset': endOffset,
      };
}

/// Result of source `normalizeContent`.
class UPNovelContent {
  const UPNovelContent({
    required this.paragraphs,
    required this.text,
    required this.length,
  });

  const UPNovelContent.empty()
      : paragraphs = const <UPNovelParagraph>[],
        text = '',
        length = 0;

  final List<UPNovelParagraph> paragraphs;
  final String text;
  final int length;
}

List<String> _normalizeParagraphs(dynamic content) {
  final values = content is List ? content : <dynamic>[content ?? ''];
  final paragraphs = <String>[];
  for (final value in values) {
    paragraphs.addAll('${value ?? ''}'.split(_lineBreakPattern));
  }
  return paragraphs;
}

/// Source `normalizeContent`.
UPNovelContent normalizeContent(dynamic content) {
  final sourceParagraphs = _normalizeParagraphs(content);
  final hasContent = sourceParagraphs.any((text) => text.isNotEmpty);
  if (!hasContent) return const UPNovelContent.empty();

  var offset = 0;
  final paragraphs = <UPNovelParagraph>[];
  for (var i = 0; i < sourceParagraphs.length; i++) {
    final text = sourceParagraphs[i];
    final startOffset = offset;
    final endOffset = startOffset + text.length;
    // Source advances past the joining newline.
    offset = endOffset + 1;
    paragraphs.add(UPNovelParagraph(
      index: i,
      text: text,
      startOffset: startOffset,
      endOffset: endOffset,
    ));
  }
  final text = paragraphs.map((p) => p.text).join('\n');
  return UPNovelContent(
    paragraphs: paragraphs,
    text: text,
    length: text.length,
  );
}

/// Source `normalizeProgress`.
Map<String, dynamic> normalizeProgress(
  Map<String, dynamic>? progress,
  Map<String, dynamic>? chapter,
) {
  final normalizedContent = normalizeContent(jsAndProp(chapter, 'content'));
  final contentLength = normalizedContent.length;
  final requestedOffset = jsNumber(jsAndProp(progress, 'charOffset'));
  final rawOffset = (requestedOffset != null && requestedOffset.isFinite)
      ? requestedOffset
      : 0;
  final charOffset = rawOffset < 0
      ? 0
      : (rawOffset > contentLength ? contentLength : rawOffset);
  final requestedPageIndex = jsNumber(jsAndProp(progress, 'pageIndex'));
  // Source: Number(chapter && chapter.index) — absent is undefined -> NaN.
  final chapterIndex = jsNumber(jsAndProp(chapter, 'index'));

  return <String, dynamic>{
    'chapterId': progress?['chapterId'] ?? chapter?['id'] ?? '',
    'chapterIndex': (chapterIndex != null && chapterIndex.isFinite)
        ? chapterIndex
        : _numberOrZero(jsAndProp(progress, 'chapterIndex')),
    'pageIndex': (requestedPageIndex != null && requestedPageIndex.isFinite)
        ? (requestedPageIndex < 0 ? 0 : requestedPageIndex)
        : 0,
    'pageCount': _maxZero(jsAndProp(progress, 'pageCount')),
    'charOffset': charOffset,
    'chapterProgress':
        contentLength == 0 ? 0 : (charOffset / contentLength).clamp(0, 1),
    'totalProgress': _maxZero(jsAndProp(progress, 'totalProgress')).clamp(0, 1),
    'scrollTop': _maxZero(jsAndProp(progress, 'scrollTop')),
    'updatedAt': _numberOrZero(jsAndProp(progress, 'updatedAt')),
  };
}

// ---------------------------------------------------------------------------
// measure-adapter.js
// ---------------------------------------------------------------------------

/// Source CJK test used by both the measurer and the tokenizer:
/// `/[㐀-鿿぀-ヿ＀-￯]/`.
///
/// Note the ranges start at U+3400, so CJK punctuation in U+3000–U+33FF
/// (`。`U+3002, `、`U+3001, `《`U+300A …) is NOT matched and measures at the
/// 0.56x Latin width. Fullwidth forms (U+FF00–U+FFEF, incl. `，`U+FF0C) are.
/// This quirk changes where lines break, so it is reproduced exactly.
final RegExp kNovelCjkPattern = RegExp('[㐀-鿿぀-ヿ＀-￯]');

final RegExp _wsPattern = RegExp(r'\s');

num _getFontSize(Map<String, dynamic>? style) {
  final parsed = jsParseFloat(style?['fontSize']);
  return (parsed != null && parsed.isFinite) ? parsed : 18;
}

/// Source `getCharacterWidth`.
///
/// A deliberate heuristic, not real text metrics — the shipped component uses
/// this rather than the optional canvas path, so pagination must match it.
num novelCharacterWidth(String character, num fontSize) {
  if (kNovelCjkPattern.hasMatch(character)) return fontSize;
  if (_wsPattern.hasMatch(character)) return fontSize * 0.28;
  return fontSize * 0.56;
}

/// Source `measureTextWidth`.
num measureTextWidth(String text, [Map<String, dynamic>? style]) {
  final fontSize = _getFontSize(style);
  var width = 0.0;
  for (final ch in jsChars(text)) {
    width += novelCharacterWidth(ch, fontSize);
  }
  return width;
}

// ---------------------------------------------------------------------------
// layout-engine.js
// ---------------------------------------------------------------------------

/// A tokenizer/wrap unit or a wrapped line.
class UPNovelLine {
  const UPNovelLine({
    required this.text,
    required this.startOffset,
    required this.endOffset,
    this.paragraphIndex,
  });

  final String text;
  final int startOffset;
  final int endOffset;
  final int? paragraphIndex;

  UPNovelLine shifted(int delta, int paragraphIndex) => UPNovelLine(
        text: text,
        startOffset: startOffset + delta,
        endOffset: endOffset + delta,
        paragraphIndex: paragraphIndex,
      );
}

List<UPNovelLine> _tokenizeText(String text) {
  final units = <UPNovelLine>[];
  var token = '';
  var tokenStart = 0;
  var offset = 0;

  void flushToken() {
    if (token.isNotEmpty) {
      units.add(UPNovelLine(
        text: token,
        startOffset: tokenStart,
        endOffset: offset,
      ));
      token = '';
    }
  }

  for (final character in jsChars(text)) {
    final startOffset = offset;
    offset += character.length;
    if (kNovelCjkPattern.hasMatch(character) ||
        _wsPattern.hasMatch(character)) {
      flushToken();
      units.add(UPNovelLine(
        text: character,
        startOffset: startOffset,
        endOffset: offset,
      ));
      tokenStart = offset;
      continue;
    }
    if (token.isEmpty) tokenStart = startOffset;
    token += character;
  }
  flushToken();
  return units;
}

List<UPNovelLine> _splitUnit(UPNovelLine unit) {
  if (unit.text.length <= 1) return <UPNovelLine>[unit];
  final result = <UPNovelLine>[];
  var offset = unit.startOffset;
  for (final character in jsChars(unit.text)) {
    final nextOffset = offset + character.length;
    result.add(UPNovelLine(
      text: character,
      startOffset: offset,
      endOffset: nextOffset,
    ));
    offset = nextOffset;
  }
  return result;
}

UPNovelLine _lineFromUnits(List<UPNovelLine> units) => UPNovelLine(
      text: units.map((u) => u.text).join(),
      startOffset: units.first.startOffset,
      endOffset: units.last.endOffset,
    );

/// Source `wrapText`.
List<UPNovelLine> wrapText(
  dynamic text,
  num width, [
  num Function(String text)? measureText,
]) {
  final source = '${text ?? ''}';
  final measure = measureText ?? ((String t) => measureTextWidth(t));
  if (source.isEmpty) {
    return const <UPNovelLine>[
      UPNovelLine(text: '', startOffset: 0, endOffset: 0),
    ];
  }

  final units = <UPNovelLine>[];
  for (final unit in _tokenizeText(source)) {
    if (measure(unit.text) > width && unit.text.length > 1) {
      units.addAll(_splitUnit(unit));
    } else {
      units.add(unit);
    }
  }

  final lines = <UPNovelLine>[];
  var currentUnits = <UPNovelLine>[];
  for (final unit in units) {
    final candidateUnits = <UPNovelLine>[...currentUnits, unit];
    final candidateText = candidateUnits.map((u) => u.text).join();
    if (currentUnits.isNotEmpty && measure(candidateText) > width) {
      lines.add(_lineFromUnits(currentUnits));
      currentUnits = <UPNovelLine>[unit];
    } else {
      currentUnits = candidateUnits;
    }
  }
  if (currentUnits.isNotEmpty) lines.add(_lineFromUnits(currentUnits));
  return lines;
}

/// Source `getLineHeight`.
num novelLineHeight(Map<String, dynamic> layout) {
  final fontSize = jsNumberOr(jsProp(layout, 'fontSize'), 18);
  final lineHeight = jsNumber(jsProp(layout, 'lineHeight'));
  if (lineHeight == null || !lineHeight.isFinite) return fontSize * 1.8;
  // <= 4 is treated as a multiplier, above that as absolute px.
  return lineHeight <= 4 ? fontSize * lineHeight : lineHeight;
}

/// One paginated page.
class UPNovelPage {
  const UPNovelPage({
    required this.index,
    required this.text,
    required this.lines,
    required this.startOffset,
    required this.endOffset,
  });

  final int index;
  final String text;
  final List<UPNovelLine> lines;
  final int startOffset;
  final int endOffset;
}

/// Result of source `paginateParagraphs`.
class UPNovelLayout {
  const UPNovelLayout({
    required this.pages,
    required this.pageCount,
    required this.charOffsetToPage,
  });

  const UPNovelLayout.empty()
      : pages = const <UPNovelPage>[],
        pageCount = 0,
        charOffsetToPage = const <Map<String, dynamic>>[];

  final List<UPNovelPage> pages;
  final int pageCount;
  final List<Map<String, dynamic>> charOffsetToPage;
}

/// Source `paginateParagraphs`.
///
/// [paragraphs] accepts [UPNovelParagraph], plain strings, or maps, matching
/// the source's string/object normalization.
UPNovelLayout paginateParagraphs(
  List<dynamic> paragraphs,
  Map<String, dynamic> layout,
) {
  final width = _atLeastOne(jsNumberOr(jsProp(layout, 'width'), 320));
  final height = _atLeastOne(jsNumberOr(jsProp(layout, 'height'), 500));
  final lineHeight = _atLeastOne(novelLineHeight(layout));
  final rawSpacing = jsNumberOr(jsProp(layout, 'paragraphSpacing'), 0);
  final paragraphSpacing = rawSpacing < 0 ? 0 : rawSpacing;
  final custom = layout['measureText'];
  final measure = custom is num Function(String)
      ? custom
      : (String text) => measureTextWidth(text, layout);

  final pages = <UPNovelPage>[];
  var lines = <UPNovelLine>[];
  num usedHeight = 0;

  void flushPage() {
    if (lines.isNotEmpty) {
      pages.add(UPNovelPage(
        index: pages.length,
        text: lines.map((l) => l.text).join('\n'),
        lines: List<UPNovelLine>.from(lines),
        startOffset: lines.first.startOffset,
        endOffset: lines.last.endOffset,
      ));
    }
    lines = <UPNovelLine>[];
    usedHeight = 0;
  }

  for (var paragraphIndex = 0;
      paragraphIndex < paragraphs.length;
      paragraphIndex++) {
    final raw = paragraphs[paragraphIndex];
    final String pText;
    final int pStart;
    if (raw is String) {
      pText = raw;
      pStart = 0;
    } else if (raw is UPNovelParagraph) {
      pText = raw.text;
      pStart = raw.startOffset;
    } else if (raw is Map) {
      pText = '${raw['text'] ?? ''}';
      // Source: line.startOffset + (paragraph.startOffset || 0)
      pStart = _numberOrZero(raw['startOffset']).toInt();
    } else {
      pText = '';
      pStart = 0;
    }

    final paragraphLines = wrapText(pText, width, measure)
        .map((line) => line.shifted(pStart, paragraphIndex))
        .toList();

    if (paragraphIndex > 0 &&
        lines.isNotEmpty &&
        usedHeight + paragraphSpacing + lineHeight > height) {
      // Source drops the spacing when the gap itself forces a page break.
      flushPage();
    } else if (paragraphIndex > 0 && lines.isNotEmpty) {
      usedHeight += paragraphSpacing;
    }

    for (final line in paragraphLines) {
      if (lines.isNotEmpty && usedHeight + lineHeight > height) flushPage();
      lines.add(line);
      usedHeight += lineHeight;
    }
  }
  flushPage();

  return UPNovelLayout(
    pages: pages,
    pageCount: pages.length,
    charOffsetToPage: pages
        .map((page) => <String, dynamic>{
              'pageIndex': page.index,
              'startOffset': page.startOffset,
              'endOffset': page.endOffset,
            })
        .toList(),
  );
}

num _atLeastOne(num value) => value < 1 ? 1 : value;

/// Source `resolveAnchor`.
Map<String, num> resolveAnchor(List<UPNovelPage> pages, dynamic charOffset) {
  if (pages.isEmpty) {
    return <String, num>{'pageIndex': 0, 'localOffset': 0};
  }
  final offset = _maxZero(charOffset);
  final page = pages.firstWhere(
    (item) => offset <= item.endOffset,
    orElse: () => pages.last,
  );
  var local = offset - page.startOffset;
  if (local < 0) local = 0;
  if (local > page.text.length) local = page.text.length;
  return <String, num>{'pageIndex': page.index, 'localOffset': local};
}

/// Source `createLayoutKey`. Unused by the source component, kept as a memo
/// key for the Flutter port and for API parity.
String createLayoutKey({
  dynamic chapterId = '',
  Map<String, dynamic> settings = const <String, dynamic>{},
  num width = 0,
  num height = 0,
}) {
  return jsonEncode(<String, dynamic>{
    'chapterId': chapterId,
    'width': width,
    'height': height,
    'fontSize': settings['fontSize'],
    'lineHeight': settings['lineHeight'],
    'paragraphSpacing': settings['paragraphSpacing'],
    'contentWidth': settings['contentWidth'],
    'fontFamily': settings['fontFamily'],
    'fontWeight': settings['fontWeight'],
  });
}

// ---------------------------------------------------------------------------
// persistence.js
// ---------------------------------------------------------------------------

/// Source `STORAGE_VERSION`.
const int kNovelReaderStorageVersion = 1;

/// Source `DEFAULT_STORAGE_PREFIX`.
const String kNovelReaderStoragePrefix = 'uview-plus:novel-reader:';

/// Source `createStorageKey`. An empty result disables persistence.
String createNovelStorageKey({dynamic storageKey, dynamic bookId}) {
  if (jsTruthy(storageKey)) return '$storageKey';
  if (bookId == null || '$bookId'.isEmpty) return '';
  return '$kNovelReaderStoragePrefix$bookId';
}

bool _isPlainObject(dynamic value) => value is Map;

Map<String, dynamic>? _normalizePersistedProgress(dynamic progress) {
  if (!_isPlainObject(progress)) return null;
  final map = progress as Map;
  for (final key in const [
    'chapterIndex',
    'pageIndex',
    'pageCount',
    'charOffset',
    'scrollTop',
  ]) {
    if (!map.containsKey(key) || map[key] == null) continue;
    final n = jsNumber(map[key]);
    if (n == null || !n.isFinite || n < 0) return null;
  }
  for (final key in const ['chapterProgress', 'totalProgress']) {
    if (!map.containsKey(key) || map[key] == null) continue;
    final n = jsNumber(map[key]);
    if (n == null || !n.isFinite || n < 0 || n > 1) return null;
  }
  return <String, dynamic>{
    ...Map<String, dynamic>.from(map),
    'pageIndex': _maxZero(map['pageIndex']),
    'pageCount': _maxZero(map['pageCount']),
    'charOffset': _maxZero(map['charOffset']),
    'scrollTop': _maxZero(map['scrollTop']),
  };
}

/// Source `normalizePersistedState`. Returns null for anything invalid, which
/// makes the caller purge the key.
Map<String, dynamic>? normalizePersistedState(dynamic raw) {
  dynamic value = raw;
  if (value is String) {
    try {
      value = jsonDecode(value);
    } catch (_) {
      return null;
    }
  }
  if (!_isPlainObject(value)) return null;
  final map = value as Map;
  if (jsNumber(map['version']) != kNovelReaderStorageVersion) return null;
  for (final key in const ['readingTime', 'updatedAt']) {
    final n = jsNumber(map[key]);
    if (n == null || !n.isFinite || n < 0) return null;
  }
  final bookmarksRaw = map['bookmarks'];
  final bookmarks = bookmarksRaw is List
      ? bookmarksRaw
          .where((item) =>
              _isPlainObject(item) &&
              (item as Map)['id'] != null &&
              item['chapterId'] != null &&
              jsIsFinite(item['charOffset']) &&
              jsNumber(item['charOffset'])! >= 0)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList()
      : <Map<String, dynamic>>[];
  return <String, dynamic>{
    'version': kNovelReaderStorageVersion,
    'progress': _normalizePersistedProgress(map['progress']),
    'settings': _isPlainObject(map['settings'])
        ? Map<String, dynamic>.from(map['settings'] as Map)
        : <String, dynamic>{},
    'bookmarks': bookmarks,
    'readingTime': jsNumber(map['readingTime']),
    'updatedAt': jsNumber(map['updatedAt']),
  };
}

/// Source `writePersistedState` payload shape.
Map<String, dynamic> buildPersistedState({
  Map<String, dynamic>? progress,
  Map<String, dynamic>? settings,
  List<Map<String, dynamic>>? bookmarks,
  dynamic readingTime,
  required int nowMs,
}) {
  return <String, dynamic>{
    'version': kNovelReaderStorageVersion,
    'progress': progress,
    'settings': settings ?? <String, dynamic>{},
    'bookmarks': bookmarks ?? <Map<String, dynamic>>[],
    'readingTime': _numberOrZero(readingTime),
    'updatedAt': nowMs,
  };
}
