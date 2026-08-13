import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_xml_layout_helpers/flutter_xml_layout_helpers.dart';
import 'package:flutter_xml_layout_helpers/headers.dart' as headers;
import 'package:flutter_xml_layout_helpers/src/value_stream.dart';

void main() {
  test('headers.dart exposes the whole package', () {
    expect(headers.PipeProvider, isA<Type>());
    expect(headers.FormGroup, isA<Type>());
    expect(headers.WidgetHelpers, isA<Type>());
    expect(headers.AnimationBuilder, isA<Type>());
  });

  group('ValueStream', () {
    test('holds the latest value and emits changes', () async {
      final stream = ValueStream<int>(0);
      expect(stream.value, 0);

      final values = <int>[];
      final subscription = stream.stream.listen(values.add);

      stream.add(1);
      stream.add(2);
      stream.value = 3;

      expect(stream.value, 3);
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();
      await stream.close();

      expect(values, <int>[1, 2, 3]);
    });
  });

  group('FormControl', () {
    test('tracks value, dirty and validation state', () {
      final control = FormControl<String>('name', 'initial',
          validators: [Validators.required]);

      expect(control.name, 'name');
      expect(control.value, 'initial');
      expect(control.valid, isTrue);
      expect(control.invalid, isFalse);
      expect(control.dirty, isFalse);
      expect(control.touched, isFalse);

      control.value = 'updated';
      expect(control.value, 'updated');
      expect(control.dirty, isTrue);
      expect(control.valid, isTrue);
    });

    test('required validator marks empty value as invalid', () async {
      final control = FormControl<String>('name', '');
      control.setValidators([Validators.required]);

      await control.validate();

      expect(control.invalid, isTrue);
      expect(control.firstError, 'required');
      expect(control.getErrors(), <String>['required']);
    });

    test('reset, commit and cancel changes', () {
      final control = FormControl<String>('name', 'a');

      control.value = 'b';
      expect(control.dirty, isTrue);
      control.cancelChanges();
      expect(control.value, 'a');
      expect(control.dirty, isFalse);

      control.value = 'c';
      control.commitChanges();
      control.value = 'd';
      control.cancelChanges();
      expect(control.value, 'c');
    });

    test('async (future) validators update status after completion', () async {
      final control = FormControl<String>('email', 'a', futureValidators: [
        FutureValidator((value) async => value == 'a' ? 'already-taken' : null),
      ]);

      expect(control.pending, isTrue);
      await control.validate();

      expect(control.invalid, isTrue);
      expect(control.firstError, 'already-taken');
    });

    test('emits value changes through valueStream', () async {
      final control = FormControl<String>('name', 'a');
      final values = <String>[];
      final subscription = control.valueStream.listen(values.add);

      control.value = 'b';
      control.value = 'c';
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(values, <String>['b', 'c']);
    });

    testWidgets('attaches a TextEditingController', (tester) async {
      final control = FormControl<String>('name', 'initial');
      final controller = TextEditingController();

      control.attachTextEditingController(controller);
      expect(controller.text, 'initial');

      controller.text = 'edited';
      expect(control.value, 'edited');
      controller.text = 'edited again';
      expect(control.touched, isTrue);

      control.dispose();
    });
  });

  group('FormGroup', () {
    test('submitEnabled follows controls validity', () {
      final group = FormGroup();
      final control =
          FormControl<String>('name', '', validators: [Validators.required]);

      group.add(control);
      expect(group.submitEnabled, isFalse);

      control.value = 'ok';
      expect(group.submitEnabled, isTrue);
    });

    test('group status aggregates controls', () {
      final group = FormGroup();
      final name =
          FormControl<String>('name', '', validators: [Validators.required]);
      final email = FormControl<String>('email', 'x');
      group.addAll(<FormControl<dynamic>>[name, email]);

      expect(group.invalid, isTrue);

      name.value = 'ok';
      expect(group.valid, isTrue);

      group.remove('name');
      expect(group.hasControl('email'), isTrue);
      expect(group.hasControl('name'), isFalse);
      expect(group.valid, isTrue);
    });

    test('group-level validator can invalidate the whole group', () async {
      final group = FormGroup();
      group.add(FormControl<String>('name', 'x'));
      group.setValidator(
        FnValidator((value) {
          final values = value as Map<String, Object?>;
          return values['name'] == 'blocked' ? 'blocked' : null;
        }),
      );

      group.get('name').value = 'blocked';
      await group.validate();
      expect(group.invalid, isTrue);
      expect(group.getError(), 'blocked');

      group.get('name').value = 'free';
      await group.validate();
      expect(group.valid, isTrue);
    });

    test('submit only fires when the group is valid', () async {
      final group = FormGroup();
      group.add(
          FormControl<String>('name', '', validators: [Validators.required]));

      var submitted = false;
      group.onSubmit((data) async {
        submitted = true;
      });

      await group.submit();
      expect(submitted, isFalse);

      group.get('name').value = 'ok';
      await group.submit();
      expect(submitted, isTrue);
    });

    test('submit passes form values to the callback', () async {
      final group = FormGroup();
      group.add(FormControl<String>('name', 'value'));

      dynamic submitted;
      group.onSubmit((data) async {
        submitted = data;
      });

      await group.submit();

      expect(submitted, <String, Object?>{'name': 'value'});
    });

    test('get throws for unknown controls', () {
      final group = FormGroup();
      expect(() => group.get('missing'), throwsException);
    });
  });

  group('WidgetHelpers', () {
    test('ifTrue returns the matching branch', () {
      final trueWidget = WidgetHelpers.ifTrue(
          true, () => const Text('yes'), () => const Text('no'));
      final falseWidget = WidgetHelpers.ifTrue(
          false, () => const Text('yes'), () => const Text('no'));

      expect(trueWidget, isA<Text>());
      expect(falseWidget, isA<Text>());
    });

    test('ifTrue falls back to SizedBox when falseWidget is null', () {
      final widget = WidgetHelpers.ifTrue(false, () => const Text('yes'));
      expect(widget, isA<SizedBox>());
    });

    test('ifElseChain picks the first true case', () {
      final result = WidgetHelpers.ifElseChain(
        <SwitchCase>[
          SwitchCase(false, () => const Text('a')),
          SwitchCase(true, () => const Text('b')),
          SwitchCase(true, () => const Text('c')),
        ],
        () => const Text('else'),
      );

      expect(result, isA<Text>());
    });

    test('ifElseChain falls back to the else builder', () {
      final result = WidgetHelpers.ifElseChain(
        <SwitchCase>[SwitchCase(false, () => const Text('a'))],
        () => const Text('else'),
      );

      expect(result, isA<Text>());
    });

    test('ifElseChainMultiChild handles null builders', () {
      final result = WidgetHelpers.ifElseChainMultiChild(
        <SwitchCaseMultiChild>[
          SwitchCaseMultiChild(false, () => <Widget>[const Text('a')]),
        ],
        () => null,
      );

      expect(result, isEmpty);
    });

    test('switchValue uses the default builder when nothing matches', () {
      final result = WidgetHelpers.switchValue(
        'x',
        () => const Text('default'),
        <SwitchCase>[SwitchCase('a', () => const Text('a'))],
      );

      expect(result, isA<Text>());
    });

    test('mapToWidgetList maps items with indexes', () {
      final widgets = WidgetHelpers.mapToWidgetList<Text, String>(
        <String>['a', 'b'],
        (item, index) => Text('$item$index'),
      );

      expect(widgets, hasLength(2));
      expect(widgets, isA<List<Text>>());
    });

    test('mapToWidgetList returns an empty list for empty input', () {
      final widgets = WidgetHelpers.mapToWidgetList<Text, String>(
        <String>[],
        (item, index) => Text(item),
      );

      expect(widgets, isEmpty);
    });
  });

  group('Disable', () {
    testWidgets('passes null event when value is true', (tester) async {
      dynamic received;
      await tester.pumpWidget(
        Disable(
          value: true,
          event: () {},
          builder: (context, event) {
            received = event;
            return const SizedBox();
          },
        ),
      );

      expect(received, isNull);
    });

    testWidgets('passes the event when value is false', (tester) async {
      dynamic received;
      final event = () {};
      await tester.pumpWidget(
        Disable(
          value: false,
          event: event,
          builder: (context, e) {
            received = e;
            return const SizedBox();
          },
        ),
      );

      expect(received, same(event));
    });
  });

  group('AnimationBuilder', () {
    testWidgets('renders with a tweenMap and builderMap', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: AnimationBuilder(
            duration: const Duration(milliseconds: 500),
            autoTrigger: false,
            tweenMap: <String, Tween<dynamic>>{
              'opacity': Tween<double>(begin: 0.2, end: 1),
            },
            builderMap: _demoBuilderMap,
            child: const Text('animated'),
          ),
        ),
      );

      expect(find.text('animated'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('triggerAnimation runs the animation', (tester) async {
      final key = GlobalKey<AnimationBuilderState>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: AnimationBuilder(
            key: key,
            duration: const Duration(milliseconds: 300),
            autoTrigger: false,
            tweenMap: <String, Tween<dynamic>>{
              'opacity': Tween<double>(begin: 0.2, end: 1),
            },
            builderMap: _demoBuilderMap,
            child: const Text('animated'),
          ),
        ),
      );

      key.currentState!.triggerAnimation();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('animated'), findsOneWidget);
    });
  });

  group('PipeProvider', () {
    testWidgets('registers custom pipes and transforms values', (tester) async {
      await tester.pumpWidget(const SizedBox());
      final context = tester.element(find.byType(SizedBox));
      final provider = PipeProvider();
      provider.register(_UppercasePipe());

      expect(provider.transform(context, 'uppercase', 'hello', <dynamic>[]),
          'HELLO');
      expect(
        () => provider.transform(context, 'missing', 'x', <dynamic>[]),
        throwsException,
      );
    });
  });
}

Widget _demoBuilderMap(
    Map<String, Animation<dynamic>> animations, Widget? child) {
  return Opacity(
    opacity: animations['opacity']!.value as double,
    child: child,
  );
}

class _UppercasePipe extends Pipe {
  @override
  String get name => 'uppercase';

  @override
  dynamic transform(BuildContext context, dynamic value, List<dynamic> args) {
    return value.toString().toUpperCase();
  }
}
