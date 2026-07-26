import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

class IconPage extends StatelessWidget {
  const IconPage({super.key});

  static const List<String> _iconNames = <String>[
    'level',
    'woman',
    'man',
    'arrow-left-double',
    'arrow-right-double',
    'chat',
    'chat-fill',
    'red-packet',
    'red-packet-fill',
    'order',
    'checkbox-mark',
    'arrow-up-fill',
    'arrow-down-fill',
    'backspace',
    'photo',
    'photo-fill',
    'lock',
    'lock-fill',
    'lock-open',
    'hourglass',
    'home',
    'home-fill',
    'star',
    'star-fill',
    'share',
    'share-fill',
    'volume',
    'volume-fill',
    'trash',
    'trash-fill',
    'shopping-cart',
    'question-circle',
    'plus-circle',
    'tags',
    'pause-circle',
    'play-circle',
    'map',
    'phone',
    'list',
    'info-circle',
    'minus-circle',
    'mic',
    'grid',
    'eye',
    'file-text',
    'edit-pen',
    'email',
    'download',
    'checkmark-circle',
    'clock',
    'close-circle',
    'calendar',
    'car',
    'bell',
    'bookmark',
    'attach',
    'error-circle',
    'wifi',
    'search',
    'setting',
    'bag',
    'rmb-circle',
    'thumb-up',
    'coupon',
    'scan',
    'warning',
    'camera',
    'heart',
    'reload',
    'account',
    'gift',
  ];

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '图标',
      child: Container(
        key: const ValueKey('example-page-componentsA/icon/icon'),
        padding: const EdgeInsets.all(14),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.05,
          ),
          itemCount: _iconNames.length,
          itemBuilder: (context, index) {
            final name = _iconNames[index];
            return InkWell(
              onTap: () => UPToast.show(context, message: '当前图标：$name'),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 8),
                  UPIcon(name: name, size: 30, color: '#909399'),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF909399)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
