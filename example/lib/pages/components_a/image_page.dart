import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class ImagePage extends StatelessWidget {
  const ImagePage({super.key});

  static const String _image = 'assets/uview/album/1.jpg';

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '图片',
      child: Container(
        key: const ValueKey('example-page-componentsA/image/image'),
        child: Column(
          children: <Widget>[
            _ImageBlock(
                '基本案例',
                UPImage(
                    src: _image,
                    width: 80,
                    height: 80,
                    onClick: () => UPToast.show(context, message: '点击图片'))),
            const _ImageBlock('自定义形状',
                UPImage(src: _image, shape: 'circle', width: 80, height: 80)),
            const _ImageBlock('自定义圆角',
                UPImage(src: _image, radius: 12, width: 80, height: 80)),
            const _ImageBlock('宽度100%',
                UPImage(src: _image, radius: 12, width: '100%', height: 80)),
            const _ImageBlock('图片模式(widthFix)',
                UPImage(src: _image, mode: 'widthFix', width: 80, height: 80)),
            const _ImageBlock('图片模式(heightFix)',
                UPImage(src: _image, mode: 'heightFix', width: 80, height: 80)),
            const _ImageBlock(
                '图片模式(scaleToFill)',
                UPImage(
                    src: _image, mode: 'scaleToFill', width: 80, height: 80)),
            const _ImageBlock('图片模式(aspectFit)',
                UPImage(src: _image, mode: 'aspectFit', width: 80, height: 80)),
            const _ImageBlock(
                '图片模式(aspectFill)',
                UPImage(
                    src: _image, mode: 'aspectFill', width: 80, height: 80)),
            const _ImageBlock(
                '自定义图片加载插槽',
                UPImage(
                    src: '',
                    mode: 'widthFix',
                    width: 80,
                    height: 80,
                    loadingWidget: UPLoadingIcon(color: 'red'))),
          ],
        ),
      ),
    );
  }
}

class _ImageBlock extends StatelessWidget {
  const _ImageBlock(this.title, this.image);

  final String title;
  final Widget image;

  @override
  Widget build(BuildContext context) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(padding: const EdgeInsets.all(16), child: image),
    );
  }
}
