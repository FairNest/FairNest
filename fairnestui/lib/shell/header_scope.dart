// lib/shell/header_scope.dart
import 'package:flutter/widgets.dart';
import 'header_controller.dart';

class HeaderScope extends InheritedNotifier<HeaderController> {
  const HeaderScope({
    super.key,
    required HeaderController controller,
    required super.child,
  }) : super(notifier: controller);

  static HeaderController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<HeaderScope>();
    assert(scope != null,
        'HeaderScope.of() called with no HeaderScope in context.');
    return scope!.notifier!;
  }
}
