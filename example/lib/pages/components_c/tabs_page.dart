import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  int _current = 3;
  int _clickCount = 0;

  void _selectTab(int index) {
    if (!mounted) return;
    setState(() {
      _current = index;
      _clickCount += 1;
    });
  }

  void _nextTab() {
    final next = (_current + 1) % _baseTabs.length;
    final disabled = _baseTabs[next]['disabled'] == true;
    if (disabled) return;
    _selectTab(next);
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      key: const ValueKey('example-page-componentsC/tabs/tabs'),
      title: '标签',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ExampleDemoBlock(
            title: '基础演示',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                UPTabs(
                  key: const ValueKey('tabs-page-basic'),
                  list: _baseTabs,
                  current: _current,
                  onChange: _selectTab,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Text('当前索引：$_current'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Text('点击次数：$_clickCount'),
                ),
              ],
            ),
          ),
          const ExampleDemoBlock(
            title: '粘性布局',
            child: UPSticky(
              bgColor: '#ffffff',
              child: UPTabs(list: _baseTabs),
            ),
          ),
          const ExampleDemoBlock(
            title: '显示徽标',
            child: UPTabs(list: _badgeTabs),
          ),
          const ExampleDemoBlock(
            title: '禁止滚动',
            child: UPTabs(
              list: _nonScrollableTabs,
              scrollable: false,
            ),
          ),
          const ExampleDemoBlock(
            title: '禁用菜单',
            child: UPTabs(
              key: ValueKey('tabs-page-disabled'),
              list: _disabledTabs,
            ),
          ),
          const ExampleDemoBlock(
            title: '自定义样式',
            child: UPTabs(
              list: _baseTabs,
              lineWidth: 30,
              lineColor: '#f56c6c',
              activeStyle: <String, dynamic>{
                'color': '#303133',
                'fontWeight': 'bold',
              },
              inactiveStyle: <String, dynamic>{
                'color': '#606266',
              },
              itemStyle: <String, dynamic>{
                'height': '34px',
              },
            ),
          ),
          ExampleDemoBlock(
            title: '右侧自定义插槽',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const UPTabs(
                  list: _baseTabs,
                  right: UPIcon(name: 'list', size: 21),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: UPButton(
                    key: const ValueKey('tabs-page-next'),
                    type: 'primary',
                    size: 'small',
                    text: '切换下一个',
                    stop: false,
                    onClick: _nextTab,
                  ),
                ),
              ],
            ),
          ),
          const ExampleDemoBlock(
            title: '胶囊模式',
            child: UPTabs(
              list: _shapeTabs,
              scrollable: false,
              shapeMode: 'capsule',
            ),
          ),
          const ExampleDemoBlock(
            title: '卡片模式',
            child: UPTabs(
              list: _cardTabs,
              scrollable: false,
              shapeMode: 'card',
              lineWidth: 26,
            ),
          ),
          const ExampleDemoBlock(
            title: '圆角矩形箭头模式',
            child: UPTabs(
              list: _pillArrowTabs,
              scrollable: false,
              shapeMode: 'pill-arrow',
            ),
          ),
          const ExampleDemoBlock(
            title: 'Tag模式',
            child: UPTabs(
              list: _tagTabs,
              shapeMode: 'tag',
            ),
          ),
          const ExampleDemoBlock(
            title: '滑块设置背景图',
            child: UPTabs(
              key: ValueKey('tabs-page-line-bg'),
              list: _badgeTabs,
              lineWidth: 20,
              lineHeight: 7,
              // Source passes a CSS image shorthand, not a colour: the base64
              // PNG below is the one from its own demo data.
              lineColor: 'url(data:image/png;base64,$_lineBg) 100% 100%',
              activeStyle: <String, dynamic>{
                'color': '#303133',
                'fontWeight': 'bold',
                'transform': 'scale(1.05)',
              },
              inactiveStyle: <String, dynamic>{
                'color': '#606266',
                'transform': 'scale(1)',
              },
              itemStyle: <String, dynamic>{
                'paddingLeft': '15px',
                'paddingRight': '15px',
                'height': '34px',
              },
            ),
          ),
          ExampleDemoBlock(
            title: '自定义内容插槽',
            child: UPTabs(
              key: const ValueKey('tabs-page-content-slot'),
              list: _baseTabs,
              // Source `default`/`content` slot, scoped {item, keyName, index}.
              contentBuilder: (context, item, keyName, index) => Text(
                '${item[keyName] ?? '-'}',
                style: const TextStyle(color: Color(0xFFFF0000)),
              ),
            ),
          ),
          ExampleDemoBlock(
            title: '在swiper中使用',
            child: SizedBox(
              height: 120,
              child: UPSwiper(
                key: const ValueKey('tabs-page-in-swiper'),
                list: const <String>['A', 'B'],
                autoplay: false,
                indicator: true,
                itemBuilder: (context, item, index) => UPTabs(
                  list: _baseTabs,
                  contentBuilder: (context, tab, keyName, i) => Text(
                    '$item-${tab[keyName] ?? '-'}',
                    style: const TextStyle(color: Color(0xFFFF0000)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Source `lineBg`: the slider texture, inlined as a data URI in its demo data.
const String _lineBg =
    'iVBORw0KGgoAAAANSUhEUgAAACgAAAAOCAYAAABdC15GAAAACXBIWXMAABYlAAAWJQFJUiTwAAAA'
    'AXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAFxSURBVHgBzZNRTsJAEIb/WTW+lpiY+FZPIDew'
    '3ABP4GJ8hxsI9zBpOYHeQDwBPQI+mRiRvpLojtPdYhCorQqF/6GdbGd2vvwzBXZcNAt4oj1ANeUo'
    'AT5iqkUjbEFLHNmhD1YPEvpZ3ghkGlVDCkc94/BmHMq998I5ONiY1ZBfpKAyuOtgAc5yOEDmYEWN'
    'h32BHF91sGHZHmwW4azciN9aQwnz3SJEgOmte+R2tdLprTYoa50mvuomlLpD4Y3oQZnov6D2RzCq'
    'I93bWOHaEmAGqQUyRBlZR1WfarcD/EJ2z8DtzDGvsMCwpm8XOCfDUsVOCYhiqRxI/CTQo4UOvjzO'
    '7Pow18vfywneuUHHUUxLn55lLw5JFpZ8bEUcY8oXdOLWiHLTxvoGpLqoUmy6dBT15o/ox3znpoyc'
    'AmxUsiJTbs1cmxeVKp+0zmFIS7bGWiVghC7Vwse8jFKAX9eljh4ggKLLv7uaQvG9/F59Oo2SouxP'
    'u7OTCxN/s8wAAAAASUVORK5CYII=';

const List<Map<String, dynamic>> _baseTabs = <Map<String, dynamic>>[
  <String, dynamic>{'name': '关注'},
  <String, dynamic>{'name': '推荐'},
  <String, dynamic>{'name': '电影'},
  <String, dynamic>{'name': '科技'},
  <String, dynamic>{'name': '音乐'},
  <String, dynamic>{'name': '美食'},
  <String, dynamic>{'name': '文化'},
  <String, dynamic>{'name': '财经'},
  <String, dynamic>{'name': '手工'},
];

const List<Map<String, dynamic>> _badgeTabs = <Map<String, dynamic>>[
  <String, dynamic>{'name': '关注'},
  <String, dynamic>{
    'name': '推荐',
    'badge': <String, dynamic>{'isDot': true},
  },
  <String, dynamic>{
    'name': '电影',
    'badge': <String, dynamic>{'value': 5},
  },
  <String, dynamic>{'name': '科技'},
];

const List<Map<String, dynamic>> _disabledTabs = <Map<String, dynamic>>[
  <String, dynamic>{'name': '关注'},
  <String, dynamic>{'name': '推荐'},
  <String, dynamic>{'name': '电影', 'disabled': true},
  <String, dynamic>{'name': '科技'},
];

const List<Map<String, dynamic>> _nonScrollableTabs = <Map<String, dynamic>>[
  <String, dynamic>{'name': '关注'},
  <String, dynamic>{'name': '推荐'},
  <String, dynamic>{'name': '电影'},
  <String, dynamic>{'name': '科技'},
];

const List<Map<String, dynamic>> _shapeTabs = <Map<String, dynamic>>[
  <String, dynamic>{'name': '关注'},
  <String, dynamic>{'name': '推荐'},
  <String, dynamic>{'name': '电影'},
];

const List<Map<String, dynamic>> _cardTabs = <Map<String, dynamic>>[
  <String, dynamic>{'name': '账号登录'},
  <String, dynamic>{'name': '免密登录'},
];

const List<Map<String, dynamic>> _pillArrowTabs = <Map<String, dynamic>>[
  <String, dynamic>{'name': '关注'},
  <String, dynamic>{'name': '精选'},
  <String, dynamic>{'name': '热门'},
];

const List<Map<String, dynamic>> _tagTabs = <Map<String, dynamic>>[
  <String, dynamic>{'name': '全部'},
  <String, dynamic>{'name': '待付款'},
  <String, dynamic>{'name': '待发货'},
  <String, dynamic>{'name': '已发货'},
  <String, dynamic>{'name': '已完成'},
  <String, dynamic>{'name': '已关闭'},
];
