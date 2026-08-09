import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';
import 'index_list_data.dart';

class IndexList2Page extends StatefulWidget {
  const IndexList2Page({super.key});

  @override
  State<IndexList2Page> createState() => _IndexList2PageState();
}

class _IndexList2PageState extends State<IndexList2Page> {
  bool _show = false;

  Widget _headerItem({
    required String title,
    required String icon,
  }) {
    return Padding(
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
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _headerItem(title: '新的朋友', icon: 'man-add-fill'),
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

  Widget _popupContent() {
    return SizedBox(
      key: const ValueKey('index-list2-page-content'),
      height: 600,
      child: UPIndexList(
        indexList: indexListLetters,
        header: _header(),
        children: _items(),
        footer: _footer(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '索引列表(弹窗)',
      child: Container(
        key: const ValueKey('example-page-componentsC/indexList/indexList2'),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            UPButton(
              key: const ValueKey('index-list2-page-open'),
              type: 'primary',
              size: 'small',
              text: '打开弹窗',
              onClick: () => setState(() => _show = true),
            ),
            UPPopup(
              key: const ValueKey('index-list2-page-popup'),
              show: _show,
              mode: 'bottom',
              safeAreaInsetBottom: false,
              minHeight: 600,
              maxHeight: 600,
              onUpdateShow: (value) => setState(() => _show = value),
              child: _show ? _popupContent() : null,
            ),
          ],
        ),
      ),
    );
  }
}
