import 'dart:async';

import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter/material.dart';

import 'up_novel_reader_core.dart';
import 'up_popup.dart';
import 'up_slider.dart';
import 'up_switch.dart';

/// Chapter descriptor accepted by [UPNovelReader].
///
/// Mirrors the source's `chapters` array items. Only `id`, `title` and
/// `content` are read by the reader; extra fields are ignored like the source.
class UPNovelChapter {
  const UPNovelChapter({
    required this.id,
    required this.title,
    this.content = '',
    this.extra,
  });

  final dynamic id;
  final String title;
  final String content;

  /// Unused by the reader; retained so host data can flow through unchanged.
  final Map<String, dynamic>? extra;
}

/// A reader bookmark (source `bookmarks` item).
class UPNovelBookmark {
  const UPNovelBookmark({
    required this.chapterId,
    required this.charOffset,
    this.pageIndex,
    this.scrollTop,
    this.excerpt,
    this.createdAt,
  });

  final dynamic chapterId;
  final int charOffset;
  final int? pageIndex;
  final int? scrollTop;
  final String? excerpt;
  final int? createdAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'chapterId': chapterId,
        'charOffset': charOffset,
        'pageIndex': pageIndex,
        'scrollTop': scrollTop,
        'excerpt': excerpt,
        'createdAt': createdAt,
      };
}

/// Persistent reader progress (source `progress` item).
class UPNovelProgress {
  const UPNovelProgress({
    this.chapterId,
    this.chapterIndex = 0,
    this.charOffset = 0,
    this.pageIndex = 0,
    this.pageCount = 0,
    this.chapterProgress = 0,
    this.totalProgress = 0,
    this.scrollTop = 0,
    this.updatedAt,
  });

  final dynamic chapterId;
  final int chapterIndex;
  final int charOffset;
  final int pageIndex;
  final int pageCount;
  final double chapterProgress;
  final double totalProgress;
  final int scrollTop;
  final int? updatedAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'chapterId': chapterId,
        'chapterIndex': chapterIndex,
        'charOffset': charOffset,
        'pageIndex': pageIndex,
        'pageCount': pageCount,
        'chapterProgress': chapterProgress,
        'totalProgress': totalProgress,
        'scrollTop': scrollTop,
        'updatedAt': updatedAt,
      };
}

/// Host hooks the reader uses instead of the uni-app platform APIs.
///
/// All are optional; the reader degrades gracefully when they are absent.
class UPNovelReaderHooks {
  const UPNovelReaderHooks({
    this.persist,
    this.readPersisted,
    this.removePersisted,
    this.clock,
  });

  /// Source `writePersistedState`. Receives the full state map. Return true to
  /// mark the write as handled (otherwise the in-memory copy is kept anyway).
  final Future<bool> Function(Map<String, dynamic> state)? persist;

  /// Source `readPersistedState`. Return the stored string or map, or null
  /// when nothing is stored.
  final Future<dynamic> Function(String key)? readPersisted;

  /// Source `removePersistedState`.
  final Future<void> Function(String key)? removePersisted;

  /// Injectable clock (ms since epoch). Defaults to
  /// `DateTime.now().millisecondsSinceEpoch` when null.
  final int Function()? clock;
}

/// Port of u-novel-reader / up-novel-reader.
///
/// The source is a composite of reader-core, content-normalizer,
/// measure-adapter, layout-engine, persistence, and four child panels
/// (reader-content, reader-toolbar, reader-catalog, reader-settings). The pure
/// algorithms live in `up_novel_reader_core.dart`; this widget wires them
/// together with the Flutter render tree, mirroring the source's own split.
///
/// Known emulations, each mirroring a source behavior that relies on a platform
/// the Flutter host may not provide:
/// - Chapter content is a plain `content` string (the source also accepts an
///   object; normalized the same way).
/// - Persistence flows through [UPNovelReaderHooks.persist] /
///   `.readPersisted` / `.removePersisted` instead of `uni.setStorageSync`.
/// - Reading time is a simple accumulated `int` reported through
///   `onReadingTimeChange`; the source's timing panel is not ported.
class UPNovelReader extends StatefulWidget {
  const UPNovelReader({
    super.key,
    this.chapters = const <UPNovelChapter>[],
    this.currentChapterIndex = 0,
    this.loading = false,
    this.error,
    this.storageKey,
    this.persist = true,
    this.initialProgress,
    this.initialBookmarks = const <UPNovelBookmark>[],
    this.defaultSettings,
    this.settings,
    this.mode = 'scroll',
    this.showBack = true,
    this.autoBack = false,
    this.backIcon = 'arrow-left',
    this.safeAreaInsetTop = true,
    this.safeAreaInsetBottom = true,
    this.preloadThreshold = 2,
    this.pageAnimation = true,
    this.controlsAutoHide = 0,
    this.hooks = const UPNovelReaderHooks(),
    this.onChapterRequest,
    this.onChapterPrefetch,
    this.onProgressChange,
    this.onSettingsChange,
    this.onBookmarkChange,
    this.onReadingTimeChange,
    this.onBack,
    this.onModeChange,
    this.onToolbarChange,
    this.onLayoutReady,
    this.onRetry,
  });

  /// Source prop `chapters`.
  final List<UPNovelChapter> chapters;

  /// Source prop `currentChapter`.
  ///
  /// Mirrors `currentChapter.index`; the reader resolves the chapter object
  /// from [chapters]. A value outside the list clamps to the nearest chapter.
  final int currentChapterIndex;

  /// Source prop `loading`.
  final bool loading;

  /// Source prop `error`.
  final dynamic error;

  /// Source prop `storageKey`.
  final String? storageKey;

  /// Source prop `persist`.
  final bool persist;

  /// Source prop `initialProgress`.
  final UPNovelProgress? initialProgress;

  /// Source prop `initialBookmarks`.
  final List<UPNovelBookmark> initialBookmarks;

  /// Source prop `defaultSettings`.
  ///
  /// The lowest-priority settings layer: source `resolvedSettings` merges
  /// `defaultSettings`, then persisted/local settings, then [settings].
  final Map<String, dynamic>? defaultSettings;

  /// Source prop `settings`.
  final Map<String, dynamic>? settings;

