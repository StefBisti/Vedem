import 'package:vedem/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

/// Implementations should never throw; return Left(Failure) instead.
abstract interface class UseCase<R, P> {
  Future<Either<Failure, R>> call(P params);
}

const int delayedUseCaseMilliseconds = 300;

class NoParams {
  const NoParams();
}
