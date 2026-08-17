import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import '../utils/up_utils.dart';
import 'up_icon.dart';

/// Port of u-tree / up-tree.
class UPTree extends StatefulWidget {
  const UPTree({
    super.key,
    this.data = const [],
    this.props = const {
      'label': 'label',
      'children': 'children',
      'nodeKey': 'id',
      'disabled': 'disabled',
    },
    this.nodeKey = '',
    this.showCheckbox = false,
    this.defaultExpandAll = false,
    this.defaultExpandedKeys = const [],
    this.defaultCheckedKeys = const [],
    this.expandOnClickNode = true,
    this.checkOnClickNode = false,
    this.checkStrictly = false,
    this.accordion = false,
    this.highlightCurrent = false,
    this.currentNodeKey = '',
    this.indent = 18,
    this.depth = 0,
    this.iconSize = 14,
    this.checkboxSize = 18,
    this.expandIcon = 'arrow-right',
    this.collapseIcon = 'arrow-down',
    this.nodeBuilder,
    this.onNodeClick,
    this.onNodeExpand,
    this.onNodeCollapse,
    this.onCheckChange,
    this.onCheck,
    this.onCurrentChange,
    this.customStyle,
  });

  final List data;
  final Map props;
  final String nodeKey;
  final bool showCheckbox;
  final bool defaultExpandAll;
  final List defaultExpandedKeys;
  final List defaultCheckedKeys;
  final bool expandOnClickNode;
  final bool checkOnClickNode;
  final bool checkStrictly;
  final bool accordion;
  final bool highlightCurrent;
  final dynamic currentNodeKey;
  final dynamic indent;

  /// Source retained tree depth.
  final dynamic depth;
  final dynamic iconSize;
  final dynamic checkboxSize;
  final String expandIcon;
  final String collapseIcon;

  /// Slot-like custom node label builder.
  final Widget Function(Map node,
      {required int level,
      required bool expanded,
      required bool checked,
      required bool indeterminate,
      required bool disabled})? nodeBuilder;
  final ValueChanged<Map>? onNodeClick;
  final ValueChanged<Map>? onNodeExpand;
  final ValueChanged<Map>? onNodeCollapse;
  final void Function(Map node, bool checked)? onCheckChange;
  final ValueChanged<Map>? onCheck;
  final void Function(Map? current, Map? old)? onCurrentChange;
  final BoxDecoration? customStyle;

  /// Source node-level flag retained at widget level (always false snapshot).
  dynamic get isExpanded => false;

  /// Source computed: switcherColor.
  dynamic get switcherColor => '#606266';

  @override
  State<UPTree> createState() => UPTreeState();
}

class _TreeNode {
  _TreeNode({
    required this.data,
    required this.key,
    required this.level,
    this.parent,
    this.expanded = false,
    this.checked = false,
    this.indeterminate = false,
    List<_TreeNode>? children,
  }) : children = children ?? <_TreeNode>[];

  final Map data;
  final String key;
  final int level;
  final _TreeNode? parent;
  bool expanded;
  bool checked;
  bool indeterminate;
  final List<_TreeNode> children;

  bool get hasChildren => children.isNotEmpty;
  bool get isLeaf => children.isEmpty;
}

class UPTreeState extends State<UPTree> {
  dynamic lastCallback;
  final List<_TreeNode> _roots = [];
  final Map<String, _TreeNode> _nodeMap = {};
  String _currentKey = '';
  int _seed = 0;

  String get _labelKey => '${widget.props['label'] ?? 'label'}';
  String get _childrenKey => '${widget.props['children'] ?? 'children'}';
  String get _disabledKey => '${widget.props['disabled'] ?? 'disabled'}';
  String get _keyField {
    if (widget.nodeKey.isNotEmpty) return widget.nodeKey;
    return '${widget.props['nodeKey'] ?? 'id'}';
  }

  /// Source prop-key aliases (Batch K).
  String get labelKey => _labelKey;
  String get childrenKey => _childrenKey;
  String get disabledKey => _disabledKey;
  String get keyField => _keyField;

  /// Source data.
  dynamic get currentKey => _currentKey.isEmpty ? null : _currentKey;
  set currentKey(dynamic v) {
    setCurrentKey(v);
  }

  Map get nodeMap => Map.unmodifiable(
        {for (final e in _nodeMap.entries) e.key: e.value.data},
      );
  int get privateKeySeed => _seed;
  List get treeData => widget.data;

  @override
  void initState() {
    super.initState();
    _currentKey = '${widget.currentNodeKey ?? ''}';
    _initTree();
  }

