import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class TextPage extends StatelessWidget {
  const TextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '文本',
      child: Container(
        key: const ValueKey('example-page-componentsC/text/text'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const _TextBlock(
              title: '基础功能',
              child: UPText(text: '我用十年青春,赴你最后之约'),
            ),
            const _TextBlock(
              title: '设置主题',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  UPText(text: '主色', type: 'primary'),
                  UPText(text: '错误', type: 'error'),
                  UPText(text: '成功', type: 'success'),
                  UPText(text: '警告', type: 'warning'),
                  UPText(text: '信息', type: 'info'),
                  ColoredBox(
                    color: Colors.black,
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: UPText(text: '颜色', size: '30rpx', color: '#fff'),
                    ),
                  ),
                  UPText(text: '颜色', color: '#4557FF', size: '32rpx'),
                ],
              ),
            ),
            const _TextBlock(
              title: '拨打电话',
              child: UPText(mode: 'phone', text: '15019479320'),
            ),
            const _TextBlock(
              title: '日期格式化',
              child: UPText(mode: 'date', text: '1612959739'),
            ),
            const _TextBlock(
              title: '姓名脱敏',
              child: UPText(mode: 'name', text: '张三三', format: 'encrypt'),
            ),
            const _TextBlock(
              title: '超链接',
              child: UPText(
                mode: 'link',
                text: 'Go to uview-plus docs',
                href: 'https://uview-plus.jiangruyi.com',
              ),
            ),
            const _TextBlock(
              title: '显示金额',
              child: UPText(mode: 'price', text: '728732.32'),
            ),
            const _TextBlock(
              title: '前后图标',
              child: Wrap(
                spacing: 20,
                runSpacing: 12,
                children: <Widget>[
                  UPText(
                    prefixIcon: 'baidu',
                    iconStyle: 'font-size: 19px',
                    text: '百度一下',
                  ),
                  UPText(
                    suffixIcon: 'arrow-rightward',
                    iconStyle: 'font-size: 18px',
                    text: '查看更多',
                  ),
                ],
              ),
            ),
            const _TextBlock(
              title: '超出隐藏',
              child: UPText(
                lines: 2,
                text:
                    '关于uview-plus的取名来由，首字母u来自于uni-app首字母，plus参考element-plus起名让大家容易理解这是Vue3版本，uni-app是基于Vue.js，Vue和View(延伸为UI、视图之意)同音，同时view组件uni-app中 最基础，最重要的组件，故取名uview-plus，表达源于uni-app和Vue之意，同时在此也对它们表示感谢。',
              ),
            ),
            _TextBlock(
              title: '小程序开放能力',
              child: UPText(
                text: '分享到微信',
                openType: 'share',
                type: 'success',
                onClick: () => UPToast.show(
                  context,
                  message: '请在微信小程序内查看效果',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  const _TextBlock({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }
}
