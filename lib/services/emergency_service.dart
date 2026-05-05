import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyService {
  static const _keyCallEnabled = 'call_ambulance';
  static const _keyPhone = 'ambulance_phone';
  static const _keyThreshold = 'critical_threshold';

  static Future<bool> isCallEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyCallEnabled) ?? false;
  }

  static Future<String> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhone) ?? '';
  }

  // lib/services/emergency_service.dart
  static Future<bool> makeEmergencyCall() async {
    final phone = await getPhoneNumber();
    if (phone.isEmpty) return false;
    final uri = Uri.parse('tel:$phone');
    try {
      await launchUrl(uri);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<int> getThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyThreshold) ?? 30;
  }

  static Future<void> saveSettings({
    required bool enabled,
    required String phone,
    required int threshold,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCallEnabled, enabled);
    await prefs.setString(_keyPhone, phone);
    await prefs.setInt(_keyThreshold, threshold);
  }

  /// Показывает диалог подтверждения звонка и, при согласии, запускает набор номера.
  /// Возвращает true, если звонок был инициирован.
  static Future<bool> showEmergencyCallDialog(BuildContext context) async {
    final phone = await getPhoneNumber();
    if (phone.isEmpty) return false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Критическое состояние!'),
        content: Text('Ваше здоровье на критическом уровне.\nПозвонить по номеру $phone?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Нет'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Позвонить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final uri = Uri.parse('tel:$phone');
      try {
        await launchUrl(uri);
        return true;
      } catch (_) {
        // Если звонок не удался, показываем номер для ручного набора
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Не удалось позвонить'),
              content: Text('Пожалуйста, позвоните по номеру:\n$phone'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return false;
      }
    }
    return false;
  }
}