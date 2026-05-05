import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/health_state_provider.dart';
import '../providers/hp_persistence_provider.dart';
import '../providers/critical_state_provider.dart';
import '../widgets/bottom_nav.dart';
import 'home_tab.dart';
import 'profile_screen.dart';
import 'systems_list_screen.dart';
import 'state_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _currentIndex = 0;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;

  final List<Widget> _pages = [
    const HomeTab(),
    const SystemsListScreen(),
    const StateScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);

    ref.listenManual(healthStateProvider, (prev, next) {
      next.whenData((state) {
        ref.read(hpPersistenceProvider.notifier).save(state.currentHp);
        ref.read(criticalStateProvider.notifier).resetDialog();
        ref.read(criticalStateProvider.notifier).checkAndShowIfNeeded(context, state.currentHp);
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final healthState = ref.read(healthStateProvider).valueOrNull;
      if (healthState != null) {
        ref.read(criticalStateProvider.notifier).resetDialog();
        ref.read(criticalStateProvider.notifier).checkAndShowIfNeeded(context, healthState.currentHp);
      }
    });

    _animController.forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final healthState = ref.read(healthStateProvider).valueOrNull;
      if (healthState != null) {
        ref.read(criticalStateProvider.notifier).resetDialog();
        ref.read(criticalStateProvider.notifier).checkAndShowIfNeeded(context, healthState.currentHp);
      }
    }
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _animController.reset();
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}