// Emits reference values from the REAL uview-plus source modules so the Dart
// port is checked against actual behavior rather than a reading of the code.
//
//   node tool/novel_reader_reference.mjs
import {
  wrapText,
  paginateParagraphs,
  resolveAnchor,
} from 'file:///D:/Repos/xyito/open/uview-plus/src/uni_modules/uview-plus/components/u-novel-reader/layout-engine.js'
import { measureTextWidth } from 'file:///D:/Repos/xyito/open/uview-plus/src/uni_modules/uview-plus/components/u-novel-reader/measure-adapter.js'
import {
  normalizeContent,
  normalizeProgress,
} from 'file:///D:/Repos/xyito/open/uview-plus/src/uni_modules/uview-plus/components/u-novel-reader/content-normalizer.js'
import {
  mergeReaderSettings,
  createBookmark,
  toggleBookmark,
  normalizeMode,
} from 'file:///D:/Repos/xyito/open/uview-plus/src/uni_modules/uview-plus/components/u-novel-reader/reader-core.js'

const out = {}

// --- measureTextWidth -------------------------------------------------------
out.measure = {}
for (const [label, text, style] of [
  ['cjk', '第一章', { fontSize: 18 }],
  ['latin', 'Hello', { fontSize: 18 }],
  ['space', 'a b', { fontSize: 18 }],
  ['cjkPunct', '。、《', { fontSize: 18 }],   // U+3002/3001/300A: NOT in range
  ['fullwidth', '，！', { fontSize: 18 }],   // U+FF0C/FF01: in range
  ['mixedDefault', '第一章 Hello', {}],       // default fontSize 18
  ['kana', 'あア', { fontSize: 20 }],
]) {
  out.measure[label] = measureTextWidth(text, style)
}

// --- wrapText ---------------------------------------------------------------
const m18 = (t) => measureTextWidth(t, { fontSize: 18 })
out.wrap = {}
for (const [label, text, width] of [
  ['empty', '', 100],
  ['cjkWrap', '第一章风起于青萍之末', 90],
  ['latinWords', 'alpha beta gamma delta', 100],
  ['longWordSplit', 'abcdefghijklmnop', 40],
  ['single', '短', 200],
]) {
  out.wrap[label] = wrapText(text, width, m18).map((l) => [
    l.text,
    l.startOffset,
    l.endOffset,
  ])
}

// --- getLineHeight (observed via pagination; not exported by the source) -----
// A single paragraph on a height-1 page yields one line per page, so the page
// count reveals nothing — instead we probe the height at which a second line
// still fits, which is exactly the resolved line height.
out.lineHeight = {}
for (const [label, layoutStyle] of [
  ['multiplier', { fontSize: 20, lineHeight: 1.5 }],   // expect 30
  ['absolute', { fontSize: 20, lineHeight: 40 }],      // expect 40
  ['nonNumeric', { fontSize: 20, lineHeight: 'x' }],   // expect 20 * 1.8 = 36
  ['empty', {}],                                       // expect 18 * 1.8 = 32.4
]) {
  // Two CJK chars at width 1 wrap to two lines; the smallest page height that
  // still holds both lines is 2 * lineHeight.
  let resolved = null
  for (let h = 1; h <= 200; h += 0.01) {
    const r = paginateParagraphs(['ab'], {
      ...layoutStyle,
      width: 1,
      height: h,
      paragraphSpacing: 0,
      measureText: (t) => t.length * 100,
    })
    if (r.pageCount === 1) {
      resolved = h
      break
    }
  }
  out.lineHeight[label] = resolved === null ? null : Math.round(resolved * 50) / 100
}

// --- paginateParagraphs -----------------------------------------------------
out.paginate = {}
{
  const content = normalizeContent('第一段落文字内容\n第二段落文字内容\n第三段')
  const layout = {
    width: 90,
    height: 80,
    fontSize: 18,
    lineHeight: 1.8,
    paragraphSpacing: 16,
    measureText: m18,
  }
  const result = paginateParagraphs(content.paragraphs, layout)
  out.paginate.basic = {
    pageCount: result.pageCount,
    pages: result.pages.map((p) => [p.index, p.text, p.startOffset, p.endOffset]),
    charOffsetToPage: result.charOffsetToPage.map((c) => [
      c.pageIndex,
      c.startOffset,
      c.endOffset,
    ]),
  }
  out.paginate.anchors = [0, 5, 9, 18, 99].map((o) => {
    const a = resolveAnchor(result.pages, o)
    return [o, a.pageIndex, a.localOffset]
  })
}
{
  // Plain-string paragraphs take the source's string-normalization branch.
  const result = paginateParagraphs(['abc def', 'ghi'], {
    width: 40,
    height: 60,
    fontSize: 18,
    lineHeight: 1.8,
    paragraphSpacing: 16,
    measureText: m18,
  })
  out.paginate.strings = {
    pageCount: result.pageCount,
    pages: result.pages.map((p) => [p.index, p.text, p.startOffset, p.endOffset]),
  }
}
{
  // Defaults: no width/height/lineHeight supplied.
  const result = paginateParagraphs(['短句'], {})
  out.paginate.defaults = {
    pageCount: result.pageCount,
    pages: result.pages.map((p) => [p.index, p.text, p.startOffset, p.endOffset]),
  }
}
out.paginate.emptyInput = paginateParagraphs([], {}).pageCount

