import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

const String _avatar =
    'https://uview-plus.jiangruyi.com/uview/template/SmilingDog.jpg';
const String _contentText = '我不信伊朗会没有后续反应，美国肯定会为今天的事情付出代价的';

/// Source `comment` — the post being replied to. Note it spells the like flag
/// `isLikes`, so the template's `comment.isLike` is always undefined and the
/// header heart never lights up; that quirk is reproduced by starting false and
/// letting the tap toggle a real flag.
final Map<String, Object?> _comment = <String, Object?>{
  'id': 1,
  'name': '叶轻眉',
  'date': '12-25 18:58',
  'contentText': _contentText,
  'url': _avatar,
  'allReply': 12,
  'likeNum': 33,
  'isLike': false,
};

/// Source `commentList`. The third entry declares `allReply` twice; the later 2
/// wins in JS, and neither value is rendered on this page anyway.
final List<Map<String, Object?>> _replyList = <Map<String, Object?>>[
  <String, Object?>{
    'name': '新八几',
    'date': '12-25 18:58',
    'contentText': '不要乱打广告啊喂！虽然是真的超好用',
    'url': _avatar,
    'likeNum': 33,
    'isLike': false,
    'reply': <String, String>{
      'name': 'uview',
      'contentStr': 'uview是基于uniapp的一个UI框架，代码优美简洁，宇宙超级无敌彩虹旋转好用，用它！',
    },
  },
  <String, Object?>{
    'name': '叶轻眉1',
    'date': '01-25 13:58',
    'url': _avatar,
    'contentText': _contentText,
    'likeNum': 11,
    'isLike': false,
    'reply': <String, String>{
      'name': '粘粘',
      'contentStr': '今天吃什么，明天吃什么，晚上吃什么，我只是一只小猫咪为什么要烦恼这么多',
    },
  },
  <String, Object?>{
    'name': '叶轻眉2',
    'date': '03-25 13:58',
    'contentText': _contentText,
    'likeNum': 21,
    'url': _avatar,
    'isLike': false,
    'reply': <String, String>{
      'name': '豆包',
      'contentStr': '想吃冰糖葫芦粘豆包，但没钱5555.........',
    },
  },
  <String, Object?>{
    'name': '叶轻眉3',
    'date': '06-20 13:58',
    'contentText': _contentText,
    'likeNum': 150,
    'url': _avatar,
    'isLike': false,
    'reply': null,
  },
];

/// Port of pages/template/comment/reply — one comment and all its replies.
class CommentReplyPage extends StatefulWidget {
  const CommentReplyPage({super.key});

  @override
  State<CommentReplyPage> createState() => _CommentReplyPageState();
}

class _CommentReplyPageState extends State<CommentReplyPage> {
  late final Map<String, Object?> _head = Map<String, Object?>.of(_comment);
  late final List<Map<String, Object?>> _list =
      _replyList.map((e) => Map<String, Object?>.of(e)).toList();

  /// Source `getLike(index)` branches on whether an index was passed: with one
  /// it toggles that reply, without one it toggles the header comment.
  void _getLike([int? index]) {
    setState(() {
      final item = index == null ? _head : _list[index];
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
      title: '全部回复',
      child: Container(
        key: const ValueKey('example-page-template/comment/reply'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              color: tokens.cardBgColor,
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _header(tokens, _head, onLike: () => _getLike()),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${_head['contentText']}',
                      style: TextStyle(fontSize: 14, color: tokens.mainColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              color: tokens.cardBgColor,
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '全部回复（${_head['allReply']}）',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: tokens.mainColor,
                    ),
                  ),
                  for (var i = 0; i < _list.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _header(
                            tokens,
                            _list[i],
                            onLike: () => _getLike(i),
                            likeKey: ValueKey('comment-reply-page-like-$i'),
                          ),
                          // Source shows the quoted reply above the body.
                          if (_list[i]['reply'] case final Map reply)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, bottom: 4),
                              child: Text.rich(
                                TextSpan(
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: tokens.contentColor,
                                  ),
                                  children: <InlineSpan>[
                                    TextSpan(
                                      text: '${reply['name']}：',
                                      style: TextStyle(color: tokens.primary),
                                    ),
                                    TextSpan(text: '${reply['contentStr']}'),
                                  ],
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${_list[i]['contentText']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: tokens.mainColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Avatar + name/date on the left, like count and heart on the right.
  Widget _header(
    UPThemeTokens tokens,
    Map<String, Object?> item, {
    required VoidCallback onLike,
    Key? likeKey,
  }) {
    final liked = item['isLike'] == true;
    return Row(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: UPImage(
            src: '${item['url']}',
            width: 36,
            height: 36,
            mode: 'aspectFill',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${item['name']}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: tokens.mainColor),
              ),
              Text(
                '${item['date']}',
                style: TextStyle(fontSize: 12, color: tokens.tipsColor),
              ),
            ],
          ),
        ),
        Text(
          '${item['likeNum']}',
          style: TextStyle(
            fontSize: 13,
            color: liked ? tokens.primary : const Color(0xFF9A9A9A),
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          key: likeKey,
          onTap: onLike,
          child: UPIcon(
            name: liked ? 'thumb-up-fill' : 'thumb-up',
            size: 15,
            color: liked ? tokens.primary : const Color(0xFF9A9A9A),
          ),
        ),
      ],
    );
  }
}
