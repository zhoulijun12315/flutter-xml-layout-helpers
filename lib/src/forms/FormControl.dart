import 'dart:async';

import 'package:flutter/widgets.dart';

import '../value_stream.dart';
import 'Validator.dart';

enum ControlStatus { valid, invalid, pending, disabled }

class FormControl<T> {
  FormControl(
    String name,
    T value, {
    void Function(T value)? changesListener,
    List<Validator>? validators,
    List<FutureValidator>? futureValidators,
  })  : _name = name,
        _value = value,
        _originalValue = value,
        _valueStream = ValueStream<T>(value),
        _dirtyStream = ValueStream<bool>(false),
        _statusStream = ValueStream<ControlStatus>(ControlStatus.valid),
        _errorsStream = ValueStream<List<String>>(<String>[]) {
    _changesListener = changesListener;
    setValidators(validators);
    setFutureValidators(futureValidators);
    _setValue(value, markAsDirty: false);
  }

  final String _name;
  String get name => _name;

  final ValueStream<T> _valueStream;
  Stream<T> get valueStream => _valueStream.stream;

  final ValueStream<bool> _dirtyStream;
  Stream<bool> get dirtyStream => _dirtyStream.stream;
  bool get dirty => _dirtyStream.value;

  final ValueStream<ControlStatus> _statusStream;
  Stream<ControlStatus> get statusStream => _statusStream.stream;
  bool get valid => _statusStream.value == ControlStatus.valid;
  bool get invalid => _statusStream.value == ControlStatus.invalid;
  bool get pending => _statusStream.value == ControlStatus.pending;

  final ValueStream<List<String>> _errorsStream;
  Stream<List<String>> get errors => _errorsStream.stream;
  List<String> getErrors() => _errorsStream.value;
  String? get firstError => getErrors().isEmpty ? null : getErrors().first;
  String? get firstErrorIfTouched => _touched ? firstError : null;

  T _originalValue;
  T _value;
  T get value => _value;
  set value(T value) => _setValue(value);

  bool _touched = false;
  bool get touched => _touched;

  int _changesCount = 0;
  bool _internalSet = false;
  TextEditingController? _attachedController;
  List<Validator> _validators = <Validator>[];
  List<FutureValidator> _futureValidators = <FutureValidator>[];
  void Function(T value)? _changesListener;

  void setValidators(List<Validator>? validators) {
    _validators = validators ?? <Validator>[];
  }

  void setFutureValidators(List<FutureValidator>? futureValidators) {
    _futureValidators = futureValidators ?? <FutureValidator>[];
  }

  Future<void> validate() async {
    _statusStream.add(ControlStatus.pending);

    final List<String> errors = <String>[];
    for (final validator in _validators) {
      final error = validator.validate(_value);
      if (error != null && error.isNotEmpty) {
        errors.add(error);
      }
    }

    _errorsStream.add(errors);

    if (errors.isNotEmpty) {
      _statusStream.add(ControlStatus.invalid);
    } else if (_futureValidators.isNotEmpty) {
      try {
        final futures = <Future<String?>>[
          for (final validator in _futureValidators) validator.validate(_value),
        ];
        final results = await Future.wait(futures);
        final futureErrors = <String>[
          for (final error in results)
            if (error != null && error.isNotEmpty) error,
        ];
        _errorsStream.add(futureErrors);
        if (futureErrors.isNotEmpty) {
          _statusStream.add(ControlStatus.invalid);
        } else {
          _statusStream.add(ControlStatus.valid);
        }
      } catch (e) {
        // A throwing validator must not surface as an unhandled async error.
        _errorsStream.add(<String>['validation error: $e']);
        _statusStream.add(ControlStatus.invalid);
      }
    } else {
      _statusStream.add(ControlStatus.valid);
    }
  }

  void _setValue(T value, {bool internalSet = false, bool markAsDirty = true}) {
    if (markAsDirty && value != _value && !_dirtyStream.value) {
      _dirtyStream.value = true;
    }

    _value = value;
    _valueStream.add(value);

    if (!internalSet) {
      _setControllerValue();
    }

    validate();
    _changesListener?.call(value);
  }

  void reset(T value) {
    _originalValue = value;
    _dirtyStream.add(false);
    _setValue(value, internalSet: true, markAsDirty: false);
  }

  void commitChanges() {
    reset(_value);
  }

  void cancelChanges() {
    reset(_originalValue);
  }

  void attachTextEditingController(TextEditingController controller) {
    _attachedController = controller;
    _attachedController!.addListener(_controllerValueChanged);

    if (_value != null) {
      _setControllerValue();
    }
  }

  void _controllerValueChanged() {
    if (_internalSet) {
      return;
    }

    // First change comes from the focus event, subsequent ones from typing or
    // blur, which is what we treat as "touched".
    _touched = ++_changesCount > 1;

    _setValue(_attachedController!.text as T, internalSet: true);
  }

  void _setControllerValue() {
    final controller = _attachedController;
    if (controller == null) {
      return;
    }

    _internalSet = true;
    controller.text = _value.toString();
    _internalSet = false;
  }

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _attachedController?.removeListener(_controllerValueChanged);
    _attachedController?.clear();
    _attachedController?.dispose();
    _attachedController = null;
    _valueStream.close();
    _dirtyStream.close();
    _statusStream.close();
    _errorsStream.close();
  }

  bool _disposed = false;
}
