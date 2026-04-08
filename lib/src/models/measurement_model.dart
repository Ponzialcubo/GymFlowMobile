class MeasurementModel {
  final DateTime fecha;
  final double peso;
  final double grasa;

  MeasurementModel({
    required this.fecha,
    required this.peso,
    required this.grasa,
  });

  factory MeasurementModel.fromMap(Map<String, dynamic> map) {
    return MeasurementModel(
      fecha: map['fecha_medicion'] != null ? DateTime.parse(map['fecha_medicion']) : DateTime.now(),
      peso: (map['peso_kg'] ?? 0).toDouble(),
      grasa: (map['grasa_porcentaje'] ?? 0).toDouble(),
    );
  }
}