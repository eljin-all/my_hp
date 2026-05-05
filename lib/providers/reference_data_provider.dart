import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/disease.dart';
import '../services/disease_service.dart';

part 'reference_data_provider.g.dart';

@Riverpod(keepAlive: true)
Future<List<Disease>> allDiseases(AllDiseasesRef ref, {required String gender}) async {
  return DiseaseService.loadDiseases(gender: gender);
}

@Riverpod(keepAlive: true)
Future<List<Map<String, dynamic>>> allTraumas(AllTraumasRef ref) async {
  return DiseaseService.loadTraumas();
}

@Riverpod(keepAlive: true)
Future<List<Map<String, dynamic>>> allActivities(AllActivitiesRef ref) async {
  return DiseaseService.loadActivities();
}