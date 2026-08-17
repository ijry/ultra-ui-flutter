# UPButton Custom Style Merge Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `UPButton.customStyle` merge with the source button's base decoration instead of replacing it.

**Architecture:** `u-button.vue` applies `[baseColor, addStyle(customStyle)]`, so caller fields override only their corresponding base CSS fields. Flutter now builds its intrinsic color, border, and radius decoration first, then overlays non-null `BoxDecoration` fields from `customStyle`; a custom gradient clears the base solid color because Flutter decorations cannot contain both simultaneously.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPButton` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-button\u-button.vue`.
- Preserve source-backed type colors, plain/disabled/loading states, dimensions, click handling, and open-type aliases.
- Do not replace intrinsic source styles merely because a caller supplies one custom style field.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Merge Root Decoration Fields

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_button.dart` near `UPButtonState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPButton` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPButton({String type = 'primary', BoxDecoration? customStyle, ...})`.
- Produces: a source-derived root decoration whose non-null `customStyle` fields override only matching base decoration fields.

- [x] **Step 1: Verify source style ordering**

Both source root branches in `u-button.vue` bind `[baseColor, addStyle(customStyle)]`. This means base button colors, shape, and borders are present before only the caller's specified custom CSS keys override them.

- [x] **Step 2: Write and confirm the failing widget regression**

```dart
testWidgets('UPButton merges source customStyle with base decoration',
    (tester) async {
  const customBorder = Border(
    top: BorderSide(color: Color(0xff123456), width: 2),
  );
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: UPButton(
          text: 'merge style',
          type: 'primary',
          customStyle: BoxDecoration(border: customBorder),
        ),
      ),
    ),
  );

  final decoration = tester.widget<Container>(
    find.ancestor(
      of: find.text('merge style'),
      matching: find.byType(Container),
    ).first,
  ).decoration! as BoxDecoration;
  expect(decoration.color, UPThemeTokens.light().primary);
  expect(decoration.border, customBorder);
  expect(decoration.borderRadius, BorderRadius.circular(3));
});
```

Run: `flutter test test/widgets_test.dart --name "UPButton merges source customStyle with base decoration" --reporter expanded`

Expected: FAIL because Flutter assigned `customStyle` as the full decoration.

Observed: the root decoration color was `null`, confirming the source primary color had been replaced.

- [x] **Step 3: Overlay caller fields onto the base decoration**

Create the source-backed base `BoxDecoration`, then use `copyWith` to overlay non-null caller color, image, border, radius, shadow, gradient, and blend mode. When a caller supplies a gradient, clear the base solid color to respect Flutter's mutually exclusive decoration constraint.

- [x] **Step 4: Verify focused button behavior**

Run: `dart format lib/src/widgets/up_button.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPButton (renders text and handles click|disabled does not click|accepts source numeric text values|BatchI launchapp shell|BatchJ aliases|merges source customStyle with base decoration)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_button.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all five matching widget tests passed and `flutter analyze lib/src/widgets/up_button.dart` reported no diagnostics.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPButton` combines its source base decoration with non-null caller `customStyle` fields in source array order.

Expected: full suite passes, `git diff --check` reports no whitespace errors, and the compatibility matrix records the batch.

Observed: `flutter test --reporter expanded` passed all 685 tests. The compatibility matrix records batch HI; `git diff --check` reported no whitespace errors.
