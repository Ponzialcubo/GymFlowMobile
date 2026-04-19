import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gymflow_app/src/models/diet_model.dart';
import 'package:gymflow_app/src/providers/auth_provider.dart';

final dietProvider = FutureProvider<DietModel?>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null) return null;

  try {
    // ⚠️ LA SUPER-CONSULTA: Traemos todo el árbol de relaciones de golpe
    final response = await Supabase.instance.client
        .from('dietas')
        .select('''
          *,
          comidas_dieta (
            *,
            comida_alimentos (
              cantidad_g,
              alimentos_catalogo (
                nombre 
              )
            )
          )
        ''')
        .eq('id_usuario', user.id)
        .eq('activa', true)
        .order('fecha_creacion', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;

    return DietModel.fromMap(response);
  } catch (e) {
    print("Error cargando dieta completa: $e");
    return null;
  }
});