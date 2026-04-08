import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymflow_app/src/providers/classes_provider.dart';
import 'package:gymflow_app/src/models/class_model.dart';

class ClassesScreen extends ConsumerWidget {
  const ClassesScreen({super.key});

  // Función auxiliar para formatear la fecha de forma manual y elegante
  String _formatFecha(DateTime fecha) {
    final dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    
    final diaSemana = dias[fecha.weekday - 1];
    final diaMes = fecha.day;
    final mes = meses[fecha.month - 1];
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');

    return '$diaSemana, $diaMes $mes - $hora:$minuto h';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(classesProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Clases Colectivas', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: classesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text('Error al conectar: $err', textAlign: TextAlign.center),
              TextButton(onPressed: () => ref.invalidate(classesProvider), child: const Text('Reintentar'))
            ],
          ),
        ),
        data: (clases) {
          if (clases.isEmpty) {
            return const Center(child: Text('No hay clases programadas hoy.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: clases.length,
            itemBuilder: (context, index) {
              final clase = clases[index];
              return _buildClassCard(context, ref, clase);
            },
          );
        },
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, WidgetRef ref, ClassModel clase) {
    final bool isFull = clase.cuposDisponibles <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            // Franja superior de estado
            Container(
              height: 6,
              width: double.infinity,
              color: clase.isReserved ? Colors.green : (isFull ? Colors.grey : Colors.blueAccent),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clase.nombreClase, 
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.person, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(clase.monitorEncargado, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${clase.horario.hour}:${clase.horario.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.blueAccent),
                      const SizedBox(width: 8),
                      Text(
                        _formatFecha(clase.horario),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clase.isReserved ? '¡Tienes plaza!' : '${clase.cuposDisponibles} plazas libres',
                            style: TextStyle(
                              color: clase.isReserved ? Colors.green : (isFull ? Colors.red : Colors.blueAccent),
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          Text('Cupo total: ${clase.capacidadMax}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: clase.isReserved ? Colors.redAccent.withOpacity(0.1) : Colors.blueAccent,
                          foregroundColor: clase.isReserved ? Colors.redAccent : Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: isFull && !clase.isReserved 
                          ? null 
                          : () => _confirmarReserva(context, ref, clase),
                        child: Text(
                          clase.isReserved ? 'Cancelar' : 'Reservar',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Lógica corregida para el modal de confirmación
  void _confirmarReserva(BuildContext parentContext, WidgetRef ref, ClassModel clase) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(clase.isReserved ? '¿Cancelar Reserva?' : '¿Confirmar Reserva?'),
        content: Text(clase.isReserved 
          ? '¿Seguro que quieres liberar tu plaza en ${clase.nombreClase}?' 
          : 'Vas a reservar plaza para ${clase.nombreClase} con ${clase.monitorEncargado}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), 
            child: const Text('Volver')
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: clase.isReserved ? Colors.redAccent : Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext); 
              try {
                await ref.read(classesProvider.notifier).toggleReserva(clase);
                
                if (!parentContext.mounted) return; 
                
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(
                    content: Text(clase.isReserved ? 'Reserva cancelada' : '¡Plaza confirmada!'),
                    backgroundColor: clase.isReserved ? Colors.orange : Colors.green,
                  )
                );
              } catch (e) {
                if (!parentContext.mounted) return;
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(content: Text('Error: No se pudo procesar la reserva'))
                );
              }
            },
            child: Text(clase.isReserved ? 'Sí, cancelar' : 'Sí, reservar'),
          ),
        ],
      ),
    );
  }
}