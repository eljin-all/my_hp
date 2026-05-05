import 'package:flutter/material.dart';
import 'state_list_screen.dart';

class StateScreen extends StatelessWidget {
  const StateScreen({super.key});

  void open(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StateListScreen(type: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Expanded(
            child: _buildCard(
              context,
              title: "Болезни",
              icon: Icons.healing,
              color: Colors.red.shade400,
              onTap: () => open(context, 'diseases'),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _buildCard(
              context,
              title: "Травмы",
              icon: Icons.sports_mma,
              color: Colors.orange.shade400,
              onTap: () => open(context, 'traumas'),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _buildCard(
              context,
              title: "Активности",
              icon: Icons.directions_run,
              color: Colors.green.shade400,
              onTap: () => open(context, 'activities'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.8), color],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 90, color: Colors.white),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Нажмите для просмотра",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}