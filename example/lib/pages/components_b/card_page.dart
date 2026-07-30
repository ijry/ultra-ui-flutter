import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  static const String _title = '素胚勾勒出青花，笔锋浓转淡';
  static const String _subTitle = '2023-05-15';
  static const String _thumbUrl =
      'https://uview-plus.jiangruyi.com/uview/ext/59c256f85a8c3757.jpg';
  static const String _baseText = '尊敬的客户您好，您有来自的开票。如果有疑问请联系您的客户经理。';
  static const List<int> _paddingOptions = <int>[10, 15, 20];

  bool _thumbVisible = true;
  int _paddingIndex = 1;
  bool _bottomVisible = true;
  bool _borderVisible = true;

  int get _paddingValue => _paddingOptions[_paddingIndex];

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: '卡片',
      child: Container(
        key: const ValueKey('example-page-componentsB/card/card'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              color: tokens.pageBgColor,
              padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const UPTitle(text: '基础卡片'),
                  const SizedBox(height: 10),
                  const UPCard(
                    full: true,
                    showHead: false,
                    showFoot: false,
                    body: Text(
                      _baseText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const UPTitle(text: '高级卡片'),
                  const SizedBox(height: 10),
                  UPCard(
                    full: true,
                    title: _title,
                    subTitle: _subTitle,
                    thumb: _thumbVisible ? _thumbUrl : '',
                    padding: _paddingValue,
                    border: _borderVisible,
                    showFoot: _bottomVisible,
                    body: const _AdvancedCardBody(imageUrl: _thumbUrl),
                    foot: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: UPIcon(
                        name: 'chat-fill',
                        size: 16,
                        label: '30评论',
                        labelSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const ExampleDemoBlock(
              title: '参数配置',
              child: SizedBox(height: 12),
            ),
            _ControlBlock(
              key: const ValueKey('card-page-thumb'),
              title: '左上角图标',
              stateText: '左上角图标：${_thumbVisible ? '显示' : '隐藏'}',
              child: UPSubsection(
                list: const <String>['显示', '隐藏'],
                current: _thumbVisible ? 0 : 1,
                onChange: (index) {
                  setState(() => _thumbVisible = index == 0);
                },
              ),
            ),
            _ControlBlock(
              key: const ValueKey('card-page-padding'),
              title: '内边距',
              stateText: '内边距：$_paddingValue',
              child: UPSubsection(
                list: _paddingOptions.map((value) => '$value').toList(),
                current: _paddingIndex,
                onChange: (index) {
                  setState(() => _paddingIndex = index);
                },
              ),
            ),
            _ControlBlock(
              key: const ValueKey('card-page-foot'),
              title: '底部',
              stateText: '底部：${_bottomVisible ? '显示' : '隐藏'}',
              child: UPSubsection(
                list: const <String>['显示', '隐藏'],
                current: _bottomVisible ? 0 : 1,
                onChange: (index) {
                  setState(() => _bottomVisible = index == 0);
                },
              ),
            ),
            _ControlBlock(
              key: const ValueKey('card-page-border'),
              title: '外边框',
              stateText: '外边框：${_borderVisible ? '显示' : '隐藏'}',
              child: UPSubsection(
                list: const <String>['显示', '隐藏'],
                current: _borderVisible ? 0 : 1,
                onChange: (index) {
                  setState(() => _borderVisible = index == 0);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdvancedCardBody extends StatelessWidget {
  const _AdvancedCardBody({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _CardBodyItem(
          imageUrl: imageUrl,
          borderBottom: true,
          text: '瓶身描绘的牡丹一如你初妆，冉冉檀香透过窗心事我了然，宣纸上走笔至此搁一半',
        ),
        _CardBodyItem(
          imageUrl: imageUrl,
          text: '釉色渲染仕女图韵味被私藏，而你嫣然的一笑如含苞待放',
        ),
      ],
    );
  }
}

class _CardBodyItem extends StatelessWidget {
  const _CardBodyItem({
    required this.text,
    required this.imageUrl,
    this.borderBottom = false,
  });

  final String text;
  final String imageUrl;
  final bool borderBottom;

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(
        border: borderBottom
            ? Border(bottom: BorderSide(color: tokens.borderColor, width: 0.5))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: tokens.mainColor,
                fontSize: 16,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 6),
          UPImage(
            src: imageUrl,
            width: 60,
            height: 60,
            radius: 4,
            showLoading: false,
          ),
        ],
      ),
    );
  }
}

class _ControlBlock extends StatelessWidget {
  const _ControlBlock({
    super.key,
    required this.title,
    required this.stateText,
    required this.child,
  });

  final String title;
  final String stateText;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            child,
            const SizedBox(height: 8),
            Text(stateText),
          ],
        ),
      ),
    );
  }
}
