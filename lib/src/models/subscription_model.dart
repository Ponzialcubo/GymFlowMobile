class UserSubscription {
  final String plan;      // De 'tipo_plan'
  final bool isActive;    // Basado en 'estado' == 'activo' y 'fecha_fin'
  final DateTime? endDate; // De 'fecha_fin'

  UserSubscription({required this.plan, required this.isActive, this.endDate});

  factory UserSubscription.fromSupabase(Map<String, dynamic> json) {
    final estado = json['estado'] as String;
    final fechaFinStr = json['fecha_fin'] as String?;
    
    DateTime? endDate;
    bool activeByDate = false;

    if (fechaFinStr != null) {
      endDate = DateTime.parse(fechaFinStr);
      activeByDate = endDate.isAfter(DateTime.now());
    }

    return UserSubscription(
      plan: json['tipo_plan'] ?? 'Sin Plan',
      // Es activo si el estado es 'activo' Y la fecha no ha caducado
      isActive: estado == 'activo' && activeByDate,
      endDate: endDate,
    );
  }
}