import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Pastikan file ini ada

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil ukuran layar untuk responsivitas
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      // Hapus SafeArea di sini agar gambar atas bisa full sampai status bar
      body: Column(
        children: [
          // --- BAGIAN ATAS (GAMBAR SAYUR) ---
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            child: Image.asset(
              'assets/images/illustrasi/firtsttop.png', // Pastikan path ini benar di pubspec.yaml
              width: double.infinity,
              height: screenHeight * 0.35, // Menggunakan 35% tinggi layar
              fit: BoxFit.cover,
            ),
          ),

          // --- BAGIAN TENGAH (TEKS & TOMBOL) ---
          // Gunakan Expanded agar bagian ini mengisi ruang kosong di tengah
          Expanded(
            child: SingleChildScrollView(
              // Tambah scroll view untuk jaga-jaga di HP kecil
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Masak apa hari ini ?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "NextDish",
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(
                        0xFF2E7D32,
                      ), // Hijau yang lebih tegas sesuai desain
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: const Text(
                      "Membantu menemukan resep terbaik,\nMengatur porsi yang pas, dan\nBerbagi ide masakan dengan sesama.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        height: 1.5, // Jarak antar baris agar lebih rapi
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // TOMBOL MASUK
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SplashScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          // Gradasi disesuaikan agar mirip Figma (lebih gelap di kanan)
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF4CAF50), // Hijau standard
                              Color(0xFF1B5E20), // Hijau tua (Forest Green)
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1B5E20).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "MASUK",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2, // Sedikit jarak antar huruf
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // --- BAGIAN BAWAH (GAMBAR ALAT MASAK) ---
          // Tidak perlu ClipRRect jika gambar transparan/png
          // Tidak perlu Transform.translate agar layout tidak rusak
          SizedBox(
            width: double.infinity,
            height: 120, // Sesuaikan tinggi sesuai aset
            child: Image.asset(
              'assets/images/illustrasi/firstbottom.png',
              fit: BoxFit.fitWidth, // Agar lebar memenuhi layar
              alignment: Alignment.bottomCenter, // Pastikan nempel bawah
            ),
          ),
        ],
      ),
    );
  }
}
