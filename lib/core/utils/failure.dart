import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({this.message, this.exception});

  final String? message;
  final Exception? exception;

  @override
  List<Object?> get props => [message, exception];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message, super.exception});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message, super.exception});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message, super.exception});
}

class ValidationFailure extends Failure {
  const ValidationFailure({super.message, super.exception});
}

class AuthFailure extends Failure {
  const AuthFailure({super.message, super.exception});
}

class TranscriptionFailure extends Failure {
  const TranscriptionFailure({super.message, super.exception});
}

class SyncFailure extends Failure {
  const SyncFailure({super.message, super.exception});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message, super.exception});
}
