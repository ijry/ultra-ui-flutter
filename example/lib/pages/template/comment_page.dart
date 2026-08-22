import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../../routes/example_catalog.dart';
import '../shared/example_page_scaffold.dart';

const String _avatarDog =
    'https://uview-plus.jiangruyi.com/uview/template/SmilingDog.jpg';
const String _avatarNian =
    'https://uview-plus.jiangruyi.com/uview/template/niannian.jpg';

const String _contentText = '我不信伊朗会没有后续反应，美国肯定会为今天的事情付出代价的';
const String _replyUview = 'uview是基于uniapp的一个UI框架，代码优美简洁，宇宙超级无敌彩虹旋转好用，用它！';

/// Source `getComment`. Note the third entry declares `allReply` twice — the
/// later 2 wins in JS, so that is the value used here.
final List<Map<String, Object?>> _commentList = <Map<String, Object?>>[
  <String, Object?>{
    'id': 1,
    'name': '叶轻眉',
    'date': '12-25 18:58',
    'contentText': _contentText,
    'url': _avatarDog,
    'allReply': 12,
    'likeNum': 33,
    'isLike': false,
    'replyList': <Map<String, String>>[
      <String, String>{'name': 'uview', 'contentStr': _replyUview},
      <String, String>{
        'name': '粘粘',
        'contentStr': '今天吃什么，明天吃什么，晚上吃什么，我只是一只小猫咪为什么要烦恼这么多',
      },
    ],
  },
  <String, Object?>{
    'id': 2,
    'name': '叶轻眉1',
    'date': '01-25 13:58',
    'contentText': _contentText,
    'allReply': 0,
    'likeNum': 11,
    'isLike': false,
    'url': _avatarNian,
    'replyList': null,
  },
  <String, Object?>{
    'id': 3,
    'name': '叶轻眉2',
    'date': '03-25 13:58',
    'contentText': _contentText,
    'likeNum': 21,
    'isLike': false,
    'allReply': 2,
    // Source points at its own bundled logo; ours lives under example assets.
    'url': 'assets/uview/common/logo.png',
    'replyList': <Map<String, String>>[
      <String, String>{'name': 'uview', 'contentStr': _replyUview},
      <String, String>{
        'name': '豆包',
        'contentStr': '想吃冰糖葫芦粘豆包，但没钱5555.........',
      },
    ],
  },
  <String, Object?>{
    'id': 4,
    'name': '叶轻眉3',
    'date': '06-20 13:58',
    'contentText': _contentText,
    'url': _avatarDog,
    'allReply': 0,
    'likeNum': 150,
    'isLike': false,
    'replyList': null,
  },
];

/// Port of pages/template/comment — a comment list with likes and replies.
class CommentPage extends StatefulWidget {
  const CommentPage({super.key});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  late final List<Map<String, Object?>> _list =
      _commentList.map((e) => Map<String, Object?>.of(e)).toList();

  /// Source `getLike` toggles the flag and moves the count with it.
  void _getLike(int index) {
    setState(() {
      final item = _list[index];
      final liked = item['isLike'] == true;
      item['isLike'] = !liked;
      final n = item['likeNum'];
      item['likeNum'] = (n is int ? n : 0) + (liked ? -1 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: '评论列表',
      child: Container(
        key: const ValueKey('example-page-template/comment/index'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (var i = 0; i < _list.length; i++)
              _comment(tokens, _list[i], i),
          ],
        ),
      ),
    );
  }

  Widget _comment(UPThemeTokens tokens, Map<String, Object?> item, int index) {
    final liked = item['isLike'] == true;
    final replies = item['replyList'];
    final url = '${item['url']}';
    return Container(
      color: tokens.cardBgColor,
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: url.startsWith('assets/')
                ? Image.asset(url, width: 40, height: 40, fit: BoxFit.cover)
                : UPImage(src: url, width: 40, height: 40, mode: 'aspectFill'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '${item['name']}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: tokens.mainColor),
                      ),
                    ),
                    Text(
                      '${item['likeNum']}',
                      style: TextStyle(
                        fontSize: 13,
                        // Source `.highlight` tints the whole like group.
                        color: liked ? tokens.primary : const Color(0xFF9A9A9A),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      key: ValueKey('comment-page-like-$index'),
                      onTap: () => _getLike(index),
                      child: UPIcon(
                        name: liked ? 'thumb-up-fill' : 'thumb-up',
                        size: 15,
                        color: liked ? tokens.primary : const Color(0xFF9A9A9A),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '${item['contentText']}',
                    style: TextStyle(fontSize: 14, color: tokens.mainColor),
                  ),
                ),
                // Source renders the reply box only when replyList exists.
                if (replies is List)
                  Container(
                    width: double.infinity,
                    color: tokens.bgColor,
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        for (final reply in replies)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  fontSize: 13,
                                  color: tokens.contentColor,
                                ),
                                children: <InlineSpan>[
                                  TextSpan(
                                    text:
                                        reply is Map ? '${reply['name']}：' : '',
                                    style: TextStyle(color: tokens.primary),
                                  ),
                                  TextSpan(
                                    text: reply is Map
                                        ? '${reply['contentStr']}'
                                        : '',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        GestureDetector(
                          key: ValueKey('comment-page-all-reply-$index'),
                          onTap: () => pushExampleRoute(
                            context,
                            findExampleRoute('template/comment/reply'),
                          ),
                          child: Row(
                            children: <Widget>[
                              Text(
                                '共${item['allReply']}条回复',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: tokens.tipsColor,
                                ),
                              ),
                              const UPIcon(name: 'arrow-right', size: 13),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: <Widget>[
                      Text(
                        '${item['date']}',
                        style: TextStyle(fontSize: 12, color: tokens.tipsColor),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        '回复',
                        style: TextStyle(fontSize: 12, color: tokens.tipsColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
