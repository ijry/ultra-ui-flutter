# Components B Fourth Source-Order Batch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate the next three registered Components B source routes after CountDown: Color, NumberBox, and CountTo.

**Architecture:** Add one Flutter example page per source route under `example/lib/pages/components_b/`, register the pages in source order, and enable their preview rows. Color is a static source color-token page; NumberBox and CountTo use real `UPNumberBox` and `UPCountTo` widgets. Extend `UPNumberBox` with optional custom slot builders so the source custom NumberBox row can be implemented without bypassing component behavior.

**Tech Stack:** Flutter `>=3.19.0`, Dart `>=3.3.0`, `flutter_test`, existing local `ultra_ui` package, Android/iOS only.

## Global Constraints

- Source of truth is `D:\Repos\xyito\open\uview-plus\src\pages.json` and the matching source files under `src/pages`.
- Preserve registered route order, exact source route title, visible Chinese labels, representative default state, and principal interaction.
- Use `UP*` widgets for each component demonstration. Do not substitute a Material control for the component being demonstrated.
- Color is not a `UPColorPicker` source demo; reproduce the source color swatch page exactly enough for visible parity.
- Do not use remote image resources at runtime.
- `ExampleRoute` entries are added only when a real source page exists. Set a preview route `available: true` only when its matching catalog builder is added.
- Preserve Flutter package names with `UP` prefixes and do not alter unrelated dirty worktree files.
- Every new behavior uses test-first implementation.
- Run `dart format`, `flutter analyze`, `flutter test`, `flutter build apk --debug`, then install and launch the APK on MuMu `127.0.0.1:16384` at the batch boundary.

---

## File Structure

```text
example/lib/pages/components_b/color_page.dart        # Source Color swatch page
example/lib/pages/components_b/number_box_page.dart   # Source NumberBox rows
example/lib/pages/components_b/count_to_page.dart     # Source CountTo sections
example/lib/routes/example_catalog.dart               # Adds three completed route builders
example/lib/routes/example_preview_catalog.dart       # Enables Color, NumberBox, CountTo preview rows
example/test/components_b_pages_test.dart             # Adds page behavior tests
example/test/route_catalog_test.dart                  # Completed route count becomes 40
packages/ultra_ui/lib/src/widgets/up_number_box.dart  # Adds custom slot builders
packages/ultra_ui/test/widgets_test.dart              # Adds NumberBox slot-builder component test
```

### Task 1: Add UPNumberBox Custom Slot Builders

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_number_box.dart`
- Modify: `packages/ultra_ui/test/widgets_test.dart`

**Interfaces:**
- Produces typedef:

```dart
typedef UPNumberBoxSlotBuilder = Widget Function(
  BuildContext context,
  num value,
  bool disabled,
);
```

- Adds optional constructor parameters and fields:

```dart
this.minusBuilder,
this.inputBuilder,
this.plusBuilder,
```

```dart
final UPNumberBoxSlotBuilder? minusBuilder;
final UPNumberBoxSlotBuilder? inputBuilder;
final UPNumberBoxSlotBuilder? plusBuilder;
```

- Custom minus and plus builders retain the component's tap, long-press, range, and event behavior.
- Custom input builder replaces only the visible input surface.

- [x] **Step 1: Write the failing package test**

Append near the existing `UPNumberBox increases value` test in `packages/ultra_ui/test/widgets_test.dart`:

```dart
testWidgets('UPNumberBox custom slot builders keep source step behavior',
    (tester) async {
  num value = 1;
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) {
            return UPNumberBox(
              value: value,
              min: 0,
              max: 3,
              onChange: (next, {name}) => setState(() => value = next),
              minusBuilder: (context, value, disabled) => Text(
                'minus-$value-${disabled ? 'off' : 'on'}',
              ),
              inputBuilder: (context, value, disabled) => Text(
                'input-$value',
              ),
              plusBuilder: (context, value, disabled) => Text(
                'plus-$value-${disabled ? 'off' : 'on'}',
              ),
            );
          },
        ),
      ),
    ),
  );

  expect(find.text('input-1'), findsOneWidget);
  await tester.tap(find.text('plus-1-on'));
  await tester.pumpAndSettle();
  expect(value, 2);
  expect(find.text('input-2'), findsOneWidget);

  await tester.tap(find.text('minus-2-on'));
  await tester.pumpAndSettle();
  expect(value, 1);
});
```

- [x] **Step 2: Run it red**

Run:

```powershell
cd packages\ultra_ui
flutter test test/widgets_test.dart --plain-name "UPNumberBox custom slot builders keep source step behavior" --reporter expanded
```

Expected: FAIL because `minusBuilder`, `inputBuilder`, and `plusBuilder` are undefined.

- [x] **Step 3: Implement builder support**

In `up_number_box.dart`, add the typedef below the imports:

```dart
typedef UPNumberBoxSlotBuilder = Widget Function(
  BuildContext context,
  num value,
  bool disabled,
);
```

Add constructor parameters after `iconStyle`:

```dart
    this.minusBuilder,
    this.inputBuilder,
    this.plusBuilder,
