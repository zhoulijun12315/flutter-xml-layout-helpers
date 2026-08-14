// ignore_for_file: unnecessary_null_comparison, prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, prefer_interpolation_to_compose_strings, use_key_in_widget_constructors, library_private_types_in_public_api, unnecessary_cast, unnecessary_type_check, dead_code

import 'package:xml_layout_demo/demo/demo_widgets.dart';
import 'package:xml_layout_demo/demo/live_xml_playground.dart';
import 'demo_page.ctrl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xml_layout_helpers/headers.dart';
import 'package:provider/provider.dart';

class DemoPage extends StatefulWidget {
  DemoPage();

  @override
  _DemoPageState createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> with TickerProviderStateMixin {
  late DemoController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = DemoController();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => mounted ? ctrl.afterFirstBuild(context) : null);
  }

  @override
  void didUpdateWidget(DemoPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    ctrl.didUpdateWidgetPreHook(oldWidget);

    ctrl.didUpdateWidgetPostHook(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ctrl._load(context);
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pipeProvider = context.watch<PipeProvider>();
    final layout = Scaffold(
      appBar: AppBar(
        title: Text(
          'XML Layout for Flutter — Demo',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DemoHero(),
              LiveXmlPlayground(),
              DemoSection(
                description:
                    ':xxx 前缀的包装属性会自动给 widget 套上 Padding / Opacity / Visibility / SizedBox / Align / Transform / Theme 等容器。',
                icon: Icons.auto_awesome,
                title: '1. Wrapper properties',
                xml: ctrl.wrappersXml,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Container(
                            color: Colors.indigo.shade100,
                            height: 42,
                            width: 86,
                            child: Text(
                              ':margin',
                            ),
                          ),
                        ),
                        Container(
                          color: Colors.teal.shade100,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              ':padding',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                      child: Row(
                        children: [
                          Opacity(
                            opacity: 0.45,
                            child: Text(
                              ':opacity 0.45',
                            ),
                          ),
                          StreamBuilder(
                            initialData: true,
                            stream: ctrl.showSecondStream,
                            builder: (BuildContext context,
                                ctrlShowSecondStreamSnapshot) {
                              final ctrlShowSecondStreamValue =
                                  ctrlShowSecondStreamSnapshot.data;
                              if (ctrlShowSecondStreamValue == null) {
                                return Container(width: 0, height: 0);
                              }
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                                child: Visibility(
                                  visible: ctrlShowSecondStreamValue,
                                  child: Text(
                                    ':visible',
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            height: 30,
                            width: 74,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                              child: Container(
                                color: Colors.amber,
                                child: Text(
                                  ':w / :h',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: Transform.scale(
                              scale: 1.15,
                              child: Container(
                                color: Colors.pink.shade100,
                                height: 44,
                                width: 44,
                                child: Text(
                                  ':scale',
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: Transform.rotate(
                              angle: 0.15,
                              child: Container(
                                color: Colors.orange.shade100,
                                height: 44,
                                width: 44,
                                child: Text(
                                  ':rotate',
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: Transform.translate(
                              offset: Offset(0, -4),
                              child: Container(
                                color: Colors.green.shade100,
                                height: 44,
                                width: 44,
                                child: Text(
                                  ':translate',
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: SizedBox(
                              width: 44,
                              child: AspectRatio(
                                aspectRatio: 1.2,
                                child: Container(
                                  color: Colors.purple.shade100,
                                  child: Text(
                                    ':aspect',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              color: Colors.blue.shade200,
                              height: 34,
                              child: Text(
                                ':flex 1',
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(6, 0, 0, 0),
                              child: Container(
                                color: Colors.cyan.shade200,
                                height: 34,
                                child: Text(
                                  ':flex 2',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                      child: Row(
                        children: [
                          Container(
                            color: Colors.blueGrey.shade100,
                            height: 56,
                            width: 180,
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                color: Colors.blueGrey,
                                height: 24,
                                width: 70,
                                child: Text(
                                  ':align',
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                            child: Theme(
                              data: ThemeData(
                                  colorScheme: ColorScheme.fromSeed(
                                      seedColor: Colors.deepOrange)),
                              child: Container(
                                child: FilledButton(
                                  onPressed: null,
                                  child: Text(
                                    ':theme',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                      child: Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Container(
                              color: Colors.indigo,
                              height: 40,
                              width: 120,
                              child: Text(
                                ':center 居中',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              DemoSection(
                description:
                    '管道把值转换与 UI 分离：widthPercent/heightPercent 按屏幕比例计算，stream 跟随流更新，自定义管道可带参数。',
                icon: Icons.filter_alt,
                title: '2. Pipes',
                xml: ctrl.pipesXml,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'widthPercent → 80% of screen width:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                        child: Container(
                          color: Colors.green,
                          height: 22,
                          width: pipeProvider
                              .transform(context, "widthPercent", 80, []),
                          child: Text(
                            '80%',
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Text(
                        'heightPercent → 3% of screen height:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                      child: Container(
                        color: Colors.deepOrange,
                        height: pipeProvider
                            .transform(context, "heightPercent", 3, []),
                        width: 140,
                      ),
                    ),
                    StreamBuilder(
                      initialData: '--',
                      stream: ctrl.clockStream,
                      builder: (BuildContext context, ctrlClockStreamSnapshot) {
                        final ctrlClockStreamValue =
                            ctrlClockStreamSnapshot.data;
                        if (ctrlClockStreamValue == null) {
                          return Container(width: 0, height: 0);
                        }
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Text(
                            'stream → ' + (ctrlClockStreamValue),
                          ),
                        );
                      },
                    ),
                    StreamBuilder(
                      initialData: 0,
                      stream: ctrl.counterStream,
                      builder:
                          (BuildContext context, ctrlCounterStreamSnapshot) {
                        final ctrlCounterStreamValue =
                            ctrlCounterStreamSnapshot.data;
                        if (ctrlCounterStreamValue == null) {
                          return Container(width: 0, height: 0);
                        }
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                          child: Text(
                            'counter → ' + (ctrlCounterStreamValue).toString(),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                      child: Text(
                        'custom pipe with args → ' +
                            (pipeProvider.transform(context, "truncate",
                                'This is a long text', [10])),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                      child: Text(
                        pipeProvider.transform(
                            context,
                            "uppercase",
                            pipeProvider
                                .transform(context, "translate", 'hello', []),
                            []),
                      ),
                    ),
                  ],
                ),
              ),
              DemoSection(
                description:
                    ':if / <if> 元素 / :switch 都支持 stream 管道，可以响应式地切换分支。',
                icon: Icons.alt_route,
                title: '3. Conditionals',
                xml: ctrl.conditionalsXml,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreamBuilder(
                      initialData: true,
                      stream: ctrl.showConditionalStream,
                      builder: (BuildContext context,
                          ctrlShowConditionalStreamSnapshot) {
                        final ctrlShowConditionalStreamValue =
                            ctrlShowConditionalStreamSnapshot.data;
                        if (ctrlShowConditionalStreamValue == null) {
                          return Container(width: 0, height: 0);
                        }
                        return WidgetHelpers.ifTrue(
                            ctrlShowConditionalStreamValue,
                            () => Text(
                                  ':if → true branch',
                                ),
                            () => Container(width: 0, height: 0));
                      },
                    ),
                    StreamBuilder(
                      initialData: true,
                      stream: ctrl.showConditionalStream,
                      builder: (BuildContext context,
                          ctrlShowConditionalStreamSnapshot) {
                        final ctrlShowConditionalStreamValue =
                            ctrlShowConditionalStreamSnapshot.data;
                        if (ctrlShowConditionalStreamValue == null) {
                          return Container(width: 0, height: 0);
                        }
                        return WidgetHelpers.ifElseChain(
                            [
                              SwitchCase(
                                  ctrlShowConditionalStreamValue,
                                  () => Text(
                                        '<if> element → true branch',
                                      )),
                              SwitchCase(
                                  false,
                                  () => Text(
                                        '<elseIf>',
                                      )),
                            ],
                            () => Text(
                                  '<else>',
                                ));
                      },
                    ),
                    StreamBuilder(
                      initialData: 0,
                      stream: ctrl.selectedIndexStream,
                      builder: (BuildContext context,
                          ctrlSelectedIndexStreamSnapshot) {
                        final ctrlSelectedIndexStreamValue =
                            ctrlSelectedIndexStreamSnapshot.data;
                        if (ctrlSelectedIndexStreamValue == null) {
                          return Container(width: 0, height: 0);
                        }
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: Container(
                            child: WidgetHelpers.switchValue(
                                ctrlSelectedIndexStreamValue,
                                () => Container(width: 0, height: 0), [
                              SwitchCase(
                                  0,
                                  () => Text(
                                        ':switch → case 0',
                                      )),
                              SwitchCase(
                                  1,
                                  () => Text(
                                        ':switch → case 1',
                                      )),
                              SwitchCase(
                                  2,
                                  () => Text(
                                        ':switch → case 2',
                                      )),
                            ]),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                      child: Wrap(
                        children: [
                          TextButton(
                            onPressed: ctrl.toggleConditional,
                            child: Text(
                              'Toggle :if',
                            ),
                          ),
                          TextButton(
                            onPressed: ctrl.cycleSelection,
                            child: Text(
                              'Cycle :switch',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              DemoSection(
                description:
                    ':repeat 把列表映射成一组 widget；:childBuilder 直接生成 children；:use builder + :itemBuilder 生成 ListView.builder。',
                icon: Icons.list_alt,
                title: '4. Lists & builders',
                xml: ctrl.listsXml,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ':repeat →',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    ...WidgetHelpers.mapToWidgetList(ctrl.items, (item, index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(8, 2, 0, 0),
                        child: Text(
                          '• ' + item.toString(),
                        ),
                      );
                    }),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Text(
                        ':childBuilder →',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    SizedBox(
                      height: 56,
                      child: ListView(
                        children: WidgetHelpers.mapToWidgetList(ctrl.items,
                            (item, index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(8, 2, 0, 0),
                            child: Text(
                              '* ' + item.toString(),
                            ),
                          );
                        }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Text(
                        ':itemBuilder (ListView.builder) →',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                      child: SizedBox(
                        height: 150,
                        child: ListView.builder(
                          itemCount: ctrl.demoItems.length,
                          itemBuilder: (BuildContext context, int index) {
                            final DemoItem item = ctrl.demoItems[index];
                            return ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigo.shade200,
                                radius: 14,
                                child: Text(
                                  item.title.substring(0, 1),
                                ),
                              ),
                              title: Text(
                                item.title,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Text(
                        ':childBuilder + stream（点按钮动态加项）→',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    SizedBox(
                      height: 90,
                      child: StreamBuilder(
                        initialData: null,
                        stream: ctrl.itemsStream,
                        builder:
                            (BuildContext context, ctrlItemsStreamSnapshot) {
                          final ctrlItemsStreamValue =
                              ctrlItemsStreamSnapshot.data;
                          if (ctrlItemsStreamValue == null) {
                            return Container(width: 0, height: 0);
                          }
                          return ListView(
                            children: WidgetHelpers.mapToWidgetList(
                                ctrlItemsStreamValue, (item, index) {
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(8, 2, 0, 0),
                                child: Text(
                                  '* ' + item.toString(),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                    TextButton(
                      onPressed: ctrl.addItem,
                      child: Text(
                        '添加一项',
                      ),
                    ),
                  ],
                ),
              ),
              DemoSection(
                description:
                    ':formControl + FormGroup 双向绑定表单状态；:formSubmit 在表单无效时自动禁用；校验错误和提交状态通过 stream 展示。',
                icon: Icons.edit_note,
                title: '5. Forms',
                xml: ctrl.formsXml,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Text fields:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    StreamBuilder(
                      initialData: ctrl.formGroup.get('name').value,
                      stream: ctrl.formGroup.get('name').valueStream,
                      builder: (BuildContext context,
                          ctrlFormGroupGetNameValueStreamSnapshot) {
                        return TextField(
                          controller: ctrl._attachController(ctrl.formGroup,
                              'name', () => TextEditingController()),
                          decoration: InputDecoration(
                              labelText: 'Name', border: OutlineInputBorder()),
                        );
                      },
                    ),
                    StreamBuilder(
                      initialData: ctrl.formGroup.get('email').value,
                      stream: ctrl.formGroup.get('email').valueStream,
                      builder: (BuildContext context,
                          ctrlFormGroupGetEmailValueStreamSnapshot) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: TextField(
                            controller: ctrl._attachController(ctrl.formGroup,
                                'email', () => TextEditingController()),
                            decoration: InputDecoration(
                                labelText: 'Email (required)',
                                border: OutlineInputBorder()),
                          ),
                        );
                      },
                    ),
                    StreamBuilder(
                      initialData: '[]',
                      stream: ctrl.emailErrorStream,
                      builder:
                          (BuildContext context, ctrlEmailErrorStreamSnapshot) {
                        final ctrlEmailErrorStreamValue =
                            ctrlEmailErrorStreamSnapshot.data;
                        if (ctrlEmailErrorStreamValue == null) {
                          return Container(width: 0, height: 0);
                        }
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                          child: Text(
                            'email error → ' + (ctrlEmailErrorStreamValue),
                          ),
                        );
                      },
                    ),
                    StreamBuilder(
                      initialData: ctrl.formGroup.submitEnabled,
                      stream: ctrl.formGroup.submitEnabledStream,
                      builder: (BuildContext context,
                          ctrlFormGroupSubmitEnabledStreamSnapshot) {
                        final ctrlFormGroupSubmitEnabledStreamValue =
                            ctrlFormGroupSubmitEnabledStreamSnapshot.data;
                        return Disable(
                          event: ctrl.formGroup.submit,
                          value: !((ctrlFormGroupSubmitEnabledStreamValue) ==
                              true),
                          builder: (BuildContext context, event) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                              child: ElevatedButton(
                                onPressed: event,
                                child: Text(
                                  'Submit',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    StreamBuilder(
                      initialData: false,
                      stream: ctrl.formGroup.submitEnabledStream,
                      builder: (BuildContext context,
                          ctrlFormGroupSubmitEnabledStreamSnapshot) {
                        final ctrlFormGroupSubmitEnabledStreamValue =
                            ctrlFormGroupSubmitEnabledStreamSnapshot.data;
                        if (ctrlFormGroupSubmitEnabledStreamValue == null) {
                          return Container(width: 0, height: 0);
                        }
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: Text(
                            'submit enabled → ' +
                                (ctrlFormGroupSubmitEnabledStreamValue)
                                    .toString(),
                          ),
                        );
                      },
                    ),
                    StreamBuilder(
                      initialData: '-',
                      stream: ctrl.lastSubmitStream,
                      builder:
                          (BuildContext context, ctrlLastSubmitStreamSnapshot) {
                        final ctrlLastSubmitStreamValue =
                            ctrlLastSubmitStreamSnapshot.data;
                        if (ctrlLastSubmitStreamValue == null) {
                          return Container(width: 0, height: 0);
                        }
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                          child: Text(
                            'last submit → ' + (ctrlLastSubmitStreamValue),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              DemoSection(
                description:
                    'apply-animation 用 tweenMap 驱动属性动画：autoTrigger 自动播放，repeats 循环，也可以通过控制器随时触发。',
                icon: Icons.movie_filter,
                title: '6. Animation',
                xml: ctrl.animationXml,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'autoTrigger color →',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: AnimationBuilder(
                          autoTrigger: true,
                          duration: Duration(milliseconds: 800),
                          key: ctrl._colorAnimKey,
                          tweenMap: {
                            "color": ColorTween(
                                begin: Colors.orange, end: Colors.blueAccent)
                          },
                          builderMap:
                              (Map<String, Animation<dynamic>> animations,
                                  Widget? child) {
                            return Container(
                              color: animations["color"]!.value,
                              height: 44,
                              width: 200,
                              child: Text(
                                'Color',
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Text(
                        'size pulse（勾选循环后无限播放，否则播放一次）→',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: AnimationBuilder(
                          curve: Curves.easeOutBack,
                          duration: Duration(milliseconds: 600),
                          key: ctrl._sizeAnimKey,
                          tweenMap: {
                            "height": Tween<double>(begin: 40, end: 64),
                            "width": Tween<double>(begin: 120, end: 200)
                          },
                          builderMap:
                              (Map<String, Animation<dynamic>> animations,
                                  Widget? child) {
                            return Container(
                              height: animations["height"]!.value,
                              width: animations["width"]!.value,
                              child: Text(
                                'Pulse',
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            StreamBuilder(
                              initialData: false,
                              stream: ctrl.loopingStream,
                              builder: (BuildContext context,
                                  ctrlLoopingStreamSnapshot) {
                                final ctrlLoopingStreamValue =
                                    ctrlLoopingStreamSnapshot.data;
                                if (ctrlLoopingStreamValue == null) {
                                  return Container(width: 0, height: 0);
                                }
                                return Switch(
                                  onChanged: (v) => ctrl.setLooping(v),
                                  value: ctrlLoopingStreamValue,
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(6, 0, 0, 0),
                              child: Text(
                                '循环播放',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: ctrl.playSizeAnim,
                      child: Text(
                        '播放 / 重新播放',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Text(
                        '控制器触发 →',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: AnimationBuilder(
                          duration: Duration(milliseconds: 800),
                          key: ctrl._fadeAnimKey,
                          tweenMap: {
                            "color": ColorTween(
                                begin: Colors.green, end: Colors.purpleAccent)
                          },
                          builderMap:
                              (Map<String, Animation<dynamic>> animations,
                                  Widget? child) {
                            return Container(
                              color: animations["color"]!.value,
                              height: 44,
                              width: 200,
                              child: Text(
                                'Replay',
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: ctrl.replayAnimation,
                      child: Text(
                        'Replay animation',
                      ),
                    ),
                  ],
                ),
              ),
              DemoSection(
                description:
                    ':disable 在条件为真时禁用点击事件（onPressed 置空）。初始可用，点 3 次后自动禁用。',
                icon: Icons.block,
                title: '7. Disable',
                xml: ctrl.disableXml,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    StreamBuilder(
                      initialData: false,
                      stream: ctrl.enabledStream,
                      builder:
                          (BuildContext context, ctrlEnabledStreamSnapshot) {
                        final ctrlEnabledStreamValue =
                            ctrlEnabledStreamSnapshot.data;
                        return Disable(
                          event: ctrl.increment,
                          value: ctrlEnabledStreamValue,
                          builder: (BuildContext context, event) {
                            return ElevatedButton(
                              onPressed: event,
                              child: Text(
                                'Increment (auto-disable after 3)',
                              ),
                            );
                          },
                        );
                      },
                    ),
                    StreamBuilder(
                      initialData: 0,
                      stream: ctrl.counterStream,
                      builder:
                          (BuildContext context, ctrlCounterStreamSnapshot) {
                        final ctrlCounterStreamValue =
                            ctrlCounterStreamSnapshot.data;
                        if (ctrlCounterStreamValue == null) {
                          return Container(width: 0, height: 0);
                        }
                        return Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(
                            'counter → ' + (ctrlCounterStreamValue).toString(),
                          ),
                        );
                      },
                    ),
                    StreamBuilder(
                      initialData: false,
                      stream: ctrl.enabledStream,
                      builder:
                          (BuildContext context, ctrlEnabledStreamSnapshot) {
                        final ctrlEnabledStreamValue =
                            ctrlEnabledStreamSnapshot.data;
                        if (ctrlEnabledStreamValue == null) {
                          return Container(width: 0, height: 0);
                        }
                        return Text(
                          'enabled → ' + (ctrlEnabledStreamValue).toString(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              DemoSection(
                description:
                    ':onTap / :onLongPress 包装属性自动套上 GestureDetector，事件计数通过 stream 管道实时显示。',
                icon: Icons.touch_app,
                title: '8. Events & gestures',
                xml: ctrl.eventsXml,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreamBuilder(
                      initialData: 0,
                      stream: ctrl.tapCountStream,
                      builder:
                          (BuildContext context, ctrlTapCountStreamSnapshot) {
                        final ctrlTapCountStreamValue =
                            ctrlTapCountStreamSnapshot.data;
                        if (ctrlTapCountStreamValue == null) {
                          return Container(width: 0, height: 0);
                        }
                        return Text(
                          'taps → ' + (ctrlTapCountStreamValue).toString(),
                        );
                      },
                    ),
                    StreamBuilder(
                      initialData: 0,
                      stream: ctrl.longPressCountStream,
                      builder: (BuildContext context,
                          ctrlLongPressCountStreamSnapshot) {
                        final ctrlLongPressCountStreamValue =
                            ctrlLongPressCountStreamSnapshot.data;
                        if (ctrlLongPressCountStreamValue == null) {
                          return Container(width: 0, height: 0);
                        }
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                          child: Text(
                            'long presses → ' +
                                (ctrlLongPressCountStreamValue).toString(),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                      child: Wrap(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: GestureDetector(
                              onTap: ctrl.handleTap,
                              child: Container(
                                color: Colors.blue.shade100,
                                height: 48,
                                width: 110,
                                child: Text(
                                  'Tap me',
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: GestureDetector(
                              onLongPress: ctrl.handleLongPress,
                              child: Container(
                                color: Colors.deepOrange.shade100,
                                height: 48,
                                width: 150,
                                child: Text(
                                  'Long press me',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              DemoSection(
                description:
                    ':stream 包装属性把任意 Stream 变成响应式数据源，子 widget 通过流里的值自由切换。',
                icon: Icons.bolt,
                title: '9. Streams & reactivity',
                xml: ctrl.streamsXml,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 110,
                      child: StreamBuilder(
                        initialData: 0,
                        stream: ctrl.selectedTabStream,
                        builder: (BuildContext context,
                            ctrlSelectedTabStreamSnapshot) {
                          final selectedTabValue =
                              ctrlSelectedTabStreamSnapshot.data;
                          return Stack(
                            children: [
                              Opacity(
                                opacity: selectedTabValue == 0 ? 1 : 0.15,
                                child: Container(
                                  color: Colors.blue.shade100,
                                  child: Text(
                                    'Tab 0 — blue',
                                  ),
                                ),
                              ),
                              Opacity(
                                opacity: selectedTabValue == 1 ? 1 : 0.15,
                                child: Container(
                                  color: Colors.pink.shade100,
                                  child: Text(
                                    'Tab 1 — pink',
                                  ),
                                ),
                              ),
                              Opacity(
                                opacity: selectedTabValue == 2 ? 1 : 0.15,
                                child: Container(
                                  color: Colors.amber.shade100,
                                  child: Text(
                                    'Tab 2 — amber',
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () => ctrl.selectTab(0),
                            child: Text(
                              '0',
                            ),
                          ),
                          TextButton(
                            onPressed: () => ctrl.selectTab(1),
                            child: Text(
                              '1',
                            ),
                          ),
                          TextButton(
                            onPressed: () => ctrl.selectTab(2),
                            child: Text(
                              '2',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              DemoSection(
                description:
                    ':consumer 从 Provider 树取数据，子 widget 通过变量直接使用（这里是 PipeProvider）。',
                icon: Icons.account_tree,
                title: '10. Consumer & Provider',
                xml: ctrl.consumerXml,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'PipeProvider via :consumer →',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Consumer<PipeProvider>(
                      builder: (BuildContext context, PipeProvider pipeProvider,
                          Widget? child) {
                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            color: Colors.orange,
                            height: 26,
                            width: pipeProvider
                                .transform(context, "widthPercent", 60, []),
                            child: Text(
                              pipeProvider.transform(
                                  context, 'widthPercent', 60, []).toString(),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              DemoSection(
                description:
                    'lib/i18n/*.json 自动生成本地化类，translate 管道按当前 Locale 取翻译，按钮可切换中英文。',
                icon: Icons.translate,
                title: '11. i18n',
                xml: ctrl.i18nXml,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'translate → ' +
                          (pipeProvider
                              .transform(context, "translate", 'hello', [])),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                      child: Text(
                        'translate → ' +
                            (pipeProvider.transform(
                                context, "translate", 'goodbye', [])),
                      ),
                    ),
                    StreamBuilder(
                      initialData: 'en',
                      stream: ctrl.localeNameStream,
                      builder:
                          (BuildContext context, ctrlLocaleNameStreamSnapshot) {
                        final ctrlLocaleNameStreamValue =
                            ctrlLocaleNameStreamSnapshot.data;
                        if (ctrlLocaleNameStreamValue == null) {
                          return Container(width: 0, height: 0);
                        }
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: Text(
                            'locale → ' + (ctrlLocaleNameStreamValue),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                      child: FilledButton(
                        onPressed: ctrl.toggleLocale,
                        child: Text(
                          'Switch locale',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              DemoSection(
                description: '通过 xmlns 导入手写组件后，XML 里可以直接使用，扩展自己的组件库。',
                icon: Icons.widgets,
                title: '12. 自定义组件 (xmlns)',
                xml: ctrl.customXml,
                child: Wrap(
                  children: [
                    DemoBadge(
                      color: Colors.orange,
                      text: '自定义组件 A',
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                      child: DemoBadge(
                        color: Colors.teal,
                        text: '自定义组件 B',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                      child: DemoBadge(
                        color: Colors.purple,
                        text: '自定义组件 C',
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                child: Container(
                  color: Colors.grey.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '完整源码：demo_page.xml · 生成代码：demo_page.xml.dart · 控制器：demo_page.ctrl.dart',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return layout;
  }
}

class DemoControllerBase {
  bool _loaded = false;
  final formGroup = FormGroup();
  final _colorAnimKey = GlobalKey<AnimationBuilderState>();
  AnimationBuilderStateMixin get colorAnim =>
      _colorAnimKey.currentState as AnimationBuilderStateMixin;
  final _sizeAnimKey = GlobalKey<AnimationBuilderState>();
  AnimationBuilderStateMixin get sizeAnim =>
      _sizeAnimKey.currentState as AnimationBuilderStateMixin;
  final _fadeAnimKey = GlobalKey<AnimationBuilderState>();
  AnimationBuilderStateMixin get fadeAnim =>
      _fadeAnimKey.currentState as AnimationBuilderStateMixin;
  Map<String, dynamic> _attachedControllers = <String, dynamic>{};

  dynamic _attachController(
      FormGroup formGroup, String controlName, controllerBuilder) {
    if (_attachedControllers.containsKey(controlName)) {
      final controller = _attachedControllers[controlName];
      return controller;
    }
    final controller = controllerBuilder();
    _attachedControllers[controlName] = controller;
    formGroup.get(controlName).attachTextEditingController(controller);
    return controller;
  }

  void _load(BuildContext context) {
    if (!_loaded) {
      _loaded = true;
      didLoad(context);
    }

    onBuild(context);
  }

  void didLoad(BuildContext context) {}

  void onBuild(BuildContext context) {}

  void afterFirstBuild(BuildContext context) {}

  void didUpdateWidgetPreHook(dynamic oldWidget) {}
  void didUpdateWidgetPostHook(dynamic oldWidget) {}

  @mustCallSuper
  void dispose() {
    formGroup.dispose();
  }
}
