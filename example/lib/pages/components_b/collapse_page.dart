import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class CollapsePage extends StatefulWidget {
  const CollapsePage({super.key});

  @override
  State<CollapsePage> createState() => _CollapsePageState();
}

class _CollapsePageState extends State<CollapsePage> {
  List<dynamic> _basicValue = <dynamic>[];
  String _changeText = '变更：[]';

  static const String _docsContent = '涵盖uniapp各个方面，给开发者方向指导和设计理念，让您茅塞顿开，一马平川';
  static const String _componentsContent =
      '众多组件覆盖开发过程的各个需求，组件功能丰富，多端兼容。让您快速集成，开箱即用';
  static const String _toolsContent = '众多的贴心小工具，是您开发过程中召之即来的利器，让您飞镖在手，百步穿杨';

  void _updateBasicValue(dynamic value) {
    setState(() {
      if (value is List) {
        _basicValue = List<dynamic>.from(value);
      } else if (value == null) {
        _basicValue = <dynamic>[];
      } else {
        _basicValue = <dynamic>[value];
      }
    });
  }

  void _recordChange(dynamic value) {
    setState(() => _changeText = '变更：$value');
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: '折叠面板',
      child: Container(
        key: const ValueKey('example-page-componentsB/collapse/collapse'),
        child: Column(
          children: <Widget>[
            _CollapseBlock(
              key: const ValueKey('collapse-page-basic'),
              title: '基础功能',
              footer: Text(_changeText),
              child: UPCollapse(
                value: _basicValue,
                onUpdateValue: _updateBasicValue,
                onChange: _recordChange,
                children: const <Widget>[
                  UPCollapseItem(
                    title: '文档指南',
                    name: 'Docs guide',
                    child: Text(_docsContent),
                  ),
                  UPCollapseItem(
                    title: '组件全面',
                    name: 'Variety components',
                    child: Text(_componentsContent),
                  ),
                  UPCollapseItem(
                    title: '众多利器',
                    name: 'Numerous tools',
                    showRight: false,
                    child: Text(_toolsContent),
                  ),
                ],
              ),
            ),
            const _CollapseBlock(
              key: ValueKey('collapse-page-expanded-disabled'),
              title: '展开和禁用',
              child: UPCollapse(
                value: ['2'],
                children: <Widget>[
                  UPCollapseItem(
                    title: '文档指南',
                    child: Text(_docsContent),
                  ),
                  UPCollapseItem(
                    disabled: true,
                    title: '组件全面',
                    child: Text(_componentsContent),
                  ),
                  UPCollapseItem(
                    name: '2',
                    title: '众多利器',
                    child: Text(_toolsContent),
                  ),
                ],
              ),
            ),
            const _CollapseBlock(
              title: '手风琴模式',
              child: UPCollapse(
                accordion: true,
                children: <Widget>[
                  UPCollapseItem(
                    title: '文档指南',
                    child: Text(_docsContent),
                  ),
                  UPCollapseItem(
                    title: '组件全面',
                    child: Text(_componentsContent),
                  ),
                  UPCollapseItem(
                    title: '众多利器',
                    child: Text(_toolsContent),
                  ),
                ],
              ),
            ),
            const _CollapseBlock(
              title: '移除下划线',
              child: UPCollapse(
                accordion: true,
                border: false,
                children: <Widget>[
                  UPCollapseItem(
                    title: '文档指南',
                    child: Text(_docsContent),
                  ),
                  UPCollapseItem(
                    title: '组件全面',
                    child: Text(_componentsContent),
                  ),
                  UPCollapseItem(
                    title: '众多利器',
                    child: Text(_toolsContent),
                  ),
                ],
              ),
            ),
            _CollapseBlock(
              key: const ValueKey('collapse-page-custom-slots'),
              title: '自定义标题和内容',
              child: UPCollapse(
                accordion: true,
                children: <Widget>[
                  UPCollapseItem(
                    titleWidget: Text(
                      '文档指南',
                      style: TextStyle(color: tokens.primary, fontSize: 14),
                    ),
                    child: const Text(_docsContent),
                  ),
                  const UPCollapseItem(
                    title: '组件全面',
                    iconWidget: UPIcon(name: 'tags-fill', size: 20),
                    child: Text(_componentsContent),
                  ),
                  UPCollapseItem(
                    title: '众多利器',
                    icon: 'tags-fill',
                    rightIconWidget: Text(
                      '10',
                      style: TextStyle(color: tokens.primary, fontSize: 14),
                    ),
                    child: const Text(_toolsContent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class _CollapseBlock extends StatelessWidget {
  const _CollapseBlock({
    super.key,
    required this.title,
    required this.child,
    this.footer,
  });

  final String title;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            child,
            if (footer != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: footer!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
