import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

const String kDefaultPlaygroundXml = '''
<Container :margin="12" :padding="12" color="Colors.indigo.shade50" :center>
  <Column mainAxisAlignment="center" crossAxisAlignment="center">
    <Text text="'Hello from XML!'" />
    <Container :margin="8" width="160" height="34" color="Colors.amber" :center>
      <Text text="':width + :center'" />
    </Container>
    <Container :margin="8" :opacity="0.6" color="Colors.teal.shade200" :center>
      <Text text="':opacity 0.6'" />
    </Container>
    <Container :margin="8" :rotate="0.15" :scale="1.1" color="Colors.pink.shade100" :center>
      <Text text="':rotate + :scale'" />
    </Container>
  </Column>
</Container>
''';

/// An interactive playground: edit XML on the left, see it rendered live.
///
/// This is a small runtime interpreter of a subset of the XML layout syntax
/// (containers, text, rows/columns, wrappers). It is demo-only — the real
/// generator is the TypeScript extension/CLI.
class LiveXmlPlayground extends StatefulWidget {
  const LiveXmlPlayground({super.key});

  @override
  State<LiveXmlPlayground> createState() => _LiveXmlPlaygroundState();
}

class _LiveXmlPlaygroundState extends State<LiveXmlPlayground> {
  final TextEditingController _editor =
      TextEditingController(text: kDefaultPlaygroundXml);

  int _revision = 0;

  @override
  void dispose() {
    _editor.dispose();
    super.dispose();
  }

  void _onChanged(String _) {
    setState(() => _revision++);
  }

