import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart'; // Pastikan import HomePage
import 'cooking_mode_intro_page.dart';

class RecipeDetailPage extends StatefulWidget {
  final Map<String, dynamic> recipeData;

  const RecipeDetailPage({
    super.key,
    required this.recipeData,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  int _portionCount = 1;
  bool _isFavorite = false;
  bool _isLoadingFav = true;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final data = await Supabase.instance.client
          .from('favorite_recipes')
          .select()
          .eq('user_id', user.id)
          .eq('recipe_name', widget.recipeData['nama'])
          .maybeSingle();
      if (mounted)
        setState(() {
          _isFavorite = data != null;
          _isLoadingFav = false;
        });
    } catch (e) {
      setState(() => _isLoadingFav = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    setState(() => _isFavorite = !_isFavorite);
    try {
      if (_isFavorite) {
        await Supabase.instance.client.from('favorite_recipes').insert({
          'user_id': user.id,
          'recipe_name': widget.recipeData['nama'],
          'recipe_json': widget.recipeData,
        });
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Tersimpan di Favorit! ❤️")));
      } else {
        await Supabase.instance.client
            .from('favorite_recipes')
            .delete()
            .eq('user_id', user.id)
            .eq('recipe_name', widget.recipeData['nama']);
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Dihapus dari Favorit.")));
      }
    } catch (e) {
      setState(() => _isFavorite = !_isFavorite);
    }
  }

  String _getImageAsset(String title) {
    final t = title.toLowerCase();
    if (t.contains('sate')) return 'assets/images/resep/sate.jpg';
    if (t.contains('gudeg')) return 'assets/images/resep/gudeg.jpg';
    if (t.contains('soto')) return 'assets/images/resep/soto.jpg';
    if (t.contains('nasi goreng')) return 'assets/images/resep/nasigoreng.jpg';
    if (t.contains('nasi liwet')) return 'assets/images/resep/nasiliwet.jpg';
    if (t.contains('nasi')) return 'assets/images/resep/nasi.jpg';
    if (t.contains('ayam')) return 'assets/images/resep/ayam.jpg';
    if (t.contains('ikan') || t.contains('lele'))
      return 'assets/images/resep/ikan.jpg';
    if (t.contains('telur')) return 'assets/images/ingredients/telur.png';
    return 'assets/images/home/bannerfood.png';
  }

  void _incrementPortion() => setState(() => _portionCount++);
  void _decrementPortion() => setState(() {
        if (_portionCount > 1) _portionCount--;
      });

  @override
  Widget build(BuildContext context) {
    final String title = widget.recipeData['nama'] ?? "Resep Spesial";

    // --- LOGIKA PEMISAHAN BAHAN ---
    // Cek apakah ada key baru 'bahan_utama', jika tidak pakai key lama 'bahan'
    final List<dynamic> mainIngredients =
        widget.recipeData['bahan_utama'] ?? widget.recipeData['bahan'] ?? [];
    final List<dynamic> spices =
        widget.recipeData['bumbu'] ?? []; // Bisa kosong kalau data lama
    final List<dynamic> caraList = widget.recipeData['cara'] ?? [];

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
            child: Image.asset(_getImageAsset(title), fit: BoxFit.cover),
          ),

          // 2. TOMBOL BACK
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () =>
                  Navigator.of(context).pop(), // Pop biasa karena dari list
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
          ),

          // 3. KONTEN SCROLLABLE
          Positioned.fill(
            top: 280,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // JUDUL
                    Text(title,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32))),
                    const SizedBox(height: 20),

