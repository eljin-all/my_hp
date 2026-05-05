import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/user_service.dart';

part 'selected_activities_provider.g.dart';

@Riverpod(keepAlive: true)
class SelectedActivities extends _$SelectedActivities {
  @override
  Future<List<int>> build() async => UserService.getActivities();

  Future<void> toggle(int id, {double? param}) async {
    final current = await future;
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
      if (param != null) await UserService.saveActivityParam(id, param);
    }
    await UserService.saveActivities(current);
    state = AsyncValue.data(current);
  }
}