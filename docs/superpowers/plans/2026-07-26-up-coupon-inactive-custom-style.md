# UPCoupon Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Preserve `UPCoupon.customStyle` as a Flutter API parameter without rendering a decoration that the uview-plus coupon template never consumes.

**Architecture:** The `u-coupon.vue` root merges only its `couponStyle` computed value, which derives from `bgColor` and `color`; it defines no `customStyle` prop and imports no shared mixin. Retain the Dart constructor field, remove only the non-source outer wrapper, and assert that the provided decoration does not enter the widget tree.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Keep public `UPCoupon` constructor compatibility and all source-backed coupon props.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-coupon\u-coupon.vue`.
- Preserve source-rendered `bgColor`, `color`, click, disabled, slot, shape, and size behavior.
- Use `apply_patch` for manual edits; do not alter unrelated workspace files.
- Do not commit, reset, clean, or revert existing workspace changes.

---

### Task 1: Align UPCoupon Custom-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_coupon.dart` near the final `customStyle` wrapper
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPCoupon` tests
- Modify: `docs/gap-matrix.md` append the verified batch record

**Interfaces:**
- Consumes: `const UPCoupon({dynamic amount = '', String unit = '￥', String unitPosition = 'left', String limit = '', String title = '优惠券', String desc = '', String time = '', String actionText = '使用', String shape = 'coupon', String size = 'medium', bool circle = false, bool disabled = false, dynamic bgColor = '', dynamic color = '', String type = '', VoidCallback? onClick, BoxDecoration? customStyle})`.
- Produces: unchanged public constructor API; supplied `customStyle` creates no matching `DecoratedBox`; source `bgColor` and `color` remain rendered through the coupon root.

- [ ] **Step 1: Add the failing widget test**

```dart
testWidgets('UPCoupon leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPCoupon(title: '优惠券', customStyle: customStyle),
      ),
    ),
  );
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [ ] **Step 2: Confirm the test currently fails**

Run: `flutter test test/widgets_test.dart --plain-name "UPCoupon leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: failure because the Flutter port wraps the coupon in `Container(decoration: customStyle)`.

- [ ] **Step 3: Remove only the non-source wrapper**

```dart
// Preserve the customStyle field and constructor parameter.
// Delete only the final wrapper:
if (customStyle != null) {
  root = Container(decoration: customStyle, child: root);
}
```

- [ ] **Step 4: Verify visual and behavior regressions**

Run:

```powershell
dart format lib/src/widgets/up_coupon.dart test/widgets_test.dart
flutter analyze lib/src/widgets/up_coupon.dart
flutter test test/widgets_test.dart --plain-name "UPCoupon leaves source-inactive customStyle unrendered" --reporter expanded
flutter test test/widgets_test.dart --plain-name "UPCoupon renders amount and title" --reporter expanded
flutter test test/widgets_test.dart --plain-name "UPCoupon disabled prevents click" --reporter expanded
flutter test --reporter expanded
```

Expected: all commands pass. `bgColor` and `color` still decorate the coupon itself, while only the unsupported `customStyle` wrapper disappears.

- [ ] **Step 5: Record verified parity**

Append a dated `docs/gap-matrix.md` entry explaining that `UPCoupon` retains the Flutter parameter but does not render `customStyle`, because the source template consumes only computed `couponStyle` from `bgColor` and `color`.

