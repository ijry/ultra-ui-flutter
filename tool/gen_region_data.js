// Transcribe uview-plus's province/city/area data into a Dart constant.
//
// The citySelect template needs the full mainland region tree: 34 provinces, each
// with cities, each with districts (~140KB of source JS). Generating it keeps the
// demo's data identical to upstream and avoids hand-transcribing thousands of
// entries.
//
// Usage: node tool/gen_region_data.js
const fs = require('fs');
const os = require('os');
const path = require('path');

const SRC = 'D:/Repos/xyito/open/uview-plus/src/pages/template/common';
const OUT =
  'D:/Repos/xyito/open/ultra-ui-flutter/example/lib/pages/template/region_data.dart';

function load(name) {
  const tmp = path.join(os.tmpdir(), `up_region_${name}.js`);
  fs.writeFileSync(
    tmp,
    fs
      .readFileSync(path.join(SRC, `${name}.js`), 'utf8')
      .replace('export default', 'module.exports ='),
  );
  return require(tmp);
}

const provinces = load('province');
const citys = load('city');
const areas = load('area');

const q = (s) => "'" + String(s).replace(/\\/g, '\\\\').replace(/'/g, "\\'") + "'";
const entry = (o) => `<String, String>{${q('label')}: ${q(o.label)}, ${q('value')}: ${q(o.value)}}`;

const lines = [
  '// GENERATED — do not edit by hand.',
  '//',
  '// Transcribed from uview-plus src/pages/template/common/{province,city,area}.js',
  '// by tool/gen_region_data.js.',
  '//',
  '// provinces[i] pairs with citys[i], and citys[i][j] with areas[i][j] — the',
  '// source keys them by position, not by code, so the three lists must stay',
  '// aligned.',
  '',
  'const List<Map<String, String>> provinces = <Map<String, String>>[',
  ...provinces.map((p) => `  ${entry(p)},`),
  '];',
  '',
  'const List<List<Map<String, String>>> citys = <List<Map<String, String>>>[',
  ...citys.map((group) => `  <Map<String, String>>[${group.map(entry).join(', ')}],`),
  '];',
  '',
  'const List<List<List<Map<String, String>>>> areas =',
  '    <List<List<Map<String, String>>>>[',
  ...areas.map(
    (province) =>
      '  <List<Map<String, String>>>[\n' +
      province
        .map((city) => `    <Map<String, String>>[${city.map(entry).join(', ')}],`)
        .join('\n') +
      '\n  ],',
  ),
  '];',
  '',
];

fs.writeFileSync(OUT, lines.join('\n'));
console.log(
  `wrote ${OUT}: ${provinces.length} provinces, ` +
    `${citys.reduce((n, c) => n + c.length, 0)} cities, ` +
    `${areas.reduce((n, p) => n + p.reduce((m, c) => m + c.length, 0), 0)} districts`,
);