```

Add fields after `iconStyle`:

```dart
  final UPNumberBoxSlotBuilder? minusBuilder;
  final UPNumberBoxSlotBuilder? inputBuilder;
  final UPNumberBoxSlotBuilder? plusBuilder;
```

Replace the local `button(String type)` builder in `UPNumberBoxState.build` with a version that uses the custom builder when present:

```dart
    Widget button(String type) {
      final disabled = _isDisabled(type);
      final slot = type == 'minus' ? widget.minusBuilder : widget.plusBuilder;
      final content = slot?.call(context, _current, disabled) ??
          Container(
            width: btnW,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: disabled ? disabledBg : bg,
              borderRadius: BorderRadius.circular(radius),
            ),
            child: UPIcon(
              name: type == 'minus' ? 'minus' : 'plus',
              size: 15,
              bold: true,
              color: disabled ? tokens.disabledColor : color,
            ),
          );
      return GestureDetector(
        onTap: () => _stepBy(type),
        onLongPressStart: widget.longPress
            ? (_) async {
                while (mounted && !_isDisabled(type)) {
                  _stepBy(type);
                  await Future<void>.delayed(const Duration(milliseconds: 100));
                }
              }
            : null,
        child: content,
      );
    }
```

Replace the `SizedBox` input branch with a custom input branch:

```dart
        if (!hideMinus)
          widget.inputBuilder?.call(
                context,
                _current,
                widget.disabled || widget.disabledInput,
              ) ??
              SizedBox(
                width: inputW,
                height: size,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !(widget.disabled || widget.disabledInput),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    height: 1.2,
                  ),
                  keyboardType: widget.integer
                      ? TextInputType.number
                      : const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: widget.integer
                      ? [FilteringTextInputFormatter.digitsOnly]
                      : null,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: inputBg,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (v) {
                    final n = num.tryParse(v);
                    if (n != null) {
                      widget.onInput?.call(n);
                      widget.onChange?.call(n, name: widget.name);
                    }
                  },
                  onSubmitted: _commit,
                ),
              ),
```

- [x] **Step 4: Run the package test green**

Run:

```powershell
cd packages\ultra_ui
flutter test test/widgets_test.dart --plain-name "UPNumberBox custom slot builders keep source step behavior" --reporter expanded
```

Expected: PASS.

### Task 2: Add Color Source Page

**Files:**
- Create: `example/lib/pages/components_b/color_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/components_b_pages_test.dart`
- Modify: `example/test/route_catalog_test.dart`

**Interfaces:**
- Produces `ColorPage` at route id `componentsB/color/color`.
- Shows source sections `主色调`, `Error`, `Warning`, `Info`, `Success`, `文字颜色`, `边框颜色`, `背景颜色`.
- Uses page key `example-page-componentsB/color/color`.

- [x] **Step 1: Write the failing Color page test**

Append to `example/test/components_b_pages_test.dart`:

```dart
testWidgets('color page renders the source primary swatch', (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsB/color/color'));

  expect(find.text('主色调'), findsOneWidget);
  expect(find.text('Primary'), findsOneWidget);
  expect(find.text('#3c9cff'), findsOneWidget);
  expect(
    find.byKey(const ValueKey('example-page-componentsB/color/color')),
    findsOneWidget,
  );
});
```

Update `example/test/route_catalog_test.dart` for the first route in this batch:

```dart
expect(exampleRoutes, hasLength(38));
```

Add source-order expectation for Components B:

```dart
final componentBRoutes = exampleRoutes
    .where((route) => route.group == ExampleRouteGroup.componentsB)
    .map((route) => route.id)
    .toList();