  /// Source prop `mode` ('scroll' | 'page'); source default is 'scroll'.
  final String mode;

  /// Source prop `showBack`.
  final bool showBack;

  /// Source prop `autoBack`.
  final bool autoBack;

  /// Source prop `backIcon`.
  final String backIcon;

  /// Source prop `safeAreaInsetTop`.
  final bool safeAreaInsetTop;

  /// Source prop `safeAreaInsetBottom`.
  final bool safeAreaInsetBottom;

  /// Source prop `preloadThreshold`.
  final int preloadThreshold;

  /// Source prop `pageAnimation`.
  final bool pageAnimation;

  /// Source prop `controlsAutoHide` (ms). The source default is 0, which
  /// disables auto-hide entirely.
  final int controlsAutoHide;

  /// Flutter host hooks (persistence, clock).
  final UPNovelReaderHooks hooks;

  /// Source emits.
  final void Function(Map<String, dynamic> chapter)? onChapterRequest;
  final void Function(Map<String, dynamic> chapter)? onChapterPrefetch;
  final void Function(Map<String, dynamic> progress)? onProgressChange;
  final void Function(Map<String, dynamic> settings)? onSettingsChange;
  final void Function(List<Map<String, dynamic>> bookmarks)? onBookmarkChange;
  final void Function(int readingTime)? onReadingTimeChange;
  final VoidCallback? onBack;
  final void Function(String mode)? onModeChange;
  final void Function(bool visible)? onToolbarChange;
  final VoidCallback? onLayoutReady;
  final VoidCallback? onRetry;

  @override
  UPNovelReaderState createState() => UPNovelReaderState();
}

class UPNovelReaderState extends State<UPNovelReader> {
  // Source data() fields (all kept internal, like the source).
  bool _controlsVisible = false;
  bool _catalogVisible = false;
  bool _settingsVisible = false;
  int _pageIndex = 0;
  double _scrollTop = 0;
  Map<String, dynamic> _resolvedSettings = mergeReaderSettings(const []);
  String _resolvedMode = 'page';
  Map<String, dynamic> _currentProgress = normalizeProgress(null, null);
  List<Map<String, dynamic>> _bookmarks = const <Map<String, dynamic>>[];
  int _readingTime = 0;
  int? _chapterIndex;
  UPNovelContent _normalizedContent = const UPNovelContent.empty();
  UPNovelLayout _layout = UPNovelLayout.empty();

  Timer? _hideTimer;
  bool _readingActive = false;
  int _readingLastActiveAt = 0;
  final ScrollController _scrollController = ScrollController();
  PageController? _pageController;

  /// Measured viewport, the Flutter equivalent of the source's
  /// `measureContainer('.up-novel-reader__viewport')`.
  double _viewportWidth = 0;
  double _viewportHeight = 0;

  /// Source `prefetchedTargets` — chapter ids already announced.
  final Set<dynamic> _prefetched = <dynamic>{};

  int get _nowMs =>
      widget.hooks.clock?.call() ?? DateTime.now().millisecondsSinceEpoch;

  /// Source `effectiveAnimation` — both the prop and the setting must allow it.
  bool get _effectiveAnimation =>
      widget.pageAnimation && _resolvedSettings['animation'] != false;

  int? get _effectiveChapterIndex {
    final chapters = widget.chapters;
    if (chapters.isEmpty) return null;
    final raw = widget.currentChapterIndex;
    if (raw < 0) return 0;
    if (raw >= chapters.length) return chapters.length - 1;
    return raw;
  }

  UPNovelChapter? get _currentChapter {
    final index = _effectiveChapterIndex;
    if (index == null) return null;
    return widget.chapters[index];
  }

  String? get _storageKey =>
      createNovelStorageKey(storageKey: widget.storageKey, bookId: null);

  bool get _isCurrentBookmarked {
    final chapter = _currentChapter;
    final chapterId = chapter?.id;
    if (chapterId == null) return false;
    return _bookmarks.any(
        (b) => b['chapterId'] == chapterId && b['charOffset'] == _pageIndex);
  }

  Map<String, dynamic> get currentProgress => Map<String, dynamic>.from(
      _currentProgress); // expose a snapshot, like the source's reactive copy

  /// Source `resolveChapter` — the active chapter object or null.
  Map<String, dynamic>? get currentChapter {
    final chapter = _currentChapter;
    if (chapter == null) return null;
    return <String, dynamic>{
      'id': chapter.id,
      'title': chapter.title,
      'content': chapter.content,
      'index': _effectiveChapterIndex,
    };
  }

  List<Map<String, dynamic>> get chapters => widget.chapters
      .asMap()
      .entries
      .map((e) => <String, dynamic>{
            'id': e.value.id,
            'title': e.value.title,
            'content': e.value.content,
            'index': e.key,
          })
      .toList();

  /// Source `normalizeChapterIndex`.
  int? normalizeChapterIndex(dynamic value) {
    if (value is num) {
      final n = value.toInt();
      if (n < 0) return null;
      if (widget.chapters.isEmpty) return null;
      return n >= widget.chapters.length ? widget.chapters.length - 1 : n;
    }
    return null;
  }

  /// Source `setMode`.
  void setMode(dynamic mode) {
    final next = normalizeReaderMode(mode);
    if (next == _resolvedMode) return;
    setState(() => _resolvedMode = next);
    widget.onModeChange?.call(next);
    _onProgress();
  }

  /// Source `setSettings`.
  void setSettings(Map<String, dynamic>? settings) {
    if (settings == null) return;
    final merged = mergeReaderSettings(<Map<String, dynamic>?>[
      _resolvedSettings,
      settings,
    ]);
    // Content comparison: `==` on Maps is identity, so a clamped no-op update
    // would otherwise still emit.
    if (mapEquals(merged, _resolvedSettings)) return;
    setState(() {
      _resolvedSettings = merged;
      _applyLayout();
    });
    widget.onSettingsChange?.call(Map<String, dynamic>.from(merged));
  }

  /// Source `toggleBookmark`.
  void toggleBookmark() {
    final chapter = _currentChapter;
    if (chapter == null) return;
    final bookmark = createBookmark(
      chapterId: chapter.id,
      charOffset: _pageIndex,
      nowMs: _nowMs,
    );
    final next = toggleBookmarkList(_bookmarks, bookmark);
    setState(() => _bookmarks = next);
    widget.onBookmarkChange
        ?.call(next.map((b) => Map<String, dynamic>.from(b)).toList());
  }

