# XML Layout for Flutter — Web Demo

A Flutter web app showcasing the XML Layout for Flutter (Ark7) features:

- Wrapper properties (`:margin`, `:padding`, `:opacity`, `:visible`, `:width/:height`)
- Pipes (`widthPercent`, `stream`, custom `translate` pipe)
- Conditionals (`:if`, `<if>/<elseIf>/<else>`, `:switch`)
- `:repeat` list rendering
- Forms (`:formControl`, `FormGroup`, `:formSubmit`, `submitEnabled`)
- Animation (`apply-animation` with tween maps) and `:disable`
- i18n (`lib/i18n/*.json` → generated localizations, locale switcher)

## Run locally

```sh
flutter pub get
flutter run -d chrome
```

## How the UI is written

- `lib/demo/demo_page.xml` is the source of truth.
- `lib/demo/demo_page.xml.dart` is generated from the XML by the generator
  (see the `flutter-xml-layout` repo) and committed so the demo builds without
  running the generator.
- `lib/demo/demo_page.ctrl.dart` is the user-owned controller — edit this file,
  never the generated `.xml.dart`.

## Regenerating the generated files

From the `flutter-xml-layout` generator repo:

```sh
npx tsc -p tools/tsconfig.build.json
node .tools-out/tools/generate.js generate ../flutter-xml-layout-helpers/example
```

This regenerates `demo_page.xml.dart` (and creates `demo_page.ctrl.dart` only
if it does not exist) plus `lib/i18n/gen/*`. Add `--json` for machine-readable
output or use `watch` instead of `generate` to regenerate on file changes.

## GitHub Pages

The workflow at `.github/workflows/deploy-demo.yml` builds this demo and deploys
it to GitHub Pages on every push to `main`. After pushing the repository, go to
**Settings → Pages** and set the source to **GitHub Actions**.

The demo will be available at
`https://<user>.github.io/<repository-name>/`.
