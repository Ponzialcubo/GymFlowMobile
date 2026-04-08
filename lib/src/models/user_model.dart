class UserModel {
  final String id;
  final String email;
  final String nombre;
  final String rol;
  final bool activo; // <-- ESTO DEBE EXISTIR

  UserModel({
    required this.id,
    required this.email,
    required this.nombre,
    required this.rol,
    required this.activo,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      nombre: map['nombre'] ?? '',
      rol: map['rol'] ?? 'socio',
      activo: map['activo'] ?? true, // <-- Y MAPEARSE AQUÍ
    );
  }
}