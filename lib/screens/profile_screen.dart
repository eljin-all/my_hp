// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/hp_service.dart';
import '../services/emergency_service.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final thresholdController = TextEditingController();

  bool callAmbulance = false;
  int maxHp = 0;
  int criticalThreshold = 30;
  String gender = 'male';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final user = await UserService.getUser();
    if (user != null) {
      final age = _calculateAge(user.birthDate);
      ageController.text = age.toString();
      heightController.text = user.height.toStringAsFixed(0);
      weightController.text = user.weight.toStringAsFixed(1);
      gender = user.gender;
      maxHp = HpService.calculateMaxHp(user);
    }

    callAmbulance = await EmergencyService.isCallEnabled();
    phoneController.text = await EmergencyService.getPhoneNumber();
    criticalThreshold = await EmergencyService.getThreshold();
    thresholdController.text = criticalThreshold.toString();

    setState(() {});
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void save() async {
    final user = await UserService.getUser();
    if (user == null) return;

    // Валидация возраста, роста, веса
    final ageText = ageController.text.trim();
    final heightText = heightController.text.trim();
    final weightText = weightController.text.trim();

    final age = int.tryParse(ageText);
    final height = double.tryParse(heightText);
    final weight = double.tryParse(weightText);

    if (age == null || age < 1 || age > 120) {
      _showError('Возраст должен быть от 1 до 120 лет');
      return;
    }
    if (height == null || height < 50 || height > 300) {
      _showError('Рост должен быть от 50 до 300 см');
      return;
    }
    if (weight == null || weight < 10 || weight > 500) {
      _showError('Вес должен быть от 10 до 500 кг');
      return;
    }

    // Валидация критического порога
    final thresholdText = thresholdController.text.trim();
    final threshold = int.tryParse(thresholdText);
    if (threshold == null || threshold < 0 || threshold > 50) {
      _showError('Критический порог должен быть от 0 до 50');
      return;
    }

    // Валидация номера телефона
    if (callAmbulance && phoneController.text.trim().isEmpty) {
      _showError('Введите номер больницы для экстренного звонка');
      return;
    }
    if (phoneController.text.isNotEmpty && !RegExp(r'^\d+$').hasMatch(phoneController.text.trim())) {
      _showError('Номер телефона может содержать только цифры');
      return;
    }

    final today = DateTime.now();
    DateTime birthDate = DateTime(today.year - age, today.month, today.day);
    if (birthDate.isAfter(today)) {
      birthDate = DateTime(today.year - age - 1, today.month, today.day);
    }

    final updated = UserModel(
      birthDate: birthDate,
      height: height,
      weight: weight,
      gender: gender,
    );

    await ref.read(userNotifierProvider.notifier).saveUser(updated);

    await EmergencyService.saveSettings(
      enabled: callAmbulance,
      phone: phoneController.text.trim(),
      threshold: threshold,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Изменения сохранены'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    _loadData();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 40),
                  const Text("Пол:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'male', label: Text('Мужской'), icon: Icon(Icons.male)),
                      ButtonSegment(value: 'female', label: Text('Женский'), icon: Icon(Icons.female)),
                    ],
                    selected: {gender},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        gender = newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Возраст (лет)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Рост (см)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Вес (кг)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  Text(
                    "Текущее максимальное HP: $maxHp",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const Text(
                    "Настройки экстренной помощи",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text("Звонить в больницу при критическом HP?"),
                    subtitle: callAmbulance && phoneController.text.trim().isEmpty
                        ? Text(
                      'Необходимо ввести номер телефона',
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                    )
                        : null,
                    value: callAmbulance,
                    onChanged: (value) {
                      setState(() {
                        callAmbulance = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: thresholdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Критический порог HP (0-50)",
                      border: OutlineInputBorder(),
                      hintText: "например, 30",
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Номер больницы",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Сохранить изменения", style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}