import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  String _preference = 'system';
  String _bridgeStatus = 'UpRoot 状态：未测试';

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final activeTheme =
        Theme.of(context).brightness == Brightness.dark ? '深色' : '浅色';
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tokens.cardBgColor,
                border: Border.all(color: tokens.borderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: <Widget>[
                  UPAvatar(text: '演', size: 72, bgColor: '#3c9cff'),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('演示用户',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      SizedBox(height: 6),
                      Text('ID: 1008611'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            UPCellGroup(
              title: '主题模式',
              children: <Widget>[
                _preferenceCell('system', '跟随系统'),
                _preferenceCell('light', '浅色模式'),
                _preferenceCell('dark', '深色模式'),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 14, left: 4),
              child: Text('当前主题：$activeTheme（${_preferenceText()}）',
                  style: TextStyle(color: tokens.tipsColor)),
            ),
            const SizedBox(height: 16),
            UPCellGroup(
              title: 'Root 根组件',
              children: <Widget>[
                UPCell(
                  title: '测试 UpRootView 通信',
                  isLink: true,
                  clickable: true,
                  onClick: _testToastBridge,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 14, left: 4),
              child: Text(_bridgeStatus,
                  style: TextStyle(color: tokens.tipsColor)),
            ),
          ],
        ),
      ),
    );
  }

  UPCell _preferenceCell(String value, String title) {
    return UPCell(
      title: title,
      value: _preference == value ? '当前' : '',
      isLink: true,
      clickable: true,
      onClick: () => setState(() => _preference = value),
    );
  }

  String _preferenceText() {
    if (_preference == 'system') return '跟随系统';
    return _preference == 'dark' ? '手动深色' : '手动浅色';
  }

  void _testToastBridge() {
    setState(() => _bridgeStatus = 'UpRoot 状态：通信成功（本地 Toast bridge）');
    UP.toast(context, message: '来自 Mine 页的 UpRoot 调用', type: 'success');
  }
}
