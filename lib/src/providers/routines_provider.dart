import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gymflow_app/src/models/routine_model.dart';
import 'package:gymflow_app/src/providers/auth_provider.dart';

// Cambiamos a AsyncNotifierProvider para tener funciones de escritura
final routinesProvider = FutureProvider<List<RoutineModel>>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null) return [];

  try {
    // Aquí hacemos el JOIN con la tabla ejercicios para traer el nombre e imagen
    final response = await Supabase.instance.client
        .from('rutinas_ejercicios') // Tu tabla de unión
        .select('*, ejercicios(*)') 
        .eq('id_usuario', user.id);

    return (response as List).map((r) => RoutineModel.fromMap(r)).toList();
  } catch (e) {
    print("Error en routinesProvider: $e");
    return [];
  }
});