expect(
  componentBRoutes.take(11),
  <String>[
    'componentsB/dropdown/dropdown',
    'componentsB/actionSheet/actionSheet',
    'componentsB/parse/parse',
    'componentsB/parse/jump',
    'componentsB/toast/toast',
    'componentsB/keyboard/keyboard',
    'componentsB/slider/slider',
    'componentsB/upload/upload',
    'componentsB/notify/notify',
    'componentsB/countDown/countDown',
    'componentsB/color/color',
  ],
);
```

- [x] **Step 2: Run it red**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --plain-name "color page renders the source primary swatch" --reporter expanded
flutter test test/route_catalog_test.dart --reporter expanded
```

Expected: FAIL with an unregistered `componentsB/color/color` route and old total count.

- [x] **Step 3: Implement ColorPage and register it**

Create `ColorPage` with data classes:

```dart
class _ColorSection {
  const _ColorSection({required this.title, required this.swatches});

  final String title;
  final List<_ColorSwatchData> swatches;
}

class _ColorSwatchData {
  const _ColorSwatchData({
    required this.label,
    required this.value,
    required this.color,
    this.darkText = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool darkText;
}
```

Use the source values:

```dart
const List<_ColorSection> _sections = <_ColorSection>[
  _ColorSection(title: '主色调', swatches: <_ColorSwatchData>[
    _ColorSwatchData(label: 'Primary', value: '#3c9cff', color: Color(0xFF3C9CFF)),
    _ColorSwatchData(label: 'Dark', value: '#398ade', color: Color(0xFF398ADE)),
    _ColorSwatchData(label: 'Disabled', value: '#9acafc', color: Color(0xFF9ACAFC)),
    _ColorSwatchData(label: 'Light', value: '#ecf5ff', color: Color(0xFFECF5FF), darkText: true),
  ]),
  _ColorSection(title: 'Error', swatches: <_ColorSwatchData>[
    _ColorSwatchData(label: 'Error', value: '#f56c6c', color: Color(0xFFF56C6C)),
    _ColorSwatchData(label: 'Dark', value: '#e45656', color: Color(0xFFE45656)),
    _ColorSwatchData(label: 'Disabled', value: '#f7b2b2', color: Color(0xFFF7B2B2)),
    _ColorSwatchData(label: 'Light', value: '#fef0f0', color: Color(0xFFFEF0F0), darkText: true),
  ]),
  _ColorSection(title: 'Warning', swatches: <_ColorSwatchData>[
    _ColorSwatchData(label: 'Warning', value: '#f9ae3d', color: Color(0xFFF9AE3D)),
    _ColorSwatchData(label: 'Dark', value: '#f1a532', color: Color(0xFFF1A532)),
    _ColorSwatchData(label: 'Disabled', value: '#f9d39b', color: Color(0xFFF9D39B)),
    _ColorSwatchData(label: 'Light', value: '#fdf6ec', color: Color(0xFFFDF6EC), darkText: true),
  ]),
  _ColorSection(title: 'Info', swatches: <_ColorSwatchData>[
    _ColorSwatchData(label: 'Info', value: '#909399', color: Color(0xFF909399)),
    _ColorSwatchData(label: 'Dark', value: '#767a82', color: Color(0xFF767A82)),
    _ColorSwatchData(label: 'Disabled', value: '#c4c6c9', color: Color(0xFFC4C6C9)),
    _ColorSwatchData(label: 'Light', value: '#f4f4f5', color: Color(0xFFF4F4F5), darkText: true),
  ]),
  _ColorSection(title: 'Success', swatches: <_ColorSwatchData>[
    _ColorSwatchData(label: 'Success', value: '#5ac725', color: Color(0xFF5AC725)),
    _ColorSwatchData(label: 'Dark', value: '#53c21d', color: Color(0xFF53C21D)),
    _ColorSwatchData(label: 'Disabled', value: '#a9e08f', color: Color(0xFFA9E08F)),
    _ColorSwatchData(label: 'Light', value: '#f5fff0', color: Color(0xFFF5FFF0), darkText: true),
  ]),
  _ColorSection(title: '文字颜色', swatches: <_ColorSwatchData>[
    _ColorSwatchData(label: '主要文字', value: '#303133', color: Color(0xFF303133)),
    _ColorSwatchData(label: '常规文字', value: '#606266', color: Color(0xFF606266)),
    _ColorSwatchData(label: '次要文字', value: '#909399', color: Color(0xFF909399)),
    _ColorSwatchData(label: '占位文字', value: '#c0c4cc', color: Color(0xFFC0C4CC)),
  ]),
  _ColorSection(title: '边框颜色', swatches: <_ColorSwatchData>[
    _ColorSwatchData(label: '一级边框', value: '#9a9998', color: Color(0xFF9A9998)),
    _ColorSwatchData(label: '二级边框', value: '#b4b3b1', color: Color(0xFFB4B3B1)),
    _ColorSwatchData(label: '三级边框', value: '#ceccca', color: Color(0xFFCECCCA)),
    _ColorSwatchData(label: '四级边框', value: '#e7e6e4', color: Color(0xFFE7E6E4), darkText: true),
  ]),
  _ColorSection(title: '背景颜色', swatches: <_ColorSwatchData>[
    _ColorSwatchData(label: '背景颜色', value: '#f3f4f6', color: Color(0xFFF3F4F6), darkText: true),
  ]),
];
```

