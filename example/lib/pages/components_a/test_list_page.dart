import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

class TestListPage extends StatelessWidget {
  const TestListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '测试',
      scrollable: false,
      child: Container(
        key: const ValueKey('example-page-componentsA/test/test'),
        child: UPList(
          height: 500,
          customStyle: const BoxDecoration(color: Colors.red),
          children: List<Widget>.generate(
            7,
            (_) => const UPListItem(
              child: UPImage(
                src: 'assets/uview/test/list-item.jpg',
                width: '100%',
                height: 160,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
