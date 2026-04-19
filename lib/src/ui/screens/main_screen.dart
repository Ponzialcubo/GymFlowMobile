import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymflow_app/src/providers/nav_provider.dart';
import 'package:gymflow_app/src/ui/screens/home_screen.dart';
import 'package:gymflow_app/src/ui/screens/routines_screen.dart';
import 'package:gymflow_app/src/ui/screens/nutrition_screen.dart';
import 'package:gymflow_app/src/ui/screens/classes_screen.dart';
import 'package:gymflow_app/src/ui/screens/profile_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navIndexProvider);

    final screens = const [
      HomeScreen(),
      RoutinesScreen(),
      NutritionScreen(),
      ClassesScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF0F172A),

      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),

      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withOpacity(0.7),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) {
                ref.read(navIndexProvider.notifier).changeIndex(index);
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              selectedItemColor: const Color(0xFF3B82F6),
              unselectedItemColor: const Color(0xFF94A3B8),
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.home_rounded, size: 26),
                  ),
                  label: 'INICIO',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.fitness_center_rounded, size: 26),
                  ),
                  label: 'RUTINA',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.apple_rounded, size: 26),
                  ),
                  label: 'DIETA',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.calendar_month_rounded, size: 26),
                  ),
                  label: 'CLASES',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.person_rounded, size: 26),
                  ),
                  label: 'PERFIL',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
