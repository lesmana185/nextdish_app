import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Definisikan warna di sini agar tidak error 'AppTheme not found'
    const Color primaryGreen = Color(0xFF63B685);

    return Scaffold(
      backgroundColor: primaryGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),

              // Title
              const Text(
                "WELCOME",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle
              const Text(
                "Bingung mau masak apa dari bahan yang ada?\n"
                "NextDish bantu temukan resep lezat\n"
                "dari sisa bahan di dapurmu.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // Illustration
              Expanded(
                child: Image.asset(
                  "assets/images/illustrasi/welcome.png",
                  fit: BoxFit.contain,
                  // Tambahkan error builder jaga-jaga jika gambar belum ada
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.soup_kitchen,
                      size: 100,
                      color: Colors.white,
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Tombol 1: Daftar Akun (PUTIH) -> Ke RegisterScreen
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Daftar Akun",
                    style: TextStyle(
                      color: primaryGreen, // Menggunakan variabel lokal
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tombol 2: Log In (OUTLINE) -> Ke LoginScreen
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Log In",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
