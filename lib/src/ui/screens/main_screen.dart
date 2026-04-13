import 'dart:ui'; // <-- Necesario para el ImageFilter del cristal
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymflow_app/src/providers/nav_provider.dart';
import 'package:gymflow_app/src/ui/screens/home_screen.dart';
import 'package:gymflow_app/src/ui/screens/routines_screen.dart';
import 'package:gymflow_app/src/ui/screens/nutrition_screen.dart'; 
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
      ProfileScreen(),
    ];

    return Scaffold(
      // 🚀 MAGIA AQUÍ: Permite que el contenido haga scroll por debajo de la Navbar
      extendBody: true, 
      backgroundColor: const Color(0xFF0F172A), // Slate 900 base
      
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      
      // 💎 NAVBAR EFECTO CRISTAL (Glassmorphism)
      bottomNavigationBar: ClipRRect(
        // Necesitamos ClipRRect para que el blur no se salga de la caja
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Desenfoque potente
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withOpacity(0.7), // Fondo oscuro translúcido
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1), // Borde superior brillante muy sutil
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
              backgroundColor: Colors.transparent, // ¡Debe ser transparente para ver el blur!
              selectedItemColor: const Color(0xFF3B82F6), // Blue 500 (Acento vibrante)
              unselectedItemColor: const Color(0xFF94A3B8), // Slate 400 (Apagado elegante)
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
                  label: 'INICIO'
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.fitness_center_rounded, size: 26),
                  ), 
                  label: 'RUTINA'
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.apple_rounded, size: 26),
                  ), 
                  label: 'DIETA'
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.person_rounded, size: 26),
                  ), 
                  label: 'PERFIL'
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}