import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class WidgetHelpers {
  static List<T> mapToWidgetList<T extends Widget, D>(
    Iterable<dynamic> items,
    T Function(D item, int index) map,
  ) {
    final result = <T>[];
    var index = 0;
    for (final item in items) {
      result.add(map(item as D, index));
      index++;
    }
    return result;
  }

  static Widget ifTrue(
    bool condition,
    Widget Function() trueWidget,
    [Widget Function()? falseWidget]
  ) {
    if (condition) {
      return trueWidget();
    }
    return falseWidget != null ? falseWidget() : const SizedBox.shrink();
  }

  static Widget ifElseChain(
    Iterable<SwitchCase> ifElseChains,
    Widget? Function()? elseBuilder,
  ) {
    final trueItem = _firstTrue(ifElseChains);
    if (trueItem != null) {
      return trueItem.builder() ?? const SizedBox.shrink();
    }

    if (elseBuilder != null) {
      return elseBuilder() ?? const SizedBox.shrink();
    }
    return const SizedBox.shrink();
  }

  static List<Widget> ifElseChainMultiChild(
    Iterable<SwitchCaseMultiChild> ifElseChains,
    List<Widget>? Function()? elseBuilder,
  ) {
    final trueItem = _firstTrueMultiChild(ifElseChains);
    if (trueItem != null) {
      return trueItem.builder() ?? const <Widget>[];
    }

    if (elseBuilder != null) {
      return elseBuilder() ?? const <Widget>[];
    }
    return const <Widget>[];
  }

  static SwitchCase? _firstTrue(Iterable<SwitchCase> cases) {
    for (final item in cases) {
      if (item.value == true) {
        return item;
      }
    }
    return null;
  }

  static SwitchCaseMultiChild? _firstTrueMultiChild(
    Iterable<SwitchCaseMultiChild> cases,
  ) {
    for (final item in cases) {
      if (item.value == true) {
        return item;
      }
    }
    return null;
  }

  static Widget switchValue(
    dynamic value,
    Widget Function()? defaultWidgetBuilder,
    Iterable<SwitchCase> cases,
  ) {
    SwitchCase? result;
    for (final item in cases) {
      if (item.value == value) {
        result = item;
        break;
      }
    }

    if (result != null) {
      return result.builder() ??
          (defaultWidgetBuilder != null
              ? defaultWidgetBuilder()
              : const SizedBox.shrink());
    }
    return defaultWidgetBuilder != null
        ? defaultWidgetBuilder()
        : const SizedBox.shrink();
  }

  static Widget when(String value, Widget widget, Widget defaultWidget) {
    final segments = value.split(':');
    final platform = segments.isNotEmpty ? segments.first : value;
    return _platformMatches(platform) ? widget : defaultWidget;
  }

  static bool _platformMatches(String platform) {
    if (kIsWeb) {
      return platform == 'web';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return platform == 'android';
      case TargetPlatform.iOS:
        return platform == 'ios';
      case TargetPlatform.macOS:
        return platform == 'mac' || platform == 'macos';
      case TargetPlatform.windows:
        return platform == 'windows';
      case TargetPlatform.linux:
        return platform == 'linux';
      case TargetPlatform.fuchsia:
        return platform == 'fuchsia';
    }
  }

  static dynamic onPlatformProperty({
    dynamic Function()? ios,
    dynamic Function()? android,
    dynamic Function()? windows,
    dynamic Function()? mac,
    dynamic Function()? linux,
  }) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios?.call();
      case TargetPlatform.android:
        return android?.call();
      case TargetPlatform.windows:
        return windows?.call();
      case TargetPlatform.macOS:
        return mac?.call();
      case TargetPlatform.linux:
        return linux?.call();
      case TargetPlatform.fuchsia:
        return null;
    }
  }

  static Widget onPlatformWidget({
    Widget Function()? ios,
    Widget Function()? android,
    Widget Function()? windows,
    Widget Function()? mac,
    Widget Function()? linux,
  }) {
    final result = onPlatformProperty(
      ios: ios,
      android: android,
      windows: windows,
      mac: mac,
      linux: linux,
    );
    return result is Widget ? result : const SizedBox.shrink();
  }
}

class SwitchCase {
  SwitchCase(this.value, this.builder);

  final dynamic value;
  final Widget? Function() builder;
}

class SwitchCaseMultiChild {
  SwitchCaseMultiChild(this.value, this.builder);

  final dynamic value;
  final List<Widget>? Function() builder;
}
