# UPGoodsSku Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retain `UPGoodsSku.customStyle` constructor compatibility without rendering a decoration absent from the source goods-SKU template.

**Architecture:** The source root is an unstyled `up-goods-sku` view with a trigger slot and an internal `up-popup`. The local prop definition declares SKU data, popup options, and pageInline only; `customStyle` is neither declared nor consumed. Flutter retains the optional parameter while returning source-backed page-inline and popup roots without an extra decoration.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPGoodsSku` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-goods-sku\u-goods-sku.vue`.
- Preserve source-backed SKU matching, disabled combinations, quantity logic, popup lifecycle, slot areas, callbacks, and model aliases.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Goods-SKU Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_goods_sku.dart` near `UPGoodsSkuState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPGoodsSku` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPGoodsSku({Map goodsInfo = const {}, List skuTree = const [], bool pageInline = false, BoxDecoration? customStyle, ...})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; source-backed SKU content remains mounted.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPGoodsSku leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: const Scaffold(
        body: UPGoodsSku(
          pageInline: true,
          customStyle: customStyle,
          goodsInfo: {'title': '测试商品', 'price': 99, 'stock': 10},
        ),
      ),
    ),
  );

  expect(find.text('测试商品'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPGoodsSku leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPGoodsSkuState.build` wraps its source-backed page-inline root in `Container(decoration: widget.customStyle)`; the same Flutter-only wrapper is used in the popup path.

Observed: the page-inline regression found one matching `DecoratedBox`, produced by the Flutter-only root wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrappers**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
// Return the page-inline `_body(context)` and popup root directly.
```

- [x] **Step 4: Verify focused goods-SKU behavior**

Run: `dart format lib/src/widgets/up_goods_sku.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPGoodsSku (pageInline selects sku|leaves source-inactive customStyle unrendered|disables unmatched sku and trigger open|public onNumChange/getSelectedSkuComb|BatchG getSelectedSkuComb)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_goods_sku.dart`

Expected: focused tests pass and analysis has no diagnostics.

Observed: all five focused widget tests passed and `flutter analyze lib/src/widgets/up_goods_sku.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPGoodsSku` retains Flutter `customStyle` API compatibility without rendering it, because both source root paths and local props never consume the prop.

Observed: `flutter test --reporter expanded` passed all 662 tests. `git diff --check` completed with no whitespace errors.
