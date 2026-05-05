import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserService {
  static const _keyBirth = 'birth';
  static const _keyHeight = 'height';
  static const _keyWeight = 'weight';
  static const _keyGender = 'gender';
  static const _keyCurrentHp = 'current_hp';
  static const _keyDiseases = 'user_diseases';
  static const _keyTraumas = 'user_traumas';
  static const _keyActivities = 'user_activities';
  static const _keyDiseaseParams = 'disease_params';
  static const _keyTraumaParams = 'trauma_params';
  static const _keyActivityParams = 'activity_params';
  static const _keyHpHistory = 'hp_history';

  static Future<void> addHpRecord(int hp) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyHpHistory);
    List data = [];
    if (raw != null) {
      data = jsonDecode(raw);
    }
    if (data.isNotEmpty && data.last['hp'] == hp) {
      return;
    }
    data.add({
      'hp': hp,
      'time': DateTime.now().toIso8601String(),
    });
    await prefs.setString(_keyHpHistory, jsonEncode(data));
  }

  static Future<List<Map<String, dynamic>>> getHpHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyHpHistory);
    if (raw == null) return [];
    final list = jsonDecode(raw);
    return List<Map<String, dynamic>>.from(list);
  }

  static Future<void> saveActivityParam(int id, double value) async {
    final prefs = await SharedPreferences.getInstance();
    final map = prefs.getString(_keyActivityParams);
    Map<String, dynamic> data = {};
    if (map != null) {
      data = Map<String, dynamic>.from(jsonDecode(map));
    }
    data[id.toString()] = value;
    await prefs.setString(_keyActivityParams, jsonEncode(data));
  }

  static Future<double?> getActivityParam(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final map = prefs.getString(_keyActivityParams);
    if (map == null) return null;
    final data = jsonDecode(map);
    return data[id.toString()]?.toDouble();
  }

  static Future<void> saveTraumaParam(int id, double value) async {
    final prefs = await SharedPreferences.getInstance();
    final map = prefs.getString(_keyTraumaParams);
    Map<String, dynamic> data = {};
    if (map != null) {
      data = Map<String, dynamic>.from(jsonDecode(map));
    }
    data[id.toString()] = value;
    await prefs.setString(_keyTraumaParams, jsonEncode(data));
  }

  static Future<double?> getTraumaParam(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final map = prefs.getString(_keyTraumaParams);
    if (map == null) return null;
    final data = jsonDecode(map);
    return data[id.toString()]?.toDouble();
  }

  static Future<void> saveDiseaseParam(String diseaseId, double value) async {
    final prefs = await SharedPreferences.getInstance();
    final map = prefs.getString(_keyDiseaseParams);
    Map<String, dynamic> data = {};
    if (map != null) {
      data = Map<String, dynamic>.from(jsonDecode(map));
    }
    data[diseaseId] = value;
    await prefs.setString(_keyDiseaseParams, jsonEncode(data));
  }

  static Future<double?> getDiseaseParam(String diseaseId) async {
    final prefs = await SharedPreferences.getInstance();
    final map = prefs.getString(_keyDiseaseParams);
    if (map == null) return null;
    final data = jsonDecode(map);
    return data[diseaseId]?.toDouble();
  }

  static Future<void> saveTraumas(List<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keyTraumas,
      ids.map((e) => e.toString()).toList(),
    );
  }

  static Future<void> removeDiseaseParam(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("disease_param_$id");
  }

  static Future<List<int>> getTraumas() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyTraumas) ?? [];
    return list.map((e) => int.parse(e)).toList();
  }

  static Future<void> saveActivities(List<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keyActivities,
      ids.map((e) => e.toString()).toList(),
    );
  }

  static Future<List<int>> getActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyActivities) ?? [];
    return list.map((e) => int.parse(e)).toList();
  }

  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBirth, user.birthDate.toIso8601String());
    await prefs.setDouble(_keyHeight, user.height);
    await prefs.setDouble(_keyWeight, user.weight);
    await prefs.setString(_keyGender, user.gender);
  }

  static Future<void> saveDiseases(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyDiseases, ids);
  }

  static Future<List<String>> getDiseases() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyDiseases) ?? [];
  }

  static Future<void> saveCurrentHp(int hp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCurrentHp, hp);
  }

  static Future<int> getCurrentHp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCurrentHp) ?? 100;
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final birth = prefs.getString(_keyBirth);
    final height = prefs.getDouble(_keyHeight);
    final weight = prefs.getDouble(_keyWeight);
    final gender = prefs.getString(_keyGender) ?? 'male';
    if (birth == null || height == null || weight == null) {
      return null;
    }
    return UserModel(
      birthDate: DateTime.parse(birth),
      height: height,
      weight: weight,
      gender: gender,
    );
  }
}