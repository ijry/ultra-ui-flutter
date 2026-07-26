import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

class OverlayPage extends StatefulWidget {
  const OverlayPage({super.key});

  @override
  State<OverlayPage> createState() => _OverlayPageState();
}

class _OverlayPageState extends State<OverlayPage> {
  bool _showBase = false;
  bool _showContent = false;
  bool _showTransparency = false;

  bool get _hasVisibleOverlay => _showBase || _showContent || _showTransparency;

  void _dismissTopmostOverlay() {
    setState(() {
      if (_showTransparency) {
        _showTransparency = false;
      } else if (_showContent) {
        _showContent = false;
      } else {
        _showBase = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasVisibleOverlay,
      // Keep the declared Flutter 3.19 minimum SDK compatible.
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) {
        if (!didPop && _hasVisibleOverlay) _dismissTopmostOverlay();
      },
      child: ExamplePageScaffold(
        title: '遮罩层',
        scrollable: false,
        child: Stack(
          children: <Widget>[
            Container(
              key: const ValueKey('example-page-componentsA/overlay/overlay'),
              padding: const EdgeInsets.only(top: 20),
              child: UPCellGroup(
                children: <Widget>[
                  _OverlayCell(
                    title: '基本案列',
                    asset: 'assets/uview/demo/overlay/baseCases.png',
                    onClick: () => setState(() => _showBase = true),
                  ),
                  _OverlayCell(
                    title: '嵌入内容',
                    asset: 'assets/uview/demo/overlay/embeddedContent.png',
                    onClick: () => setState(() => _showContent = true),
                  ),
                  _OverlayCell(
                    title: '设置透明度',
                    asset: 'assets/uview/demo/overlay/setTransparency.png',
                    onClick: () => setState(() => _showTransparency = true),
                  ),
                ],
              ),
            ),
            if (_showBase)
              UPOverlay(
                show: true,
                rootOverlay: false,
                onClick: () => setState(() => _showBase = false),
              ),
            if (_showContent)
              UPOverlay(
                show: true,
                rootOverlay: false,
                onClick: () => setState(() => _showContent = false),
                child: Center(
                  child: IgnorePointer(
                    child: Container(
                      key: const ValueKey('overlay-content-box'),
                      width: 100,
                      height: 100,
                      color: const Color(0xFF70E1F5),
                    ),
                  ),
                ),
              ),
            if (_showTransparency)
              UPOverlay(
                show: true,
                rootOverlay: false,
                opacity: .85,
                onClick: () => setState(() => _showTransparency = false),
              ),
          ],
        ),
      ),
    );
  }
}

class _OverlayCell extends StatelessWidget {
  const _OverlayCell({
    required this.title,
    required this.asset,
    required this.onClick,
  });

  final String title;
  final String asset;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return UPCell(
      title: title,
      titleStyle: const TextStyle(fontWeight: FontWeight.w500),
      isLink: true,
      clickable: true,
      iconSlot: Image.asset(asset, width: 48, height: 30, fit: BoxFit.contain),
      onClick: onClick,
    );
  }
}
