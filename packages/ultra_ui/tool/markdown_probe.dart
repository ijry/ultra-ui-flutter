// Prints the Dart `markdown` package's HTML for the same inputs as
// tool/markdown_reference.mjs, so the two parsers can be compared directly.
//
//   dart run tool/markdown_probe.dart
import 'dart:convert';

import 'package:markdown/markdown.dart' as md;

const Map<String, String> cases = <String, String>{
  'heading': '# H1\n## H2\n### H3',
  'emphasis': '**bold** and *italic* and ~~strike~~ and `code`',
  'link': '[text](https://example.com)',
  'image': '![alt](https://example.com/a.png)',
  'list': '- one\n- two\n- three',
  'ordered': '1. one\n2. two',
  'task': '- [x] done\n- [ ] todo',
  'quote': '> quoted',
  'hr': '---',
  'fenced': '```dart\nvar x = 1;\n```',
  'fencedNoLang': '```\nplain\n```',
  'table': '| a | b |\n|---|---|\n| 1 | 2 |',
  'paragraphs': 'first para\n\nsecond para',
  'softBreak': 'line one\nline two',
  'escaped': 'a < b & c > d',
  'inlineHtml': 'text <b>bold</b> more',
  'empty': '',
  'nestedList': '- outer\n  - inner',
};

void main() {
  final out = <String, String>{};
  for (final entry in cases.entries) {
    out[entry.key] = md.markdownToHtml(
      entry.value,
      extensionSet: md.ExtensionSet.gitHubFlavored,
    );
  }
  print(const JsonEncoder.withIndent(' ').convert(out));
}
