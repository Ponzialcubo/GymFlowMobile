import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymflow_app/src/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos al "cerebro" (Provider) para obtener los datos del usuario
    final user = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('GymFlow', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          // Botón de Cerrar Sesión
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera de Bienvenida
              Text(
                '¡Hola, ${user?.nombre ?? "Socio"}! 👋',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Es un buen día para entrenar duro.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Tarjeta de Resumen (Widget Senior)
              _buildFeatureCard(
                title: 'Rutina de hoy',
                subtitle: 'Pecho y Tríceps',
                icon: Icons.fitness_center,
                color: Colors.blueAccent,
                onTap: () {
                  // Aquí irá la navegación a los ejercicios
                },
              ),
              const SizedBox(height: 16),

              _buildFeatureCard(
                title: 'Mi Progreso',
                subtitle: 'Has completado 3 entrenos esta semana',
                icon: Icons.show_chart,
                color: Colors.green,
                onTap: () {},
              ),
              
              const SizedBox(height: 30),
              const Text(
                'Accesos rápidos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Fila de botones circulares
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickAction(Icons.calendar_month, 'Horarios'),
                  _buildQuickAction(Icons.person, 'Perfil'),
                  _buildQuickAction(Icons.notifications, 'Avisos'),
                  _buildQuickAction(Icons.settings, 'Ajustes'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para las tarjetas principales
  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para acciones rápidas
  Widget _buildQuickAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blueAccent),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}