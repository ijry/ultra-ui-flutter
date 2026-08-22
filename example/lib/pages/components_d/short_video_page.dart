import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

const List<Map<String, Object>> _tabsList = <Map<String, Object>>[
  <String, Object>{'name': '推荐'},
  <String, Object>{'name': '关注'},
  <String, Object>{'name': '朋友'},
  <String, Object>{'name': '本地'},
];

class ShortVideoPage extends StatefulWidget {
  const ShortVideoPage({super.key});

  @override
  State<ShortVideoPage> createState() => _ShortVideoPageState();
}

class _ShortVideoPageState extends State<ShortVideoPage> {
  int _currentTab = 0;
  int _currentVideo = 0;
  String _lastAction = '';

  late final List<Map<String, Object>> _videoList = <Map<String, Object>>[
    <String, Object>{
      'videoUrl': 'https://uview-plus.jiangruyi.com/big/rjtsdl.MP4',
      'progress': 0,
      'bgColor': '#000',
      'author': <String, Object>{
        'avatar': '/static/avatar1.jpg',
        'name': '创作者1',
        'desc': '这是一段视频描述',
      },
      'isLiked': false,
      'likeCount': 128,
      'commentCount': 25,
      'shareCount': 12,
      'collectCount': 8,
      'isCollected': false,
    },
    <String, Object>{
      'videoUrl': 'https://uview-plus.jiangruyi.com/big/shanghai.mp4',
      'progress': 0,
      'bgColor': '#000',
      'author': <String, Object>{
        'avatar': '/static/avatar2.jpg',
        'name': '创作者2',
        'desc': '记录美好生活',
      },
      'isLiked': true,
      'likeCount': 863,
      'commentCount': 96,
      'shareCount': 32,
      'collectCount': 45,
      'isCollected': true,
    },
    <String, Object>{
      'videoUrl': 'https://uview-plus.jiangruyi.com/big/shanghai.mp4',
      'progress': 0,
      'bgColor': '#000',
      'author': <String, Object>{
        'avatar': '/static/avatar3.jpg',
        'name': '创作者3',
        'desc': '生活需要仪式感',
      },
      'isLiked': false,
      'likeCount': 562,
      'commentCount': 47,
      'shareCount': 21,
      'collectCount': 19,
      'isCollected': false,
    },
  ];

  void _toggleLike(int index) {
    if (index < 0 || index >= _videoList.length) return;
    setState(() {
      final item = _videoList[index];
      final liked = item['isLiked'] == true;
      item['isLiked'] = !liked;
      final count = item['likeCount'];
      item['likeCount'] = (count is int ? count : 0) + (liked ? -1 : 1);
      _lastAction = liked ? '取消点赞' : '点赞';
    });
  }

  void _toggleCollect(int index) {
    if (index < 0 || index >= _videoList.length) return;
    setState(() {
      final item = _videoList[index];
      final collected = item['isCollected'] == true;
      item['isCollected'] = !collected;
      final count = item['collectCount'];
      item['collectCount'] = (count is int ? count : 0) + (collected ? -1 : 1);
      _lastAction = collected ? '取消收藏' : '收藏';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '短视频',
      // The player fills its viewport; a scroll view would give it unbounded
      // height, so this page opts out like the source's full-screen page does.
      scrollable: false,
      child: Container(
        key: const ValueKey('example-page-componentsD/shortVideo/shortVideo'),
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: UPShortVideo(
                key: const ValueKey('short-video-page-player'),
                tabsList: _tabsList,
                videoList: _videoList,
                currentTab: _currentTab,
                currentVideo: _currentVideo,
                onTabChange: (index) => setState(() => _currentTab = index),
                onVideoChange: (index) => setState(() => _currentVideo = index),
                onLike: (item, index) => _toggleLike(index),
                onCollect: (item, index) => _toggleCollect(index),
                onComment: (item, index) =>
                    setState(() => _lastAction = '评论功能'),
                onShare: (item, index) => setState(() => _lastAction = '分享功能'),
                // Source overrides the menu and search slots with plain icons.
                menuSlot: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: UPIcon(
                        name: 'grid', size: 22, color: Color(0xFFDDDDDD)),
                  ),
                ),
                searchSlot: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: UPIcon(
                        name: 'search', size: 22, color: Color(0xFFDDDDDD)),
                  ),
                ),
                // Source replaces the whole action column via the actions slot.
                actionsBuilder: (context, item, index) {
                  final map = item is Map ? item : const <String, Object>{};
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _action(
                        map['isLiked'] == true ? 'thumb-up-fill' : 'thumb-up',
                        '${map['likeCount'] ?? 0}',
                        () => _toggleLike(index),
                      ),
                      _action(
                        'chat',
                        '${map['commentCount'] ?? 0}',
                        () => setState(() => _lastAction = '评论功能'),
                      ),
                      _action(
                        'share',
                        '${map['shareCount'] ?? 0}',
                        () => setState(() => _lastAction = '分享功能'),
                      ),
                      _action(
                        map['isCollected'] == true ? 'star-fill' : 'star',
                        '${map['collectCount'] ?? 0}',
                        () => _toggleCollect(index),
                      ),
                    ],
                  );
                },
              ),
            ),
            if (_lastAction.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '最近操作：$_lastAction',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Source action item: icon above a count, stacked with a 20px gap.
  Widget _action(String icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            UPIcon(name: icon, size: 32, color: const Color(0xFFEEEEEE)),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
