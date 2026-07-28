import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';
import 'up_image.dart';
import 'up_loading_icon.dart';

/// Progress/result callback for host-injected auto upload.
typedef UPUploadProgress = void Function(num progress);
typedef UPUploadAutoUploader = Future<Map> Function(
  Map file,
  UPUploadAutoUploadContext context,
  UPUploadProgress onProgress,
);

/// Context passed to [UPUpload.autoUploader].
class UPUploadAutoUploadContext {
  const UPUploadAutoUploadContext({
    required this.index,
    required this.driver,
    required this.api,
    required this.authUrl,
    required this.header,
    required this.accept,
    required this.name,
    required this.customAfterAutoUpload,
  });

  final int index;
  final String driver;
  final String api;
  final String authUrl;
  final Map header;
  final String accept;
  final String name;
  final bool customAfterAutoUpload;
}

/// Visual/API port of u-upload with list mutation helpers.
class UPUpload extends StatefulWidget {
  const UPUpload({
    super.key,
    this.accept = 'image',
    this.extension = const [],
    this.capture = const ['album', 'camera'],
    this.compressed = true,
    this.camera = 'back',
    this.maxDuration = 60,
    this.uploadIcon = 'camera-fill',
    this.uploadIconColor = '#D3D4D6',
    this.useBeforeRead = false,
    this.previewFullImage = true,
    this.maxCount = 52,
    this.disabled = false,
    this.imageMode = 'aspectFill',
    this.name = '',
    this.sizeType = const ['original', 'compressed'],
    this.multiple = false,
    this.deletable = true,
    this.maxSize,
    this.fileList = const [],
    this.uploadText = '',
    this.width = 80,
    this.height = 80,
    this.previewImage = true,
    this.autoDelete = false,
    this.autoUpload = false,
    this.autoUploadApi = '',
    this.autoUploadAuthUrl = '',
    this.autoUploadDriver = '',
    this.autoUploadHeader = const {},
    this.getVideoThumb = false,
    this.customAfterAutoUpload = false,
    this.videoPreviewObjectFit = 'cover',
    this.onAfterRead,
    this.onBeforeRead,
    this.onDelete,
    this.onOversize,
    this.onClickPreview,
    this.onChoose,
    this.onUpdateFileList,
    this.onError,
    this.onAfterAutoUpload,
    this.autoUploader,
    this.picker,
    this.trigger,
    this.customStyle,
  });

  final String accept;
  final List extension;
  final dynamic capture;
  final bool compressed;
  final String camera;
  final int maxDuration;
  final String uploadIcon;
  final dynamic uploadIconColor;
  final bool useBeforeRead;
  final bool previewFullImage;
  final dynamic maxCount;
  final bool disabled;
  final String imageMode;
  final String name;
  final List sizeType;
  final bool multiple;
  final bool deletable;
  final dynamic maxSize;
  final List fileList;
  final String uploadText;
  final dynamic width;
  final dynamic height;
  final bool previewImage;
  final bool autoDelete;
  final bool autoUpload;
  final String autoUploadApi;
  final String autoUploadAuthUrl;
  final String autoUploadDriver;
  final Map autoUploadHeader;
  final bool getVideoThumb;
  final bool customAfterAutoUpload;
  final String videoPreviewObjectFit;
  final void Function(dynamic file, Map detail)? onAfterRead;
  final Future<dynamic> Function(dynamic file, Map detail)? onBeforeRead;

  /// Source prop alias: beforeRead.
  Future<dynamic> Function(dynamic file, Map detail)? get beforeRead =>
      onBeforeRead;
  final void Function(int index, Map item)? onDelete;
  final void Function(dynamic file)? onOversize;
  final void Function(Map item, int index)? onClickPreview;
  final VoidCallback? onChoose;
  final ValueChanged<List>? onUpdateFileList;
  final ValueChanged<dynamic>? onError;

  /// Source `afterAutoUpload` hook. Return `{url, thumb?}` or call via Future.
  final Future<Map?> Function(dynamic payload)? onAfterAutoUpload;

  /// Host-provided uploader. Keeps package free of network deps.
  /// Return `{url, thumb?}` on success; throw / return empty url for failure.
  final UPUploadAutoUploader? autoUploader;

  /// Host-provided picker. Return one map / string or a list.
  final Future<dynamic> Function()? picker;
  final Widget? trigger;

  final BoxDecoration? customStyle;