  /// Source `setProgress`.
  void setProgress(Map<String, dynamic>? progress) {
    if (progress == null) return;
    final chapter = currentChapter;
    final normalized = normalizeProgress(progress, chapter);
    setState(() {
      _currentProgress = normalized;
      _pageIndex = (normalized['pageIndex'] is num)
          ? (normalized['pageIndex'] as num).toInt()
          : 0;
      _scrollTop = (normalized['scrollTop'] is num)
          ? (normalized['scrollTop'] as num).toDouble()
          : 0;
      _syncPage();
    });
    widget.onProgressChange?.call(Map<String, dynamic>.from(normalized));
  }

  /// Source `getBookmarks`.
  List<Map<String, dynamic>> getBookmarks() =>
      _bookmarks.map((b) => Map<String, dynamic>.from(b)).toList();

  /// Source `clearBookmarks`.
  void clearBookmarks() {
    setState(() => _bookmarks = const <Map<String, dynamic>>[]);
    widget.onBookmarkChange?.call(const <Map<String, dynamic>>[]);
  }

  /// Source `setReadingTime`.
  void setReadingTime(int value) {
    if (value < 0) return;
    setState(() => _readingTime = value);
    widget.onReadingTimeChange?.call(value);
  }

  /// Source `openCatalog` / `closeCatalog`.
  void openCatalog() => setState(() => _catalogVisible = true);
  void closeCatalog() => setState(() => _catalogVisible = false);

  /// Source `openSettings` / `closeSettings`.
  void openSettings() => setState(() => _settingsVisible = true);
  void closeSettings() => setState(() => _settingsVisible = false);

  /// Source `showControls` / `hideControls`.
  void showControls() {
    if (_controlsVisible) return;
    setState(() => _controlsVisible = true);
    widget.onToolbarChange?.call(true);
    _scheduleHide();
  }

  void hideControls() {
    if (!_controlsVisible) return;
    setState(() => _controlsVisible = false);
    widget.onToolbarChange?.call(false);
    _hideTimer?.cancel();
  }

  /// Source `handleBack` — respects `autoBack`.
  void handleBack() {
    if (widget.autoBack) widget.onBack?.call();
  }

  /// Source `handleChapterSelect`.
  void handleChapterSelect(dynamic chapter) {
    final index = chapter is Map ? chapter['index'] : null;
    if (index is! num) return;
    _goToChapter(index.toInt());
    closeCatalog();
  }

  /// Source `handleBookmarkSelect`.
  void handleBookmarkSelect(dynamic bookmark) {
    final chapterId = bookmark is Map ? bookmark['chapterId'] : null;
    final offset = bookmark is Map ? bookmark['charOffset'] : null;
    final chapterIndex = widget.chapters.indexWhere((c) => c.id == chapterId);
    if (chapterIndex < 0) return;
    _goToChapter(chapterIndex,
        charOffset: offset is num ? offset.toInt() : null);
    closeCatalog();
  }

  /// Source `handleSettingsUpdate`.
  void handleSettingsUpdate(dynamic settings) {
    if (settings is Map) setSettings(Map<String, dynamic>.from(settings));
  }

  /// Source `requestChapter('previous' | 'next')`.
  void requestChapter(String direction) {
    final index = _effectiveChapterIndex;
    if (index == null) return;
    final target = direction == 'previous' ? index - 1 : index + 1;
    if (target < 0 || target >= widget.chapters.length) return;
    widget.onChapterRequest?.call(chapters[target]);
  }

  /// Source `handleRetry` — re-requests the current chapter.
  void handleRetry() {
    final index = _effectiveChapterIndex;
    if (index == null) return;
    widget.onChapterRequest?.call(chapters[index]);
    widget.onRetry?.call();
  }

  void _goToChapter(int index, {int? charOffset}) {
    final chapter = widget.chapters[index];
    widget.onChapterRequest?.call(<String, dynamic>{
      'id': chapter.id,
      'title': chapter.title,
      'content': chapter.content,
      'index': index,
    });
    if (charOffset != null) {
      // Restore position when the host supplies a stored offset.
      final normalized = normalizeProgress(
        <String, dynamic>{'charOffset': charOffset},
        <String, dynamic>{
          'id': chapter.id,
          'index': index,
          'content': chapter.content
        },
      );
      setState(() {
        _currentProgress = normalized;
        _pageIndex = (normalized['pageIndex'] as num).toInt();
      });
    }
  }

  void _onProgress() {
    final chapter = currentChapter;
    final progress = normalizeProgress(
      <String, dynamic>{
        'chapterId': chapter?['id'],
        'chapterIndex': chapter?['index'],
        'charOffset': _scrollTop > 0 ? _scrollTop : _pageIndex,
        'pageIndex': _pageIndex,
        'pageCount': _layout.pageCount,
        'totalProgress': _chapterIndex == null
            ? 0
            : (widget.chapters.isEmpty
                ? 0
                : (_chapterIndex! + 1) / widget.chapters.length),
      },
      chapter,
    );
    _currentProgress = progress;
    widget.onProgressChange?.call(Map<String, dynamic>.from(progress));
  }

  // -------------------------------------------------------------------------
  // Source computed/method surface
  //
  // These mirror the source component's own names so callers ported from Vue
  // can reach the same values. Each delegates to the existing implementation
  // rather than duplicating it.
  // -------------------------------------------------------------------------

  /// Source computed `resolvedMode`.
  String get resolvedMode => _resolvedMode;

  /// Source computed `resolvedBookmarks`.
  List<Map<String, dynamic>> get resolvedBookmarks => getBookmarks();

  /// Source computed `themeTokens`.
  UPNovelReaderTheme get themeTokens =>
      resolveNovelReaderTheme(_resolvedSettings['theme']);

  /// Source computed `isDark` — whether the active theme is a dark one.
  bool get isDark => themeTokens.name == 'night' || themeTokens.name == 'dark';

  /// Source computed `hasContent`.
  bool get hasContent =>
      _normalizedContent.paragraphs.isNotEmpty || _layout.pages.isNotEmpty;

