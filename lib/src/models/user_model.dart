class UserModel {
  final String id;
  final String email;
  final String nombre;
  final String rol;

  UserModel({
    required this.id,
    required this.email,
    required this.nombre,
    required this.rol,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      nombre: map['nombre'] ?? 'Socio',
      rol: map['rol'] ?? 'socio',
    );
  }
}