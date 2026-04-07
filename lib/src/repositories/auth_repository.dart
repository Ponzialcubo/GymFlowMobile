import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gymflow_app/src/models/user_model.dart';
import 'package:gymflow_app/src/services/auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final response = await _authService.signIn(email, password);
      
      if (response.user != null) {
        return UserModel(
          id: response.user!.id,
          email: response.user!.email!,
          nombre: response.user!.userMetadata?['full_name'] ?? 'Socio',
          rol: 'socio',
        );
      }
      return null;
    } catch (e) {
      rethrow; // Lanzamos el error para que el Provider lo capture
    }
  }
}