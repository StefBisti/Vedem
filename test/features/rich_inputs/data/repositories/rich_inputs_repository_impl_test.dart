import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vedem/core/error/error_messages.dart';
import 'package:vedem/core/error/exceptions.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/features/rich_inputs/data/datasources/rich_inputs_data_source.dart';
import 'package:vedem/features/rich_inputs/data/models/rich_input_model.dart';
import 'package:vedem/features/rich_inputs/data/models/rich_input_part_model.dart';
import 'package:vedem/features/rich_inputs/data/repositories/rich_inputs_repository_impl.dart';
import 'package:vedem/features/rich_inputs/domain/entities/rich_input_entity.dart';
import 'package:vedem/features/rich_inputs/domain/entities/rich_input_part_entity.dart';
import 'package:vedem/features/rich_inputs/domain/entities/rich_input_type.dart';

class MockRichInputsDataSource extends Mock implements RichInputsDataSource {}

void main() {
  late MockRichInputsDataSource dataSource;
  late RichInputsRepositoryImpl repo;

  final RichInputModel sampleRichInput = RichInputModel(
    parts: [
      RichInputPartModel(
        type: RichInputType.bullet,
        content: 'test 1',
        padding: 0,
      ),
      RichInputPartModel(
        type: RichInputType.plain,
        content: 'test 2',
        padding: 20,
      ),
    ],
  );
  final RichInputEntity sampleRichInputEntity = RichInputEntity(
    parts: [
      RichInputPartEntity(
        type: RichInputType.bullet,
        content: 'test 1',
        padding: 0,
      ),
      RichInputPartEntity(
        type: RichInputType.plain,
        content: 'test 2',
        padding: 20,
      ),
    ],
  );
  final String sampleKey = '2025-08-30';

  setUp(() {
    dataSource = MockRichInputsDataSource();
    repo = RichInputsRepositoryImpl(dataSource: dataSource);
  });

  test('loadRichInput should return RichInputModel when success', () async {
    when(
      () => dataSource.readRichInput(sampleKey),
    ).thenAnswer((_) async => sampleRichInput);
    final res = await repo.loadRichInput(sampleKey);
    expect(res, right(sampleRichInputEntity));
    expect(res, isNot(right(sampleRichInput)));
  });
  test('loadRichInput should return LocalHiveFailure when error', () async {
    when(
      () => dataSource.readRichInput(sampleKey),
    ).thenThrow(LocalHiveException(message: loadRichInputError));
    final res = await repo.loadRichInput(sampleKey);
    expect(res, left(LocalHiveFailure(loadRichInputError)));
    verify(() => dataSource.readRichInput(sampleKey)).called(1);
  });

  test('saveRichInput should return unit when success', () async {
    when(
      () => dataSource.writeRichInput(sampleKey, sampleRichInput),
    ).thenAnswer((_) => Future.value());
    final res = await repo.saveRichInput(sampleKey, sampleRichInputEntity);
    expect(res, right(unit));
    verify(
      () => dataSource.writeRichInput(sampleKey, sampleRichInput),
    ).called(1);
  });
  test('saveRichInput should return LocalHiveFailure when error', () async {
    when(
      () => dataSource.writeRichInput(sampleKey, sampleRichInput),
    ).thenThrow(LocalHiveException(message: loadRichInputError));
    final res = await repo.saveRichInput(sampleKey, sampleRichInputEntity);
    expect(res, left(LocalHiveFailure(loadRichInputError)));
    verify(() => dataSource.writeRichInput(sampleKey, sampleRichInput)).called(1);
  });
}
