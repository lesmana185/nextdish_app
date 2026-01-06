import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER HIJAU
          Container(
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 20,
              left: 10,
              right: 10,
            ),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF63B685),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  "Pusat Bantuan",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  left: 10,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // KONTEN INFO (KOTAK HIJAU BESAR)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(
                  0xFF7CB342,
                ).withOpacity(0.8), // Hijau Agak Gelap
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoSection(
                      "Cara Menggunakan Aplikasi",
                      "Tambahkan bahan di Dapur Saya, lalu cari resep dan mulai memasak dengan panduan suara.",
                    ),
                    const SizedBox(height: 16),
                    _buildInfoSection(
                      "Mode Masak & Perintah Suara",
                      "Gunakan perintah suara seperti lanjut dan ulang untuk memasak tanpa menyentuh layar.",
                    ),
                    const SizedBox(height: 16),
                    _buildInfoSection(
                      "Cari Resep dengan AI",
                      "Tanyakan ke AI berdasarkan bahan yang tersedia untuk mendapatkan rekomendasi menu.",
                    ),
                    const SizedBox(height: 16),
                    _buildInfoSection(
                      "Tentang NextDish",
                      "NextDish membantu mengolah bahan dapur agar tidak terbuang dan lebih bermanfaat.",
                    ),

                    const SizedBox(height: 30),

                    // TOMBOL HUBUNGI KAMI
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Aksi ke WA (Nanti)
                        },
                        icon: const Icon(
                          Icons.chat_bubble,
                          color: Color(0xFF558B2F),
                        ),
                        label: const Text(
                          "Hubungi Kami",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white,
            height: 1.3,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
