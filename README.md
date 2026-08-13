# flutter_xml_layout_helpers

Helper widgets & classes for the XML Layout for Flutter (Ark7) extension for
VS Code.

## 🚀 Live demo

See what the XML layout can do without installing anything:

**[https://zhoulijun12315.github.io/flutter-xml-layout-helpers/](https://zhoulijun12315.github.io/flutter-xml-layout-helpers/)**

The demo is a Flutter web app written entirely in XML — covering wrapper
properties, pipes, conditionals, `:repeat`, forms, animation, `:disable` and
i18n (EN/中文). The whole UI comes from
[`example/lib/demo/demo_page.xml`](example/lib/demo/demo_page.xml).

This is an actively maintained, null-safe fork of
[`flutter_xmllayout_helpers`](https://pub.dev/packages/flutter_xmllayout_helpers).
Compared with the original package:

- Null-safe, compatible with Dart 3 / modern Flutter.
- Requires only the Flutter SDK (`provider` and `rxdart` dependencies removed).
- Supports Dart `>=2.17` / Flutter `3.0+`, so existing Flutter 3 projects can
  keep using the package while upgrading.
- Web-compatible: the `dart:io` platform checks were replaced with
  `defaultTargetPlatform` + `kIsWeb`.
- Fixes several latent bugs (platform branch ordering, `switchValue` not
  invoking its default builder, unused animation listeners, stream leaks).

Migrating from `flutter_xmllayout_helpers`:

```yaml
dependencies:
  flutter_xml_layout_helpers: ^0.1.0
```

```dart
import 'package:flutter_xml_layout_helpers/flutter_xml_layout_helpers.dart';
```

> **Note on rxdart:** this package no longer depends on `rxdart`. The
> generated code never creates `BehaviorSubject` itself — if you use
> `BehaviorSubject` (or other rxdart types) in your own controllers or
> `var` declarations, add `rxdart` to your app's own `pubspec.yaml`
> dependencies. Previously it arrived transitively through this package.

## Web demo

See [`example/`](example/) for the demo source (a Flutter web app built from
[`demo_page.xml`](example/lib/demo/demo_page.xml)) and the
[GitHub Pages workflow](.github/workflows/deploy-demo.yml) that deploys it.
The live version is available at
<https://zhoulijun12315.github.io/flutter-xml-layout-helpers/>.
