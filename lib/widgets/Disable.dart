import 'package:flutter/widgets.dart';

typedef DisableWidgetBuilder = Widget Function(
    BuildContext context, dynamic event);

class Disable extends StatelessWidget {
  const Disable({Key? key, this.value, this.builder, this.event})
      : super(key: key);

  final DisableWidgetBuilder? builder;
  final Function? event;
  final Object? value;

  @override
  Widget build(BuildContext context) {
    final builder = this.builder;
    if (builder == null) {
      return const SizedBox.shrink();
    }
    return builder(context, value == true ? null : event);
  }
}
