import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vedem/core/error/exceptions.dart';
import 'package:vedem/features/rich_inputs/data/datasources/rich_inputs_local_data_source.dart';
import 'package:vedem/features/rich_inputs/data/models/rich_input_model.dart';
import 'package:vedem/features/rich_inputs/data/models/rich_input_part_model.dart';
import 'package:vedem/features/rich_inputs/domain/entities/rich_input_type.dart';

class MockBox extends Mock implements Box {}

void main() {
  late MockBox box;
  late RichInputsLocalDataSource dataSource;

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
  final String sampleKey = '2025-08-30';

  setUp(() {
    box = MockBox();
    dataSource = RichInputsLocalDataSource(box: box);
  });

  test('readRichInput should read from box when success', () async {
    when(
      () => box.get(sampleKey, defaultValue: any(named: 'defaultValue')),
    ).thenReturn(sampleRichInput);
    final res = await dataSource.readRichInput(sampleKey);
    expect(res, sampleRichInput);
  });
  test('readRichInput should throw [LocalHiveException] when error', () async {
    when(
      () => box.get(sampleKey, defaultValue: any(named: 'defaultValue')),
    ).thenThrow(Exception());
    expect(
      () async => await dataSource.readRichInput(sampleKey),
      throwsA(isA<LocalHiveException>()),
    );
  });

  test('writeRichInput should write to box when success', () async {
    when(() => box.put(any(), any())).thenAnswer((_) => Future.value());
    await dataSource.writeRichInput(sampleKey, sampleRichInput);
    verify(() => box.put(sampleKey, sampleRichInput));
  });
  test('writeRichInput should throw [LocalHiveException] when error', () async {
    when(() => box.put(any(), any())).thenThrow(Exception());
    expect(
      () async => await dataSource.writeRichInput(sampleKey, sampleRichInput),
      throwsA(isA<LocalHiveException>()),
    );
  });
}