  void _refresh() {
    setState(() => _revision++);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.edit_note,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '0. 实时 Playground',
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _refresh,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('重新渲染'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '直接在左侧修改 XML，右侧会立即渲染。支持 Container/Text/'
                        'Column/Row/SizedBox/Center/Icon 和 :margin/:padding/:opacity/'
                        ':center/:width/:height/:visible/:rotate/:scale/:translate。',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 900;
                final labelStyle = theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w600,
                );
                final codeLabel = Row(
                  children: [
                    const Icon(Icons.code, size: 14),
                    const SizedBox(width: 4),
                    Text('XML 编辑器', style: labelStyle),
                  ],
                );
                final effectLabel = Row(
                  children: [
                    const Icon(Icons.play_circle_outline, size: 14),
                    const SizedBox(width: 4),
                    Text('实时渲染', style: labelStyle),
                  ],
                );
                final editor = _XmlEditor(
                  controller: _editor,
                  onChanged: _onChanged,
                );
                final preview = _LivePreview(xml: _editor.text);

                if (wide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: codeLabel),
                          const SizedBox(width: 16),
                          Expanded(child: effectLabel),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: editor),
                          const SizedBox(width: 16),
                          Expanded(child: preview),
                        ],
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    codeLabel,
                    const SizedBox(height: 8),
                    editor,
                    const SizedBox(height: 16),
                    effectLabel,
                    const SizedBox(height: 8),
                    preview,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _XmlEditor extends StatelessWidget {
  const _XmlEditor({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF33334A)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          height: 1.6,
          color: Color(0xFFE8E8F0),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _LivePreview extends StatelessWidget {
  const _LivePreview({required this.xml});

  final String xml;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warnings = <String>[];

    Widget preview;
    String? error;
    try {
      final document = XmlDocument.parse(xml);
      preview = XmlInterpreter.build(document.rootElement, warnings);
    } catch (e) {
      error = '$e';
      preview = const SizedBox.shrink();
    }

    return Container(
      height: 300,
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: error != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent),
                const SizedBox(height: 6),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      error,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: DefaultTextStyle(
                        style: theme.textTheme.bodyLarge!,
                        child: preview,
                      ),
                    ),
                  ),
                ),
                if (warnings.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      warnings.join('\n'),
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

/// A tiny runtime interpreter for a subset of the XML layout syntax.
class XmlInterpreter {
  static Widget build(XmlElement element, List<String> warnings) {
    final name = element.name.local;
    switch (name) {
      case 'Container':
        return _container(element, warnings);
      case 'Text':
        return _text(element, warnings);
      case 'Column':
      case 'Row':
        return _flex(element, warnings, isRow: name == 'Row');
      case 'SizedBox':
        return _sizedBox(element, warnings);
      case 'Center':
        return _applyWrappers(
          Center(child: _firstChild(element, warnings)),
          element,
          warnings,
        );
      case 'Padding':
        return _applyWrappers(
          Padding(
            padding: _insets(_attr(element, 'padding')) ?? EdgeInsets.zero,
            child: _firstChild(element, warnings),
          ),
          element,
          warnings,
        );
      case 'Icon':
        return _icon(element, warnings);
      case 'TextButton':
      case 'ElevatedButton':
      case 'FilledButton':
        return _button(element, warnings);
      default:
        warnings.add('暂不支持的标签: <$name>');
        return const SizedBox.shrink();
    }
  }

  static Widget _container(XmlElement element, List<String> warnings) {
    final width = _num(_attr(element, 'width'));
    final height = _num(_attr(element, 'height'));
    final color = _color(_attr(element, 'color'));
    return _applyWrappers(
      Container(
        width: width?.toDouble(),
        height: height?.toDouble(),
        color: color,
        child: _firstChild(element, warnings),
      ),
      element,
      warnings,
    );
  }

  static Widget _text(XmlElement element, List<String> warnings) {
    final raw = _attr(element, 'text');
    final value = _parseValue(raw);
    final color = _color(_attr(element, 'color'));
    return _applyWrappers(
      Text(
        value?.toString() ?? raw,
        style: color != null ? TextStyle(color: color) : null,
      ),
      element,
      warnings,
    );
  }

  static Widget _flex(
    XmlElement element,
    List<String> warnings, {
    required bool isRow,
  }) {
    final children = element.childElements
        .map((child) => build(child, warnings))
        .toList();
    final mainAxisAlignment =
        _mainAxisAlignment(_attr(element, 'mainAxisAlignment'));
    final crossAxisAlignment =
        _crossAxisAlignment(_attr(element, 'crossAxisAlignment'));
    final flex = isRow
        ? Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: children,
          )
        : Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: children,
          );
    return _applyWrappers(flex, element, warnings);
  }

  static Widget _sizedBox(XmlElement element, List<String> warnings) {
    return _applyWrappers(
      SizedBox(
        width: _num(_attr(element, 'width'))?.toDouble(),
        height: _num(_attr(element, 'height'))?.toDouble(),
        child: _firstChild(element, warnings),
      ),
      element,
      warnings,
    );
  }

  static Widget _icon(XmlElement element, List<String> warnings) {
    final icon = _iconData(_attr(element, 'icon'));
    final size = _num(_attr(element, 'size'));
    return _applyWrappers(
      Icon(icon ?? Icons.help_outline, size: size?.toDouble()),
      element,
      warnings,
    );
  }

  static Widget _button(XmlElement element, List<String> warnings) {
    final onPressed = _attr(element, 'onPressed');
    if (onPressed.isNotEmpty && !onPressed.startsWith('null')) {
      warnings.add('Playground 暂不支持 <$onPressed> 回调，按钮仅作展示');
    }
    final child = _firstChild(element, warnings);
    return _applyWrappers(
      switch (element.name.local) {
        'TextButton' => TextButton(onPressed: null, child: child),
        'ElevatedButton' => ElevatedButton(onPressed: null, child: child),
        _ => FilledButton(onPressed: null, child: child),
      },
      element,
      warnings,
    );
  }

  static Widget _firstChild(XmlElement element, List<String> warnings) {
    final children = element.childElements.toList();
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }
    return build(children.first, warnings);
  }

  static Widget _applyWrappers(
    Widget child,
    XmlElement element,
    List<String> warnings,
  ) {
    var result = child;

    final padding = _insets(_attr(element, ':padding'));
    if (padding != null) {
      result = Padding(padding: padding, child: result);
    }
    final margin = _insets(_attr(element, ':margin'));
    if (margin != null) {
      result = Padding(padding: margin, child: result);
    }
    final opacity = _num(_attr(element, ':opacity'));
    if (opacity != null) {
      result = Opacity(opacity: opacity.toDouble().clamp(0, 1), child: result);
    }
    final width = _num(_attr(element, ':width'));
    final height = _num(_attr(element, ':height'));
    if (width != null || height != null) {
      result = SizedBox(
        width: width?.toDouble(),
        height: height?.toDouble(),
        child: result,
      );
    }
    final visible = _bool(_attr(element, ':visible'));
    if (visible != null) {
      result = Visibility(visible: visible, child: result);
    }
    final angle = _num(_attr(element, ':rotate'));
    if (angle != null) {
      result = Transform.rotate(angle: angle.toDouble(), child: result);
    }
    final scale = _num(_attr(element, ':scale'));
    if (scale != null) {
      result = Transform.scale(scale: scale.toDouble(), child: result);
    }
    final offset = _offset(_attr(element, ':translate'));
    if (offset != null) {
      result = Transform.translate(offset: offset, child: result);
    }
    if (_attr(element, ':center').isNotEmpty) {
      result = Center(child: result);
    }
    return result;
  }

  static Object? _parseValue(String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      return null;
    }
    if (value.length >= 2 &&
        ((value.startsWith("'") && value.endsWith("'")) ||
            (value.startsWith('"') && value.endsWith('"')))) {
      return value.substring(1, value.length - 1);
    }
    if (value == 'true') return true;
    if (value == 'false') return false;
    final asInt = int.tryParse(value);
    if (asInt != null) return asInt;
    final asDouble = double.tryParse(value);
    if (asDouble != null) return asDouble;
    return value;
  }

  static num? _num(String raw) {
    final value = _parseValue(raw);
    return value is num ? value : null;
  }

  static bool? _bool(String raw) {
    final value = _parseValue(raw);
    return value is bool ? value : null;
  }

  static EdgeInsets? _insets(String raw) {
    final parts = raw
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return null;
    }
    final values = <double>[];
    for (final part in parts) {
      final value = double.tryParse(part);
      if (value == null) {
        return null;
      }
      values.add(value);
    }
    switch (values.length) {
      case 1:
        return EdgeInsets.all(values[0]);
      case 2:
        return EdgeInsets.symmetric(
          vertical: values[0],
          horizontal: values[1],
        );
      case 4:
        // Web order: top right bottom left.
        return EdgeInsets.fromLTRB(
          values[3],
          values[0],
          values[1],
          values[2],
        );
      default:
        return null;
    }
  }

  static Offset? _offset(String raw) {
    final match = RegExp(r'Offset\(\s*(-?[\d.]+)\s*,\s*(-?[\d.]+)\s*\)')
        .firstMatch(raw.trim());
    if (match == null) {
      return null;
    }
    return Offset(
      double.parse(match.group(1)!),
      double.parse(match.group(2)!),
    );
  }

  static Color? _color(String raw) {
    final parts = raw.trim().split('.');
    if (parts.isEmpty || parts.first != 'Colors') {
      return null;
    }
    Color base;
    switch (parts[1]) {
      case 'red': base = Colors.red; break;
      case 'pink': base = Colors.pink; break;
      case 'purple': base = Colors.purple; break;
      case 'deepPurple': base = Colors.deepPurple; break;
      case 'indigo': base = Colors.indigo; break;
      case 'blue': base = Colors.blue; break;
      case 'lightBlue': base = Colors.lightBlue; break;
      case 'cyan': base = Colors.cyan; break;
      case 'teal': base = Colors.teal; break;
      case 'green': base = Colors.green; break;
      case 'lightGreen': base = Colors.lightGreen; break;
      case 'lime': base = Colors.lime; break;
      case 'yellow': base = Colors.yellow; break;
      case 'amber': base = Colors.amber; break;
      case 'orange': base = Colors.orange; break;
      case 'deepOrange': base = Colors.deepOrange; break;
      case 'brown': base = Colors.brown; break;
      case 'grey': base = Colors.grey; break;
      case 'blueGrey': base = Colors.blueGrey; break;
      case 'black': return Colors.black;
      case 'white': return Colors.white;
      case 'transparent': return Colors.transparent;
      default:
        return null;
    }
    if (parts.length < 3) {
      return base;
    }
    final shade = int.tryParse(parts[2].replaceFirst('shade', ''));
    if (shade == null) {
      return base;
    }
    return _shade(base, shade);
  }

  static Color _shade(Color base, int shade) {
    final material = base as MaterialColor;
    switch (shade) {
      case 50: return material.shade50;
      case 100: return material.shade100;
      case 200: return material.shade200;
      case 300: return material.shade300;
      case 400: return material.shade400;
      case 500: return material.shade500;
      case 600: return material.shade600;
      case 700: return material.shade700;
      case 800: return material.shade800;
      case 900: return material.shade900;
      default: return material;
    }
  }

  static IconData? _iconData(String raw) {
    final name = raw.trim().split('.').last;
    switch (name) {
      case 'home': return Icons.home;
      case 'star': return Icons.star;
      case 'favorite': return Icons.favorite;
      case 'add': return Icons.add;
      case 'check': return Icons.check;
      case 'close': return Icons.close;
      case 'settings': return Icons.settings;
      case 'bolt': return Icons.bolt;
      case 'edit': return Icons.edit;
      case 'code': return Icons.code;
      default:
        return null;
    }
  }

  static MainAxisAlignment _mainAxisAlignment(String raw) {
    final value = raw.trim().split('.').last;
    switch (value) {
      case 'start': return MainAxisAlignment.start;
      case 'end': return MainAxisAlignment.end;
      case 'spaceBetween': return MainAxisAlignment.spaceBetween;
      case 'spaceAround': return MainAxisAlignment.spaceAround;
      case 'spaceEvenly': return MainAxisAlignment.spaceEvenly;
      case 'center':
      default:
        return MainAxisAlignment.center;
    }
  }

  static CrossAxisAlignment _crossAxisAlignment(String raw) {
    final value = raw.trim().split('.').last;
    switch (value) {
      case 'start': return CrossAxisAlignment.start;
      case 'end': return CrossAxisAlignment.end;
      case 'stretch': return CrossAxisAlignment.stretch;
      case 'center':
      default:
        return CrossAxisAlignment.center;
    }
  }

  static String _attr(XmlElement element, String name) {
    return element.getAttribute(name) ?? '';
  }
}
