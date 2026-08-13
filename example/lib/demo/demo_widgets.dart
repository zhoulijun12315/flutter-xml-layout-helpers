import 'package:flutter/material.dart';

/// A scrollable, syntax-highlighted XML code block with line numbers.
class XmlCodeBlock extends StatelessWidget {
  const XmlCodeBlock({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final lines = code.split('\n');
    return Container(
      constraints: const BoxConstraints(maxHeight: 340),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF33334A)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < lines.length; i++)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${i + 1}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Color(0xFF56566E),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: _XmlHighlighter.highlight(lines[i]),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          height: 1.6,
                          color: Color(0xFFE8E8F0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// A demo section: header + labeled XML source + live preview.
///
/// Wide screens show the source and preview side by side; narrow screens
/// stack them vertically.
class DemoSection extends StatelessWidget {
  const DemoSection({
    super.key,
    required this.title,
    required this.icon,
    required this.xml,
    required this.child,
    this.description,
  });

  final String title;
  final IconData icon;
  final String xml;
  final Widget child;
  final String? description;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          description!,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
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
                    Text('XML 源码', style: labelStyle),
                  ],
                );
                final effectLabel = Row(
                  children: [
                    const Icon(Icons.play_circle_outline, size: 14),
                    const SizedBox(width: 4),
                    Text('实时效果', style: labelStyle),
                  ],
                );

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
                          Expanded(flex: 5, child: XmlCodeBlock(code: xml)),
                          const SizedBox(width: 16),
                          Expanded(flex: 6, child: _previewBox(theme, child)),
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
                    XmlCodeBlock(code: xml),
                    const SizedBox(height: 16),
                    effectLabel,
                    const SizedBox(height: 8),
                    _previewBox(theme, child),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewBox(ThemeData theme, Widget child) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 240),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: DefaultTextStyle(
        style: theme.textTheme.bodyLarge!,
        child: child,
      ),
    );
  }
}

/// A tiny custom widget used to demonstrate the `xmlns` component feature.
class DemoBadge extends StatelessWidget {
  const DemoBadge({super.key, required this.text, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color ?? scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color != null ? Colors.white : scheme.onPrimaryContainer,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// The hero header shown at the top of the demo page.
class DemoHero extends StatelessWidget {
  const DemoHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B6CFF), Color(0xFF9B5CFF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B6CFF).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'XML Layout for Flutter',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '用 XML 声明 Flutter UI：左侧是 XML 源码，右侧是它的实时效果。'
            '点击卡片里的按钮、输入文字，感受一下响应式能力。',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroChip(label: '纯 XML 驱动'),
              _HeroChip(label: 'Angular 风格属性'),
              _HeroChip(label: 'stream 管道'),
              _HeroChip(label: '表单 · 动画 · i18n'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

/// A tiny XML syntax highlighter (no external dependencies).
class _XmlHighlighter {
  static const _tag = Color(0xFF7FD4FF);
  static const _attr = Color(0xFFC792EA);
  static const _string = Color(0xFFC3E88D);
  static const _comment = Color(0xFF676E95);
  static const _punct = Color(0xFF89DDFF);

  static final RegExp _pattern = RegExp(
    r'''(<!--[\s\S]*?-->)|(<\/?[A-Za-z0-9_.:-]+)|([A-Za-z0-9_.:-]+=)|("[^"]*"|'[^']*')|(>|\?>)''',
  );

  static List<TextSpan> highlight(String line) {
    final spans = <TextSpan>[];
    var last = 0;
    for (final match in _pattern.allMatches(line)) {
      if (match.start > last) {
        spans.add(TextSpan(text: line.substring(last, match.start)));
      }
      final text = match.group(0)!;
      final color = match.group(1) != null
          ? _comment
          : match.group(2) != null
              ? _tag
              : match.group(3) != null
                  ? _attr
                  : match.group(4) != null
                      ? _string
                      : _punct;
      spans.add(TextSpan(text: text, style: TextStyle(color: color)));
      last = match.end;
    }
    if (last < line.length) {
      spans.add(TextSpan(text: line.substring(last)));
    }
    return spans;
  }
}
