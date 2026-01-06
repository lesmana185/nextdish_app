import 'package:flutter/material.dart';
import 'home_complex_page.dart';
import 'cooking_mode_intro_page.dart'; // <--- 1. IMPORT HALAMAN MODE MASAK

class RecipeDetailPage extends StatefulWidget {
  final String recipeName;
  final String imagePath;

  const RecipeDetailPage({
    super.key,
    required this.recipeName,
    required this.imagePath,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  int _portionCount = 1;

  void _incrementPortion() {
    setState(() {
      _portionCount++;
    });
  }

  void _decrementPortion() {
    setState(() {
      if (_portionCount > 1) _portionCount--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: Stack(
        children: [
          // 1. GAMBAR HERO
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 350,
            child: Image.asset(widget.imagePath, fit: BoxFit.cover),
          ),

          // 2. TOMBOL BACK
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
          ),

          // 3. KONTEN UTAMA
          Positioned.fill(
            top: 280,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- BAGIAN BAHAN ---
                    const Text(
                      "Bahan :",
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildIngredientText("Nasi putih", 1, "piring"),
                    _buildIngredientText("Bawang putih", 2, "siung"),
                    _buildIngredientText("Bawang merah", 2, "siung"),
                    _buildIngredientText("Telur", 1, "butir"),
                    _buildStaticIngredientText("Ayam suwir / sosis (opsional)"),
                    _buildStaticIngredientText("Garam & kecap secukupnya"),
                    _buildStaticIngredientText("Minyak Goreng"),

                    const SizedBox(height: 24),

                    // --- BAGIAN LANGKAH ---
                    const Text(
                      "Langkah :",
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildStepText(1, "Panaskan sedikit minyak di wajan."),
                    _buildStepText(
                      2,
                      "Tumis bawang putih dan bawang merah hingga harum.",
                    ),
                    _buildStepText(
                      3,
                      "Masukkan telur, orak-arik hingga matang.",
                    ),
                    _buildStepText(4, "Masukkan nasi dan bahan tambahan."),
                    _buildStepText(
                      5,
                      "Bumbui dengan garam dan kecap, aduk rata.",
                    ),
                    _buildStepText(
                      6,
                      "Masak hingga nasi goreng matang dan harum.",
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. WIDGET PORSI
          Positioned(
            top: 250,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                height: 50,
                width: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _decrementPortion,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.3),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.remove, size: 20),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          "$_portionCount porsi",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _incrementPortion,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.5),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: const Center(child: Icon(Icons.add, size: 20)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 5. TOMBOL LOVE & MIC (Floating Right)
          Positioned(
            top: 310,
            right: 20,
            child: Column(
              children: [
                // Tombol Love
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF5350),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),

                // --- 2. TOMBOL MIC (NAVIGATION ADDED HERE) ---
                GestureDetector(
                  onTap: () {
                    // Pindah ke Halaman Intro Mode Masak
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CookingModeIntroPage(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF42A5F5),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.mic, color: Colors.white, size: 28),
                  ),
                ),
              ],
            ),
          ),

          // 6. BOTTOM NAV BAR
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildCustomBottomNavBar(context),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildIngredientText(String name, double baseAmount, String unit) {
    double totalAmount = baseAmount * _portionCount;
    String displayAmount = totalAmount % 1 == 0
        ? totalAmount.toInt().toString()
        : totalAmount.toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              "$name – $displayAmount $unit",
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF424242),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticIngredientText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF424242),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepText(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$number. ",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF333333),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- NAV BAR ---
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
                    MaterialPageRoute(builder: (_) => const HomeComplexPage()),
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