  /// Source computed `isCurrentBookmarked`.
  bool get isCurrentBookmarked => _isCurrentBookmarked;

  /// Source computed `hasPreviousChapter` / `hasNextChapter`.
  ///
  /// Source looks for any unlocked chapter before/after the current one, not
  /// merely an adjacent index.
  bool get hasPreviousChapter => (_effectiveChapterIndex ?? 0) > 0;
  bool get hasNextChapter =>
      (_effectiveChapterIndex ?? 0) < widget.chapters.length - 1;

  /// Source computed `contentWidthPercent`.
  double get contentWidthPercent {
    final value = _resolvedSettings['contentWidth'];
    if (value is num) return value.toDouble();
    final parsed = jsParseFloat('$value'.replaceAll('%', ''));
    return (parsed ?? 92).toDouble();
  }

  /// Source computed `getLineHeight` — resolved line height in px.
  double get getLineHeight => novelLineHeight(_resolvedSettings).toDouble();

  /// Source computed `displayIndex` — 1-based chapter number for display.
  int get displayIndex => (_effectiveChapterIndex ?? -1) + 1;

  /// Source `resolveScrollProgress`.
  double resolveScrollProgress() {
    if (_viewportHeight <= 0) return 0;
    final max = _scrollController.hasClients
        ? _scrollController.position.maxScrollExtent
        : 0.0;
    if (max <= 0) return 0;
    return (_scrollTop / max).clamp(0.0, 1.0);
  }

  /// Source `getBookmarkExcerpt` — the source takes -12/+28 chars around the
  /// current offset.
  String getBookmarkExcerpt() {
    final text = _normalizedContent.text;
    if (text.isEmpty) return '';
    final offset = _pageIndex.clamp(0, text.length);
    final start = (offset - 12).clamp(0, text.length);
    final end = (offset + 28).clamp(0, text.length);
    return text.substring(start, end).trim();
  }

  /// Source `movePage(±1)`.
  void movePage(int offset) {
    if (_resolvedMode != 'page') return;
    final next = _pageIndex + offset;
    if (next >= 0 && next < _layout.pages.length) {
      setState(() => _pageIndex = next);
      _onProgress();
      return;
    }
    // Out of range: the source asks the host for the neighbouring chapter.
    requestChapter(offset < 0 ? 'previous' : 'next');
  }

  /// Source `toggleControls`.
  void toggleControls([String reason = 'manual']) =>
      _controlsVisible ? hideControls() : showControls();

  /// Source `scheduleControlsHide` / `clearControlsHideTimer`.
  void scheduleControlsHide() => _scheduleHide();
  void clearControlsHideTimer() => _hideTimer?.cancel();

  /// Source `queuePersist` / `flushPersistence`.
  void queuePersist() => _persist();
  bool flushPersistence() {
    _persist();
    return true;
  }

  /// Source `emitProgress`.
  void emitProgress() => _onProgress();

  /// Source `emitSettings`.
  void emitSettings() => widget.onSettingsChange
      ?.call(Map<String, dynamic>.from(_resolvedSettings));

  /// Source `emitContentWidth`.
  void emitContentWidth(dynamic percent) =>
      setSettings(<String, dynamic>{'contentWidth': '$percent%'});

  /// Source `setTheme`.
  void setTheme(dynamic theme) =>
      setSettings(<String, dynamic>{'theme': '$theme'});

  /// Source `toggleWeight` — flips between the source's two weights.
  void toggleWeight() => setSettings(<String, dynamic>{
        'fontWeight': _resolvedSettings['fontWeight'] == 600 ? 400 : 600,
      });

  /// Source `toggleAnimation`.
  void toggleAnimation() => setSettings(<String, dynamic>{
        'animation': _resolvedSettings['animation'] == false,
      });

  /// Source `initializeReaderState`.
  void initializeReaderState() => _loadPersisted();

  /// Source `syncProgress`.
  void syncProgress() => _syncPage();

  /// Source `handleWindowResize` — re-measure and repaginate.
  void handleWindowResize() => _applyLayout();

  /// Source `handleScroll` / `handleContentScroll`.
  void handleScroll([dynamic event]) => handleContentScroll(event);
  void handleContentScroll([dynamic event]) {
    if (event is Map && event['scrollTop'] is num) {
      _scrollTop = (event['scrollTop'] as num).toDouble();
    } else if (_scrollController.hasClients) {
      _scrollTop = _scrollController.offset;
    }
    _onProgress();
  }

  /// Source `handlePageChange`.
  void handlePageChange(dynamic payload) {
    final index = payload is Map ? payload['pageIndex'] : payload;
    if (index is! num) return;
    setState(() => _pageIndex = index.toInt());
    _onProgress();
  }

  /// Source `handleTap` / `handleTapZone`.
  void handleTap([dynamic event]) => handleTapZone('center');
  void handleTapZone([String zone = 'center']) {
    if (zone == 'center') {
      toggleControls('tap-center');
      return;
    }
    // Left/right only page in page mode, per the source.
    if (_resolvedMode == 'page') movePage(zone == 'left' ? -1 : 1);
  }

  /// Source toolbar handler aliases.
  void handlePrevious() => requestChapter('previous');
  void handleNext() => requestChapter('next');
  void handleToggleCatalog() => openCatalog();
  void handleToggleSettings() => openSettings();
  void handleToggleControls() => hideControls();
  void handleToggleBookmark() => toggleBookmark();
  void selectChapter(dynamic chapter) => handleChapterSelect(chapter);
  void selectBookmark(dynamic bookmark) => handleBookmarkSelect(bookmark);

  /// Source host helper `set` — records a payload for host inspection.
  dynamic lastSet;
  void set([dynamic payload]) {
    lastSet = payload;
  }

  /// Source `emitPrefetchIfNeeded` — asks the host to preload the next chapter
  /// once the reader is within `preloadThreshold` pages of the end.
  void _emitPrefetchIfNeeded() {
    if (_resolvedMode != 'page' || _layout.pageCount <= 0) return;
    final threshold = widget.preloadThreshold < 0 ? 0 : widget.preloadThreshold;
    if (_layout.pageCount - _pageIndex > threshold) return;
    final index = _effectiveChapterIndex;
    if (index == null || index + 1 >= widget.chapters.length) return;
    final target = chapters[index + 1];
    if (_prefetched.contains(target['id'])) return;
    _prefetched.add(target['id']);
    widget.onChapterPrefetch?.call(target);
  }

