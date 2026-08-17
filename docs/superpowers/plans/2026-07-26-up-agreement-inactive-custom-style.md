# UPAgreement Inactive Custom Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep the Flutter-only `UPAgreement.customStyle` constructor API compatible without rendering a decoration absent from the source agreement template.

**Architecture:** `u-agreement.vue` declares only agreement URL props and renders an `up-modal` inside an unstyled root view. It neither declares nor consumes `customStyle`. Remove only the Flutter outer decoration wrapper, leaving the source-backed modal, agreement links, controller, and confirmation flow unchanged.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Preserve the public `UPAgreement` constructor and `customStyle` field.
- Match `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus\components\u-agreement\u-agreement.vue`.
- Preserve source-backed modal visibility, cancel, confirmation, default agreement content, URLs, and controller behavior.
- Use `apply_patch` for manual edits and leave unrelated workspace changes intact.
- Do not commit, reset, clean, or revert existing worktree changes.

---

### Task 1: Align Agreement Shared-Style Rendering

**Files:**
- Modify: `packages/ultra_ui/lib/src/widgets/up_agreement.dart` near `UPAgreementState.build`
- Modify: `packages/ultra_ui/test/widgets_test.dart` near existing `UPAgreement` tests
- Modify: `docs/gap-matrix.md` append the verified parity record

**Interfaces:**
- Consumes: `UPAgreement({String urlProtocol, String urlPrivacy, UPAgreementController? controller, BoxDecoration? customStyle, ValueChanged<int>? onConfirm})`.
- Produces: unchanged constructor API; supplied `customStyle` produces no matching `DecoratedBox`; modal remains initially closed and controller-driven.

- [x] **Step 1: Add the failing widget regression**

```dart
testWidgets('UPAgreement leaves source-inactive customStyle unrendered',
    (tester) async {
  const customStyle = BoxDecoration(color: Color(0xff123456));
  final controller = UPAgreementController();
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: Scaffold(
        body: UPAgreement(
          controller: controller,
          customStyle: customStyle,
        ),
      ),
    ),
  );

  controller.showModal();
  await tester.pumpAndSettle();
  expect(find.text('阅读并同意'), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration == customStyle,
    ),
    findsNothing,
  );
});
```

- [x] **Step 2: Confirm current behavior fails**

Run: `flutter test test/widgets_test.dart --name "UPAgreement leaves source-inactive customStyle unrendered" --reporter expanded`

Expected: FAIL because `UPAgreementState.build` wraps its modal root in `Container(decoration: widget.customStyle)`.

Observed: UPModal retains hidden content using `AnimatedOpacity`, so the initial assertion was revised to open through the source controller path. The revised test rendered the confirmation action and then failed only after finding one `DecoratedBox` carrying `customStyle`, produced by the Flutter-only agreement wrapper.

- [x] **Step 3: Delete only the Flutter-only decoration wrapper**

```dart
// Keep `final BoxDecoration? customStyle;` and its constructor parameter.
// Remove only this final build branch:
if (widget.customStyle != null) {
  root = Container(decoration: widget.customStyle, child: root);
}
```

- [x] **Step 4: Verify focused agreement behavior**

Run: `dart format lib/src/widgets/up_agreement.dart test/widgets_test.dart`

Run: `flutter test test/widgets_test.dart --name "UPAgreement (controller showModal and confirm|leaves source-inactive customStyle unrendered|BatchD urlClick/showModal/close)" --reporter expanded`

Run: `flutter analyze lib/src/widgets/up_agreement.dart`

Expected: all focused tests pass and analysis has no diagnostics.

Observed: all three focused widget tests passed and `flutter analyze lib/src/widgets/up_agreement.dart` reported no issues.

- [x] **Step 5: Verify suite and record source parity**

Run: `flutter test --reporter expanded`

Run: `git diff --check`

Append a dated `docs/gap-matrix.md` entry noting that `UPAgreement` retains its Flutter `customStyle` constructor parameter for compatibility but does not render it because the source component declares and consumes no such prop.

Observed: `flutter test --reporter expanded` passed all 642 tests. `git diff --check` completed with no whitespace errors.
