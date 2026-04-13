import 'dart:ui'; // <-- Necesario para el efecto Glassmorphism (ImageFilter)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymflow_app/src/providers/auth_provider.dart';
import 'package:gymflow_app/src/ui/screens/main_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        // Redirigimos sin SnackBar verde (en apps premium la transición suele ser limpia y directa)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'), 
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating, // SnackBar moderno flotante
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // 1. FONDO CON GRADIENTE OSCURO (Base del Premium Dark Mode)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A), // Slate 900
                  Color(0xFF1E293B), // Slate 800
                  Color(0xFF020617), // Slate 950
                ],
              ),
            ),
          ),
          
          // 2. CÍRCULOS DE LUZ (Para que el cristal tenga algo que desenfocar)
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primaryColor.withOpacity(0.3),
              ),
            ),
          ),

          // 3. CONTENIDO Y GLASSMORPHISM
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Efecto cristal
                  child: Container(
                    padding: const EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05), // Fondo semitransparente
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1), // Borde brillante sutil
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // LOGO
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.fitness_center, size: 60, color: theme.primaryColor),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'GymFlow',
                          style: TextStyle(
                            fontSize: 36, 
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tu ecosistema de entrenamiento',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                        const SizedBox(height: 48),

                        // INPUT EMAIL
                        _buildGlassTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        // INPUT CONTRASEÑA
                        _buildGlassTextField(
                          controller: _passwordController,
                          label: 'Contraseña',
                          icon: Icons.lock_outline,
                          obscureText: true,
                        ),
                        const SizedBox(height: 40),

                        // BOTÓN ENTRAR
                        SizedBox(
                          width: double.infinity, // Ocupa todo el ancho
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading 
                              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                              : const Text('ENTRAR', style: TextStyle(letterSpacing: 2)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET MODULAR: Campo de texto estilo Glassmorphism
  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white54),
        filled: true,
        fillColor: Colors.black.withOpacity(0.2), // Fondo oscuro del input
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none, // Quitamos el borde por defecto
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2), // Borde azul al enfocar
        ),
      ),
    );
  }
}