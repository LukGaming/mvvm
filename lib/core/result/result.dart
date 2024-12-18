abstract class Result<T extends Object> {
  const Result();

  factory Result.ok(T value) = Ok._;

  factory Result.error(Exception error) = ResultError._;
}

final class Ok<T extends Object> extends Result<T> {
  Ok._(this.value);
  final T value;
}

final class ResultError<T extends Object> extends Result<T> {
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

extension ResultCasting<T extends Object> on Result<T> {
  Ok<T> get asOk => this as Ok<T>;

  ResultError<T> get asError => this as ResultError<T>;
}
