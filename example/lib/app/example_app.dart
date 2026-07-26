import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import 'example_shell.dart';

class UltraUiExampleApp extends StatelessWidget {
  const UltraUiExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'uview-plus',
      debugShowCheckedModeBanner: false,
      theme: UP.themeData(),
      home: const ExampleShell(),
    );
  }
}
