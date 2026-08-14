import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_xml_layout_helpers/headers.dart';

import '../locale_controller.dart';
import 'demo_page.xml.dart';

class DemoItem {
  DemoItem(this.title);

  final String title;
}

class DemoController extends DemoControllerBase {
  String get wrappersXml => r'''
<Container :margin="4" width="86" height="42"
           color="Colors.indigo.shade100">
  <Text text="':margin'" />
</Container>
<Text :opacity="0.45" text="':opacity 0.45'" />
<Container :width="74" :height="30" color="Colors.amber">
  <Text text="':w / :h'" />
</Container>
<Container :scale="1.15" :rotate="0.15"
           :translate="Offset(0, -4)" :aspectRatio="1.2" />
<Container :flex="1" height="34" color="Colors.blue.shade200" />
<SizedBox width="180" height="56" color="Colors.blueGrey.shade100">
  <Container :align="Alignment.bottomRight" width="70" height="24"
             color="Colors.blueGrey" />
</SizedBox>
<Container :theme="ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange))">
  <FilledButton onPressed="null"><Text text="':theme'" /></FilledButton>
</Container>
<Container color="Colors.grey.shade200">
  <Container :margin="12" width="120" height="40"
             color="Colors.indigo" :center>
    <Text text="':center 居中'" />
  </Container>
</Container>
''';

  String get pipesXml => r'''
<Container width="80 | widthPercent" height="22"
           color="Colors.green">
  <Text text="'80%'" />
</Container>
<Container width="140" height="3 | heightPercent"
           color="Colors.deepOrange" />
<Text text="'stream → ' + (ctrl.clockStream | stream:'--')" />
<Text text="'counter → ' + (ctrl.counterStream | stream:0).toString()" />
<Text text="'custom pipe → ' + ('This is a long text' | truncate:10)" />
''';

  String get conditionalsXml => r'''
<Text :if="ctrl.showConditionalStream | stream:true"
      text="':if → true branch'" />
<if value="ctrl.showConditionalStream | stream:true">
  <Text text="'<if> element → true branch'" />
</if>
<elseIf value="false"><Text text="'<elseIf>'" /></elseIf>
<else><Text text="'<else>'" /></else>
<Container :switch="ctrl.selectedIndexStream | stream:0">
  <Text :switchCase="0" text="':switch → case 0'" />
  <Text :switchCase="1" text="':switch → case 1'" />
</Container>
''';

  String get listsXml => r'''
<Text :repeat="item of ctrl.items"
      text="'• ' + item.toString()" />
<ListView :childBuilder="item of ctrl.items">
  <Text text="'* ' + item.toString()" />
</ListView>
<ListView :use="builder"
          :itemBuilder="DemoItem item of ctrl.demoItems"
          itemCount="ctrl.demoItems.length">
  <ListTile>
    <title><Text text="item.title" /></title>
  </ListTile>
</ListView>
<ListView :childBuilder="item of ctrl.itemsStream | stream">
  <Text text="'* ' + item.toString()" />
</ListView>
''';

  String get formsXml => r'''
<TextField :formControl="'name'"
  decoration="InputDecoration(labelText: 'Name')" />
<TextField :formControl="'email'" :margin="8 0 0 0"
  decoration="InputDecoration(labelText: 'Email (required)')" />
<ElevatedButton :formSubmit="formGroup" :margin="8 0 0 0">
  <Text text="'Submit'" />
</ElevatedButton>
''';