  void _syncPage() {
    if (_layout.pages.isEmpty) return;
    final anchor = resolveAnchor(_layout.pages, _pageIndex);
    _pageIndex = anchor['pageIndex'] as int;
  }

  void _relayout() {
    final chapter = _currentChapter;
    if (chapter == null) {
      _normalizedContent = const UPNovelContent.empty();
      _layout = UPNovelLayout.empty();
      return;
    }
    _normalizedContent = normalizeContent(chapter.content);
    // Pagination needs a measured viewport; it runs in build once the real
    // constraints are known (see _applyLayout). Until then keep the content
    // normalized but unpaginated, matching the source's pre-measure state.
    if (_viewportWidth > 0 && _viewportHeight > 0) _applyLayout();
  }

  /// Source `refreshLayout` — paginate against the measured viewport.
  ///
  /// Only runs in `page` mode, like the source, and re-anchors the current page
  /// through the layout change via `resolveAnchor`.
  void _applyLayout() {
    if (_resolvedMode != 'page') {
      _layout = UPNovelLayout.empty();
      return;
    }
    final settings = _resolvedSettings;
    final contentWidth = _resolveContentWidth(_viewportWidth);
    _layout = paginateParagraphs(
      _normalizedContent.paragraphs,
      <String, dynamic>{
        'width': contentWidth,
        // Source couples this to the article's 32px vertical padding.
        'height': _viewportHeight - 64,
        'fontSize': settings['fontSize'],
        'lineHeight': settings['lineHeight'],
        'paragraphSpacing': settings['paragraphSpacing'],
        'measureText': (String text) => measureTextWidth(text, settings),
      },
    );
    final anchor = resolveAnchor(_layout.pages, _currentProgress['charOffset']);
    _pageIndex = (anchor['pageIndex'] as num).toInt();
  }

  /// Source `resolveContentWidth`.
  double _resolveContentWidth(double width) {
    final value = _resolvedSettings['contentWidth'];
    if (value is String && value.endsWith('%')) {
      final pct = jsParseFloat(value.substring(0, value.length - 1));
      if (pct == null) return width;
      return width * pct.clamp(40, 100) / 100;
    }
    final parsed = jsParseFloat(value);
    if (parsed == null || parsed <= 0) return width;
    return parsed < width ? parsed.toDouble() : width;
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    final delay = widget.controlsAutoHide;
    if (delay <= 0) return;
    _hideTimer = Timer(Duration(milliseconds: delay), () {
      if (mounted &&
          _controlsVisible &&
          !_catalogVisible &&
          !_settingsVisible) {
        hideControls();
      }
    });
  }

  /// Source `activateReading` — starts the reading-time clock.
  ///
  /// The source accumulates timestamp deltas rather than ticking a timer, so
  /// reading time advances without a periodic callback.
  void activateReading() {
    if (widget.loading || widget.error != null || _currentChapter == null) {
      return;
    }
    if (_readingActive) return;
    _readingActive = true;
    _readingLastActiveAt = _nowMs;
  }

  /// Source `pauseReading` — accumulates elapsed time and reports it.
  void pauseReading() {
    if (!_readingActive) return;
    final delta = _nowMs - _readingLastActiveAt;
    _readingActive = false;
    _readingLastActiveAt = 0;
    if (delta <= 0) return;
    _readingTime += delta;
    widget.onReadingTimeChange?.call(_readingTime);
    _persist();
  }

  /// Accumulated reading time in ms, including the in-flight span.
  int get readingTime => _readingActive
      ? _readingTime + (_nowMs - _readingLastActiveAt)
      : _readingTime;

