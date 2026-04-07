import 'package:flutter/material.dart';

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mi Rutina', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Cabecera del día
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.cyan]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ¡CORREGIDO!: Aquí era letterSpacing en lugar de trackingSpacing
                Text('DÍA 1', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 2)),
                SizedBox(height: 8),
                Text('Pecho y Tríceps', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Duración est.: 60 min', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Ejercicios de hoy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Lista de ejercicios (Diseño Mockup)
          _buildExerciseCard('Press de Banca', '4 series x 10 repeticiones', Icons.fitness_center),
          _buildExerciseCard('Aperturas con mancuernas', '3 series x 12 repeticiones', Icons.sports_gymnastics),
          _buildExerciseCard('Extensión de Tríceps', '4 series x 15 repeticiones', Icons.accessibility_new),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(String title, String subtitle, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black12,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
          child: Icon(icon, color: Colors.blueAccent),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.check_circle_outline, color: Colors.grey),
      ),
    );
  }
}