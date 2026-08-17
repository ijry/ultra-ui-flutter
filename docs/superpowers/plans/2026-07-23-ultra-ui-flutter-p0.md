# Ultra UI Flutter P0 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish source-driven 1:1 Flutter port infrastructure and ship UPIcon/UPButton with uview-plus defaults.

**Architecture:** `packages/ultra_ui` library + `example` gallery. Config/theme/utils mirror uview-plus `$u`. Widgets use UP prefix and source prop defaults/styles.

**Tech Stack:** Flutter 3.41+, Dart 3.11+, pure Flutter widgets, bundled `upicon.ttf`.

## Global Constraints

- Source of truth: uview-plus 3.8.82 at `D:\Repos\xyito\open\uview-plus\src\uni_modules\uview-plus`
- Widget prefix: `UP*`
- Visual tolerance: ±1 logical px
- Keep platform-only props as no-op retained API
- End state remains full component-set parity

---

### Task 1: Package scaffold + core config/theme/utils

**Files:**
- Create: `packages/ultra_ui/pubspec.yaml`
- Create: `packages/ultra_ui/lib/ultra_ui.dart`
- Create: `packages/ultra_ui/lib/src/config/up_config.dart`
- Create: `packages/ultra_ui/lib/src/theme/up_theme.dart`
- Create: `packages/ultra_ui/lib/src/utils/up_utils.dart`
- Create: `packages/ultra_ui/fonts/upicon.ttf`
- Create: `packages/ultra_ui/lib/src/icons/icon_code_points.dart`

- [x] **Step 1: Create package and copy icon assets**
- [x] **Step 2: Implement config/theme/utils defaults from source**
- [x] **Step 3: Add unit tests for getPx/test/defaults**

### Task 2: UPIcon + UPLoadingIcon + UPButton

**Files:**
- Create: `packages/ultra_ui/lib/src/widgets/up_icon.dart`
- Create: `packages/ultra_ui/lib/src/widgets/up_loading_icon.dart`
- Create: `packages/ultra_ui/lib/src/widgets/up_button.dart`
- Create: `packages/ultra_ui/test/widgets_test.dart`

- [x] **Step 1: Port UPIcon with codepoint map**
- [x] **Step 2: Port button metrics/colors from source scss**
- [x] **Step 3: Widget tests for click/disabled/icon render**

### Task 3: Example app gallery

**Files:**
- Create: `example/pubspec.yaml`
- Create: `example/lib/main.dart`

- [x] **Step 1: Wire path dependency to ultra_ui**
- [x] **Step 2: Show Button/Icon state matrix**

### Task 4: P1 remaining MVP widgets

**Next widgets:**
- UPText, UPTag, UPBadge, UPCell/UPCellGroup, UPGap, UPLine, UPDivider, UPImage, UPAvatar

- [ ] Implement one component per source props+scss pair
- [ ] Add example states + tests each time
- [ ] Keep gap matrix updated

### Task 5: Continue to full parity

- [ ] P2 forms
- [ ] P3 feedback/navigation
- [ ] P4 complex data widgets
- [ ] P5 remaining set + docs
