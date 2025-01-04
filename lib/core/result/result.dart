abstract class Result<T> {
  const Result();

  factory Result.ok(T value) = Ok._;

  factory Result.error(Exception error) = ResultError._;
}

final class Ok<T> extends Result<T> {
  Ok._(this.value);
  final T value;
}

final class ResultError<T> extends Result<T> {
  ResultError._(this.error);

  Exception error;
}

extension ResultExtension on Object {
  Result ok() {
    return Result.ok(this);
  }
}

extension ResultException on Exception {
  Result error() {
    return Result.error(this);
  }
}

extension ResultCasting<T> on Result<T> {
  Ok<T> get asOk => this as Ok<T>;

  ResultError<T> get asError => this as ResultError<T>;
}
