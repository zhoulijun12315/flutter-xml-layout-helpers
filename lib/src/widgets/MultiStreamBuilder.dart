import 'dart:async';

import 'package:flutter/widgets.dart';

/// Rebuilds its subtree whenever **any** of the given streams emits.
///
/// Unlike nesting several `StreamBuilder`s, the render condition is not tied
/// to the stream values — the subtree always renders and simply refreshes on
/// every emission. [builder] receives the latest value of each stream
/// (null until a stream has emitted).
class MultiStreamBuilder extends StatefulWidget {
  const MultiStreamBuilder({
    Key? key,
    required this.streams,
    required this.builder,
  }) : super(key: key);

  final List<Stream<dynamic>> streams;
  final Widget Function(BuildContext context, List<dynamic> values) builder;

  @override
  State<MultiStreamBuilder> createState() => _MultiStreamBuilderState();
}

class _MultiStreamBuilderState extends State<MultiStreamBuilder> {
  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];
  late List<dynamic> _values;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _values = List<dynamic>.filled(widget.streams.length, null);
    _subscribe();
  }

  @override
  void didUpdateWidget(MultiStreamBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.streams, widget.streams)) {
      _cancel();
      _values = List<dynamic>.filled(widget.streams.length, null);
      _ready = false;
      _subscribe();
    }
  }

  void _subscribe() {
    for (var i = 0; i < widget.streams.length; i++) {
      _subscriptions.add(
        widget.streams[i].listen(
          (value) {
            _values[i] = value;
            if (_ready && mounted) {
              setState(() {});
            }
          },
          onError: (Object _) {
            // Ignore stream errors; values simply stay unchanged.
          },
        ),
      );
    }
    _ready = true;
  }

  void _cancel() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _values);
  }
}
