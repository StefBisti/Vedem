import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:vedem/core/error/error_messages.dart';
import 'package:vedem/core/hive/app_hive.dart';
import 'package:vedem/features/rich_inputs/data/datasources/rich_inputs_data_source.dart';
import 'package:vedem/features/rich_inputs/data/datasources/rich_inputs_local_data_source.dart';
import 'package:vedem/features/rich_inputs/data/models/rich_input_model.dart';
import 'package:vedem/features/rich_inputs/data/models/rich_input_model_adapter.dart';
import 'package:vedem/features/rich_inputs/data/models/rich_input_part_model.dart';
import 'package:vedem/features/rich_inputs/data/models/rich_input_part_model_adapter.dart';
import 'package:vedem/features/rich_inputs/data/models/rich_input_type_adapter.dart';
import 'package:vedem/features/rich_inputs/data/repositories/rich_inputs_repository_impl.dart';
import 'package:vedem/features/rich_inputs/domain/entities/rich_input_entity.dart';
import 'package:vedem/features/rich_inputs/domain/entities/rich_input_type.dart';
import 'package:vedem/features/rich_inputs/domain/repositories/rich_inputs_repository.dart';
import 'package:vedem/features/rich_inputs/domain/usecases/load_rich_input_use_case.dart';
import 'package:vedem/features/rich_inputs/domain/usecases/save_rich_input_use_case.dart';
import 'package:vedem/features/rich_inputs/presentation/cubit/rich_inputs_cubit.dart';

// tests saving + loading, not complex text manipulation
void main() {
  late Directory tmpDir;
  late Box<RichInputModel> box;
  late RichInputsDataSource dataSource;
  late RichInputsRepository repo;
  late LoadRichInputUseCase loadRichInputUseCase;
  late SaveRichInputUseCase saveRichInputUseCase;
  late RichInputsCubit cubit;

  setUpAll(() async {
    tmpDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tmpDir.path);
    Hive.registerAdapter(RichInputTypeAdapter());
    Hive.registerAdapter(RichInputPartModelAdapter());
    Hive.registerAdapter(RichInputModelAdapter());
  });

  setUp(() async {
    box = await Hive.openBox<RichInputModel>('daily_inputs_test');
    dataSource = RichInputsLocalDataSource(box: box);
    repo = RichInputsRepositoryImpl(dataSource: dataSource);
    loadRichInputUseCase = LoadRichInputUseCase(repository: repo);
    saveRichInputUseCase = SaveRichInputUseCase(repository: repo);
    cubit = RichInputsCubit(
      loadRichInputUseCase: loadRichInputUseCase,
      saveRichInputUseCase: saveRichInputUseCase,
    );
  });

  tearDown(() async {
    await box.clear();
    await box.close();
  });

  tearDownAll(() async {
    await Hive.close();
    await tmpDir.delete(recursive: true);
  });

  final String sampleKey = '2025-08-30';
  final String sampleKey2 = '2025-08-31';
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
  final RichInputModel sampleRichInput2 = RichInputModel(
    parts: [
      RichInputPartModel(
        type: RichInputType.bullet,
        content: 'test 11',
        padding: 0,
      ),
      RichInputPartModel(
        type: RichInputType.plain,
        content: 'test 22',
        padding: 203,
      ),
    ],
  );

  test(
    'When reading from a non existing key, the rich input should be empty',
    () async {
      await cubit.loadRichInput(sampleKey);
      expect(
        cubit.state,
        RichInputsState(
          richInput: RichInputEntity.empty(),
          isLoading: false,
          error: null,
        ),
      );
    },
  );
  test('Loading 2 times immediately gives error and loads first one', () async {
    box.put(sampleKey, sampleRichInput);

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        RichInputsState(
          richInput: RichInputEntity.empty(),
          isLoading: true,
          error: null,
        ),
        RichInputsState(
          richInput: RichInputEntity.empty(),
          isLoading: true,
          error: noOperationWhileIsLoadingError,
        ),
        RichInputsState(
          richInput: sampleRichInput.toEntity(),
          isLoading: false,
          error: null,
        ),
      ]),
    );

    cubit.loadRichInput(sampleKey);
    cubit.loadRichInput('other key');

    await expectation;
  });
  
  test('App flow', () async {
    
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        // User has no inputs, but loads one
        RichInputsState(
          richInput: RichInputEntity.empty(),
          isLoading: true,
          error: null,
        ),
        RichInputsState(
          richInput: RichInputEntity.empty(),
          isLoading: false,
          error: null,
        ),
        // User has no inputs, loads another one
        RichInputsState(
          richInput: RichInputEntity.empty(),
          isLoading: true,
          error: null,
        ),
        RichInputsState(
          richInput: RichInputEntity.empty(),
          isLoading: false,
          error: null,
        ),
        // User saves something here
        RichInputsState(
          richInput: RichInputEntity.empty(),
          isLoading: true,
          error: null,
        ),
        RichInputsState(
          richInput: sampleRichInput.toEntity(),
          isLoading: false,
          error: null,
        ),
        // User loads previous input
        // User loads second input again
      ]),
    );


    await cubit.loadRichInput(sampleKey);
    expect(
        cubit.state,
        RichInputsState(
          richInput: RichInputEntity.empty(),
          isLoading: false,
          error: null,
        ),
      );
  });
}
