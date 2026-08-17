import 'package:flutter/material.dart';

import '../theme/up_theme.dart';
import 'up_button.dart';
import 'up_number_box.dart';

/// Port of u-goods-sku / up-goods-sku.
class UPGoodsSku extends StatefulWidget {
  const UPGoodsSku({
    super.key,
    this.goodsInfo = const {},
    this.skuTree = const [],
    this.skuList = const [],
    this.maxBuy = 999,
    this.confirmText = '确定',
    this.closeable = true,
    this.pageInline = false,
    this.show = false,
    this.trigger,
    this.header,
    this.onUpdateShow,
    this.onOpen,
    this.onConfirm,
    this.onClose,
    this.customStyle,
  });

  final Map goodsInfo;
  final List skuTree;
  final List skuList;
  final int maxBuy;
  final String confirmText;
  final bool closeable;
  final bool pageInline;
  final bool show;

  /// Slot: trigger (opens popup when not pageInline).
  final Widget? trigger;

  /// Slot: header.
  final Widget? header;
  final ValueChanged<bool>? onUpdateShow;
  final VoidCallback? onOpen;
  final ValueChanged<Map>? onConfirm;
  final VoidCallback? onClose;
  final BoxDecoration? customStyle;

  @override
  State<UPGoodsSku> createState() => UPGoodsSkuState();
}

class UPGoodsSkuState extends State<UPGoodsSku> {
  final Map<String, dynamic> selectedSku = {};
  num buyNum = 1;
  late bool innerShow;

  @override
  void initState() {
    super.initState();
    innerShow = widget.pageInline ? true : widget.show;
    _initSelected();
  }

