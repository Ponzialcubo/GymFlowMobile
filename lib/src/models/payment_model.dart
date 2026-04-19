class PaymentModel {
  final String id;
  final double monto;
  final DateTime fechaPago;
  final String concepto;
  final String estado;

  PaymentModel({
    required this.id,
    required this.monto,
    required this.fechaPago,
    required this.concepto,
    required this.estado,
  });

  factory PaymentModel.fromSuscripcion(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      // Mapeamos 'precio' de la tabla al 'monto' del modelo
      monto: (json['precio'] as num?)?.toDouble() ?? 0.0, 
      // Mapeamos 'fecha_inicio' como la fecha del recibo
      fechaPago: DateTime.parse(json['fecha_inicio']),
      // Creamos el concepto dinámico para la UI
      concepto: 'Membresía ${json['tipo_plan'] ?? 'GymFlow'}',
      estado: json['estado'] ?? 'desconocido',
    );
  }
}