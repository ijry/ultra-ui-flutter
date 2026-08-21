// Emits the HTML the source's own `marked` bundle produces, so the Dart
// markdown swap can be checked against the real upstream parser.
//
//   node tool/markdown_reference.mjs
import { marked } from 'file:///D:/Repos/xyito/open/uview-plus/src/uni_modules/uview-plus/components/u-markdown/marked.esm.mjs'

const cases = {
  heading: '# H1\n## H2\n### H3',
  emphasis: '**bold** and *italic* and ~~strike~~ and `code`',
  link: '[text](https://example.com)',
  image: '![alt](https://example.com/a.png)',
  list: '- one\n- two\n- three',
  ordered: '1. one\n2. two',
  task: '- [x] done\n- [ ] todo',
  quote: '> quoted',
  hr: '---',
  fenced: '```dart\nvar x = 1;\n```',
  fencedNoLang: '```\nplain\n```',
  table: '| a | b |\n|---|---|\n| 1 | 2 |',
  paragraphs: 'first para\n\nsecond para',
  softBreak: 'line one\nline two',
  escaped: 'a < b & c > d',
  inlineHtml: 'text <b>bold</b> more',
  empty: '',
  nestedList: '- outer\n  - inner',
}

const out = {}
for (const [name, src] of Object.entries(cases)) {
  out[name] = marked(src)
}
process.stdout.write(JSON.stringify(out, null, 1))
