import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gymflow_app/src/models/measurement_model.dart';
import 'package:gymflow_app/src/providers/auth_provider.dart';

final measurementsProvider = FutureProvider<List<MeasurementModel>>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null) return [];

  try {
    final response = await Supabase.instance.client
        .from('mediciones') // Verifica que tu tabla se llame así
        .select()
        .eq('id_usuario', user.id)
        .order('fecha_medicion', ascending: true); // Ordenamos para que la gráfica tenga sentido

    return (response as List).map((m) => MeasurementModel.fromMap(m)).toList();
  } catch (e) {
    print("Error en measurementsProvider: $e");
    return [];
  }
});