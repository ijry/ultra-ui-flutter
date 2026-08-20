import 'package:flutter/widgets.dart';

import 'up_notify.dart';
import 'up_toast.dart';

/// Global registry backing [UPRootToastHost].
///
/// Replaces the source's `uni.$u.setRootToastRef` / `setRootNotifyRef`, which
/// let `$u.toast()` and `$u.notify()` run without a locally mounted component.
/// On Flutter the toast is already imperative and only needs a
/// [BuildContext], so this registry stores the host's context plus the notify
/// state, and [UPRootToastHost] registers and clears them with its lifecycle.
class UPRootToastRegistry {
  UPRootToastRegistry._();

  static BuildContext? _toastContext;
  static UPNotifyState? _notifyState;

  /// Source `uni.$u.setRootToastRef`.
  static void setRootToastRef(BuildContext? context) {
    _toastContext = context;
  }

  /// Source `uni.$u.setRootNotifyRef`.
  static void setRootNotifyRef(UPNotifyState? state) {
    _notifyState = state;
  }

  /// Whether a host is currently mounted.
  static bool get hasToastRef => _toastContext != null;
  static bool get hasNotifyRef => _notifyState != null;

  /// The registered notify state, or null when no host is mounted.
  static UPNotifyState? get notifyRef => _notifyState;

  /// Shows a toast through the registered host.
  ///
  /// Returns false when no host is mounted, matching the source's
  /// `typeof ... === 'function'` guard rather than throwing.
  static bool toast({
    String message = '',
    String type = '',
    String icon = '',
    bool loading = false,
    String position = 'center',
    int duration = 2000,
  }) {
    final context = _toastContext;
    if (context == null || !context.mounted) return false;
    UPToast.show(
      context,
      message: message,
      type: type,
      icon: icon,
      loading: loading,
      position: position,
      duration: duration,
    );
    return true;
  }

  /// Hides a toast shown through the registered host.
  static bool hideToast() {
    if (_toastContext == null) return false;
    UPToast.hide();
    return true;
  }

  /// Shows a notify through the registered host.
  static bool notify({
    String message = '',
    String type = 'primary',
    int? duration,
  }) {
    final state = _notifyState;
    if (state == null || !state.mounted) return false;
    state.show(options: <String, dynamic>{
      'message': message,
      'type': type,
      if (duration != null) 'duration': duration,
    });
    return true;
  }

  /// Closes a notify shown through the registered host.
  static bool closeNotify() {
    final state = _notifyState;
    if (state == null || !state.mounted) return false;
    state.close();
    return true;
  }
}

/// Port of libs/root/root-toast-host.vue.
///
/// Mount this once above the app's routes so [UPRootToastRegistry.toast] and
/// [UPRootToastRegistry.notify] work from anywhere without a local widget. It
/// registers its refs on mount and clears them on unmount, as the source does
/// in `onMounted` / `onBeforeUnmount`.
class UPRootToastHost extends StatefulWidget {
  const UPRootToastHost({super.key, this.child});

  /// The subtree the host wraps. The source template renders only the two
  /// hosts; the Flutter host also passes the app through so it can sit at the
  /// root of a `builder`.
  final Widget? child;

  @override
  State<UPRootToastHost> createState() => UPRootToastHostState();
}

class UPRootToastHostState extends State<UPRootToastHost> {
  final GlobalKey<UPNotifyState> _notifyKey = GlobalKey<UPNotifyState>();

  /// The state this host registered, kept so dispose can tell whether it still
  /// owns the global ref (the key's currentState is already null by then).
  UPNotifyState? _registeredNotifyState;

  /// Source ref: upGlobalNotifyRef.
  UPNotifyState? get upGlobalNotifyRef => _notifyKey.currentState;

  @override
  void initState() {
    super.initState();
    // Source onMounted registers both refs.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _registeredNotifyState = _notifyKey.currentState;
      UPRootToastRegistry.setRootToastRef(context);
      UPRootToastRegistry.setRootNotifyRef(_registeredNotifyState);
    });
  }

  @override
  void dispose() {
    // Source onBeforeUnmount clears both refs, but only if this host still
    // owns them — a newer host may have replaced them already.
    if (UPRootToastRegistry._toastContext == context) {
      UPRootToastRegistry.setRootToastRef(null);
    }
    if (_registeredNotifyState != null &&
        UPRootToastRegistry._notifyState == _registeredNotifyState) {
      UPRootToastRegistry.setRootNotifyRef(null);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final host = UPNotify(key: _notifyKey);
    final child = widget.child;
    if (child == null) return host;
    return Stack(
      textDirection: TextDirection.ltr,
      children: <Widget>[
        child,
        host,
      ],
    );
  }
}
