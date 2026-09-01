import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';
import 'package:ultra_ui_media/ultra_ui_media.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class PdfReaderPage extends StatefulWidget {
  const PdfReaderPage({super.key});

  @override
  State<PdfReaderPage> createState() => _PdfReaderPageState();
}

class _PdfReaderPageState extends State<PdfReaderPage> {
  bool _show = false;

  static const String _pdfFileUrl =
      'https://uview-plus.jiangruyi.com/big/plus.pdf';

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: 'PDF阅读器',
      child: Container(
        key: const ValueKey('example-page-componentsD/pdfReader/pdfReader'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '默认',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    UPButton(
                      key: const ValueKey('pdf-reader-page-open'),
                      text: '打开PDF预览',
                      onClick: () => setState(() => _show = true),
                    ),
                    UPPopup(
                      show: _show,
                      onUpdateShow: (value) => setState(() => _show = value),
                      onClose: () => setState(() => _show = false),
                      child: SizedBox(
                        height: 480,
                        child: UPPdfReader(
                          key: const ValueKey('pdf-reader-page-viewer'),
                          src: _pdfFileUrl,
                          baseUrl: '',
                          viewerBuilder: (viewerUrl) => UPPdfView(
                            target: resolvePdfTarget(viewerUrl),
                          ),
                        ),
                      ),
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
}
