import 'dart:async';

/// A lightweight broadcast stream holder that keeps the latest value.
///
/// This is an internal implementation detail that replaces the small subset
/// of `rxdart`'s `BehaviorSubject` used by this package, so the package does
/// not need to depend on `rxdart`.
class ValueStream<T> {
  ValueStream(this._value);

  T _value;
  final StreamController<T> _controller = StreamController<T>.broadcast(
    sync: true,
  );

  /// The latest value.
  T get value => _value;

  /// The broadcast stream. Listeners receive values emitted after they
  /// subscribe; use [value] to read the current value.
  Stream<T> get stream => _controller.stream;

  /// Updates the current value and emits it to listeners.
  void add(T value) {
    _value = value;
    if (!_controller.isClosed) {
      _controller.add(value);
    }
  }

  set value(T value) => add(value);

  Future<void> close() => _controller.close();
}

/// Merges multiple streams into a single synchronous broadcast stream.
///
/// Replaces `StreamGroup.merge` from `package:async` so the package does not
/// need that dependency. The merged stream stays open until the consumer
/// cancels its subscription.
Stream<T> mergeStreams<T>(Iterable<Stream<T>> streams) {
  final controller = StreamController<T>.broadcast(sync: true);
  final subscriptions = <StreamSubscription<T>>[];
  for (final stream in streams) {
    subscriptions.add(
      stream.listen(
        controller.add,
        onError: (Object error, StackTrace stackTrace) {
          controller.addError(error, stackTrace);
        },
        onDone: () {
          // Keep the merged stream open; individual sources may complete.
        },
      ),
    );
  }
  controller.onCancel = () {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    controller.close();
  };
  return controller.stream;
}
