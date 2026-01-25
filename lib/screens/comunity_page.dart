import 'package:flutter/material.dart';
import 'home_page.dart';
import 'share_recipe_page.dart';
import 'mykitchen_page.dart'; // <--- Import Dapur
import 'search_loading_page.dart'; // <--- Import Search
import 'profile_page.dart'; // <--- Import Profil

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. MAIN CONTENT
          Padding(
            padding: const EdgeInsets.only(bottom: 90), // Ruang Nav Bar
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 50,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER KOMUNITAS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Komunitas",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF388E3C),
                              fontFamily: 'Serif',
                            ),
                          ),
                          Text(
                            "Berbagi resep dengan\npengguna NextDish Lainnya",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Image.asset(
                            'assets/images/home/logosmall.png',
                            height: 40,
                          ),
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

                  const SizedBox(height: 30),

                  // POST 1 (CHRISTAL)
                  _buildPostCard(
                    avatarPath: 'assets/images/home/profile.png',
                    name: "Christal",
                    time: "13 Menit yang lalu",
                    caption:
                        "Hari ini aku mau share resep nasi goreng simple, mudah dibuat dari bahan yang ada dirumah.",
                    imagePath: 'assets/images/home/nasigoreng.jpg',
                    likes: "200",
                    comments: "68",
                  ),

                  const SizedBox(height: 20),

                  // POST 2 (KIM)
                  _buildPostCard(
                    avatarPath: 'assets/images/home/profile.png',
                    name: "KIM",
                    time: "20 Menit yang lalu",
                    caption:
                        "Hari ini aku mau share resep Sayur Asem simple, mudah dibuat. dari bahan yang ada dirumah.",
                    imagePath: 'assets/images/home/salad.jpg',
                    likes: "150",
                    comments: "32",
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),

          // 2. FAB (TOMBOL TAMBAH +)
          Positioned(
            bottom: 110,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShareRecipePage(),
                  ),
                );
              },
              backgroundColor: const Color(0xFF38A169),
              child: const Icon(Icons.add, size: 32, color: Colors.white),
            ),
          ),

          // 3. NAV BAR (SUDAH DIHUBUNGKAN)
          _buildCustomBottomNavBar(context),
        ],
      ),
    );
  }

  // WIDGET: KARTU POSTINGAN
  Widget _buildPostCard({
    required String avatarPath,
    required String name,
    required String time,
    required String caption,
    required String imagePath,
    required String likes,
    required String comments,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage(avatarPath),
              backgroundColor: Colors.green.shade100,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          caption,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.asset(
                  imagePath,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      color: Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      likes,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      comments,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- REUSED NAV BAR (TERHUBUNG) ---
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
                // KE HOME
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => HomePage(),
                      transitionDuration: Duration.zero,
                    ),
                  ),
                  child: _navItem(Icons.home, "Home", false),
                ),

                // KE DAPUR
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const MyKitchenPage(),
                      transitionDuration: Duration.zero,
                    ),
                  ),
                  child: _navItem(Icons.shopping_basket, "Dapur Saya", false),
                ),

                const SizedBox(width: 60),

                // KOMUNITAS (AKTIF)
                _navItem(Icons.chat_bubble, "Komunitas", true),

                // KE PROFIL
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const ProfilePage(),
                      transitionDuration: Duration.zero,
                    ),
                  ),
                  child: _navItem(Icons.person, "Profil", false),
                ),
              ],
            ),
          ),

          // TOMBOL TENGAH (CARI RESEP)
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchLoadingPage(),
                  ),
                );
              },
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
                        'assets/images/home/logosmall.png',
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
