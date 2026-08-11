import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_page_scaffold.dart';

class ModalPage extends StatefulWidget {
  const ModalPage({super.key});

  @override
  State<ModalPage> createState() => _ModalPageState();
}

class _ModalPageState extends State<ModalPage> {
  static const _content = '模态框，常用于消息提示、消息确认、在当前页面内完成特定的交互操作';

  final List<bool> _shows = List<bool>.filled(10, false);
  int _confirmCount = 0;
  int _cancelCount = 0;
  int _closeCount = 0;
  bool _asyncClosed = false;

  void _open(int index) {
    if (!mounted) return;
    setState(() {
      for (var i = 0; i < _shows.length; i++) {
        _shows[i] = i == index;
      }
    });
  }

  void _setShow(int index, bool show) {
    if (!mounted) return;
    setState(() => _shows[index] = show);
  }

  void _recordConfirm() {
    if (!mounted) return;
    setState(() => _confirmCount += 1);
  }

  void _recordCancel() {
    if (!mounted) return;
    setState(() => _cancelCount += 1);
  }

  void _recordClose() {
    if (!mounted) return;
    setState(() => _closeCount += 1);
  }

  void _confirmAsync() {
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 120), () {
        if (!mounted) return;
        setState(() {
          _shows[3] = false;
          _asyncClosed = true;
        });
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      key: const ValueKey('example-page-componentsC/modal/modal'),
      title: '模态框',
      scrollable: false,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      children: <Widget>[
                        for (var i = 0; i < _modalTitles.length; i++)
                          UPCell(
                            key: ValueKey('modal-page-open-$i'),
                            title: _modalTitles[i],
                            iconSlot: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Image.asset(
                                'assets/uview/common/logo.png',
                                width: 28,
                                height: 28,
                              ),
                            ),
                            isLink: true,
                            clickable: true,
                            onClick: () => _open(i),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text('确认次数：$_confirmCount'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: Text('取消次数：$_cancelCount'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: Text('关闭次数：$_closeCount'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    '异步状态：${_asyncClosed ? '已关闭' : '未关闭'}',
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(child: _basicModal()),
          Positioned.fill(child: _untitledModal()),
          Positioned.fill(child: _cancelModal()),
          Positioned.fill(child: _asyncModal()),
          Positioned.fill(child: _reverseModal()),
          Positioned.fill(child: _overlayModal()),
          Positioned.fill(child: _slotModal()),
          Positioned.fill(child: _customButtonModal()),
          Positioned.fill(child: _noZoomModal()),
          Positioned.fill(child: _bottomCloseModal()),
        ],
      ),
    );
  }

  Widget _basicModal() {
    return UPModal(
      key: const ValueKey('modal-page-basic'),
      show: _shows[0],
      title: '标题',
      content: _content,
      contentTextAlign: 'left',
      onConfirm: _recordConfirm,
      onUpdateShow: (show) => _setShow(0, show),
    );
  }

  Widget _untitledModal() {
    return UPModal(
      key: const ValueKey('modal-page-untitled'),
      show: _shows[1],
      content: _content,
      onUpdateShow: (show) => _setShow(1, show),
    );
  }

  Widget _cancelModal() {
    return UPModal(
      key: const ValueKey('modal-page-cancel'),
      show: _shows[2],
      content: _content,
      showCancelButton: true,
      closeOnClickOverlay: true,
      onConfirm: _recordConfirm,
      onCancel: _recordCancel,
      onClose: _recordClose,
      onUpdateShow: (show) => _setShow(2, show),
    );
  }

  Widget _asyncModal() {
    return UPModal(
      key: const ValueKey('modal-page-async'),
      show: _shows[3],
      content: _content,
      showCancelButton: true,
      asyncClose: true,
      onConfirm: _confirmAsync,
      onCancel: () => _setShow(3, false),
      onUpdateShow: (show) => _setShow(3, show),
    );
  }

  Widget _reverseModal() {
    return UPModal(
      key: const ValueKey('modal-page-reverse'),
      show: _shows[4],
      content: _content,
      showCancelButton: true,
      buttonReverse: true,
      onConfirm: _recordConfirm,
      onCancel: _recordCancel,
      onUpdateShow: (show) => _setShow(4, show),
    );
  }

  Widget _overlayModal() {
    return UPModal(
      key: const ValueKey('modal-page-overlay'),
      show: _shows[5],
      title: '标题',
      content: _content,
      closeOnClickOverlay: true,
      onConfirm: _recordConfirm,
      onClose: _recordClose,
      onUpdateShow: (show) => _setShow(5, show),
    );
  }

  Widget _slotModal() {
    return UPModal(
      key: const ValueKey('modal-page-slot'),
      show: _shows[6],
      title: '利剑出鞘,一统江湖',
      closeOnClickOverlay: true,
      child: Image.asset(
        'assets/uview/common/logo.png',
        width: 80,
        height: 80,
      ),
      onUpdateShow: (show) => _setShow(6, show),
    );
  }

  Widget _customButtonModal() {
    return UPModal(
      key: const ValueKey('modal-page-custom-button'),
      show: _shows[7],
      title: '标题',
      content: _content,
      closeOnClickOverlay: true,
      showCancelButton: true,
      confirmButton: UPButton(
        type: 'success',
        shape: 'circle',
        text: '确定',
        stop: false,
        onClick: () => _setShow(7, false),
      ),
      onUpdateShow: (show) => _setShow(7, show),
    );
  }

  Widget _noZoomModal() {
    return UPModal(
      key: const ValueKey('modal-page-no-zoom'),
      show: _shows[8],
      title: '标题',
      content: _content,
      zoom: false,
      onConfirm: _recordConfirm,
      onUpdateShow: (show) => _setShow(8, show),
    );
  }

  Widget _bottomCloseModal() {
    return UPModal(
      key: const ValueKey('modal-page-bottom-close'),
      show: _shows[9],
      title: '标题',
      content: _content,
      zoom: false,
      popupBottom: GestureDetector(
        onTap: () => _setShow(9, false),
        child: const Padding(
          padding: EdgeInsets.only(top: 20),
          child: CircleAvatar(
            radius: 15,
            backgroundColor: Color(0xff606266),
            child: UPIcon(name: 'close', color: Colors.white, size: 16),
          ),
        ),
      ),
      onUpdateShow: (show) => _setShow(9, show),
    );
  }
}

const List<String> _modalTitles = <String>[
  '基础使用',
  '无标题',
  '带取消按钮',
  '异步关闭',
  '对调取消和确认按钮',
  '允许点击遮罩关闭',
  '传入slot',
  '自定义按钮',
  '淡入淡出动画',
  '带底部关闭按钮',
];
