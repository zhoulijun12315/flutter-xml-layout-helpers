import 'dart:async';

import '../value_stream.dart';
import 'FormControl.dart';
import 'Validator.dart';

class FormGroup {
  FormGroup();

  final Map<String, FormControl<dynamic>> _controls =
      <String, FormControl<dynamic>>{};
  Future<void> Function(dynamic data)? _submitCallback;
  StreamSubscription<dynamic>? _submitEnabledSubscription;
  StreamSubscription<ControlStatus>? _controlsStatusSubscription;
  Validator? _validator;

  final ValueStream<ControlStatus> _statusStream = ValueStream<ControlStatus>(
    ControlStatus.valid,
  );
  Stream<ControlStatus> get statusStream => _statusStream.stream;
  ControlStatus get status => _statusStream.value;
  bool get valid => _statusStream.value == ControlStatus.valid;
  bool get invalid => _statusStream.value == ControlStatus.invalid;
  bool get pending => _statusStream.value == ControlStatus.pending;

  final ValueStream<String> _errorStream = ValueStream<String>('');
  Stream<String> get error => _errorStream.stream;
  String getError() => _errorStream.value;

  final ValueStream<bool> _submitting = ValueStream<bool>(false);
  Stream<bool> get submittingStream => _submitting.stream;
  bool get submitting => _submitting.value;

  final ValueStream<bool> _submitEnabledStream = ValueStream<bool>(false);
  Stream<bool> get submitEnabledStream => _submitEnabledStream.stream;
  bool get submitEnabled => _submitEnabledStream.value;

  void add(FormControl<dynamic> control) {
    _controls[control.name] = control;
    _initStatusStream();
    validate();
  }

  void addAll(List<FormControl<dynamic>> controls) {
    for (final control in controls) {
      _controls[control.name] = control;
    }
    _initStatusStream();
    validate();
  }

  void remove(String key) {
    final control = _controls.remove(key);
    if (control != null) {
      _initStatusStream();
      validate();
      control.dispose();
    }
  }

  void removeAll(List<String> keys) {
    var hasControls = false;
    for (final key in keys) {
      final control = _controls.remove(key);
      if (control != null) {
        hasControls = true;
        control.dispose();
      }
    }
    if (hasControls) {
      _initStatusStream();
      validate();
    }
  }

  void _initStatusStream() {
    _controlsStatusSubscription?.cancel();
    _controlsStatusSubscription = mergeStreams<ControlStatus>(
      _controls.values.map((control) => control.statusStream).toList(),
    ).listen((_) => _updateStatusFromControls());

    _submitEnabledSubscription?.cancel();
    _submitEnabledSubscription = mergeStreams<Object?>(<Stream<Object?>>[
      _statusStream.stream,
      _submitting.stream,
    ]).listen((_) => _updateSubmitEnabled());

    // Recompute immediately so the group state reflects the current controls.
    // This mirrors the replay semantics the original code got from rxdart's
    // BehaviorSubject.
    _updateStatusFromControls();
    _updateSubmitEnabled();
  }

  void _updateStatusFromControls() {
    final hasInvalid = _controls.values.any((control) => control.invalid);
    if (hasInvalid) {
      _statusStream.add(ControlStatus.invalid);
      return;
    }

    final hasPending = _controls.values.any((control) => control.pending);
    if (hasPending) {
      _statusStream.add(ControlStatus.pending);
    } else {
      _runValidator();
      _setStatus();
    }
  }

  void _updateSubmitEnabled() {
    final newValue = status == ControlStatus.valid && !submitting;
    if (_submitEnabledStream.value != newValue) {
      _submitEnabledStream.value = newValue;
    }
  }

  bool _hasError() {
    return _errorStream.value.isNotEmpty;
  }

  void _runValidator() {
    final value = getValue();
    if (_validator != null) {
      _errorStream.value = _validator!.validate(value) ?? '';
    } else if (_errorStream.value.isNotEmpty) {
      _errorStream.value = '';
    }
  }

  void _setStatus() {
    if (_hasError()) {
      _statusStream.add(ControlStatus.invalid);
    } else {
      _errorStream.value = '';
      _statusStream.add(ControlStatus.valid);
    }
  }

  Future<void> validate() async {
    await Future.wait(_controls.values.map((control) => control.validate()));
  }

  bool hasControl(String name) {
    return _controls.containsKey(name);
  }

  FormControl<T> get<T>(String name) {
    final control = _controls[name];
    if (control == null) {
      throw Exception(
        "FormControl with name: $name not found. don't forget to add it to "
        'the formGroup: formGroup.addControl(FormControl<Type>(\'$name\', \'\'))',
      );
    }
    return control as FormControl<T>;
  }

  void setValue(Map<String, Object?> value) {
    _controls.forEach((name, control) {
      control.value = value[name];
    });
  }

  Map<String, Object?> getValue() {
    final values = <String, Object?>{};
    _controls.forEach((name, control) {
      values[name] = control.value;
    });
    return values;
  }

  void setValidator(Validator validator) {
    _validator = validator;
  }

  Future<void> submit() async {
    if (_submitCallback == null || _submitting.value) {
      return;
    }

    _submitting.value = true;
    try {
      await validate();
      if (valid) {
        await _submitCallback!(getValue());
      }
    } finally {
      _submitting.value = false;
    }
  }

  void onSubmit(Future<void> Function(dynamic data) submitCallback) {
    _submitCallback = submitCallback;
  }

  void dispose() {
    _controlsStatusSubscription?.cancel();
    _controlsStatusSubscription = null;
    _submitEnabledSubscription?.cancel();
    _submitEnabledSubscription = null;
    _submitEnabledStream.close();
    _submitting.close();
    _errorStream.close();
    _statusStream.close();
    for (final control in _controls.values) {
      control.dispose();
    }
  }
}
