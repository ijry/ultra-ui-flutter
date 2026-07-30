import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_image.dart';

class UPCard extends StatelessWidget {
  const UPCard({
    super.key,
    this.full = false,
    this.title = '',
    this.titleColor = '#303133',
    this.titleSize = '15px',
    this.subTitle = '',
    this.subTitleColor = '#909399',
    this.subTitleSize = '13px',
    this.border = true,
    this.index = '',
    this.margin = '15px',
    this.borderRadius = '8px',
    this.headStyle = const {},
    this.bodyStyle = const {},
    this.footStyle = const {},
    this.headBorderBottom = true,
    this.footBorderTop = true,
    this.thumb = '',
    this.thumbWidth = '30px',
    this.thumbCircle = false,
    this.padding = '15px',
    this.paddingHead = '',
    this.paddingBody = '',
    this.paddingFoot = '',
    this.showHead = true,
    this.showFoot = true,
    this.boxShadow = 'none',
    this.customStyle,
    this.head,
    this.body,
    this.foot,
    this.onClick,
    this.onHeadClick,
    this.onBodyClick,
    this.onFootClick,
  });

  final bool full;
  final String title;
  final dynamic titleColor;
  final dynamic titleSize;
  final String subTitle;
  final dynamic subTitleColor;
  final dynamic subTitleSize;
  final bool border;
  final dynamic index;
  final dynamic margin;
  final dynamic borderRadius;
  final Map headStyle;
  final Map bodyStyle;
  final Map footStyle;
  final bool headBorderBottom;
  final bool footBorderTop;
  final String thumb;
  final dynamic thumbWidth;
  final bool thumbCircle;
  final dynamic padding;
  final dynamic paddingHead;
  final dynamic paddingBody;
  final dynamic paddingFoot;
  final bool showHead;
  final bool showFoot;
  final String boxShadow;
  final BoxDecoration? customStyle;
  final Widget? head;
  final Widget? body;
  final Widget? foot;
  final ValueChanged<dynamic>? onClick;
  final ValueChanged<dynamic>? onHeadClick;
  final ValueChanged<dynamic>? onBodyClick;
  final ValueChanged<dynamic>? onFootClick;

  /// Source `click` method.
  void click([dynamic idx]) => onClick?.call(idx ?? index);

  /// Source head/body/foot click helpers.
  void headClick([dynamic idx]) => onHeadClick?.call(idx ?? index);
  void bodyClick([dynamic idx]) => onBodyClick?.call(idx ?? index);
  void footClick([dynamic idx]) => onFootClick?.call(idx ?? index);

  EdgeInsets _pad(dynamic value) {
    final fallback = UPUtils.getPx(padding);
    if (value == null || '$value'.isEmpty) {
      return EdgeInsets.all(fallback);
    }
    final text = '$value'.trim();
    final parts = text.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return EdgeInsets.all(UPUtils.getPx(parts[0]));
    }
    if (parts.length == 2) {
      return EdgeInsets.symmetric(
        vertical: UPUtils.getPx(parts[0]),
        horizontal: UPUtils.getPx(parts[1]),
      );
    }
    if (parts.length == 3) {
      return EdgeInsets.only(
        top: UPUtils.getPx(parts[0]),
        right: UPUtils.getPx(parts[1]),
        bottom: UPUtils.getPx(parts[2]),
        left: UPUtils.getPx(parts[1]),
      );
    }
    return EdgeInsets.only(
      top: UPUtils.getPx(parts[0]),
      right: UPUtils.getPx(parts[1]),
      bottom: UPUtils.getPx(parts[2]),
      left: UPUtils.getPx(parts[3]),
    );
  }

  EdgeInsets _margin() {
    if (full) return EdgeInsets.zero;
    final text = '$margin'.trim();
    final parts = text.split(RegExp(r'\s+'));
    if (parts.length == 1) return EdgeInsets.all(UPUtils.getPx(parts[0]));
    if (parts.length == 2) {
      return EdgeInsets.symmetric(
        vertical: UPUtils.getPx(parts[0]),
        horizontal: UPUtils.getPx(parts[1]),
      );
    }
    if (parts.length >= 4) {
      return EdgeInsets.only(
        top: UPUtils.getPx(parts[0]),
        right: UPUtils.getPx(parts[1]),
        bottom: UPUtils.getPx(parts[2]),
        left: UPUtils.getPx(parts[3]),
      );
    }
    return EdgeInsets.all(UPUtils.getPx(margin));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final radius = UPUtils.getPx(borderRadius);
    final titleC = UPUtils.parseColor(titleColor) ?? tokens.mainColor;
    final subC = UPUtils.parseColor(subTitleColor) ?? tokens.tipsColor;
    final tw = UPUtils.getPx(thumbWidth);

    final headWidget = head ??
        (title.isNotEmpty
            ? Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (thumb.isNotEmpty) ...[
                          UPImage(
                            src: thumb,
                            width: tw,
                            height: tw,
                            radius: thumbCircle ? 1000 : 4,
                            shape: thumbCircle ? 'circle' : 'square',
                            showLoading: false,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: titleC,
                              fontSize: UPUtils.getPx(titleSize),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (subTitle.isNotEmpty)
                    Text(
                      subTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: subC,
                        fontSize: UPUtils.getPx(subTitleSize),
                      ),
                    ),
                ],
              )
            : const SizedBox.shrink());

    Widget root = GestureDetector(
      onTap: () => onClick?.call(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: full ? double.infinity : null,
        margin: _margin(),
        decoration: BoxDecoration(
          color: tokens.cardBgColor,
          borderRadius: BorderRadius.circular(radius),
          border:
              border ? Border.all(color: tokens.borderColor, width: 0.5) : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHead)
              GestureDetector(
                onTap: () {
                  headClick();
                  click();
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: _pad(paddingHead),
                  decoration: headBorderBottom
                      ? BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: tokens.borderColor,
                              width: 0.5,
                            ),
                          ),
                        )
                      : null,
                  child: headWidget,
                ),
              ),
            GestureDetector(
              onTap: () {
                bodyClick();
                click();
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: _pad(paddingBody),
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: tokens.contentColor, fontSize: 14),
                  child: body ?? const SizedBox.shrink(),
                ),
              ),
            ),
            if (showFoot)
              GestureDetector(
                onTap: () {
                  footClick();
                  click();
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: foot == null ? EdgeInsets.zero : _pad(paddingFoot),
                  decoration: footBorderTop
                      ? BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: tokens.borderColor,
                              width: 0.5,
                            ),
                          ),
                        )
                      : null,
                  child: foot == null
                      ? const SizedBox.shrink()
                      : DefaultTextStyle.merge(
                          style:
                              TextStyle(color: tokens.tipsColor, fontSize: 13),
                          child: foot!,
                        ),
                ),
              ),
          ],
        ),
      ),
    );

    return root;
  }
}
