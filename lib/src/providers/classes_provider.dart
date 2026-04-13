import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gymflow_app/src/models/class_model.dart';
import 'package:gymflow_app/src/providers/auth_provider.dart';

final classesProvider = AsyncNotifierProvider<ClassesNotifier, List<ClassModel>>(() {
  return ClassesNotifier();
});

class ClassesNotifier extends AsyncNotifier<List<ClassModel>> {
  @override
  Future<List<ClassModel>> build() async {
    final user = ref.watch(authProvider);
    if (user == null) return [];

    try {
      // 1. Obtenemos el momento exacto de ahora mismo
      final ahora = DateTime.now().toIso8601String();

      // 2. Consulta con FILTRO INTELIGENTE
      final response = await Supabase.instance.client
          .from('clases_colectivas')
          .select('*, reservas_clases(id_usuario)')
          .gte('horario', ahora) // <--- EL ESCUDO: Solo trae clases de este segundo en adelante
          .order('horario', ascending: true);

      return response.map((json) => ClassModel.fromMap(json, user.id)).toList();
    } catch (e) {
      print("Error cargando clases: $e");
      return [];
    }
  }

  Future<void> toggleReserva(ClassModel clase) async {
    final user = ref.read(authProvider);
    if (user == null) return;

    try {
      if (clase.isReserved) {
        // Cancelar Reserva
        await Supabase.instance.client
            .from('reservas_clases')
            .delete()
            .eq('id_usuario', user.id)
            .eq('id_clase', clase.id); 
      } else {
        // Reservar Plaza
        if (clase.cuposDisponibles <= 0) throw Exception('Clase completa');
        
        await Supabase.instance.client
            .from('reservas_clases')
            .insert({
              'id_usuario': user.id,
              'id_clase': clase.id, 
            });
      }
      ref.invalidateSelf(); // Refrescamos la lista para actualizar la UI
    } catch (e) {
      print("Error en reserva: $e");
      rethrow;
    }
  }
}