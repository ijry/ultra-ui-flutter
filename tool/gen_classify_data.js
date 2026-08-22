// Transcribe uview-plus's classify.data.js into a Dart constant.
//
// The mall-menu templates render a 14-category, 169-item catalogue. Generating it
// from the source keeps the demo showing the same data as upstream, and means a
// change there can be picked up by re-running this rather than by hand-editing
// 169 entries.
//
// Usage: node tool/gen_classify_data.js
const fs = require('fs');
const path = require('path');

const SRC =
  'D:/Repos/xyito/open/uview-plus/src/pages/template/common/classify.data.js';
const OUT =
  'D:/Repos/xyito/open/ultra-ui-flutter/example/lib/pages/template/classify_data.dart';

// The source is an ES module; rewrite the single export so require() can load it.
const tmp = path.join(require('os').tmpdir(), 'up_classify_data.js');
fs.writeFileSync(
  tmp,
  fs.readFileSync(SRC, 'utf8').replace('export default', 'module.exports ='),
);
const data = require(tmp);

// Dart single-quoted string literal.
const q = (s) => "'" + String(s).replace(/\\/g, '\\\\').replace(/'/g, "\\'") + "'";

const lines = [
  '// GENERATED — do not edit by hand.',
  '//',
  "// Transcribed from uview-plus src/pages/template/common/classify.data.js by",
  '// tool/gen_classify_data.js. 14 categories, 169 items.',
  '',
  'const List<Map<String, Object>> classifyData = <Map<String, Object>>[',
];
for (const category of data) {
  lines.push('  <String, Object>{');
  lines.push(`    ${q('name')}: ${q(category.name)},`);
  lines.push(`    ${q('foods')}: <Map<String, Object>>[`);
  for (const food of category.foods) {
    lines.push(
      `      <String, Object>{${q('name')}: ${q(food.name)}, ` +
        `${q('key')}: ${q(food.key)}, ${q('icon')}: ${q(food.icon)}, ` +
        `${q('cat')}: ${food.cat}},`,
    );
  }
  lines.push('    ],');
  lines.push('  },');
}
lines.push('];', '');

fs.writeFileSync(OUT, lines.join('\n'));
console.log(
  `wrote ${OUT}: ${data.length} categories, ` +
    `${data.reduce((n, c) => n + c.foods.length, 0)} items`,
);
