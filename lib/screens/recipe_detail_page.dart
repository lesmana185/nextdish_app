import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cooking_mode_intro_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
      if (mounted) {
        setState(() {
          _isFavorite = data != null;
          _isLoadingFav = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingFav = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Silakan login untuk menyimpan resep.")));
      return;
    }

    setState(() => _isFavorite = !_isFavorite);

    try {
      if (_isFavorite) {
        await Supabase.instance.client.from('favorite_recipes').insert({
          'user_id': user.id,
          'recipe_name': widget.recipeData['nama'],
          'recipe_json': widget.recipeData,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Tersimpan di Favorit! ❤️")));
        }
      } else {
        await Supabase.instance.client
            .from('favorite_recipes')
            .delete()
            .eq('user_id', user.id)
            .eq('recipe_name', widget.recipeData['nama']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Dihapus dari Favorit.")));
        }
      }
    } catch (e) {
      setState(() => _isFavorite = !_isFavorite);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Gagal: $e")));
      }
    }
  }

  // --- WIDGET GAMBAR YANG LEBIH KUAT (ANTI LAYAR IJO) ---
  Widget _buildHeaderImage(String? imageUrl, String title) {
    // Logic: Coba URL Internet -> Kalau gagal/null -> Coba Aset Lokal -> Kalau gagal -> Tampilkan Placeholder

    ImageProvider? networkImage;
    if (imageUrl != null &&
        imageUrl.isNotEmpty &&
        imageUrl.startsWith('http')) {
      networkImage = NetworkImage(imageUrl);
    }

    // Aset Lokal Fallback
    final t = title.toLowerCase();
    String assetPath = 'assets/images/home/bannerfood.png'; // Default umum

    if (t.contains('sate'))
      assetPath = 'assets/images/resep/sate.jpg';
    else if (t.contains('gudeg'))
      assetPath = 'assets/images/resep/gudeg.jpg';
    else if (t.contains('soto'))
      assetPath = 'assets/images/resep/soto.jpg';
    else if (t.contains('nasi goreng'))
      assetPath = 'assets/images/resep/nasigoreng.jpg';
    else if (t.contains('ayam'))
      assetPath = 'assets/images/resep/ayam.jpg';
    else if (t.contains('ikan') || t.contains('lele'))
      assetPath = 'assets/images/resep/ikan.jpg';
    else if (t.contains('telur'))
      assetPath = 'assets/images/ingredients/telur.png';

    return Stack(
      children: [
        // 1. Gambar Utama
        Positioned.fill(
          child: networkImage != null
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Jika Internet Error, pakai Aset Lokal
                    return Image.asset(assetPath,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                            Container(color: Colors.grey.shade300));
                  },
                )
              : Image.asset(assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                      color: Colors.grey.shade300)), // Jika aset lokal pun gada
        ),

        // 2. Efek Gelap (Gradient)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _incrementPortion() => setState(() => _portionCount++);
  void _decrementPortion() => setState(() {
        if (_portionCount > 1) _portionCount--;
      });

  @override
  Widget build(BuildContext context) {
    final String title = widget.recipeData['nama'] ?? "Resep Spesial";
    final String? imageUrl = widget.recipeData['image_url'];

    final List<dynamic> mainIngredients =
        widget.recipeData['bahan_utama'] ?? widget.recipeData['bahan'] ?? [];
    final List<dynamic> spices = widget.recipeData['bumbu'] ?? [];
    final List<dynamic> caraList = widget.recipeData['cara'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: Stack(
        children: [
          // 1. GAMBAR HERO (HEADER)
          Positioned(
            top: 0, left: 0, right: 0, height: 350,
            child: _buildHeaderImage(imageUrl, title), // Panggil fungsi baru
          ),

          // 2. TOMBOL BACK
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
          ),

          // 3. KONTEN (Kertas Putih)
          Positioned.fill(
            top: 280,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5))
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32))),
                    const SizedBox(height: 20),
                    _buildSectionHeader(Icons.kitchen, "Bahan Utama"),
                    const SizedBox(height: 12),
                    if (mainIngredients.isEmpty)
                      const Text("- Tidak ada data bahan",
                          style: TextStyle(color: Colors.grey)),
                    ...mainIngredients
                        .map((item) => _buildDynamicIngredient(item.toString()))
                        .toList(),
                    const SizedBox(height: 20),
                    if (spices.isNotEmpty) ...[
                      _buildSectionHeader(Icons.eco, "Bumbu & Penyedap",
                          color: Colors.orange),
                      const SizedBox(height: 12),
                      ...spices
                          .map((item) =>
                              _buildDynamicIngredient(item.toString()))
                          .toList(),
                      const SizedBox(height: 24),
                    ],
                    _buildSectionHeader(Icons.menu_book, "Instruksi Koki"),
                    const SizedBox(height: 12),
                    if (caraList.isEmpty)
                      const Text("- Tidak ada langkah tersedia",
                          style: TextStyle(color: Colors.grey)),
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

          // 4. ATUR PORSI
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
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        bottomLeft: Radius.circular(12))),
                                child: const Center(
                                    child: Icon(Icons.remove,
                                        size: 20, color: Colors.green))))),
                    Expanded(
                        flex: 2,
                        child: Center(
                            child: Text("$_portionCount porsi",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)))),
                    Expanded(
                        child: GestureDetector(
                            onTap: _incrementPortion,
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.3),
                                    borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(12),
                                        bottomRight: Radius.circular(12))),
                                child: const Center(
                                    child: Icon(Icons.add,
                                        size: 20, color: Colors.green))))),
                  ],
                ),
              ),
            ),
          ),

          // 5. TOMBOL FAVORIT & MIC
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
                  onTap: () async {
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString(
                          'last_cooked_recipe', jsonEncode(widget.recipeData));
                    } catch (e) {
                      debugPrint("Gagal simpan history: $e");
                    }
                    if (context.mounted) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CookingModeIntroPage(
                                  recipeData: widget.recipeData)));
                    }
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
                              offset: Offset(0, 4))
                        ]),
                    child: const Icon(Icons.mic, color: Colors.white, size: 28),
                  ),
                ),
              ],
            ),
          ),

          // 6. NAVBAR BAWAH (Custom)
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildCustomBottomNavBar(context),
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildSectionHeader(IconData icon, String title,
      {Color color = const Color(0xFF2E7D32)}) {
    return Row(children: [
      Icon(icon, color: color),
      const SizedBox(width: 8),
      Text(title,
          style: const TextStyle(
              fontFamily: 'Serif', fontSize: 18, fontWeight: FontWeight.bold))
    ]);
  }

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
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
              child: Text(displayText,
                  style: const TextStyle(
                      fontSize: 15, color: Color(0xFF424242), height: 1.4)))
        ]));
  }

  Widget _buildStepText(int number, String text) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                      fontSize: 14))),
          const SizedBox(width: 12),
          Expanded(
              child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300)),
                  child: Text(text,
                      style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF333333),
                          height: 1.5))))
        ]));
  }

  Widget _buildCustomBottomNavBar(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
          color: Color(0xFF63B685),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home, color: Colors.white, size: 28),
                  SizedBox(height: 4),
                  Text("Home",
                      style: TextStyle(color: Colors.white, fontSize: 10))
                ]),
          ),
          // Nav item dummy karena ini halaman detail
          _navItem(Icons.shopping_basket, "Dapur"),
          const SizedBox(width: 20),
          _navItem(Icons.chat_bubble, "Komunitas"),
          _navItem(Icons.person, "Profil"),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, color: Colors.white, size: 28),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 10))
    ]);
  }
}
