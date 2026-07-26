import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

class ExamplePageScaffold extends StatelessWidget {
  const ExamplePageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.scrollable = true,
  });

  final String title;
  final Widget child;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final body = scrollable
        ? ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: <Widget>[child],
          )
        : child;
    return Scaffold(
      backgroundColor: UPThemeTokens.of(context).pageBgColor,
      appBar: AppBar(
        title: Text(title),
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
      ),
      body:
          SafeArea(key: const ValueKey('example-page-safe-area'), child: body),
    );
  }
}
