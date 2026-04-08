import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart'; 
import 'package:gymflow_app/src/providers/auth_provider.dart';
import 'package:gymflow_app/src/providers/subscription_provider.dart';
// 1. IMPORTANTE: Importamos la nueva pantalla de evolución
import 'package:gymflow_app/src/ui/screens/evolution_screen.dart'; 

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final subAsync = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.of(context).pushReplacementNamed('/'); 
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- CARNET VIRTUAL INTELIGENTE ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
              ),
              child: subAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => const Text('Error al cargar datos'),
                data: (subscription) {
                  final hasAccess = subscription?.isActive ?? false;
                  
                  final statusColor = hasAccess ? Colors.green : Colors.redAccent;
                  final statusText = hasAccess ? 'ACCESO PERMITIDO' : 'ACCESO DENEGADO';

                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blue[50],
                        child: Text(
                          user?.nombre.substring(0, 1).toUpperCase() ?? 'S',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(user?.nombre ?? 'Socio', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(user?.email ?? '', style: const TextStyle(color: Colors.grey)),
                      
                      const SizedBox(height: 24),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Plan ${subscription?.plan?.toUpperCase() ?? 'INACTIVO'}',
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: hasAccess ? Colors.white : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: statusColor, width: 3),
                        ),
                        child: QrImageView(
                          data: user?.id ?? 'invitado', 
                          version: QrVersions.auto,
                          size: 150.0,
                          foregroundColor: hasAccess ? Colors.black87 : Colors.black26, 
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Text(statusText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: statusColor, letterSpacing: 2)),
                    ],
                  );
                },
              ),
            ),
            
            const SizedBox(height: 30),
            
            // --- OPCIONES INFERIORES CON NAVEGACIÓN ---
            
            _buildSettingsTile(
              icon: Icons.history, 
              title: 'Historial de pagos',
              onTap: () {
                // Futura pantalla de pagos
              }
            ),
            
            // 2. AQUÍ CONECTAMOS EL BOTÓN CON LA GRÁFICA
            _buildSettingsTile(
              icon: Icons.monitor_weight_outlined, 
              title: 'Mis medidas corporales',
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const EvolutionScreen())
                );
              }
            ),
            
            _buildSettingsTile(
              icon: Icons.settings_outlined, 
              title: 'Ajustes de la cuenta',
              onTap: () {
                // Futura pantalla de ajustes
              }
            ),
          ],
        ),
      ),
    );
  }

  // 3. ACTUALIZAMOS LA FUNCIÓN PARA QUE ACEPTE EL ONTAP
  Widget _buildSettingsTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap, // Le pasamos la acción aquí
      ),
    );
  }
}