// --- normalizeContent -------------------------------------------------------
out.content = {}
for (const [label, value] of [
  ['crlf', 'a\r\nb\rc\nd'],
  ['array', ['one\ntwo', 'three']],
  ['blank', '\n\n'],
  ['null', null],
  ['number', 12],
]) {
  const c = normalizeContent(value)
  out.content[label] = {
    text: c.text,
    length: c.length,
    paragraphs: c.paragraphs.map((p) => [
      p.index,
      p.text,
      p.startOffset,
      p.endOffset,
    ]),
  }
}

// --- normalizeProgress ------------------------------------------------------
out.progress = {}
out.progress.clampsToContent = normalizeProgress(
  { charOffset: 999, pageIndex: 2, pageCount: 5, totalProgress: 0.5 },
  { id: 'c1', index: 3, content: '0123456789' }
)
out.progress.negatives = normalizeProgress(
  { charOffset: -5, pageIndex: -2, scrollTop: -9, totalProgress: 2 },
  { id: 'c1', index: 0, content: '0123456789' }
)
out.progress.emptyChapter = normalizeProgress(null, null)
out.progress.fallbackIndex = normalizeProgress(
  { chapterIndex: 7 },
  { id: 'c2', content: 'abc' }
)
// Chapter index present but non-numeric, and progress-only index forms.
out.progress.chapterIndexNaN = normalizeProgress(
  { chapterIndex: 7 },
  { id: 'c2', index: 'x', content: 'abc' }
)
out.progress.noChapterAtAll = normalizeProgress({ chapterIndex: 7 }, null)

// --- mergeReaderSettings ----------------------------------------------------
out.settings = {}
out.settings.defaults = mergeReaderSettings()
out.settings.clamped = mergeReaderSettings({
  fontSize: 99,
  lineHeight: 9,
  paragraphSpacing: -4,
  fontWeight: 700,
  animation: false,
})
out.settings.lowClamp = mergeReaderSettings({ fontSize: 2, lineHeight: 0.1 })
out.settings.badValues = mergeReaderSettings({
  fontSize: 'nope',
  lineHeight: 'nope',
  fontWeight: 'bold',
})
out.settings.numericWidth = mergeReaderSettings({ contentWidth: 150 })
out.settings.stringWidth = mergeReaderSettings({ contentWidth: '  80%  ' })
out.settings.emptyWidth = mergeReaderSettings({ contentWidth: '   ' })
out.settings.priority = mergeReaderSettings(
  { fontSize: 20 },
  { fontSize: 22 },
  { theme: 'night' }
)
out.settings.modes = ['scroll', 'page', 'bogus', undefined].map((m) =>
  normalizeMode(m)
)

// --- bookmarks --------------------------------------------------------------
out.bookmarks = {}
out.bookmarks.created = createBookmark({
  chapterId: 'c1',
  chapterIndex: 2,
  charOffset: 30,
  pageIndex: 1,
  scrollTop: 40,
  excerpt: 'text',
  createdAt: 1700000000000,
})
out.bookmarks.coerced = createBookmark({
  chapterId: null,
  chapterIndex: 'x',
  charOffset: -3,
  pageIndex: -1,
  scrollTop: 'y',
  createdAt: 1700000000000,
})
{
  const a = createBookmark({ chapterId: 'c1', charOffset: 10, createdAt: 1 })
  const b = createBookmark({ chapterId: 'c1', charOffset: 20, createdAt: 2 })
  out.bookmarks.addTwo = toggleBookmark(toggleBookmark([], a), b).map((x) => x.id)
  out.bookmarks.removeFirst = toggleBookmark(
    toggleBookmark(toggleBookmark([], a), b),
    a
  ).map((x) => x.id)
  out.bookmarks.noId = toggleBookmark([a], { id: '' }).map((x) => x.id)
}

process.stdout.write(JSON.stringify(out, null, 1))
