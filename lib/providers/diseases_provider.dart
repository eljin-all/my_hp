import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/user_service.dart';

part 'diseases_provider.g.dart';

@Riverpod(keepAlive: true)
class SelectedDiseases extends _$SelectedDiseases {
  @override
  Future<List<String>> build() async => UserService.getDiseases();

  Future<void> toggle(String id, {double? param}) async {
    final current = await future;
    if (current.contains(id)) {
      current.remove(id);
      await UserService.removeDiseaseParam(id);
    } else {
      current.add(id);
      if (param != null) await UserService.saveDiseaseParam(id, param);
    }
    await UserService.saveDiseases(current);
    state = AsyncValue.data(current);
  }
}