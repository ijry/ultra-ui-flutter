import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

/// Demonstrates the global toast/notify host.
///
/// The point of this component is that `UPRootToastRegistry` works from
/// anywhere once a host is mounted — no toast or notify widget is placed on this
/// page. In a real app the host wraps the whole app once; here it wraps just
/// this page so the demo is self-contained.
class RootToastHostPage extends StatefulWidget {
  const RootToastHostPage({super.key});

  @override
  State<RootToastHostPage> createState() => _RootToastHostPageState();
}

class _RootToastHostPageState extends State<RootToastHostPage> {
  String _lastResult = '未调用';

  void _record(String label, bool handled) {
    if (!mounted) return;
    // A false result means no host was mounted, which is the source's
    // typeof-guard behavior rather than an error.
    setState(() => _lastResult = '$label -> ${handled ? '已处理' : '无宿主'}');
  }

  @override
  Widget build(BuildContext context) {
    return UPRootToastHost(
      child: ExamplePageScaffold(
        title: '全局提示宿主',
        child: Container(
          key: const ValueKey(
              'example-page-componentsD/rootToastHost/rootToastHost'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ExampleDemoBlock(
                title: '全局 toast（页面内无 UPToast）',
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      UPButton(
                        key: const ValueKey('root-toast-host-page-toast'),
                        text: '弹出 toast',
                        type: 'primary',
                        onClick: () => _record(
                          'toast',
                          UPRootToastRegistry.toast(message: '来自全局宿主'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      UPButton(
                        key: const ValueKey('root-toast-host-page-toast-icon'),
                        text: '成功 toast',
                        onClick: () => _record(
                          'toast(success)',
                          UPRootToastRegistry.toast(
                            message: '操作成功',
                            type: 'success',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ExampleDemoBlock(
                title: '全局 notify（页面内无 UPNotify）',
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      UPButton(
                        key: const ValueKey('root-toast-host-page-notify'),
                        text: '顶部通知',
                        onClick: () => _record(
                          'notify',
                          UPRootToastRegistry.notify(
                            message: '这是一条全局通知',
                            type: 'warning',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      UPButton(
                        key: const ValueKey('root-toast-host-page-close'),
                        text: '关闭通知',
                        onClick: () => _record(
                          'closeNotify',
                          UPRootToastRegistry.closeNotify(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                key: const ValueKey('root-toast-host-page-result'),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('最近调用：$_lastResult'),
                    const SizedBox(height: 8),
                    Text('toast 宿主已挂载：'
                        '${UPRootToastRegistry.hasToastRef ? '是' : '否'}'),
                    Text('notify 宿主已挂载：'
                        '${UPRootToastRegistry.hasNotifyRef ? '是' : '否'}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
