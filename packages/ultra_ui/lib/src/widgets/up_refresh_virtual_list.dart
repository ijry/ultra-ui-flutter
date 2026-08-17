import 'package:flutter/widgets.dart';

import 'up_pull_refresh.dart';
import 'up_virtual_list.dart';

/// Port of u-refresh-virtual-list / up-refresh-virtual-list.
class UPRefreshVirtualList extends StatefulWidget {
  const UPRefreshVirtualList({
    super.key,
    this.listData = const [],
    this.itemHeight = 50,
    this.height = '100%',
    this.buffer = 4,
    this.keyField = 'id',
    this.onRefresh,
    this.onScroll,
    this.itemBuilder,
    this.customStyle,
  });

  final List listData;
  final double itemHeight;
  final dynamic height;
  final int buffer;
  final String keyField;
  final VoidCallback? onRefresh;
  final ValueChanged<double>? onScroll;
  final Widget Function(BuildContext context, dynamic item, int index)?
      itemBuilder;
  final BoxDecoration? customStyle;

  @override
  State<UPRefreshVirtualList> createState() => UPRefreshVirtualListState();
}

class UPRefreshVirtualListState extends State<UPRefreshVirtualList> {
  bool refreshing = false;
  double scrollTop = 0;

  /// Source `handleRefresh`.
  void handleRefresh() {
    if (mounted) {
      setState(() => refreshing = true);
    } else {
      refreshing = true;
    }
    widget.onRefresh?.call();
  }

  /// Source `handleScroll`.
  void handleScroll([double? offset]) {
    if (offset == null) return;
    scrollTop = offset;
    widget.onScroll?.call(offset);
    if (mounted) setState(() {});
  }

  void finishRefresh() {
    if (!mounted) return;
    setState(() => refreshing = false);
  }

  void scrollTo(double top) {
    if (!mounted) return;
    setState(() => scrollTop = top);
  }

  void scrollToTop() => scrollTo(0);

  @override
  Widget build(BuildContext context) {
    Widget root = UPPullRefresh(
      refreshing: refreshing,
      threshold: 50,
      onRefresh: handleRefresh,
      child: UPVirtualList(
        listData: widget.listData,
        itemHeight: widget.itemHeight,
        height: widget.height,
        buffer: widget.buffer,
        keyField: widget.keyField,
        scrollTop: scrollTop,
        itemBuilder: widget.itemBuilder,
        onScroll: handleScroll,
      ),
    );
    return root;
  }
}
