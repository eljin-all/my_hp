import 'package:flutter/services.dart';
import '../models/disease.dart';

class DiseaseService {
  static Future<List<Disease>> loadDiseases({String gender = 'male'}) async {
    final raw = await rootBundle.loadString('assets/databases/diseases.csv');
    final lines = raw.split('\n');

    final diseases = lines
        .where((line) => line.trim().isNotEmpty)
        .skip(1)
        .map((line) {
      try {
        return Disease.fromCsv(line);
      } catch (e) {
        print("Ошибка строки: $line");
        return null;
      }
    })
        .whereType<Disease>()
        .toList();

    return diseases.where((d) {
      if (d.id.endsWith('_f')) {
        return gender == 'female';
      }
      if (d.id.endsWith('_m')) {
        return gender == 'male';
      }
      return true;
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> loadTraumas() async {
    final raw = await rootBundle.loadString('assets/databases/traumas.csv');
    final lines = raw.split('\n');
    return lines.skip(1).where((l) => l.trim().isNotEmpty).map((line) {
      final row = line.split(';');
      return {
        'id': int.parse(row[0]),
        'name': row[1],
        'minus_hp': int.parse(row[2]),
        'scale_type': int.parse(row[3]),
        'system': row.length > 4 ? row[4].trim().toLowerCase() : '',
      };
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> loadActivities() async {
    final raw = await rootBundle.loadString('assets/databases/activities.csv');
    final lines = raw.split('\n');
    return lines.skip(1).where((l) => l.trim().isNotEmpty).map((line) {
      final row = line.split(';');
      return {
        'id': int.parse(row[0]),
        'name': row[1],
        'hp': int.parse(row[2]),
      };
    }).toList();
  }
}