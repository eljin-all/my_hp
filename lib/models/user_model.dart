// models/user_model.dart
class UserModel {
  final DateTime birthDate;
  final double height;
  final double weight;
  final String gender; // 'male' или 'female'

  UserModel({
    required this.birthDate,
    required this.height,
    required this.weight,
    required this.gender,
  });
}