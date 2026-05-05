import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'system_view_screen.dart';
import '../providers/user_provider.dart';

class SystemItem {
  final String name;
  final String path;

  SystemItem(this.name, this.path);
}

class SystemsListScreen extends ConsumerWidget {
  const SystemsListScreen({super.key});

  void openSystem(BuildContext context, SystemItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SystemViewScreen(item: item),
      ),
    );
  }

  List<SystemItem> _getFilteredSystems(String gender) {
    return [
      SystemItem("Сердечно-сосудистая", "cardiovascular_system"),
      SystemItem("Пищеварительная", "digestive_system"),
      SystemItem("Эндокринная", "endocrine_system"),
      if (gender == 'female')
        SystemItem("Мочеполовая", "genitourinary_system_female")
      else
        SystemItem("Мочеполовая", "genitourinary_system_male"),
      SystemItem("Иммунная", "immune_system"),
      SystemItem("Инфекции", "infections"),
      SystemItem("Опорно-двигательная", "musculoskeletal_system"),
      SystemItem("Нервная", "nervous_system"),
      SystemItem("Онкология", "oncology"),
      SystemItem("Полость рта", "oral_cavity"),
      SystemItem("Зрение и слух", "vision_and_hearing"),
      SystemItem("Дыхательная", "respiratory_system"),
      SystemItem("Кожа", "skin"),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userNotifierProvider);
    final gender = userAsync.valueOrNull?.gender ?? 'male';
    final systems = _getFilteredSystems(gender);

    return Scaffold(
      appBar: AppBar(title: const Text("Системы")),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: systems.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final item = systems[index];
          return GestureDetector(
            onTap: () => openSystem(context, item),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/systems/${item.path}/preview.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}