  @override
  void didUpdateWidget(covariant UPTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data ||
        oldWidget.props != widget.props ||
        oldWidget.nodeKey != widget.nodeKey ||
        oldWidget.defaultExpandAll != widget.defaultExpandAll ||
        oldWidget.defaultExpandedKeys != widget.defaultExpandedKeys ||
        oldWidget.defaultCheckedKeys != widget.defaultCheckedKeys ||
        oldWidget.checkStrictly != widget.checkStrictly) {
      _initTree();
    }
    if (oldWidget.currentNodeKey != widget.currentNodeKey) {
      _currentKey = '${widget.currentNodeKey ?? ''}';
    }
  }

  void _initTree() {
    _seed = 0;
    _roots
      ..clear()
      ..addAll(_cloneNodes(widget.data, null, 0));
    if (!widget.checkStrictly) {
      _syncParentChecked(_roots);
    }
  }

  List<_TreeNode> _cloneNodes(List raw, _TreeNode? parent, int level) {
    final list = <_TreeNode>[];
    for (var i = 0; i < raw.length; i++) {
      final e = raw[i];
      final data = e is Map
          ? Map<String, dynamic>.from(e)
          : <String, dynamic>{_labelKey: '$e', _keyField: '$e'};
      final key = _resolveKey(data, parent, i);
      final childrenRaw = data[_childrenKey];
      final childrenList = childrenRaw is List ? childrenRaw : const [];
      final expanded = widget.defaultExpandAll ||
          widget.defaultExpandedKeys.map((e) => '$e').contains(key) ||
          data['expanded'] == true;
      final checked =
          widget.defaultCheckedKeys.map((e) => '$e').contains(key) ||
              data['checked'] == true;
      final node = _TreeNode(
        data: data,
        key: key,
        level: level,
        parent: parent,
        expanded: expanded,
        checked: checked,
      );
      _nodeMap[key] = node;
      node.children.addAll(_cloneNodes(childrenList, node, level + 1));
      if (checked && !widget.checkStrictly) {
        _setChildrenChecked(node, true);
      }
      list.add(node);
    }
    return list;
  }

  String _resolveKey(Map data, _TreeNode? parent, int index) {
    final raw = data[_keyField];
    if (raw != null && '$raw'.isNotEmpty) return '$raw';
    final parentKey = parent?.key ?? 'root';
    _seed += 1;
    return '$parentKey-$index-$_seed';
  }

  bool _isDisabled(Map data) => data[_disabledKey] == true;

  void _setChildrenChecked(_TreeNode node, bool checked) {
    for (final child in node.children) {
      if (_isDisabled(child.data)) continue;
      child.checked = checked;
      child.indeterminate = false;
      _setChildrenChecked(child, checked);
    }
  }

  void _updateParentChecked(_TreeNode node) {
    final parent = node.parent;
    if (parent == null) return;
    final enabled = parent.children.where((c) => !_isDisabled(c.data)).toList();
    final allChecked =
        enabled.isNotEmpty && enabled.every((c) => c.checked == true);
    final someChecked =
        enabled.any((c) => c.checked == true || c.indeterminate == true);
    parent.checked = allChecked;
    parent.indeterminate = !allChecked && someChecked;
    _updateParentChecked(parent);
  }

  void _syncParentChecked(List<_TreeNode> nodes) {
    for (final node in nodes) {
      if (node.children.isNotEmpty) {
        _syncParentChecked(node.children);
        final enabled =
            node.children.where((c) => !_isDisabled(c.data)).toList();
        final allChecked =
            enabled.isNotEmpty && enabled.every((c) => c.checked == true);
        final someChecked =
            enabled.any((c) => c.checked == true || c.indeterminate == true);
        node.checked = allChecked;
        node.indeterminate = !allChecked && someChecked;
      }
    }
  }

  void _walk(List<_TreeNode> nodes, void Function(_TreeNode n) cb) {
    for (final n in nodes) {
      cb(n);
      _walk(n.children, cb);
    }
  }

  // ---- Source public methods ----

  List getCheckedNodes([bool leafOnly = false]) {
    final out = <Map>[];
    _walk(_roots, (n) {
      if (n.checked && (!leafOnly || n.isLeaf)) {
        out.add(Map<String, dynamic>.from(n.data));
      }
    });
    return out;
  }

  List getCheckedKeys([bool leafOnly = false]) {
    final out = <String>[];
    _walk(_roots, (n) {
      if (n.checked && (!leafOnly || n.isLeaf)) out.add(n.key);
    });
    return out;
  }

  List getHalfCheckedNodes() {
    final out = <Map>[];
    _walk(_roots, (n) {
      if (n.indeterminate) out.add(Map<String, dynamic>.from(n.data));
    });
    return out;
  }

  List getHalfCheckedKeys() =>
      getHalfCheckedNodes().map((e) => '${e[_keyField] ?? ''}').toList();

  void setCheckedKeys(List keys, [bool leafOnly = false]) {
    final set = keys.map((e) => '$e').toSet();
    setState(() {
      _walk(_roots, (n) {
        n.checked = false;
        n.indeterminate = false;
      });
      for (final key in set) {
        final node = _nodeMap[key];
        if (node == null) continue;
        if (leafOnly && !node.isLeaf) continue;
        _setNodeChecked(node, true, deep: true);
      }
      if (!widget.checkStrictly) _syncParentChecked(_roots);
    });
  }

  void setChecked(dynamic key, bool checked, [bool deep = true]) {
    final node = _nodeMap['$key'];
    if (node == null) return;
    setState(() => _setNodeChecked(node, checked, deep: deep));
  }

  Map? getCurrentNode() {
    final n = _nodeMap[_currentKey];
    return n == null ? null : Map<String, dynamic>.from(n.data);
  }

  void setCurrentKey(dynamic key) {
    final old = getCurrentNode();
    setState(() => _currentKey = '$key');
    final cur = getCurrentNode();
    if (cur != old) widget.onCurrentChange?.call(cur, old);
  }

  /// Source node-level `isExpanded` query.
  bool isExpanded([dynamic key]) {
    if (key == null) {
      return _nodeMap.values.any((n) => n.expanded);
    }
    final node = _nodeMap['$key'];
    return node?.expanded ?? false;
  }

  void expand(dynamic key) {
    final node = _nodeMap['$key'];
    if (node == null || !node.hasChildren || node.expanded) return;
    setState(() {
      if (widget.accordion) _collapseSiblings(node);
      node.expanded = true;
    });
    widget.onNodeExpand?.call(Map<String, dynamic>.from(node.data));
  }

  void collapse(dynamic key) {
    final node = _nodeMap['$key'];
    if (node == null || !node.expanded) return;
    setState(() => node.expanded = false);
    widget.onNodeCollapse?.call(Map<String, dynamic>.from(node.data));
  }

  void expandAll() {
    setState(() {
      _walk(_roots, (n) {
        if (n.hasChildren) n.expanded = true;
      });
    });
  }

  void collapseAll() {
    setState(() {
      _walk(_roots, (n) => n.expanded = false);
    });
  }

  /// Source node style helpers.
  List cloneNodes([List? raw]) {
    final source = raw ?? widget.data;
    return [
      for (final item in source)
        if (item is Map) Map<String, dynamic>.from(item) else item,
    ];
  }

  List collectVisibleNodes([dynamic _]) => visibleNodes;

  Map getNodeClass([dynamic key]) {
    final n = _nodeMap['$key'];
    if (n == null) return const {};
    return {
      'expanded': n.expanded,
      'checked': n.checked,
      'indeterminate': n.indeterminate,
      'disabled': _isDisabled(n.data),
      'isLeaf': n.isLeaf,
      'level': n.level,
    };
  }

  Map getNodeContentStyle([dynamic key]) {
    final n = _nodeMap['$key'];
    final indent = getIndentValue(n?.level ?? 1);
    return {
      'paddingLeft': indent,
      'key': key,
    };
  }

  double getIndentValue([dynamic level]) {
    final base = (num.tryParse('${widget.indent}') ?? 18).toDouble();
    final lv = (num.tryParse('$level') ?? 1).toDouble();
    return base * (lv - 1).clamp(0, 100);
  }

  /// Source `initTree`.
  /// Source `initTree`.
  void initTree([dynamic _]) => _initTree();

  /// Source `toggleExpand`.
  /// Source check helpers (Batch J).
  void toggleCheck([dynamic key]) {
    if (key == null) return;
    final checked = getCheckedKeys().contains(key);
    setChecked(key, !checked);
  }

  void callback([dynamic payload]) {
    lastCallback = payload ?? true;
    // Source uses callback as optional host hook after internal ops.
  }

  void toggleExpand(dynamic key) => toggle(key);

  /// Source `setNodeChecked`.
  void setNodeChecked(dynamic key, bool checked, [bool deep = true]) =>
      setChecked(key, checked, deep);

  /// Source `setChildrenChecked`.
  void setChildrenChecked(dynamic key, bool checked) =>
      updateChildCheckStatus(key, checked);

  /// Source `updateParentChecked` alias.
  void updateParentChecked(dynamic key) => updateParentCheckStatus(key);

  /// Source `syncParentChecked`.
  void syncParentChecked([dynamic _]) {
    setState(() => _syncParentChecked(_roots));
  }

  /// Source `walkNodes`.
  void walkNodes(void Function(Map node) cb) {
    _walk(_roots, (n) => cb(Map<String, dynamic>.from(n.data)));
  }

  /// Source `getNodeByKey`.
  Map? getNodeByKey(dynamic key) {
    final n = _nodeMap['$key'];
    if (n == null) return null;
    return Map<String, dynamic>.from(n.data);
  }

  /// Source `getCurrentKey`.
  dynamic getCurrentKey([dynamic _]) =>
      _currentKey.isEmpty ? null : _currentKey;

  /// Source `emitCheck`.
  void emitCheck([dynamic _]) {
    widget.onCheck?.call({
      'checkedNodes': getCheckedNodes(),
      'checkedKeys': getCheckedKeys(),
      'halfCheckedNodes': getHalfCheckedNodes(),
      'halfCheckedKeys': getHalfCheckedKeys(),
    });
  }

  /// Source tree prop helpers.
  Map get treeProps => Map<String, dynamic>.from(widget.props);

  List get visibleNodes {
    final out = <Map>[];
    void walk(List<_TreeNode> nodes) {
      for (final n in nodes) {
        out.add(Map<String, dynamic>.from(n.data));
        if (n.expanded && n.hasChildren) walk(n.children);
      }
    }

    walk(_roots);
    return out;
  }

  String resolveNodeKey(Map data, [dynamic parent, int index = 0]) =>
      _resolveKey(data, null, index);

  String getNodeKey(_TreeNode node) => node.key;
  String getNodeLabel(_TreeNode node) => '${node.data[_labelKey] ?? ''}';
  bool isNodeDisabled(Map data) => _isDisabled(data);
  bool includesKey(List keys, dynamic key) =>
      keys.map((e) => '$e').contains('$key');

  List getChildren(Map data) {
    final c = data[_childrenKey];
    return c is List ? c : const [];
  }

  /// Source click/expand/check aliases.
  void handleNodeClick(dynamic key) {
    _walk(_roots, (n) {
      if ('${n.key}' == '$key') _onNodeTap(n);
    });
  }

  void handleExpandClick(dynamic key) {
    _walk(_roots, (n) {
      if ('${n.key}' == '$key') _toggleExpand(n);
    });
  }

  void collapseSiblingNodes(dynamic key) {
    _walk(_roots, (n) {
      if ('${n.key}' == '$key') _collapseSiblings(n);
    });
  }

  void handleCheckboxChange(dynamic key, bool checked) {
    setChecked(key, checked, true);
  }

  /// Source `toggle` expand/collapse by key.
  void toggle(dynamic key) {
    final node = _nodeMap['$key'];
    if (node == null || !node.hasChildren) return;
    if (node.expanded) {
      collapse(key);
    } else {
      expand(key);
    }
  }

  /// Source `updateChildCheckStatus` — cascade check to descendants.
  void updateChildCheckStatus(dynamic key, bool checked) {
    final node = _nodeMap['$key'];
    if (node == null) return;
    setState(() {
      node.checked = checked;
      node.indeterminate = false;
      _setChildrenChecked(node, checked);
    });
  }

  /// Source `updateParentCheckStatus` — bubble check state upward.
  void updateParentCheckStatus(dynamic key) {
    final node = _nodeMap['$key'];
    if (node == null) return;
    setState(() => _updateParentChecked(node));
  }

  Map? getParentNode(dynamic key) {
    Map? parent;
    void walk(List<_TreeNode> nodes, _TreeNode? p) {
      for (final n in nodes) {
        if ('${n.key}' == '$key') {
          parent = p == null ? null : Map<String, dynamic>.from(p.data);
          return;
        }
        if (n.hasChildren) walk(n.children, n);
      }
    }

    walk(_roots, null);
    return parent;
  }

  void _setNodeChecked(_TreeNode node, bool checked, {required bool deep}) {
    if (_isDisabled(node.data)) return;
    node.checked = checked;
    node.indeterminate = false;
    if (!widget.checkStrictly && deep) {
      _setChildrenChecked(node, checked);
    }
    if (!widget.checkStrictly) {
      _updateParentChecked(node);
    }
  }

  void _collapseSiblings(_TreeNode node) {
    final siblings = node.parent?.children ?? _roots;
    for (final s in siblings) {
      if (s != node) s.expanded = false;
    }
  }

  void _toggleExpand(_TreeNode node) {
    if (!node.hasChildren) return;
    final next = !node.expanded;
    setState(() {
      if (widget.accordion && next) _collapseSiblings(node);
      node.expanded = next;
    });
    if (next) {
      widget.onNodeExpand?.call(Map<String, dynamic>.from(node.data));
    } else {
      widget.onNodeCollapse?.call(Map<String, dynamic>.from(node.data));
    }
  }

  void _onNodeTap(_TreeNode node) {
    if (_isDisabled(node.data)) return;
    final old = getCurrentNode();
    setState(() => _currentKey = node.key);
    final cur = Map<String, dynamic>.from(node.data);
    widget.onNodeClick?.call(cur);
    if (old != cur) widget.onCurrentChange?.call(cur, old);
    if (widget.expandOnClickNode && node.hasChildren) {
      _toggleExpand(node);
    }
    if (widget.showCheckbox && widget.checkOnClickNode) {
      final next = !node.checked;
      setState(() => _setNodeChecked(node, next, deep: true));
      widget.onCheckChange?.call(cur, next);
      widget.onCheck?.call({
        'checkedNodes': getCheckedNodes(),
        'checkedKeys': getCheckedKeys(),
        'halfCheckedNodes': getHalfCheckedNodes(),
        'halfCheckedKeys': getHalfCheckedKeys(),
        'node': cur,
      });
    }
  }

  List<Widget> _buildVisible() {
    final indent = UPUtils.getPx(widget.indent);
    final iconSize = UPUtils.getPx(widget.iconSize);
    final tokens = UPThemeTokens.of(context);
    final out = <Widget>[];

    void walk(List<_TreeNode> nodes) {
      for (final n in nodes) {
        final disabled = _isDisabled(n.data);
        final label = '${n.data[_labelKey] ?? ''}';
        final isCurrent = widget.highlightCurrent && n.key == _currentKey;
        out.add(
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: disabled ? null : () => _onNodeTap(n),
            child: Container(
              color: isCurrent
                  ? tokens.primary.withValues(alpha: 0.08)
                  : const Color(0x00000000),
              padding: EdgeInsets.only(
                left: n.level * indent,
                top: 8,
                bottom: 8,
                right: 8,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: n.hasChildren ? () => _toggleExpand(n) : null,
                    child: SizedBox(
                      width: 20,
                      child: n.hasChildren
                          ? UPIcon(
                              name: n.expanded
                                  ? widget.collapseIcon
                                  : widget.expandIcon,
                              size: iconSize,
                              color: tokens.contentColor,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  if (widget.showCheckbox)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        key: ValueKey('up-tree-checkbox-${n.key}'),
                        behavior: HitTestBehavior.opaque,
                        onTap:
                            disabled ? null : () => _handleTreeCheckboxTap(n),
                        child: IgnorePointer(
                          child: SizedBox(
                            width: UPUtils.getPx(widget.checkboxSize),
                            height: UPUtils.getPx(widget.checkboxSize),
                            child: Checkbox(
                              value: n.indeterminate ? null : n.checked,
                              tristate: true,
                              onChanged: disabled ? null : (_) {},
                              activeColor: tokens.primary,
                              checkColor: tokens.cardBgColor,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: widget.nodeBuilder != null
                        ? widget.nodeBuilder!(
                            Map<String, dynamic>.from(n.data),
                            level: n.level + 1,
                            expanded: n.expanded,
                            checked: n.checked,
                            indeterminate: n.indeterminate,
                            disabled: disabled,
                          )
                        : Text(
                            label,
                            style: TextStyle(
                              color: disabled
                                  ? tokens.disabledColor
                                  : tokens.mainColor,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
        if (n.hasChildren && n.expanded) walk(n.children);
      }
    }

    walk(_roots);
    return out;
  }

  void _handleTreeCheckboxTap(_TreeNode node) {
    final next = node.indeterminate ? true : !node.checked;
    setState(() => _setNodeChecked(node, next, deep: true));
    final cur = Map<String, dynamic>.from(node.data);
    widget.onCheckChange?.call(cur, next);
    widget.onCheck?.call({
      'checkedNodes': getCheckedNodes(),
      'checkedKeys': getCheckedKeys(),
      'halfCheckedNodes': getHalfCheckedNodes(),
      'halfCheckedKeys': getHalfCheckedKeys(),
      'node': cur,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _buildVisible(),
    );
  }
}
