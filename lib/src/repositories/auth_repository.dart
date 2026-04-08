import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gymflow_app/src/models/user_model.dart';
import 'package:gymflow_app/src/services/auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  Future<UserModel?> signIn(String email, String password) async {
    try {
      // 1. Verificamos credenciales en Supabase Auth
      final response = await _authService.signIn(email, password);
      
      if (response.user != null) {
        
        // 2. Buscamos su ficha real en la tabla 'usuarios'
        // Esto es vital para saber si está 'activo' o dado de baja
        final userData = await Supabase.instance.client
            .from('usuarios')
            .select('nombre, rol, activo')
            .eq('id', response.user!.id)
            .single();

        // 3. Construimos el usuario mezclando la info de Auth y la info de la Base de Datos
        return UserModel(
          id: response.user!.id,
          email: response.user!.email!,
          // Priorizamos el nombre de la BD, si falla usamos los metadatos
          nombre: userData['nombre'] ?? response.user!.userMetadata?['full_name'] ?? 'Socio',
          rol: userData['rol'] ?? 'socio',
          activo: userData['activo'] ?? true, // <-- AQUÍ PASAMOS EL PARAMETRO QUE FALTABA
        );
      }
      return null;
    } catch (e) {
      rethrow; // Lanzamos el error para que el Provider lo capture
    }
  }
}