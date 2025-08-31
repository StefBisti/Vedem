import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vedem/core/error/error_messages.dart';
import 'package:vedem/core/error/failures.dart';
import 'package:vedem/features/rich_inputs/data/models/rich_input_model.dart';
import 'package:vedem/features/rich_inputs/domain/usecases/load_rich_input_use_case.dart';
import 'package:vedem/features/rich_inputs/domain/usecases/save_rich_input_use_case.dart';
import 'package:vedem/features/rich_inputs/presentation/cubit/rich_inputs_cubit.dart';

class MockLoadRichInputUseCase extends Mock implements LoadRichInputUseCase {}

class FakeLoadRichInputUseCaseParams extends Fake
    implements LoadRichInputUseCaseParams {}

class MockSaveRichInputUseCase extends Mock implements SaveRichInputUseCase {}

class FakeSaveRichInputUseCaseParams extends Fake
    implements SaveRichInputUseCaseParams {}

void main() {
  late MockLoadRichInputUseCase load;
  late MockSaveRichInputUseCase save;
  late RichInputsCubit cubit;

  const testKey = "2025-08-30";
  final testEntity = RichInputModel.empty().toEntity()..initializePartsIds();

  setUp(() {
    load = MockLoadRichInputUseCase();
    save = MockSaveRichInputUseCase();
    cubit = RichInputsCubit(
      loadRichInputUseCase: load,
      saveRichInputUseCase: save,
    );
  });

  setUpAll(() {
    registerFallbackValue(FakeLoadRichInputUseCaseParams());
    registerFallbackValue(FakeSaveRichInputUseCaseParams());
  });

  group("loadRichInput", () {
    blocTest<RichInputsCubit, RichInputsState>(
      "emits [failure] when isLoading on load",
      build: () {
        return cubit;
      },
      seed: () => RichInputsState(richInput: testEntity, isLoading: true),
      act: (cubit) => cubit.loadRichInput(testKey),
      expect: () => [
        RichInputsState(
          richInput: testEntity,
          isLoading: true,
          error: noOperationWhileIsLoadingError,
        ),
      ],
    );

    blocTest<RichInputsCubit, RichInputsState>(
      "emits [loading, success] when load succeeds",
      build: () {
        when(() => load.call(any())).thenAnswer((_) async => right(testEntity));
        return cubit;
      },
      act: (cubit) => cubit.loadRichInput(testKey),
      expect: () => [
        const RichInputsState(isLoading: true, error: null),
        RichInputsState(richInput: testEntity, isLoading: false, error: null),
      ],
    );

    blocTest<RichInputsCubit, RichInputsState>(
      "emits [loading, error] when load fails",
      build: () {
        when(
          () => load.call(any()),
        ).thenAnswer((_) async => left(LocalHiveFailure(loadRichInputError)));
        return cubit;
      },
      act: (cubit) => cubit.loadRichInput(testKey),
      expect: () => [
        const RichInputsState(isLoading: true, error: null),
        const RichInputsState(isLoading: false, error: loadRichInputError),
      ],
    );
  });

  group("saveRichInput", () {
    blocTest<RichInputsCubit, RichInputsState>(
      "emits [failure] when isLoading",
      build: () {
        return cubit;
      },
      seed: () => RichInputsState(richInput: testEntity, isLoading: true),
      act: (cubit) => cubit.saveRichInput(testKey, testEntity),
      expect: () => [
        RichInputsState(
          richInput: testEntity,
          isLoading: true,
          error: noOperationWhileIsLoadingError,
        ),
      ],
    );
    blocTest<RichInputsCubit, RichInputsState>(
      "emits [loading, success] when save succeeds",
      build: () {
        when(() => save.call(any())).thenAnswer((_) async => right(unit));
        return cubit;
      },
      seed: () =>
          RichInputsState(richInput: testEntity, isLoading: false, error: null),
      act: (cubit) => cubit.saveRichInput(testKey, testEntity),
      expect: () => [
        RichInputsState(richInput: testEntity, isLoading: true, error: null),
        RichInputsState(richInput: testEntity, isLoading: false, error: null),
      ],
    );

    blocTest<RichInputsCubit, RichInputsState>(
      "emits [loading, error] when save fails",
      build: () {
        when(
          () => save.call(any()),
        ).thenAnswer((_) async => left(LocalHiveFailure(saveRichInputError)));
        return cubit;
      },
      seed: () =>
          RichInputsState(richInput: testEntity, isLoading: false, error: null),

      act: (cubit) => cubit.saveRichInput(testKey, testEntity),
      expect: () => [
        RichInputsState(richInput: testEntity, isLoading: true, error: null),
        RichInputsState(
          richInput: testEntity,
          isLoading: false,
          error: saveRichInputError,
        ),
      ],
    );
  });
}
