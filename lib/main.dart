import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gymflow_app/src/constants/supabase_constants.dart';
import 'package:gymflow_app/src/config/theme.dart';
import 'package:gymflow_app/src/ui/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.anonKey,
  );

  runApp(
    // ProviderScope es obligatorio para que Riverpod funcione
    const ProviderScope(
      child: GymFlowApp(),
    ),
  );
}

class GymFlowApp extends StatelessWidget {
  const GymFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GymFlow',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}