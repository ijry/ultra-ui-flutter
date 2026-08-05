import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class AlbumPage extends StatefulWidget {
  const AlbumPage({super.key});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  static const String _albumBase =
      'https://uview-plus.jiangruyi.com/uview/album/';

  static const List<dynamic> _urls1 = <dynamic>[
    <String, String>{'src2': '${_albumBase}1.jpg'},
  ];

  static const List<String> _urls2 = <String>[
    '${_albumBase}1.jpg',
    '${_albumBase}2.jpg',
    '${_albumBase}3.jpg',
    '${_albumBase}4.jpg',
    '${_albumBase}5.jpg',
    '${_albumBase}6.jpg',
    '${_albumBase}7.jpg',
    '${_albumBase}8.jpg',
    '${_albumBase}9.jpg',
    '${_albumBase}10.jpg',
  ];

  static const List<String> _urls3 = <String>[
    '${_albumBase}5.jpg',
    '${_albumBase}6.jpg',
    '${_albumBase}7.jpg',
    '${_albumBase}8.jpg',
  ];

  static const List<String> _urls4 = <String>[
    '${_albumBase}7.jpg',
    '${_albumBase}8.jpg',
    '${_albumBase}9.jpg',
    '${_albumBase}10.jpg',
  ];

  double _albumWidth = 0;
  String _previewText = '';

  void _setAlbumWidth(double width) {
    if (!mounted || width == _albumWidth) return;
    setState(() => _albumWidth = width);
  }

  void _onPreview(String src, int index) {
    setState(() => _previewText = '预览：$src（第${index + 1}张）');
  }

  Widget _avatar() {
    final tokens = UPThemeTokens.of(context);
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: tokens.bgColor,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tokens.primary,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'u',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  Widget _profile({
    required Widget album,
    String description = '全面的组件和便捷的工具会让您信手拈来，如鱼得水',
    bool alignDescription = false,
  }) {
    final descriptionWidget = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: alignDescription && _albumWidth > 0
          ? SizedBox(
              width: _albumWidth,
              child: UPText(text: description, flex1: false),
            )
          : UPText(text: description, flex1: false),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _avatar(),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const UPText(
                text: 'uview-plus',
                type: 'primary',
                bold: true,
                size: 17,
                flex1: false,
              ),
              descriptionWidget,
              album,
            ],
          ),
        ),
      ],
    );
  }

  Widget _block(String title, Widget child) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '相册',
      child: Container(
        key: const ValueKey('example-page-componentsC/album/album'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _block(
              '基础使用',
              _profile(
                album: UPAlbum(
                  key: const ValueKey('album-page-basic'),
                  urls: _urls1,
                  keyName: 'src2',
                  singleSize: 180,
                  onPreview: _onPreview,
                ),
              ),
            ),
            _block(
              '多图模式',
              _profile(
                album: const UPAlbum(
                  key: ValueKey('album-page-multiple'),
                  urls: _urls2,
                  maxCount: 9,
                ),
              ),
            ),
            _block(
              '图文对齐',
              _profile(
                alignDescription: true,
                album: UPAlbum(
                  urls: _urls2,
                  multipleSize: 68,
                  onAlbumWidth: _setAlbumWidth,
                ),
              ),
            ),
            _block(
              '更改裁剪模式',
              _profile(
                album: const UPAlbum(
                  urls: _urls3,
                  rowCount: 2,
                  maxCount: 4,
                  multipleMode: 'scaleToFill',
                ),
              ),
            ),
            _block(
              '更改图片大小',
              _profile(
                album: const UPAlbum(
                  urls: _urls4,
                  rowCount: 2,
                  maxCount: 4,
                  multipleSize: 50,
                ),
              ),
            ),
            _block(
              '自定义圆角',
              _profile(
                album: const UPAlbum(
                  urls: _urls2,
                  radius: 10,
                ),
              ),
            ),
            _block(
              '自定义形状',
              _profile(
                album: const UPAlbum(
                  urls: _urls2,
                  shape: 'circle',
                ),
              ),
            ),
            _block(
              '自适应自动换行',
              _profile(
                description: '每行占满自动换行(不受rowCount限制)',
                album: const UPAlbum(
                  urls: _urls2,
                  maxCount: 9,
                  autoWrap: true,
                ),
              ),
            ),
            if (_previewText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(_previewText),
              ),
            const UPGap(height: 50),
          ],
        ),
      ),
    );
  }
}
