import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/mykitchen_page.dart';
import 'screens/comunity_page.dart';
import 'screens/profile_page.dart';
import 'screens/search_loading_page.dart';

class MainScaffold extends StatefulWidget {
  // 1. Tambahkan variabel ini agar bisa menerima pesanan index
  final int initialIndex;

  const MainScaffold({
    super.key,
    this.initialIndex = 0, // Defaultnya 0 (Home)
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  // 2. Gunakan variabel state untuk menyimpan index aktif
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // 3. Set index awal sesuai permintaan (misal: 1 untuk Dapur)
    _currentIndex = widget.initialIndex;
  }

  // Daftar Halaman
  final List<Widget> _pages = [
    const HomePage(), // Index 0
    const MyKitchenPage(), // Index 1
    const CommunityPage(), // Index 2
    const ProfilePage(), // Index 3
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Logic Tombol Tengah (Cari Resep)
  void _onCariResepPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchLoadingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body berubah sesuai index
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // NAVBAR CUSTOM (Desain Tetap Sesuai Punya Kamu)
      bottomNavigationBar: SizedBox(
        height: 100, // Tinggi area navbar + tombol melayang
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none, // Biar bayangan tidak kepotong
          children: [
            // 1. Background Hijau Melengkung
            Container(
              height: 70,
              decoration: const BoxDecoration(
                color: Color(0xFF63B685),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(Icons.home, "Home", 0),
                  _navItem(Icons.shopping_basket, "Dapur", 1),
                  const SizedBox(width: 60), // Space kosong untuk tombol tengah
                  _navItem(Icons.chat_bubble, "Komunitas", 2),
                  _navItem(Icons.person, "Profil", 3),
                ],
              ),
            ),

            // 2. Tombol Tengah Melayang (Cari)
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: _onCariResepPressed,
                child: Container(
                  width: 75,
                  height: 75,
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
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
                          height: 28,
                          errorBuilder: (c, e, s) =>
                              const Icon(Icons.search, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Cari",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
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
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque, // Agar area klik lebih responsif
      child: SizedBox(
        width: 60, // Lebar area sentuh
        child: Column(
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
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
