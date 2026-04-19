import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymflow_app/src/providers/classes_provider.dart';
import 'package:gymflow_app/src/models/class_model.dart';
import 'dart:ui'; 

class ClassesScreen extends ConsumerWidget {
  const ClassesScreen({super.key});

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background, // Slate 900
      appBar: AppBar(
        title: const Text(
          'Clases Colectivas', 
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: classesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.white24),
              const SizedBox(height: 16),
              Text('Error de conexión: $err', style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
              TextButton(
                onPressed: () => ref.invalidate(classesProvider), 
                child: const Text('REINTENTAR', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold))
              )
            ],
          ),
        ),
        data: (clases) {
          if (clases.isEmpty) {
            return const Center(
              child: Text('No hay clases programadas hoy.', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w600))
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            itemCount: clases.length,
            itemBuilder: (context, index) => _buildClassCard(context, ref, clases[index]),
          );
        },
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, WidgetRef ref, ClassModel clase) {
    final bool isFull = clase.cuposDisponibles <= 0;
    final bool isReserved = clase.isReserved;
    
    // Colores reactivos al estado real
    final accentColor = isReserved ? const Color(0xFF10B981) : (isFull ? Colors.white24 : const Color(0xFF3B82F6));

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isReserved 
            ? const Color(0xFF10B981).withOpacity(0.05) 
            : const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isReserved ? const Color(0xFF10B981).withOpacity(0.3) : Colors.white.withOpacity(0.05),
          width: 1.5
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Column(
          children: [
            // Indicador visual de estado superior
            Container(height: 4, color: accentColor.withOpacity(0.5)),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          clase.nombreClase.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                        ),
                      ),
                      if (isReserved)
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 24),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Información de Monitor y Hora
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildBadge(Icons.person_rounded, clase.monitorEncargado, Colors.white54),
                      _buildBadge(Icons.schedule_rounded, '${clase.horario.hour}:${clase.horario.minute.toString().padLeft(2, '0')}', const Color(0xFF3B82F6)),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Fecha formateada
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, size: 14, color: Colors.white38),
                      const SizedBox(width: 8),
                      Text(_formatFecha(clase.horario), style: const TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: Colors.white10, height: 1),
                  ),
                  
                  // Fila inferior de Cupos y Botón
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isReserved ? 'TIENES PLAZA' : (isFull ? 'COMPLETO' : '${clase.cuposDisponibles} LIBRES'),
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 0.5
                            ),
                          ),
                          Text('De ${clase.capacidadMax} totales', style: const TextStyle(fontSize: 11, color: Colors.white24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isReserved ? const Color(0xFFE11D48).withOpacity(0.1) : accentColor,
                          foregroundColor: isReserved ? const Color(0xFFFB7185) : Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: isReserved ? const BorderSide(color: Color(0xFFE11D48), width: 1) : null,
                        ),
                        onPressed: isFull && !isReserved ? null : () => _confirmarReserva(context, ref, clase),
                        child: Text(
                          isReserved ? 'CANCELAR' : 'RESERVAR',
                          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12),
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

  Widget _buildBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _confirmarReserva(BuildContext parentContext, WidgetRef ref, ClassModel clase) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Efecto de desenfoque tras el diálogo
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: const BorderSide(color: Colors.white10)),
          title: Text(
            clase.isReserved ? '¿Cancelar Reserva?' : '¿Confirmar Reserva?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          content: Text(
            clase.isReserved 
              ? '¿Seguro que quieres liberar tu plaza en ${clase.nombreClase}?' 
              : 'Vas a reservar plaza para ${clase.nombreClase} con ${clase.monitorEncargado}.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), 
              child: const Text('VOLVER', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: clase.isReserved ? const Color(0xFFE11D48) : const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext); 
                try {
                  await ref.read(classesProvider.notifier).toggleReserva(clase);
                  if (!parentContext.mounted) return; 
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text(clase.isReserved ? 'Reserva cancelada' : '¡Plaza confirmada!'),
                      backgroundColor: clase.isReserved ? Colors.orange : const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    )
                  );
                } catch (e) {
                  if (!parentContext.mounted) return;
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text('Error al procesar la solicitud.'))
                  );
                }
              },
              child: Text(clase.isReserved ? 'SÍ, CANCELAR' : 'SÍ, RESERVAR'),
            ),
          ],
        ),
      ),
    );
  }
}