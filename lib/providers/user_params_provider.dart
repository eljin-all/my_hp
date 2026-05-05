import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/user_service.dart';
import 'diseases_provider.dart';
import 'selected_traumas_provider.dart';
import 'selected_activities_provider.dart';

part 'user_params_provider.g.dart';

@Riverpod(keepAlive: true)
Future<UserParams> userParams(UserParamsRef ref) async {
  final diseaseIds = await ref.watch(selectedDiseasesProvider.future);
  final traumaIds = await ref.watch(selectedTraumasProvider.future);
  final activityIds = await ref.watch(selectedActivitiesProvider.future);

  final diseaseParams = <String, double>{};
  for (var id in diseaseIds) {
    final p = await UserService.getDiseaseParam(id);
    if (p != null) diseaseParams[id] = p;
  }

  final traumaParams = <int, double>{};
  for (var id in traumaIds) {
    final p = await UserService.getTraumaParam(id);
    if (p != null) traumaParams[id] = p;
  }

  final activityParams = <int, double>{};
  for (var id in activityIds) {
    final p = await UserService.getActivityParam(id);
    if (p != null) activityParams[id] = p;
  }

  return UserParams(
    diseaseParams: diseaseParams,
    traumaParams: traumaParams,
    activityParams: activityParams,
  );
}

class UserParams {
  final Map<String, double> diseaseParams;
  final Map<int, double> traumaParams;
  final Map<int, double> activityParams;

  UserParams({
    required this.diseaseParams,
    required this.traumaParams,
    required this.activityParams,
  });
}