Register immediately after CountDown:

```dart
const ExampleRoute(
  id: 'componentsB/color/color',
  sourcePath: 'pages/componentsB/color/color',
  title: '色彩',
  group: ExampleRouteGroup.componentsB,
  builder: _buildColor,
),
```

Add:

```dart
Widget _buildColor(BuildContext context) => const ColorPage();
```

Set the matching preview route `pages/componentsB/color/color` to `available: true`.

- [x] **Step 4: Run Color tests green**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --plain-name "color page renders the source primary swatch" --reporter expanded
flutter test test/route_catalog_test.dart --reporter expanded
```

Expected: PASS.

### Task 3: Add NumberBox Source Page

**Files:**
- Create: `example/lib/pages/components_b/number_box_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/components_b_pages_test.dart`
- Modify: `example/test/route_catalog_test.dart`

**Interfaces:**
- Produces `NumberBoxPage` at route id `componentsB/numberBox/numberBox`.
- Uses real `UPNumberBox` for all source rows.
- Uses `UPNumberBox.minusBuilder`, `inputBuilder`, and `plusBuilder` for the source custom row.

- [x] **Step 1: Write the failing NumberBox page test**

Append to `example/test/components_b_pages_test.dart`:

```dart
testWidgets('numberBox page increments source basic value and hides custom minus',
    (tester) async {
  await tester
      .pumpWidget(buildRouteUnderTest('componentsB/numberBox/numberBox'));

  expect(find.text('基础用法'), findsOneWidget);
  expect(find.text('基础值：3'), findsOneWidget);

  final basicPlus = find.descendant(
    of: find.byKey(const ValueKey('number-box-page-basic')),
    matching: find.byWidgetPredicate(
      (widget) => widget is UPIcon && widget.name == 'plus',
    ),
  );
  await tester.tap(basicPlus);
  await tester.pumpAndSettle();
  expect(find.text('基础值：4'), findsOneWidget);

  await tester.ensureVisible(find.byKey(const ValueKey('number-box-page-custom')));
  await tester.pump();
  final customMinus = find.byKey(const ValueKey('number-box-custom-minus'));
  expect(customMinus, findsOneWidget);
  await tester.tap(customMinus);
  await tester.pumpAndSettle();
  await tester.tap(customMinus);
  await tester.pumpAndSettle();
  await tester.tap(customMinus);
  await tester.pumpAndSettle();
  expect(customMinus, findsNothing);
  expect(find.text('自定义值：0'), findsOneWidget);
});
```

Extend the Components B source-order expectation in `route_catalog_test.dart` from Task 2:

```dart
expect(exampleRoutes, hasLength(39));
```

```dart
expect(
  componentBRoutes.take(12),
  <String>[
    'componentsB/dropdown/dropdown',
    'componentsB/actionSheet/actionSheet',
    'componentsB/parse/parse',
    'componentsB/parse/jump',
    'componentsB/toast/toast',
    'componentsB/keyboard/keyboard',
    'componentsB/slider/slider',
    'componentsB/upload/upload',
    'componentsB/notify/notify',
    'componentsB/countDown/countDown',
    'componentsB/color/color',
    'componentsB/numberBox/numberBox',
  ],
);
```

- [x] **Step 2: Run it red**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --plain-name "numberBox page increments source basic value and hides custom minus" --reporter expanded
```

