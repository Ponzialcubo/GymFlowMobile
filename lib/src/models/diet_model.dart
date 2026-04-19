class MealModel {
  final String title;
  final String foodDetails;

  MealModel({required this.title, required this.foodDetails});

  factory MealModel.fromMap(Map<String, dynamic> map) {
    final title = map['momento_dia'] ?? 'Comida';
    String details = 'Sin alimentos registrados.';

    // Extraemos los alimentos anidados de la super-consulta
    if (map['comida_alimentos'] != null) {
      final alimentosList = map['comida_alimentos'] as List;
      
      if (alimentosList.isNotEmpty) {
        final items = alimentosList.map((item) {
          // Navegamos hasta el nombre del catálogo
          final nombre = item['alimentos_catalogo']?['nombre'] ?? 'Alimento';
          final cantidad = item['cantidad_g'] ?? 0;
          return '$nombre (${cantidad}g)';
        }).toList();
        
        details = items.join(', ') + '.';
      }
    }

    return MealModel(title: title, foodDetails: details);
  }
}

class DietModel {
  final String objetivo;
  final int calorias;
  final int proteinas;
  final int carbos;
  final int grasas;
  final List<MealModel> comidas; // 👈 Aquí guardamos todas las comidas reales

  DietModel({
    required this.objetivo,
    required this.calorias,
    required this.proteinas,
    required this.carbos,
    required this.grasas,
    required this.comidas,
  });

  factory DietModel.fromMap(Map<String, dynamic> map) {
    final listadoComidas = map['comidas_dieta'] as List? ?? [];

    return DietModel(
      objetivo: map['nombre_dieta'] ?? 'Plan Nutricional',
      calorias: map['calorias_objetivo'] ?? 0,
      proteinas: map['proteinas'] ?? 0,
      carbos: map['carbohidratos'] ?? 0,
      grasas: map['grasas'] ?? 0,
      // Mapeamos cada comida al sub-modelo
      comidas: listadoComidas.map((c) => MealModel.fromMap(c)).toList(),
    );
  }
}