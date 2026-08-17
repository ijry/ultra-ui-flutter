import 'package:flutter/widgets.dart';

import '../utils/up_utils.dart';
import 'up_image.dart';

/// 1:1 API shell of u-album / up-album.
class UPAlbum extends StatefulWidget {
  const UPAlbum({
    super.key,
    this.urls = const [],
    this.keyName = '',
    this.singleSize = 180,
    this.multipleSize = 70,
    this.space = 6,
    this.singleMode = 'scaleToFill',
    this.multipleMode = 'aspectFill',
    this.maxCount = 9,
    this.previewFullImage = true,
    this.rowCount = 3,
    this.showMore = true,
    this.shape = 'square',
    this.radius = 0,
    this.autoWrap = false,
    this.unit = 'px',
    this.stop = true,
    this.customStyle,
    this.onAlbumWidth,
    this.onPreview,
    this.previewHandler,
  });

  final List urls;
  final String keyName;
  final dynamic singleSize;
  final dynamic multipleSize;
  final dynamic space;
  final String singleMode;
  final String multipleMode;
  final dynamic maxCount;
  final bool previewFullImage;
  final dynamic rowCount;
  final bool showMore;
  final String shape;
  final dynamic radius;
  final bool autoWrap;
  final String unit;
  final bool stop;
  final BoxDecoration? customStyle;
  final ValueChanged<double>? onAlbumWidth;

  /// Source-compatible tap callback: (src, index).
  final void Function(String src, int index)? onPreview;

  /// Host inject for system preview (maps uni.previewImage).
  /// Payload: `{urls: List<String>, currentIndex: int, current: String}`.
  final ValueChanged<Map>? previewHandler;

  @override
  State<UPAlbum> createState() => UPAlbumState();
}

class UPAlbumState extends State<UPAlbum> {
  /// Source `getComponentWidth` — measured host width when laid out.
  Future<double> getComponentWidth() async {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return 0;
    return box.size.width;
  }

  /// Source data.
  double singleHeight = 0;
  double singlePercent = 1;
  double singleWidth = 0;

  /// Source `getSrc`.
  String getSrc(dynamic item) => _src(item);

  /// Source `onPreviewTap`.
  void onPreviewTap(int index) => previewAt(index);

  /// Source display helpers.
  List get showUrls {
    final max = int.tryParse('${widget.maxCount}') ?? 9;
    final list = widget.urls;
    if (list.length <= max) return List.from(list);
    return list.take(max).toList();
  }

  Map imageStyle([int index = 0]) {
    final multi = widget.urls.length > 1;
    final size = UPUtils.getPx(multi ? widget.multipleSize : widget.singleSize);
    return {
      'width': size,
      'height': size,
      'index': index,
    };
  }

  double imageWidth([int index = 0]) =>
      (imageStyle(index)['width'] as num).toDouble();
  double imageHeight([int index = 0]) =>
      (imageStyle(index)['height'] as num).toDouble();

  /// Source `getImageRect` — measure host and sync single size fields.
  Map getImageRect([dynamic _]) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return {
        'width': 0.0,
        'height': 0.0,
        'left': 0.0,
        'top': 0.0,
        'right': 0.0,
        'bottom': 0.0,
      };
    }
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;
    singleWidth = size.width;
    singleHeight = size.height;
    if (size.width > 0) {
      singlePercent = size.height / size.width;
    }
    return {
      'width': size.width,
      'height': size.height,
      'left': offset.dx,
      'top': offset.dy,
      'right': offset.dx + size.width,
      'bottom': offset.dy + size.height,
    };
  }

  String _src(dynamic item) {
    if (item is String) return item;
    if (item is Map) {
      if (widget.keyName.isNotEmpty && item[widget.keyName] != null) {
        return '${item[widget.keyName]}';
      }
      return '${item['url'] ?? item['src'] ?? item['thumb'] ?? ''}';
    }
    return '$item';
  }

  List<String> get previewUrls => widget.urls.map(_src).toList();

  List<List<dynamic>> _rows(List list, int rows) {
    if (widget.autoWrap) return [list];
    final out = <List<dynamic>>[];
    for (var i = 0; i < list.length; i++) {
      final row = i ~/ rows;
      if (out.length <= row) out.add(<dynamic>[]);
      out[row].add(list[i]);
    }
    return out;
  }

  void previewAt(int index) {
    final urls = previewUrls;
    if (urls.isEmpty) return;
    final safeIndex = index.clamp(0, urls.length - 1);
    final src = urls[safeIndex];
    if (!widget.previewFullImage) {
      widget.onPreview?.call(src, safeIndex);
      return;
    }
    widget.previewHandler?.call({
      'urls': urls,
      'currentIndex': safeIndex,
      'current': src,
    });
    widget.onPreview?.call(src, safeIndex);
  }

  void previewUrl(String url) {
    final urls = previewUrls;
    final index = urls.indexOf(url);
    previewAt(index < 0 ? 0 : index);
  }

  @override
  Widget build(BuildContext context) {
    final max = int.tryParse('${widget.maxCount}') ?? 9;
    final rows = (int.tryParse('${widget.rowCount}') ?? 3).clamp(1, 12);
    final gap = UPUtils.getPx(widget.space);
    final list = widget.urls.take(max).toList();
    final single = list.length == 1;
    final size =
        UPUtils.getPx(single ? widget.singleSize : widget.multipleSize);
    final mode = single ? widget.singleMode : widget.multipleMode;
    final r = widget.shape == 'circle' ? 1000.0 : UPUtils.getPx(widget.radius);

    if (list.isEmpty) return const SizedBox.shrink();

    final total = widget.urls.length;
    final matrix = _rows(list, rows);
    var globalIndex = 0;
    final rowWidgets = <Widget>[];
    for (var ri = 0; ri < matrix.length; ri++) {
      final row = matrix[ri];
      final cells = <Widget>[];
      for (var ci = 0; ci < row.length; ci++) {
        final index = globalIndex++;
        final src = _src(row[ci]);
        final isLast = index == list.length - 1;
        final showPlus = widget.showMore && total > max && isLast;
        cells.add(
          Padding(
            padding: EdgeInsets.only(
              right: (!widget.autoWrap && ci == row.length - 1) ? 0 : gap,
              bottom: (!widget.autoWrap && ri == matrix.length - 1) ? 0 : gap,
            ),
            child: GestureDetector(
              onTap: () => previewAt(index),
              child: Stack(
                children: [
                  UPImage(
                    src: src,
                    width: size,
                    height: size,
                    mode: mode,
                    shape: widget.shape,
                    radius: r,
                  ),
                  if (showPlus)
                    Positioned.fill(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0x66000000),
                          borderRadius: BorderRadius.circular(r),
                        ),
                        child: Text(
                          '+${total - max}',
                          style: TextStyle(
                            color: const Color(0xFFFFFFFF),
                            fontSize: size * 0.3,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }
      rowWidgets.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: cells,
        ),
      );
    }

    final albumWidth = single
        ? size
        : (widget.autoWrap ? null : size * rows + gap * (rows - 1));
    if (albumWidth != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onAlbumWidth?.call(albumWidth);
      });
    }

    Widget body = SizedBox(
      width: albumWidth,
      child: widget.autoWrap
          ? Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var i = 0; i < list.length; i++)
                  GestureDetector(
                    onTap: () => previewAt(i),
                    child: UPImage(
                      src: _src(list[i]),
                      width: size,
                      height: size,
                      mode: mode,
                      shape: widget.shape,
                      radius: r,
                    ),
                  ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: rowWidgets,
            ),
    );

    return body;
  }
}
