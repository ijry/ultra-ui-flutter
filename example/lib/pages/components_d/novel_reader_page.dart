import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

const List<UPNovelChapter> _chapters = <UPNovelChapter>[
  UPNovelChapter(
    id: 'c1',
    title: '第一章 风起',
    content: '风起于青萍之末，浪成于微澜之间。\n'
        '少年提剑出门去，未问前路几多难。\n'
        '山雨欲来风满楼，一夜关河万木秋。',
  ),
  UPNovelChapter(
    id: 'c2',
    title: '第二章 长夜',
    content: '长夜未央，孤灯如豆。\n'
        '案上残卷翻至末页，窗外雪落无声。\n'
        '他忽然明白，有些路只能独行。',
  ),
  UPNovelChapter(
    id: 'c3',
    title: '第三章 破晓',
    content: '天光乍破，云海翻涌。\n'
        '千里之行，始于足下。\n'
        '剑锋所指，即是归途。',
  ),
];

class NovelReaderPage extends StatefulWidget {
  const NovelReaderPage({super.key});

  @override
  State<NovelReaderPage> createState() => _NovelReaderPageState();
}

class _NovelReaderPageState extends State<NovelReaderPage> {
  int _chapterIndex = 0;
  String _lastEvent = '未触发';
  int _bookmarkCount = 0;

  // Stands in for the host's storage; the reader never touches the platform.
  Map<String, dynamic>? _stored;

  void _note(String text) {
    if (!mounted) return;
    setState(() => _lastEvent = text);
  }

  @override
  Widget build(BuildContext context) {
    final hooks = UPNovelReaderHooks(
      persist: (state) async {
        _stored = state;
        return true;
      },
      readPersisted: (_) async => _stored,
    );

    return ExamplePageScaffold(
      title: '小说阅读器',
      child: Container(
        key: const ValueKey('example-page-componentsD/novelReader/novelReader'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '滚动模式（源码默认）',
              child: SizedBox(
                height: 320,
                child: UPNovelReader(
                  key: const ValueKey('novel-reader-page-scroll'),
                  chapters: _chapters,
                  currentChapterIndex: _chapterIndex,
                  storageKey: 'demo-book',
                  hooks: hooks,
                  // Tap the centre to reveal the toolbars, as in the source.
                  onToolbarChange: (visible) =>
                      _note('toolbar -> ${visible ? '显示' : '隐藏'}'),
                  onChapterRequest: (chapter) {
                    final index = chapter['index'];
                    if (index is int) {
                      setState(() => _chapterIndex = index);
                    }
                    _note('切换到 ${chapter['title']}');
                  },
                  onBookmarkChange: (list) {
                    setState(() => _bookmarkCount = list.length);
                    _note('书签数 ${list.length}');
                  },
                  onSettingsChange: (settings) => _note(
                      '字号 ${settings['fontSize']}，主题 ${settings['theme']}'),
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '翻页模式 + 夜间主题',
              child: SizedBox(
                height: 320,
                child: UPNovelReader(
                  key: const ValueKey('novel-reader-page-paged'),
                  chapters: _chapters,
                  mode: 'page',
                  settings: const <String, dynamic>{
                    'theme': 'night',
                    'fontSize': 20,
                  },
                  onProgressChange: (progress) =>
                      _note('进度 ${progress['pageIndex']}/'
                          '${progress['pageCount']}'),
                ),
              ),
            ),
            Padding(
              key: const ValueKey('novel-reader-page-result'),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('当前章节：${_chapters[_chapterIndex].title}'),
                  const SizedBox(height: 8),
                  Text('书签数：$_bookmarkCount'),
                  const SizedBox(height: 8),
                  Text('最近事件：$_lastEvent'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
