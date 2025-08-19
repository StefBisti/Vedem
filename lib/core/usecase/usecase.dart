import 'package:vedem/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class UseCase<ReturnType, Params> {
  Future<Either<Failure, ReturnType>> call(Params params);
}

class NoParams {
  const NoParams();
}
