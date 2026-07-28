import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class Tabbar2Page extends StatefulWidget {
  const Tabbar2Page({super.key});

  @override
  State<Tabbar2Page> createState() => _Tabbar2PageState();
}

class _Tabbar2PageState extends State<Tabbar2Page> {
  int _value1 = 0;
  int _value2 = 1;
  String _value3 = 'play-right';
  int _value4 = 0;
  int _value5 = 0;
  int _value6 = 0;
  int _value7 = 3;
  int _value8 = 0;
  int _value9 = 1;
  int _value10 = 0;
  int _value11 = 2;
  int _value12 = 0;
  int _value13 = 1;
  int _value14 = 2;
  int _value15 = 2;

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }

  void _setInt(void Function(int value) update, dynamic value) {
    setState(() => update(_toInt(value)));
  }

  void _changeIntercept(dynamic name) {
    if (name == 1) {
      UPToast.show(context, message: '请您先登录');
      return;
    }
    _setInt((value) => _value5 = value, name);
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: 'Tabbar-vue',
      child: Container(
        key: const ValueKey('example-page-componentsB/tabbar/tabbar2'),
        child: Column(
          children: <Widget>[
            _Tabbar2Block(
              title: '基础功能',
              child: _tabbar(
                value: _value1,
                onChange: (name) => _setInt((value) => _value1 = value, name),
                children: _sourceItems(),
                footer: Text('基础值：$_value1'),
              ),
            ),
            _Tabbar2Block(
              title: '显示徽标',
              child: _tabbar(
                value: _value2,
                onChange: (name) => _setInt((value) => _value2 = value, name),
                children: _sourceItems(badge: true),
                footer: Text('徽标值：$_value2'),
              ),
            ),
            _Tabbar2Block(
              title: '匹配标签的名称',
              child: _tabbar(
                value: _value3,
                onChange: (name) => setState(() => _value3 = '$name'),
                children: _sourceItems(
                  names: const <dynamic>[
                    'home',
                    'photo',
                    'play-right',
                    'account',
                  ],
                ),
                footer: Text('名称值：$_value3'),
              ),
            ),
            _Tabbar2Block(
              title: '自定义图标/颜色',
              child: _tabbar(
                value: _value4,
                activeColor: '#d81e06',
                onChange: (name) => _setInt((value) => _value4 = value, name),
                children: _sourceItems(customIcons: true),
                footer: Text('颜色值：$_value4'),
              ),
            ),
            _Tabbar2Block(
              title: '拦截切换事件(点击第二个标签)',
              child: _tabbar(
                value: _value5,
                onChange: _changeIntercept,
                children: _sourceItems(),
                footer: Text('拦截值：$_value5'),
              ),
            ),
            _Tabbar2Block(
              title: '去除上边框',
              child: _tabbar(
                value: _value7,
                border: false,
                onChange: (name) => _setInt((value) => _value7 = value, name),
                children: _sourceItems(),
                footer: Text('无边框值：$_value7'),
              ),
            ),
            _Tabbar2Block(
              title: '首页导航推荐：胶囊风格',
              child: _tabbar(
                value: _value8,
                styleType: 'pill',
                animationType: 'scale',
                activeBackgroundColor: 'rgba(59, 130, 246, 0.10)',
                onChange: (name) => _setInt((value) => _value8 = value, name),
                children: _homeItems(),
                footer: Text('胶囊值：$_value8'),
              ),
            ),
            _Tabbar2Block(
              title: '首页导航推荐：上浮风格',
              child: _tabbar(
                value: _value9,
                styleType: 'lift',
                animationType: 'lift',
                textMode: 'active',
                onChange: (name) => _setInt((value) => _value9 = value, name),
                children: _homeItems(),
                footer: Text('上浮值：$_value9'),
              ),
            ),
            _Tabbar2Block(
              title: '中间按钮自定义背景色',
              child: _tabbar(
                value: _value14,
                onChange: (name) => _setInt((value) => _value14 = value, name),
                children: _midButtonItems(
                  midText: '发布',
                  midIcon: 'plus',
                  midBgColor: '#E8FFF7',
                  midIconColor: '#10B981',
                ),
                footer: Text('中间背景值：$_value14'),
              ),
            ),
            _Tabbar2Block(
              title: '中间按钮自定义图标',
              child: _tabbar(
                value: _value15,
                onChange: (name) => _setInt((value) => _value15 = value, name),
                children: _midButtonItems(
                  midText: '拍摄',
                  midIcon: 'camera-fill',
                  midBgColor: '#EEF4FF',
                  midIconColor: '#3B82F6',
                  midIconSize: 30,
                ),
                footer: Text('中间图标值：$_value15'),
              ),
            ),
            _Tabbar2Block(
              title: '卡片风格 + 脉冲反馈',
              child: _tabbar(
                value: _value10,
                styleType: 'card',
                animationType: 'pulse',
                activeBackgroundColor: 'rgba(255, 107, 107, 0.12)',
                onChange: (name) => _setInt((value) => _value10 = value, name),
                children: _cardItems(),
                footer: Text('卡片值：$_value10'),
              ),
            ),
            _Tabbar2Block(
              title: '下划线风格',
              child: _tabbar(
                value: _value11,
                styleType: 'underline',
                animationType: 'swing',
                onChange: (name) => _setInt((value) => _value11 = value, name),
                children: _underlineItems(),
                footer: Text('下划线值：$_value11'),
              ),
            ),
            _Tabbar2Block(
              key: const ValueKey('tabbar2-page-dot'),
              title: '圆点风格',
              child: _tabbar(
                value: _value12,
                styleType: 'dot',
                onChange: (name) => _setInt((value) => _value12 = value, name),
                children: _dotItems(),
                footer: Text('圆点值：$_value12'),
              ),
            ),
            _Tabbar2Block(
              title: '首页导航推荐：发光风格',
              child: _tabbar(
                value: _value13,
                styleType: 'glow',
                animationType: 'scale',
                activeBackgroundColor: 'rgba(125, 211, 252, 0.12)',
                onChange: (name) => _setInt((value) => _value13 = value, name),
                children: _homeItems(),
                footer: Text('发光值：$_value13'),
              ),
            ),
            _Tabbar2Block(
              title: '固定在底部(固定在屏幕最下方)',
              child: _tabbar(
                value: _value6,
                fixed: true,
                placeholder: true,
                safeAreaInsetBottom: true,
                onChange: (name) => _setInt((value) => _value6 = value, name),
                children: _sourceItems(),
                footer: Text('固定值：$_value6'),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _tabbar({
    required dynamic value,
    required ValueChanged<dynamic> onChange,
    required List<Widget> children,
    bool fixed = false,
    bool placeholder = false,
    bool safeAreaInsetBottom = false,
    bool border = true,
    String activeColor = '#1989fa',
    String inactiveColor = '#7d7e80',
    String styleType = 'default',
    String animationType = 'none',
    String textMode = 'always',
    String activeBackgroundColor = '',
    Widget? footer,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        UPTabbar(
          value: value,
          fixed: fixed,
          placeholder: placeholder,
          safeAreaInsetBottom: safeAreaInsetBottom,
          border: border,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          styleType: styleType,
          animationType: animationType,
          textMode: textMode,
          activeBackgroundColor: activeBackgroundColor,
          children: children,
          onChange: onChange,
        ),
        if (footer != null) ...[
          const SizedBox(height: 8),
          footer,
        ],
      ],
    );
  }

  List<Widget> _sourceItems({
    List<dynamic> names = const <dynamic>[0, 1, 2, 3],
    bool badge = false,
    bool customIcons = false,
  }) {
    const labels = <String>['首页', '放映厅', '直播', '我的'];
    const icons = <String>['home', 'photo', 'play-right', 'account'];
    return List<Widget>.generate(labels.length, (index) {
      return UPTabbarItem(
        name: names[index],
        text: labels[index],
        icon: customIcons && index == 0 ? 'bell' : icons[index],
        activeIcon: customIcons && index == 0 ? 'bell-fill' : '',
        dot: badge && index == 0,
        badge: badge && index == 1 ? '3' : null,
      );
    });
  }

  List<Widget> _homeItems() {
    const labels = <String>['首页', '发现', '消息', '我的'];
    const icons = <String>['home', 'search', 'chat', 'account'];
    const activeIcons = <String>[
      'home-fill',
      'search',
      'chat-fill',
      'account-fill',
    ];
    return List<Widget>.generate(labels.length, (index) {
      return UPTabbarItem(
        name: index,
        text: labels[index],
        icon: icons[index],
        activeIcon: activeIcons[index],
      );
    });
  }

  List<Widget> _midButtonItems({
    required String midText,
    required String midIcon,
    required String midBgColor,
    required String midIconColor,
    int midIconSize = 26,
  }) {
    return <Widget>[
      const UPTabbarItem(name: 0, text: '首页', icon: 'home'),
      const UPTabbarItem(name: 1, text: '发现', icon: 'search'),
      UPTabbarItem(
        name: 2,
        text: midText,
        icon: midIcon,
        mode: 'midButton',
        midButtonBgColor: midBgColor,
        midButtonIconColor: midIconColor,
        midButtonIconSize: midIconSize,
        midButtonOffsetY: -12,
      ),
      const UPTabbarItem(name: 3, text: '消息', icon: 'chat'),
      const UPTabbarItem(name: 4, text: '我的', icon: 'account'),
    ];
  }

  List<Widget> _cardItems() {
    const labels = <String>['收藏', '喜欢', '消息', '地图'];
    const icons = <String>['star', 'heart', 'chat', 'map'];
    const activeIcons = <String>[
      'star-fill',
      'heart-fill',
      'chat-fill',
      'map-fill',
    ];
    return List<Widget>.generate(labels.length, (index) {
      return UPTabbarItem(
        name: index,
        text: labels[index],
        icon: icons[index],
        activeIcon: activeIcons[index],
      );
    });
  }

  List<Widget> _underlineItems() {
    const labels = <String>['首页', '分类', '消息', '我的'];
    const icons = <String>['home', 'grid', 'chat', 'account'];
    const activeIcons = <String>[
      'home-fill',
      'grid-fill',
      'chat-fill',
      'account-fill',
    ];
    return List<Widget>.generate(labels.length, (index) {
      return UPTabbarItem(
        name: index,
        text: labels[index],
        icon: icons[index],
        activeIcon: activeIcons[index],
      );
    });
  }

  List<Widget> _dotItems() {
    const labels = <String>['首页', '图片', '视频', '我的'];
    const icons = <String>['home', 'photo', 'play-right', 'account'];
    const activeIcons = <String>[
      'home-fill',
      'photo-fill',
      'play-right-fill',
      'account-fill',
    ];
    return List<Widget>.generate(labels.length, (index) {
      return UPTabbarItem(
        name: index,
        text: labels[index],
        icon: icons[index],
        activeIcon: activeIcons[index],
      );
    });
  }
}

class _Tabbar2Block extends StatelessWidget {
  const _Tabbar2Block({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}
