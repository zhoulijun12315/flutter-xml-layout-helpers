import 'package:flutter/widgets.dart';

import 'Pipe.dart';

class WidthPercentPipe extends Pipe {
  @override
  String get name => 'widthPercent';

  @override
  dynamic transform(BuildContext context, dynamic value, List<dynamic> args) {
    final size = MediaQuery.of(context).size;
    return (size.width * value) / 100.0;
  }
}

class HeightPercentPipe extends Pipe {
  @override
  String get name => 'heightPercent';

  @override
  dynamic transform(BuildContext context, dynamic value, List<dynamic> args) {
    final size = MediaQuery.of(context).size;
    return (size.height * value) / 100.0;
  }
}
