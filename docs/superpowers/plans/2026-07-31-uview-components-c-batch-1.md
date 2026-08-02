# Components C Batch 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Flutter example pages for the first five uView Plus Components C source demos: Form, Textarea, NoNetwork, Loadmore, and Text.

**Architecture:** Add one route page per source demo under `example/lib/pages/components_c/`, register them immediately after Components B Table2, and enable their existing preview entries. Each page owns deterministic local state and uses the existing `UP*` widgets without adding dependencies or network requirements.

**Tech Stack:** Flutter, Dart, `ultra_ui`, existing example route catalog, Flutter widget tests, adb.

## Global Constraints

- Source root: `D:\Repos\xyito\open\uview-plus\src`.
- Preserve `pages.json` source order.
- Component class names use the `UP` prefix.
- Runtime target is Android/iOS Flutter only.
- Preserve source labels, representative props, and principal interactions.
- Do not stage `README.md` or unrelated untracked files.
- Work directly on `main`, matching the previously approved workflow.

---

## File Structure

- Create `example/lib/pages/components_c/form_page.dart`: source form fields, validation, reset, sex action sheet, calendar, birthday picker, and code countdown.
- Create `example/lib/pages/components_c/textarea_page.dart`: five ordered textarea examples.
- Create `example/lib/pages/components_c/no_network_page.dart`: source normal-network view plus deterministic offline/retry controls.
- Create `example/lib/pages/components_c/loadmore_page.dart`: seven ordered loadmore examples and click feedback.
- Create `example/lib/pages/components_c/text_page.dart`: ten ordered text examples and platform fallback feedback.
- Modify `example/lib/routes/example_catalog.dart`: imports, five route entries, and builders.
- Modify `example/lib/routes/example_preview_catalog.dart`: mark the five preview rows available.
- Create `example/test/components_c_pages_test.dart`: focused interactions for all five pages.
- Modify `example/test/route_catalog_test.dart`: completed total `55 -> 60` and Components C source-order assertions.

## Task 1: Add Failing Route And Page Tests

**Files:**
- Create: `example/test/components_c_pages_test.dart`
- Modify: `example/test/route_catalog_test.dart`

**Interfaces:**
- Consumes: `buildRouteUnderTest(String id)`, `findExampleRoute(String id)`, `UPToast.hide()`.
- Produces: failing expectations for the five missing route pages and route order.

- [ ] **Step 1: Extend route catalog expectations**

Change the completed route count to `60`. Add a Components C list assertion whose first five ids are:

```dart
<String>[
  'componentsC/form/form',
  'componentsC/textarea/textarea',
  'componentsC/noNetwork/noNetwork',
  'componentsC/loadmore/loadmore',
  'componentsC/text/text',
]
```

- [ ] **Step 2: Add focused page tests**

Create tests with these names and assertions:

```dart
testWidgets('form page selects sex and reports validation state', ...);
testWidgets('textarea page edits the source basic value', ...);
testWidgets('noNetwork page renders normal state and retries offline panel', ...);
testWidgets('loadmore page emits the source loadmore action', ...);
testWidgets('text page renders source modes and share fallback', ...);
```

Use stable page keys and section keys. Clean `UPToast` after toast assertions.

- [ ] **Step 3: Run tests and confirm missing-route failure**

Run:

```powershell
cd example
flutter test test/route_catalog_test.dart test/components_c_pages_test.dart --reporter expanded
```

Expected: FAIL because the five routes are not registered.

## Task 2: Implement Form Page

**Files:**
- Create: `example/lib/pages/components_c/form_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`

**Interfaces:**
- Consumes: `UPFormState.validate`, `setModelValue`, `resetFields`, `clearValidate`; `UPActionSheet`; `UPCalendar`; `UPDatetimePicker`; `UPCodeController`.
- Produces: `FormPage` and route `componentsC/form/form`.

- [ ] **Step 1: Build the source field order**

Create `FormPage` with `ExamplePageScaffold(scrollable: false)` and an internal `Stack` containing a `ListView` plus popup widgets. Render the nine source fields under `基础使用` in source order. Keep visible state labels such as `姓名：楼兰`, `性别：未选择`, and `提交状态：未提交` for deterministic tests.

- [ ] **Step 2: Wire model and validation**

Use a `GlobalKey<UPFormState>` and local model map. Every input callback updates both local state and `UPFormState.setModelValue`. Use source-shaped required/min/length rules. Submit awaits `validate()` and sets `提交状态：校验通过` or `提交状态：校验失败`.

- [ ] **Step 3: Add source popup interactions**

