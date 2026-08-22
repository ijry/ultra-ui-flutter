import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

/// Poster painter JSON, copied from the source demo.
const Map<String, Object> _posterConfig = <String, Object>{
  'css': <String, Object>{
    'width': '750rpx',
    'height': '1114rpx',
    'background': 'linear-gradient(135deg,#fce38a,#f38181)',
  },
  'views': <Map<String, Object>>[
    // 背景卡片
    <String, Object>{
      'type': 'view',
      'css': <String, Object>{
        'position': 'absolute',
        'left': '40rpx',
        'top': '144rpx',
        'background': '#fff',
        'radius': '16rpx',
        'width': '670rpx',
        'height': '930rpx',
        'shadow': '0 20rpx 48rpx rgba(0,0,0,.05)',
      },
    },
    // 标题文本
    <String, Object>{
      'type': 'text',
      'text': '为您挑选了一个好物',
      'css': <String, Object>{
        'position': 'absolute',
        'color': '#666',
        'left': '144rpx',
        'top': '90rpx',
        'fontSize': '30rpx',
      },
    },
    // 商品图片
    <String, Object>{
      'type': 'image',
      'src': 'https://uview-plus.jiangruyi.com/uview/swiper/swiper1.png',
      'css': <String, Object>{
        'position': 'absolute',
        'left': '72rpx',
        'top': '176rpx',
        'width': '606rpx',
        'height': '606rpx',
        'radius': '12rpx',
      },
    },
    // 价格
    <String, Object>{
      'type': 'text',
      'text': '￥299',
      'css': <String, Object>{
        'position': 'absolute',
        'color': '#FF0000',
        'left': '66rpx',
        'top': '840rpx',
        'fontSize': '56rpx',
        'fontWeight': 'bold',
      },
    },
    // 商品标题
    <String, Object>{
      'type': 'text',
      'text': '精美陶瓷茶具套装，高端大气上档次，送礼自用两相宜',
      'css': <String, Object>{
        'position': 'absolute',
        'lineClamp': 2,
        'width': '396rpx',
        'color': '#333',
        'left': '72rpx',
        'top': '930rpx',
        'fontSize': '36rpx',
        'lineHeight': '50rpx',
      },
    },
    // 二维码
    <String, Object>{
      'type': 'qrcode',
      'text': 'https://example.com/product/123',
      'css': <String, Object>{
        'position': 'absolute',
        'left': '500rpx',
        'top': '864rpx',
        'width': '178rpx',
        'height': '178rpx',
      },
    },
  ],
};

class PosterPage extends StatefulWidget {
  const PosterPage({super.key});

  @override
  State<PosterPage> createState() => _PosterPageState();
}

class _PosterPageState extends State<PosterPage> {
  final GlobalKey<UPPosterState> _poster = GlobalKey<UPPosterState>();
  String _status = '';

  Future<void> _generatePoster() async {
    setState(() => _status = '海报生成中...');
    final state = _poster.currentState;
    if (state == null) return;
    final result = await state.exportImage();
    if (!mounted) return;
    setState(() {
      // Source toasts success/failure; report the same outcome inline.
      _status = '${result['errMsg']}' == 'ok'
          ? '海报生成成功 '
              '(${result['width']}×${result['height']})'
          : '海报生成失败';
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: '海报',
      child: Container(
        key: const ValueKey('example-page-componentsD/poster/poster'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExampleDemoBlock(
              title: '基础示例',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    UPButton(
                      key: const ValueKey('poster-page-generate'),
                      type: 'primary',
                      shape: 'circle',
                      text: '生成海报',
                      onClick: _generatePoster,
                    ),
                    if (_status.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          _status,
                          style: TextStyle(color: tokens.contentColor),
                        ),
                      ),
                    const SizedBox(height: 20),
                    // The poster renders its own fixed-size canvas; scale it to
                    // fit the page the way the source's preview does.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: UPPoster(
                        key: _poster,
                        json: _posterConfig,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
