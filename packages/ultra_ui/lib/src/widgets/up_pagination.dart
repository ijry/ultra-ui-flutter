import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';

/// 1:1-ish port of u-pagination layout pieces.
class UPPagination extends StatefulWidget {
  const UPPagination({
    super.key,
    this.currentPage = 1,
    this.modelValue,
    this.pageSize = 10,
    this.total = 0,
    this.prevText = '',
    this.nextText = '',
    this.buttonBgColor = '#f5f7fa',
    this.buttonBorderColor = '#dcdfe6',
    this.pageSizes = const [10, 20, 30, 40, 50],
    this.layout = 'prev, pager, next',
    this.hideOnSinglePage = false,
    this.forceEllipses = true,
    this.customStyle,
    this.onCurrentChange,
    this.onSizeChange,
    this.onUpdateCurrentPage,
    this.onUpdateModelValue,
    this.onUpdatePageSize,
  });

  final int currentPage;

  /// Source v-model / modelValue alias for currentPage.
  final dynamic modelValue;
  final int pageSize;
  final int total;
  final String prevText;
  final String nextText;
  final dynamic buttonBgColor;
  final dynamic buttonBorderColor;
  final List pageSizes;
  final String layout;
  final bool hideOnSinglePage;
  final bool forceEllipses;
  final BoxDecoration? customStyle;
  final ValueChanged<int>? onCurrentChange;
  final ValueChanged<int>? onSizeChange;
  final ValueChanged<int>? onUpdateCurrentPage;

  /// Source update:modelValue alias for current page.
  final ValueChanged<dynamic>? onUpdateModelValue;
  final ValueChanged<int>? onUpdatePageSize;

  @override
  State<UPPagination> createState() => UPPaginationState();
}

class UPPaginationState extends State<UPPagination> {
  /// Source data.
  dynamic currentPageInput;

  int get currentPage {
    if (widget.modelValue != null) {
      return int.tryParse('${widget.modelValue}') ?? widget.currentPage;
    }
    return widget.currentPage;
  }

  int get pageSize => widget.pageSize;
  int get total => widget.total;

  int get _safePageSize => pageSize <= 0 ? 1 : pageSize;

  int get totalPages =>
      total <= 0 ? 1 : ((total + _safePageSize - 1) ~/ _safePageSize);

  List<dynamic> get displayedPages {
    final totalP = totalPages;
    final current = currentPage;
    if (!widget.forceEllipses || totalP <= 4) {
      return [for (var i = 1; i <= totalP; i++) i];
    }
    if (current <= 2) return [1, 2, 3, 4, '...', totalP];
    if (current >= totalP - 1) {
      return [1, '...', totalP - 3, totalP - 2, totalP - 1, totalP];
    }
    return [1, '...', current - 1, current, current + 1, '...', totalP];
  }

  /// Source page-size helpers (Batch K).
  int get pageSizeIndex {
    final sizes = normalizedPageSizes;
    final idx = sizes.indexWhere((e) => e.value == pageSize);
    return idx < 0 ? 0 : idx;
  }

  String get pageSizeLabel {
    for (final size in normalizedPageSizes) {
      if (size.value == pageSize) return size.label;
    }
    return '$pageSize';
  }

  List<_UPPageSizeOption> get normalizedPageSizes {
    return widget.pageSizes
        .map((raw) {
          if (raw is Map) {
            final value = int.tryParse('${raw['value'] ?? ''}');
            if (value == null) return null;
            final label = '${raw['label'] ?? '$value条/页'}';
            return _UPPageSizeOption(label: label, value: value);
          }
          final value = int.tryParse('$raw');
          if (value == null) return null;
          return _UPPageSizeOption(label: '${value}条/页', value: value);
        })
        .whereType<_UPPageSizeOption>()
        .toList();
  }

  void goTo(int page) {
    if (page == '...') return;
    if (page == currentPage) return;
    widget.onUpdateCurrentPage?.call(page);
    widget.onUpdateModelValue?.call(page);
    widget.onCurrentChange?.call(page);
  }

  void prev() {
    if (currentPage > 1) goTo(currentPage - 1);
  }

  void next() {
    if (currentPage < totalPages) goTo(currentPage + 1);
  }

