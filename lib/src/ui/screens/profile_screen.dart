import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart'; 
import 'package:gymflow_app/src/providers/auth_provider.dart';
import 'package:gymflow_app/src/providers/subscription_provider.dart';
import 'package:gymflow_app/src/ui/screens/evolution_screen.dart'; 
import 'package:gymflow_app/src/ui/screens/payments_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final subAsync = ref.watch(subscriptionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background, // Slate 900 base
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFE11D48)), // Rose 600
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.of(context).pushReplacementNamed('/'); 
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- CARNET VIRTUAL INTELIGENTE (VIP Pass) ---
            subAsync.when(
              loading: () => const SizedBox(height: 300, child: Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))),
              error: (err, stack) => const Text('Error al cargar datos', style: TextStyle(color: Colors.redAccent)),
              data: (subscription) {
                final hasAccess = subscription?.isActive ?? false;
                
                // Colores Premium
                final Color accentColor = hasAccess ? const Color(0xFF10B981) : const Color(0xFFE11D48); // Emerald vs Rose
                final String statusText = hasAccess ? 'ACCESO PERMITIDO' : 'ACCESO DENEGADO';
                final String planText = subscription?.plan?.toUpperCase() ?? 'INACTIVO';

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
                    border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
                    // ✨ Efecto GLOW dependiendo del estado
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(hasAccess ? 0.15 : 0.05), 
                        blurRadius: 40, 
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: accentColor.withOpacity(0.5), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: accentColor.withOpacity(0.1),
                          child: Text(
                            user?.nombre?.substring(0, 1).toUpperCase() ?? 'S',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: accentColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Info Usuario
                      Text(user?.nombre ?? 'Socio', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                      const SizedBox(height: 4),
                      Text(user?.email ?? '', style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                      
                      const SizedBox(height: 24),
                      
                      // Badge del Plan
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: accentColor.withOpacity(0.2)),
                        ),
                        child: Text(
                          'PLAN $planText',
                          style: TextStyle(color: accentColor, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // CÓDIGO QR (Fondo blanco asegurado para escáneres)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: hasAccess ? Colors.white : Colors.white.withOpacity(0.2), // Si no tiene acceso se atenúa
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: hasAccess ? [
                            BoxShadow(color: accentColor.withOpacity(0.2), blurRadius: 20)
                          ] : [],
                        ),
                        child: QrImageView(
                          data: user?.id ?? 'invitado', 
                          version: QrVersions.auto,
                          size: 160.0,
                          // QR negro puro si hay acceso, gris oscuro si está inactivo
                          foregroundColor: hasAccess ? Colors.black : Colors.black54, 
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Texto de Estado
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(hasAccess ? Icons.check_circle_rounded : Icons.cancel_rounded, color: accentColor, size: 16),
                          const SizedBox(width: 8),
                          Text(statusText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: accentColor, letterSpacing: 2)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 40),
            
            // --- OPCIONES INFERIORES CON NAVEGACIÓN ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'GESTIÓN DE CUENTA',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 2),
              ),
            ),
            const SizedBox(height: 16),

            _buildSettingsTile(
              icon: Icons.history_rounded, 
              title: 'Historial de pagos',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentsScreen()));
              }
            ),
            
            _buildSettingsTile(
              icon: Icons.monitor_weight_rounded, 
              title: 'Mis medidas corporales',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EvolutionScreen()));
              }
            ),
            
            _buildSettingsTile(
              icon: Icons.settings_rounded, 
              title: 'Ajustes de la aplicación',
              onTap: () {} // Futura pantalla
            ),

            const SizedBox(height: 100), // Espacio para el BottomNav transparente
          ],
        ),
      ),
    );
  }

  // WIDGET AUXILIAR: Botones de menú estilo Glassmorphism
  Widget _buildSettingsTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5), // Slate 800 translúcido
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity(0.1), // Fondo sutil azul para el icono
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF3B82F6), size: 24), // Blue 500
        ),
        title: Text(
          title, 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white24),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}