import 'package:flutter/widgets.dart';

import '../pipes/Pipe.dart';
import '../pipes/PrecentPipes.dart';

class PipeProvider {
  final Map<String, Pipe> _pipes = <String, Pipe>{};

  PipeProvider() {
    _registerBuiltInPipes();
  }

  void _registerBuiltInPipes() {
    register(WidthPercentPipe());
    register(HeightPercentPipe());
  }

  void register(Pipe pipe, {String? name}) {
    final key = (name == null || name.isEmpty) ? pipe.name : name;
    _pipes.putIfAbsent(key, () => pipe);
  }

  dynamic transform(
    BuildContext context,
    String name,
    dynamic value,
    List<dynamic> args,
  ) {
    final pipe = _pipes[name];
    if (pipe == null) {
      throw Exception('No such a pipe with name: "$name"');
    }
    return pipe.transform(context, value, args);
  }
}
