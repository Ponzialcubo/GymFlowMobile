import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymflow_app/src/providers/payments_provider.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background, // Slate 900
      appBar: AppBar(
        title: const Text('Mi Contabilidad', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: paymentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
        data: (pagos) {
          
          final totalInvertido = pagos
              .where((p) => p.estado.contains('recibo'))
              .fold(0.0, (sum, item) => sum + item.monto);

          return Column(
            children: [
              // --- TARJETA DE RESUMEN (Estilo Tarjeta de Crédito Premium) ---
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)], // Slate 800 -> Slate 900
                    ),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 15))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL INVERTIDO', 
                        style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2)
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${totalInvertido.toStringAsFixed(2)} €', 
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)
                      ),
                    ],
                  ),
                ),
              ),
              
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text('MOVIMIENTOS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 2)),
                ),
              ),
              const SizedBox(height: 16),

              // --- LISTA DE MOVIMIENTOS ---
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: pagos.length,
                  itemBuilder: (context, index) {
                    final pago = pagos[index];
                    final isRecibo = pago.estado.contains('recibo');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withOpacity(0.5), // Slate 800 translúcido
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isRecibo ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFF3B82F6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              isRecibo ? Icons.account_balance_wallet_rounded : Icons.description_rounded,
                              color: isRecibo ? const Color(0xFF34D399) : const Color(0xFF60A5FA), // Emerald vs Blue
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pago.concepto, 
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white)
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${pago.fechaPago.day.toString().padLeft(2, '0')}/${pago.fechaPago.month.toString().padLeft(2, '0')}/${pago.fechaPago.year}',
                                  style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                isRecibo ? '-${pago.monto.toStringAsFixed(2)} €' : 'Contrato',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900, 
                                  fontSize: 16, 
                                  color: isRecibo ? Colors.white : Colors.white38
                                ),
                              ),
                              if (isRecibo) ...[
                                const SizedBox(height: 4),
                                const Text('PAGADO', style: TextStyle(color: Color(0xFF10B981), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                              ]
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}