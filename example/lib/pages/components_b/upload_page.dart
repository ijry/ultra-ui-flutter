import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  List<Map<String, dynamic>> _fileList1 = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _fileList2 = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _fileList3 = <Map<String, dynamic>>[
    {'url': 'assets/uview/swiper/swiper1.png', 'status': 'success'},
  ];
  List<Map<String, dynamic>> _fileList4 = <Map<String, dynamic>>[
    {'url': 'assets/uview/swiper/swiper1.png', 'status': 'success'},
    {'url': 'assets/uview/swiper/swiper1.png', 'status': 'success'},
  ];
  List<Map<String, dynamic>> _fileList5 = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _fileList6 = <Map<String, dynamic>>[];

  Future<dynamic> _pickFile(String name, String accept) async {
    if (accept == 'video') {
      return <String, dynamic>{
        'url': 'local-demo-video.mp4',
        'name': 'local-demo-video.mp4',
        'type': 'video',
      };
    }
    return <String, dynamic>{
      'url': 'assets/uview/swiper/swiper1.png',
      'name': 'swiper1.png',
      'type': 'image',
    };
  }

  Future<dynamic> _beforeRead(dynamic file, Map detail) async {
    return file;
  }

  void _setFileList(String name, List source) {
    final next = <Map<String, dynamic>>[
      for (final item in source)
        if (item is Map)
          Map<String, dynamic>.from(item)
        else
          <String, dynamic>{'url': '$item', 'status': 'success'},
    ];
    setState(() {
      switch (name) {
        case '1':
          _fileList1 = next;
          break;
        case '2':
          _fileList2 = next;
          break;
        case '3':
          _fileList3 = next;
          break;
        case '4':
          _fileList4 = next;
          break;
        case '5':
          _fileList5 = next;
          break;
        case '6':
          _fileList6 = next;
          break;
      }
    });
  }

  void _deleteFile(String name, int index) {
    setState(() {
      final target = switch (name) {
        '1' => _fileList1,
        '2' => _fileList2,
        '3' => _fileList3,
        '4' => _fileList4,
        '5' => _fileList5,
        '6' => _fileList6,
        _ => null,
      };
      if (target != null && index >= 0 && index < target.length) {
        target.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '上传',
      child: Container(
        key: const ValueKey('example-page-componentsB/upload/upload'),
        child: Column(
          children: <Widget>[
            _UploadBlock(
              title: '基础用法',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  UPUpload(
                    key: const ValueKey('upload-page-basic'),
                    fileList: _fileList1,
                    useBeforeRead: true,
                    name: '1',
                    multiple: true,
                    maxCount: 10,
                    autoUpload: true,
                    picker: () => _pickFile('1', 'image'),
                    onBeforeRead: _beforeRead,
                    onDelete: (index, item) => _deleteFile('1', index),
                    onUpdateFileList: (list) => _setFileList('1', list),
                  ),
                  const SizedBox(height: 8),
                  Text('基础用法：${_fileList1.length}'),
                ],
              ),
            ),
            _UploadBlock(
              title: '上传视频',
              child: UPUpload(
                fileList: _fileList2,
                name: '2',
                multiple: true,
                maxCount: 10,
                accept: 'video',
                autoUpload: true,
                picker: () => _pickFile('2', 'video'),
                onDelete: (index, item) => _deleteFile('2', index),
                onUpdateFileList: (list) => _setFileList('2', list),
              ),
            ),
            _UploadBlock(
              title: '文件预览',
              child: UPUpload(
                fileList: _fileList3,
                name: '3',
                multiple: true,
                maxCount: 10,
                previewFullImage: true,
                autoUpload: true,
                picker: () => _pickFile('3', 'image'),
                onDelete: (index, item) => _deleteFile('3', index),
                onUpdateFileList: (list) => _setFileList('3', list),
              ),
            ),
            _UploadBlock(
              title: '隐藏上传按钮',
              child: UPUpload(
                fileList: _fileList4,
                name: '4',
                multiple: true,
                maxCount: 2,
                autoUpload: true,
                picker: () => _pickFile('4', 'image'),
                onDelete: (index, item) => _deleteFile('4', index),
                onUpdateFileList: (list) => _setFileList('4', list),
              ),
            ),
            _UploadBlock(
              title: '限制上传数量',
              child: UPUpload(
                fileList: _fileList5,
                name: '5',
                multiple: true,
                maxCount: 3,
                autoUpload: true,
                picker: () => _pickFile('5', 'image'),
                onDelete: (index, item) => _deleteFile('5', index),
                onUpdateFileList: (list) => _setFileList('5', list),
              ),
            ),
            _UploadBlock(
              title: '自定义上传样式',
              child: UPUpload(
                fileList: _fileList6,
                name: '6',
                multiple: true,
                maxCount: 1,
                width: 250,
                height: 150,
                autoUpload: true,
                picker: () => _pickFile('6', 'image'),
                trigger: Image.asset(
                  'assets/uview/demo/upload/positive.png',
                  width: 250,
                  height: 150,
                  fit: BoxFit.cover,
                ),
                onDelete: (index, item) => _deleteFile('6', index),
                onUpdateFileList: (list) => _setFileList('6', list),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadBlock extends StatelessWidget {
  const _UploadBlock({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExampleDemoBlock(
      title: title,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}
