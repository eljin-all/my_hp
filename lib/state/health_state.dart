// lib/state/health_state.dart
import '../models/user_model.dart';
import '../models/disease.dart';
import '../services/hp_service.dart';

class HealthState {
  final UserModel? user;
  final List<Disease> allDiseases;
  final List<Map<String, dynamic>> allTraumas;
  final List<Map<String, dynamic>> allActivities;
  final List<String> selectedDiseaseIds;
  final List<int> selectedTraumaIds;
  final List<int> selectedActivityIds;
  final Map<String, double> diseaseParams;
  final Map<int, double> traumaParams;
  final Map<int, double> activityParams;
  final int maxHp;
  final int currentHp;
  final int imtDebuff;

  const HealthState({
    this.user,
    this.allDiseases = const [],
    this.allTraumas = const [],
    this.allActivities = const [],
    this.selectedDiseaseIds = const [],
    this.selectedTraumaIds = const [],
    this.selectedActivityIds = const [],
    this.diseaseParams = const {},
    this.traumaParams = const {},
    this.activityParams = const {},
    this.maxHp = 100,
    this.currentHp = 100,
    this.imtDebuff = 0,
  });

  HealthState copyWith({
    UserModel? user,
    List<Disease>? allDiseases,
    List<Map<String, dynamic>>? allTraumas,
    List<Map<String, dynamic>>? allActivities,
    List<String>? selectedDiseaseIds,
    List<int>? selectedTraumaIds,
    List<int>? selectedActivityIds,
    Map<String, double>? diseaseParams,
    Map<int, double>? traumaParams,
    Map<int, double>? activityParams,
    int? maxHp,
    int? currentHp,
    int? imtDebuff,
  }) {
    return HealthState(
      user: user ?? this.user,
      allDiseases: allDiseases ?? this.allDiseases,
      allTraumas: allTraumas ?? this.allTraumas,
      allActivities: allActivities ?? this.allActivities,
      selectedDiseaseIds: selectedDiseaseIds ?? this.selectedDiseaseIds,
      selectedTraumaIds: selectedTraumaIds ?? this.selectedTraumaIds,
      selectedActivityIds: selectedActivityIds ?? this.selectedActivityIds,
      diseaseParams: diseaseParams ?? this.diseaseParams,
      traumaParams: traumaParams ?? this.traumaParams,
      activityParams: activityParams ?? this.activityParams,
      maxHp: maxHp ?? this.maxHp,
      currentHp: currentHp ?? this.currentHp,
      imtDebuff: imtDebuff ?? this.imtDebuff,
    );
  }

  // Отсортированные списки
  List<Disease> get sortedDiseases {
    final sorted = List<Disease>.from(allDiseases);
    sorted.sort((a, b) => b.hp.compareTo(a.hp));
    return sorted;
  }

  List<Map<String, dynamic>> get sortedTraumas {
    final sorted = List<Map<String, dynamic>>.from(allTraumas);
    sorted.sort((a, b) => ((b['minus_hp'] as int?) ?? 0).compareTo((a['minus_hp'] as int?) ?? 0));
    return sorted;
  }

  List<Map<String, dynamic>> get sortedActivities {
    final sorted = List<Map<String, dynamic>>.from(allActivities);
    sorted.sort((a, b) => ((b['hp'] as int?) ?? 0).compareTo((a['hp'] as int?) ?? 0));
    return sorted;
  }

  static HealthState recalculate(HealthState prev) {
    if (prev.user == null) {
      return prev.copyWith(currentHp: 100, maxHp: 100, imtDebuff: 0);
    }

    final user = prev.user!;
    final maxHp = HpService.calculateMaxHp(user);
    final imtDebuff = HpService.getImtDebuff(user);

    final selectedDiseases = prev.allDiseases
        .where((d) => prev.selectedDiseaseIds.contains(d.id))
        .toList();

    final selectedTraumas = prev.allTraumas
        .where((t) => prev.selectedTraumaIds.contains(t['id'] as int))
        .toList();

    final selectedActivities = prev.allActivities
        .where((a) => prev.selectedActivityIds.contains(a['id'] as int))
        .toList();

    final currentHp = HpService.applyEffects(
      maxHp,
      user,
      selectedDiseases,
      prev.diseaseParams,
      selectedTraumas,
      prev.traumaParams,
      selectedActivities,
      prev.activityParams,
    );

    return prev.copyWith(
      maxHp: maxHp,
      imtDebuff: imtDebuff,
      currentHp: currentHp,
    );
  }
}