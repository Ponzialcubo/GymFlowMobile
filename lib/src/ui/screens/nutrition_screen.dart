import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymflow_app/src/providers/diet_provider.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dietAsync = ref.watch(dietProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Nutrición',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.history_rounded, color: Colors.white54), onPressed: () {})
        ],
      ),
      body: dietAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
        data: (dieta) {
          if (dieta == null) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. TARJETA RESUMEN DE MACROS
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 15))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dieta.objetivo.toUpperCase(),
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white54, letterSpacing: 2),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Objetivo Diario',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              // AQUI ESTABA EL ERROR: Hemos quitado los 'const' de estos colores
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                            ),
                            child: Text(
                              '${dieta.calorias} kcal',
                              style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.w900, letterSpacing: 1),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 40),
                      
                      // BARRAS DE MACROS REALES
                      _MacroBar(label: 'Proteínas', current: dieta.proteinas.toDouble(), total: dieta.proteinas.toDouble(), color: const Color(0xFF3B82F6), unit: 'g'),
                      const SizedBox(height: 24),
                      _MacroBar(label: 'Carbohidratos', current: dieta.carbos.toDouble(), total: dieta.carbos.toDouble(), color: const Color(0xFF10B981), unit: 'g'),
                      const SizedBox(height: 24),
                      _MacroBar(label: 'Grasas', current: dieta.grasas.toDouble(), total: dieta.grasas.toDouble(), color: const Color(0xFFF59E0B), unit: 'g'),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                const Text(
                  'TUS COMIDAS',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 2),
                ),
                const SizedBox(height: 20),

                // 2. LISTA DE COMIDAS DINÁMICA
                if (dieta.comidas.isEmpty)
                  const Text('No hay alimentos registrados en esta dieta.', style: TextStyle(color: Colors.white54)),

                ...dieta.comidas.map((comida) {
                  IconData icon = Icons.restaurant_rounded;
                  Color color = const Color(0xFF3B82F6);
                  String time = 'Horario libre';

                  final nombreLower = comida.title.toLowerCase();
                  if (nombreLower.contains('desayuno')) {
                    icon = Icons.wb_twilight_rounded; color = const Color(0xFFF59E0B); time = '08:00 - 09:30';
                  } else if (nombreLower.contains('comida') || nombreLower.contains('almuerzo')) {
                    icon = Icons.wb_sunny_rounded; color = const Color(0xFF3B82F6); time = '14:00 - 15:30';
                  } else if (nombreLower.contains('merienda')) {
                    icon = Icons.pie_chart_rounded; color = const Color(0xFF10B981); time = '17:30 - 18:30';
                  } else if (nombreLower.contains('cena')) {
                    icon = Icons.nights_stay_rounded; color = const Color(0xFF8B5CF6); time = '20:30 - 21:30';
                  }

                  return _MealCard(
                    title: comida.title,
                    time: time,
                    foodDetails: comida.foodDetails,
                    icon: icon,
                    accentColor: color,
                  );
                }).toList(),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_menu_rounded, size: 80, color: Colors.white10),
          const SizedBox(height: 16),
          const Text('Sin dieta asignada', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Habla con tu entrenador para tu plan.', style: TextStyle(color: Colors.white54)),
        ],
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

  const _MacroBar({required this.label, required this.current, required this.total, required this.color, required this.unit});

  @override
  Widget build(BuildContext context) {
    final double percentage = total > 0 ? (current / total).clamp(0.0, 1.0) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: color, letterSpacing: 1.5)),
            Text('${current.toInt()} / ${total.toInt()}$unit', style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white70, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(height: 8, decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(10))),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 8,
              child: FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 8)],
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

  const _MealCard({required this.title, required this.time, required this.foodDetails, required this.icon, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
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
                    Text(title.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                    Text(time, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 0.5)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(foodDetails, style: const TextStyle(fontSize: 13, height: 1.6, color: Colors.white70, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}