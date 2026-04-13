import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gymflow_app/src/providers/auth_provider.dart';
import 'package:gymflow_app/src/models/payment_model.dart';

final paymentsProvider = FutureProvider<List<PaymentModel>>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null) return [];

  try {
    // Consultamos la tabla 'suscripciones' que es la que tiene los registros
    final response = await Supabase.instance.client
        .from('suscripciones')
        .select()
        .eq('id_usuario', user.id)
        .order('fecha_inicio', ascending: false);

    final List data = response as List;
    return data.map((json) => PaymentModel.fromSuscripcion(json)).toList();
  } catch (e) {
    print("Error en paymentsProvider: $e");
    return [];
  }
});