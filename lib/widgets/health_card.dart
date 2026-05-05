// widgets/health_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/health_state.dart';
import '../providers/health_state_provider.dart';
import '../providers/diseases_provider.dart';
import '../providers/selected_traumas_provider.dart';
import '../providers/selected_activities_provider.dart';
import '../models/disease.dart';
import '../services/hp_service.dart';

class HealthCard extends ConsumerStatefulWidget {
  const HealthCard({super.key});

  @override
  ConsumerState<HealthCard> createState() => _HealthCardState();
}

class _HealthCardState extends ConsumerState<HealthCard> {
  HealthState? _lastState;
  int? _lastHp;

  Future<bool> _showDeleteConfirmation(BuildContext context, String itemName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Подтверждение'),
        content: Text('Удалить "$itemName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final healthStateAsync = ref.watch(healthStateProvider);

    ref.listen(healthStateProvider, (prev, next) {
      next.whenData((state) => _lastState = state);
    });

    if (healthStateAsync.isLoading && _lastState != null) {
      return _buildContent(context, ref, _lastState!);
    }
    if (healthStateAsync.hasError && _lastState != null) {
      return _buildContent(context, ref, _lastState!);
    }

    return healthStateAsync.when(
      data: (state) {
        _lastState = state;
        return _buildContent(context, ref, state);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Ошибка: $err')),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, HealthState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final currentHp = ref.watch(healthStateProvider.select(
          (s) => s.whenOrNull(data: (d) => d.currentHp) ?? 0,
    ));
    final maxHp = ref.watch(healthStateProvider.select(
          (s) => s.whenOrNull(data: (d) => d.maxHp) ?? 100,
    ));
    final imtDebuff = ref.watch(healthStateProvider.select(
          (s) => s.whenOrNull(data: (d) => d.imtDebuff) ?? 0,
    ));
    final ageDebuff = ref.watch(healthStateProvider.select(
          (s) => s.whenOrNull(data: (d) => d.user != null ? HpService.getAgeDebuff(d.user!) : 0) ?? 0,
    ));

    final animatedHpText = TweenAnimationBuilder<int>(
      tween: IntTween(begin: _lastHp ?? currentHp, end: currentHp),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Text(
          "$value / $maxHp",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: value <= 30 ? colorScheme.error : colorScheme.onSurface,
          ),
        );
      },
    );
    _lastHp = currentHp;

    final selectedDiseases = state.sortedDiseases
        .where((d) => state.selectedDiseaseIds.contains(d.id))
        .toList();
    final selectedTraumas = state.sortedTraumas
        .where((t) => state.selectedTraumaIds.contains(t['id'] as int))
        .toList();
    final selectedActivities = state.sortedActivities
        .where((a) => state.selectedActivityIds.contains(a['id'] as int))
        .toList();

    Widget singleRow(String title, String text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$title ",
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    Widget listSection(String title, List<Widget> items) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                "Нет",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            )
          else
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: Column(
                key: ValueKey(items.map((e) => e.key).join()),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items,
              ),
            ),
        ],
      );
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/ui/voxel_heart.png',
              width: 28,
              height: 28,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Общее состояние", style: theme.textTheme.bodyMedium),
                animatedHpText,
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (ageDebuff > 0) ...[
          singleRow("Возраст:", "Снижение из-за возраста (-$ageDebuff)"),
          const SizedBox(height: 4),
        ],

        if (imtDebuff > 0) ...[
          singleRow("Штраф ИМТ:", "Отклонение массы тела (-$imtDebuff)"),
          const SizedBox(height: 4),
        ],

        const SizedBox(height: 4),

        listSection(
          "Болезни:",
          selectedDiseases.map((d) {
            final p = state.diseaseParams[d.id] ?? 1;
            final effect = HpService.calculateDiseaseEffect(d, p).round();
            return Row(
              key: ValueKey(d.id),
              children: [
                Expanded(
                  child: Text(
                    "${d.name} (-$effect)",
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: IconButton(
                    icon: Icon(Icons.close, size: 18, color: colorScheme.error),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      final confirmed = await _showDeleteConfirmation(context, d.name);
                      if (confirmed) {
                        ref.read(selectedDiseasesProvider.notifier).toggle(d.id);
                      }
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 8),

        listSection(
          "Травмы:",
          selectedTraumas.map((t) {
            final id = t['id'] as int;
            final p = state.traumaParams[id] ?? 1;
            final effect = HpService.calculateTraumaEffect(t, p).round();
            return Row(
              key: ValueKey(id),
              children: [
                Expanded(
                  child: Text(
                    "${t['name']} (-$effect)",
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: IconButton(
                    icon: Icon(Icons.close, size: 18, color: colorScheme.error),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      final confirmed = await _showDeleteConfirmation(context, t['name']);
                      if (confirmed) {
                        ref.read(selectedTraumasProvider.notifier).toggle(id);
                      }
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 8),

        listSection(
          "Активности:",
          selectedActivities.map((a) {
            final id = a['id'] as int;
            final p = state.activityParams[id] ?? 1;
            final effect = HpService.calculateActivityEffect(a, p).round();
            return Row(
              key: ValueKey(id),
              children: [
                Expanded(
                  child: Text(
                    "${a['name']} (+$effect)",
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: IconButton(
                    icon: Icon(Icons.close, size: 18, color: colorScheme.primary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      final confirmed = await _showDeleteConfirmation(context, a['name']);
                      if (confirmed) {
                        ref.read(selectedActivitiesProvider.notifier).toggle(id);
                      }
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(14),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: content,
      ),
    );
  }
}