  @override
  void initState() {
    super.initState();
    // Source merge order: defaultSettings, then local/persisted, then settings.
    _resolvedSettings = mergeReaderSettings(<Map<String, dynamic>?>[
      widget.defaultSettings,
      widget.settings,
    ]);
    _resolvedMode = normalizeReaderMode(widget.mode);
    _bookmarks = List<Map<String, dynamic>>.from(
        widget.initialBookmarks.map((b) => b.toMap()));
    _chapterIndex = _effectiveChapterIndex;
    final initial =
        widget.initialProgress?.toMap() ?? const <String, dynamic>{};
    _currentProgress = normalizeProgress(initial, currentChapter);
    _loadPersisted();
    _relayout();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onLayoutReady?.call();
      activateReading();
    });
  }

  /// Mirrors the source watchers on `currentChapter`, `mode`, and `settings`.
  @override
  void didUpdateWidget(UPNovelReader oldWidget) {
    super.didUpdateWidget(oldWidget);

    final chapterChanged =
        widget.currentChapterIndex != oldWidget.currentChapterIndex ||
            !identical(widget.chapters, oldWidget.chapters);
    if (chapterChanged) {
      _chapterIndex = _effectiveChapterIndex;
      // Source clears the prefetch record when the chapter changes.
      _prefetched.clear();
      _pageIndex = 0;
      _scrollTop = 0;
      _pageController?.dispose();
      _pageController = null;
      _relayout();
      _onProgress();
    }

    if (widget.mode != oldWidget.mode) {
      final next = normalizeReaderMode(widget.mode);
      if (next != _resolvedMode) {
        _resolvedMode = next;
        _applyLayout();
        widget.onModeChange?.call(next);
      }
    }

    if (widget.settings != oldWidget.settings && widget.settings != null) {
      final merged = mergeReaderSettings(<Map<String, dynamic>?>[
        _resolvedSettings,
        widget.settings,
      ]);
      if (!mapEquals(merged, _resolvedSettings)) {
        _resolvedSettings = merged;
        _applyLayout();
      }
    }
  }

  Future<void> _loadPersisted() async {
    final key = _storageKey;
    if (key == null || key.isEmpty) return;
    final reader = widget.hooks.readPersisted;
    if (reader == null) return;
    final raw = await reader(key);
    if (!mounted) return;
    final state = normalizePersistedState(raw);
    if (state == null) return;
    setState(() {
      final storedSettings = state['settings'];
      if (storedSettings is Map) {
        // Source order: defaultSettings, then persisted/local, then the
        // explicit `settings` prop — which therefore still wins over storage.
        _resolvedSettings = mergeReaderSettings(<Map<String, dynamic>?>[
          widget.defaultSettings,
          Map<String, dynamic>.from(storedSettings),
          widget.settings,
        ]);
      }
      final storedProgress = state['progress'];
      if (storedProgress is Map) {
        _currentProgress = normalizeProgress(
          Map<String, dynamic>.from(storedProgress),
          currentChapter,
        );
        _pageIndex = (_currentProgress['pageIndex'] as num).toInt();
        _scrollTop = (_currentProgress['scrollTop'] as num).toDouble();
      }
      final storedBookmarks = state['bookmarks'];
      if (storedBookmarks is List) {
        _bookmarks = storedBookmarks
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      final readingTime = state['readingTime'];
      if (readingTime is num) _readingTime = readingTime.toInt();
      _relayout();
      _syncPage();
    });
  }

  void _persist() {
    if (!widget.persist) return;
    final key = _storageKey;
    if (key == null || key.isEmpty) return;
    final state = buildPersistedState(
      progress: _currentProgress,
      settings: _resolvedSettings,
      bookmarks: _bookmarks,
      readingTime: _readingTime,
      nowMs: _nowMs,
    );
    widget.hooks.persist?.call(state);
  }

  /// Source `destroyed` — clears timers and writes state.
  @override
  void dispose() {
    _hideTimer?.cancel();
    pauseReading();
    _scrollController.dispose();
    _pageController?.dispose();
    _persist();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Rendered structure (mirrors the source template)
  // -------------------------------------------------------------------------

  Widget _buildContent(BuildContext context, Size size) {
    final theme = resolveNovelReaderTheme(_resolvedSettings['theme']);
    final settings = _resolvedSettings;

    if (widget.loading) {
      return Center(
        child: SizedBox(
          width: 44,
          height: 44,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(theme.active),
          ),
        ),
      );
    }
    if (widget.error != null) {
      return Center(
        child: GestureDetector(
          onTap: handleRetry,
          child: Text('加载失败，点击重试',
              style: TextStyle(color: theme.muted, fontSize: 14)),
        ),
      );
    }
    if (widget.chapters.isEmpty) {
      return Center(
        child: Text('暂无章节', style: TextStyle(color: theme.muted, fontSize: 14)),
      );
    }

    final textStyle = TextStyle(
      fontSize: (settings['fontSize'] as num).toDouble(),
      height: settings['lineHeight'] as double?,
      color: theme.text,
      fontWeight: (settings['fontWeight'] as num) >= 600
          ? FontWeight.w600
          : FontWeight.w400,
      fontFamily: settings['fontFamily'] == 'system'
          ? null
          : settings['fontFamily'] as String?,
    );
    final horizontalPadding = 16.0;

    if (_resolvedMode == 'page') {
      if (_layout.pages.isEmpty) {
        return Center(
          child:
              Text('暂无正文', style: TextStyle(color: theme.muted, fontSize: 14)),
        );
      }
      final pageIndex = _pageIndex.clamp(0, _layout.pages.length - 1);
      // One controller for the widget's life; a fresh one per build would reset
      // the scroll position and swallow page changes.
      final controller =
          _pageController ??= PageController(initialPage: pageIndex);
      return PageView.builder(
        controller: controller,
        onPageChanged: (index) {
          if (index == _pageIndex) return;
          setState(() => _pageIndex = index);
          _onProgress();
          _emitPrefetchIfNeeded();
        },
        itemBuilder: (context, index) {
          final p = _layout.pages[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in p.lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(line.text, style: textStyle),
                  ),
              ],
            ),
          );
        },
        itemCount: _layout.pages.length,
      );
    }

    // scroll mode
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          _scrollTop = _scrollController.offset;
          _onProgress();
        }
        return false;
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final p in _layout.pages)
              for (final line in p.lines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(line.text, style: textStyle),
                ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = resolveNovelReaderTheme(_resolvedSettings['theme']);
    final layoutSize = MediaQuery.sizeOf(context);

    return ColoredBox(
      color: theme.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : layoutSize.width;
          final height = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : layoutSize.height;
          // Repaginate only when the measured viewport actually changes;
          // doing it unconditionally would re-run on every frame and mutate
          // state during layout.
          if (width > 0 &&
              height > 0 &&
              (width != _viewportWidth || height != _viewportHeight)) {
            _viewportWidth = width;
            _viewportHeight = height;
            _applyLayout();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {});
                widget.onLayoutReady?.call();
              }
            });
          }

          return Stack(
            children: [
              // The source binds its tap handler to the content view itself, so
              // interactive content (the retry action) stays reachable and the
              // toolbars/panels above are never covered by a tap layer.
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _controlsVisible ? hideControls : showControls,
                  child: _buildContent(context, layoutSize),
                ),
              ),
              if (_controlsVisible)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ColoredBox(
                    color: theme.toolbar,
                    child: SafeArea(
                      bottom: false,
                      child: UPNovelReaderTopToolbar(
                        theme: theme,
                        title: _currentChapter?.title ?? '',
                        showBack: widget.showBack,
                        backIcon: widget.backIcon,
                        isBookmarked: _isCurrentBookmarked,
                        onBack: handleBack,
                        onToggleCatalog: openCatalog,
                        onToggleBookmark: toggleBookmark,
                        onToggleControls: hideControls,
                      ),
                    ),
                  ),
                ),
              if (_controlsVisible)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ColoredBox(
                    color: theme.toolbar,
                    child: SafeArea(
                      top: false,
                      child: UPNovelReaderBottomToolbar(
                        theme: theme,
                        progress: _currentProgress,
                        pageCount: _layout.pageCount,
                        currentChapterIndex: _effectiveChapterIndex ?? 0,
                        chapterCount: widget.chapters.length,
                        hasPrevious: (_effectiveChapterIndex ?? 0) > 0,
                        hasNext: (_effectiveChapterIndex ?? 0) <
                            widget.chapters.length - 1,
                        onPrevious: () => requestChapter('previous'),
                        onNext: () => requestChapter('next'),
                        onToggleSettings: openSettings,
                        onToggleControls: hideControls,
                      ),
                    ),
                  ),
                ),
              // Catalog popup (left). Mounted only while open: the source
              // renders the panel inside the popup, so a closed popup has no
              // catalog subtree at all.
              if (_catalogVisible)
                Positioned.fill(
                  child: UPPopup(
                    show: _catalogVisible,
                    mode: 'left',
                    round: '0',
                    duration: _effectiveAnimation ? 300 : 0,
                    safeAreaInsetBottom: widget.safeAreaInsetBottom,
                    customStyle: BoxDecoration(color: theme.toolbar),
                    onUpdateShow: (show) {
                      if (!show) setState(() => _catalogVisible = false);
                    },
                    child: UPNovelReaderCatalog(
                      theme: theme,
                      chapters: chapters,
                      currentChapterIndex: _effectiveChapterIndex ?? 0,
                      bookmarks: _bookmarks,
                      progress: _currentProgress,
                      onChapterSelect: handleChapterSelect,
                      onBookmarkSelect: handleBookmarkSelect,
                    ),
                  ),
                ),
              // Settings popup (bottom), mounted only while open.
              if (_settingsVisible)
                Positioned.fill(
                  child: UPPopup(
                    show: _settingsVisible,
                    mode: 'bottom',
                    round: '18',
                    duration: _effectiveAnimation ? 300 : 0,
                    safeAreaInsetBottom: widget.safeAreaInsetBottom,
                    customStyle: BoxDecoration(color: theme.toolbar),
                    onUpdateShow: (show) {
                      if (!show) setState(() => _settingsVisible = false);
                    },
                    child: UPNovelReaderSettings(
                      theme: theme,
                      settings: _resolvedSettings,
                      onUpdateSettings: handleSettingsUpdate,
                      onClose: closeSettings,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Source `reader-toolbar.vue` (top position).
class UPNovelReaderTopToolbar extends StatelessWidget {
  const UPNovelReaderTopToolbar({
    required this.theme,
    required this.title,
    required this.showBack,
    required this.backIcon,
    required this.isBookmarked,
    required this.onBack,
    required this.onToggleCatalog,
    required this.onToggleBookmark,
    required this.onToggleControls,
  });

  final UPNovelReaderTheme theme;
  final String title;
  final bool showBack;
  final String backIcon;
  final bool isBookmarked;
  final VoidCallback onBack;
  final VoidCallback onToggleCatalog;
  final VoidCallback onToggleBookmark;
  final VoidCallback onToggleControls;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          if (showBack)
            _IconButton(icon: backIcon, color: theme.text, onTap: onBack),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.text,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _IconButton(
            // Source swaps to the filled bookmark glyph when the current
            // position is bookmarked.
            icon: isBookmarked ? 'bookmark-fill' : 'bookmark',
            color: isBookmarked ? theme.active : theme.muted,
            onTap: onToggleBookmark,
          ),
          _IconButton(icon: 'list', color: theme.text, onTap: onToggleCatalog),
          _IconButton(
              icon: 'close', color: theme.muted, onTap: onToggleControls),
        ],
      ),
    );
  }
}

