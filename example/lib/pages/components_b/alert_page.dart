import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  final List<bool> _closeable = <bool>[true, true];
  int _closeEvents = 0;

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '警告',
      child: Container(
        key: const ValueKey('example-page-componentsB/alert/alert'),
        child: Column(
          children: <Widget>[
            _AlertBlock(
              title: '基础功能',
              children: <Widget>[
                const UPAlert(description: '山不在于高，有了神仙就出名'),
                const UPAlert(description: '水不在深，有龙则灵', type: 'primary'),
                const UPAlert(
                  description: '斯是陋室，惟吾德馨。苔痕上阶绿，草色入帘青',
                  type: 'error',
                ),
                const UPAlert(description: '谈笑有鸿儒，往来无白丁', type: 'info'),
                const UPAlert(description: '可以调素琴，阅金经', type: 'success'),
              ],
            ),
            _AlertBlock(
              title: '深浅色',
              children: <Widget>[
                const UPAlert(
                  description: '无丝竹之乱耳，无案牍之劳形',
                  type: 'warning',
                ),
                const UPAlert(
                  description: '南阳诸葛庐，西蜀子云亭。孔子云：何陋之有',
                  type: 'warning',
                  effect: 'dark',
                ),
              ],
            ),
            _AlertBlock(
              title: '显示图标',
              children: <Widget>[
                const UPAlert(
                  description: '六王毕，四海一；蜀山兀，阿房出',
                  type: 'error',
                  showIcon: true,
                ),
                const UPAlert(
                  description: '覆压三百余里，隔离天日。骊山北构而西折，直走咸阳，二川溶溶，流入宫墙',
                  type: 'error',
                  effect: 'dark',
                  showIcon: true,
                ),
              ],
            ),
            _AlertBlock(
              title: '可关闭',
              footer: Text('关闭事件：$_closeEvents'),
              children: <Widget>[
                if (_closeable[0])
                  UPAlert(
                    description: '五步一楼，十步一阁；廊腰缦回，檐牙高啄；各抱地势，钩心斗角',
                    type: 'success',
                    showIcon: true,
                    closable: true,
                    onClose: () => setState(() => _closeable[0] = false),
                  ),
                if (_closeable[1])
                  UPAlert(
                    key: const ValueKey('alert-page-close-callback'),
                    description: '盘盘焉，囷囷焉，蜂房水涡，矗不知其几千万落',
                    type: 'success',
                    effect: 'dark',
                    closable: true,
                    showIcon: true,
                    onClose: () => setState(() {
                      _closeable[1] = false;
                      _closeEvents++;
                    }),
                  ),
              ],
            ),
            _AlertBlock(
              title: '带标题',
              children: <Widget>[
                const UPAlert(
                  title: '妃嫔媵嫱，王子皇孙，辞楼下殿',
                  description: '长桥卧波，未云何龙？复道行空，不霁何虹',
                  type: 'info',
                  showIcon: true,
                  closable: true,
                ),
                const UPAlert(
                  title: '辇来于秦，朝歌夜弦，为秦宫人。明星荧荧，开妆镜也',
                  description: '高低冥迷，不知西东。歌台暖响，春光融融；舞殿冷袖，风雨凄凄。一日之内，一宫之间，而气候不齐',
                  type: 'info',
                  effect: 'dark',
                  closable: true,
                  showIcon: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertBlock extends StatelessWidget {
  const _AlertBlock({
    required this.title,
    required this.children,
    this.footer,
  });

  final String title;
  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (final child in children)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: child,
              ),
            if (footer != null) footer!,
          ],
        ),
      ),
    );
  }
}
