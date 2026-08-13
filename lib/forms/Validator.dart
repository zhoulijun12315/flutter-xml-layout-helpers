typedef ValidateFn<T, V> = T Function(V? value);

abstract class Validator {
  /// Returns an error message if [value] is invalid, or `null` when valid.
  String? validate(Object? value) => null;
}

class FutureValidator {
  FutureValidator(this._validateFn);

  final ValidateFn<Future<String?>, Object> _validateFn;

  Future<String?> validate(Object? value) => _validateFn(value);
}

class FnValidator extends Validator {
  FnValidator(this._validateFn);

  final ValidateFn<String?, Object> _validateFn;

  @override
  String? validate(Object? value) => _validateFn(value);
}

class Validators {
  static final FnValidator required = FnValidator((value) {
    if (value != null && value is String && value.isNotEmpty) {
      return null;
    }
    return 'required';
  });
}