  @override
  void didUpdateWidget(covariant UPGoodsSku oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.show != widget.show) {
      innerShow = widget.pageInline ? true : widget.show;
    }
    if (oldWidget.skuTree != widget.skuTree) {
      selectedSku.clear();
      _initSelected();
    }
  }

  void _initSelected() {
    for (final t in widget.skuTree) {
      if (t is Map) {
        final k = _treeKey(t);
        if (k.isNotEmpty) selectedSku[k] = selectedSku[k] ?? '';
      }
    }
  }

  String _treeKey(Map tree) =>
      '${tree['name'] ?? tree['k'] ?? tree['id'] ?? ''}';

  String _treeLabel(Map tree) =>
      '${tree['label'] ?? tree['k_s'] ?? tree['name'] ?? _treeKey(tree)}';

  List _treeChildren(Map tree) =>
      (tree['children'] ?? tree['v'] ?? tree['values'] ?? tree['list'] ?? [])
          as List? ??
      const [];

  Map? get selectedSkuComb {
    return getSkuComb(selectedSku);
  }

  num get price {
    final comb = selectedSkuComb;
    if (comb != null) {
      return num.tryParse('${comb['price'] ?? comb['price_fee'] ?? 0}') ?? 0;
    }
    return num.tryParse(
          '${widget.goodsInfo['price'] ?? widget.goodsInfo['price_fee'] ?? 0}',
        ) ??
        0;
  }

  num get stock {
    final comb = selectedSkuComb;
    if (comb != null) {
      return num.tryParse('${comb['stock'] ?? comb['quantity'] ?? 0}') ?? 0;
    }
    return num.tryParse(
          '${widget.goodsInfo['stock'] ?? widget.goodsInfo['quantity'] ?? 0}',
        ) ??
        0;
  }

  num get maxBuyNum {
    final s = stock;
    // Source: stock > maxBuy ? maxBuy : stock
    return s > widget.maxBuy ? widget.maxBuy : s;
  }

  bool get canBuy {
    final need = widget.skuTree.length;
    final got = selectedSku.values.where((v) => '$v'.isNotEmpty).length;
    return got == need && buyNum > 0 && stock > 0;
  }

  String get selectedSkuText {
    final selected = <String>[];
    selectedSku.forEach((key, value) {
      if ('$value'.isEmpty) return;
      for (final tree in widget.skuTree) {
        if (tree is! Map) continue;
        if (_treeKey(tree) != key) continue;
        for (final leaf in _treeChildren(tree)) {
          if (leaf is Map && '${leaf['id'] ?? leaf['name']}' == '$value') {
            selected.add('${leaf['name'] ?? leaf['label'] ?? value}');
          } else if ('$leaf' == '$value') {
            selected.add('$leaf');
          }
        }
      }
    });
    return selected.join(', ');
  }

  bool isSelected(String skuKey, dynamic skuValueId) =>
      '${selectedSku[skuKey]}' == '$skuValueId';

  bool isDisabled(String skuKey, dynamic skuValueId) {
    if (widget.skuList.isEmpty) return false;
    final temp = Map<String, dynamic>.from(selectedSku);
    temp[skuKey] = skuValueId;
    final filled = temp.values.where((v) => '$v'.isNotEmpty).length;
    // Source: if all dimensions filled, disable when no matching combination.
    if (filled >= widget.skuTree.length) {
      final comb = getSkuComb(temp);
      if (comb == null) return true;
      final st = num.tryParse('${comb['stock'] ?? comb['quantity'] ?? 1}') ?? 1;
      return st <= 0;
    }
    // Partial selection: disable if no remaining sku can match current picks.
    for (final item in widget.skuList) {
      if (item is! Map) continue;
      if (_matchesSelected(item, temp)) return false;
    }
    return true;
  }

  /// Source-compatible: match selected dimensions against a sku row.
  Map? getSkuComb(Map selected) {
    final filled = <String, dynamic>{};
    selected.forEach((k, v) {
      if ('$v'.isNotEmpty) filled['$k'] = v;
    });
    if (filled.length != widget.skuTree.length) return null;
    for (final item in widget.skuList) {
      if (item is! Map) continue;
      if (_matchesSelected(item, filled)) return item;
    }
    // Fallback: id equals joined selected values (common demo schema).
    final joined = filled.values.map((v) => '$v').join('_');
    for (final item in widget.skuList) {
      if (item is! Map) continue;
      final id = '${item['id'] ?? ''}';
      if (id.isNotEmpty && id == joined) return item;
    }
    return null;
  }

  bool _matchesSelected(Map sku, Map selected) {
    final nested = sku['s'] ?? sku['sku'] ?? sku['specs'];
    for (final entry in selected.entries) {
      final key = '${entry.key}';
      final value = '${entry.value}';
      if (value.isEmpty) continue;
      String? candidate;
      if (nested is Map && nested.containsKey(key)) {
        candidate = '${nested[key]}';
      } else if (sku.containsKey(key)) {
        candidate = '${sku[key]}';
      }
      if (candidate != value) return false;
    }
    return true;
  }

  void open() {
    setState(() => innerShow = true);
    widget.onUpdateShow?.call(true);
    widget.onOpen?.call();
  }

  void close() {
    setState(() => innerShow = false);
    widget.onUpdateShow?.call(false);
    widget.onClose?.call();
  }

  /// Source method: clear selected sku and buy num.
  void reset() {
    setState(() {
      selectedSku.clear();
      _initSelected();
      buyNum = 1;
    });
  }

  void onSkuClick(String skuKey, dynamic leaf) {
    final id =
        leaf is Map ? (leaf['id'] ?? leaf['name'] ?? leaf['value']) : leaf;
    if (isDisabled(skuKey, id)) return;
    setState(() {
      if ('${selectedSku[skuKey]}' == '$id') {
        selectedSku[skuKey] = '';
      } else {
        selectedSku[skuKey] = id;
      }
    });
  }

  /// Source `onNumChange`.
  void onNumChange(num next) {
    var v = next;
    final max = maxBuyNum;
    if (v < 1) v = 1;
    if (max > 0 && v > max) v = max;
    setState(() => buyNum = v);
  }

  /// Source `getSelectedSkuComb` alias of [selectedSkuComb]/[getSkuComb].
  Map? getSelectedSkuComb([Map? selected]) {
    if (selected == null) return selectedSkuComb;
    return getSkuComb(selected);
  }

  /// Source `getSelectedSku` snapshot.
  Map getSelectedSku([dynamic _]) => Map<String, dynamic>.from(selectedSku);

  void onConfirm() {
    if (!canBuy && widget.skuTree.isNotEmpty) return;
    final comb = selectedSkuComb;
    widget.onConfirm?.call({
      'goodsInfo': widget.goodsInfo,
      'selectedSku': Map<String, dynamic>.from(selectedSku),
      'selectedSkuComb': comb,
      // Source keys
      'sku': comb,
      'buyNum': buyNum,
      'num': buyNum,
      'price': price,
      'stock': stock,
      'selectedSkuText': selectedSkuText,
      'selectedText': selectedSkuText,
    });
    if (!widget.pageInline) close();
  }

  Widget _body(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final title =
        '${widget.goodsInfo['title'] ?? widget.goodsInfo['name'] ?? '商品'}';
    final thumb =
        '${widget.goodsInfo['image'] ?? widget.goodsInfo['picture'] ?? widget.goodsInfo['thumb'] ?? widget.goodsInfo['pic'] ?? ''}';

    final header = widget.header ??
        Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: tokens.bgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: thumb.isEmpty
                  ? Icon(Icons.image, color: tokens.tipsColor)
                  : Text(
                      thumb,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: tokens.mainColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: '¥',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFFA3534),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: '$price',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFFFA3534),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '库存 $stock 件',
                    style: TextStyle(fontSize: 12, color: tokens.tipsColor),
                  ),
                  Text(
                    '已选: $selectedSkuText',
                    style: TextStyle(fontSize: 12, color: tokens.contentColor),
                  ),
                ],
              ),
            ),
            if (widget.closeable && !widget.pageInline)
              GestureDetector(
                onTap: close,
                child: Icon(Icons.close, color: tokens.tipsColor),
              ),
          ],
        );

    return Container(
      decoration: BoxDecoration(
        color: tokens.cardBgColor,
        borderRadius: widget.pageInline
            ? BorderRadius.zero
            : const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: EdgeInsets.fromLTRB(
        widget.pageInline ? 0 : 16,
        widget.pageInline ? 0 : 16,
        widget.pageInline ? 0 : 16,
        widget.pageInline ? 0 : 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const SizedBox(height: 16),
          ...widget.skuTree.map((tree) {
            if (tree is! Map) return const SizedBox.shrink();
            final k = _treeKey(tree);
            final name = _treeLabel(tree);
            final values = _treeChildren(tree);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      color: tokens.mainColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: values.map((v) {
                      dynamic vid;
                      String label;
                      if (v is Map) {
                        vid = v['id'] ?? v['name'] ?? v['value'];
                        label = '${v['name'] ?? v['label'] ?? vid}';
                      } else {
                        vid = v;
                        label = '$v';
                      }
                      final active = isSelected(k, vid);
                      final disabled = isDisabled(k, vid);
                      return GestureDetector(
                        onTap: disabled ? null : () => onSkuClick(k, v),
                        child: Opacity(
                          opacity: disabled ? 0.4 : 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? tokens.primary.withValues(alpha: 0.1)
                                  : tokens.bgColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: active
                                    ? tokens.primary
                                    : tokens.borderColor,
                              ),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                color: active
                                    ? tokens.primary
                                    : tokens.contentColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }),
          Row(
            children: [
              Text('购买数量',
                  style: TextStyle(fontSize: 14, color: tokens.mainColor)),
              const Spacer(),
              UPNumberBox(
                value: buyNum,
                min: 1,
                max: maxBuyNum,
                disabled: !canBuy,
                onChange: (v, {name}) => onNumChange(v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          UPButton(
            text: widget.confirmText,
            type: 'primary',
            disabled: !canBuy && widget.skuTree.isNotEmpty,
            onClick: onConfirm,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pageInline) {
      return _body(context);
    }

    final panel = innerShow
        ? Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: close,
                  child: Container(color: const Color(0x66000000)),
                ),
              ),
              Align(alignment: Alignment.bottomCenter, child: _body(context)),
            ],
          )
        : const SizedBox.shrink();

    Widget root = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.trigger != null)
          GestureDetector(
            onTap: open,
            behavior: HitTestBehavior.opaque,
            child: widget.trigger,
          ),
        if (innerShow) Expanded(child: panel) else panel,
      ],
    );

    // When used without explicit height (common in tests), avoid Expanded crash.
    if (widget.trigger == null) {
      root = panel;
    } else {
      root = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: open,
            behavior: HitTestBehavior.opaque,
            child: widget.trigger,
          ),
          if (innerShow)
            SizedBox(
              height: 420,
              child: panel,
            ),
        ],
      );
    }

    return root;
  }
}
