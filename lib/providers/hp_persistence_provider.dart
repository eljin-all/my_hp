import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/user_service.dart';
import 'hp_history_provider.dart';

part 'hp_persistence_provider.g.dart';

@Riverpod(keepAlive: true)
class HpPersistence extends _$HpPersistence {
  @override
  void build() {}

  Future<void> save(int hp) async {
    await UserService.saveCurrentHp(hp);
    // Уведомляем провайдер истории о новой записи
    ref.read(hpHistoryProvider.notifier).addRecord(hp);
  }
}