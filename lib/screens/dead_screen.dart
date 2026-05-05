import 'package:flutter/material.dart';

class DeadScreen extends StatefulWidget {
  const DeadScreen({super.key});

  @override
  State<DeadScreen> createState() => _DeadScreenState();
}

class _DeadScreenState extends State<DeadScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _scaleAnimation = Tween<double>(begin: 1.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Тёмный фон с тусклым красным свечением
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.shade900.withOpacity(0.4),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          // Декоративные красные линии по бокам
          Positioned(
            top: 0,
            bottom: 0,
            left: 20,
            child: Container(width: 1, color: Colors.red.shade900.withOpacity(0.3)),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: 20,
            child: Container(width: 1, color: Colors.red.shade900.withOpacity(0.3)),
          ),
          Positioned(
            top: 40,
            left: 40,
            right: 40,
            child: Container(height: 1, color: Colors.red.shade900.withOpacity(0.2)),
          ),
          Positioned(
            bottom: 120,
            left: 40,
            right: 40,
            child: Container(height: 1, color: Colors.red.shade900.withOpacity(0.2)),
          ),

          // Основной контент
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'YOU DIED',
                          style: TextStyle(
                            color: Color(0xFF8B0000),
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 8,
                            fontFamily: 'Serif',
                          ),
                        ),
                        const SizedBox(height: 40),
                        Icon(
                          Icons.local_fire_department,
                          color: Colors.red.shade700,
                          size: 60,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Но надежда ещё не угасла...',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 50),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context, true),
                          icon: const Icon(Icons.local_fire_department, color: Colors.white),
                          label: const Text(
                            'ВОСКРЕСНУТЬ',
                            style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 3,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A0000),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                              side: BorderSide(color: Colors.red.shade800, width: 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}