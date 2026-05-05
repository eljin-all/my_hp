import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import 'main_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  String gender = 'male';
  String? errorText;

  void save() {
    final ageText = ageController.text.trim();
    final heightText = heightController.text.trim();
    final weightText = weightController.text.trim();

    if (ageText.isEmpty || heightText.isEmpty || weightText.isEmpty) {
      setState(() => errorText = 'Заполните все поля');
      return;
    }

    final age = int.tryParse(ageText);
    final height = double.tryParse(heightText);
    final weight = double.tryParse(weightText);

    if (age == null || height == null || weight == null) {
      setState(() => errorText = 'Введите корректные числа');
      return;
    }

    if (age < 1 || age > 120) {
      setState(() => errorText = 'Возраст должен быть от 1 до 120 лет');
      return;
    }

    if (height < 50 || height > 300) {
      setState(() => errorText = 'Рост должен быть от 50 до 300 см');
      return;
    }

    if (weight < 10 || weight > 500) {
      setState(() => errorText = 'Вес должен быть от 10 до 500 кг');
      return;
    }

    _submitUser(age, height, weight);
  }

  void _submitUser(int age, double height, double weight) async {
    final birthDate = DateTime.now().subtract(Duration(days: age * 365));

    final user = UserModel(
      birthDate: birthDate,
      height: height,
      weight: weight,
      gender: gender,
    );

    await ref.read(userNotifierProvider.notifier).saveUser(user);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Регистрация")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'male', label: Text('Мужской'), icon: Icon(Icons.male)),
                ButtonSegment(value: 'female', label: Text('Женский'), icon: Icon(Icons.female)),
              ],
              selected: {gender},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  gender = newSelection.first;
                  errorText = null;
                });
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Возраст (1-120 лет)",
                border: const OutlineInputBorder(),
                errorText: errorText != null && ageController.text.isEmpty ? '' : null,
              ),
              onChanged: (_) => setState(() => errorText = null),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Рост (50-300 см)",
                border: const OutlineInputBorder(),
                errorText: errorText != null && heightController.text.isEmpty ? '' : null,
              ),
              onChanged: (_) => setState(() => errorText = null),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Вес (10-500 кг)",
                border: const OutlineInputBorder(),
                errorText: errorText != null && weightController.text.isEmpty ? '' : null,
              ),
              onChanged: (_) => setState(() => errorText = null),
            ),
            if (errorText != null) ...[
              const SizedBox(height: 16),
              Text(
                errorText!,
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 14),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Начать", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}