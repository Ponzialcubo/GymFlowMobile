import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart'; // La súper librería de gráficos
import 'package:gymflow_app/src/providers/measurements_provider.dart';
import 'package:gymflow_app/src/models/measurement_model.dart';

class EvolutionScreen extends ConsumerWidget {
  const EvolutionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurementsAsync = ref.watch(measurementsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mi Evolución', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: measurementsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (mediciones) {
          // Si hay menos de 2 mediciones, no podemos trazar una línea
          if (mediciones.length < 2) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.monitor_weight_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Faltan datos', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                  const SizedBox(height: 8),
                  Text('Tu entrenador necesita registrar al menos\n2 pesajes para generar tu gráfica.', 
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }

          // Extraemos el último peso y el primero para calcular la diferencia
          final pesoActual = mediciones.last.peso;
          final pesoInicial = mediciones.first.peso;
          final diferencia = pesoActual - pesoInicial;
          final subiendo = diferencia > 0;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // --- TARJETA DE RESUMEN ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Peso Actual', style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('$pesoActual kg', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: subiendo ? Colors.orange[50] : Colors.green[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(subiendo ? Icons.arrow_upward : Icons.arrow_downward, 
                               color: subiendo ? Colors.orange : Colors.green, size: 16),
                          const SizedBox(width: 4),
                          Text('${diferencia.abs().toStringAsFixed(1)} kg', 
                               style: TextStyle(color: subiendo ? Colors.orange : Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 30),
              Text('Historial de Peso', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.grey[800])),
              const SizedBox(height: 20),

              // --- EL GRÁFICO ---
              Container(
                height: 300,
                padding: const EdgeInsets.only(right: 20, left: 10, top: 24, bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                ),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 5, // Líneas horizontales cada 5kg
                      getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[200], strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      // Fechas abajo
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && value.toInt() < mediciones.length) {
                              final fecha = mediciones[value.toInt()].fecha;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text('${fecha.day}/${fecha.month}', style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      // Pesos a la izquierda
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) => Text('${value.toInt()}kg', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    // Límites del gráfico (Dejamos margen arriba y abajo)
                    minY: (mediciones.map((m) => m.peso).reduce((a, b) => a < b ? a : b)) - 5,
                    maxY: (mediciones.map((m) => m.peso).reduce((a, b) => a > b ? a : b)) + 5,
                    
                    lineBarsData: [
                      LineChartBarData(
                        spots: mediciones.asMap().entries.map((entry) {
                          return FlSpot(entry.key.toDouble(), entry.value.peso);
                        }).toList(),
                        isCurved: true, // Curvas suaves
                        color: Colors.blueAccent,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true), // Puntos en cada pesaje
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blueAccent.withOpacity(0.15), // Sombreado bajo la curva
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}