                    // --- SECTION 1: BAHAN UTAMA ---
                    const Row(
                      children: [
                        Icon(Icons.kitchen, color: Color(0xFF2E7D32)),
                        SizedBox(width: 8),
                        Text("Bahan Utama :",
                            style: TextStyle(
                                fontFamily: 'Serif',
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (mainIngredients.isEmpty)
                      const Text("- Tidak ada data bahan"),
                    ...mainIngredients
                        .map((item) => _buildDynamicIngredient(item.toString()))
                        .toList(),

                    const SizedBox(height: 20),

                    // --- SECTION 2: BUMBU & PELENGKAP (JIKA ADA) ---
                    if (spices.isNotEmpty) ...[
                      const Row(
                        children: [
                          Icon(Icons.eco, color: Colors.orange),
                          SizedBox(width: 8),
                          Text("Bumbu & Penyedap :",
                              style: TextStyle(
                                  fontFamily: 'Serif',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...spices
                          .map((item) =>
                              _buildDynamicIngredient(item.toString()))
                          .toList(),
                      const SizedBox(height: 24),
                    ],

                    // --- SECTION 3: LANGKAH MEMASAK ---
                    const Row(
                      children: [
                        Icon(Icons.menu_book, color: Color(0xFF2E7D32)),
                        SizedBox(width: 8),
                        Text("Instruksi Koki :",
                            style: TextStyle(
                                fontFamily: 'Serif',
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (caraList.isEmpty) const Text("- Tidak ada langkah"),
                    ...caraList
                        .asMap()
                        .entries
                        .map((entry) => _buildStepText(
                            entry.key + 1, entry.value.toString()))
                        .toList(),
                  ],
                ),
              ),
            ),
          ),

          // 4. PORSI (FLOATING)
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
                          offset: const Offset(0, 4))
                    ]),
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
                                        bottomLeft: Radius.circular(12))),
                                child: const Center(
                                    child: Icon(Icons.remove, size: 20))))),
                    Expanded(
                        flex: 2,
                        child: Center(
                            child: Text("$_portionCount porsi",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)))),
                    Expanded(
                        child: GestureDetector(
                            onTap: _incrementPortion,
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.5),
                                    borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(12),
                                        bottomRight: Radius.circular(12))),
                                child: const Center(
                                    child: Icon(Icons.add, size: 20))))),
                  ],
                ),
              ),
            ),
          ),

          // 5. TOMBOL LOVE & MIC
          Positioned(
            top: 310,
            right: 20,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _toggleFavorite,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                        color: Color(0xFFEF5350),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4))
                        ]),
                    child: _isLoadingFav
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.white,
                            size: 28),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CookingModeIntroPage())),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                        color: Color(0xFF42A5F5),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4))
                        ]),
                    child: const Icon(Icons.mic, color: Colors.white, size: 28),
                  ),
                ),
              ],
            ),
          ),

          // 6. NAVBAR CUSTOM DIBAWAH
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildCustomBottomNavBar(context),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  // Fungsi Pintar: Mengalikan angka di dalam teks (Misal: "1 sdt" jadi "2 sdt")
  Widget _buildDynamicIngredient(String text) {
    String displayText = text;
    if (_portionCount > 1) {
      displayText = text.replaceAllMapped(RegExp(r'(\d+)'), (match) {
        int original = int.parse(match.group(0)!);
        return (original * _portionCount).toString();
      });
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
              child: Text(displayText,
                  style: const TextStyle(
                      fontSize: 16, color: Color(0xFF424242), height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildStepText(int number, String text) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 16), // Jarak antar langkah lebih lega
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: Color(0xFF63B685), shape: BoxShape.circle),
            child: Text("$number",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 15, color: Color(0xFF333333), height: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

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
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  // KEMBALI KE HOME YANG BENAR (POP sampai habis)
                  onTap: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.home, color: Colors.white, size: 28),
                        const SizedBox(height: 4),
                        const Text("Home",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600))
                      ]),
                ),
                _navItem(Icons.shopping_basket, "Dapur Saya", false),
                const SizedBox(width: 60),
                _navItem(Icons.chat_bubble, "Komunitas", false),
                _navItem(Icons.person, "Profil", false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, color: Colors.white, size: 28),
      const SizedBox(height: 4),
      Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600))
    ]);
  }
}
