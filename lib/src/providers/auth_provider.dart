import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymflow_app/src/models/user_model.dart';
import 'package:gymflow_app/src/repositories/auth_repository.dart';

// El nuevo "NotifierProvider" (estilo Riverpod 3.0)
final authProvider = NotifierProvider<AuthNotifier, UserModel?>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<UserModel?> {
  // En lugar de un constructor, usamos el método build para el estado inicial
  @override
  UserModel? build() {
    return null; // Estado inicial: nadie logueado
  }

  final AuthRepository _repository = AuthRepository();

  Future<void> login(String email, String password) async {
    try {
      final user = await _repository.signIn(email, password);
      state = user; // Actualizamos el estado
    } catch (e) {
      state = null;
      rethrow;
    }
  }

  void logout() {
    state = null;
  }
}