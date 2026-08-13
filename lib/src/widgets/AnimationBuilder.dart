import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Animates widgets declared in XML layouts.
///
/// Adapted from https://github.com/GIfatahTH/animator (see the original source
/// for the design; this version is null-safe and no longer depends on rxdart).
class AnimationBuilder extends StatefulWidget {
  AnimationBuilder({
    Key? key,
    this.controller,
    this.animation,
    this.child,
    this.tween,
    this.duration,
    this.curve = Curves.linear,
    this.cycles,
    this.repeats,
    this.builder,
    this.builderMap,
    this.tweenMap,
    this.name,
    this.autoTrigger,
    this.customListener,
    this.endAnimationListener,
    this.statusListener,
  })  : assert(
          builder != null || builderMap != null,
          'You have to define one of the "builder" or "builderMap" argument',
        ),
        assert(
          builder == null || builderMap == null,
          'You have to define either builder or "builderMap" argument. '
          "you can't define both",
        ),
        assert(
          builderMap == null || tweenMap != null,
          '"tweenMap" must not be null. If you have one tween use '
          '"builder" argument instead',
        ),
        super(key: key ?? UniqueKey());

  final Widget? child;

  final AnimationController? controller;
  final Animation<double>? animation;

  /// A linear interpolation between a beginning and ending value.
  ///
  /// `tween` is used for a single [Animation<double>] animation.
  final Tween<double>? tween;

  /// The duration of the animation.
  final Duration? duration;

  /// An easing curve, i.e. a mapping of the unit interval to the unit
  /// interval.
  final Curve curve;

  /// The number of forward and backward periods the animation performs before
  /// stopping.
  final int? cycles;

  /// The number of forward periods the animation performs before stopping.
  final int? repeats;

  /// Whether to start the animation when the [AnimationBuilder] widget is
  /// inserted into the tree.
  final bool? autoTrigger;

  /// Called every time the animation value changes.
  final VoidCallback? customListener;

  /// Called when the animation finishes.
  final VoidCallback? endAnimationListener;

  /// Called every time the status of the animation changes.
  final ValueChanged<AnimationStatus>? statusListener;

  /// Builds the widget for a single-tween animation.
  final Widget Function(Animation<double>, Widget?)? builder;

  /// Builds the widget for a multi-tween animation.
  final Widget Function(Map<String, Animation<dynamic>>, Widget?)? builderMap;

  /// A map of tweens used with [builderMap].
  final Map<String, Tween<dynamic>>? tweenMap;

  /// The name of this [AnimationBuilder] widget. Many widgets can share the
  /// same name; it is used to trigger the animation from logic classes.
  final dynamic name;

  @override
  AnimationBuilderState createState() => AnimationBuilderState();
}

class AnimationBuilderStateMixin {
  AnimationController? get controller => null;

  void triggerAnimation({
    int? cycles,
    int? repeats,
    bool dispose = false,
    bool reset = false,
  }) {}
}

