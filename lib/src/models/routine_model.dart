class RoutineModel {
  final int id;
  final String diaSemana;
  final int series;
  final int repeticiones;
  final String nombreEjercicio;
  final String grupoMuscular;
  final String imagenUrl;
  final bool completado; 

  RoutineModel({
    required this.id,
    required this.diaSemana,
    required this.series,
    required this.repeticiones,
    required this.nombreEjercicio,
    required this.grupoMuscular,
    required this.imagenUrl,
    required this.completado, 
  });

  factory RoutineModel.fromMap(Map<String, dynamic> map) {
    final ejercicio = map['ejercicios'] ?? {}; 
    return RoutineModel(
      id: map['id'] ?? 0,
      diaSemana: map['dia_semana'] ?? '',
      series: map['series'] ?? 0,
      repeticiones: map['repeticiones'] ?? 0,
      nombreEjercicio: ejercicio['nombre'] ?? 'Ejercicio desconocido',
      grupoMuscular: ejercicio['grupo_muscular'] ?? '',
      imagenUrl: ejercicio['imagen_url'] ?? '',
      completado: map['completado'] ?? false, // <-- 3. LO LEEMOS DE SUPABASE
    );
  }
}