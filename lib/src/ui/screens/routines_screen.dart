import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymflow_app/src/models/routine_model.dart';
import 'package:gymflow_app/src/providers/routines_provider.dart';

class RoutinesScreen extends ConsumerStatefulWidget {
  const RoutinesScreen({super.key});

  @override
  ConsumerState<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends ConsumerState<RoutinesScreen> {
  String selectedDay = 'Lunes';
  final List<String> diasSemana = const ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];

  @override
  Widget build(BuildContext context) {
    final routinesAsync = ref.watch(routinesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background, // Slate 900
      appBar: AppBar(
        title: const Text('Mi Rutina', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- SELECTOR DE DÍAS ---
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: diasSemana.length,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              itemBuilder: (context, index) {
                final dia = diasSemana[index];
                final isSelected = dia.toLowerCase() == selectedDay.toLowerCase();
                
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(dia.toUpperCase(), style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white54,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1,
                    )),
                    selected: isSelected,
                    selectedColor: const Color(0xFF3B82F6),
                    backgroundColor: Colors.white.withOpacity(0.05),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF3B82F6) : Colors.white.withOpacity(0.1),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (selected) {
                      if (selected) setState(() => selectedDay = dia);
                    },
                  ),
                );
              },
            ),
          ),
          
          // --- LISTA DE EJERCICIOS ---
          Expanded(
            child: routinesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
              error: (err, stack) => Center(child: Text('Error al cargar: $err', style: const TextStyle(color: Colors.redAccent))),
              data: (todasLasRutinas) {
                
                final rutinasDelDia = todasLasRutinas.where(
                  (r) => r.diaSemana.toLowerCase() == selectedDay.toLowerCase()
                ).toList();

                if (rutinasDelDia.isEmpty) {
                  return _buildEmptyState();
                }

                final completados = rutinasDelDia.where((r) => r.completado).length;
                final progreso = rutinasDelDia.isNotEmpty ? completados / rutinasDelDia.length : 0.0;

                return ListView(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Cabecera colorida (Dashboard Mini)
                    _buildProgressHeader(progreso, completados, rutinasDelDia.length),
                    
                    const SizedBox(height: 40),
                    const Text('EJERCICIOS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 2)),
                    const SizedBox(height: 16),
                    
                    ...rutinasDelDia.map((rutina) => _buildExerciseCard(rutina)),
                    const SizedBox(height: 100), // Espacio para el BottomNav
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPONENTES VISUALES ---

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.hotel_class_rounded, size: 60, color: Colors.white24),
          ),
          const SizedBox(height: 24),
          const Text('Día de Descanso', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
          const SizedBox(height: 8),
          const Text('Recupera energías para el próximo entreno.', style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(double progreso, int completados, int total) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2563EB), Color(0xFF0F172A)], // Blue 600 to Slate 900
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(selectedDay.toUpperCase(), style: const TextStyle(color: Color(0xFF93C5FD), fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 10)),
              const SizedBox(height: 8),
              const Text('Entrenamiento', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
              const SizedBox(height: 32),
              // Barra de progreso visual Glow
              Stack(
                children: [
                  Container(height: 8, decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(10))),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    height: 8,
                    width: (constraints.maxWidth - 64) * progreso, // 64 es el padding total (32+32)
                    decoration: BoxDecoration(
                      color: const Color(0xFF60A5FA), // Blue 400
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        if (progreso > 0) BoxShadow(color: const Color(0xFF60A5FA).withOpacity(0.8), blurRadius: 10)
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('$completados de $total completados', style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        );
      }
    );
  }

  Widget _buildExerciseCard(RoutineModel rutina) {
    final isDone = rutina.completado;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFF064E3B).withOpacity(0.2) : const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDone ? const Color(0xFF10B981).withOpacity(0.3) : Colors.white.withOpacity(0.05), width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        onTap: () {
          // AQUI SE LLAMA AL NOTIFIER QUE AHORA SÍ EXISTE
          ref.read(routinesProvider.notifier).toggleExercise(rutina.id, isDone);
        },
        leading: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFF10B981).withOpacity(0.2) : Colors.white.withOpacity(0.05), 
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.fitness_center_rounded, color: isDone ? const Color(0xFF34D399) : Colors.white54, size: 20),
        ),
        title: Text(
          rutina.nombreEjercicio, 
          style: TextStyle(
            fontWeight: FontWeight.w900, 
            fontSize: 16, 
            color: isDone ? Colors.white54 : Colors.white,
            decoration: isDone ? TextDecoration.lineThrough : null,
            decorationColor: Colors.white54,
          )
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            '${rutina.series} series × ${rutina.repeticiones} reps', 
            style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w800, fontSize: 12)
          ),
        ),
        trailing: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFF10B981) : Colors.transparent,
            border: Border.all(color: isDone ? const Color(0xFF10B981) : Colors.white24, width: 2),
            shape: BoxShape.circle,
          ),
          child: isDone ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
        ),
      ),
    );
  }
}