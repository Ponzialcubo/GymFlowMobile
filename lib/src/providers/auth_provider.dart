import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Añadimos esto para poder forzar el cierre
import 'package:gymflow_app/src/models/user_model.dart';
import 'package:gymflow_app/src/repositories/auth_repository.dart';

final authProvider = NotifierProvider<AuthNotifier, UserModel?>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() {
    return null; 
  }

  final AuthRepository _repository = AuthRepository();

  Future<void> login(String email, String password) async {
    try {
      // 1. Preguntamos a Supabase si el email y contraseña son correctos
      final user = await _repository.signIn(email, password);
      
      // --- ESCUDO PROTECTOR (Comprobación de Baja Lógica) ---
      // Si el login es correcto pero el usuario está dado de baja...
      if (user != null && user.activo == false) {
        
        // A. Destruimos inmediatamente el token temporal que Supabase acaba de crear
        await Supabase.instance.client.auth.signOut();
        
        // B. Lanzamos un error explícito para que la pantalla de Login lo muestre
        throw Exception('Cuenta inactiva. Por favor, contacte con recepción.');
      }

      // 2. Si pasa el filtro y está activo, le damos las llaves de la app
      state = user; 
      
    } catch (e) {
      state = null;
      rethrow;
    }
  }

  // Aprovechamos para mejorar el logout y que también borre la sesión real
  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    state = null;
  }
}