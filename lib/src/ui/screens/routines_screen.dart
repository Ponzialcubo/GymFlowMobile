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

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mi Rutina', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- SELECTOR DE DÍAS ---
          Container(
            color: Colors.white,
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: diasSemana.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemBuilder: (context, index) {
                final dia = diasSemana[index];
                final isSelected = dia.toLowerCase() == selectedDay.toLowerCase();
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(dia, style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    )),
                    selected: isSelected,
                    selectedColor: Colors.blueAccent,
                    backgroundColor: Colors.grey[100],
                    side: BorderSide.none,
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error al cargar: $err')),
              data: (todasLasRutinas) {
                
                final rutinasDelDia = todasLasRutinas.where(
                  (r) => r.diaSemana.toLowerCase() == selectedDay.toLowerCase()
                ).toList();

                if (rutinasDelDia.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hotel_class_rounded, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('Día de Descanso', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                        const SizedBox(height: 8),
                        Text('Recupera energías para el próximo entreno.', style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                // Calculamos el progreso (ej: 2 de 4 ejercicios completados)
                final completados = rutinasDelDia.where((r) => r.completado).length;
                final progreso = completados / rutinasDelDia.length;

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Cabecera colorida
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.cyan]),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(selectedDay.toUpperCase(), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12)),
                          const SizedBox(height: 8),
                          const Text('Entrenamiento', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 16),
                          // Barra de progreso visual
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progreso,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('$completados de ${rutinasDelDia.length} completados', style: const TextStyle(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text('Ejercicios', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.grey[800], letterSpacing: -0.5)),
                    const SizedBox(height: 16),
                    
                    // AHORA PASAMOS EL MODELO COMPLETO Y EL REF A LA TARJETA
                    ...rutinasDelDia.map((rutina) => _buildExerciseCard(rutina)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- TARJETA INTERACTIVA ---
  Widget _buildExerciseCard(RoutineModel rutina) {
    final isDone = rutina.completado;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: isDone ? 0 : 2, 
      color: isDone ? Colors.green[50] : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        // Al tocar la tarjeta entera, marcamos como hecho
        onTap: () {
          ref.read(routinesProvider.notifier).toggleExercise(rutina.id, isDone);
        },
        leading: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDone ? Colors.green[100] : Colors.blue[50], 
            borderRadius: BorderRadius.circular(16)
          ),
          child: Icon(Icons.fitness_center, color: isDone ? Colors.green : Colors.blueAccent),
        ),
        title: Text(
          rutina.nombreEjercicio, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 16, 
            color: isDone ? Colors.grey[400] : Colors.black87,
            decoration: isDone ? TextDecoration.lineThrough : null, 
          )
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            '${rutina.series} series x ${rutina.repeticiones} reps', 
            style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500)
          ),
        ),
        // Botón check interactivo
        trailing: InkWell(
          onTap: () {
            ref.read(routinesProvider.notifier).toggleExercise(rutina.id, isDone);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDone ? Colors.green : Colors.transparent,
              border: Border.all(color: isDone ? Colors.green : Colors.grey[300]!),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: isDone ? Colors.white : Colors.grey[300], size: 20),
          ),
        ),
      ),
    );
  }
}