/// Source `reader-toolbar.vue` (bottom position).
class UPNovelReaderBottomToolbar extends StatelessWidget {
  const UPNovelReaderBottomToolbar({
    required this.theme,
    required this.progress,
    required this.pageCount,
    required this.currentChapterIndex,
    required this.chapterCount,
    required this.hasPrevious,
    required this.hasNext,
    required this.onPrevious,
    required this.onNext,
    required this.onToggleSettings,
    required this.onToggleControls,
  });

  final UPNovelReaderTheme theme;
  final Map<String, dynamic> progress;
  final int pageCount;
  final int currentChapterIndex;
  final int chapterCount;
  final bool hasPrevious;
  final bool hasNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToggleSettings;
  final VoidCallback onToggleControls;

  /// Source computed `progressPercent`.
  ///
  /// Prefers the reported chapterProgress and falls back to page position, so a
  /// scroll-mode reader (which has no pages) still shows real progress.
  double get progressPercent {
    final chapterProgress = progress['chapterProgress'];
    if (chapterProgress is num) {
      return (chapterProgress * 100).clamp(0.0, 100.0).toDouble();
    }
    if (pageCount > 0) {
      final index = progress['pageIndex'];
      final pageIndex = index is num ? index.toInt() : 0;
      return ((pageIndex + 1) / pageCount * 100).clamp(0.0, 100.0).toDouble();
    }
    return 0;
  }

  /// Source computed `progressLabel`, e.g. `1/3 · 45%`.
  String get progressLabel {
    final current = currentChapterIndex >= 0 ? currentChapterIndex + 1 : 0;
    final chapterText = chapterCount > 0 ? '$current/$chapterCount' : '阅读进度';
    return '$chapterText · ${progressPercent.round()}%';
  }

  /// Source computed `previousDisabled` / `nextDisabled`.
  bool get previousDisabled => !hasPrevious;
  bool get nextDisabled => !hasNext;

  @override
  Widget build(BuildContext context) {
    final percent = progressPercent;
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          _IconButton(
              icon: 'arrow-left',
              color: hasPrevious ? theme.text : theme.disabled,
              onTap: hasPrevious ? onPrevious : null),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  // Source progressLabel format, not a bespoke one.
                  progressLabel,
                  style: TextStyle(color: theme.muted, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: LinearProgressIndicator(
                    value: percent / 100,
                    minHeight: 2,
                    backgroundColor: theme.border,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.active),
                  ),
                ),
              ],
            ),
          ),
          _IconButton(
              icon: 'arrow-right',
              color: hasNext ? theme.text : theme.disabled,
              onTap: hasNext ? onNext : null),
          _IconButton(
              icon: 'setting', color: theme.text, onTap: onToggleSettings),
          _IconButton(
              icon: 'close', color: theme.muted, onTap: onToggleControls),
        ],
      ),
    );
  }
}

/// Source `reader-catalog.vue`.
class UPNovelReaderCatalog extends StatelessWidget {
  const UPNovelReaderCatalog({
    required this.theme,
    required this.chapters,
    required this.currentChapterIndex,
    required this.bookmarks,
    required this.progress,
    required this.onChapterSelect,
    required this.onBookmarkSelect,
  });

