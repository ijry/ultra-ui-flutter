import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';

/// 1:1 API shell of u-select / up-select.
class UPSelect extends StatefulWidget {
  const UPSelect({
    super.key,
    this.maxHeight = '90vh',
    this.overlay = true,
    this.overlayOpacity = 0.01,
    this.overlayStyle = const {},
    this.duration = 300,
    this.label = '选项',
    this.options = const [],
    this.keyName = 'id',
    this.labelName = 'name',
    this.showOptionsLabel = false,
    this.current = '',
    this.modelValue,
    this.disabled = false,
    this.border = false,
    this.itemColor = '',
    this.iconColor = '',
    this.iconSize = '13px',
    this.optionsWidth = '',
    this.zIndex = 11000,
    this.onUpdateCurrent,
    this.onUpdateModelValue,
    this.onSelect,
    this.textBuilder,
    this.iconSlot,
    this.optionsBuilder,
    this.optionItemBuilder,
    this.onUpdateShow,
    this.customStyle,
  });

  final dynamic maxHeight;
  final bool overlay;
  final dynamic overlayOpacity;
  final Map overlayStyle;
  final dynamic duration;
  final String label;
  final List options;
  final String keyName;
  final String labelName;
  final bool showOptionsLabel;
  final dynamic current;

  /// Source v-model alias for current.
  final dynamic modelValue;
  final bool disabled;
  final bool border;
  final dynamic itemColor;
  final dynamic iconColor;
  final dynamic iconSize;
  final dynamic optionsWidth;
  final dynamic zIndex;
  final ValueChanged<dynamic>? onUpdateCurrent;

  /// Source update:modelValue alias for current.
  final ValueChanged<dynamic>? onUpdateModelValue;
  dynamic get effectiveCurrent => modelValue ?? current;
  final ValueChanged<Map>? onSelect;

  /// Slot: text. Receives the resolved current label.
  final Widget Function(String currentLabel)? textBuilder;

  /// Slot: icon.
  final Widget? iconSlot;

  /// Slot: options panel body.
  final Widget? optionsBuilder;

  /// Slot: optionItem.
  final Widget Function(Map item)? optionItemBuilder;

  final BoxDecoration? customStyle;

  final ValueChanged<bool>? onUpdateShow;

  @override
  State<UPSelect> createState() => UPSelectState();
}

class UPSelectState extends State<UPSelect> {
  bool _open = false;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  Size _triggerSize = Size.zero;
  bool _alignPanelRight = false;

  String get currentLabel {
    for (final item in widget.options) {
      if (item is Map &&
          '${item[widget.keyName]}' == '${widget.effectiveCurrent}') {
        return '${item[widget.labelName]}';
      }
    }
    return '';
  }

