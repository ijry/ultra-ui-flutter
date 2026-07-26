import 'package:flutter/material.dart';

import '../pages/home/components_home_page.dart';
import '../pages/home/mine_page.dart';
import '../pages/home/templates_home_page.dart';

class ExampleShell extends StatefulWidget {
  const ExampleShell({super.key});

  @override
  State<ExampleShell> createState() => _ExampleShellState();
}

class _ExampleShellState extends State<ExampleShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const <Widget>[
          ComponentsHomePage(),
          TemplatesHomePage(),
          MinePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.widgets_outlined),
            selectedIcon: Icon(Icons.widgets),
            label: '组件',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: '模板',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
