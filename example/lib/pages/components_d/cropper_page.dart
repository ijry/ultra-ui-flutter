import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class CropperPage extends StatefulWidget {
  const CropperPage({super.key});

  @override
  State<CropperPage> createState() => _CropperPageState();
}

class _CropperPageState extends State<CropperPage> {
  /// Source keys results by the `index` it passes to chooseImage.
  final Map<int, String> _urls = <int, String>{};

  void _cutImage(Map payload) {
    final index = payload['index'];
    final path = payload['path'];
    if (index is! int || path is! String) return;
    setState(() => _urls[index] = path);
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '图片裁剪',
      child: Container(
        key: const ValueKey('example-page-componentsD/cropper/cropper'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '头像裁剪',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: UPCropper(
                  key: const ValueKey('cropper-page-avatar'),
                  index: 0,
                  canChangeSize: false,
                  areaWidth: '300rpx',
                  areaHeight: '300rpx',
                  exportWidth: '260rpx',
                  exportHeight: '260rpx',
                  onConfirm: _cutImage,
                  // Source default slot: an avatar that opens the cropper.
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: UPAvatar(src: _urls[0] ?? '', size: 120),
                  ),
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '可变大小',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: UPCropper(
                  key: const ValueKey('cropper-page-resizable'),
                  index: 1,
                  canChangeSize: true,
                  areaWidth: '300rpx',
                  areaHeight: '180rpx',
                  exportWidth: '260rpx',
                  exportHeight: '160rpx',
                  onConfirm: _cutImage,
                  child: SizedBox(
                    height: 160,
                    child: UPImage(src: _urls[1] ?? '', height: 160),
                  ),
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '限制在图片内',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: UPCropper(
                  key: const ValueKey('cropper-page-inner'),
                  index: 2,
                  inner: true,
                  canChangeSize: false,
                  areaWidth: '300rpx',
                  areaHeight: '300rpx',
                  exportWidth: '260rpx',
                  exportHeight: '260rpx',
                  onConfirm: _cutImage,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: UPAvatar(src: _urls[2] ?? '', size: 120),
                  ),
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '裁剪已有临时图片',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: UPCropper(
                  key: const ValueKey('cropper-page-external'),
                  index: 3,
                  areaWidth: '300rpx',
                  areaHeight: '300rpx',
                  exportWidth: '260rpx',
                  exportHeight: '260rpx',
                  onConfirm: _cutImage,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: UPAvatar(src: _urls[3] ?? '', size: 120),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