Expected: FAIL because `componentsB/numberBox/numberBox` is not registered.

- [x] **Step 3: Implement NumberBoxPage and register it**

Create a `StatefulWidget` with controlled values:

```dart
num _value1 = 3;
num _value2 = 3;
num _value3 = 5;
num _value4 = 3;
num _value5 = 3;
num _value6 = 3;
num _value7 = 3;
num _value8 = 3.1;
num _value9 = 3;
num _value10 = 3;
num _value11 = 3;
bool _asyncLoading = false;
```

Use `UPCellGroup(border: true, children: <Widget>[...])`. Each row is:

```dart
UPCell(
  title: title,
  border: true,
  rightIconSlot: KeyedSubtree(
    key: key,
    child: numberBox,
  ),
)
```

For the basic row, add a small visible state label below the group or in the
row title area:

```dart
Text('基础值：$_value1')
```

For the custom row, add:

```dart
Text('自定义值：$_value11')
```

Use the source custom builders:

```dart
minusBuilder: (context, value, disabled) => Container(
  key: const ValueKey('number-box-custom-minus'),
  width: 22,
  height: 22,
  alignment: Alignment.center,
  decoration: BoxDecoration(
    border: Border.all(color: const Color(0xFFE6E6E6)),
    borderRadius: BorderRadius.circular(100),
  ),
  child: const UPIcon(name: 'minus', size: 12),
),
inputBuilder: (context, value, disabled) => Container(
  width: 50,
  alignment: Alignment.center,
  padding: const EdgeInsets.symmetric(horizontal: 10),
  child: Text('$value', textAlign: TextAlign.center),
),
plusBuilder: (context, value, disabled) => Container(
  key: const ValueKey('number-box-custom-plus'),
  width: 22,
  height: 22,
  alignment: Alignment.center,
  decoration: const BoxDecoration(
    color: Color(0xFFFF0000),
    shape: BoxShape.circle,
  ),
  child: const UPIcon(name: 'plus', color: Colors.white, size: 12),
),
```

For async change:

```dart
void _changeAsync(num next) {
  if (_asyncLoading) return;
  setState(() => _asyncLoading = true);
  UPToast.show(
    message: '正在加载',
    type: 'loading',
    duration: const Duration(seconds: 3),
  );
  Future<void>.delayed(const Duration(seconds: 3), () {
    if (!mounted) return;
    setState(() {
      _value9 = next;
      _asyncLoading = false;
    });
    UPToast.hide();
  });
}
```

Register after Color:

```dart
const ExampleRoute(
  id: 'componentsB/numberBox/numberBox',
  sourcePath: 'pages/componentsB/numberBox/numberBox',
  title: '步进器',
  group: ExampleRouteGroup.componentsB,
  builder: _buildNumberBox,
),
```

Add:

```dart
Widget _buildNumberBox(BuildContext context) => const NumberBoxPage();
```

Set the matching preview route `pages/componentsB/numberBox/numberBox` to `available: true`.