  final UPNovelReaderTheme theme;
  final List<Map<String, dynamic>> chapters;
  final int currentChapterIndex;
  final List<Map<String, dynamic>> bookmarks;
  final Map<String, dynamic> progress;
  final ValueChanged<dynamic> onChapterSelect;
  final ValueChanged<dynamic> onBookmarkSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text(
              '目录',
              style: TextStyle(
                color: theme.text,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0x14000000)),
          Expanded(
            child: ListView.builder(
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final isCurrent = index == currentChapterIndex;
                final chapter = chapters[index];
                return InkWell(
                  onTap: () => onChapterSelect(chapter),
                  child: Container(
                    color: isCurrent ? kNovelReaderCurrentTint : null,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            chapter['title'] ?? '第 ${index + 1} 章',
                            style: TextStyle(
                              color: isCurrent ? theme.active : theme.text,
                              fontSize: 14,
                              fontWeight:
                                  isCurrent ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (isCurrent)
                          // Source marks the active chapter with a checkmark.
                          Icon(Icons.check, size: 16, color: theme.active),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: Color(0x14000000)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Text(
              '书签 ${bookmarks.length}',
              style: TextStyle(color: theme.muted, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// Source `reader-settings.vue`.
class UPNovelReaderSettings extends StatelessWidget {
  const UPNovelReaderSettings({
    required this.theme,
    required this.settings,
    required this.onUpdateSettings,
    required this.onClose,
  });

  final UPNovelReaderTheme theme;
  final Map<String, dynamic> settings;
  final ValueChanged<Map<String, dynamic>> onUpdateSettings;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '阅读设置',
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _IconButton(icon: 'close', color: theme.muted, onTap: onClose),
              ],
            ),
            const SizedBox(height: 20),
            _SettingRow(
              label: '字号',
              theme: theme,
              child: Row(
                children: [
                  _IconButton(
                    icon: 'minus',
                    color: theme.text,
                    onTap: () => _adjustFontSize(-1),
                  ),
                  Text(
                    '${settings['fontSize']}',
                    style: TextStyle(color: theme.text, fontSize: 14),
                  ),
                  _IconButton(
                    icon: 'plus',
                    color: theme.text,
                    onTap: () => _adjustFontSize(1),
                  ),
                ],
              ),
            ),
            _SettingRow(
              label: '行距',
              theme: theme,
              child: SizedBox(
                width: 120,
                child: UPSlider(
                  value: settings['lineHeight'],
                  min: 1,
                  max: 3,
                  step: 0.1,
                  activeColor: kNovelReaderPanelAccent,
                  inactiveColor: theme.border,
                  onChange: (value) => onUpdateSettings(<String, dynamic>{
                    'lineHeight': value,
                  }),
                ),
              ),
            ),
            _SettingRow(
              label: '段距',
              theme: theme,
              child: SizedBox(
                width: 120,
                child: UPSlider(
                  value: settings['paragraphSpacing'],
                  min: 0,
                  max: 40,
                  step: 2,
                  activeColor: kNovelReaderPanelAccent,
                  inactiveColor: theme.border,
                  onChange: (value) => onUpdateSettings(<String, dynamic>{
                    'paragraphSpacing': value,
                  }),
                ),
              ),
            ),
            _SettingRow(
              label: '夜间模式',
              theme: theme,
              child: UPSwitch(
                value:
                    settings['theme'] == 'night' || settings['theme'] == 'dark',
                activeColor: kNovelReaderPanelAccent,
                onChange: (value) => onUpdateSettings(<String, dynamic>{
                  'theme': value ? 'night' : 'day',
                }),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '主题',
              style: TextStyle(color: theme.muted, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final option in kNovelReaderThemeOptions)
                  _ThemeSwatch(
                    theme: theme,
                    option: option,
                    isActive: settings['theme'] == option['value'],
                    onTap: () => onUpdateSettings(<String, dynamic>{
                      'theme': option['value'],
                    }),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _adjustFontSize(int delta) {
    final current = (settings['fontSize'] as num).toInt();
    onUpdateSettings(<String, dynamic>{'fontSize': current + delta});
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.theme,
    required this.child,
  });

  final String label;
  final UPNovelReaderTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: theme.text, fontSize: 14)),
          child,
        ],
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.theme,
    required this.option,
    required this.isActive,
    required this.onTap,
  });

  final UPNovelReaderTheme theme;
  final Map<String, dynamic> option;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final value = option['value'] as String;
    final swatch = kNovelReaderThemes[value]!;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: swatch.background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? kNovelReaderPanelAccent : theme.border,
                  width: isActive ? 2 : 1,
                ),
              ),
              child: Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: swatch.text,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              option['label'] as String,
              style: TextStyle(
                color: isActive ? theme.active : theme.muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String icon;
  final Color color;
  final VoidCallback? onTap;

  static const Map<String, IconData> _icons = <String, IconData>{
    'arrow-left': Icons.arrow_back_ios_new,
    'arrow-right': Icons.arrow_forward_ios,
    'bookmark': Icons.bookmark_border,
    'bookmark-fill': Icons.bookmark,
    'list': Icons.format_list_bulleted,
    'setting': Icons.settings_outlined,
    'close': Icons.close,
    'minus': Icons.remove,
    'plus': Icons.add,
  };

  @override
  Widget build(BuildContext context) {
    final iconData = _icons[icon] ?? Icons.circle;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(iconData, size: 20, color: color),
      ),
    );
  }
}

/// Source `toggleBookmark` on a list — exposed for the widget's own use and
/// kept here (rather than in the core) because the source implements it
/// inline in the component, not in reader-core.
List<Map<String, dynamic>> toggleBookmarkList(
  List<Map<String, dynamic>> bookmarks,
  Map<String, dynamic> bookmark,
) {
  final id = bookmark['id'];
  final list = List<Map<String, dynamic>>.from(bookmarks);
  final existing = list.indexWhere((item) => item['id'] == id);
  if (existing == -1) return <Map<String, dynamic>>[...list, bookmark];
  return <Map<String, dynamic>>[
    for (var i = 0; i < list.length; i++)
      if (i != existing) list[i],
  ];
}
