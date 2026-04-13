import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymflow_app/src/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final theme = Theme.of(context);

    // Simulamos algunos datos para que el Dashboard brille (luego los conectarás con tus Providers)
    final String firstName = user?.nombre?.split(' ')[0] ?? "Socio";
    final bool hasActivePlan = true; // Simulación

    return Scaffold(
      backgroundColor: theme.colorScheme.background, // Slate 900
      appBar: AppBar(
        title: const Text('GymFlow', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5, color: Colors.white)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white54),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.of(context).pushReplacementNamed('/');
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
              // 🌟 HEADER PREMIUM
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
                      Text( // <-- ¡Bórrele el const a esta línea!
                    'Tu progreso de hoy'.toUpperCase(),
                    style: const TextStyle( // <-- El const se queda aquí para el estilo
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
                      gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF60A5FA)]), // Blue 600 to Blue 400
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
                      ],
                    ),
                    child: const Center(child: Text('🔥', style: TextStyle(fontSize: 24))),
                  )
                ],
              ),
              const SizedBox(height: 40),

              // 💎 TARJETA DE MEMBRESÍA (HERO CARD)
              _buildHeroCard(context, hasActivePlan),
              
              const SizedBox(height: 32),
              
              // 📊 RESUMEN DE MACROS (Mini-versión del Dashboard Web)
              Row(
                children: [
                  Expanded(
                    child: _buildMacroCard(
                      title: 'KCAL HOY',
                      value: '2.450',
                      color: const Color(0xFF10B981), // Emerald 500
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMacroCard(
                      title: 'ENTRENO',
                      value: 'Pecho/Tríceps',
                      color: const Color(0xFF3B82F6), // Blue 500
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ⚡ ACCESOS RÁPIDOS (Rediseñados)
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
              
              const SizedBox(height: 100), // Espacio extra para el BottomNav (extendBody)
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildHeroCard(BuildContext context, bool isActive) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B), // Slate 800
            Color(0xFF0F172A), // Slate 900
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
          // Efecto Glow interno
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
              const Text(
                'MEMBRESÍA ACTIVA',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white54, letterSpacing: 2),
              ),
              const SizedBox(height: 8),
              const Text(
                'Plan Pro',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -2),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
                ),
                child: const Text(
                  'SIGUIENTE COBRO: 01 MAY',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF60A5FA), letterSpacing: 1),
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
        color: const Color(0xFF1E293B).withOpacity(0.5), // Slate 800 translúcido
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
}