- [x] **Step 4: Run NumberBox tests green**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --plain-name "numberBox page increments source basic value and hides custom minus" --reporter expanded
flutter test test/route_catalog_test.dart --reporter expanded
```

Expected: PASS.

### Task 4: Add CountTo Source Page

**Files:**
- Create: `example/lib/pages/components_b/count_to_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`
- Modify: `example/test/components_b_pages_test.dart`
- Modify: `example/test/route_catalog_test.dart`

**Interfaces:**
- Produces `CountToPage` at route id `componentsB/countTo/countTo`.
- Uses real `UPCountTo` widgets for all six source blocks.
- Manual controls call `UPCountToState.start`, `stop`, and `resume`.

- [x] **Step 1: Write the failing CountTo page test**

Append to `example/test/components_b_pages_test.dart`:

```dart
testWidgets('countTo page starts pauses and resumes the manual source counter',
    (tester) async {
  await tester.pumpWidget(buildRouteUnderTest('componentsB/countTo/countTo'));

  expect(find.text('自定义控制'), findsOneWidget);
  expect(find.text('计数状态：未开始'), findsOneWidget);

  await tester.ensureVisible(find.text('开始'));
  await tester.pump();
  await tester.tap(find.text('开始'));
  await tester.pump();
  expect(find.text('计数状态：运行中'), findsOneWidget);

  await tester.tap(find.text('暂停'));
  await tester.pump();
  expect(find.text('计数状态：已暂停'), findsOneWidget);

  await tester.tap(find.text('继续'));
  await tester.pump();
  expect(find.text('计数状态：继续中'), findsOneWidget);
});
```

Extend the Components B source-order expectation in `route_catalog_test.dart`:

```dart
expect(exampleRoutes, hasLength(40));
```

```dart
expect(
  componentBRoutes.take(13),
  <String>[
    'componentsB/dropdown/dropdown',
    'componentsB/actionSheet/actionSheet',
    'componentsB/parse/parse',
    'componentsB/parse/jump',
    'componentsB/toast/toast',
    'componentsB/keyboard/keyboard',
    'componentsB/slider/slider',
    'componentsB/upload/upload',
    'componentsB/notify/notify',
    'componentsB/countDown/countDown',
    'componentsB/color/color',
    'componentsB/numberBox/numberBox',
    'componentsB/countTo/countTo',
  ],
);
```

- [x] **Step 2: Run it red**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --plain-name "countTo page starts pauses and resumes the manual source counter" --reporter expanded
```

Expected: FAIL because `componentsB/countTo/countTo` is not registered.

- [x] **Step 3: Implement CountToPage and register it**

Create `CountToPage` with:

```dart
final GlobalKey<UPCountToState> _manualKey = GlobalKey<UPCountToState>();
String _manualStatus = '未开始';
```

Use six `ExampleDemoBlock` sections:

```dart
ExampleDemoBlock(
  title: '基础功能',
  child: const Padding(
    padding: EdgeInsets.all(12),
    child: UPCountTo(endVal: 3000),
  ),
)
```

Use source configurations for the remaining sections:

```dart
const UPCountTo(startVal: 300)
const UPCountTo(startVal: 100.00, endVal: 10.55, decimals: 2)
const UPCountTo(startVal: 2000, endVal: 1542, separator: ',', decimals: 2)
UPCountTo(key: _manualKey, endVal: 3000, autoplay: false)
const UPCountTo(endVal: 3000, color: '#909399', fontSize: 40, bold: true)
```

Manual controls:

```dart
UPGrid(
  border: true,
  align: 'center',
  children: <Widget>[
    UPGridItem(
      onClick: (_) => _startManual(),
      child: const _CountToGridItem(label: '开始'),
    ),
    UPGridItem(
      onClick: (_) => _pauseManual(),
      child: const _CountToGridItem(label: '暂停'),
    ),
    UPGridItem(
      onClick: (_) => _resumeManual(),
      child: const _CountToGridItem(label: '继续'),
    ),
  ],
)
```

Register after NumberBox:

```dart
const ExampleRoute(
  id: 'componentsB/countTo/countTo',
  sourcePath: 'pages/componentsB/countTo/countTo',
  title: '数字滚动',
  group: ExampleRouteGroup.componentsB,
  builder: _buildCountTo,
),
```

Add:

```dart
Widget _buildCountTo(BuildContext context) => const CountToPage();
```

Set the matching preview route `pages/componentsB/countTo/countTo` to `available: true`.

