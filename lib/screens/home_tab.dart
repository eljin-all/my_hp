import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/health_state_provider.dart';
import '../providers/hp_history_provider.dart';
import '../providers/hp_persistence_provider.dart';
import '../widgets/health_card.dart';
import '../widgets/interactive_hp_chart.dart';
import 'dead_screen.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  int _selectedRangeIndex = 1;
  int? _selectedPointIndex;

  List<Map<String, dynamic>> get filteredHistory {
    final historyAsync = ref.watch(hpHistoryProvider);
    final history = historyAsync.valueOrNull ?? [];
    if (history.isEmpty) return [];

    final now = DateTime.now();
    DateTime startDate;
    switch (_selectedRangeIndex) {
      case 0:
        startDate = now.subtract(const Duration(days: 7));
      case 1:
        startDate = now.subtract(const Duration(days: 30));
      case 2:
        startDate = now.subtract(const Duration(days: 365));
      default:
        startDate = now.subtract(const Duration(days: 30));
    }
    return history.where((record) {
      final time = DateTime.parse(record['time']);
      return time.isAfter(startDate) || time.isAtSameMomentAs(startDate);
    }).toList();
  }

  String _formatTime(DateTime time) {
    return "${time.day}.${time.month}.${time.year} ${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final history = filteredHistory;

    final currentHp = ref.watch(healthStateProvider.select(
          (state) => state.whenOrNull(data: (data) => data.currentHp) ?? 0,
    ));
    final maxHp = ref.watch(healthStateProvider.select(
          (state) => state.whenOrNull(data: (data) => data.maxHp) ?? 100,
    ));


    final isCritical = currentHp <= 30;

    return Container(
      decoration: BoxDecoration(
        gradient: isCritical
            ? LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.error.withOpacity(0.3),
            theme.scaffoldBackgroundColor,
          ],
        )
            : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Здоровье",
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Flexible(child: const HealthCard()),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "История HP",
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  ToggleButtons(
                    isSelected: [
                      _selectedRangeIndex == 0,
                      _selectedRangeIndex == 1,
                      _selectedRangeIndex == 2,
                    ],
                    onPressed: (index) => setState(() => _selectedRangeIndex = index),
                    borderRadius: BorderRadius.circular(20),
                    selectedColor: theme.colorScheme.onPrimary,
                    fillColor: theme.colorScheme.primary,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    children: const [
                      Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("Нед")),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("Мес")),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("Год")),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 280,
                child: history.isEmpty
                    ? Center(
                  child: Text(
                    "Нет данных за выбранный период",
                    style: theme.textTheme.bodyLarge,
                  ),
                )
                    : InteractiveHpChart(
                  history: history,
                  currentHp: currentHp,
                  maxHp: maxHp,
                  onPointSelected: (index) => setState(() => _selectedPointIndex = index),
                ),
              ),
              if (_selectedPointIndex != null && _selectedPointIndex! < history.length)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "Выбрано: ${history[_selectedPointIndex!]['hp']} HP (${_formatTime(DateTime.parse(history[_selectedPointIndex!]['time']))})",
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}