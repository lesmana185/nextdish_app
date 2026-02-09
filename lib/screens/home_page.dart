import 'dart:async';
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
import 'compost_landing_page.dart';
import 'search_loading_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onSwitchToKitchen;

  const HomePage({super.key, this.onSwitchToKitchen});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = "Chef";
  String? _avatarUrl;
  Map<String, String> _adminImages = {};

  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadAdminImages();

    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.userUpdated ||
          event == AuthChangeEvent.signedIn) {
        _loadUserProfile();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  // --- 1. STREAM FAVORIT (REAL-TIME FIX) ---
  Stream<List<Map<String, dynamic>>> _getFavoritesStream() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return const Stream.empty();

    // Mengambil stream data favorit secara real-time
    return Supabase.instance.client
        .from('favorite_recipes')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
  }

  Future<void> _loadUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      if (mounted) {
        setState(() {
          _userName = user.userMetadata?['full_name'] ??
              user.email?.split('@')[0] ??
              "Chef";
          String? url = user.userMetadata?['avatar_url'];
          _avatarUrl = url != null
              ? "$url?t=${DateTime.now().millisecondsSinceEpoch}"
              : null;
        });
      }
    }
  }

  Future<void> _loadAdminImages() async {
    try {
      final Map<String, String> tempMap = {};
      final resMenu = await Supabase.instance.client
          .from('food_gallery')
          .select('food_name, image_url');
      for (var item in resMenu) {
        tempMap[item['food_name'].toString().toLowerCase()] = item['image_url'];
      }
      if (mounted) setState(() => _adminImages = tempMap);
    } catch (e) {/* Silent */}
  }

  String _findBestImage(String title) {
    final t = title.toLowerCase();
    for (var key in _adminImages.keys) {
      if (t.contains(key)) return _adminImages[key]!;
    }
    return 'assets/images/home/bannerfood.png';
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
          icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF63B685)),
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
            _buildFavoriteSlider(), // Menggunakan StreamBuilder di dalam sini
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

  // --- 2. BUILDER FAVORIT DENGAN STREAM ---
  Widget _buildFavoriteSlider() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getFavoritesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 180,
            child: Center(
                child: CircularProgressIndicator(color: Color(0xFF63B685))),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200)),
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

        final favorites = snapshot.data!;

        return SizedBox(
          height: 180,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.9),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favItem = favorites[index];
              final resep = favItem['recipe_json'];
              final String imageUrl =
                  favItem['image_url'] ?? ""; // Ambil image dari DB

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailPage(
                          recipeData: resep,
                          imageUrl: imageUrl,
                        ),
                      ),
                    );
                  },
                  child: _buildHeroCard(resep, imageUrl),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeroCard(Map<String, dynamic> resep, String imageUrl) {
    final bool isNetwork = imageUrl.startsWith('http');

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
          // Info Text
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 160,
                  child: Text(resep['nama'] ?? "Resep",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.2)),
                ),
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
          // Gambar di Sebelah Kanan
          Positioned(
            right: 0,
            bottom: 0,
            top: 0,
            width: 140,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(24)),
              child: isNetwork
                  ? Image.network(imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                          Container(color: Colors.white12))
                  : Image.asset(imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                          Container(color: Colors.white12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKitchenInfo() {
    return GestureDetector(
      onTap: () {
        if (widget.onSwitchToKitchen != null) {
          widget.onSwitchToKitchen!();
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const MyKitchenPage()));
        }
      },
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
              child: _buildActionButton("Atur Porsi\n(Resep)", Icons.balance,
                  const Color(0xFFEF9A9A), Colors.red.shade900,
                  onTap: _openLastRecipeDetail)),
          const SizedBox(width: 12),
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

  // --- LOGIC FUNCTIONS ---
  Future<void> _resumeCookingSession() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastRecipeString = prefs.getString('last_cooked_recipe');
    if (lastRecipeString != null) {
      final Map<String, dynamic> recipeData = jsonDecode(lastRecipeString);
      if (mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CookingModeStepsPage(
                    recipeName: recipeData['nama'] ?? "Masakan",
                    steps: recipeData['cara'] ?? [])));
      }
    }
  }

  Future<void> _openLastRecipeDetail() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastRecipeString = prefs.getString('last_cooked_recipe');
    if (lastRecipeString != null) {
      final Map<String, dynamic> recipeData = jsonDecode(lastRecipeString);
      final String img = _findBestImage(recipeData['nama'] ?? "");
      if (mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    RecipeDetailPage(recipeData: recipeData, imageUrl: img)));
      }
    }
  }

  void _openCompostAssistant() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const CompostLandingPage()));
  }

  Future<void> _onCariResepPressed() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const SearchLoadingPage()));
  }
}
