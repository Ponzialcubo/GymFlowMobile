class PaymentModel {
  final String id; // Ahora es un UUID (String)
  final double monto;
  final DateTime fechaPago;
  final String concepto;
  final String metodoPago;
  final String estado;

  PaymentModel({
    required this.id,
    required this.monto,
    required this.fechaPago,
    required this.concepto,
    required this.metodoPago,
    required this.estado,
  });

  factory PaymentModel.fromSuscripcion(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'], // Leemos el UUID
      monto: (map['precio'] ?? 0).toDouble(),
      fechaPago: DateTime.parse(map['fecha_inicio']),
      concepto: 'Membresía ${map['tipo_plan']}',
      metodoPago: 'Domiciliación',
      estado: map['estado'] ?? 'activo',
    );
  }
}