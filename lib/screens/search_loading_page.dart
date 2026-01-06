import 'package:flutter/material.dart';
import 'recipe_search_page.dart'; // File halaman resep yang akan kita buat

class SearchLoadingPage extends StatefulWidget {
  const SearchLoadingPage({super.key});

  @override
  State<SearchLoadingPage> createState() => _SearchLoadingPageState();
}

class _SearchLoadingPageState extends State<SearchLoadingPage> {
  @override
  void initState() {
    super.initState();
    // Timer 3 detik simulasi loading "Mencari Resep"
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // Pindah ke Halaman Hasil Resep (Replace agar tidak bisa back ke loading)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RecipeSearchPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF63B685), // Warna Hijau NextDish
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // --- TEKS JUDUL ---
            const Text(
              "Chef NextDish",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Sedang Mencari Resep Terbaik",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Bahanmu sedang diracik jadi menu spesial hari ini",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ),

            const Spacer(),

            // --- GAMBAR MASCOT ---
            // Pastikan aset robot_chef.png sudah ada
            Image.asset(
              'assets/images/illustrasi/robotr_chef.png',
              height: 250,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.smart_toy, size: 150, color: Colors.white),
            ),

            const Spacer(),

            // --- LOADING INDICATOR (Lingkaran Putih) ---
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
