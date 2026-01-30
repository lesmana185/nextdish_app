import 'package:flutter/material.dart';
import 'cooking_mode_steps_page.dart';

class CookingModeIntroPage extends StatelessWidget {
  // Terima Data Resep dari Halaman Sebelumnya
  final Map<String, dynamic> recipeData;

  const CookingModeIntroPage({super.key, required this.recipeData});

  @override
  Widget build(BuildContext context) {
    // Ambil nama masakan, default ke "Masakan Ini" jika null
    final String recipeName = recipeData['nama'] ?? "Masakan Ini";
    final List<dynamic> steps = recipeData['cara'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back,
                              size: 20, color: Colors.black54),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Mode Masak",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Serif',
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Image.asset('assets/images/home/logosmall.png',
                              height: 30),
                          const Text("NextDish",
                              style: TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // GAMBAR ROBOT
                Image.asset(
                  'assets/images/illustrasi/robotmic.png',
                  height: 250,
                  errorBuilder: (ctx, err, stack) => const Icon(Icons.smart_toy,
                      size: 150, color: Colors.green),
                ),

                const SizedBox(height: 30),

                // TEKS SAMBUTAN DINAMIS
                const Text(
                  "Pilihan yang enak!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Kamu akan memasak $recipeName.\nPastikan semua bahan sudah siap, ya.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, height: 1.5),
                  ),
                ),

                const SizedBox(height: 50),

                // KARTU TOMBOL MIC
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Tombol Mic Biru Besar
                      GestureDetector(
                        onTap: () {
                          // Validasi langkah masak
                          if (steps.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Maaf, data langkah masak tidak tersedia untuk resep ini.")));
                            return;
                          }

                          // Pindah ke Halaman Langkah Masak membawa Data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CookingModeStepsPage(
                                recipeName: recipeName,
                                steps: steps,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.blue.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5)),
                            ],
                          ),
                          child: const Icon(Icons.mic,
                              color: Colors.white, size: 40),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Tekan tombol mikrofon\naku akan memandu suaramu",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Note: Navbar saya hapus di intro agar fokus, tapi kalau mau dipasang bisa copy dari bawah.
        ],
      ),
    );
  }
}
