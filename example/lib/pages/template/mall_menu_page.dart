import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';
import 'classify_data.dart';

/// Port of pages/template/mallMenu/index1 and index2 — a mall category menu.
///
/// The two source pages differ only in how the right pane tracks the left menu:
/// index1 shows just the active category, index2 shows every section and syncs
/// the menu as you scroll. Those are exactly UPCateTab's `tab` and `follow`
/// modes, so this uses the component rather than re-deriving the scroll maths
/// the source pages hand-roll with `createSelectorQuery`.
class MallMenuPage extends StatefulWidget {
  const MallMenuPage({super.key, required this.mode, required this.routeId});

  /// `tab` for index1, `follow` for index2.
  final String mode;

  /// Route id, used for this page's layout-test key.
  final String routeId;

  @override
  State<MallMenuPage> createState() => _MallMenuPageState();
}

class _MallMenuPageState extends State<MallMenuPage> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: widget.mode == 'tab' ? '垂直分类(左右独立)' : '垂直分类(左右联动)',
      // The menu scrolls internally, so the page must not also scroll.
      scrollable: false,
      child: Container(
        key: ValueKey('example-page-${widget.routeId}'),
        color: tokens.bgColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Source search bar: a non-functional affordance above the menu.
            Container(
              color: tokens.cardBgColor,
              padding: const EdgeInsets.all(10),
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: tokens.bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: <Widget>[
                    const UPIcon(
                      name: 'search',
                      color: Color(0xFF909399),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      // index1 searches "uview-plus", index2 just "搜索".
                      widget.mode == 'tab' ? '搜索uview-plus' : '搜索',
                      style: TextStyle(
                        fontSize: 13,
                        color: tokens.tipsColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: UPCateTab(
                key: ValueKey('mall-menu-page-${widget.mode}'),
                mode: widget.mode,
                tabList: classifyData,
                current: _current,
                onUpdateCurrent: (value) => setState(() => _current = value),
                // Source renders one section per category: a heading, then a
                // 3-across grid of thumbnails.
                itemListBuilder: (context, tab, index) {
                  final map = tab is Map ? tab : const <String, Object>{};
                  final foods = map['foods'];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: tokens.cardBgColor,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            '${map['name'] ?? ''}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: tokens.mainColor,
                            ),
                          ),
                        ),
                        // Source lays the thumbnails out 3-across. A Wrap child
                        // gets unbounded width, so the cell size is computed
                        // from the pane here rather than inside each thumb.
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final cell = constraints.maxWidth.isFinite
                                ? constraints.maxWidth / 3
                                : 70.0;
                            return Wrap(
                              children: <Widget>[
                                if (foods is List)
                                  for (final food in foods)
                                    _thumb(tokens, food, cell),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Source `.thumb-box`: a third of the pane wide, image above a caption.
  Widget _thumb(UPThemeTokens tokens, dynamic food, double width) {
    final map = food is Map ? food : const <String, Object>{};
    return SizedBox(
      width: width,
      child: Column(
        children: <Widget>[
          UPImage(
            src: '${map['icon'] ?? ''}',
            width: 50,
            height: 50,
            mode: 'aspectFill',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              '${map['name'] ?? ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: tokens.contentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
