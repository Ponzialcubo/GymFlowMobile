import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymflow_app/src/providers/auth_provider.dart';
import 'package:gymflow_app/src/ui/screens/login_screen.dart';
import 'package:gymflow_app/src/providers/subscription_provider.dart';
import 'package:gymflow_app/src/providers/diet_provider.dart';
import 'package:gymflow_app/src/providers/routines_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final theme = Theme.of(context);

    final String firstName = user != null
      ? user.nombre.split(' ')[0]
      : "Socio";

    final subscriptionAsync = ref.watch(subscriptionProvider);
    final subscription = subscriptionAsync.asData?.value;
    final bool hasActivePlan = subscription?.isActive ?? false;
    final String planNombre = subscription?.plan ?? 'Sin plan';
    final String proximoCobro = subscription?.endDate != null
      ? '${subscription!.endDate!.day.toString().padLeft(2, '0')} '
        '${_mesCorto(subscription.endDate!.month)}'
      : 'Sin fecha';

    final dietAsync = ref.watch(dietProvider);
    final diet = dietAsync.asData?.value;
    final String kcalHoy = diet != null
      ? diet.calorias.toString()
      : '--';

    final routinesAsync = ref.watch(routinesProvider);
    final routines = routinesAsync.asData?.value ?? [];
    final hoy = _diaSemanaHoy();
    final rutinasHoy = routines
      .where((r) => r.diaSemana.toLowerCase() == hoy)
      .toList();
    final String entrenoHoy = rutinasHoy.isNotEmpty
      ? rutinasHoy.map((r) => r.grupoMuscular).toSet().join('/')
      : 'Descanso';

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('GymFlow', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5, color: Colors.white)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white54),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER PREMIUM
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola, $firstName 👋',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tu progreso de hoy'.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B82F6),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF60A5FA)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
                      ],
                    ),
                    child: const Center(child: Text('🔥', style: TextStyle(fontSize: 24))),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // TARJETA DE MEMBRESÍA (HERO CARD)
              _buildHeroCard(context, hasActivePlan, planNombre, proximoCobro),

              const SizedBox(height: 32),

              // RESUMEN DE MACROS
              Row(
                children: [
                  Expanded(
                    child: _buildMacroCard(
                      title: 'KCAL HOY',
                      value: kcalHoy,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMacroCard(
                      title: 'ENTRENO',
                      value: entrenoHoy,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ACCESOS RÁPIDOS
              const Text(
                'ACCESOS RÁPIDOS',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 2),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickAction(Icons.calendar_month_rounded, 'Horarios'),
                  _buildQuickAction(Icons.emoji_events_rounded, 'Logros'),
                  _buildQuickAction(Icons.notifications_rounded, 'Avisos'),
                  _buildQuickAction(Icons.settings_rounded, 'Ajustes'),
                ],
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildHeroCard(BuildContext context, bool isActive,
                        String planNombre, String proximoCobro) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
        ),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 15))
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -60,
            bottom: -60,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3B82F6).withOpacity(0.15),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isActive ? 'MEMBRESÍA ACTIVA' : 'SIN MEMBRESÍA',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white54, letterSpacing: 2),
              ),
              const SizedBox(height: 8),
              Text(
                planNombre,
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -2),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
                ),
                child: Text(
                  'SIGUIENTE COBRO: $proximoCobro',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF60A5FA), letterSpacing: 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard({required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color, letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70, letterSpacing: 0.5),
        ),
      ],
    );
  }

  static String _diaSemanaHoy() {
    const dias = ['lunes', 'martes', 'miércoles',
                  'jueves', 'viernes', 'sábado', 'domingo'];
    return dias[DateTime.now().weekday - 1];
  }

  static String _mesCorto(int mes) {
    const meses = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
                   'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];
    return meses[mes - 1];
  }
}
