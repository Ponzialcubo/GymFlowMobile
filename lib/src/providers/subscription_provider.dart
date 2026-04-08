import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gymflow_app/src/providers/auth_provider.dart';

// Un pequeño modelo para guardar los datos de su pago
class UserSubscription {
  final String plan;
  final bool isActive;
  final DateTime? endDate;

  UserSubscription({required this.plan, required this.isActive, this.endDate});
}

// El proveedor que consulta la base de datos
final subscriptionProvider = FutureProvider<UserSubscription?>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null) return null;

  try {
    // Buscamos si tiene una suscripción activa
    final response = await Supabase.instance.client
        .from('suscripciones')
        .select()
        .eq('id_usuario', user.id)
        .eq('estado', 'activo')
        .order('fecha_fin', ascending: false)
        .limit(1)
        .maybeSingle();

    // Si no hay respuesta, no tiene plan
    if (response == null) {
      return UserSubscription(plan: 'Sin plan', isActive: false);
    }

    // Comprobamos que la fecha actual no ha superado la fecha de fin
    final endDate = DateTime.parse(response['fecha_fin']);
    final isActive = endDate.isAfter(DateTime.now());

    return UserSubscription(
      plan: response['tipo_plan'],
      isActive: isActive,
      endDate: endDate,
    );
  } catch (e) {
    print("Error leyendo suscripción: $e");
    return UserSubscription(plan: 'Error', isActive: false);
  }
});