// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_finish_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(workoutFinishRepo)
final workoutFinishRepoProvider = WorkoutFinishRepoProvider._();

final class WorkoutFinishRepoProvider
    extends
        $FunctionalProvider<
          WorkoutFinishRepo,
          WorkoutFinishRepo,
          WorkoutFinishRepo
        >
    with $Provider<WorkoutFinishRepo> {
  WorkoutFinishRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutFinishRepoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutFinishRepoHash();

  @$internal
  @override
  $ProviderElement<WorkoutFinishRepo> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WorkoutFinishRepo create(Ref ref) {
    return workoutFinishRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkoutFinishRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkoutFinishRepo>(value),
    );
  }
}

String _$workoutFinishRepoHash() => r'798782e7488c811e6fdb83f5480ac5f0b30a7e71';

@ProviderFor(uploadWorkoutFinish)
final uploadWorkoutFinishProvider = UploadWorkoutFinishFamily._();

final class UploadWorkoutFinishProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  UploadWorkoutFinishProvider._({
    required UploadWorkoutFinishFamily super.from,
    required ({WorkoutFinish workoutFinish, List<String> imageUrls})
    super.argument,
  }) : super(
         retry: null,
         name: r'uploadWorkoutFinishProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$uploadWorkoutFinishHash();

  @override
  String toString() {
    return r'uploadWorkoutFinishProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument =
        this.argument
            as ({WorkoutFinish workoutFinish, List<String> imageUrls});
    return uploadWorkoutFinish(
      ref,
      workoutFinish: argument.workoutFinish,
      imageUrls: argument.imageUrls,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UploadWorkoutFinishProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$uploadWorkoutFinishHash() =>
    r'2a137263c25713cec7003afb92f212b5944180ad';

final class UploadWorkoutFinishFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<void>,
          ({WorkoutFinish workoutFinish, List<String> imageUrls})
        > {
  UploadWorkoutFinishFamily._()
    : super(
        retry: null,
        name: r'uploadWorkoutFinishProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UploadWorkoutFinishProvider call({
    required WorkoutFinish workoutFinish,
    required List<String> imageUrls,
  }) => UploadWorkoutFinishProvider._(
    argument: (workoutFinish: workoutFinish, imageUrls: imageUrls),
    from: this,
  );

  @override
  String toString() => r'uploadWorkoutFinishProvider';
}

@ProviderFor(deleteWorkoutFinish)
final deleteWorkoutFinishProvider = DeleteWorkoutFinishFamily._();

final class DeleteWorkoutFinishProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  DeleteWorkoutFinishProvider._({
    required DeleteWorkoutFinishFamily super.from,
    required WorkoutFinish super.argument,
  }) : super(
         retry: null,
         name: r'deleteWorkoutFinishProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deleteWorkoutFinishHash();

  @override
  String toString() {
    return r'deleteWorkoutFinishProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as WorkoutFinish;
    return deleteWorkoutFinish(ref, workoutFinish: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteWorkoutFinishProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deleteWorkoutFinishHash() =>
    r'23c448a8705d9469faa6577ccf6bd1a9329aa570';

final class DeleteWorkoutFinishFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, WorkoutFinish> {
  DeleteWorkoutFinishFamily._()
    : super(
        retry: null,
        name: r'deleteWorkoutFinishProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeleteWorkoutFinishProvider call({required WorkoutFinish workoutFinish}) =>
      DeleteWorkoutFinishProvider._(argument: workoutFinish, from: this);

  @override
  String toString() => r'deleteWorkoutFinishProvider';
}

@ProviderFor(updateWorkoutFinishImages)
final updateWorkoutFinishImagesProvider = UpdateWorkoutFinishImagesFamily._();

final class UpdateWorkoutFinishImagesProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  UpdateWorkoutFinishImagesProvider._({
    required UpdateWorkoutFinishImagesFamily super.from,
    required ({WorkoutFinish workoutFinish, List<String> imageUrls})
    super.argument,
  }) : super(
         retry: null,
         name: r'updateWorkoutFinishImagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$updateWorkoutFinishImagesHash();

  @override
  String toString() {
    return r'updateWorkoutFinishImagesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument =
        this.argument
            as ({WorkoutFinish workoutFinish, List<String> imageUrls});
    return updateWorkoutFinishImages(
      ref,
      workoutFinish: argument.workoutFinish,
      imageUrls: argument.imageUrls,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateWorkoutFinishImagesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$updateWorkoutFinishImagesHash() =>
    r'72a1bd2035060ef18b7be0310921829140f3c2ed';

final class UpdateWorkoutFinishImagesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<void>,
          ({WorkoutFinish workoutFinish, List<String> imageUrls})
        > {
  UpdateWorkoutFinishImagesFamily._()
    : super(
        retry: null,
        name: r'updateWorkoutFinishImagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UpdateWorkoutFinishImagesProvider call({
    required WorkoutFinish workoutFinish,
    required List<String> imageUrls,
  }) => UpdateWorkoutFinishImagesProvider._(
    argument: (workoutFinish: workoutFinish, imageUrls: imageUrls),
    from: this,
  );

  @override
  String toString() => r'updateWorkoutFinishImagesProvider';
}

@ProviderFor(todayWorkoutFinish)
final todayWorkoutFinishProvider = TodayWorkoutFinishProvider._();

final class TodayWorkoutFinishProvider
    extends
        $FunctionalProvider<
          AsyncValue<WorkoutFinish?>,
          WorkoutFinish?,
          FutureOr<WorkoutFinish?>
        >
    with $FutureModifier<WorkoutFinish?>, $FutureProvider<WorkoutFinish?> {
  TodayWorkoutFinishProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayWorkoutFinishProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayWorkoutFinishHash();

  @$internal
  @override
  $FutureProviderElement<WorkoutFinish?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WorkoutFinish?> create(Ref ref) {
    return todayWorkoutFinish(ref);
  }
}

String _$todayWorkoutFinishHash() =>
    r'8f2cf4c1fe582e4ac452adc09fea4c3b2084a187';

@ProviderFor(workoutFinishList)
final workoutFinishListProvider = WorkoutFinishListFamily._();

final class WorkoutFinishListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkoutFinish>>,
          List<WorkoutFinish>,
          FutureOr<List<WorkoutFinish>>
        >
    with
        $FutureModifier<List<WorkoutFinish>>,
        $FutureProvider<List<WorkoutFinish>> {
  WorkoutFinishListProvider._({
    required WorkoutFinishListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'workoutFinishListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workoutFinishListHash();

  @override
  String toString() {
    return r'workoutFinishListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<WorkoutFinish>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WorkoutFinish>> create(Ref ref) {
    final argument = this.argument as String;
    return workoutFinishList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkoutFinishListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workoutFinishListHash() => r'ecd34b7695689ecd52c17b47c77fb37f837f899b';

final class WorkoutFinishListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<WorkoutFinish>>, String> {
  WorkoutFinishListFamily._()
    : super(
        retry: null,
        name: r'workoutFinishListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WorkoutFinishListProvider call(String userId) =>
      WorkoutFinishListProvider._(argument: userId, from: this);

  @override
  String toString() => r'workoutFinishListProvider';
}

@ProviderFor(workoutFinish)
final workoutFinishProvider = WorkoutFinishFamily._();

final class WorkoutFinishProvider
    extends
        $FunctionalProvider<
          AsyncValue<WorkoutFinish?>,
          WorkoutFinish?,
          FutureOr<WorkoutFinish?>
        >
    with $FutureModifier<WorkoutFinish?>, $FutureProvider<WorkoutFinish?> {
  WorkoutFinishProvider._({
    required WorkoutFinishFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'workoutFinishProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workoutFinishHash();

  @override
  String toString() {
    return r'workoutFinishProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<WorkoutFinish?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WorkoutFinish?> create(Ref ref) {
    final argument = this.argument as String;
    return workoutFinish(ref, workoutFinishId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkoutFinishProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workoutFinishHash() => r'360a215ac836656aebfc5de136acca99f1a04b62';

final class WorkoutFinishFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<WorkoutFinish?>, String> {
  WorkoutFinishFamily._()
    : super(
        retry: null,
        name: r'workoutFinishProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WorkoutFinishProvider call({required String workoutFinishId}) =>
      WorkoutFinishProvider._(argument: workoutFinishId, from: this);

  @override
  String toString() => r'workoutFinishProvider';
}

@ProviderFor(feedWorkoutFinish)
final feedWorkoutFinishProvider = FeedWorkoutFinishFamily._();

final class FeedWorkoutFinishProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkoutFinish>>,
          List<WorkoutFinish>,
          FutureOr<List<WorkoutFinish>>
        >
    with
        $FutureModifier<List<WorkoutFinish>>,
        $FutureProvider<List<WorkoutFinish>> {
  FeedWorkoutFinishProvider._({
    required FeedWorkoutFinishFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'feedWorkoutFinishProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$feedWorkoutFinishHash();

  @override
  String toString() {
    return r'feedWorkoutFinishProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<WorkoutFinish>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WorkoutFinish>> create(Ref ref) {
    final argument = this.argument as String;
    return feedWorkoutFinish(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedWorkoutFinishProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$feedWorkoutFinishHash() => r'961ab6207fe5fbc6bf2310a6a4717bcce20a1570';

final class FeedWorkoutFinishFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<WorkoutFinish>>, String> {
  FeedWorkoutFinishFamily._()
    : super(
        retry: null,
        name: r'feedWorkoutFinishProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FeedWorkoutFinishProvider call(String userId) =>
      FeedWorkoutFinishProvider._(argument: userId, from: this);

  @override
  String toString() => r'feedWorkoutFinishProvider';
}

@ProviderFor(workoutCount)
final workoutCountProvider = WorkoutCountFamily._();

final class WorkoutCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  WorkoutCountProvider._({
    required WorkoutCountFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'workoutCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workoutCountHash();

  @override
  String toString() {
    return r'workoutCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as String;
    return workoutCount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkoutCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workoutCountHash() => r'518796a8438349bd3cd3214508f2c2efb95e8e9c';

final class WorkoutCountFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, String> {
  WorkoutCountFamily._()
    : super(
        retry: null,
        name: r'workoutCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WorkoutCountProvider call(String userId) =>
      WorkoutCountProvider._(argument: userId, from: this);

  @override
  String toString() => r'workoutCountProvider';
}