  String get animationXml => r'''
<Container width="220" height="56" :center>
  <Text text="'Color'" />
  <apply-animation name="colorAnim"
      duration="milliseconds: 800" autoTrigger>
    <color type="color" begin="Colors.orange"
           end="Colors.blueAccent" />
  </apply-animation>
</Container>
<Container :center>
  <apply-animation name="sizeAnim" duration="milliseconds: 600">
    <width type="double" begin="120" end="200" />
    <height type="double" begin="40" end="64" />
  </apply-animation>
</Container>
<Switch value="ctrl.loopingStream | stream:false"
        onChanged="(v) => ctrl.setLooping(v)" />
<TextButton onPressed="ctrl.playSizeAnim">
  <Text text="'播放 / 重新播放'" />
</TextButton>
<apply-animation name="fadeAnim" duration="milliseconds: 800">
  <color type="color" begin="Colors.green"
         end="Colors.purpleAccent" />
</apply-animation>
''';

  String get disableXml => r'''
<ElevatedButton :disable="ctrl.enabledStream | stream:false"
                onPressed="ctrl.increment">
  <Text text="'Increment (auto-disable after 3)'" />
</ElevatedButton>
<Text text="'counter → ' + (ctrl.counterStream | stream:0).toString()" />
''';

  String get eventsXml => r'''
<Container :onTap="ctrl.handleTap" width="110" height="48"
           color="Colors.blue.shade100" :center>
  <Text text="'Tap me'" />
</Container>
<Container :onLongPress="ctrl.handleLongPress" width="150"
           height="48" color="Colors.deepOrange.shade100" :center>
  <Text text="'Long press me'" />
</Container>
''';

  String get streamsXml => r'''
<Stack :stream="ctrl.selectedTabStream:0:selectedTabValue"
       height="110">
  <Container :opacity="selectedTabValue == 0 ? 1 : 0.15"
             color="Colors.blue.shade100" />
  <Container :opacity="selectedTabValue == 1 ? 1 : 0.15"
             color="Colors.pink.shade100" />
</Stack>
<Container :watch="ctrl.tapCountStream, ctrl.longPressCountStream">
  <Text text="'taps → ' + (ctrl.tapCountStream | stream:0).toString()" />
</Container>
''';

  String get i18nXml => r'''
<Text text="'translate → ' + ('hello' | translate)" />
<FilledButton onPressed="ctrl.toggleLocale">
  <Text text="'Switch locale'" />
</FilledButton>
''';

  String get consumerXml => r'''
<Container :consumer="PipeProvider pipeProvider"
           width="60 | widthPercent" height="26"
           color="Colors.orange">
  <Text text="pipeProvider.transform(context, 'widthPercent', 60, []).toString()" />
</Container>
''';

  String get customXml => r'''
<DemoBadge text="'自定义组件 A'" color="Colors.orange" />
<DemoBadge text="'自定义组件 B'" color="Colors.teal" />
''';

  final StreamController<bool> _showConditionalController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _showSecondController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _enabledController =
      StreamController<bool>.broadcast();
  final StreamController<int> _selectedIndexController =
      StreamController<int>.broadcast();
  final StreamController<int> _counterController =
      StreamController<int>.broadcast();
  final StreamController<String> _lastSubmitController =
      StreamController<String>.broadcast();
  final StreamController<String> _localeNameController =
      StreamController<String>.broadcast();
  final StreamController<int> _selectedTabController =
      StreamController<int>.broadcast();
  final StreamController<int> _tapCountController =
      StreamController<int>.broadcast();
  final StreamController<int> _longPressCountController =
      StreamController<int>.broadcast();
  final StreamController<String> _emailErrorController =
      StreamController<String>.broadcast();
  final StreamController<String> _clockController =
      StreamController<String>.broadcast();
  final StreamController<bool> _loopingController =
      StreamController<bool>.broadcast();
  final StreamController<List<String>> _itemsStreamController =
      StreamController<List<String>>.broadcast();

  StreamSubscription<List<String>>? _emailErrorsSubscription;
  Timer? _clockTimer;

