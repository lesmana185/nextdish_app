import 'package:flutter/material.dart';
import 'mykitchen_page.dart';

class HomeComplexPage extends StatelessWidget {
  const HomeComplexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. MAIN CONTENT (Scrollable)
          Padding(
            padding: const EdgeInsets.only(bottom: 90), // Ruang untuk Nav Bar
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),

                  // HEADER
                  _buildHeader(),

                  const SizedBox(height: 20),

                  // HERO BANNER (Resep Favorit)
                  _buildHeroBanner(),

                  const SizedBox(height: 20),

                  // INVENTORY SUMMARY (12 Bahan)
                  _buildInventorySummary(),

                  const SizedBox(height: 24),

                  // TITLE: AKSI CEPAT
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Aksi Cepat",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // GRID BUTTONS
                  _buildQuickActions(),

                  const SizedBox(height: 24),

                  // TITLE: REKOMENDASI
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Rekomendasi",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // HORIZONTAL LIST (FOOD CARDS)
                  _buildRecommendationList(),

                  const SizedBox(height: 24),

                  // WARNING ALERT (Susu Kedaluwarsa)
                  _buildExpiryAlert(),

                  const SizedBox(height: 16),

                  // WASTE IMPACT
                  _buildWasteImpact(),

                  const SizedBox(height: 40), // Bottom spacing
                ],
              ),
            ),
          ),

          // 2. CHAT AI FLOATING BUTTON
          Positioned(right: 20, bottom: 110, child: _buildChatAIButton()),

          // 3. CUSTOM BOTTOM NAVIGATION BAR
          _buildCustomBottomNavBar(context),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage(
              'assets/images/home/profile.png',
            ), // Ganti sesuai aset
            backgroundColor: Colors.green,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Text(
                    "Hello Christal,",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.notifications_active,
                    color: Colors.amber,
                    size: 18,
                  ),
                ],
              ),
              const Text(
                "Mau masak apa hari ini?",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Column(
            children: [
              Image.asset(
                'assets/images/home/logosmall.png',
                height: 30,
              ), // Ganti sesuai aset
              const Text(
                "NextDish",
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 160,
      // 1. INI PEMBUNGKUS HIJAUNYA
      decoration: BoxDecoration(
        color: const Color(0xFF63B685), // Warna Hijau Utama
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF63B685).withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      // ClipRRect memastikan anak-anak (gambar) tidak keluar dari lengkungan hijau
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // 2. GAMBAR NASI GORENG (Di Sebelah Kanan)
            Positioned(
              right: -20, // Geser sedikit ke kanan agar terlihat artistik
              top: 0,
              bottom: 0,
              width:
                  180, // Batasi lebar gambar agar tidak menutupi seluruh hijau
              child: Image.asset(
                'assets/images/home/bannerfood.png', // Pastikan ini gambar PNG transparan lebih bagus
                fit: BoxFit.cover,
              ),
            ),

            // 3. TEKS & KONTEN (Di Sebelah Kiri - Di atas gambar)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Resep\nFavorit",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.1, // Jarak antar baris rapat
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Label Nama Makanan
                  Row(
                    children: [
                      const Icon(
                        Icons.restaurant_menu,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "Nasi Goreng",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Tombol Lihat Detail
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white, // Tombol putih kontras
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Lihat Detail",
                      style: TextStyle(
                        color: Color(0xFF63B685), // Teks hijau
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 4. TITIK-TITIK (Pagination Dots)
            Positioned(
              bottom: 15,
              right: 20,
              child: Row(
                children: [_dot(true), _dot(false), _dot(false), _dot(false)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(bool isActive) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      width: isActive ? 16 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isActive ? 1 : 0.5),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildInventorySummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), // Light Green
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/home/iventoryicon.png',
            height: 60,
          ), // Ganti aset
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "12 Bahan di Dapur",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    const Text("Segar (8)", style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 12),
                    const Icon(Icons.error, color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    const Text(
                      "Hampir Basi (4)",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  "Cari Resep\nDari Bahan",
                  const Color(0xFFFFCC80),
                  'assets/images/home/searchlogo.png',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  "Mode Masak",
                  const Color(0xFF90CAF9),
                  'assets/images/home/miclogo.png',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  "Atur Porsi",
                  const Color(0xFFEF9A9A),
                  'assets/images/home/scalelogo.png',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  "Composite\nAssistant",
                  const Color(0xFFA5D6A7),
                  'assets/images/home/daurlogo.png',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String title, Color color, String iconPath) {
    return Container(
      height: 70,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            color, // Menggunakan warna flat dulu, bisa diganti gradient jika perlu
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.5),
            radius: 20,
            child: Image.asset(iconPath, width: 20), // Ganti Aset
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationList() {
    return SizedBox(
      height: 220,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        children: [
          _foodCard(
            "Nasi Goreng",
            "30 Menit",
            "420 kkal",
            'assets/images/home/nasigoreng.jpg',
          ),
          _foodCard(
            "Salad",
            "10 Menit",
            "150 kkal",
            'assets/images/home/salad.jpg',
          ),
          _foodCard(
            "Ramen",
            "20 Menit",
            "500 kkal",
            'assets/images/home/ramen.jpg',
          ),
        ],
      ),
    );
  }

  Widget _foodCard(String title, String time, String kkal, String imgPath) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16, bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(imgPath), // Ganti aset
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 4)),
        ],
      ),
      child: Stack(
        children: [
          // Gradient Overlay biar teks terbaca
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4, bottom: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "Bahan Tersedia",
                    style: TextStyle(color: Colors.white, fontSize: 8),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      time,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "|",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      kkal,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryAlert() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0), // Orange Muda
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Susu akan kedaluwarsa besok!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF63B685),
              minimumSize: const Size(80, 30),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: const Text("Masak", style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteImpact() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        "0.4 kg sampah berhasil diselamatkan.\nKamu membantu mengurangi limbah makanan.",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: Colors.black87),
      ),
    );
  }

  // --- REUSED WIDGETS (Sama seperti sebelumnya) ---

  Widget _buildChatAIButton() {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE8F5E9),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/home/logochat.png',
            height: 30,
          ), // Ganti aset
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

  Widget _buildCustomBottomNavBar(BuildContext context) {
    // Tambahkan parameter context
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
                // 1. HOME (Aktif)
                _navItem(Icons.home, "Home", true),

                // 2. DAPUR SAYA (Sekarang bisa diklik)
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const MyKitchenPage(),
                        transitionDuration: Duration.zero, // Transisi instan
                      ),
                    );
                  },
                  child: _navItem(Icons.shopping_basket, "Dapur Saya", false),
                ),

                const SizedBox(width: 60), // Spasi untuk tombol tengah
                // 3. KOMUNITAS
                _navItem(Icons.chat_bubble, "Komunitas", false),

                // 4. PROFIL
                _navItem(Icons.person, "Profil", false),
              ],
            ),
          ),

          // TOMBOL TENGAH (Cari Resep)
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
                    Image.asset(
                      'assets/images/home/logosmall.png', // Pastikan aset ini benar
                      height: 30,
                    ),
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
