import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Importamos Supabase
import 'package:gymflow_app/screens/login_screen.dart'; // Importamos tu nueva pantalla

// Cambiamos el main para que sea asíncrono (para poder esperar a la base de datos)
Future<void> main() async {
  // Esta línea es obligatoria si hacemos cosas antes del runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos la conexión a tu Supabase
  await Supabase.initialize(
    url: 'https://qxqnkuisrwqbqvgcmoyb.supabase.co',
    // OJO: Si esta clave te da error más adelante, asegúrate de haberla copiado entera, a veces son más largas.
    anonKey: 'sb_publishable_vcqofCF4xL5X-h91nWzARA_hz8d_ETp',
  );

  runApp(const GymFlowApp());
}

class GymFlowApp extends StatelessWidget {
  const GymFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymFlow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      // ¡AQUÍ ESTÁ EL CAMBIO! Ahora la pantalla principal es tu LoginScreen
      home: const LoginScreen(),
    );
  }
}