  late final Stream<bool> showConditionalStream =
      _showConditionalController.stream;
  late final Stream<bool> showSecondStream = _showSecondController.stream;
  late final Stream<bool> enabledStream = _enabledController.stream;
  late final Stream<int> selectedIndexStream = _selectedIndexController.stream;
  late final Stream<int> counterStream = _counterController.stream;
  late final Stream<String> lastSubmitStream = _lastSubmitController.stream;
  late final Stream<String> localeNameStream = _localeNameController.stream;
  late final Stream<int> selectedTabStream = _selectedTabController.stream;
  late final Stream<int> tapCountStream = _tapCountController.stream;
  late final Stream<int> longPressCountStream =
      _longPressCountController.stream;
  late final Stream<String> emailErrorStream = _emailErrorController.stream;
  late final Stream<bool> loopingStream = _loopingController.stream;
  late final Stream<List<String>> itemsStream = _itemsStreamController.stream;
  Stream<String> get clockStream => _clockController.stream;

  bool _showConditional = true;
  bool _showSecond = true;
  bool _enabled = true;
  int _selectedIndex = 0;
  int _counter = 0;
  int _tapCount = 0;
  int _longPressCount = 0;
  bool _looping = false;

  final List<String> items = <String>['Alpha', 'Beta', 'Gamma'];
  final List<DemoItem> demoItems = <DemoItem>[
    DemoItem('Alpha'),
    DemoItem('Beta'),
    DemoItem('Gamma'),
    DemoItem('Delta'),
  ];

  void toggleConditional() {
    _showConditional = !_showConditional;
    _showConditionalController.add(_showConditional);
  }

  void toggleSecond() {
    _showSecond = !_showSecond;
    _showSecondController.add(_showSecond);
  }

  void cycleSelection() {
    _selectedIndex = (_selectedIndex + 1) % 3;
    _selectedIndexController.add(_selectedIndex);
  }

  void increment() {
    _counter++;
    _counterController.add(_counter);
    if (_counter >= 3 && _enabled) {
      _enabled = false;
      _enabledController.add(false);
    }
  }

  void selectTab(int index) {
    _selectedTabController.add(index);
  }

  void handleTap() {
    _tapCount++;
    _tapCountController.add(_tapCount);
  }

  void handleLongPress() {
    _longPressCount++;
    _longPressCountController.add(_longPressCount);
  }

  void toggleLocale() {
    LocaleController.toggle();
    _localeNameController.add(LocaleController.locale.value.languageCode);
  }

  void replayAnimation() {
    fadeAnim.triggerAnimation();
  }

  void setLooping(bool value) {
    _looping = value;
    _loopingController.add(value);
  }

  void playSizeAnim() {
    sizeAnim.triggerAnimation(repeats: _looping ? 0 : 1);
  }

  void addItem() {
    items.add('Item ${items.length + 1}');
    _itemsStreamController.add(List<String>.of(items));
  }

  @override
  void didLoad(BuildContext context) {
    formGroup.add(FormControl<String>('name', ''));
    formGroup.add(
      FormControl<String>('email', '', validators: [Validators.required]),
    );
    formGroup.onSubmit((data) async {
      _lastSubmitController.add(data.toString());
    });
    _emailErrorsSubscription = formGroup.get('email').errors.listen((errors) {
      _emailErrorController.add(errors.toString());
    });
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final h = now.hour.toString().padLeft(2, '0');
      final m = now.minute.toString().padLeft(2, '0');
      final s = now.second.toString().padLeft(2, '0');
      _clockController.add('$h:$m:$s');
    });
  }

  @override
  void dispose() {
    _emailErrorsSubscription?.cancel();
    _clockTimer?.cancel();
    _clockController.close();
    _showConditionalController.close();
    _showSecondController.close();
    _enabledController.close();
    _selectedIndexController.close();
    _counterController.close();
    _lastSubmitController.close();
    _localeNameController.close();
    _selectedTabController.close();
    _tapCountController.close();
    _longPressCountController.close();
    _emailErrorController.close();
    _loopingController.close();
    _itemsStreamController.close();
    super.dispose();
  }
}
