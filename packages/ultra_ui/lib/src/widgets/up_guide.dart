import 'package:flutter/material.dart';

import '../utils/up_utils.dart';
import 'up_image.dart';

/// Port of u-guide (fullscreen onboarding pages).
class UPGuide extends StatefulWidget {
  const UPGuide({
    super.key,
    this.show = false,
    this.list = const [],
    this.storageKey = 'up-guide-default',
    this.once = true,
    this.showSkip = true,
    this.skipText = '跳过',
    this.nextText = '下一步',
    this.finishText = '立即体验',
    this.indicator = true,
    this.bgColor = '#111111',
    this.zIndex = 10075,
    this.onUpdateShow,
    this.onChange,
    this.onSkip,
    this.onFinish,
    this.onClose,
    this.customStyle,
  });

  final bool show;
  final List list;
  final String storageKey;
  final bool once;
  final bool showSkip;
  final String skipText;
  final String nextText;
  final String finishText;
  final bool indicator;
  final dynamic bgColor;
  final dynamic zIndex;
  final ValueChanged<bool>? onUpdateShow;
  final ValueChanged<int>? onChange;
  final VoidCallback? onSkip;
  final VoidCallback? onFinish;
  final VoidCallback? onClose;
  final BoxDecoration? customStyle;

  // once memory: in-memory + optional host persistence hooks.
  static final Set<String> _remembered = {};
  static Future<bool> Function(String key)? readPersisted;
  static Future<void> Function(String key)? writePersisted;
  static Future<void> Function(String key)? removePersisted;

  /// Test/helper: clear remembered keys.
  static void clearRemembered([String? key]) {
    if (key == null) {
      _remembered.clear();
    } else {
      _remembered.remove(key);
    }
  }

  /// Whether a storage key is currently remembered (session cache).
  static bool isRemembered(String key) => _remembered.contains(key);

  /// Source computed: pageList.
  List get pageList => list;

  /// Source computed: resolvedStorageKey.
  dynamic get resolvedStorageKey =>
      storageKey.isEmpty ? 'up-guide-default' : storageKey;

  @override
  State<UPGuide> createState() => UPGuideState();
}

class UPGuideState extends State<UPGuide> {
  int _current = 0;
  bool _innerShow = false;
  bool _closing = false;
  late final PageController _pageController;

  int get current => _current;
  bool get isOpen => _innerShow && !_hiddenByOnce && widget.list.isNotEmpty;

