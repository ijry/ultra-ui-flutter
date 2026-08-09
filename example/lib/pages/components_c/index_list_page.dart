import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';
import 'index_list2_page.dart';
import 'index_list_data.dart';

class IndexListPage extends StatelessWidget {
  const IndexListPage({super.key});

  Widget _headerItem({
    required String title,
    required String icon,
    VoidCallback? onTap,
    Key? key,
  }) {
    return GestureDetector(
      key: key,
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: <Widget>[
            UPAvatar(
              shape: 'square',
              size: 35,
              icon: icon,
              fontSize: 26,
              randomBgColor: true,
            ),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _header({VoidCallback? onNewFriend}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _headerItem(
          key: const ValueKey('index-list-page-new-friend'),
          title: '新的朋友',
          icon: 'man-add-fill',
          onTap: onNewFriend,
        ),
        const UPLine(),
        _headerItem(title: '标签', icon: 'tags-fill'),
        const UPLine(),
        _headerItem(title: '朋友圈', icon: 'chrome-circle-fill'),
        const UPLine(),
        _headerItem(title: 'QQ', icon: 'qq-fill'),
        const UPLine(),
      ],
    );
  }

  Widget _contactItem(IndexListContact contact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: <Widget>[
              UPImage(
                src: contact.url,
                width: 35,
                height: 35,
                shape: 'square',
                radius: 3,
                showLoading: false,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  contact.name,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        const UPLine(),
      ],
    );
  }

  List<UPIndexItem> _items() {
    final groups = buildIndexListGroups();
    return <UPIndexItem>[
      for (var i = 0; i < indexListLetters.length; i++)
        UPIndexItem(
          anchor: UPIndexAnchor(text: indexListLetters[i]),
          children: <Widget>[
            for (final contact in groups[i]) _contactItem(contact),
          ],
        ),
    ];
  }

  Widget _footer() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Text(
        '共305位好友',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF909399),
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '索引列表',
      child: Container(
        key: const ValueKey('example-page-componentsC/indexList/indexList'),
        child: SizedBox(
          height: 600,
          child: UPIndexList(
            key: const ValueKey('index-list-page-widget'),
            indexList: indexListLetters,
            header: _header(
              onNewFriend: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const IndexList2Page(),
                  ),
                );
              },
            ),
            children: _items(),
            footer: _footer(),
          ),
        ),
      ),
    );
  }
}
