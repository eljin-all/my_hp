import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      selectedItemColor: theme.colorScheme.onSurface,
      unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Здоровье"),
        BottomNavigationBarItem(icon: Icon(Icons.accessibility_new), label: "Системы"),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Состояние"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Профиль"),
      ],
    );
  }
}