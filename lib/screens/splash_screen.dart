import 'dart:async';
import 'package:flutter/material.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Logo Utama
            AnimatedOpacity(opacity: 1, duration: Duration(milliseconds: 800)),
            Image.asset(
              'assets/images/logo/logonextdihs.png',
              width: 180,
              height: 170,
            ),
            const SizedBox(height: 20),

            // 3. Tagline dengan Warna Fill 144C2A & Drop Shadow
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Setiap Sisa Punya Cerita Rasa',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF144C2A), // Warna yang kamu minta
                  shadows: [
                    Shadow(
                      blurRadius: 4.0,
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(
                        1.5,
                        1.5,
                      ), // Efek bayangan (Drop Shadow)
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
