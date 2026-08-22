import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../../routes/example_catalog.dart';
import '../shared/example_page_scaffold.dart';

/// Source `getData` seeds three saved addresses.
const List<Map<String, Object>> _siteList = <Map<String, Object>>[
  <String, Object>{
    'id': 1,
    'name': '游X',
    'phone': '183****5523',
    'tag': <Map<String, String>>[
      <String, String>{'tagText': '默认'},
      <String, String>{'tagText': '家'},
    ],
    'site': '广东省深圳市宝安区 自由路66号',
  },
  <String, Object>{
    'id': 2,
    'name': '李XX',
    'phone': '183****5555',
    'tag': <Map<String, String>>[
      <String, String>{'tagText': '公司'},
    ],
    'site': '广东省深圳市宝安区 翻身路xx号',
  },
  <String, Object>{
    'id': 3,
    'name': '王YY',
    'phone': '153****5555',
    'tag': <Map<String, String>>[],
    'site': '广东省深圳市宝安区 平安路13号',
  },
];

/// Port of pages/template/address — the saved-address list.
class AddressPage extends StatelessWidget {
  const AddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: '收货地址',
      child: Container(
        key: const ValueKey('example-page-template/address/index'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (final site in _siteList) _item(tokens, site),
            // Source pins the button to the bottom with `position: absolute`;
            // this page scrolls, so it follows the list instead.
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 30, 40, 15),
              child: GestureDetector(
                key: const ValueKey('address-page-add'),
                onTap: () => pushExampleRoute(
                  context,
                  findExampleRoute('template/address/addSite'),
                ),
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      UPIcon(name: 'plus', color: Colors.white, size: 15),
                      SizedBox(width: 5),
                      Text(
                        '新建收货地址',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(UPThemeTokens tokens, Map<String, Object> site) {
    final tags = site['tag'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              // Flexible: the name, phone and up to two tags overrun a 320px
              // phone. The name is the part that can give way.
              Flexible(
                child: Text(
                  '${site['name']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: tokens.mainColor,
                  ),
                ),
              ),
              // Source's 60rpx gap; it and the phone give way before the row
              // overruns a 320px phone.
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Text(
                    '${site['phone']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: tokens.mainColor,
                    ),
                  ),
                ),
              ),
              if (tags is List)
                for (final tag in tags)
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Container(
                      width: 30,
                      height: 17,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        // Source paints only the 默认 tag red.
                        color: (tag is Map && tag['tagText'] == '默认')
                            ? Colors.red
                            : const Color(0xFF3191FD),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        tag is Map ? '${tag['tagText']}' : '',
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    // Source hardcodes this line rather than reading site.site.
                    '广东省深圳市宝安区 自由路66号',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF999999),
                    ),
                  ),
                ),
                const UPIcon(
                  name: 'edit-pen',
                  size: 20,
                  color: Color(0xFF999999),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
