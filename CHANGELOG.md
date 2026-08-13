## [0.0.6] - 3-7-2020.
fix some bugs & update dependencies

## [0.0.3] - 22-7-2019.
Make mapToWidgetList generic.

## [0.0.2] - 17-7-2019.
Add submitEnabledStream.

## [0.0.1] - 13-7-2019.

* Initial release.
## [0.1.0] - 2026-08-12

- Renamed package to `flutter_xml_layout_helpers` (maintained fork).
- Migrated to null safety (Dart 3 compatible, SDK `>=2.17.0 <4.0.0`).
- Removed `provider` and `rxdart` dependencies (Flutter SDK only).
- Replaced `dart:io` platform checks with `defaultTargetPlatform`/`kIsWeb`.
- Fixed `switchValue` not invoking the default builder, duplicate platform
  branches, unused animation listeners, and stream/controller leaks.
- Added basic unit tests for forms, helpers and pipes.

## Unreleased

- `headers.dart` is now the single public entry point; implementations moved
  to `lib/src/` (removed the old `flutter_xml_layout_helpers.dart` main file).
- `WidgetHelpers.ifTrue` accepts a nullable condition (`null` is treated as
  `false`), matching pre-null-safety behavior for optional `bool` params.

## [0.0.6] - 3-7-2020.