- [x] **Step 4: Run CountTo tests green**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --plain-name "countTo page starts pauses and resumes the manual source counter" --reporter expanded
flutter test test/route_catalog_test.dart --reporter expanded
```

Expected: PASS.

### Task 5: Batch Verification and Commit

**Files:**
- All files from Tasks 1-4.
- Modify this plan file to mark completed steps before staging.

**Interfaces:**
- Completed example route catalog has 40 routes: 4 main, 23 Components A, and 13 Components B.
- Color, NumberBox, and CountTo preview rows are `available: true`; other unfinished preview rows remain unavailable.

- [x] **Step 1: Run formatting**

Run:

```powershell
cd example
dart format lib/pages/components_b/color_page.dart lib/pages/components_b/number_box_page.dart lib/pages/components_b/count_to_page.dart lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/components_b_pages_test.dart test/route_catalog_test.dart
cd ..\packages\ultra_ui
dart format lib/src/widgets/up_number_box.dart test/widgets_test.dart
cd ..\..
git diff --check -- docs/superpowers/plans/2026-07-28-uview-components-b-batch-4.md
```

- [x] **Step 2: Run targeted tests**

Run:

```powershell
cd example
flutter test test/components_b_pages_test.dart --plain-name "color page renders the source primary swatch" --reporter expanded
flutter test test/components_b_pages_test.dart --plain-name "numberBox page increments source basic value and hides custom minus" --reporter expanded
flutter test test/components_b_pages_test.dart --plain-name "countTo page starts pauses and resumes the manual source counter" --reporter expanded
flutter test test/route_catalog_test.dart --reporter expanded
cd ..\packages\ultra_ui
flutter test test/widgets_test.dart --plain-name "UPNumberBox custom slot builders keep source step behavior" --reporter expanded
```

- [x] **Step 3: Run full verification**

Run the example commands sequentially from the `example` directory:

```powershell
flutter analyze
flutter test --reporter expanded
flutter build apk --debug
```

Run the package command from the `packages\ultra_ui` directory:

```powershell
flutter test test/widgets_test.dart --reporter expanded
```

- [x] **Step 4: Install and launch on MuMu**

Run:

```powershell
cd example
$adb = (Get-Command adb).Source
$serial = '127.0.0.1:16384'
& $adb connect $serial
& $adb -s $serial install -r build\app\outputs\flutter-apk\app-debug.apk
& $adb -s $serial shell am force-stop com.example.ultra_ui_example
& $adb -s $serial shell monkey -p com.example.ultra_ui_example -c android.intent.category.LAUNCHER 1
& $adb -s $serial shell dumpsys window | Select-String 'com.example.ultra_ui_example/.MainActivity'
```

- [x] **Step 5: Commit only this batch**

Run:

```powershell
git diff --check -- docs/superpowers/plans/2026-07-28-uview-components-b-batch-4.md example/lib/pages/components_b/color_page.dart example/lib/pages/components_b/number_box_page.dart example/lib/pages/components_b/count_to_page.dart example/lib/routes/example_catalog.dart example/lib/routes/example_preview_catalog.dart example/test/components_b_pages_test.dart example/test/route_catalog_test.dart packages/ultra_ui/lib/src/widgets/up_number_box.dart packages/ultra_ui/test/widgets_test.dart
git add -- docs/superpowers/plans/2026-07-28-uview-components-b-batch-4.md example/lib/pages/components_b/color_page.dart example/lib/pages/components_b/number_box_page.dart example/lib/pages/components_b/count_to_page.dart example/lib/routes/example_catalog.dart example/lib/routes/example_preview_catalog.dart example/test/components_b_pages_test.dart example/test/route_catalog_test.dart packages/ultra_ui/lib/src/widgets/up_number_box.dart packages/ultra_ui/test/widgets_test.dart
git diff --cached --check
git commit -m "feat(example): add color numberbox countto source pages"
```

## Plan Self-Review

- Spec coverage: Tasks cover the three approved source routes, the required `UPNumberBox` API extension, route/preview enablement, tests, APK build, and MuMu launch.
- Placeholder scan: No deferred-detail markers or vague unimplemented steps remain.
- Type consistency: Route ids, source paths, page class names, builder names, and `UPNumberBoxSlotBuilder` signatures are consistent across tasks.
