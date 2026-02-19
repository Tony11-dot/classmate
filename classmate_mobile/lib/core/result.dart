class Result<T> {
  final T? value;
  final String? error;

  const Result._(this.value, this.error);

  bool get isOk => error == null;

  static Result<T> ok<T>(T value) => Result._(value, null);
  static Result<T> err<T>(String message) => Result._(null, message);
}
