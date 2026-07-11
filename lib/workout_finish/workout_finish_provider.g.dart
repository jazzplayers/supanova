// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_finish/workout_finish_provider.dart';

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

/// ======================
/// 운동 완료 업로드
/// ======================
///
/// keepAlive를 켜는 이유:
/// upload 도중 화면이 바뀌거나 provider listener가 사라지면
/// autoDispose provider가 dispose될 수 있음.
/// 그 상태에서 await 이후 ref.invalidate를 호출하면
/// Cannot use the Ref of uploadWorkoutFinishProvider...
/// 에러가 날 수 있음.

@ProviderFor(uploadWorkoutFinish)
final uploadWorkoutFinishProvider = UploadWorkoutFinishFamily._();

/// ======================
/// 운동 완료 업로드
/// ======================
///
/// keepAlive를 켜는 이유:
/// upload 도중 화면이 바뀌거나 provider listener가 사라지면
/// autoDispose provider가 dispose될 수 있음.
/// 그 상태에서 await 이후 ref.invalidate를 호출하면
/// Cannot use the Ref of uploadWorkoutFinishProvider...
/// 에러가 날 수 있음.

final class UploadWorkoutFinishProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// ======================
  /// 운동 완료 업로드
  /// ======================
  ///
  /// keepAlive를 켜는 이유:
  /// upload 도중 화면이 바뀌거나 provider listener가 사라지면
  /// autoDispose provider가 dispose될 수 있음.
  /// 그 상태에서 await 이후 ref.invalidate를 호출하면
  /// Cannot use the Ref of uploadWorkoutFinishProvider...
  /// 에러가 날 수 있음.
  UploadWorkoutFinishProvider._({
    required UploadWorkoutFinishFamily super.from,
    required ({
      WorkoutFinish workoutFinish,
      List<String> imageUrls,
      String? thumbnailUrl,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'uploadWorkoutFinishProvider',
         isAutoDispose: false,
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
            as ({
              WorkoutFinish workoutFinish,
              List<String> imageUrls,
              String? thumbnailUrl,
            });
    return uploadWorkoutFinish(
      ref,
      workoutFinish: argument.workoutFinish,
      imageUrls: argument.imageUrls,
      thumbnailUrl: argument.thumbnailUrl,
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
    r'6e084e6911778ba5e4da04bd56fe1b9cfaae8d37';

/// ======================
/// 운동 완료 업로드
/// ======================
///
/// keepAlive를 켜는 이유:
/// upload 도중 화면이 바뀌거나 provider listener가 사라지면
/// autoDispose provider가 dispose될 수 있음.
/// 그 상태에서 await 이후 ref.invalidate를 호출하면
/// Cannot use the Ref of uploadWorkoutFinishProvider...
/// 에러가 날 수 있음.

final class UploadWorkoutFinishFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<void>,
          ({
            WorkoutFinish workoutFinish,
            List<String> imageUrls,
            String? thumbnailUrl,
          })
        > {
  UploadWorkoutFinishFamily._()
    : super(
        retry: null,
        name: r'uploadWorkoutFinishProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// ======================
  /// 운동 완료 업로드
  /// ======================
  ///
  /// keepAlive를 켜는 이유:
  /// upload 도중 화면이 바뀌거나 provider listener가 사라지면
  /// autoDispose provider가 dispose될 수 있음.
  /// 그 상태에서 await 이후 ref.invalidate를 호출하면
  /// Cannot use the Ref of uploadWorkoutFinishProvider...
  /// 에러가 날 수 있음.

  UploadWorkoutFinishProvider call({
    required WorkoutFinish workoutFinish,
    required List<String> imageUrls,
    String? thumbnailUrl,
  }) => UploadWorkoutFinishProvider._(
    argument: (
      workoutFinish: workoutFinish,
      imageUrls: imageUrls,
      thumbnailUrl: thumbnailUrl,
    ),
    from: this,
  );

  @override
  String toString() => r'uploadWorkoutFinishProvider';
}

/// ======================
/// 운동 완료 삭제
/// ======================

@ProviderFor(deleteWorkoutFinish)
final deleteWorkoutFinishProvider = DeleteWorkoutFinishFamily._();

/// ======================
/// 운동 완료 삭제
/// ======================

final class DeleteWorkoutFinishProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// ======================
  /// 운동 완료 삭제
  /// ======================
  DeleteWorkoutFinishProvider._({
    required DeleteWorkoutFinishFamily super.from,
    required WorkoutFinish super.argument,
  }) : super(
         retry: null,
         name: r'deleteWorkoutFinishProvider',
         isAutoDispose: false,
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
    r'1dae8f3d262132ee4e24c261736a5e8662e8973c';

/// ======================
/// 운동 완료 삭제
/// ======================

final class DeleteWorkoutFinishFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, WorkoutFinish> {
  DeleteWorkoutFinishFamily._()
    : super(
        retry: null,
        name: r'deleteWorkoutFinishProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// ======================
  /// 운동 완료 삭제
  /// ======================

  DeleteWorkoutFinishProvider call({required WorkoutFinish workoutFinish}) =>
      DeleteWorkoutFinishProvider._(argument: workoutFinish, from: this);

  @override
  String toString() => r'deleteWorkoutFinishProvider';
}

/// ======================
/// 운동 완료 이미지 수정
/// ======================

@ProviderFor(updateWorkoutFinishImages)
final updateWorkoutFinishImagesProvider = UpdateWorkoutFinishImagesFamily._();

/// ======================
/// 운동 완료 이미지 수정
/// ======================

final class UpdateWorkoutFinishImagesProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// ======================
  /// 운동 완료 이미지 수정
  /// ======================
  UpdateWorkoutFinishImagesProvider._({
    required UpdateWorkoutFinishImagesFamily super.from,
    required ({
      WorkoutFinish workoutFinish,
      List<String> imageUrls,
      String? thumbnailUrl,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'updateWorkoutFinishImagesProvider',
         isAutoDispose: false,
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
            as ({
              WorkoutFinish workoutFinish,
              List<String> imageUrls,
              String? thumbnailUrl,
            });
    return updateWorkoutFinishImages(
      ref,
      workoutFinish: argument.workoutFinish,
      imageUrls: argument.imageUrls,
      thumbnailUrl: argument.thumbnailUrl,
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
    r'cf8f5c2e0f431196a959668cf3ca694aaefc1350';

/// ======================
/// 운동 완료 이미지 수정
/// ======================

final class UpdateWorkoutFinishImagesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<void>,
          ({
            WorkoutFinish workoutFinish,
            List<String> imageUrls,
            String? thumbnailUrl,
          })
        > {
  UpdateWorkoutFinishImagesFamily._()
    : super(
        retry: null,
        name: r'updateWorkoutFinishImagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// ======================
  /// 운동 완료 이미지 수정
  /// ======================

  UpdateWorkoutFinishImagesProvider call({
    required WorkoutFinish workoutFinish,
    required List<String> imageUrls,
    String? thumbnailUrl,
  }) => UpdateWorkoutFinishImagesProvider._(
    argument: (
      workoutFinish: workoutFinish,
      imageUrls: imageUrls,
      thumbnailUrl: thumbnailUrl,
    ),
    from: this,
  );

  @override
  String toString() => r'updateWorkoutFinishImagesProvider';
}

/// ======================
/// 오늘 운동 기록
/// ======================

@ProviderFor(todayWorkoutFinish)
final todayWorkoutFinishProvider = TodayWorkoutFinishProvider._();

/// ======================
/// 오늘 운동 기록
/// ======================

final class TodayWorkoutFinishProvider
    extends
        $FunctionalProvider<
          AsyncValue<WorkoutFinish?>,
          WorkoutFinish?,
          FutureOr<WorkoutFinish?>
        >
    with $FutureModifier<WorkoutFinish?>, $FutureProvider<WorkoutFinish?> {
  /// ======================
  /// 오늘 운동 기록
  /// ======================
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

/// ======================
/// 운동 기록 리스트
/// ======================

@ProviderFor(workoutFinishList)
final workoutFinishListProvider = WorkoutFinishListFamily._();

/// ======================
/// 운동 기록 리스트
/// ======================

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
  /// ======================
  /// 운동 기록 리스트
  /// ======================
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

String _$workoutFinishListHash() => r'459107280ca1ea24d4d75dbd8add797ff4d6ed4b';

/// ======================
/// 운동 기록 리스트
/// ======================

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

  /// ======================
  /// 운동 기록 리스트
  /// ======================

  WorkoutFinishListProvider call(String userId) =>
      WorkoutFinishListProvider._(argument: userId, from: this);

  @override
  String toString() => r'workoutFinishListProvider';
}

/// ======================
/// 단일 운동 기록
/// ======================

@ProviderFor(workoutFinish)
final workoutFinishProvider = WorkoutFinishFamily._();

/// ======================
/// 단일 운동 기록
/// ======================

final class WorkoutFinishProvider
    extends
        $FunctionalProvider<
          AsyncValue<WorkoutFinish?>,
          WorkoutFinish?,
          FutureOr<WorkoutFinish?>
        >
    with $FutureModifier<WorkoutFinish?>, $FutureProvider<WorkoutFinish?> {
  /// ======================
  /// 단일 운동 기록
  /// ======================
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

/// ======================
/// 단일 운동 기록
/// ======================

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

  /// ======================
  /// 단일 운동 기록
  /// ======================

  WorkoutFinishProvider call({required String workoutFinishId}) =>
      WorkoutFinishProvider._(argument: workoutFinishId, from: this);

  @override
  String toString() => r'workoutFinishProvider';
}

/// ======================
/// 기존 피드 운동 기록
/// ======================
///
/// 기존 화면에서 쓰고 있던 provider라서 유지.
/// 내부 Repo에서는 getFeedListWorkoutFinish를 재사용해도 됨.

@ProviderFor(feedWorkoutFinish)
final feedWorkoutFinishProvider = FeedWorkoutFinishFamily._();

/// ======================
/// 기존 피드 운동 기록
/// ======================
///
/// 기존 화면에서 쓰고 있던 provider라서 유지.
/// 내부 Repo에서는 getFeedListWorkoutFinish를 재사용해도 됨.

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
  /// ======================
  /// 기존 피드 운동 기록
  /// ======================
  ///
  /// 기존 화면에서 쓰고 있던 provider라서 유지.
  /// 내부 Repo에서는 getFeedListWorkoutFinish를 재사용해도 됨.
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

String _$feedWorkoutFinishHash() => r'397dba08793a3513a6c8da9921545f619a8aa103';

/// ======================
/// 기존 피드 운동 기록
/// ======================
///
/// 기존 화면에서 쓰고 있던 provider라서 유지.
/// 내부 Repo에서는 getFeedListWorkoutFinish를 재사용해도 됨.

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

  /// ======================
  /// 기존 피드 운동 기록
  /// ======================
  ///
  /// 기존 화면에서 쓰고 있던 provider라서 유지.
  /// 내부 Repo에서는 getFeedListWorkoutFinish를 재사용해도 됨.

  FeedWorkoutFinishProvider call(String userId) =>
      FeedWorkoutFinishProvider._(argument: userId, from: this);

  @override
  String toString() => r'feedWorkoutFinishProvider';
}

/// ======================
/// 피드 리스트 화면용
/// ======================
///
/// 인스타그램처럼 특정 게시글을 누르면,
/// 해당 유저의 운동 기록들을 세로 리스트로 연속해서 보여주는 화면에 사용.

@ProviderFor(feedListWorkoutFinish)
final feedListWorkoutFinishProvider = FeedListWorkoutFinishFamily._();

/// ======================
/// 피드 리스트 화면용
/// ======================
///
/// 인스타그램처럼 특정 게시글을 누르면,
/// 해당 유저의 운동 기록들을 세로 리스트로 연속해서 보여주는 화면에 사용.

final class FeedListWorkoutFinishProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkoutFinish>>,
          List<WorkoutFinish>,
          FutureOr<List<WorkoutFinish>>
        >
    with
        $FutureModifier<List<WorkoutFinish>>,
        $FutureProvider<List<WorkoutFinish>> {
  /// ======================
  /// 피드 리스트 화면용
  /// ======================
  ///
  /// 인스타그램처럼 특정 게시글을 누르면,
  /// 해당 유저의 운동 기록들을 세로 리스트로 연속해서 보여주는 화면에 사용.
  FeedListWorkoutFinishProvider._({
    required FeedListWorkoutFinishFamily super.from,
    required (String, {int limit}) super.argument,
  }) : super(
         retry: null,
         name: r'feedListWorkoutFinishProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$feedListWorkoutFinishHash();

  @override
  String toString() {
    return r'feedListWorkoutFinishProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<WorkoutFinish>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WorkoutFinish>> create(Ref ref) {
    final argument = this.argument as (String, {int limit});
    return feedListWorkoutFinish(ref, argument.$1, limit: argument.limit);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedListWorkoutFinishProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$feedListWorkoutFinishHash() =>
    r'3eaf4978d367432fba0bb316ffbf99f686522356';

/// ======================
/// 피드 리스트 화면용
/// ======================
///
/// 인스타그램처럼 특정 게시글을 누르면,
/// 해당 유저의 운동 기록들을 세로 리스트로 연속해서 보여주는 화면에 사용.

final class FeedListWorkoutFinishFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<WorkoutFinish>>,
          (String, {int limit})
        > {
  FeedListWorkoutFinishFamily._()
    : super(
        retry: null,
        name: r'feedListWorkoutFinishProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// ======================
  /// 피드 리스트 화면용
  /// ======================
  ///
  /// 인스타그램처럼 특정 게시글을 누르면,
  /// 해당 유저의 운동 기록들을 세로 리스트로 연속해서 보여주는 화면에 사용.

  FeedListWorkoutFinishProvider call(String userId, {int limit = 60}) =>
      FeedListWorkoutFinishProvider._(
        argument: (userId, limit: limit),
        from: this,
      );

  @override
  String toString() => r'feedListWorkoutFinishProvider';
}

/// ======================
/// 프로필 운동 그리드
/// ======================

@ProviderFor(profileWorkoutGrid)
final profileWorkoutGridProvider = ProfileWorkoutGridFamily._();

/// ======================
/// 프로필 운동 그리드
/// ======================

final class ProfileWorkoutGridProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkoutFinish>>,
          List<WorkoutFinish>,
          FutureOr<List<WorkoutFinish>>
        >
    with
        $FutureModifier<List<WorkoutFinish>>,
        $FutureProvider<List<WorkoutFinish>> {
  /// ======================
  /// 프로필 운동 그리드
  /// ======================
  ProfileWorkoutGridProvider._({
    required ProfileWorkoutGridFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'profileWorkoutGridProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileWorkoutGridHash();

  @override
  String toString() {
    return r'profileWorkoutGridProvider'
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
    return profileWorkoutGrid(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileWorkoutGridProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileWorkoutGridHash() =>
    r'22c80ea18cc4595679003181e5eb921a338f459e';

/// ======================
/// 프로필 운동 그리드
/// ======================

final class ProfileWorkoutGridFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<WorkoutFinish>>, String> {
  ProfileWorkoutGridFamily._()
    : super(
        retry: null,
        name: r'profileWorkoutGridProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// ======================
  /// 프로필 운동 그리드
  /// ======================

  ProfileWorkoutGridProvider call(String userId) =>
      ProfileWorkoutGridProvider._(argument: userId, from: this);

  @override
  String toString() => r'profileWorkoutGridProvider';
}

/// ======================
/// 운동 개수
/// ======================

@ProviderFor(workoutCount)
final workoutCountProvider = WorkoutCountFamily._();

/// ======================
/// 운동 개수
/// ======================

final class WorkoutCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// ======================
  /// 운동 개수
  /// ======================
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

/// ======================
/// 운동 개수
/// ======================

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

  /// ======================
  /// 운동 개수
  /// ======================

  WorkoutCountProvider call(String userId) =>
      WorkoutCountProvider._(argument: userId, from: this);

  @override
  String toString() => r'workoutCountProvider';
}
