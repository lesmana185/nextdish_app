import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan Stack agar kita bisa menumpuk Navigasi Bar di atas konten
    return Scaffold(
      backgroundColor: const Color(
        0xFFFAFAFA,
      ), // Warna background agak cream/putih
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. KONTEN UTAMA (Scrollable)
          // Kita kasih padding bawah yang besar agar konten paling bawah tidak tertutup Nav Bar
          Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 50), // Spasi untuk Status Bar
                  // --- HEADER ---
                  _buildHeader(),

                  const SizedBox(height: 30),

                  // --- ILLUSTRATION & EMPTY STATE ---
                  _buildEmptyStateSection(context),

                  const SizedBox(height: 30),

                  // --- 3 STEPS CARD ---
                  _buildStepsCard(),

                  // Spacer tambahan agar scroll lebih nyaman
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // 2. CHAT AI FLOATING BUTTON
          // Posisi di kanan bawah, sedikit di atas Nav Bar
          Positioned(
            right: 20,
            bottom: 100, // Di atas Nav Bar
            child: _buildChatAIButton(),
          ),

          // 3. CUSTOM BOTTOM NAVIGATION BAR
          _buildCustomBottomNavBar(),
        ],
      ),
    );
  }

  // WIDGET: HEADER
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.green.shade100,
            backgroundImage: const AssetImage('assets/images/home/profile.png'),
          ),
          const SizedBox(width: 12),

          // Greetings
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Hello Christal,",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.notifications_active,
                    color: Colors.amber,
                    size: 20,
                  ),
                ],
              ),
              const Text(
                "Mau masak apa hari ini?",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),

          const Spacer(),

          // Logo Kanan
          Column(
            children: [
              Image.asset('assets/images/home/logosmall.png', height: 35),
              const Text(
                "NextDish",
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // WIDGET: EMPTY STATE (KULKAS)
  Widget _buildEmptyStateSection(BuildContext context) {
    return Column(
      children: [
        // Gambar Kulkas
        Image.asset(
          'assets/images/home/kulkas.png',
          height: 200,
          fit: BoxFit.contain,
        ),

        const SizedBox(height: 20),

        const Text(
          "Dapur kamu masih kosong",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF333333),
          ),
        ),

        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: const Text(
            "Yuk mulai dengan memasukkan bahan makanan yang ada di rumah kamu.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
          ),
        ),

        const SizedBox(height: 24),

        // Tombol Masuk ke Dapur
        Container(
          width: 250,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)], // Gradasi Hijau
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                print("Masuk dapur clicked");
              },
              borderRadius: BorderRadius.circular(12),
              child: const Center(
                child: Text(
                  "Masuk ke Dapur",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // WIDGET: 3 LANGKAH
  Widget _buildStepsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Mulai Masak dalam 3 Langkah",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepItem(
                'Tambah\nBahan',
                'assets/images/home/checklist1.png',
                Colors.orange.shade100,
              ),
              _buildStepItem(
                'Cari\nResep AI',
                'assets/images/home/checklist2.png',
                Colors.red.shade100,
              ),
              _buildStepItem(
                'Masak\nTanpa Ribet',
                'assets/images/home/checklist3.png',
                Colors.blue.shade100,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String title, String iconPath, Color bgColor) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5), // Background abu sangat muda
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Image.asset(iconPath),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  // WIDGET: CHAT AI BUTTON (FLOATING)
  Widget _buildChatAIButton() {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE8F5E9), // Hijau sangat muda
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/home/logochat.png', height: 30),
          const Text(
            "Chat AI",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET: CUSTOM BOTTOM NAV BAR
  Widget _buildCustomBottomNavBar() {
    return SizedBox(
      height: 100, // Tinggi total area navigasi
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Background Hijau Melengkung
          Container(
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFF63B685), // Warna Hijau Utama
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, "Home", true),
                _buildNavItem(Icons.shopping_basket, "Dapur Saya", false),
                const SizedBox(width: 60), // Space kosong untuk tombol tengah
                _buildNavItem(Icons.chat_bubble, "Komunitas", false),
                _buildNavItem(Icons.person, "Profil", false),
              ],
            ),
          ),

          // 2. Tombol Tengah (Menonjol)
          Positioned(
            top: 0,
            child: Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: Colors.white, // Lingkaran putih luar
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(5),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF63B685), // Lingkaran hijau dalam
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

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
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
