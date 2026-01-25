import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/mykitchen_page.dart';
import 'screens/comunity_page.dart';
import 'screens/profile_page.dart';
import 'services/ai_recipe_services.dart';
import 'screens/search_loading_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  // Daftar Halaman
  final List<Widget> _pages = [
    const HomePage(), // Index 0
    const MyKitchenPage(), // Index 1
    const CommunityPage(), // Index 2 (Komunitas)
    const ProfilePage(), // Index 3
  ];

  // Logic Tombol Tengah (Cari Resep)
  Future<void> _onCariResepPressed() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
            child: CircularProgressIndicator(color: Color(0xFF63B685))));
    try {
      final aiService = AiRecipeService();
      final jsonResult = await aiService.generateRecipeFromKitchen();
      if (mounted) Navigator.pop(context);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchLoadingPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Gagal: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body berubah sesuai index
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // NAVBAR CUSTOM DI SINI (SATU SUMBER UNTUK SEMUA)
      bottomNavigationBar: Container(
        height: 100,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Background Hijau Melengkung
            Container(
              height: 70,
              decoration: const BoxDecoration(
                color: Color(0xFF63B685),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -2))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(Icons.home, "Home", 0),
                  _navItem(Icons.shopping_basket, "Dapur", 1),
                  const SizedBox(width: 60), // Space tombol tengah
                  _navItem(Icons.chat_bubble, "Komunitas", 2),
                  _navItem(Icons.person, "Profil", 3),
                ],
              ),
            ),

            // Tombol Tengah Melayang
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: _onCariResepPressed,
                child: Container(
                  width: 75,
                  height: 75,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10)
                      ]),
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Color(0xFF63B685), shape: BoxShape.circle),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/home/logosmall.png',
                              height: 30),
                          const Text("Cari",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold))
                        ]),
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
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              color: isActive ? const Color(0xFF1B5E20) : Colors.white,
              size: 26),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: isActive ? const Color(0xFF1B5E20) : Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
