import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class SignaturePage extends StatefulWidget {
  const SignaturePage({super.key});

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  final UPSignatureController _signature1 = UPSignatureController();
  final UPSignatureController _signature2 = UPSignatureController();

  ui.Image? _preview1;
  ui.Image? _preview2;

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Source picks the canvas background from the active theme.
    final bgColor = isDark ? '#1c1c1e' : '#f5f5f5';

    return ExamplePageScaffold(
      title: '签名',
      child: Container(
        key: const ValueKey('example-page-componentsD/signature/signature'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: UPAlert(description: 'PC端查看时需要触摸仿真模式'),
            ),
            ExampleDemoBlock(
              title: '基础签名示例',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    UPSignature(
                      key: const ValueKey('signature-page-basic'),
                      controller: _signature1,
                      // Source passes 700x200 in rpx-derived px units.
                      width: 700,
                      height: 200,
                      bgColor: bgColor,
                      showToolbar: false,
                      onConfirm: (payload) => _capture(1),
                    ),
                    _previewBlock(
                      image: _preview1,
                      tokens: tokens,
                      onExport: () => _capture(1),
                      onClear: () {
                        _signature1.clear();
                        setState(() => _preview1 = null);
                      },
                      exportKey: const ValueKey('signature-page-export-1'),
                      clearKey: const ValueKey('signature-page-clear-1'),
                    ),
                  ],
                ),
              ),
            ),
            ExampleDemoBlock(
              title: '自定义颜色和工具栏示例',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    UPSignature(
                      key: const ValueKey('signature-page-custom'),
                      controller: _signature2,
                      width: 700,
                      height: 200,
                      color: '#ff0000',
                      thickness: 6,
                      bgColor: bgColor,
                      onConfirm: (payload) => _capture(2),
                    ),
                    _previewBlock(
                      image: _preview2,
                      tokens: tokens,
                      onExport: () => _capture(2),
                      onClear: () {
                        _signature2.clear();
                        setState(() => _preview2 = null);
                      },
                      exportKey: const ValueKey('signature-page-export-2'),
                      clearKey: const ValueKey('signature-page-clear-2'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The source previews an exported temp file path; there is no filesystem step
  /// here, so the exported [ui.Image] is shown directly via RawImage.
  Future<void> _capture(int which) async {
    final controller = which == 1 ? _signature1 : _signature2;
    final image = await controller.toImage();
    if (!mounted) return;
    setState(() {
      if (which == 1) {
        _preview1 = image;
      } else {
        _preview2 = image;
      }
    });
  }

  Widget _previewBlock({
    required ui.Image? image,
    required UPThemeTokens tokens,
    required VoidCallback onExport,
    required VoidCallback onClear,
    required Key exportKey,
    required Key clearKey,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              UPButton(
                key: exportKey,
                type: 'primary',
                size: 'small',
                text: '生成预览',
                onClick: onExport,
              ),
              const SizedBox(width: 8),
              UPButton(
                key: clearKey,
                type: 'primary',
                size: 'small',
                text: '清除签名',
                onClick: onClear,
              ),
            ],
          ),
          if (image != null) ...<Widget>[
            const SizedBox(height: 10),
            Text('签名预览:', style: TextStyle(color: tokens.contentColor)),
            const SizedBox(height: 10),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: tokens.borderColor),
              ),
              child: SizedBox(
                height: 120,
                child: RawImage(image: image, fit: BoxFit.contain),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
