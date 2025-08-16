# Vedem 1.0

O aplicatie simpla, complet locala, in flutter folosind clean architecture cu bloc, in care poti adauga taskuri cu diamante in fiecare zi si poti pune o poza drept daily highlight.

## Tech stack
- Flutter
- flutter_bloc (BLoC pattern)
- Hive (local persistence)
- path_provider + image_picker + flutter_image_compress
- Git + GitHub for VCS
- GitHub Actions for CI (lint & tests)

## How to run
1. Install Flutter SDK.
2. `flutter pub get`
3. `flutter run`

## Development workflow
- Branch from `main` into `feature/*`
- Use Conventional Commit messages, e.g. `feat(tasks): add TasksBloc subscribe`
- Open a PR for each feature/issue, run CI, self-review, merge when green.

## Roadmap (Milestones)
- Project scaffold & CI
- Tasks feature (local + BLoC)
- Highlights (image) feature (local)
- Day page (compose tasks + highlight)
- Tests, polish, release

## Notes
This repo uses Hive for local storage. Hive boxes (runtime files) are not committed — they live in device/app storage and should be ignored by `.gitignore`.
