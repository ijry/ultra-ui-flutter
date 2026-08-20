// UPNovelReader core-algorithm parity tests.
//
// Every expected value in this file was produced by executing the REAL
// uview-plus source modules under Node, not by reading them:
//
//   node --import ./tool/js_ext_resolver.mjs tool/novel_reader_reference.mjs
//
// Regenerate that reference and re-check these numbers if the upstream
// u-novel-reader layout engine, content normalizer, or reader core changes.
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

/// The measure function the source component actually installs.
num _m18(String text) =>
    measureTextWidth(text, const <String, dynamic>{'fontSize': 18});

List<List<Object>> _lines(List<UPNovelLine> lines) =>
    lines.map((l) => <Object>[l.text, l.startOffset, l.endOffset]).toList();

List<List<Object>> _pages(List<UPNovelPage> pages) => pages
    .map((p) => <Object>[p.index, p.text, p.startOffset, p.endOffset])
    .toList();

void main() {
  group('measureTextWidth (source measure-adapter heuristic)', () {
    test('CJK characters measure at the full font size', () {
      expect(_m18('第一章'), 54);
    });

    test('Latin characters measure at 0.56em and spaces at 0.28em', () {
      expect(_m18('Hello'), closeTo(50.4, 1e-9));
      expect(_m18('a b'), closeTo(25.2, 1e-9));
    });

    test('CJK punctuation outside the source range falls back to 0.56em', () {
      // U+3002/U+3001/U+300A sit below the source range start (U+3400), so the
      // source measures them as Latin. Preserved deliberately for parity.
      expect(_m18('。、《'), closeTo(30.24, 1e-9));
    });

    test('fullwidth forms inside the source range measure as CJK', () {
      expect(_m18('，！'), 36);
    });

    test('kana measures as CJK at the supplied font size', () {
      expect(
        measureTextWidth('あア', const <String, dynamic>{'fontSize': 20}),
        40,
      );
    });

    test('missing fontSize uses the source default of 18', () {
      expect(measureTextWidth('第一章 Hello'), closeTo(109.44, 1e-9));
    });
  });

  group('wrapText (source layout-engine)', () {
    test('empty text yields one empty line', () {
      expect(_lines(wrapText('', 100, _m18)), <List<Object>>[
        <Object>['', 0, 0],
      ]);
    });

    test('CJK text wraps greedily at the measured width', () {
      expect(_lines(wrapText('第一章风起于青萍之末', 90, _m18)), <List<Object>>[
        <Object>['第一章风起', 0, 5],
        <Object>['于青萍之末', 5, 10],
      ]);
    });

    test('Latin words wrap as whole tokens with source token offsets', () {
      // The source flushes a pending Latin token using the already-advanced
      // offset, so a token's endOffset overshoots by one. Kept for parity.
      expect(
          _lines(wrapText('alpha beta gamma delta', 100, _m18)), <List<Object>>[
        <Object>['alpha beta', 0, 11],
        <Object>[' gamma ', 10, 17],
        <Object>['delta', 17, 22],
      ]);
    });

    test('a token wider than the line splits per character', () {
      expect(_lines(wrapText('abcdefghijklmnop', 40, _m18)), <List<Object>>[
        <Object>['abc', 0, 3],
        <Object>['def', 3, 6],
        <Object>['ghi', 6, 9],
        <Object>['jkl', 9, 12],
        <Object>['mno', 12, 15],
        <Object>['p', 15, 16],
      ]);
    });

    test('text narrower than the width stays on one line', () {
      expect(_lines(wrapText('短', 200, _m18)), <List<Object>>[
        <Object>['短', 0, 1],
      ]);
    });
  });

  group('novelLineHeight (source getLineHeight)', () {
    test('values at or below 4 act as a multiplier', () {
      expect(
        novelLineHeight(
            const <String, dynamic>{'fontSize': 20, 'lineHeight': 1.5}),
        30,
      );
    });

    test('values above 4 act as absolute px', () {
      expect(
        novelLineHeight(
            const <String, dynamic>{'fontSize': 20, 'lineHeight': 40}),
        40,
      );
    });

    test('a non-numeric line height falls back to 1.8em', () {
      expect(
        novelLineHeight(
            const <String, dynamic>{'fontSize': 20, 'lineHeight': 'x'}),
        36,
      );
      expect(novelLineHeight(const <String, dynamic>{}), closeTo(32.4, 1e-9));
    });
  });

  group('normalizeContent (source content-normalizer)', () {
    test('splits on every source line-break form and advances past newlines',
        () {
      final content = normalizeContent('a\r\nb\rc\nd');
      expect(content.text, 'a\nb\nc\nd');
      expect(content.length, 7);
      expect(
        content.paragraphs.map((p) => <Object>[
              p.index,
              p.text,
              p.startOffset,
              p.endOffset,
            ]),
        <List<Object>>[
          <Object>[0, 'a', 0, 1],
          <Object>[1, 'b', 2, 3],
          <Object>[2, 'c', 4, 5],
          <Object>[3, 'd', 6, 7],
        ],
      );
    });

    test('array content is flattened then split', () {
      final content = normalizeContent(<String>['one\ntwo', 'three']);
      expect(content.text, 'one\ntwo\nthree');
      expect(content.length, 13);
      expect(content.paragraphs.last.startOffset, 8);
      expect(content.paragraphs.last.endOffset, 13);
    });

    test('blank and null content produce the source empty state', () {
      for (final value in <dynamic>['\n\n', null, '']) {
        final content = normalizeContent(value);
        expect(content.paragraphs, isEmpty);
        expect(content.text, '');
        expect(content.length, 0);
      }
    });

    test('non-string content is stringified like the source', () {
      final content = normalizeContent(12);
      expect(content.text, '12');
      expect(content.length, 2);
    });
  });

  group('paginateParagraphs (source layout-engine)', () {
    test('paginates normalized paragraphs with source offsets', () {
      final content = normalizeContent('第一段落文字内容\n第二段落文字内容\n第三段');
      final layout = paginateParagraphs(
        content.paragraphs,
        <String, dynamic>{
          'width': 90,
          'height': 80,
          'fontSize': 18,
          'lineHeight': 1.8,
          'paragraphSpacing': 16,
          'measureText': _m18,
        },
      );

      expect(layout.pageCount, 3);
      expect(_pages(layout.pages), <List<Object>>[
        <Object>[0, '第一段落文\n字内容', 0, 8],
        <Object>[1, '第二段落文\n字内容', 9, 17],
        <Object>[2, '第三段', 18, 21],
      ]);
      expect(
        layout.charOffsetToPage
            .map((c) => <Object>[
                  c['pageIndex'] as Object,
                  c['startOffset'] as Object,
                  c['endOffset'] as Object,
                ])
            .toList(),
        <List<Object>>[
          <Object>[0, 0, 8],
          <Object>[1, 9, 17],
          <Object>[2, 18, 21],
        ],
      );
    });

    test('plain-string paragraphs take the source zero-offset branch', () {
      // Raw strings carry no startOffset, so the source restarts offsets per
      // paragraph — page 2 begins at 0 again rather than continuing from 7.
      final layout = paginateParagraphs(
        <dynamic>['abc def', 'ghi'],
        <String, dynamic>{
          'width': 40,
          'height': 60,
          'fontSize': 18,
          'lineHeight': 1.8,
          'paragraphSpacing': 16,
          'measureText': _m18,
        },
      );
      expect(layout.pageCount, 3);
      expect(_pages(layout.pages), <List<Object>>[
        <Object>[0, 'abc ', 0, 4],
        <Object>[1, 'def', 4, 7],
        <Object>[2, 'ghi', 0, 3],
      ]);
    });

    test('missing layout values use the source defaults', () {
      final layout =
          paginateParagraphs(<dynamic>['短句'], const <String, dynamic>{});
      expect(layout.pageCount, 1);
      expect(_pages(layout.pages), <List<Object>>[
        <Object>[0, '短句', 0, 2],
      ]);
    });

    test('no paragraphs produces no pages', () {
      expect(
        paginateParagraphs(<dynamic>[], const <String, dynamic>{}).pageCount,
        0,
      );
    });
  });

  group('resolveAnchor (source layout-engine)', () {
    test('maps a char offset onto the containing page', () {
      final content = normalizeContent('第一段落文字内容\n第二段落文字内容\n第三段');
      final layout = paginateParagraphs(
        content.paragraphs,
        <String, dynamic>{
          'width': 90,
          'height': 80,
          'fontSize': 18,
          'lineHeight': 1.8,
          'paragraphSpacing': 16,
          'measureText': _m18,
        },
      );

      for (final probe in <List<num>>[
        <num>[0, 0, 0],
        <num>[5, 0, 5],
        <num>[9, 1, 0],
        <num>[18, 2, 0],
        <num>[99, 2, 3], // past the end clamps to the last page
      ]) {
        final anchor = resolveAnchor(layout.pages, probe[0]);
        expect(anchor['pageIndex'], probe[1], reason: 'offset ${probe[0]}');
        expect(anchor['localOffset'], probe[2], reason: 'offset ${probe[0]}');
      }
    });

    test('an empty page list resolves to the first page', () {
      final anchor = resolveAnchor(const <UPNovelPage>[], 42);
      expect(anchor['pageIndex'], 0);
      expect(anchor['localOffset'], 0);
    });
  });

  group('mergeReaderSettings (source reader-core)', () {
    test('returns the source defaults with no sources', () {
      expect(
          mergeReaderSettings(const <Map<String, dynamic>?>[]),
          <String, dynamic>{
            'theme': 'day',
            'fontSize': 18,
            'lineHeight': 1.8,
            'paragraphSpacing': 16,
            'contentWidth': '92%',
            'fontFamily': 'system',
            'fontWeight': 400,
            'animation': true,
          });
    });

    test('clamps to the source upper and lower bounds', () {
      final high = mergeReaderSettings(<Map<String, dynamic>?>[
        <String, dynamic>{
          'fontSize': 99,
          'lineHeight': 9,
          'paragraphSpacing': -4,
          'fontWeight': 700,
          'animation': false,
        },
      ]);
      expect(high['fontSize'], 48);
      expect(high['lineHeight'], 3);
      expect(high['paragraphSpacing'], 0);
      expect(high['fontWeight'], 600);
      expect(high['animation'], isFalse);

      final low = mergeReaderSettings(<Map<String, dynamic>?>[
        <String, dynamic>{'fontSize': 2, 'lineHeight': 0.1},
      ]);
      expect(low['fontSize'], 12);
      expect(low['lineHeight'], 1);
    });

    test('unparseable numbers fall back to the source defaults', () {
      final merged = mergeReaderSettings(<Map<String, dynamic>?>[
        <String, dynamic>{
          'fontSize': 'nope',
          'lineHeight': 'nope',
          'fontWeight': 'bold',
        },
      ]);
      expect(merged['fontSize'], 18);
      expect(merged['lineHeight'], 1.8);
      // JS `'bold' >= 600` is false, so the source lands on 400.
      expect(merged['fontWeight'], 400);
    });

    test('contentWidth follows the source numeric and string branches', () {
      expect(
        mergeReaderSettings(<Map<String, dynamic>?>[
          <String, dynamic>{'contentWidth': 150},
        ])['contentWidth'],
        100, // bare number clamps to 40..100, no '%' appended
      );
      expect(
        mergeReaderSettings(<Map<String, dynamic>?>[
          <String, dynamic>{'contentWidth': '  80%  '},
        ])['contentWidth'],
        '80%',
      );
      expect(
        mergeReaderSettings(<Map<String, dynamic>?>[
          <String, dynamic>{'contentWidth': '   '},
        ])['contentWidth'],
        '92%',
      );
    });

    test('later sources win and null sources are skipped', () {
      final merged = mergeReaderSettings(<Map<String, dynamic>?>[
        <String, dynamic>{'fontSize': 20},
        <String, dynamic>{'fontSize': 22},
        null,
        <String, dynamic>{'theme': 'night'},
      ]);
      expect(merged['fontSize'], 22);
      expect(merged['theme'], 'night');
    });
  });

  group('normalizeReaderMode (source normalizeMode)', () {
    test('only the source allowed modes survive', () {
      expect(normalizeReaderMode('scroll'), 'scroll');
      expect(normalizeReaderMode('page'), 'page');
      expect(normalizeReaderMode('bogus'), 'scroll');
      expect(normalizeReaderMode(null), 'scroll');
    });
  });

  group('normalizeProgress (source content-normalizer)', () {
    test('clamps the char offset to the chapter content length', () {
      final progress = normalizeProgress(
        <String, dynamic>{
          'charOffset': 999,
          'pageIndex': 2,
          'pageCount': 5,
          'totalProgress': 0.5,
        },
        <String, dynamic>{'id': 'c1', 'index': 3, 'content': '0123456789'},
      );
      expect(progress['chapterId'], 'c1');
      expect(progress['chapterIndex'], 3);
      expect(progress['charOffset'], 10);
      expect(progress['pageIndex'], 2);
      expect(progress['pageCount'], 5);
      expect(progress['chapterProgress'], 1);
      expect(progress['totalProgress'], 0.5);
    });

    test('negative values floor at zero and progress clamps to one', () {
      final progress = normalizeProgress(
        <String, dynamic>{
          'charOffset': -5,
          'pageIndex': -2,
          'scrollTop': -9,
          'totalProgress': 2,
        },
        <String, dynamic>{'id': 'c1', 'index': 0, 'content': '0123456789'},
      );
      expect(progress['charOffset'], 0);
      expect(progress['pageIndex'], 0);
      expect(progress['scrollTop'], 0);
      expect(progress['totalProgress'], 1);
    });

    test('a missing chapter yields the source zero state', () {
      final progress = normalizeProgress(null, null);
      expect(progress['chapterId'], '');
      expect(progress['chapterIndex'], 0);
      expect(progress['charOffset'], 0);
      expect(progress['chapterProgress'], 0);
      expect(progress['totalProgress'], 0);
    });

    test('a chapter without an index falls back to the progress index', () {
      final progress = normalizeProgress(
        <String, dynamic>{'chapterIndex': 7},
        <String, dynamic>{'id': 'c2', 'content': 'abc'},
      );
      expect(progress['chapterId'], 'c2');
      expect(progress['chapterIndex'], 7);
    });

    test('a non-numeric chapter index also falls back to the progress index',
        () {
      final progress = normalizeProgress(
        <String, dynamic>{'chapterIndex': 7},
        <String, dynamic>{'id': 'c2', 'index': 'x', 'content': 'abc'},
      );
      expect(progress['chapterIndex'], 7);
    });

    test('no chapter at all keeps the source zero index', () {
      // Source reads `chapter && chapter.index`, so a null chapter short
      // circuits to null -> Number(null) === 0, which IS finite. The progress
      // index is therefore not consulted.
      final progress =
          normalizeProgress(<String, dynamic>{'chapterIndex': 7}, null);
      expect(progress['chapterIndex'], 0);
    });
  });

  group('bookmarks (source reader-core)', () {
    test('createBookmark builds the source chapterId:charOffset id', () {
      final bookmark = createBookmark(
        chapterId: 'c1',
        chapterIndex: 2,
        charOffset: 30,
        pageIndex: 1,
        scrollTop: 40,
        excerpt: 'text',
        createdAt: 1700000000000,
        nowMs: 0,
      );
      expect(bookmark['id'], 'c1:30');
      expect(bookmark['chapterIndex'], 2);
      expect(bookmark['charOffset'], 30);
      expect(bookmark['pageIndex'], 1);
      expect(bookmark['scrollTop'], 40);
      expect(bookmark['excerpt'], 'text');
      expect(bookmark['createdAt'], 1700000000000);
    });

    test('createBookmark coerces the source falsey and negative values', () {
      final bookmark = createBookmark(
        chapterId: null,
        chapterIndex: 'x',
        charOffset: -3,
        pageIndex: -1,
        scrollTop: 'y',
        createdAt: 1700000000000,
        nowMs: 0,
      );
      expect(bookmark['id'], ':0');
      expect(bookmark['chapterId'], isNull);
      expect(bookmark['chapterIndex'], 0);
      expect(bookmark['charOffset'], 0);
      expect(bookmark['pageIndex'], 0);
      expect(bookmark['scrollTop'], 0);
      expect(bookmark['excerpt'], '');
    });

    test('toggleBookmark adds then removes by id', () {
      final a = createBookmark(
          chapterId: 'c1', charOffset: 10, createdAt: 1, nowMs: 0);
      final b = createBookmark(
          chapterId: 'c1', charOffset: 20, createdAt: 2, nowMs: 0);

      final both =
          toggleBookmark(toggleBookmark(const <Map<String, dynamic>>[], a), b);
      expect(both.map((x) => x['id']), <String>['c1:10', 'c1:20']);

      final removed = toggleBookmark(both, a);
      expect(removed.map((x) => x['id']), <String>['c1:20']);
    });

    test('a bookmark without an id leaves the list untouched', () {
      final a = createBookmark(
          chapterId: 'c1', charOffset: 10, createdAt: 1, nowMs: 0);
      final result = toggleBookmark(
        <Map<String, dynamic>>[a],
        const <String, dynamic>{'id': ''},
      );
      expect(result.map((x) => x['id']), <String>['c1:10']);
    });
  });

  group('createNovelStorageKey (source persistence)', () {
    test('an explicit storage key wins', () {
      expect(createNovelStorageKey(storageKey: 'k', bookId: 9), 'k');
    });

    test('a book id uses the source prefix', () {
      expect(
        createNovelStorageKey(bookId: 42),
        'uview-plus:novel-reader:42',
      );
    });

    test('no key and no book id disables persistence', () {
      expect(createNovelStorageKey(), '');
      expect(createNovelStorageKey(bookId: ''), '');
    });
  });

  group('normalizePersistedState (source persistence)', () {
    Map<String, dynamic> envelope(Map<String, dynamic> extra) =>
        <String, dynamic>{
          'version': 1,
          'readingTime': 0,
          'updatedAt': 1,
          ...extra,
        };

    test('accepts a valid source envelope', () {
      final state = normalizePersistedState(envelope(<String, dynamic>{
        'settings': <String, dynamic>{'theme': 'night'},
        'bookmarks': <Map<String, dynamic>>[
          <String, dynamic>{'id': 'c1:0', 'chapterId': 'c1', 'charOffset': 0},
        ],
      }));
      expect(state, isNotNull);
      expect(state!['settings'], <String, dynamic>{'theme': 'night'});
      expect((state['bookmarks'] as List).length, 1);
    });

    test('rejects a wrong version or a non-finite stamp', () {
      expect(normalizePersistedState(envelope(<String, dynamic>{'version': 2})),
          isNull);
      expect(
        normalizePersistedState(envelope(<String, dynamic>{'readingTime': -1})),
        isNull,
      );
      expect(normalizePersistedState(null), isNull);
      expect(normalizePersistedState('not json'), isNull);
    });

    test('drops an invalid progress field but keeps the record', () {
      final state = normalizePersistedState(envelope(<String, dynamic>{
        'progress': <String, dynamic>{'pageIndex': -1},
      }));
      expect(state, isNotNull);
      expect(state!['progress'], isNull);
    });

    test('filters bookmarks to the source-valid entries', () {
      final state = normalizePersistedState(envelope(<String, dynamic>{
        'bookmarks': <dynamic>[
          <String, dynamic>{'id': 'ok', 'chapterId': 'c1', 'charOffset': 0},
          <String, dynamic>{'id': null, 'chapterId': 'c1', 'charOffset': 0},
          <String, dynamic>{'id': 'x', 'chapterId': null, 'charOffset': 0},
          <String, dynamic>{'id': 'y', 'chapterId': 'c1', 'charOffset': -1},
          'nope',
        ],
      }));
      expect((state!['bookmarks'] as List).length, 1);
      expect((state['bookmarks'] as List).first['id'], 'ok');
    });

    test('a JSON string payload is parsed like the source', () {
      final state = normalizePersistedState(
        '{"version":1,"readingTime":5,"updatedAt":9}',
      );
      expect(state, isNotNull);
      expect(state!['readingTime'], 5);
    });
  });
}
