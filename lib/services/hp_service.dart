import '../models/disease.dart';

class HpService {
  static int _getBaseHpByAge(int age) {
    if (age <= 12) return 70;
    if (age <= 17) return 90;
    if (age <= 40) return 100;
    if (age <= 60) return 100;
    if (age <= 75) return 90;
    return 70;
  }

  static int calculateMaxHp(user) {
    int baseHp = _getBaseHpByAge(user.age);
    final heightM = user.height / 100;
    final bmi = user.weight / (heightM * heightM);
    if (bmi < 18.5 || bmi > 24.9) {
      baseHp = (baseHp * 0.9).round();
    }
    return baseHp;
  }

  static int getImtDebuff(user) {
    int baseHp = _getBaseHpByAge(user.age);
    final heightM = user.height / 100;
    final bmi = user.weight / (heightM * heightM);
    if (bmi < 18.5 || bmi > 24.9) {
      return baseHp - (baseHp * 0.9).round();
    }
    return 0;
  }

  static int getAgeDebuff(user) {
    final baseHp = _getBaseHpByAge(user.age);
    return 100 - baseHp;
  }

  static double calculateDiseaseEffect(Disease d, double param) {
    double factor;
    if (d.system == 'oncology') {
      factor = param / 5;
    } else if (d.system == 'oral_cavity') {
      factor = param / 32;
    } else if (d.system == 'skin' || d.system == 'nervous_system') {
      factor = param / 3;
    } else {
      factor = param / 5;
    }
    return d.hp * factor;
  }

  static double calculateTraumaEffect(Map<String, dynamic> t, double param) {
    final minusHp = t['minus_hp'] ?? 0;
    final scale = t['scale_type'] ?? 0;
    if (scale == 0) return minusHp.toDouble();
    if (t['system'] == 'oral_cavity') {
      return minusHp * (param / 32);
    }
    return minusHp * (param / 10);
  }

  static double calculateActivityEffect(Map<String, dynamic> a, double param) {
    final plusHp = a['plus_hp'] ?? a['hp'] ?? 0;
    return plusHp * (param / 7);
  }

  static int applyEffects(
      int maxHp,
      dynamic user,
      List<Disease> diseases,
      Map<String, double> diseaseParams,
      List<Map<String, dynamic>> traumas,
      Map<int, double> traumaParams,
      List<Map<String, dynamic>> activities,
      Map<int, double> activityParams,
      ) {
    double hp = maxHp.toDouble();
    for (final d in diseases) {
      final p = diseaseParams[d.id] ?? 1;
      hp -= calculateDiseaseEffect(d, p);
    }
    for (final t in traumas) {
      final id = t['id'];
      final p = traumaParams[id] ?? 1;
      hp -= calculateTraumaEffect(t, p);
    }
    for (final a in activities) {
      final id = a['id'];
      final p = activityParams[id] ?? 1;
      hp += calculateActivityEffect(a, p);
    }
    if (hp <= 0) hp = 1;
    if (hp > maxHp) hp = maxHp.toDouble();
    return hp.round();
  }
}