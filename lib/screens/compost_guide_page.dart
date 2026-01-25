import 'package:flutter/material.dart';
import 'compost_result_page.dart'; // Halaman Sukses
import 'home_page.dart';

class CompostGuidePage extends StatelessWidget {
  const CompostGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF63B685),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Panduan Pengolahan",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset(
              'assets/images/illustrasi/robotmic.png',
              height: 35,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 150),
            child: Column(
              children: [
                // CARD 1: CANGKANG TELUR
                _buildGuideCard(
                  title: "Cangkang Telur",
                  imagePath: "assets/images/ingredients/telur.png",
                  bgColor: const Color(0xFFE8F5E9), // Hijau Muda
                  steps: [
                    {"text": "Cuci Bersih", "done": true}, // Hijau
                    {"text": "Keringkan", "done": true},
                    {"text": "Hancurkan", "done": false}, // Putih
                    {"text": "Taburkan di pot tanaman", "done": false},
                  ],
                ),

                const SizedBox(height: 20),

                // CARD 2: SUSU
                _buildGuideCard(
                  title: "Susu Kedaluwarsa",
                  imagePath: "assets/images/ingredients/susu.png",
                  bgColor: const Color(0xFFFFEBEE), // Merah Muda
                  steps: [
                    {
                      "text": "Buang ke saluran air dengan\nair mengalir",
                      "done": false,
                      "color": Colors.yellow,
                    }, // Kuning
                    {
                      "text": "Jangan campurkan ke\nkompos",
                      "done": false,
                      "color": Colors.yellow,
                    },
                  ],
                ),
              ],
            ),
          ),

          // TOMBOL PROSES SELESAI
          Positioned(
            bottom: 120,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CompostResultPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38A169),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  "Proses Selesai",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // NAV BAR
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildCustomBottomNavBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideCard({
    required String title,
    required String imagePath,
    required Color bgColor,
    required List<Map<String, dynamic>> steps,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                imagePath,
                width: 40,
                height: 40,
                errorBuilder: (c, e, s) => const Icon(Icons.egg, size: 30),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: steps.map((step) {
                Color dotColor;
                if (step.containsKey('color')) {
                  dotColor = step['color']; // Kuning (Susu)
                } else {
                  dotColor = step['done']
                      ? const Color(0xFF00C853)
                      : Colors.grey.shade300; // Hijau/Putih (Telur)
                }

                // Border untuk yang putih
                BoxBorder? border =
                    step['done'] == false && !step.containsKey('color')
                        ? Border.all(color: Colors.grey)
                        : null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: dotColor == Colors.grey.shade300
                              ? Colors.white
                              : dotColor,
                          border: border,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          step['text'],
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // --- REUSED NAV BAR ---
  Widget _buildCustomBottomNavBar(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFF63B685),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomePage()),
                  ),
                  child: _navItem(Icons.home, "Home", false),
                ),
                _navItem(Icons.shopping_basket, "Dapur Saya", false),
                const SizedBox(width: 60),
                _navItem(Icons.chat_bubble, "Komunitas", false),
                _navItem(Icons.person, "Profil", false),
              ],
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(5),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF63B685),
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/home/logosmall.png', height: 30),
                    const Text(
                      "Cari resep",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFF1B5E20) : Colors.white,
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF1B5E20) : Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
