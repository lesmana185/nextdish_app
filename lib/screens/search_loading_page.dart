import 'package:flutter/material.dart';
import '../services/ai_recipe_services.dart'; // Pastikan nama file service benar
import 'recipe_search_page.dart'; // Pastikan nama file result benar

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
    try {
      // 1. Panggil Service AI
      final aiService = AiRecipeService();

      // 2. Minta AI membuat resep
      final String resepAsli = await aiService.generateRecipeFromKitchen();

      if (!mounted) return;

      // 3. Pindah ke Halaman Hasil (Replacement agar user gabisa back ke loading)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeResultPage(recipeContent: resepAsli),
        ),
      );
    } catch (e) {
      // Jika Error (Misal koneksi putus), Balik ke Home dan kasih tau user
      if (mounted) {
        Navigator.pop(context); // Kembali ke halaman sebelumnya
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat resep: $e")),
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
          width: double.infinity, // Pastikan konten di tengah secara horizontal
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
                'assets/images/illustrasi/robotr_chef.png', // Pastikan aset ini ada
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