  void changeSize(int size) {
    if (size <= 0 || size == pageSize) return;
    widget.onUpdatePageSize?.call(size);
    widget.onSizeChange?.call(size);
  }

  void setCurrentPage(int page) => goTo(page);

  void setPageSize(int size) => changeSize(size);

  dynamic _eventValue(dynamic event) {
    if (event is Map) {
      final detail = event['detail'];
      if (detail is Map && detail.containsKey('value')) return detail['value'];
      if (event.containsKey('value')) return event['value'];
    }
    return event;
  }

  /// Source `handleSizeChange` receives the picker option index.
  void handleSizeChange(dynamic event) {
    final index = int.tryParse('${_eventValue(event)}');
    final options = normalizedPageSizes;
    if (options.isEmpty) return;
    final size = index != null && index >= 0 && index < options.length
        ? options[index].value
        : options.first.value;
    widget.onUpdatePageSize?.call(size);
    widget.onSizeChange?.call(size);
  }

  /// Source `onInputPage` / `onConfirmPage` helpers.
  void onInputPage(dynamic page) {
    currentPageInput = '${_eventValue(page)}';
  }

  void onConfirmPage([dynamic page]) {
    final input = page == null ? currentPageInput : _eventValue(page);
    final number = int.tryParse('$input');
    if (number != null && number >= 1 && number <= totalPages) goTo(number);
  }

  @override
  void initState() {
    super.initState();
    currentPageInput = '$currentPage';
  }

  @override
  void didUpdateWidget(covariant UPPagination oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage ||
        oldWidget.modelValue != widget.modelValue) {
      currentPageInput = '$currentPage';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final parts = widget.layout
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final btnBg =
        UPUtils.parseColor(widget.buttonBgColor) ?? const Color(0xFFF5F7FA);
    final btnBorder =
        UPUtils.parseColor(widget.buttonBorderColor) ?? const Color(0xFFDCDFE6);

    Widget btn({
      required Widget child,
      required VoidCallback? onTap,
      bool disabled = false,
    }) {
      return GestureDetector(
        onTap: disabled ? null : onTap,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: disabled ? 0.5 : 1,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: btnBg,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: btnBorder, width: 0.5),
            ),
            child: child,
          ),
        ),
      );
    }

    final children = <Widget>[
      btn(
        disabled: currentPage <= 1,
        onTap: prev,
        child: widget.prevText.isNotEmpty
            ? Text(widget.prevText,
                style: TextStyle(color: tokens.contentColor, fontSize: 14))
            : UPIcon(name: 'arrow-left', size: 14, color: tokens.contentColor),
      ),
    ];
    for (final part in parts) {
      switch (part) {
        case 'prev':
        case 'next':
          break;
        case 'pager':
          for (final page in displayedPages) {
            final active = page == currentPage;
            children.add(GestureDetector(
              onTap: page == '...' ? null : () => goTo(page as int),
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: active ? tokens.primary : null,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$page',
                  style: TextStyle(
                    color:
                        active ? const Color(0xFFFFFFFF) : tokens.contentColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ));
          }
          break;
        case 'total':
          if (total <= 0) break;
          children.add(Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '共 $total 条',
              style: TextStyle(color: tokens.contentColor, fontSize: 14),
            ),
          ));
          break;
        case 'sizes':
          final options = normalizedPageSizes;
          if (options.isEmpty) break;
          children.add(Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in options)
                  GestureDetector(
                    onTap: () => changeSize(option.value),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            option.value == pageSize ? tokens.primary : btnBg,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: btnBorder, width: 0.5),
                      ),
                      child: Text(
                        option.label,
                        style: TextStyle(
                          color: option.value == pageSize
                              ? const Color(0xFFFFFFFF)
                              : tokens.contentColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ));
          break;
        case 'jumper':
          break;
      }
    }

    children.add(btn(
      disabled: currentPage >= totalPages,
      onTap: next,
      child: widget.nextText.isNotEmpty
          ? Text(widget.nextText,
              style: TextStyle(color: tokens.contentColor, fontSize: 14))
          : UPIcon(name: 'arrow-right', size: 14, color: tokens.contentColor),
    ));

    Widget body = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
    return body;
  }
}

class _UPPageSizeOption {
  const _UPPageSizeOption({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;
}
