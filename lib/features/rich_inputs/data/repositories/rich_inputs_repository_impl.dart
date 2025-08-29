import 'package:fpdart/fpdart.dart';
import 'package:vedem/core/error/exceptions.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/features/rich_inputs/data/datasources/rich_inputs_data_source.dart';
import 'package:vedem/features/rich_inputs/data/models/rich_input_model.dart';
import 'package:vedem/features/rich_inputs/domain/entities/rich_input_entity.dart';
import 'package:vedem/features/rich_inputs/domain/repositories/rich_inputs_repository.dart';

class RichInputsRepositoryImpl implements RichInputsRepository {
  final RichInputsDataSource dataSource;

  const RichInputsRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, RichInputEntity>> loadRichInput(String dayId) async {
    try {
      RichInputModel loadedRichInput = await dataSource.readRichInput(dayId);
      return right(loadedRichInput.toEntity());
    } on LocalHiveException catch (e) {
      return left(LocalHiveFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveRichInput(
    String dayId,
    RichInputEntity newRichInput,
  ) async {
    try {
      await dataSource.writeRichInput(
        dayId,
        RichInputModel.fromEntity(newRichInput),
      );
      return right(unit);
    } on LocalHiveException catch (e) {
      return left(LocalHiveFailure(e.message));
    }
  }
}
