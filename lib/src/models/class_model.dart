class ClassModel {
  final int id;
  final String nombreClase;
  final String monitorEncargado;
  final DateTime horario; // Ahora es un DateTime real
  final int capacidadMax;
  final int cuposReservados;
  final bool isReserved;

  ClassModel({
    required this.id,
    required this.nombreClase,
    required this.monitorEncargado,
    required this.horario,
    required this.capacidadMax,
    required this.cuposReservados,
    required this.isReserved,
  });

  int get cuposDisponibles => capacidadMax - cuposReservados;

  factory ClassModel.fromMap(Map<String, dynamic> map, String currentUserId) {
    // Leemos las reservas que vengan de tu tabla reservas_clases
    final listaReservas = map['reservas_clases'] as List? ?? [];
    
    return ClassModel(
      id: map['id'] ?? 0,
      nombreClase: map['nombre_clase'] ?? 'Clase sin nombre',
      monitorEncargado: map['monitor_encargado'] ?? 'Sin asignar',
      // Convertimos el timestamp de tu base de datos a un objeto DateTime de Dart
      horario: map['horario'] != null ? DateTime.parse(map['horario']) : DateTime.now(),
      capacidadMax: map['capacidad_max'] ?? 20,
      cuposReservados: listaReservas.length,
      // Comprobamos si el ID del usuario está en esta tabla
      isReserved: listaReservas.any((r) => r['id_usuario'] == currentUserId),
    );
  }
}