import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymflow_app/src/providers/nav_provider.dart';
import 'package:gymflow_app/src/ui/screens/home_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos en qué pestaña estamos
    final currentIndex = ref.watch(navIndexProvider);

    // Lista de pantallas (Por ahora ponemos textos de relleno en las vacías)
    final screens = [
      const HomeScreen(), // La que ya tenemos
      const Center(child: Text('Pantalla de Rutinas 🏋️', style: TextStyle(fontSize: 24))),
      const Center(child: Text('Pantalla de Clases 📅', style: TextStyle(fontSize: 24))),
      const Center(child: Text('Pantalla de Perfil 👤', style: TextStyle(fontSize: 24))),
    ];

    return Scaffold(
      // Usamos IndexedStack para que las pantallas mantengan su estado (scroll, etc.) al cambiar
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            // USAMOS LA NUEVA FUNCIÓN DEL NOTIFIER
            ref.read(navIndexProvider.notifier).changeIndex(index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.fitness_center_rounded), label: 'Rutinas'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Clases'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}