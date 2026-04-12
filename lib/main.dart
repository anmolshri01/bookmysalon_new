import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 🔥 MUST for async init

  await Supabase.initialize(
    url: 'https://tfclrffhkrqrtsvjwnxu.supabase.co',
    anonKey: 'sb_publishable_TcFiH3R2oeepcwDZaenXcA_FTL32d2Y',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookMySalon',
      debugShowCheckedModeBanner: false,

      // 🔥 FIX: Prevent rebuild issues on web
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),

      home: const LoginPage(),
    );
  }
}