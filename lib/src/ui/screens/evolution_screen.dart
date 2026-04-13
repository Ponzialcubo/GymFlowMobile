import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart'; 
import 'package:gymflow_app/src/providers/measurements_provider.dart';

class EvolutionScreen extends ConsumerWidget {
  const EvolutionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurementsAsync = ref.watch(measurementsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background, // Slate 900
      appBar: AppBar(
        title: const Text('Mi Evolución', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), // Flecha de volver en blanco
      ),
      body: measurementsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
        data: (mediciones) {
          
          // --- ESTADO VACÍO (Menos de 2 mediciones) ---
          if (mediciones.length < 2) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.monitor_weight_outlined, size: 60, color: Colors.white24),
                  ),
                  const SizedBox(height: 24),
                  const Text('Faltan datos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
                  const SizedBox(height: 8),
                  const Text(
                    'Tu entrenador necesita registrar al menos\n2 pesajes para generar tu gráfica.', 
                    textAlign: TextAlign.center, 
                    style: TextStyle(color: Colors.white54, height: 1.5)
                  ),
                ],
              ),
            );
          }

          // --- CÁLCULOS LÓGICOS ---
          final pesoActual = mediciones.last.peso;
          final pesoInicial = mediciones.first.peso;
          final diferencia = pesoActual - pesoInicial;
          final subiendo = diferencia > 0;
          
          // Colores dinámicos para el badge (Si sube: Naranja. Si baja: Esmeralda)
          final Color badgeColor = subiendo ? const Color(0xFFF59E0B) : const Color(0xFF10B981);
          final Color badgeBg = subiendo ? const Color(0xFFF59E0B).withOpacity(0.1) : const Color(0xFF10B981).withOpacity(0.1);

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              // --- TARJETA DE RESUMEN PREMIUM ---
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)], // Slate 800 -> 900
                  ),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 15))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PESO ACTUAL', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 10)),
                        const SizedBox(height: 8),
                        Text('$pesoActual kg', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: badgeColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(subiendo ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: badgeColor, size: 18),
                          const SizedBox(width: 6),
                          Text('${diferencia.abs().toStringAsFixed(1)} kg', style: TextStyle(color: badgeColor, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 40),
              
              const Text('HISTORIAL DE PESO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 2)),
              
              const SizedBox(height: 20),

              // --- EL GRÁFICO (Dark Mode & Neón) ---
              Container(
                height: 350, // Un poco más de altura para que respire
                width: double.infinity, 
                padding: const EdgeInsets.only(right: 24, left: 10, top: 40, bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.5), // Slate 800 translúcido
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 5, 
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.white.withOpacity(0.05), // Líneas sutiles oscuras
                        strokeWidth: 1,
                        dashArray: [5, 5], // Línea punteada premium
                      ),
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
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text('${fecha.day}/${fecha.month}', style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
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
                          reservedSize: 45,
                          getTitlesWidget: (value, meta) => Text('${value.toInt()}kg', style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minY: (mediciones.map((m) => m.peso).reduce((a, b) => a < b ? a : b)) - 5,
                    maxY: (mediciones.map((m) => m.peso).reduce((a, b) => a > b ? a : b)) + 5,
                    
                    lineBarsData: [
                      LineChartBarData(
                        spots: mediciones.asMap().entries.map((entry) {
                          return FlSpot(entry.key.toDouble(), entry.value.peso);
                        }).toList(),
                        isCurved: true, 
                        color: const Color(0xFF3B82F6), // Blue 500 (Vibrante)
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: const Color(0xFF3B82F6),
                              strokeWidth: 2,
                              strokeColor: Colors.white, // Borde blanco en los puntos
                            );
                          }
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          // Degradado que se desvanece hacia abajo
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF3B82F6).withOpacity(0.3),
                              const Color(0xFF3B82F6).withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                    // Tooltip al hacer tap en la gráfica
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        // ✅ Cambiamos tooltipBgColor por getTooltipColor (Nueva versión de fl_chart)
                        // ✅ Quitamos el "const" problemático
                        getTooltipColor: (LineBarSpot touchedSpot) => const Color(0xFF0F172A).withOpacity(0.8),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((LineBarSpot touchedSpot) {
                            return LineTooltipItem(
                              '${touchedSpot.y} kg',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40), // Espacio al final
            ],
          );
        },
      ),
    );
  }
}