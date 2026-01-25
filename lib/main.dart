import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 1. Import DotEnv
import 'screens/first_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load file rahasia (.env)
  await dotenv.load(fileName: ".env");

  // 3. Inisialisasi Supabase menggunakan variabel dari .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '', // Ambil URL
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '', // Ambil Key
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NextDish',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const FirstPage(),
    );
  }
}