  void openSelect() {
    if (widget.disabled || _open) return;
    setState(() => _open = true);
    widget.onUpdateShow?.call(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_open) return;
      adjustOptionsWrapPosition();
      _showOverlay();
    });
  }

  void closeSelect() {
    if (!_open && _overlayEntry == null) return;
    final wasOpen = _open;
    _removeOverlay();
    setState(() => _open = false);
    if (wasOpen) widget.onUpdateShow?.call(false);
  }

  /// Source-compatible aliases.
  void open() => openSelect();
  void close() => closeSelect();
  void toggle() {
    if (_open) {
      closeSelect();
    } else {
      openSelect();
    }
  }

  bool get isOpen => _open;

  void setCurrent(dynamic value) {
    widget.onUpdateCurrent?.call(value);
    widget.onUpdateModelValue?.call(value);
  }

  /// Source style helpers.
  dynamic resolvedItemColor([dynamic _]) => widget.itemColor;
  dynamic resolvedTextColor([dynamic _]) => widget.itemColor;
  dynamic resolvedIconColor([dynamic _]) => widget.iconColor;
  dynamic normalizedOptionsWidth([dynamic _]) => widget.optionsWidth;
  Map selectLabelStyle([dynamic _]) => {
        'label': currentLabel,
        'disabled': widget.disabled,
      };

  /// Source retained wrap side fields.
  dynamic optionsWrapLeft;
  dynamic optionsWrapRight;

  Map optionsWrapStyle([dynamic _]) => {
        'width': widget.optionsWidth,
        'open': _open,
      };
  Map optionsStyle([dynamic _]) => optionsWrapStyle();

  /// Source `overlayClick`.
  /// Source `overlayClick`.
  void overlayClick() => closeSelect();

  /// Source `selectItem`.
  void selectItem(Map item) => _select(item);

  /// Source `adjustOptionsWrapPosition` — measure trigger and cache wrap sides.
  void adjustOptionsWrapPosition([dynamic _]) {
    if (!mounted) return;
    final box = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      optionsWrapLeft = 0;
      optionsWrapRight = 0;
      return;
    }
    final o = box.localToGlobal(Offset.zero);
    final size = MediaQuery.sizeOf(context);
    final optionWidth = _optionsWidthPx() ?? box.size.width;
    final alignRight = o.dx + optionWidth > size.width;
    final nextLeft = o.dx;
    final nextRight = size.width - (o.dx + box.size.width);
    final changed = _triggerSize != box.size ||
        _alignPanelRight != alignRight ||
        optionsWrapLeft != nextLeft ||
        optionsWrapRight != nextRight;
    void update() {
      _triggerSize = box.size;
      _alignPanelRight = alignRight;
      optionsWrapLeft = nextLeft;
      optionsWrapRight = nextRight;
    }

    if (changed && mounted) {
      setState(update);
      _overlayEntry?.markNeedsBuild();
    } else {
      update();
    }
  }

  void _toggle() {
    toggle();
  }

  void _select(Map item) {
    widget.onUpdateCurrent?.call(item[widget.keyName]);
    widget.onUpdateModelValue?.call(item[widget.keyName]);
    widget.onSelect?.call(item);
    closeSelect();
  }

  @override
  void didUpdateWidget(covariant UPSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_open) _overlayEntry?.markNeedsBuild();
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _showOverlay() {
    if (_overlayEntry != null || !mounted) return;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    _overlayEntry = OverlayEntry(builder: _buildOverlay);
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  double _maxHeightPx(BuildContext context) {
    final raw = '${widget.maxHeight}';
    if (raw.endsWith('vh')) {
      final n = double.tryParse(raw.replaceAll('vh', '')) ?? 90;
      final h = MediaQuery.sizeOf(context).height;
      return h * n / 100;
    }
    return UPUtils.getPx(widget.maxHeight);
  }

  double? _optionsWidthPx() {
    if (widget.optionsWidth == null || '${widget.optionsWidth}'.isEmpty) {
      return null;
    }
    return UPUtils.getPx(widget.optionsWidth);
  }

  Widget _buildOptionsPanel(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final itemColor = UPUtils.parseColor(widget.itemColor) ?? tokens.mainColor;
    final maxH = _maxHeightPx(context);
    final optW = _optionsWidthPx() ??
        (_triggerSize.width > 0 ? _triggerSize.width : null);
    return Container(
      key: const ValueKey('up-select-options-panel'),
      width: optW,
      constraints: BoxConstraints(
        maxHeight: maxH > 0 ? maxH : 280,
        minWidth: optW ?? 100,
      ),
      decoration: BoxDecoration(
        color: tokens.cardBgColor,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: widget.optionsBuilder ??
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final raw in widget.options)
                  if (raw is Map)
                    GestureDetector(
                      onTap: () => _select(Map<dynamic, dynamic>.from(raw)),
                      child: widget.optionItemBuilder
                              ?.call(Map<dynamic, dynamic>.from(raw)) ??
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            color: '${raw[widget.keyName]}' ==
                                    '${widget.effectiveCurrent}'
                                ? tokens.primary.withValues(alpha: 0.08)
                                : null,
                            child: Text(
                              '${raw[widget.labelName]}',
                              style: TextStyle(
                                color: '${raw[widget.keyName]}' ==
                                        '${widget.effectiveCurrent}'
                                    ? tokens.primary
                                    : itemColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                    ),
              ],
            ),
          ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final opacity =
        (double.tryParse('${widget.overlayOpacity}') ?? 0.01).clamp(0.0, 1.0);
    return Stack(
      children: [
        if (widget.overlay)
          Positioned.fill(
            child: GestureDetector(
              key: const ValueKey('up-select-overlay-barrier'),
              behavior: HitTestBehavior.opaque,
              onTap: closeSelect,
              child: ColoredBox(
                color: Color.fromRGBO(0, 0, 0, opacity),
              ),
            ),
          ),
        CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor:
              _alignPanelRight ? Alignment.bottomRight : Alignment.bottomLeft,
          followerAnchor:
              _alignPanelRight ? Alignment.topRight : Alignment.topLeft,
          offset: const Offset(0, 4),
          child: Material(
            color: Colors.transparent,
            child: _buildOptionsPanel(context),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final labelText = widget.showOptionsLabel && currentLabel.isNotEmpty
        ? currentLabel
        : widget.label;
    final textColor = tokens.mainColor;
    final iconColor =
        UPUtils.parseColor(widget.iconColor) ?? tokens.contentColor;
    Widget body = CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        key: _triggerKey,
        onTap: _toggle,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: widget.disabled ? 0.5 : 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: widget.border ? tokens.cardBgColor : null,
              border:
                  widget.border ? Border.all(color: tokens.borderColor) : null,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.textBuilder?.call(currentLabel) ??
                    Text(
                      labelText,
                      style: TextStyle(color: textColor, fontSize: 14),
                    ),
                const SizedBox(width: 4),
                widget.iconSlot ??
                    UPIcon(
                      name: 'arrow-down',
                      size: widget.iconSize,
                      color: iconColor,
                    ),
              ],
            ),
          ),
        ),
      ),
    );

    return body;
  }
}
