import 'package:flutter/material.dart';

import 'package:cinematic_weather/core/theme/app_theme.dart';
import 'package:cinematic_weather/presentation/screens/home_screen.dart';
import 'package:cinematic_weather/presentation/screens/radar_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  static const _screens = [HomeScreen(), RadarScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: _BottomNav(
        index: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: index,
        onTap: onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.accentBlue,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.wb_sunny_outlined),
            activeIcon: Icon(Icons.wb_sunny),
            label: 'Weather',
            tooltip: 'Weather — current conditions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.radar_outlined),
            activeIcon: Icon(Icons.radar),
            label: 'Radar',
            tooltip: 'Radar — live weather map',
          ),
        ],
      ),
    );
  }
}
