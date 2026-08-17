# UPParse Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep the Flutter-retained `UPParse.customStyle` API compatible without rendering a decoration that the source parser template never declares.

**Architecture:** `u-parse.vue` is standalone and binds its root view to `containerStyle`, not `customStyle`. Remove only Flutter's custom-style decoration wrapper. `containerStyle` is an independent active source API that requires a defined CSS-string-to-Flutter-style mapping and remains outside this narrow no-op alignment.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve public `UPParse` constructor compatibility.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-parse\u-parse.vue`.
- Preserve parser rendering, selectable content, callbacks, and public helper behavior.
- Do not implement `containerStyle` as an incidental side effect of aligning `customStyle`.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align UPParse Custom-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_parse.dart:271-286`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPParse` tests
- Modify: `docs/gap-matrix.md` append the verified parity record and active `containerStyle` follow-up

**Interfaces:**
- Consumes: `const UPParse({String content = '', String? containerStyle, bool selectable = false, BoxDecoration? customStyle, ValueChanged<String>? onLinkTap, ValueChanged<String>? onImgTap})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source parser content and helper APIs remain unchanged; `containerStyle` remains documented as not yet mapped.

- [x] **Step 1: Add the failing widget test**

```dart
testWidgets('UPParse leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPParse(
          content: '<p>解析内容</p>',
          customStyle: customStyle,
        ),
      ),
    ),
  );
  expect(find.textContaining('解析内容'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPParse leaves source-inactive customStyle unrendered" --reporter expanded`

Observed: failure because `UPParse` wrapped its root in `Container(decoration: customStyle)`.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
// Do not change the independent `containerStyle` field in this task.
// Remove only this final build branch:
if (customStyle != null) {
  root = Container(decoration: customStyle, child: root);
}
```

- [x] **Step 4: Verify parser behavior**

Run:

```powershell
dart format lib/src/widgets/up_parse.dart test/widgets_test.dart
flutter test test/widgets_test.dart --name "UPParse (renders html text|leaves source-inactive customStyle unrendered|renders list and code|BatchE setContent/getText/link helpers|renders strike video task and h4-h6)" --reporter expanded
flutter analyze lib/src/widgets/up_parse.dart
```

Observed: all five focused tests and static analysis pass.

- [x] **Step 5: Verify suite and record source parity**

Run:

```powershell
flutter test --reporter expanded
git diff --check
```

Append a dated `docs/gap-matrix.md` entry noting that `UPParse.customStyle` is retained but inactive, while source-backed `containerStyle` remains a separate unmapped API gap.

Observed: `flutter test --reporter expanded` passes all 634 tests and `git diff --check` passes.
