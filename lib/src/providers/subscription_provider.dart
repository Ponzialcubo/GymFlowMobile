import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gymflow_app/src/providers/auth_provider.dart';
import 'package:gymflow_app/src/models/subscription_model.dart';

final subscriptionProvider = FutureProvider<UserSubscription?>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null) return null;

  try {
    final response = await Supabase.instance.client
        .from('suscripciones')
        .select()
        .eq('id_usuario', user.id)
        .eq('estado', 'activo')
        .maybeSingle();

    if (response == null) {
      return UserSubscription(plan: 'Sin plan', isActive: false);
    }

    return UserSubscription.fromSupabase(response);
  } catch (e) {
    print("Error en subscriptionProvider: $e");
    return UserSubscription(plan: 'Error', isActive: false);
  }
});