import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../../routes/example_catalog.dart';
import '../shared/example_page_scaffold.dart';
import 'parse_source_content.dart';

class ParsePage extends StatelessWidget {
  const ParsePage({super.key});

  static const String _domain =
      'https://6874-html-foe72-1259071903.tcb.qcloud.la/demo';

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '富文本解析器',
      child: Container(
        key: const ValueKey('example-page-componentsB/parse/parse'),
        padding: const EdgeInsets.all(12),
        child: UPParse(
          content: parseSourceContent,
          domain: _domain,
          lazyLoad: true,
          scrollTable: true,
          selectable: true,
          useAnchor: true,
          imageSourceResolver: _offlineImageSource,
          onLinkTap: (href) => _handleSourceLink(context, href),
        ),
      ),
    );
  }

  String _offlineImageSource(String source) =>
      source.startsWith('https://6874-html-foe72-1259071903.tcb.qcloud.la/')
          ? ''
          : source;

  void _handleSourceLink(BuildContext context, String href) {
    if (href.endsWith('/pages/componentsB/parse/jump')) {
      pushExampleRoute(context, findExampleRoute('componentsB/parse/jump'));
      return;
    }
    final message = href.startsWith('#') ? '锚点链接：$href' : href;
    UPToast.show(context, message: message);
  }
}
