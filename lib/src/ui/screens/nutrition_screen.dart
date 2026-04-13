import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background, // Slate 900 base
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Nutrición',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.white54),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TARJETA RESUMEN DE MACROS (Estilo Premium Glassmorphism)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E293B), // Slate 800
                    Color(0xFF0F172A), // Slate 900
                  ],
                ),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DÉFICIT CALÓRICO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.white54,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Objetivo Diario',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1), // Emerald tint
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                        ),
                        child: const Text(
                          '2500 kcal',
                          style: TextStyle(
                            color: Color(0xFF34D399), // Emerald 400
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  // Barras de Macros (Colores vibrantes sobre fondo oscuro)
                  const _MacroBar(
                    label: 'Proteínas',
                    current: 120,
                    total: 160,
                    color: Color(0xFF3B82F6), // Blue 500
                    unit: 'g',
                  ),
                  const SizedBox(height: 24),
                  const _MacroBar(
                    label: 'Carbohidratos',
                    current: 150,
                    total: 300,
                    color: Color(0xFF10B981), // Emerald 500
                    unit: 'g',
                  ),
                  const SizedBox(height: 24),
                  const _MacroBar(
                    label: 'Grasas',
                    current: 40,
                    total: 60,
                    color: Color(0xFFF59E0B), // Amber 500
                    unit: 'g',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            
            const Text(
              'TUS COMIDAS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white54,
                letterSpacing: 2,
              ),
            ),
            
            const SizedBox(height: 20),

            // 2. LISTA DE COMIDAS (Estilo Glass Card)
            const _MealCard(
              title: 'Desayuno',
              time: '08:00 - 09:30',
              foodDetails: 'Avena (50g), Leche de almendras, 1 Scoop de Proteína, Plátano.',
              icon: Icons.wb_twilight_rounded,
              accentColor: Color(0xFFF59E0B), // Amber
            ),
            const _MealCard(
              title: 'Almuerzo',
              time: '14:00 - 15:30',
              foodDetails: 'Pechuga de pollo (200g), Arroz integral (100g), Brócoli.',
              icon: Icons.wb_sunny_rounded,
              accentColor: Color(0xFF3B82F6), // Blue
            ),
            const _MealCard(
              title: 'Cena',
              time: '20:30 - 21:30',
              foodDetails: 'Salmón a la plancha (150g), Patata cocida, Ensalada verde.',
              icon: Icons.nights_stay_rounded,
              accentColor: Color(0xFF8B5CF6), // Violet
            ),
            
            const SizedBox(height: 100), // Espacio para el BottomNav
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS PRIVADOS REUTILIZABLES ---

class _MacroBar extends StatelessWidget {
  final String label;
  final double current;
  final double total;
  final Color color;
  final String unit;

  const _MacroBar({
    required this.label,
    required this.current,
    required this.total,
    required this.color,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = (current / total).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w900, 
                fontSize: 10,
                color: color,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              '${current.toInt()} / ${total.toInt()}$unit',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 8,
              // Usamos un LayoutBuilder o MediaQuery si quisiéramos exactitud, 
              // pero FractionallySizedBox es perfecto aquí.
              child: FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.6),
                        blurRadius: 8,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  final String title;
  final String time;
  final String foodDetails;
  final IconData icon;
  final Color accentColor;

  const _MealCard({
    required this.title,
    required this.time,
    required this.foodDetails,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5), // Slate 800 translúcido
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: accentColor, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  foodDetails,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}