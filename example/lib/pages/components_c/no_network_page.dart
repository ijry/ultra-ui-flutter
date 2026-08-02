import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

class NoNetworkPage extends StatefulWidget {
  const NoNetworkPage({super.key});

  @override
  State<NoNetworkPage> createState() => _NoNetworkPageState();
}

class _NoNetworkPageState extends State<NoNetworkPage> {
  final GlobalKey<UPNoNetworkState> _networkKey = GlobalKey<UPNoNetworkState>();
  int _disconnectedCount = 0;
  int _connectedCount = 0;
  int _retryCount = 0;
  bool _offline = false;

  void _showOffline() {
    setState(() => _offline = true);
    _networkKey.currentState?.show();
  }

  void _restoreNetwork() {
    _networkKey.currentState?.hide();
    setState(() => _offline = false);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    return ExamplePageScaffold(
      title: '无网络提示',
      scrollable: false,
      child: Stack(
        children: <Widget>[
          Container(
            key: const ValueKey('example-page-componentsC/noNetwork/noNetwork'),
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(32, 110, 32, 24),
            child: Column(
              children: <Widget>[
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: tokens.success,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  alignment: Alignment.center,
                  child: const UPIcon(
                    name: 'checkbox-mark',
                    color: '#ffffff',
                    size: 30,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  '网络正常',
                  style: TextStyle(color: tokens.success, fontSize: 15),
                ),
                const SizedBox(height: 15),
                Text(
                  '请您断开设备的WiFi和数据连接(或开启飞行模式)，即可看到效果',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: tokens.tipsColor, fontSize: 13),
                ),
                const SizedBox(height: 24),
                UPButton(
                  text: '模拟断网',
                  type: 'primary',
                  size: 'small',
                  onClick: _showOffline,
                ),
                const SizedBox(height: 12),
                Text('断开：$_disconnectedCount'),
                Text('连接：$_connectedCount'),
                Text('重试：$_retryCount'),
              ],
            ),
          ),
          UPNoNetwork(
            key: _networkKey,
            show: false,
            onDisconnected: () {
              if (mounted) {
                setState(() => _disconnectedCount++);
              }
            },
            onConnected: () {
              if (mounted) {
                setState(() => _connectedCount++);
              }
            },
            onRetry: () {
              if (mounted) {
                setState(() => _retryCount++);
              }
            },
          ),
          if (_offline)
            Positioned(
              left: 0,
              right: 0,
              bottom: 30,
              child: Center(
                child: UPButton(
                  text: '恢复网络',
                  type: 'success',
                  size: 'small',
                  onClick: _restoreNetwork,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
