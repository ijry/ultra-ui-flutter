import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

class Table2Page extends StatefulWidget {
  const Table2Page({super.key});

  @override
  State<Table2Page> createState() => _Table2PageState();
}

class _Table2PageState extends State<Table2Page> {
  static const List<Map<String, dynamic>> _tableData = <Map<String, dynamic>>[
    <String, dynamic>{'id': 1, 'name': '张三', 'age': 25},
    <String, dynamic>{'id': 2, 'name': '李四', 'age': 30},
  ];

  static const List<Map<String, dynamic>> _fixedData = <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 1,
      'name': '张三',
      'age': 25,
      'age2': 25,
      'age3': 25,
      'age4': 25,
      'age5': 25,
      'age6': 25,
      'age7': 25,
      'age8': 25,
      'age9': 25,
      'age10': 25,
      'age11': 25,
    },
    <String, dynamic>{
      'id': 2,
      'name': '李四',
      'age': 25,
      'age2': 25,
      'age3': 25,
      'age4': 25,
      'age5': 25,
      'age6': 25,
      'age7': 25,
      'age8': 25,
      'age9': 25,
      'age10': 25,
      'age11': 25,
    },
  ];

  static const List<Map<String, dynamic>> _treeData = <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 1,
      'name': '部门A',
      'age': 25,
      'age2': 25,
      'actions': '编辑',
      'children': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 2,
          'name': '员工1',
          'age': 22,
          'age2': 25,
          'actions': '编辑',
          'children': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 22,
              'name': '员工22',
              'age': 22,
              'age2': 25,
              'actions': '编辑',
            },
            <String, dynamic>{
              'id': 32,
              'name': '员工32',
              'age': 24,
              'age2': 25,
              'actions': '编辑',
            },
          ],
        },
        <String, dynamic>{
          'id': 3,
          'name': '员工2',
          'age': 24,
          'age2': 25,
          'actions': '编辑',
        },
      ],
    },
    <String, dynamic>{
      'id': 4,
      'name': '部门B',
      'age': 30,
      'age2': 30,
      'actions': '编辑',
    },
  ];

  static const List<Map<String, dynamic>> _spanData = <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 1,
      'name': '张三',
      'age': 25,
      'address': '北京市朝阳区',
      'department': '技术部',
    },
    <String, dynamic>{
      'id': 2,
      'name': '李四',
      'age': 30,
      'address': '北京市朝阳区',
      'department': '技术部',
    },
    <String, dynamic>{
      'id': 3,
      'name': '王五',
      'age': 28,
      'address': '上海市浦东新区',
      'department': '销售部',
    },
    <String, dynamic>{
      'id': 4,
      'name': '赵六',
      'age': 35,
      'address': '广州市天河区',
      'department': '人事部',
    },
  ];

  static const List<Map<String, dynamic>> _baseColumns = <Map<String, dynamic>>[
    <String, dynamic>{
      'title': '姓名',
      'key': 'name',
      'width': '70px',
      'align': 'center',
    },
    <String, dynamic>{
      'title': '年龄',
      'key': 'age',
      'width': '70px',
      'align': 'right',
      'headerAlign': 'center',
    },
  ];

  static const List<Map<String, dynamic>> _styleColumns =
      <Map<String, dynamic>>[
    <String, dynamic>{'title': '姓名', 'key': 'name', 'width': '70px'},
    <String, dynamic>{'title': '年龄', 'key': 'age', 'width': '70px'},
  ];

  static const List<Map<String, dynamic>> _selectionColumns =
      <Map<String, dynamic>>[
    <String, dynamic>{'type': 'selection', 'width': '50px'},
    <String, dynamic>{'title': '姓名', 'key': 'name', 'width': '80px'},
    <String, dynamic>{'title': '年龄', 'key': 'age', 'width': '70px'},
  ];

  static const List<Map<String, dynamic>> _sortColumns = <Map<String, dynamic>>[
    <String, dynamic>{'title': '姓名', 'key': 'name', 'sortable': true},
    <String, dynamic>{'title': '年龄', 'key': 'age', 'sortable': true},
  ];

  static const List<Map<String, dynamic>> _fixedColumns =
      <Map<String, dynamic>>[
    <String, dynamic>{'title': '名称', 'key': 'name', 'width': '60px'},
    <String, dynamic>{
      'title': '年龄',
      'key': 'age',
      'width': '60px',
      'fixed': 'left',
    },
    <String, dynamic>{'title': '年龄2', 'key': 'age2', 'width': '60px'},
    <String, dynamic>{'title': '年龄3', 'key': 'age3', 'width': '60px'},
    <String, dynamic>{
      'title': '年龄4',
      'key': 'age4',
      'width': '60px',
      'fixed': 'left',
    },
    <String, dynamic>{'title': '年龄5', 'key': 'age5', 'width': '60px'},
    <String, dynamic>{'title': '年龄6', 'key': 'age6', 'width': '60px'},
    <String, dynamic>{'title': '年龄7', 'key': 'age7', 'width': '60px'},
    <String, dynamic>{'title': '年龄8', 'key': 'age8', 'width': '60px'},
    <String, dynamic>{'title': '年龄9', 'key': 'age9', 'width': '60px'},
    <String, dynamic>{'title': '年龄10', 'key': 'age10', 'width': '66px'},
    <String, dynamic>{'title': '年龄11', 'key': 'age11', 'width': '66px'},
  ];

  static const List<Map<String, dynamic>> _treeColumns = <Map<String, dynamic>>[
    <String, dynamic>{'type': 'selection', 'width': '50px'},
    <String, dynamic>{
      'title': '名称',
      'key': 'name',
      'width': '150px',
      'fixed': 'left',
    },
    <String, dynamic>{'title': '年龄', 'key': 'age', 'width': '80px'},
    <String, dynamic>{'title': '年龄', 'key': 'age2', 'width': '80px'},
    <String, dynamic>{'title': '操作', 'key': 'actions', 'width': '150px'},
  ];

  static const List<Map<String, dynamic>> _spanColumns = <Map<String, dynamic>>[
    <String, dynamic>{'title': 'ID', 'key': 'id', 'width': '50px'},
    <String, dynamic>{'title': '姓名', 'key': 'name', 'width': '100px'},
    <String, dynamic>{'title': '年龄', 'key': 'age', 'width': '100px'},
    <String, dynamic>{'title': '地址', 'key': 'address', 'width': '150px'},
    <String, dynamic>{'title': '部门', 'key': 'department', 'width': '100px'},
  ];

  dynamic _currentRowId;
  String _rowClickText = '行点击：未选择';
  int _selectionCount = 0;
  String _sortText = '排序：未排序';
  String _expandText = '展开：1';
  bool _popupShow = false;
  String _popupSelectionText = '弹窗选择：未选择';

  void _handleRowClick(Map row) {
    setState(() {
      _currentRowId = row['id'];
      _rowClickText = '行点击：${row['name']}';
    });
  }

  void _handleSelectionChange(List selection) {
    setState(() => _selectionCount = selection.length);
  }

  void _handleSortChange(List conditions) {
    setState(() {
      if (conditions.isEmpty) {
        _sortText = '排序：未排序';
        return;
      }
      final condition = Map<dynamic, dynamic>.from(conditions.first as Map);
      _sortText = '排序：${condition['field']} ${condition['order']}';
    });
  }

  void _handleExpandChange(List keys) {
    setState(() {
      _expandText = '展开：${keys.map((key) => '$key').join(',')}';
    });
  }

  void _openPopup() => setState(() => _popupShow = true);

  void _handlePopupRowClick(Map row) {
    setState(() {
      _popupSelectionText = '弹窗选择：${row['name']}';
      _popupShow = false;
    });
    UPToast.show(
      context,
      message: '选中: ${row['name']}',
      duration: 800,
    );
  }

  List<int> _arraySpanMethod(Map scope) {
    final rowIndex = int.tryParse('${scope['rowIndex']}') ?? 0;
    final columnIndex = int.tryParse('${scope['columnIndex']}') ?? 0;
    if (rowIndex == 0 && columnIndex == 1) return <int>[1, 2];
    if (rowIndex == 0 && columnIndex == 2) return <int>[0, 0];
    if (rowIndex == 0 && columnIndex == 3) return <int>[2, 1];
    if (rowIndex == 1 && columnIndex == 3) return <int>[0, 0];
    if (rowIndex == 0 && columnIndex == 4) return <int>[2, 1];
    if (rowIndex == 1 && columnIndex == 4) return <int>[0, 0];
    return <int>[1, 1];
  }

  Map<String, dynamic> _cellStyle(Map scope) {
    final column = Map<dynamic, dynamic>.from(scope['column'] as Map);
    final row = Map<dynamic, dynamic>.from(scope['row'] as Map);
    if (column['key'] == 'age' && row['age'] == 25) {
      return <String, dynamic>{
        'backgroundColor': '#2979ff',
        'color': '#ffffff',
      };
    }
    return <String, dynamic>{};
  }

  Widget _buildPopupLayer() {
    return UPPopup(
      show: _popupShow,
      mode: 'bottom',
      round: 10,
      closeable: true,
      onUpdateShow: (value) {
        if (!value) setState(() => _popupShow = false);
      },
      child: _popupShow
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: KeyedSubtree(
                key: const ValueKey('table2-page-popup-table'),
                child: UPTable2(
                  data: _tableData,
                  columns: _baseColumns,
                  stripe: true,
                  border: true,
                  height: '300px',
                  onRowClick: _handlePopupRowClick,
                  onCellClick: (row, column, rowIndex, columnIndex) {
                    _handlePopupRowClick(row);
                  },
                ),
              ))
          : const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: '表格2',
      scrollable: false,
      child: SizedBox.expand(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: <Widget>[
                  Container(
                    key: const ValueKey(
                        'example-page-componentsB/table2/table2'),
                    child: Column(
                      children: <Widget>[
                        _Table2Block(
                          key: const ValueKey('table2-page-basic'),
                          title: '基础表格（斑马纹 + 边框）',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              UPTable2(
                                data: _tableData,
                                columns: _baseColumns,
                                stripe: true,
                                border: true,
                                onRowClick: _handleRowClick,
                                onCellClick:
                                    (row, column, rowIndex, columnIndex) {
                                  _handleRowClick(row);
                                },
                              ),
                              const SizedBox(height: 8),
                              Text(_rowClickText),
                            ],
                          ),
                        ),
                        _Table2Block(
                          title: '表格样式自定义',
                          child: UPTable2(
                            data: _tableData,
                            columns: _styleColumns,
                            stripe: true,
                            cellStyle: _cellStyle,
                            onRowClick: _handleRowClick,
                            onCellClick: (row, column, rowIndex, columnIndex) {
                              _handleRowClick(row);
                            },
                          ),
                        ),
                        _Table2Block(
                          title: '支持单选的表格',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              UPTable2(
                                data: _tableData,
                                columns: _baseColumns,
                                highlightCurrentRow: true,
                                currentRowKey: _currentRowId,
                                onRowClick: _handleRowClick,
                                onCellClick:
                                    (row, column, rowIndex, columnIndex) {
                                  _handleRowClick(row);
                                },
                              ),
                              const SizedBox(height: 8),
                              Text(_rowClickText),
                            ],
                          ),
                        ),
                        _Table2Block(
                          key: const ValueKey('table2-page-selection'),
                          title: '支持复选框的表格',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              UPTable2(
                                data: _tableData,
                                columns: _selectionColumns,
                                rowKey: 'id',
                                onSelectionChange: _handleSelectionChange,
                              ),
                              const SizedBox(height: 8),
                              Text('选择数量：$_selectionCount'),
                            ],
                          ),
                        ),
                        _Table2Block(
                          key: const ValueKey('table2-page-sort'),
                          title: '支持排序与筛选',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              UPTable2(
                                data: _tableData,
                                columns: _sortColumns,
                                sortable: true,
                                multiSort: true,
                                filters: const <String, dynamic>{'name': '张'},
                                onSortChange: _handleSortChange,
                              ),
                              const SizedBox(height: 8),
                              Text(_sortText),
                            ],
                          ),
                        ),
                        const _Table2Block(
                          title: '列固定',
                          child: UPTable2(
                            data: _fixedData,
                            columns: _fixedColumns,
                            border: true,
                          ),
                        ),
                        _Table2Block(
                          key: const ValueKey('table2-page-tree'),
                          title: '树形结构',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              UPTable2(
                                data: _treeData,
                                columns: _treeColumns,
                                treeProps: const <String, dynamic>{
                                  'children': 'children'
                                },
                                expandRowKeys: const <int>[1],
                                mainCol: 'name',
                                onExpandChange: _handleExpandChange,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: <Widget>[
                                  Text(_expandText),
                                  const SizedBox(width: 12),
                                  const UPTag(
                                    type: 'primary',
                                    size: 'mini',
                                    text: '编辑',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _Table2Block(
                          key: const ValueKey('table2-page-span'),
                          title: '单元格合并',
                          child: UPTable2(
                            data: _spanData,
                            columns: _spanColumns,
                            spanMethod: _arraySpanMethod,
                            border: true,
                          ),
                        ),
                        _Table2Block(
                          key: const ValueKey('table2-page-popup'),
                          title: '弹窗中使用表格',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              UPButton(
                                text: '打开弹窗表格',
                                type: 'primary',
                                onClick: _openPopup,
                              ),
                              const SizedBox(height: 8),
                              Text(_popupSelectionText),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildPopupLayer(),
          ],
        ),
      ),
    );
  }
}

class _Table2Block extends StatelessWidget {
  const _Table2Block({
    super.key,
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
