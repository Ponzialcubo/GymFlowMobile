import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gymflow_app/src/models/measurement_model.dart';
import 'package:gymflow_app/src/providers/auth_provider.dart';

final measurementsProvider = FutureProvider<List<MeasurementModel>>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null) return [];

  try {
    final response = await Supabase.instance.client
        .from('mediciones')
        .select('fecha_medicion, peso_kg, grasa_porcentaje')
        .eq('id_usuario', user.id)
        .order('fecha_medicion', ascending: true); // De antiguo a nuevo

    return response.map((json) => MeasurementModel.fromMap(json)).toList();
  } catch (e) {
    print("Error leyendo mediciones: $e");
    return [];
  }
});