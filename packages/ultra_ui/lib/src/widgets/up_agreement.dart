import 'package:flutter/widgets.dart';

import '../theme/up_theme.dart';
import 'up_modal.dart';

/// 1:1 API shell of u-agreement / up-agreement.
class UPAgreement extends StatefulWidget {
  const UPAgreement({
    super.key,
    this.urlProtocol = '/pages/user_agreement/agreement/info?title=用户协议',
    this.urlPrivacy = '/pages/user_agreement/agreement/info?title=隐私政策',
    this.onConfirm,
    this.onUrlClick,
    this.controller,
    this.child,
    this.customStyle,
  });

  final String urlProtocol;
  final String urlPrivacy;
  final ValueChanged<int>? onConfirm;

  /// Host navigation hook for protocol/privacy urls (source uses uni.navigateTo).
  final ValueChanged<String>? onUrlClick;
  final UPAgreementController? controller;
  final Widget? child;
  final BoxDecoration? customStyle;

  @override
  State<UPAgreement> createState() => UPAgreementState();
}

class UPAgreementController {
  UPAgreementState? _state;
  void showModal() => _state?.showModal();
  void close() => _state?.close();
}

class UPAgreementState extends State<UPAgreement> {
  bool show = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
  }

  @override
  void didUpdateWidget(covariant UPAgreement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
  }

  void showModal() => setState(() => show = true);

  void close() {
    // Source close may quit app on native; Flutter keeps dismiss-only.
    if (!show) return;
    setState(() => show = false);
  }

  /// Source `urlClick`: resolve the component property selected by the
  /// template, while preserving direct URL calls for Flutter consumers.
  void urlClick(String type) {
    final url = switch (type) {
      'urlProtocol' => widget.urlProtocol,
      'urlPrivacy' => widget.urlPrivacy,
      _ => type,
    };
    widget.onUrlClick?.call(url);
  }

  void confirm() {
    setState(() => show = false);
    widget.onConfirm?.call(1);
  }

  @override
  void dispose() {
    widget.controller?._state = null;
    super.dispose();
  }

  Widget _link(String text, String url, Color color) {
    return GestureDetector(
      onTap: () => urlClick(url),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 14, height: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = UPThemeTokens.of(context);
    final linkColor = tokens.primary;
    final content = widget.child ??
        Text.rich(
          TextSpan(
            style:
                TextStyle(color: tokens.mainColor, fontSize: 14, height: 1.6),
            children: [
              const TextSpan(
                text: '我们非常重视您的个人信息和隐私保护。为了更好地保障您的个人权益，在您使用我们的产品前，请务必审慎阅读《',
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: _link('用户协议', widget.urlProtocol, linkColor),
              ),
              const TextSpan(text: '》和《'),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: _link('隐私政策', widget.urlPrivacy, linkColor),
              ),
              const TextSpan(
                text:
                    '》内的所有条款，尤其是:1.我们对您的个人信息的收集/保存/使用/对外提供/保护等规则条款，以及您的用户权利等条款;2. 约定我们的限制责任、免责条款;3.其他以颜色或加粗进行标识的重要条款。如您对以上协议有任何疑问，请先不要同意，您点击“同意并继续”的行为即表示您已阅读完毕并同意以上协议的全部内容。',
              ),
            ],
          ),
        );

    Widget root = UPModal(
      show: show,
      showCancelButton: true,
      confirmText: '阅读并同意',
      onConfirm: confirm,
      onCancel: close,
      onClose: close,
      child: content,
    );
    return root;
  }
}
