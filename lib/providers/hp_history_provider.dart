import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/user_service.dart';

part 'hp_history_provider.g.dart';

@Riverpod(keepAlive: true)
class HpHistory extends _$HpHistory {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    return UserService.getHpHistory();
  }

  // Метод для добавления новой записи (вызывается из HpPersistenceProvider)
  Future<void> addRecord(int hp) async {
    final current = state.value ?? [];
    // Проверка на дублирование последней записи
    if (current.isNotEmpty && current.last['hp'] == hp) {
      return;
    }
    final newRecord = {
      'hp': hp,
      'time': DateTime.now().toIso8601String(),
    };
    final updated = [...current, newRecord];
    state = AsyncValue.data(updated);
    // Сохраняем в SharedPreferences (дублируем логику UserService, но можно оставить)
    await UserService.addHpRecord(hp);
  }
}