Use `UPActionSheet` for sex; selecting `男` or `女` updates and validates the field. Use `UPCalendar(mode: 'range')` for hotel dates and `UPDatetimePicker(mode: 'date')` for birthday. Use `UPCodeController` for the 20-second code countdown and show `验证码已发送` before starting.

- [ ] **Step 4: Add reset behavior**

Reset local model to the source initial values, call `resetFields()` and `clearValidate()`, reset the code controller, and set `提交状态：已重置`.

- [ ] **Step 5: Register Form and run its test**

Register the route after Table2, enable its preview row, then run:

```powershell
cd example
flutter test test/components_c_pages_test.dart --name "form page" --reporter expanded
```

Expected: PASS.

## Task 3: Implement Textarea Page

**Files:**
- Create: `example/lib/pages/components_c/textarea_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`

**Interfaces:**
- Consumes: `UPTextarea(value:, onUpdateValue:)`.
- Produces: `TextareaPage` and route `componentsC/textarea/textarea`.

- [ ] **Step 1: Build five ordered blocks**

Render `基础使用`, `字数统计`, `自动增高`, `禁用状态`, and `下划线模式` with source props. Put the first block under `ValueKey('textarea-page-basic')` and expose `基础值：<value>`.

- [ ] **Step 2: Register Textarea and run its test**

Register immediately after Form, enable the preview row, then run:

```powershell
cd example
flutter test test/components_c_pages_test.dart --name "textarea page" --reporter expanded
```

Expected: PASS.

## Task 4: Implement NoNetwork, Loadmore, And Text Pages

**Files:**
- Create: `example/lib/pages/components_c/no_network_page.dart`
- Create: `example/lib/pages/components_c/loadmore_page.dart`
- Create: `example/lib/pages/components_c/text_page.dart`
- Modify: `example/lib/routes/example_catalog.dart`
- Modify: `example/lib/routes/example_preview_catalog.dart`

**Interfaces:**
- Consumes: `UPNoNetworkState.show/hide/retry`, `UPLoadmore.onLoadmore`, `UPText` modes.
- Produces: the remaining three Components C batch routes.

- [ ] **Step 1: Build NoNetwork page**

Default to the source normal state with the green check circle and exact hint text. Add a source-compatible deterministic button `模拟断网` that calls `UPNoNetworkState.show()`. The offline panel's `重试` increments `重试：N`; a `恢复网络` action calls `hide()`. Keep event counters visible.

- [ ] **Step 2: Build Loadmore page**

Render all seven source blocks with exact statuses and labels. The click block increments `加载次数：N` and shows `加载更多` with `UPToast.show`.

- [ ] **Step 3: Build Text page**

Render all ten source blocks with exact source text and props. Expose `UPText` modes for phone/date/name/link/price, prefix/suffix icons, two-line truncation, and the mini-program share fallback toast.

- [ ] **Step 4: Register routes and enable previews**

Register NoNetwork, Loadmore, and Text after Textarea in source order. Enable only their matching preview rows.

- [ ] **Step 5: Run focused tests**

Run:

```powershell
cd example
flutter test test/components_c_pages_test.dart --reporter expanded
flutter test test/route_catalog_test.dart --reporter expanded
```

Expected: PASS.

## Task 5: Final Verification And Commit

**Files:**
- Include all five pages, route changes, preview changes, tests, and this plan.
- Include package widget files only when modified or required as untracked dependencies of the batch.

**Interfaces:**
- Produces: a verified Components C batch 1 commit.

- [ ] **Step 1: Format changed files**

```powershell
cd example
dart format lib/pages/components_c/form_page.dart lib/pages/components_c/textarea_page.dart lib/pages/components_c/no_network_page.dart lib/pages/components_c/loadmore_page.dart lib/pages/components_c/text_page.dart lib/routes/example_catalog.dart lib/routes/example_preview_catalog.dart test/components_c_pages_test.dart test/route_catalog_test.dart
```

- [ ] **Step 2: Run full verification**

```powershell
cd example
flutter analyze
flutter test --reporter expanded
flutter build apk --debug

cd ..\packages\ultra_ui
flutter test test/widgets_test.dart --reporter expanded
```

- [ ] **Step 3: Install to MuMu**

Install `example/build/app/outputs/flutter-apk/app-debug.apk` to `127.0.0.1:16384`, launch `com.example.ultra_ui_example`, and verify `MainActivity` is focused.

- [ ] **Step 4: Commit only batch files**

Stage only the plan, five pages, route/preview files, tests, and any package files actually required by this batch. Leave `README.md` and unrelated untracked files untouched.
