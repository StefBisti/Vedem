import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/features/rich_inputs/domain/entities/rich_input_entity.dart';

abstract interface class RichInputsRepository {
  Future<Either<Failure, RichInputEntity>> loadRichInput(String dayId);

  Future<Either<Failure, Unit>> saveRichInput(
    String dayId,
    RichInputEntity newRichInput,
  );
}
