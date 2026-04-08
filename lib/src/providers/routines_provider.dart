import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gymflow_app/src/models/routine_model.dart';
import 'package:gymflow_app/src/providers/auth_provider.dart';

// Cambiamos a AsyncNotifierProvider para tener funciones de escritura
final routinesProvider = AsyncNotifierProvider<RoutinesNotifier, List<RoutineModel>>(() {
  return RoutinesNotifier();
});

class RoutinesNotifier extends AsyncNotifier<List<RoutineModel>> {
  @override
  Future<List<RoutineModel>> build() async {
    final user = ref.watch(authProvider);
    if (user == null) return [];

    final response = await Supabase.instance.client
        .from('rutinas')
        .select('*, ejercicios(*)')
        .eq('id_usuario', user.id);

    return response.map((json) => RoutineModel.fromMap(json)).toList();
  }

  // ¡NUEVA FUNCIÓN! El gatillo que dispara la actualización a Supabase
  Future<void> toggleExercise(int idRutina, bool estadoActual) async {
    try {
      // 1. Mandamos el cambio a la base de datos (invertimos el estado)
      await Supabase.instance.client
          .from('rutinas')
          .update({'completado': !estadoActual})
          .eq('id', idRutina);

      // 2. Refrescamos la lista automáticamente para que la UI reaccione
      ref.invalidateSelf();
    } catch (e) {
      print("Error al actualizar ejercicio: $e");
    }
  }
}