  /// Source computed: resolvedUploadIconColor.
  dynamic get resolvedUploadIconColor {
    final c = '$uploadIconColor';
    if (c != '#D3D4D6') return uploadIconColor;
    return '#909399';
  }

  /// Source computed: resolvedUploadTextColor.
  dynamic get resolvedUploadTextColor => '#909399';

  @override
  State<UPUpload> createState() => UPUploadState();
}

class UPUploadState extends State<UPUpload> {
  bool _popupShow = false;

  /// Source host helper.
  Future<void> setTimeout([dynamic cb, int ms = 0]) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
    if (cb is Function) cb();
  }

  /// Source data.
  int currentItemIndex = -1;
  bool isInCount = false;
  dynamic successIcon;
  double videoThumbCanvasHeight = 0;
  String videoThumbCanvasId = 'up-upload-video-thumb';
  double videoThumbCanvasWidth = 0;
  dynamic lastToast;

  late List _lists;

  /// Source-compatible list snapshot.
  List get lists => _cloneList(_lists);
  List get fileList => lists;

  /// Source `formatFileList`.
  List formatFileList([List? source]) => _cloneList(source ?? _lists);

  /// Source file format helpers (Batch L).
  Map formatFile([dynamic file]) {
    if (file is Map) return Map<String, dynamic>.from(file);
    return {
      'url': '$file',
      'name': '$file',
      'type': 'file',
      'status': 'success',
      'message': '',
    };
  }

  Map formatImage([dynamic file]) {
    final m = formatFile(file);
    m['type'] = 'image';
    m['isImage'] = true;
    return m;
  }

  Map formatVideo([dynamic file]) {
    final m = formatFile(file);
    m['type'] = 'video';
    m['isVideo'] = true;
    return m;
  }

  Map formatMedia([dynamic file]) {
    final m = formatFile(file);
    final name = '${m['name'] ?? m['url'] ?? ''}'.toLowerCase();
    if (name.endsWith('.mp4') ||
        name.endsWith('.mov') ||
        name.endsWith('.avi')) {
      return formatVideo(m);
    }
    return formatImage(m);
  }

  List pickExclude([List? source, List? exclude]) {
    final list = source ?? _lists;
    final ex = {
      for (final e in (exclude ?? const []))
        if (e is Map) '${e['url'] ?? e['name'] ?? e}' else '$e'
    };
    return [
      for (final item in list)
        if (!ex.contains(
            item is Map ? '${item['url'] ?? item['name'] ?? item}' : '$item'))
          item
    ];
  }

  /// Source `getDetail`.
  Map getDetail({int? index}) => _detail(index: index);

  /// Source preview helpers.
  /// Source `popupShow` — preview popup visibility flag.
  bool popupShow([dynamic next]) {
    if (next != null) {
      _popupShow = next == true || next == 'true' || next == 1;
    }
    return _popupShow;
  }

  /// Source before-read / preview / fail aliases.
  Future<dynamic> onBeforeRead(dynamic file, [Map? detail]) async {
    if (widget.onBeforeRead == null) return file;
    return widget.onBeforeRead!(file, detail ?? _detail());
  }

  /// Source after-read / toast aliases (Batch I).
  Future<void> afterRead(dynamic file, [Map? detail]) async {
    await _onAfterRead(file);
  }

  Future<void> onAfterRead(dynamic file, [Map? detail]) async =>
      afterRead(file, detail);
  void toast([dynamic message]) {
    lastToast = message;
  }

  void fail([dynamic err]) => widget.onError?.call(err);
  void onClickPreview(Map item, int index) =>
      widget.onClickPreview?.call(item, index);

  void onPreviewImage(int index) {
    if (index < 0 || index >= _lists.length) return;
    final item = _asMap(_lists[index]);
    _popupShow = true;
    widget.onClickPreview?.call(item, index);
  }

  void onPreviewVideo(int index) => onPreviewImage(index);

  /// Source video helpers.
  dynamic lastVideoError;
  dynamic lastVideoMeta;
  void videoErrorCallback([dynamic err]) {
    lastVideoError = err;
    widget.onError?.call(err);
  }

  void loadedVideoMetadata([dynamic meta]) {
    lastVideoMeta = meta;
  }

  int get count => _lists.length;
  bool get canAdd => _inCount && !widget.disabled;

  /// Source typo-compatible alias of [successUpload].
  void succcessUpload(int index, String url, {String thumb = ''}) =>
      successUpload(index, url, thumb: thumb);

  /// Clear all files.
  void clear() {
    setState(() => _lists = []);
    _emitList();
  }

  /// Replace list programmatically.
  void setFileList(List next) {
    setState(() => _lists = _cloneList(next));
    _emitList();
  }

  @override
  void initState() {
    super.initState();
    _lists = _cloneList(widget.fileList);
  }

  @override
  void didUpdateWidget(covariant UPUpload oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.fileList, widget.fileList)) {
      _lists = _cloneList(widget.fileList);
    }
  }

  List _cloneList(List source) => [
        for (final item in source)
          item is Map ? Map<dynamic, dynamic>.from(item) : item
      ];

  int get _maxCount => int.tryParse('${widget.maxCount}') ?? 52;
  bool get _inCount => _lists.length < _maxCount;

  double? get _maxSize {
    if (widget.maxSize == null || '${widget.maxSize}'.isEmpty) return null;
    return double.tryParse('${widget.maxSize}');
  }

  Map _asMap(dynamic item) {
    if (item is Map) return Map<dynamic, dynamic>.from(item);
    return {'url': '$item', 'status': 'success'};
  }

  bool _isImage(Map item) {
    final type = '${item['type'] ?? ''}';
    if (item['isImage'] == true || type == 'image') return true;
    final url = '${item['url'] ?? item['thumb'] ?? item['path'] ?? ''}';
    return RegExp(r'\.(png|jpe?g|gif|webp|bmp|svg)(\?|$)', caseSensitive: false)
        .hasMatch(url);
  }

  bool _isVideo(Map item) {
    final type = '${item['type'] ?? ''}';
    return item['isVideo'] == true || type == 'video';
  }

  Map _detail({int? index}) => {
        'name': widget.name,
        'index': index ?? _lists.length,
      };

  bool _isOversize(dynamic file) {
    final max = _maxSize;
    if (max == null) return false;
    if (file is List) {
      return file.any((item) {
        final m = _asMap(item);
        final size = num.tryParse('${m['size'] ?? 0}') ?? 0;
        return size > max;
      });
    }
    final m = _asMap(file);
    final size = num.tryParse('${m['size'] ?? 0}') ?? 0;
    return size > max;
  }

  List _normalizeFiles(dynamic file) {
    if (file is List) {
      return [
        for (final item in file)
          _asMap(item)
            ..putIfAbsent('status', () => 'success')
            ..putIfAbsent('message', () => '')
            ..putIfAbsent('progress', () => 0)
      ];
    }
    if (file == null) return const [];
    final m = _asMap(file);
    m.putIfAbsent('status', () => 'success');
    m.putIfAbsent('message', () => '');
    m.putIfAbsent('progress', () => 0);
    return [m];
  }

  void _emitList() {
    widget.onUpdateFileList?.call(_cloneList(_lists));
  }

  Future<void> chooseFile([dynamic params]) async {
    if (widget.disabled || !_inCount) return;
    widget.onChoose?.call();
    dynamic result;
    try {
      if (widget.picker != null) {
        result = await widget.picker!.call();
      } else {
        return;
      }
    } catch (e) {
      widget.onError?.call(e);
      return;
    }
    if (result == null) return;
    await _onBeforeRead(result);
  }

  Future<void> _onBeforeRead(dynamic file) async {
    dynamic next = file;
    if (widget.onBeforeRead != null) {
      next = await widget.onBeforeRead!(file, _detail());
      if (next == false) return;
      next ??= file;
    } else if (widget.useBeforeRead) {
      return;
    }
    await _onAfterRead(next);
  }

  Future<void> _onAfterRead(dynamic file) async {
    if (_isOversize(file)) {
      widget.onOversize?.call(file);
      return;
    }
    final files = _normalizeFiles(file);
    if (files.isEmpty) return;

    final remain = _maxCount - _lists.length;
    final accepted = files.take(remain).toList();
    if (accepted.isEmpty) return;

    final startIndex = _lists.length;
    setState(() {
      for (final item in accepted) {
        if (widget.autoUpload) {
          item['status'] = 'uploading';
          item['message'] = item['message']?.toString().isNotEmpty == true
              ? item['message']
              : '上传中';
          item['progress'] = 0;
        }
        _lists.add(item);
      }
    });
    _emitList();

    // Source only emits afterRead when autoUpload is false.
    if (!widget.autoUpload) {
      widget.onAfterRead?.call(
        accepted.length == 1 ? accepted.first : accepted,
        _detail(index: startIndex),
      );
      return;
    }

    // Keep afterRead for host pipelines even under autoUpload (additive).
    widget.onAfterRead?.call(
      accepted.length == 1 ? accepted.first : accepted,
      _detail(index: startIndex),
    );

    for (var i = 0; i < accepted.length; i++) {
      await _autoUploadOne(startIndex + i);
    }
  }

  Future<void> _autoUploadOne(int index) async {
    if (index < 0 || index >= _lists.length) return;
    final file = _asMap(_lists[index]);
    final context = UPUploadAutoUploadContext(
      index: index,
      driver:
          widget.autoUploadDriver.isEmpty ? 'local' : widget.autoUploadDriver,
      api: widget.autoUploadApi,
      authUrl: widget.autoUploadAuthUrl,
      header: Map<dynamic, dynamic>.from(widget.autoUploadHeader),
      accept: widget.accept,
      name: widget.name,
      customAfterAutoUpload: widget.customAfterAutoUpload,
    );

    updateUpload(
        index, {'progress': 0, 'status': 'uploading', 'message': '上传中'});

    try {
      Map result;
      if (widget.autoUploader != null) {
        result = await widget.autoUploader!(
          file,
          context,
          (progress) {
            updateUpload(index, {
              'progress': progress,
              'status': progress >= 100 ? 'success' : 'uploading',
              'message': progress >= 100 ? '' : '上传中',
            });
          },
        );
      } else {
        // Simulated local success path (no network deps in package).
        for (final p in [20, 55, 90, 100]) {
          await Future<void>.delayed(const Duration(milliseconds: 8));
          if (!mounted || index >= _lists.length) return;
          updateUpload(index, {
            'progress': p,
            'status': p >= 100 ? 'success' : 'uploading',
            'message': p >= 100 ? '' : '上传中',
          });
        }
        result = {
          'url': '${file['url'] ?? file['path'] ?? ''}',
          'thumb': '${file['thumb'] ?? ''}',
          'code': 200,
        };
      }

      if (!mounted || index >= _lists.length) return;

      Map? after;
      if (widget.customAfterAutoUpload && widget.onAfterAutoUpload != null) {
        after = await widget.onAfterAutoUpload!(result);
        if (after == null || '${after['url'] ?? ''}'.isEmpty) {
          failUpload(index, message: '上传失败');
          return;
        }
        successUpload(
          index,
          '${after['url']}',
          thumb: '${after['thumb'] ?? ''}',
        );
        return;
      }

      final url = '${result['url'] ?? result['data']?['url'] ?? ''}';
      final thumb = '${result['thumb'] ?? result['data']?['thumb'] ?? ''}';
      final code = result['code'];
      if (url.isEmpty || (code != null && code != 200 && '$code' != '200')) {
        failUpload(index,
            message: '${result['msg'] ?? result['message'] ?? '上传失败'}');
        return;
      }
      successUpload(index, url, thumb: thumb);
    } catch (e) {
      if (!mounted || index >= _lists.length) return;
      failUpload(index, message: '$e');
      widget.onError?.call(e);
    }
  }

  /// Source-compatible progress update.
  void updateUpload(int index, Map param) {
    if (index < 0 || index >= _lists.length) return;
    final item = _asMap(_lists[index]);
    final progress =
        num.tryParse('${param['progress'] ?? item['progress'] ?? 0}') ?? 0;
    final status =
        param['status'] ?? (progress >= 100 ? 'success' : 'uploading');
    setState(() {
      _lists[index] = {
        ...item,
        ...param,
        'status': status,
        'message': param.containsKey('message')
            ? param['message']
            : (status == 'uploading' ? (item['message'] ?? '上传中') : ''),
        'progress': progress,
      };
    });
    _emitList();
  }

  /// Source-compatible success finalize.
  void successUpload(int index, String url, {String thumb = ''}) {
    if (index < 0 || index >= _lists.length) return;
    final item = _asMap(_lists[index]);
    setState(() {
      _lists[index] = {
        ...item,
        'status': 'success',
        'message': '',
        'url': url,
        'progress': 100,
        if (thumb.isNotEmpty) 'thumb': thumb,
      };
    });
    _emitList();
  }

  /// Failed finalize (status overlay + message).
  void failUpload(int index, {String message = '上传失败'}) {
    if (index < 0 || index >= _lists.length) return;
    final item = _asMap(_lists[index]);
    setState(() {
      _lists[index] = {
        ...item,
        'status': 'failed',
        'message': message,
        'progress': item['progress'] ?? 0,
      };
    });
    _emitList();
  }

  void deleteItem(int index) {
    if (index < 0 || index >= _lists.length) return;
    final item = _asMap(_lists[index]);
    if (widget.autoDelete) {
      setState(() => _lists.removeAt(index));
      _emitList();
      return;
    }
    setState(() => _lists.removeAt(index));
    _emitList();
    widget.onDelete?.call(index, item);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final w = UPUtils.getPx(widget.width);
    final h = UPUtils.getPx(widget.height);
    final iconColor =
        UPUtils.parseColor(widget.uploadIconColor) ?? const Color(0xFFD3D4D6);

    final children = <Widget>[];
    if (widget.previewImage) {
      for (var i = 0; i < _lists.length; i++) {
        final item = _asMap(_lists[i]);
        final status = '${item['status'] ?? 'success'}';
        final progress = (num.tryParse('${item['progress'] ?? 0}') ?? 0)
            .toDouble()
            .clamp(0, 100);
        final url = '${item['thumb'] ?? item['url'] ?? item['path'] ?? ''}';
        final deletableItem = item['deletable'] != false && widget.deletable;
        Widget preview;
        if (_isImage(item) && url.isNotEmpty) {
          preview = UPImage(
            src: url,
            width: w,
            height: h,
            mode: widget.imageMode,
            onClick: () => widget.onClickPreview?.call(item, i),
          );
        } else {
          preview = GestureDetector(
            onTap: () => widget.onClickPreview?.call(item, i),
            child: Container(
              width: w,
              height: h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                border: Border.all(color: tokens.borderColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UPIcon(
                    name: _isVideo(item) ? 'movie' : 'folder',
                    size: 26,
                    color: const Color(0xFF80CBF9),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item['name'] ?? (_isVideo(item) ? '视频' : '文件')}',
                    style: TextStyle(color: tokens.tipsColor, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }

        children.add(
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                preview,
                if (status == 'uploading' || status == 'failed')
                  Positioned.fill(
                    child: Container(
                      color: const Color(0x99000000),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (status == 'failed')
                              const UPIcon(
                                name: 'close-circle',
                                size: 25,
                                color: Color(0xFFFFFFFF),
                              )
                            else
                              const UPLoadingIcon(size: 22, mode: 'circle'),
                            if ('${item['message'] ?? ''}'.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: SizedBox(
                                  width: w,
                                  child: Text(
                                    '${item['message']}',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (status == 'uploading')
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SizedBox(
                      height: 3,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress / 100,
                        child: const ColoredBox(color: Color(0xFF3C9CFF)),
                      ),
                    ),
                  ),
                if (status != 'uploading' && deletableItem)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => deleteItem(i),
                      child: Container(
                        width: 18,
                        height: 18,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Color(0x99000000),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                          ),
                        ),
                        child: const UPIcon(
                          name: 'close',
                          size: 10,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                if (status == 'success')
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 18,
                      height: 14,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFF5AC725),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                        ),
                      ),
                      child: const UPIcon(
                        name: 'checkmark',
                        size: 12,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }
    }

    if (_inCount) {
      if (widget.trigger != null) {
        children.add(
          GestureDetector(
            onTap: widget.disabled
                ? null
                : () {
                    chooseFile();
                  },
            child: widget.trigger,
          ),
        );
      } else {
        children.add(
          GestureDetector(
            onTap: widget.disabled
                ? null
                : () {
                    chooseFile();
                  },
            child: Opacity(
              opacity: widget.disabled ? 0.5 : 1,
              child: Container(
                width: w,
                height: h,
                margin: const EdgeInsets.only(right: 8, bottom: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F5F7),
                  border: Border.all(color: tokens.borderColor),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UPIcon(
                      name: widget.uploadIcon,
                      size: 26,
                      color: iconColor,
                    ),
                    if (widget.uploadText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          widget.uploadText,
                          style: TextStyle(
                            color: tokens.tipsColor,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }

    Widget root = Wrap(children: children);
    if (widget.customStyle != null) {
      root = Container(decoration: widget.customStyle, child: root);
    }
    return root;
  }
}
