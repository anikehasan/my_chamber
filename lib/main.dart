import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: MyChamberApp(),
    ),
  );
}

class MyChamberApp extends StatelessWidget {
  const MyChamberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyChamber',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F4C5C),
        ),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('MyChamber Connected to Supabase'),
        ),
      ),
    );
  }
}