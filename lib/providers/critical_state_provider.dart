import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/emergency_service.dart';
import '../providers/hp_persistence_provider.dart';
import '../screens/dead_screen.dart';
import '../screens/main_screen.dart';

final criticalStateProvider = StateNotifierProvider<CriticalStateNotifier, int?>((ref) {
  return CriticalStateNotifier(ref);
});

class CriticalStateNotifier extends StateNotifier<int?> {
  final Ref _ref;

  CriticalStateNotifier(this._ref) : super(null);

  bool _isDialogShowing = false;
  bool _canShowDialog = true;

  void resetDialog() {
    _canShowDialog = true;
  }

  Future<void> checkAndShowIfNeeded(BuildContext context, int currentHp) async {
    if (_isDialogShowing || !_canShowDialog) return;

    if (currentHp == 1) {
      _isDialogShowing = true;
      _canShowDialog = false;

      final callEnabled = await EmergencyService.isCallEnabled();
      final phone = await EmergencyService.getPhoneNumber();
      final canCall = callEnabled && phone.isNotEmpty;

      final result = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Критическое состояние'),
          content: const Text('Ваше здоровье на минимальном уровне.\nЖивы ли вы?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, 'no'), child: const Text('Нет')),
            TextButton(onPressed: () => Navigator.pop(ctx, 'yes'), child: const Text('Да')),
            if (canCall)
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'call'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Позвонить в больницу'),
              ),
          ],
        ),
      );
      _isDialogShowing = false;

      if (result == 'no') {
        if (context.mounted) {
          final revived = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const DeadScreen()),
          );
          if (revived == true && context.mounted) {
            _ref.read(hpPersistenceProvider.notifier).save(10);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainScreen()),
                  (route) => false,
            );
          }
        }
      } else if (result == 'call') {
        await EmergencyService.makeEmergencyCall();
      }
      return;
    }

    final threshold = await EmergencyService.getThreshold();
    final callEnabled = await EmergencyService.isCallEnabled();
    if (currentHp <= threshold && callEnabled) {
      _isDialogShowing = true;
      _canShowDialog = false;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Критическое состояние!'),
          content: Text('Ваше здоровье на критическом уровне.\nПозвонить в больницу?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Нет')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Позвонить'),
            ),
          ],
        ),
      );
      _isDialogShowing = false;

      if (confirmed == true) {
        await EmergencyService.makeEmergencyCall();
      }
    }
  }
}