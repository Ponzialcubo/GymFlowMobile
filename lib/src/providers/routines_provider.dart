import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gymflow_app/src/models/routine_model.dart';
import 'package:gymflow_app/src/providers/auth_provider.dart';

// 1. Convertido a AsyncNotifierProvider para poder usar el .notifier
final routinesProvider = AsyncNotifierProvider<RoutinesNotifier, List<RoutineModel>>(() {
  return RoutinesNotifier();
});

class RoutinesNotifier extends AsyncNotifier<List<RoutineModel>> {
  @override
  Future<List<RoutineModel>> build() async {
    final user = ref.watch(authProvider);
    if (user == null) return [];

    try {
      final response = await Supabase.instance.client
          .from('rutinas')
          .select('*, ejercicios(*)')
          .eq('id_usuario', user.id);

      print('RUTINAS OBTENIDAS: ${(response as List).length}');
      for (var r in response as List) {
        print('DIA: ${r['dia_semana']} | EJERCICIO: ${r['ejercicios']}');
      }
      return (response as List).map((r) => RoutineModel.fromMap(r)).toList();
    } catch (e) {
      print("Error cargando rutinas: $e");
      return [];
    }
  }

  // 3. Función para marcar como completado
  Future<void> toggleExercise(int id, bool currentStatus) async {
    try {
      await Supabase.instance.client
          .from('rutinas')
          .update({'completado': !currentStatus})
          .eq('id', id);

      // Refrescamos la pantalla para que la barra de progreso se mueva
      ref.invalidateSelf();
    } catch (e) {
      print("Error al actualizar ejercicio: $e");
      rethrow;
    }
  }
}