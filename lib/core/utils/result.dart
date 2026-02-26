import 'package:dartz/dartz.dart';

import 'failure.dart';

typedef Result<T> = Either<Failure, T>;
typedef FutureResult<T> = Future<Result<T>>;

extension ResultExtension<T> on Result<T> {
  T? getOrNull() => fold((l) => null, (r) => r);

  T getOrElse(T defaultValue) => fold((l) => defaultValue, (r) => r);

  T getOrThrow() => fold((l) => throw l, (r) => r);

  bool get isSuccess => isRight();

  bool get isFailure => isLeft();

  Failure? get failure => fold((l) => l, (r) => null);

  Result<R> mapSuccess<R>(R Function(T) mapper) {
    return fold(
      (failure) => Left(failure),
      (success) => Right(mapper(success)),
    );
  }
}
