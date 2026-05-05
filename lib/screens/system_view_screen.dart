// screens/system_view_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../models/disease.dart';
import '../state/health_state.dart';
import '../providers/diseases_provider.dart';
import '../providers/health_state_provider.dart';
import '../services/hp_service.dart';
import '../state/model_state.dart';
import '../utils/dialogs.dart';
import 'systems_list_screen.dart';

class SystemViewScreen extends ConsumerStatefulWidget {
  final SystemItem item;

  const SystemViewScreen({super.key, required this.item});

  @override
  ConsumerState<SystemViewScreen> createState() => _SystemViewScreenState();
}

class _SystemViewScreenState extends ConsumerState<SystemViewScreen>
    with SingleTickerProviderStateMixin {
  List<Disease> diseases = [];
  List<String> selectedIds = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _loadDiseases();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _loadDiseases() async {
    final healthState = await ref.read(healthStateProvider.future);
    final allDiseases = healthState.allDiseases;
    final selected = healthState.selectedDiseaseIds;

    final systemDiseases = allDiseases
        .where((d) => d.system.trim() == widget.item.path.trim())
        .toList();

    setState(() {
      diseases = systemDiseases;
      selectedIds = selected;
    });

    _updateModelState(healthState);
  }

  void _updateModelState(HealthState state) {
    double systemHp = state.maxHp.toDouble();
    final systemSelectedDiseases = state.allDiseases
        .where((d) => d.system.trim() == widget.item.path.trim() &&
        state.selectedDiseaseIds.contains(d.id))
        .toList();
    for (final d in systemSelectedDiseases) {
      final p = state.diseaseParams[d.id] ?? 1;
      systemHp -= HpService.calculateDiseaseEffect(d, p);
    }
    if (systemHp < 0) systemHp = 0;
    if (systemHp > state.maxHp) systemHp = state.maxHp.toDouble();
    final percent = systemHp / state.maxHp;
    ModelState modelState;
    if (percent > 0.7) {
      modelState = ModelState.good;
    } else if (percent > 0.4) {
      modelState = ModelState.mid;
    } else {
      modelState = ModelState.bad;
    }
    GlobalModelState.setState(widget.item.path, modelState);
  }

  String getModelPath(String systemPath) {
    return 'assets/systems/$systemPath/model.glb';
  }

  String getVariantName(ModelState state) {
    switch (state) {
      case ModelState.good:
        return 'good';
      case ModelState.mid:
        return 'mid';
      case ModelState.bad:
        return 'bad';
    }
  }

  List<Disease> get filteredDiseases {
    if (_searchQuery.isEmpty) return diseases;
    return diseases
        .where((d) => d.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<HealthState>>(healthStateProvider, (_, next) {
      next.whenData((state) => _updateModelState(state));
    });

    final healthStateAsync = ref.watch(healthStateProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.item.name)),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: healthStateAsync.when(
              data: (state) {
                final currentState = GlobalModelState.getState(widget.item.path);
                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: ModelViewer(
                          key: ValueKey(currentState),
                          src: getModelPath(widget.item.path),
                          variantName: getVariantName(currentState),
                          autoRotate: true,
                          cameraControls: true,
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Ошибка: $err')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск болезней...',
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
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            flex: 1,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: filteredDiseases.isEmpty
                  ? Center(
                key: const ValueKey('empty'),
                child: const Text("Нет данных"),
              )
                  : ListView.builder(
                key: const ValueKey('list'),
                itemCount: filteredDiseases.length,
                itemBuilder: (context, index) {
                  final d = filteredDiseases[index];
                  final isSelected = selectedIds.contains(d.id);
                  return ListTile(
                    title: Text(d.name),
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected ? Colors.green : Colors.grey,
                    ),
                    trailing: Text("HP: ${d.hp}"),
                    onTap: () async {
                      if (!isSelected) {
                        double? param;
                        if (d.system == 'oncology') {
                          param = await showNumberSliderDialog(context, min: 1, max: 5, title: "Стадия (1-5)");
                        } else if (d.system == 'oral_cavity') {
                          param = await showNumberSliderDialog(context, min: 1, max: 32, title: "Количество зубов");
                        } else if (d.system == 'skin' || d.system == 'nervous_system') {
                          param = await showNumberSliderDialog(context, min: 1, max: 3, title: "Степень (1-3)");
                        } else {
                          param = await showNumberSliderDialog(context, min: 1, max: 5, title: "Сила заболевания (1-5)");
                        }
                        if (param == null) return;
                        await ref.read(selectedDiseasesProvider.notifier).toggle(d.id, param: param);
                      } else {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Подтверждение'),
                            content: Text('Удалить болезнь "${d.name}"?'),
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
                        await ref.read(selectedDiseasesProvider.notifier).toggle(d.id);
                      }
                      final newSelected = ref.read(selectedDiseasesProvider).valueOrNull ?? [];
                      setState(() {
                        selectedIds = newSelected;
                      });
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}