import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class ReadMorePage extends StatefulWidget {
  const ReadMorePage({super.key});

  @override
  State<ReadMorePage> createState() => _ReadMorePageState();
}

class _ReadMorePageState extends State<ReadMorePage> {
  static const String _content = '''
<p>浔阳江头夜送客，枫叶荻花秋瑟瑟。主人下马客在船，举酒欲饮无管弦。
醉不成欢惨将别，别时茫茫江浸月。忽闻水上琵琶声，主人忘归客不发。
寻声暗问弹者谁，琵琶声停欲语迟。移船相近邀相见，添酒回灯重开宴。
千呼万唤始出来，犹抱琵琶半遮面。转轴拨弦三两声，未成曲调先有情。
弦弦掩抑声声思，似诉平生不得志。低眉信手续续弹，说尽心中无限事。
大弦嘈嘈如急雨，小弦切切如私语。嘈嘈切切错杂弹，大珠小珠落玉盘。
间关莺语花底滑，幽咽泉流冰下难。冰泉冷涩弦凝绝，凝绝不通声暂歇。
别有幽愁暗恨生，此时无声胜有声。银瓶乍破水浆迸，铁骑突出刀枪鸣。
曲终收拨当心画，四弦一声如裂帛。东船西舫悄无言，唯见江心秋月白。
沉吟放拨插弦中，整顿衣裳起敛容。同是天涯沦落人，相逢何必曾相识！
我从去年辞帝京，谪居卧病浔阳城。今夜闻君琵琶语，如听仙乐耳暂明。
莫辞更坐弹一曲，为君翻作《琵琶行》。感我此言良久立，却坐促弦弦转急。
凄凄不似向前声，满座重闻皆掩泣。座中泣下谁最多？江州司马青衫湿。</p>
''';

  final GlobalKey<UPReadMoreState> _readMoreKey = GlobalKey<UPReadMoreState>();
  bool _parseInitialized = false;
  int _openCount = 0;
  int _closeCount = 0;

  void _initReadMore() {
    if (_parseInitialized) return;
    _parseInitialized = true;
    _readMoreKey.currentState?.init();
  }

  @override
  Widget build(BuildContext context) {
    final readMoreState = _readMoreKey.currentState;
    final status = readMoreState?.status ?? 'close';
    return ExamplePageScaffold(
      title: '阅读更多',
      child: Container(
        key: const ValueKey('example-page-componentsC/readMore/readMore'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '基础使用',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: UPReadMore(
                  key: _readMoreKey,
                  showHeight: 200,
                  toggle: true,
                  onOpen: (_) => setState(() => _openCount += 1),
                  onClose: (_) => setState(() => _closeCount += 1),
                  child: UPParse(
                    content: _content,
                    tagStyle: const <String, String>{
                      'p': 'color: #606266; line-height: 24px;',
                    },
                    onLoad: _initReadMore,
                  ),
                ),
              ),
            ),
            Padding(
              key: const ValueKey('read-more-page-status'),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('状态：$status'),
                  Text('展开次数：$_openCount'),
                  Text('收起次数：$_closeCount'),
                ],
              ),
            ),
            const UPGap(height: 40),
          ],
        ),
      ),
    );
  }
}
