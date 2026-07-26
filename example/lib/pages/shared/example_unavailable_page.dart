import 'package:flutter/material.dart';

import 'example_page_scaffold.dart';

class ExampleUnavailablePage extends StatelessWidget {
  const ExampleUnavailablePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: title,
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Text('后续迁移'),
      ),
    );
  }
}
