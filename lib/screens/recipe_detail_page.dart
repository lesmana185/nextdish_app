import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cooking_mode_intro_page.dart';
import '../main_scaffold.dart';

class RecipeDetailPage extends StatefulWidget {
  final Map<String, dynamic> recipeData;
  final String imageUrl; // URL gambar diterima dari halaman sebelumnya

  const RecipeDetailPage({
    super.key,
    required this.recipeData,
    required this.imageUrl,
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

  // --- LOGIKA FAVORIT (SUPABASE) ---
  Future<void> _checkIfFavorite() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoadingFav = false);
      return;
    }

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
      debugPrint("Error cek favorit: $e");
      if (mounted) setState(() => _isLoadingFav = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Silakan login untuk menyimpan resep!")));
      return;
    }

    // Optimistic Update
    setState(() => _isFavorite = !_isFavorite);

    try {
      if (_isFavorite) {
        await Supabase.instance.client.from('favorite_recipes').insert({
          'user_id': user.id,
          'recipe_name': widget.recipeData['nama'],
          'recipe_json': widget.recipeData,
          'image_url': widget.imageUrl,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Resep tersimpan ke Favorit!")),
          );
        }
      } else {
        await Supabase.instance.client
            .from('favorite_recipes')
            .delete()
            .eq('user_id', user.id)
            .eq('recipe_name', widget.recipeData['nama']);
      }
    } catch (e) {
      // Revert jika gagal
      setState(() => _isFavorite = !_isFavorite);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan: $e")),
        );
      }
    }
  }

  // --- LOGIKA PORSI ---
  void _increment() => setState(() => _portionCount++);
  void _decrement() => setState(() {
        if (_portionCount > 1) _portionCount--;
      });

  // --- BUILDER UTAMA ---
  @override
  Widget build(BuildContext context) {
    // Default text disamakan dengan RecipeResultPage agar Hero Animation lancar
    final String title = widget.recipeData['nama'] ?? "Menu Spesial";

    final List<dynamic> ingredients = widget.recipeData['bahan'] ?? [];
    final List<dynamic> steps = widget.recipeData['cara'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: Stack(
        children: [
          // 1. GAMBAR HEADER (Full Width dengan Hero Animation)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 350,
            child: Hero(
              tag: title, // Tag harus sama dengan halaman sebelumnya
              child: _buildHeaderImage(widget.imageUrl),
            ),
          ),

          // 2. GRADIENT GELAP
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
            ),
          ),

          // 3. TOMBOL BACK
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
                child:
                    const Icon(Icons.arrow_back, color: Colors.black, size: 24),
              ),
            ),
          ),

          // 4. KONTEN PUTIH (Scrollable Panel)
          Positioned.fill(
            top: 280,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5))
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // JUDUL RESEP
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // INFO WAKTU & KALORI
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 18, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(widget.recipeData['waktu'] ?? "30 Min",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13)),
                        const SizedBox(width: 20),
                        const Icon(Icons.local_fire_department_outlined,
                            size: 18, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(widget.recipeData['kalori'] ?? "Estimasi",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // LIST BAHAN
                    _sectionTitle(Icons.kitchen, "Bahan-bahan"),
                    if (ingredients.isEmpty)
                      const Text("- Data bahan tidak tersedia -",
                          style: TextStyle(color: Colors.grey)),
                    ...ingredients.map((item) => _dynamicIng(item.toString())),

                    const SizedBox(height: 30), // Jarak agak jauh dikit

                    // LIST CARA MASAK (Tutorial Style)
                    _sectionTitle(Icons.menu_book, "Cara Memasak"),
                    if (steps.isEmpty)
                      const Text("- Data cara masak tidak tersedia -",
                          style: TextStyle(color: Colors.grey)),
                    // DI SINI PERUBAHANNYA: Menggunakan Tutorial Step Card
                    ...steps.asMap().entries.map((e) =>
                        _buildTutorialStepCard(e.key + 1, e.value.toString())),
                  ],
                ),
              ),
            ),
          ),

          // 5. PORSI ADJUSTER
          Positioned(
            top: 255,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                height: 50,
                width: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.green),
                      onPressed: _decrement,
                    ),
                    Text(
                      "$_portionCount Porsi",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.green),
                      onPressed: _increment,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 6. TOMBOL AKSI KANAN
          Positioned(
            top: 330,
            right: 24,
            child: Column(
              children: [
                // Tombol Favorit
                GestureDetector(
                  onTap: _toggleFavorite,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 8)
                        ]),
                    child: _isLoadingFav
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: const Color(0xFFEF5350),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // Tombol Cooking Mode
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => CookingModeIntroPage(
                                recipeData: widget.recipeData)));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                        color: Color(0xFF42A5F5),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 8)
                        ]),
                    child: const Icon(Icons.mic, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // 7. BOTTOM NAVBAR
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 70,
              decoration: const BoxDecoration(
                  color: Color(0xFF63B685),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -2))
                  ]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navBtn(Icons.home, "Home", () => _goToHome(0)),
                  _navBtn(Icons.shopping_basket, "Dapur", () => _goToHome(1)),
                  _navBtn(Icons.chat_bubble, "Komunitas", () {}),
                  _navBtn(Icons.person, "Profil", () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  // 1. HELPER BARU: Tutorial Step Card
  // Menggantikan _stepItem yang lama agar teks panjang terlihat rapi
  Widget _buildTutorialStepCard(int stepNum, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
        // Border tipis hijau agar selaras dengan tema
        border: Border.all(color: const Color(0xFF63B685).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge Langkah
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF63B685).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Langkah $stepNum",
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Isi Teks Deskriptif (Justify agar rapi kiri-kanan)
          Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6, // Spasi baris lebih lega
              color: Colors.black87,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(String url) {
    bool isNetwork = url.startsWith('http');

    if (isNetwork) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Colors.grey.shade200,
            child: const Center(
                child: CircularProgressIndicator(color: Colors.green)),
          );
        },
        errorBuilder: (ctx, error, stackTrace) {
          return Image.asset('assets/images/menu_book.png', fit: BoxFit.cover);
        },
      );
    } else {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (ctx, error, stackTrace) {
          return Image.asset('assets/images/menu_book.png', fit: BoxFit.cover);
        },
      );
    }
  }

  void _goToHome(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainScaffold(initialIndex: index)),
      (route) => false,
    );
  }

  Widget _sectionTitle(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF63B685)),
          const SizedBox(width: 8),
          Text(text,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _dynamicIng(String text) {
    String display = text.replaceAllMapped(RegExp(r'(\d+)'), (m) {
      try {
        int baseVal = int.parse(m.group(0)!);
        return (baseVal * _portionCount).toString();
      } catch (e) {
        return m.group(0)!;
      }
    });

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.check_circle, size: 16, color: Color(0xFF63B685)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(display, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }
}
