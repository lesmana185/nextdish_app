import 'package:flutter/material.dart';
import '../services/ai_recipe_services.dart';
import 'recipe_search_page.dart'; // Pastikan import ini mengarah ke file result yang benar

class SearchLoadingPage extends StatefulWidget {
  const SearchLoadingPage({super.key});

  @override
  State<SearchLoadingPage> createState() => _SearchLoadingPageState();
}

class _SearchLoadingPageState extends State<SearchLoadingPage> {
  @override
  void initState() {
    super.initState();
    _startCooking();
  }

  Future<void> _startCooking() async {
    // Tambah delay dikit biar animasi loading-nya sempat kelihatan (UX)
    await Future.delayed(const Duration(seconds: 2));

    try {
      final aiService = AiRecipeService();

      // PERBAIKAN DI SINI:
      // Tipe datanya sekarang Map<String, dynamic>, BUKAN String lagi.
      final Map<String, dynamic> resepAsli =
          await aiService.generateRecipeFromKitchen();

      if (!mounted) return;

      // Pindah ke Halaman Hasil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // RecipeResultPage sekarang menerima Map, jadi langsung pas
          builder: (context) => RecipeResultPage(recipeContent: resepAsli),
        ),
      );
    } catch (e) {
      // Jika Error, Balik ke Home
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Gagal memuat resep: $e"),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF63B685), // Hijau NextDish
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              const Text(
                "Chef NextDish",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                "Sedang Mencari Resep Terbaik",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
              const SizedBox(height: 12),
              const Text(
                "Bahanmu sedang diracik jadi menu spesial hari ini...",
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
              ),

              const Spacer(),

              // GAMBAR ROBOT
              Image.asset(
                'assets/images/illustrasi/robotr_chef.png',
                height: 250,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.smart_toy, size: 100, color: Colors.white),
              ),

              const Spacer(),

              // LOADING
              const CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 3),
              const SizedBox(height: 20),
              const Text("Mohon tunggu sebentar...",
                  style: TextStyle(color: Colors.white70, fontSize: 12)),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