class AnimationBuilderState extends State<AnimationBuilder>
    with TickerProviderStateMixin, AnimationBuilderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;
  Map<String, Animation<dynamic>> _animationMap =
      <String, Animation<dynamic>>{};
  late Tween<dynamic> _tween;

  VoidCallback? _listener;
  ValueChanged<AnimationStatus>? _statusListener;
  ValueChanged<AnimationStatus>? _repeatStatusListener;
  VoidCallback? _endAnimationListener;

  bool _disposed = false;

  bool get _controllerIsDisposed => _disposed;

  int? _cycles;
  int? _repeats;

  @override
  AnimationController? get controller => _controller;

  @override
  void initState() {
    _tween = widget.tween ?? Tween<double>(begin: 0, end: 1);
    _listener = widget.customListener;
    _statusListener = widget.statusListener;
    _endAnimationListener = widget.endAnimationListener;
    _initAnimation(
      dispose: false,
      trigger: widget.autoTrigger ?? false,
      cycles: widget.cycles,
      repeats: widget.repeats,
    );
    super.initState();
  }

  void _initAnimation({
    bool trigger = false,
    int? cycles,
    int? repeats,
    bool dispose = false,
  }) {
    if (_controller == null || _controllerIsDisposed) {
      _controller = widget.controller ??
          AnimationController(duration: widget.duration, vsync: this);
    }

    final controller = _controller!;
    _animation = _tween.animate(
      widget.animation ??
          CurvedAnimation(parent: controller, curve: widget.curve),
    ) as Animation<double>;

    final tweenMap = widget.tweenMap;
    if (tweenMap != null) {
      _animationMap = <String, Animation<dynamic>>{};
      tweenMap.forEach((key, tween) {
        final parent = widget.animation ??
            CurvedAnimation(parent: controller, curve: widget.curve);
        _animationMap[key] = tween.animate(parent);
      });
    }

    final animation = _animation!;
    if (_listener != null) {
      animation.addListener(_listener!);
    }
    if (_statusListener != null) {
      animation.addStatusListener(_statusListener!);
    }

    if (cycles != null) {
      _cycles = cycles;
      _addCycleStatusListener(cycles, dispose, _endAnimationListener);
    } else {
      final repeatCount = repeats ?? 1;
      _repeats = repeatCount;
      _addRepeatStatusListener(repeatCount, dispose, _endAnimationListener);
    }

    if (trigger) {
      controller.forward();
    }
  }

  /// Starts running this animation forwards (towards the end).
  void triggerAnimation({
    int? cycles,
    int? repeats,
    bool dispose = false,
    bool reset = false,
  }) {
    if (_disposed) {
      return;
    }
    _initAnimation(
      repeats: repeats ?? _repeats,
      cycles: cycles ?? _cycles,
      dispose: dispose,
    );

    final controller = _controller!;
    if (reset && cycles == null && _cycles == null) {
      controller.reset();
    }

    if (controller.isDismissed) {
      controller.forward();
    } else if (controller.isCompleted && (cycles != null || _cycles != null)) {
      controller.reverse();
    } else {
      controller.reset();
      controller.forward();
    }
  }

  void _addCycleStatusListener(
    int cycles,
    bool dispose,
    VoidCallback? endAnimationListener,
  ) {
    final animation = _animation!;
    final controller = _controller!;
    if (_repeatStatusListener != null) {
      animation.removeStatusListener(_repeatStatusListener!);
    }
    if (cycles == 0) {
      _repeatStatusListener = (AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        }
        if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      };
    } else {
      late final ValueChanged<AnimationStatus> repeatStatusListener;
      repeatStatusListener = (AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          cycles--;
          if (cycles <= 0) {
            animation.removeStatusListener(repeatStatusListener);
            if (dispose) {
              _disposeAnimation();
            }
            endAnimationListener?.call();
            return;
          }
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          cycles--;
          if (cycles <= 0) {
            animation.removeStatusListener(repeatStatusListener);
            if (dispose) {
              _disposeAnimation();
            }
            endAnimationListener?.call();
            return;
          }
          controller.forward();
        }
      };
      _repeatStatusListener = repeatStatusListener;
    }
    animation.addStatusListener(_repeatStatusListener!);
  }

  /// Removes listeners and disposes the animation controller.
  void _disposeAnimation() {
    final listener = _listener;
    if (listener != null) {
      _animation?.removeListener(listener);
    }
    final statusListener = _statusListener;
    if (statusListener != null) {
      _animation?.removeStatusListener(statusListener);
    }
    if (!_controllerIsDisposed) {
      _controller?.dispose();
    }
  }

  void _addRepeatStatusListener(
    int repeats,
    bool dispose,
    VoidCallback? endAnimationListener,
  ) {
    final animation = _animation!;
    final controller = _controller!;
    if (_repeatStatusListener != null) {
      animation.removeStatusListener(_repeatStatusListener!);
    }
    if (repeats == 0) {
      _repeatStatusListener = (AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          controller.reset();
          controller.forward();
        }
      };
    } else {
      late final ValueChanged<AnimationStatus> repeatStatusListener;
      repeatStatusListener = (AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          repeats--;
          if (repeats <= 0) {
            animation.removeStatusListener(repeatStatusListener);
            endAnimationListener?.call();
            return;
          }
          controller.reset();
          controller.forward();
        }
      };
      _repeatStatusListener = repeatStatusListener;
    }
    animation.addStatusListener(_repeatStatusListener!);
  }

  @override
  void dispose() {
    _disposed = true;
    final listener = _listener;
    if (listener != null) {
      _animation?.removeListener(listener);
    }
    final statusListener = _statusListener;
    if (statusListener != null) {
      _animation?.removeStatusListener(statusListener);
    }
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation!,
      child: widget.child,
      builder: (context, child) {
        final builder = widget.builder;
        if (builder != null) {
          return builder(_animation!, child);
        }
        return widget.builderMap!(_animationMap, child);
      },
    );
  }
}
