// screens/state_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/disease.dart';
import '../state/health_state.dart';
import '../providers/health_state_provider.dart';
import '../providers/diseases_provider.dart';
import '../providers/selected_traumas_provider.dart';
import '../providers/selected_activities_provider.dart';
import '../utils/dialogs.dart';

class StateListScreen extends ConsumerStatefulWidget {
  final String type;

  const StateListScreen({super.key, required this.type});

  @override
  ConsumerState<StateListScreen> createState() => _StateListScreenState();
}

class _StateListScreenState extends ConsumerState<StateListScreen> {
  HealthState? _lastState;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final healthStateAsync = ref.watch(healthStateProvider);

    ref.listen(healthStateProvider, (prev, next) {
      next.whenData((state) => _lastState = state);
    });

    if (healthStateAsync.isLoading && _lastState != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.type)),
        body: _buildBody(context, ref, _lastState!),
      );
    }

    if (healthStateAsync.hasError && _lastState != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.type)),
        body: _buildBody(context, ref, _lastState!),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.type)),
      body: healthStateAsync.when(
        data: (state) {
          _lastState = state;
          return _buildBody(context, ref, state);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Ошибка: $err')),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, HealthState state) {
    final bool showSearch = widget.type == 'diseases' || widget.type == 'traumas';

    return Column(
      children: [
        if (showSearch)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
        Expanded(
          child: _buildList(context, ref, state),
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, HealthState state) {
    List<dynamic> items;
    List<dynamic> selectedIds;

    switch (widget.type) {
      case 'diseases':
        items = state.allDiseases;
        selectedIds = state.selectedDiseaseIds;
        break;
      case 'traumas':
        items = state.allTraumas;
        selectedIds = state.selectedTraumaIds;
        break;
      case 'activities':
        items = state.allActivities;
        selectedIds = state.selectedActivityIds;
        break;
      default:
        items = [];
        selectedIds = [];
    }

    if (_searchQuery.isNotEmpty && (widget.type == 'diseases' || widget.type == 'traumas')) {
      items = items.where((item) {
        final name = item is Disease ? item.name : item['name'] as String;
        return name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: items.isEmpty
          ? Center(
        key: const ValueKey('empty'),
        child: const Text("Нет данных"),
      )
          : ListView.builder(
        key: const ValueKey('list'),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          dynamic id;
          String name;
          int hp;

          if (item is Disease) {
            id = item.id;
            name = item.name;
            hp = item.hp;
          } else {
            id = item['id'];
            name = item['name'];
            hp = (widget.type == 'activities')
                ? (item['plus_hp'] ?? item['hp'] ?? 0)
                : (item['minus_hp'] ?? 0);
          }

          final isSelected = selectedIds.contains(id);

          String hpText;
          if (widget.type == 'activities') {
            hpText = "HP: +$hp";
          } else {
            hpText = "HP: -$hp";
          }

          return ListTile(
            title: Text(name),
            trailing: Text(hpText),
            leading: Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.green : Colors.grey,
            ),
            onTap: () async {
              double? param;

              if (!isSelected) {
                if (widget.type == 'diseases') {
                  final disease = item as Disease;
                  if (disease.system == 'oncology') {
                    param = await showNumberSliderDialog(context, min: 1, max: 5, title: "Стадия (1-5)");
                  } else if (disease.system == 'oral_cavity') {
                    param = await showNumberSliderDialog(context, min: 1, max: 32, title: "Количество зубов");
                  } else if (disease.system == 'skin' || disease.system == 'nervous_system') {
                    param = await showNumberSliderDialog(context, min: 1, max: 3, title: "Степень (1-3)");
                  } else {
                    param = await showNumberSliderDialog(context, min: 1, max: 5, title: "Сила заболевания (1-5)");
                  }
                  if (param == null) return;
                  await ref.read(selectedDiseasesProvider.notifier).toggle(id, param: param);
                } else if (widget.type == 'traumas') {
                  final trauma = item as Map<String, dynamic>;
                  if (trauma['system'] == 'oral_cavity') {
                    param = await showNumberSliderDialog(context, min: 1, max: 32, title: "Количество зубов");
                  } else if (trauma['scale_type'] == 1) {
                    param = await showNumberSliderDialog(context, min: 1, max: 10, title: "Интенсивность");
                  } else {
                    param = 1;
                  }
                  if (param == null && trauma['scale_type'] != 0) return;
                  await ref.read(selectedTraumasProvider.notifier).toggle(id, param: param);
                } else if (widget.type == 'activities') {
                  param = await showNumberSliderDialog(context, min: 1, max: 7, title: "Раз в неделю (1-7)");
                  if (param == null) return;
                  await ref.read(selectedActivitiesProvider.notifier).toggle(id, param: param);
                }
              } else {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Подтверждение'),
                    content: Text('Удалить "$name"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Удалить'),
                      ),
                    ],
                  ),
                );
                if (confirm != true) return;

                if (widget.type == 'diseases') {
                  await ref.read(selectedDiseasesProvider.notifier).toggle(id);
                } else if (widget.type == 'traumas') {
                  await ref.read(selectedTraumasProvider.notifier).toggle(id);
                } else if (widget.type == 'activities') {
                  await ref.read(selectedActivitiesProvider.notifier).toggle(id);
                }
              }
            },
          );
        },
      ),
    );
  }
}