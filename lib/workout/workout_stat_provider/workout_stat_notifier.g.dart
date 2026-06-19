// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_stat_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Workout)
final workoutProvider = WorkoutProvider._();

final class WorkoutProvider
    extends $NotifierProvider<Workout, WorkoutStatsState> {
  WorkoutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutHash();

  @$internal
  @override
  Workout create() => Workout();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkoutStatsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkoutStatsState>(value),
    );
  }
}

String _$workoutHash() => r'57bb45c719a64eebd11f78b448ceaaa80793a0db';

abstract class _$Workout extends $Notifier<WorkoutStatsState> {
  WorkoutStatsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<WorkoutStatsState, WorkoutStatsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WorkoutStatsState, WorkoutStatsState>,
              WorkoutStatsState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
