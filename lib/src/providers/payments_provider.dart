import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gymflow_app/src/models/payment_model.dart';
import 'package:gymflow_app/src/providers/auth_provider.dart';

final paymentsProvider = FutureProvider<List<PaymentModel>>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null) return [];

  try {
    // Apuntamos a la tabla que SÍ tiene datos
    final response = await Supabase.instance.client
    .from('suscripciones')
    .select()
    .eq('id_usuario', user.id)
    .order('fecha_inicio', ascending: false);

    return response.map((json) => PaymentModel.fromSuscripcion(json)).toList();
  } catch (e) {
    print("Error cargando el historial: $e");
    return [];
  }
});