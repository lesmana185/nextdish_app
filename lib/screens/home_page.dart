import 'dart:async'; // WAJIB ADA untuk StreamSubscription
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/ai_recipe_services.dart';
import 'recipe_search_page.dart';
import 'chat_ai_page.dart';
import 'cooking_mode_steps_page.dart';
import 'mykitchen_page.dart';
import 'recipe_detail_page.dart';
import 'compost_landing_page.dart'; // <--- IMPORT BARU

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = "Chef";
  String? _avatarUrl;
  List<Map<String, dynamic>> _favorites = [];
  Map<String, String> _adminImages = {};

  // Variabel untuk memantau perubahan akun (Ganti foto/nama)
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadFavorites();
    _loadAdminImages();

    // --- MATA-MATA (LISTENER) ---
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.userUpdated ||
          event == AuthChangeEvent.tokenRefreshed ||
          event == AuthChangeEvent.signedIn) {
        _loadUserProfile(); // Refresh data user di Home
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  void refreshFavorites() => _loadFavorites();

  Future<void> _loadUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      if (mounted) {
        setState(() {
          _userName = user.userMetadata?['full_name'] ??
              user.email?.split('@')[0] ??
              "Chef";

          // Trik timestamp agar gambar refresh
          String? url = user.userMetadata?['avatar_url'];
          if (url != null) {
            _avatarUrl = "$url?t=${DateTime.now().millisecondsSinceEpoch}";
          } else {
            _avatarUrl = null;
          }
        });
      }
    }
  }

  Future<void> _loadFavorites() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final response = await Supabase.instance.client
          .from('favorite_recipes')
          .select('recipe_json')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _favorites = List<Map<String, dynamic>>.from(
              response.map((e) => e['recipe_json']));
        });
      }
    } catch (e) {
      // Silent error
    }
  }

  Future<void> _loadAdminImages() async {
    try {
      final response = await Supabase.instance.client
          .from('food_gallery')
          .select('food_name, image_url')
          .limit(50);
      final Map<String, String> imageMap = {};
      for (var item in response) {
        imageMap[item['food_name'].toString().toLowerCase()] =
            item['image_url'];
      }
      if (mounted) setState(() => _adminImages = imageMap);
    } catch (e) {
      // Silent error
    }
  }

  // --- 1. FITUR LANJUT MASAK ---
  Future<void> _resumeCookingSession() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastRecipeString = prefs.getString('last_cooked_recipe');

    if (lastRecipeString != null) {
      try {
        final Map<String, dynamic> recipeData = jsonDecode(lastRecipeString);
        final String name = recipeData['nama'] ?? "Masakan";
        final List<dynamic> steps = recipeData['cara'] ?? [];

        if (steps.isEmpty) throw Exception("Data langkah kosong");

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CookingModeStepsPage(
                recipeName: name,
                steps: steps,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Data sesi rusak, pilih resep baru.")),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Belum ada sesi masak aktif. Pilih resep dulu!"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // --- 2. FITUR ATUR PORSI ---
  Future<void> _openLastRecipeDetail() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastRecipeString = prefs.getString('last_cooked_recipe');

    if (lastRecipeString != null) {
      try {
        final Map<String, dynamic> recipeData = jsonDecode(lastRecipeString);

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailPage(recipeData: recipeData),
            ),
          ).then((_) => _loadFavorites());
        }
      } catch (e) {
        debugPrint("Error decoding recipe: $e");
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Belum ada resep terakhir. Cari resep dulu ya!"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // --- 3. FITUR COMPOSITE (SEKARANG SUDAH AKTIF) ---
  void _openCompostAssistant() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CompostLandingPage()),
    ).then((_) {
      // Refresh home/dapur info kalau user balik setelah hapus sampah
      _loadFavorites();
    });
  }

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
                MaterialPageRoute(
                    builder: (context) =>
                        RecipeResultPage(recipeContent: jsonResult)))
            .then((_) => _loadFavorites());
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Gagal: $e")));
      }
    }
  }

  // --- LOGIKA GAMBAR ---
  Widget _buildRecipeImage(String title) {
    final t = title.toLowerCase();

    String? adminUrl;
    for (var key in _adminImages.keys) {
      if (t.contains(key)) {
        adminUrl = _adminImages[key];
        break;
      }
    }
    if (adminUrl != null) {
      return Image.network(adminUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => _buildFallbackImage());
    }

    String? localAsset;
    if (t.contains('sate'))
      localAsset = 'assets/images/resep/sate.jpg';
    else if (t.contains('gudeg'))
      localAsset = 'assets/images/resep/gudeg.jpg';
    else if (t.contains('soto'))
      localAsset = 'assets/images/resep/soto.jpg';
    else if (t.contains('nasi goreng'))
      localAsset = 'assets/images/resep/nasigoreng.jpg';
    else if (t.contains('nasi liwet'))
      localAsset = 'assets/images/resep/nasiliwet.jpg';
    else if (t.contains('nasi'))
      localAsset = 'assets/images/resep/nasi.jpg';
    else if (t.contains('ayam'))
      localAsset = 'assets/images/resep/ayam.jpg';
    else if (t.contains('ikan') || t.contains('lele'))
      localAsset = 'assets/images/resep/ikan.jpg';

    if (localAsset != null) {
      return Image.asset(localAsset,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => _buildFallbackImage());
    }

    return _buildFallbackImage();
  }

  Widget _buildFallbackImage() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Image.asset('assets/images/home/logosmall.png',
            height: 40,
            errorBuilder: (c, e, s) =>
                const Icon(Icons.restaurant, color: Colors.green)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ChatAIPage())),
          backgroundColor: Colors.white,
          elevation: 4,
          icon: Image.asset('assets/images/home/logochat.png',
              height: 24,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.chat, color: Colors.green)),
          label: const Text("Chat AI",
              style: TextStyle(
                  color: Color(0xFF63B685), fontWeight: FontWeight.bold)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 150),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            const Text("Resep Favorit Kamu ❤️",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildFavoriteSlider(),
            const SizedBox(height: 20),
            _buildKitchenInfo(),
            const SizedBox(height: 24),
            const Text("Aksi Cepat",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.grey.shade200,
              // FOTO PROFIL DINAMIS
              backgroundImage: _avatarUrl != null
                  ? NetworkImage(_avatarUrl!)
                  : const AssetImage('assets/images/home/profile.png')
                      as ImageProvider,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hello $_userName, 👋",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const Text("Mau masak apa hari ini?",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
        Image.asset('assets/images/home/logosmall.png', height: 35),
      ],
    );
  }

  Widget _buildFavoriteSlider() {
    if (_favorites.isEmpty) {
      return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.favorite_border, color: Colors.grey, size: 30),
            SizedBox(height: 8),
            Text("Belum ada resep favorit.\nYuk cari & simpan resep!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final resep = _favorites[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                RecipeDetailPage(recipeData: resep)))
                    .then((_) => _loadFavorites());
              },
              child: _buildHeroCard(resep),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(Map<String, dynamic> resep) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF63B685),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF63B685).withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(resep['nama'] ?? "Resep",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.2)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(resep['waktu'] ?? "Estimasi",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text("Lihat Detail",
                      style: TextStyle(
                          color: Color(0xFF63B685),
                          fontWeight: FontWeight.bold,
                          fontSize: 10)),
                )
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            top: 0,
            width: 140,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(24)),
              child: _buildRecipeImage(resep['nama'] ?? ""),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKitchenInfo() {
    return GestureDetector(
      onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const MyKitchenPage()))
          .then((_) => _loadFavorites()),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Image.asset('assets/images/ingredients/telur.png',
                height: 40, errorBuilder: (c, e, s) => const Icon(Icons.egg)),
            const SizedBox(width: 16),
            const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Cek Bahan di Dapur",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 4),
                  Text("Ketuk untuk kelola bahanmu",
                      style: TextStyle(fontSize: 10, color: Colors.grey))
                ]),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(children: [
          Expanded(
              child: _buildActionButton("Cari Resep\nDari Bahan", Icons.search,
                  const Color(0xFFFFCC80), Colors.orange.shade900,
                  onTap: _onCariResepPressed)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildActionButton("Mode Masak\n(Lanjut)", Icons.mic,
                  const Color(0xFF90CAF9), Colors.blue.shade900,
                  onTap: _resumeCookingSession)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _buildActionButton("Atur Porsi\n(Resep Terakhir)",
                  Icons.balance, const Color(0xFFEF9A9A), Colors.red.shade900,
                  onTap: _openLastRecipeDetail)),
          const SizedBox(width: 12),

          // --- TOMBOL COMPOSITE SUDAH AKTIF ---
          Expanded(
              child: _buildActionButton("Composite\nAssistant", Icons.recycling,
                  const Color(0xFFA5D6A7), Colors.green.shade900,
                  onTap: _openCompostAssistant)),
        ]),
      ],
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color bgColor, Color iconColor,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: bgColor, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                  color: Colors.white54, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)))
        ]),
      ),
    );
  }
}
