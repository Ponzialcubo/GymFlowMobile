class UserSubscription {
  final String plan;      // De 'tipo_plan'
  final bool isActive;    // Lógica calculada
  final DateTime? endDate; // De 'fecha_fin'

  UserSubscription({required this.plan, required this.isActive, this.endDate});

  factory UserSubscription.fromSupabase(Map<String, dynamic> json) {
    final estado = json['estado'] as String;
    final fechaFinStr = json['fecha_fin'] as String?;
    
    DateTime? endDate;
    bool activeByDate;

    if (fechaFinStr == null) {
      activeByDate = true; // Sin fecha límite = activo indefinido
    } else {
      endDate = DateTime.parse(fechaFinStr);
      activeByDate = endDate.isAfter(DateTime.now());
    }

    return UserSubscription(
      plan: json['tipo_plan'] ?? 'Sin Plan',
      // Es activo si el estado en la tabla es 'activo' Y la fecha no ha caducado
      isActive: estado == 'activo' && activeByDate,
      endDate: endDate,
    );
  }
}