  /// Source data.
  bool get closing => _closing;
  bool get innerShow => _innerShow;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _innerShow = widget.show;
    _bootstrap();
  }

  @override
  void didUpdateWidget(covariant UPGuide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.show != widget.show) {
      _innerShow = widget.show;
    }
  }

  Future<void> _bootstrap() async {
    if (widget.list.isEmpty) return;
    if (widget.once) {
      if (UPGuide._remembered.contains(widget.resolvedStorageKey)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() => _innerShow = false);
          widget.onUpdateShow?.call(false);
        });
        return;
      }
      final reader = UPGuide.readPersisted;
      if (reader != null) {
        final remembered = await reader(widget.resolvedStorageKey);
        if (remembered) {
          UPGuide._remembered.add(widget.resolvedStorageKey);
          if (mounted) {
            setState(() => _innerShow = false);
            widget.onUpdateShow?.call(false);
          }
          return;
        }
      }
    }
    if (mounted) setState(() => _innerShow = widget.show);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _hiddenByOnce =>
      widget.once && UPGuide._remembered.contains(widget.resolvedStorageKey);

  void open() {
    setState(() {
      _current = 0;
      _innerShow = true;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    widget.onUpdateShow?.call(true);
  }

  void close({bool remember = true}) {
    if (_closing) return;
    _closing = true;
    if (remember && widget.once) {
      UPGuide._remembered.add(widget.resolvedStorageKey);
      final writer = UPGuide.writePersisted;
      if (writer != null) {
        writer(widget.resolvedStorageKey);
      }
    }
    if (mounted) {
      setState(() => _innerShow = false);
    } else {
      _innerShow = false;
    }
    widget.onUpdateShow?.call(false);
    widget.onClose?.call();
    // Reset re-entry guard synchronously to avoid pending timers in tests.
    _closing = false;
  }

  /// Source method: clear remembered storage for this key.
  Future<void> reset() async {
    UPGuide.clearRemembered(widget.resolvedStorageKey);
    final remover = UPGuide.removePersisted;
    if (remover != null) await remover(widget.resolvedStorageKey);
  }

  /// Source `bootstrap`.
  Future<void> bootstrap() => _bootstrap();

  bool get isLastPage =>
      widget.list.isNotEmpty && _current >= widget.list.length - 1;

  /// Source `onSwiperChange`.
  void onSwiperChange(int index) {
    if (index < 0 || index >= widget.list.length) return;
    setState(() => _current = index);
    widget.onChange?.call(index);
    if (_pageController.hasClients) {
      _pageController.jumpToPage(index);
    }
  }

  /// Source `onPrimaryAction`.
  void onPrimaryAction() => _next();

  /// Source `onSkip`.
  void onSkip() => _close(skip: true);

  /// Source `readRemembered` / `writeRemembered`.
  Future<bool> readRemembered() async {
    if (UPGuide._remembered.contains(widget.resolvedStorageKey)) return true;
    final reader = UPGuide.readPersisted;
    if (reader != null) return reader(widget.resolvedStorageKey);
    return false;
  }

  Future<void> writeRemembered() async {
    UPGuide._remembered.add(widget.resolvedStorageKey);
    final writer = UPGuide.writePersisted;
    if (writer != null) await writer(widget.resolvedStorageKey);
  }

  void _close({bool finish = false, bool skip = false}) {
    if (finish) widget.onFinish?.call();
    if (skip) widget.onSkip?.call();
    close(remember: true);
  }

  void _next() {
    final last = widget.list.length - 1;
    if (_current >= last) {
      _close(finish: true);
      return;
    }
    final next = _current + 1;
    setState(() => _current = next);
    widget.onChange?.call(next);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final show = _innerShow && !_hiddenByOnce && widget.list.isNotEmpty;
    if (!show) return const SizedBox.shrink();

    final bg = UPUtils.parseColor(widget.bgColor) ?? const Color(0xFF111111);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final pageHorizontalPadding = UPUtils.rpx2px(40, screenWidth: screenWidth);
    final pageTopPadding = UPUtils.rpx2px(120, screenWidth: screenWidth);
    final pageBottomPadding = UPUtils.rpx2px(40, screenWidth: screenWidth);
    final imageSize = UPUtils.rpx2px(560, screenWidth: screenWidth);
    final footerTopPadding = UPUtils.rpx2px(24, screenWidth: screenWidth);
    final footerHorizontalPadding =
        UPUtils.rpx2px(32, screenWidth: screenWidth);
    final footerBottomPadding = UPUtils.rpx2px(24, screenWidth: screenWidth) +
        MediaQuery.paddingOf(context).bottom;
    final dotSize = UPUtils.rpx2px(14, screenWidth: screenWidth);
    final activeDotWidth = UPUtils.rpx2px(34, screenWidth: screenWidth);
    final dotGap = UPUtils.rpx2px(12, screenWidth: screenWidth);
    final buttonGap = UPUtils.rpx2px(16, screenWidth: screenWidth);
    final buttonHeight = UPUtils.rpx2px(84, screenWidth: screenWidth);
    final buttonRadius = UPUtils.rpx2px(42, screenWidth: screenWidth);

    Widget page = Material(
      color: bg,
      child: SizedBox.expand(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.list.length,
                onPageChanged: (index) {
                  setState(() => _current = index);
                  widget.onChange?.call(index);
                },
                itemBuilder: (context, index) {
                  final item = widget.list[index];
                  final map = item is Map ? item : <String, dynamic>{};
                  final image = '${map['image'] ?? ''}';
                  final title = '${map['title'] ?? ''}';
                  final desc = '${map['desc'] ?? ''}';
                  final pageBg =
                      UPUtils.parseColor(map['backgroundColor']) ?? bg;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxHeight <
                          imageSize + pageTopPadding + pageBottomPadding;
                      final content = Container(
                        color: pageBg,
                        padding: EdgeInsets.fromLTRB(
                          pageHorizontalPadding,
                          pageTopPadding,
                          pageHorizontalPadding,
                          pageBottomPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (image.isNotEmpty)
                              SizedBox(
                                width: imageSize,
                                height: imageSize,
                                child: UPImage(
                                  src: image,
                                  width: imageSize,
                                  height: imageSize,
                                  mode: 'aspectFit',
                                  showLoading: false,
                                ),
                              )
                            else
                              Container(
                                width: imageSize,
                                height: imageSize,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0x1FFFFFFF),
                                  borderRadius: BorderRadius.circular(
                                    UPUtils.rpx2px(
                                      24,
                                      screenWidth: screenWidth,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  '暂无引导图',
                                  style: TextStyle(color: Color(0xFFFFFFFF)),
                                ),
                              ),
                            if (title.isNotEmpty) ...[
                              SizedBox(
                                height: UPUtils.rpx2px(
                                  48,
                                  screenWidth: screenWidth,
                                ),
                              ),
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: UPUtils.rpx2px(
                                    40,
                                    screenWidth: screenWidth,
                                  ),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFFFFFFF),
                                ),
                              ),
                            ],
                            if (desc.isNotEmpty) ...[
                              SizedBox(
                                height: UPUtils.rpx2px(
                                  18,
                                  screenWidth: screenWidth,
                                ),
                              ),
                              Text(
                                desc,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: UPUtils.rpx2px(
                                    28,
                                    screenWidth: screenWidth,
                                  ),
                                  color: const Color(0xD9FFFFFF),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                      if (!compact) return content;
                      return SingleChildScrollView(child: content);
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                footerHorizontalPadding,
                footerTopPadding,
                footerHorizontalPadding,
                footerBottomPadding,
              ),
              child: Column(
                children: [
                  if (widget.indicator)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: UPUtils.rpx2px(26, screenWidth: screenWidth),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(widget.list.length, (index) {
                          final active = index == _current;
                          return Container(
                            width: active ? activeDotWidth : dotSize,
                            height: dotSize,
                            margin:
                                EdgeInsets.symmetric(horizontal: dotGap / 2),
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xFFFFFFFF)
                                  : const Color(0x59FFFFFF),
                              borderRadius: BorderRadius.circular(dotSize),
                            ),
                          );
                        }),
                      ),
                    ),
                  Row(
                    children: [
                      if (widget.showSkip)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _close(skip: true),
                            child: Container(
                              height: buttonHeight,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(buttonRadius),
                                border: Border.all(
                                  color: const Color(0x6BFFFFFF),
                                  width: UPUtils.rpx2px(
                                    2,
                                    screenWidth: screenWidth,
                                  ),
                                ),
                              ),
                              child: Text(
                                widget.skipText,
                                style: TextStyle(
                                  color: const Color(0xFFFFFFFF),
                                  fontSize: UPUtils.rpx2px(
                                    28,
                                    screenWidth: screenWidth,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (widget.showSkip) SizedBox(width: buttonGap),
                      Expanded(
                        child: GestureDetector(
                          onTap: _next,
                          child: Container(
                            height: buttonHeight,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(buttonRadius),
                            ),
                            child: Text(
                              _current >= widget.list.length - 1
                                  ? widget.finishText
                                  : widget.nextText,
                              style: TextStyle(
                                color: const Color(0xFF111111),
                                fontSize: UPUtils.rpx2px(
                                  28,
                                  screenWidth: screenWidth,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return page;
  }
}
