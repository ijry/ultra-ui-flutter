// UPNovelReader widget tests.
//
// The pure algorithms are covered against real upstream JS output in
// novel_reader_core_test.dart. These tests cover the widget layer: rendering,
// controls, callbacks, and the source's prop-watcher behavior.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

const List<UPNovelChapter> _chapters = <UPNovelChapter>[
  UPNovelChapter(id: 'c1', title: '第一章 起', content: '风起于青萍之末。\n浪成于微澜之间。'),
  UPNovelChapter(id: 'c2', title: '第二章 承', content: '山雨欲来风满楼。'),
  UPNovelChapter(id: 'c3', title: '第三章 转', content: '千里之行始于足下。'),
];

/// A fixed clock so reading-time assertions are deterministic.
class _Clock {
  int now = 1700000000000;
  int call() => now;
}

Widget _host(Widget child, {Size size = const Size(360, 640)}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(width: size.width, height: size.height, child: child),
      ),
    ),
  );
}

/// Taps the reader's content area to reveal the toolbars.
///
/// Taps the geometric centre of the reader, which is content in every fixture
/// here — the toolbars sit at the top and bottom edges.
Future<void> _revealControls(WidgetTester tester) async {
  await tester.tapAt(tester.getCenter(find.byType(UPNovelReader)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the first chapter and hides controls initially',
      (tester) async {
    await tester.pumpWidget(_host(const UPNovelReader(chapters: _chapters)));
    await tester.pumpAndSettle();

    expect(find.textContaining('风起于青萍'), findsWidgets);
    // Source starts with controlsVisible false, so the title is not shown.
    expect(find.text('第一章 起'), findsNothing);
  });

  testWidgets('a center tap reveals the toolbars and reports it',
      (tester) async {
    final visibility = <bool>[];
    await tester.pumpWidget(_host(UPNovelReader(
      chapters: _chapters,
      controlsAutoHide: 0, // disable auto-hide so the state is stable
      onToolbarChange: visibility.add,
    )));
    await tester.pumpAndSettle();

    await _revealControls(tester);

    expect(visibility, <bool>[true]);
    expect(find.text('第一章 起'), findsOneWidget);
    expect(find.text('第 1 章 / 3 章'), findsOneWidget);
  });

  testWidgets('the close control hides the toolbars again', (tester) async {
    final visibility = <bool>[];
    await tester.pumpWidget(_host(UPNovelReader(
      chapters: _chapters,
      controlsAutoHide: 0,
      onToolbarChange: visibility.add,
    )));
    await tester.pumpAndSettle();

    await _revealControls(tester);
    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();

    expect(visibility, <bool>[true, false]);
    expect(find.text('第一章 起'), findsNothing);
  });

  testWidgets('controls auto-hide after the source delay', (tester) async {
    final visibility = <bool>[];
    await tester.pumpWidget(_host(UPNovelReader(
      chapters: _chapters,
      controlsAutoHide: 3000,
      onToolbarChange: visibility.add,
    )));
    await tester.pumpAndSettle();

    await _revealControls(tester);
    expect(visibility, <bool>[true]);

    await tester.pump(const Duration(milliseconds: 3100));
    await tester.pumpAndSettle();
    expect(visibility, <bool>[true, false]);
  });

  testWidgets('next and previous request the neighbouring chapter',
      (tester) async {
    final requested = <dynamic>[];
    await tester.pumpWidget(_host(UPNovelReader(
      chapters: _chapters,
      currentChapterIndex: 1,
      controlsAutoHide: 0,
      onChapterRequest: (chapter) => requested.add(chapter['id']),
    )));
    await tester.pumpAndSettle();

    await _revealControls(tester);

    await tester.tap(find.byIcon(Icons.arrow_forward_ios));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new).last);
    await tester.pumpAndSettle();

    expect(requested, <dynamic>['c3', 'c1']);
  });

  testWidgets('edge chapters disable the matching navigation control',
      (tester) async {
    final requested = <dynamic>[];
    await tester.pumpWidget(_host(UPNovelReader(
      chapters: _chapters,
      controlsAutoHide: 0,
      showBack: false, // so arrow-left can only be the "previous" control
      onChapterRequest: (chapter) => requested.add(chapter['id']),
    )));
    await tester.pumpAndSettle();

    await _revealControls(tester);

    // On the first chapter, "previous" is disabled and must not emit.
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();
    expect(requested, isEmpty);
  });

  testWidgets('the catalog lists chapters and selecting one requests it',
      (tester) async {
    final requested = <dynamic>[];
    await tester.pumpWidget(_host(UPNovelReader(
      chapters: _chapters,
      controlsAutoHide: 0,
      onChapterRequest: (chapter) => requested.add(chapter['id']),
    )));
    await tester.pumpAndSettle();

    await _revealControls(tester);
    await tester.tap(find.byIcon(Icons.format_list_bulleted));
    await tester.pumpAndSettle();

    expect(find.text('目录'), findsOneWidget);
    expect(find.text('第三章 转'), findsOneWidget);

    await tester.tap(find.text('第三章 转'));
    await tester.pumpAndSettle();
    expect(requested, <dynamic>['c3']);
  });

  testWidgets('bookmarking reports the source bookmark list', (tester) async {
    final clock = _Clock();
    List<Map<String, dynamic>>? reported;
    await tester.pumpWidget(_host(UPNovelReader(
      chapters: _chapters,
      controlsAutoHide: 0,
      hooks: UPNovelReaderHooks(clock: clock.call),
      onBookmarkChange: (list) => reported = list,
    )));
    await tester.pumpAndSettle();

    await _revealControls(tester);
    await tester.tap(find.byIcon(Icons.bookmark_border));
    await tester.pumpAndSettle();

    expect(reported, isNotNull);
    expect(reported!.length, 1);
    expect(reported!.first['chapterId'], 'c1');
    expect(reported!.first['id'], 'c1:0');
    expect(reported!.first['createdAt'], clock.now);

    // Toggling the same position removes it, per the source.
    await tester.tap(find.byIcon(Icons.bookmark).first);
    await tester.pumpAndSettle();
    expect(reported, isEmpty);
  });

  testWidgets('the settings panel edits font size and reports settings',
      (tester) async {
    Map<String, dynamic>? reported;
    await tester.pumpWidget(_host(UPNovelReader(
      chapters: _chapters,
      controlsAutoHide: 0,
      onSettingsChange: (s) => reported = s,
    )));
    await tester.pumpAndSettle();

    await _revealControls(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('阅读设置'), findsOneWidget);
    expect(find.text('18'), findsOneWidget); // source default fontSize

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(reported, isNotNull);
    expect(reported!['fontSize'], 19);
  });

  testWidgets('font size clamps to the source maximum', (tester) async {
    final key = GlobalKey<UPNovelReaderState>();
    Map<String, dynamic>? reported;
    await tester.pumpWidget(_host(UPNovelReader(
      key: key,
      chapters: _chapters,
      settings: const <String, dynamic>{'fontSize': 48},
      onSettingsChange: (s) => reported = s,
    )));
    await tester.pumpAndSettle();

    key.currentState!.setSettings(const <String, dynamic>{'fontSize': 99});
    await tester.pumpAndSettle();

    // Already at the clamp ceiling, so the merged value is unchanged and the
    // source's "no change" guard suppresses the callback.
    expect(reported, isNull);
  });

  testWidgets('theme selection switches the reader palette', (tester) async {
    Map<String, dynamic>? reported;
    await tester.pumpWidget(_host(UPNovelReader(
      chapters: _chapters,
      controlsAutoHide: 0,
      onSettingsChange: (s) => reported = s,
    )));
    await tester.pumpAndSettle();

    await _revealControls(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('夜间'));
    await tester.pumpAndSettle();

    expect(reported!['theme'], 'night');
    // The root paints the night background from the source THEME_TOKENS map.
    final box = tester.widget<ColoredBox>(find
        .descendant(
          of: find.byType(UPNovelReader),
          matching: find.byType(ColoredBox),
        )
        .first);
    expect(box.color, kNovelReaderThemes['night']!.background);
  });

  testWidgets('loading and error states replace the content', (tester) async {
    await tester.pumpWidget(
        _host(const UPNovelReader(chapters: _chapters, loading: true)));
    // A single pump, not pumpAndSettle: the spinner animates indefinitely.
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.textContaining('风起于青萍'), findsNothing);

    var retried = 0;
    await tester.pumpWidget(_host(UPNovelReader(
      chapters: _chapters,
      error: 'boom',
      onRetry: () => retried++,
    )));
    await tester.pumpAndSettle();
    expect(find.text('加载失败，点击重试'), findsOneWidget);

    await tester.tap(find.text('加载失败，点击重试'));
    await tester.pumpAndSettle();
    expect(retried, 1);
  });

  testWidgets('an empty chapter list renders the source empty state',
      (tester) async {
    await tester.pumpWidget(_host(const UPNovelReader()));
    await tester.pumpAndSettle();
    expect(find.text('暂无章节'), findsOneWidget);
  });

  testWidgets('autoBack false suppresses the back callback', (tester) async {
    var backs = 0;
    await tester.pumpWidget(_host(UPNovelReader(
      chapters: _chapters,
      controlsAutoHide: 0,
      autoBack: false,
      onBack: () => backs++,
    )));
    await tester.pumpAndSettle();

    await _revealControls(tester);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new).first);
    await tester.pumpAndSettle();
    expect(backs, 0);
  });

  testWidgets('autoBack true reports the source back event', (tester) async {
    var backs = 0;
    await tester.pumpWidget(_host(UPNovelReader(
      chapters: _chapters,
      controlsAutoHide: 0,
      onBack: () => backs++,
    )));
    await tester.pumpAndSettle();

    await _revealControls(tester);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new).first);
    await tester.pumpAndSettle();
    expect(backs, 1);
  });

  testWidgets('scroll mode renders all paragraphs without pagination',
      (tester) async {
    String? mode;
    await tester.pumpWidget(_host(UPNovelReader(
      chapters: _chapters,
      mode: 'scroll',
      onModeChange: (m) => mode = m,
    )));
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    // No mode change fires on the initial build, only on a later prop change.
    expect(mode, isNull);
  });

  testWidgets('a mode prop change reports the source normalized mode',
      (tester) async {
    String? mode;
    await tester.pumpWidget(_host(UPNovelReader(
      chapters: _chapters,
      onModeChange: (m) => mode = m,
    )));
    await tester.pumpAndSettle();

    await tester.pumpWidget(_host(UPNovelReader(
      chapters: _chapters,
      mode: 'scroll',
      onModeChange: (m) => mode = m,
    )));
    await tester.pumpAndSettle();
    expect(mode, 'scroll');

    // An unknown mode normalizes to scroll, so no further change is reported.
    await tester.pumpWidget(_host(UPNovelReader(
      chapters: _chapters,
      mode: 'bogus',
      onModeChange: (m) => mode = m,
    )));
    await tester.pumpAndSettle();
    expect(mode, 'scroll');
  });

  testWidgets('a chapter change resets the page and reports progress',
      (tester) async {
    final progress = <Map<String, dynamic>>[];
    await tester.pumpWidget(_host(UPNovelReader(
      chapters: _chapters,
      onProgressChange: progress.add,
    )));
    await tester.pumpAndSettle();

    await tester.pumpWidget(_host(UPNovelReader(
      chapters: _chapters,
      currentChapterIndex: 2,
      onProgressChange: progress.add,
    )));
    await tester.pumpAndSettle();

    expect(progress, isNotEmpty);
    expect(progress.last['chapterId'], 'c3');
    expect(progress.last['chapterIndex'], 2);
    expect(progress.last['pageIndex'], 0);
  });

  testWidgets('currentChapterIndex clamps into the chapter list',
      (tester) async {
    final key = GlobalKey<UPNovelReaderState>();
    await tester.pumpWidget(_host(UPNovelReader(
      key: key,
      chapters: _chapters,
      currentChapterIndex: 99,
    )));
    await tester.pumpAndSettle();
    expect(key.currentState!.currentChapter!['id'], 'c3');

    await tester.pumpWidget(_host(UPNovelReader(
      key: key,
      chapters: _chapters,
      currentChapterIndex: -5,
    )));
    await tester.pumpAndSettle();
    expect(key.currentState!.currentChapter!['id'], 'c1');
  });

  testWidgets('reading time accumulates from the injected clock',
      (tester) async {
    final clock = _Clock();
    final reported = <int>[];
    final key = GlobalKey<UPNovelReaderState>();
    await tester.pumpWidget(_host(UPNovelReader(
      key: key,
      chapters: _chapters,
      hooks: UPNovelReaderHooks(clock: clock.call),
      onReadingTimeChange: reported.add,
    )));
    await tester.pumpAndSettle();

    clock.now += 5000;
    expect(key.currentState!.readingTime, 5000);

    key.currentState!.pauseReading();
    await tester.pumpAndSettle();
    expect(reported, <int>[5000]);

    // Paused, so further clock movement does not accumulate.
    clock.now += 9000;
    expect(key.currentState!.readingTime, 5000);
  });

  testWidgets('defaultSettings sits below the settings prop', (tester) async {
    await tester.pumpWidget(_host(const UPNovelReader(
      chapters: _chapters,
      defaultSettings: <String, dynamic>{'theme': 'green', 'fontSize': 20},
      settings: <String, dynamic>{'theme': 'paper'},
    )));
    await tester.pumpAndSettle();

    // settings wins for theme; defaultSettings still supplies fontSize.
    final box = tester.widget<ColoredBox>(find
        .descendant(
          of: find.byType(UPNovelReader),
          matching: find.byType(ColoredBox),
        )
        .first);
    expect(box.color, kNovelReaderThemes['paper']!.background);
  });

  testWidgets('the settings prop outranks persisted settings', (tester) async {
    await tester.pumpWidget(_host(UPNovelReader(
      chapters: _chapters,
      storageKey: 'book-1',
      settings: const <String, dynamic>{'theme': 'green'},
      hooks: UPNovelReaderHooks(
        readPersisted: (k) async => <String, dynamic>{
          'version': 1,
          'readingTime': 0,
          'updatedAt': 1,
          // Storage disagrees with the prop; the source lets the prop win.
          'settings': <String, dynamic>{'theme': 'night'},
        },
      ),
    )));
    await tester.pumpAndSettle();

    final box = tester.widget<ColoredBox>(find
        .descendant(
          of: find.byType(UPNovelReader),
          matching: find.byType(ColoredBox),
        )
        .first);
    expect(box.color, kNovelReaderThemes['green']!.background);
  });

  testWidgets('persisted settings apply when no settings prop is given',
      (tester) async {
    final clock = _Clock();
    final key = GlobalKey<UPNovelReaderState>();
    await tester.pumpWidget(_host(UPNovelReader(
      key: key,
      chapters: _chapters,
      storageKey: 'book-1',
      hooks: UPNovelReaderHooks(
        clock: clock.call,
        readPersisted: (k) async => <String, dynamic>{
          'version': 1,
          'readingTime': 4242,
          'updatedAt': clock.now,
          'settings': <String, dynamic>{'theme': 'paper', 'fontSize': 22},
          'bookmarks': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'c1:0',
              'chapterId': 'c1',
              'charOffset': 0,
            },
          ],
        },
      ),
    )));
    await tester.pumpAndSettle();

    expect(key.currentState!.readingTime, 4242);
    expect(key.currentState!.getBookmarks().length, 1);
    final box = tester.widget<ColoredBox>(find
        .descendant(
          of: find.byType(UPNovelReader),
          matching: find.byType(ColoredBox),
        )
        .first);
    expect(box.color, kNovelReaderThemes['paper']!.background);
  });

  testWidgets('a rejected persisted envelope is ignored', (tester) async {
    final clock = _Clock();
    final key = GlobalKey<UPNovelReaderState>();
    await tester.pumpWidget(_host(UPNovelReader(
      key: key,
      chapters: _chapters,
      storageKey: 'book-1',
      hooks: UPNovelReaderHooks(
        // A frozen clock keeps readingTime at 0 while the reader is active.
        clock: clock.call,
        // Wrong version, so normalizePersistedState returns null.
        readPersisted: (k) async =>
            <String, dynamic>{'version': 99, 'readingTime': 7, 'updatedAt': 1},
      ),
    )));
    await tester.pumpAndSettle();

    expect(key.currentState!.readingTime, 0);
    expect(key.currentState!.getBookmarks(), isEmpty);
  });

  testWidgets('disposal writes the persisted state through the host hook',
      (tester) async {
    final clock = _Clock();
    Map<String, dynamic>? written;
    await tester.pumpWidget(_host(UPNovelReader(
      chapters: _chapters,
      storageKey: 'book-1',
      hooks: UPNovelReaderHooks(
        clock: clock.call,
        persist: (state) async {
          written = state;
          return true;
        },
      ),
    )));
    await tester.pumpAndSettle();

    await tester.pumpWidget(_host(const SizedBox.shrink()));
    await tester.pumpAndSettle();

    expect(written, isNotNull);
    expect(written!['version'], 1);
    expect(written!['updatedAt'], clock.now);
    expect(written!['settings'], isA<Map<String, dynamic>>());
  });

  testWidgets('persist: false suppresses the write', (tester) async {
    var writes = 0;
    await tester.pumpWidget(_host(UPNovelReader(
      chapters: _chapters,
      storageKey: 'book-1',
      persist: false,
      hooks: UPNovelReaderHooks(persist: (_) async {
        writes++;
        return true;
      }),
    )));
    await tester.pumpAndSettle();
    await tester.pumpWidget(_host(const SizedBox.shrink()));
    await tester.pumpAndSettle();

    expect(writes, 0);
  });

  testWidgets('no storage key disables persistence entirely', (tester) async {
    var reads = 0;
    await tester.pumpWidget(_host(UPNovelReader(
      chapters: _chapters,
      hooks: UPNovelReaderHooks(readPersisted: (_) async {
        reads++;
        return null;
      }),
    )));
    await tester.pumpAndSettle();
    expect(reads, 0);
  });

  testWidgets('public controls drive the toolbars and panels', (tester) async {
    final key = GlobalKey<UPNovelReaderState>();
    await tester.pumpWidget(_host(UPNovelReader(
      key: key,
      chapters: _chapters,
      controlsAutoHide: 0,
    )));
    await tester.pumpAndSettle();

    key.currentState!.showControls();
    await tester.pumpAndSettle();
    expect(find.text('第一章 起'), findsOneWidget);

    key.currentState!.openCatalog();
    await tester.pumpAndSettle();
    expect(find.text('目录'), findsOneWidget);

    key.currentState!.closeCatalog();
    await tester.pumpAndSettle();

    key.currentState!.openSettings();
    await tester.pumpAndSettle();
    expect(find.text('阅读设置'), findsOneWidget);

    key.currentState!.closeSettings();
    await tester.pumpAndSettle();

    key.currentState!.hideControls();
    await tester.pumpAndSettle();
    expect(find.text('第一章 起'), findsNothing);
  });
}
