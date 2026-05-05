import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../state/health_state.dart';
import 'user_provider.dart';
import 'diseases_provider.dart';
import 'selected_traumas_provider.dart';
import 'selected_activities_provider.dart';
import 'reference_data_provider.dart';
import 'user_params_provider.dart';

part 'health_state_provider.g.dart';

@Riverpod(keepAlive: true)
Future<HealthState> healthState(HealthStateRef ref) async {
  final userAsync = ref.watch(userNotifierProvider);
  final diseaseIdsAsync = ref.watch(selectedDiseasesProvider);
  final traumaIdsAsync = ref.watch(selectedTraumasProvider);
  final activityIdsAsync = ref.watch(selectedActivitiesProvider);
  final userParamsAsync = ref.watch(userParamsProvider);

  final user = userAsync.valueOrNull;
  final gender = user?.gender ?? 'male';

  final allDiseases = await ref.watch(allDiseasesProvider(gender: gender).future);
  final allTraumas = await ref.watch(allTraumasProvider.future);
  final allActivities = await ref.watch(allActivitiesProvider.future);

  final diseaseIds = diseaseIdsAsync.valueOrNull ?? [];
  final traumaIds = traumaIdsAsync.valueOrNull ?? [];
  final activityIds = activityIdsAsync.valueOrNull ?? [];

  final userParams = userParamsAsync.valueOrNull ?? UserParams(
    diseaseParams: {},
    traumaParams: {},
    activityParams: {},
  );

  final state = HealthState(
    user: user,
    allDiseases: allDiseases,
    allTraumas: allTraumas,
    allActivities: allActivities,
    selectedDiseaseIds: diseaseIds,
    selectedTraumaIds: traumaIds,
    selectedActivityIds: activityIds,
    diseaseParams: userParams.diseaseParams,
    traumaParams: userParams.traumaParams,
    activityParams: userParams.activityParams,
  );

  return HealthState.recalculate(state);
}