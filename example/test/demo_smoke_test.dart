import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xml_layout_demo/main.dart';

void main() {
  testWidgets('demo app builds without exceptions', (tester) async {
    await tester.pumpWidget(const XmlLayoutDemoApp());
    await tester.pump();

    expect(find.text('0. 实时 Playground'), findsOneWidget);
    expect(find.text('1. Wrapper properties'), findsOneWidget);
    expect(find.text('5. Forms'), findsOneWidget);
    expect(find.text('10. Consumer & Provider'), findsOneWidget);
    expect(find.text('11. i18n'), findsOneWidget);
    expect(find.text('12. 自定义组件 (xmlns)'), findsOneWidget);
    expect(find.text('XML 源码'), findsWidgets);
    expect(find.text('实时效果'), findsWidgets);
  });

  testWidgets('playground re-renders preview when XML is edited',
      (tester) async {
    await tester.pumpWidget(const XmlLayoutDemoApp());
    await tester.pump();

    final editor = find.byType(TextField).first;
    await tester.enterText(editor, '<Text text="\'EDITED LIVE\'" />');
    await tester.pump();

    expect(find.text('EDITED LIVE'), findsOneWidget);
  });
}
