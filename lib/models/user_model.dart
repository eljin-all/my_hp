class UserModel {
  final int age;       // возраст в годах
  final double height; // см
  final double weight; // кг
  final String gender; // 'male' или 'female'

  UserModel({
    required this.age,
    required this.height,
    required this.weight,
    required this.gender,
  });
}