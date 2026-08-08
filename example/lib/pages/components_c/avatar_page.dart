import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class AvatarPage extends StatefulWidget {
  const AvatarPage({super.key});

  @override
  State<AvatarPage> createState() => _AvatarPageState();
}

class _AvatarPageState extends State<AvatarPage> {
  static const String _base = 'https://uview-plus.jiangruyi.com/album/';
  static const List<String> _groupUrls = <String>[
    '${_base}1.jpg',
    '${_base}2.jpg',
    '${_base}3.jpg',
    '${_base}4.jpg',
    '${_base}7.jpg',
    '${_base}6.jpg',
    '${_base}5.jpg',
  ];

  int _clickCount = 0;

  Widget _avatarItem(Widget child) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: child,
    );
  }

  Widget _contentRow(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }

  Widget _block(String title, Widget child) {
    return ExampleDemoBlock(title: title, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '头像',
      child: Container(
        key: const ValueKey('example-page-componentsC/avatar/avatar'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _block(
              '基础演示',
              _contentRow([
                const UPAvatar(
                  key: ValueKey('avatar-page-basic'),
                  src: '${_base}1.jpg',
                ),
              ]),
            ),
            _block(
              '头像形状',
              _contentRow([
                _avatarItem(
                  UPAvatar(
                    key: const ValueKey('avatar-page-clickable'),
                    src: '${_base}2.jpg',
                    shape: 'circle',
                    onClick: (_) => setState(() => _clickCount += 1),
                  ),
                ),
                const UPAvatar(
                  src: '${_base}3.jpg',
                  shape: 'square',
                ),
              ]),
            ),
            _block(
              '头像尺寸',
              _contentRow([
                _avatarItem(const UPAvatar(src: '${_base}4.jpg', size: 30)),
                _avatarItem(const UPAvatar(src: '${_base}5.jpg', size: 40)),
                const UPAvatar(src: '${_base}6.jpg', size: 50),
              ]),
            ),
            _block(
              '图标头像',
              _contentRow([
                _avatarItem(const UPAvatar(
                  icon: 'red-packet-fill',
                  fontSize: 22,
                )),
                const UPAvatar(
                  icon: 'star-fill',
                  fontSize: 22,
                ),
              ]),
            ),
            _block(
              '文字头像(自动背景色)',
              _contentRow([
                _avatarItem(const UPAvatar(
                  text: 'U',
                  fontSize: 20,
                  randomBgColor: true,
                  colorIndex: 0,
                )),
                _avatarItem(const UPAvatar(
                  text: '邓',
                  fontSize: 18,
                  randomBgColor: true,
                )),
                _avatarItem(const UPAvatar(
                  text: '张',
                  fontSize: 18,
                  randomBgColor: true,
                )),
                const UPAvatar(
                  text: '王',
                  fontSize: 18,
                  randomBgColor: true,
                ),
              ]),
            ),
            _block(
              '图片加载失败(显示默认头像)',
              _contentRow([
                const UPAvatar(src: '${_base}noExist.jpg'),
              ]),
            ),
            _block(
              '头像组',
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const UPAvatarGroup(
                      key: ValueKey('avatar-page-group-wide'),
                      urls: _groupUrls,
                      size: 35,
                      gap: 0.4,
                    ),
                    const SizedBox(height: 20),
                    const UPAvatarGroup(
                      key: ValueKey('avatar-page-group-tight'),
                      urls: _groupUrls,
                      size: 35,
                      gap: 0.6,
                    ),
                  ],
                ),
              ),
            ),
            if (_clickCount > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text('点击次数：$_clickCount'),
              ),
            const UPGap(height: 40),
          ],
        ),
      ),
    );
  }
}
