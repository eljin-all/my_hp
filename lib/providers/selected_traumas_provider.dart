import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/user_service.dart';

part 'selected_traumas_provider.g.dart';

@Riverpod(keepAlive: true)
class SelectedTraumas extends _$SelectedTraumas {
  @override
  Future<List<int>> build() async => UserService.getTraumas();

  Future<void> toggle(int id, {double? param}) async {
    final current = await future;
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
      if (param != null) await UserService.saveTraumaParam(id, param);
    }
    await UserService.saveTraumas(current);
    state = AsyncValue.data(current);
  }
}