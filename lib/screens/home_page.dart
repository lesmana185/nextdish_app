import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/ai_recipe_services.dart'; // Pastikan path service benar
import 'recipe_search_page.dart'; // Halaman Loading
import 'recipe_search_page.dart'; // Halaman Hasil AI
import 'chat_ai_page.dart';
import 'cooking_mode_intro_page.dart';
import 'mykitchen_page.dart';
import 'recipe_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = "Chef";
  String? _avatarUrl;

  List<Map<String, dynamic>> _favorites = [];
  bool _isLoadingFav = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadFavorites();
  }

  // Supaya saat kembali dari halaman lain, data favorit ter-update
  void refreshFavorites() {
    _loadFavorites();
  }

  Future<void> _loadUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.userMetadata?['full_name'] ??
            user.email?.split('@')[0] ??
            "Chef";
        _avatarUrl = user.userMetadata?['avatar_url'];
      });
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
          _isLoadingFav = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingFav = false);
    }
  }

  Future<void> _onCariResepPressed() async {
    // Navigasi ke Halaman Loading Search (Robot Masak)
    // Pastikan kamu sudah punya file 'search_loading_page.dart'
    // Jika belum, pakai dialog loading biasa seperti di bawah:

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
            child: CircularProgressIndicator(color: Color(0xFF63B685))));

    try {
      final aiService = AiRecipeService();
      final jsonResult = await aiService.generateRecipeFromKitchen();

      if (mounted) Navigator.pop(context); // Tutup Loading

      if (mounted) {
        // Pindah ke Hasil, dan REFRESH favorit saat kembali
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

  // --- LOGIKA GAMBAR PINTAR (HYBRID: LOKAL + INTERNET) ---
  Widget _buildRecipeImage(String title) {
    // 1. Bersihkan nama masakan biar gampang dicocokkan
    final t = title.toLowerCase();

    // 2. Cek Aset Lokal Dulu (Prioritas Utama - Cepat & Hemat)
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
    else if (t.contains('nasi kebuli'))
      localAsset = 'assets/images/resep/nasikebuli.jpg';
    else if (t.contains('ayam'))
      localAsset = 'assets/images/resep/ayam.jpg';
    else if (t.contains('ikan') || t.contains('lele'))
      localAsset = 'assets/images/resep/ikan.jpg';
    else if (t.contains('telur'))
      localAsset = 'assets/images/ingredients/telur.png';

    // Jika ada di lokal, tampilkan langsung
    if (localAsset != null) {
      return Image.asset(
        localAsset,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200),
      );
    }

    // 3. Jika TIDAK ADA di lokal, PANGGIL API GAMBAR (Pollinations.ai)
    // Kita encode judulnya agar spasi berubah jadi %20 (format URL yang benar)
    // Tambahkan kata kunci "delicious food photorealistic" agar gambarnya bagus
    final String prompt = Uri.encodeComponent(
        "$title delicious food photorealistic high resolution");
    final String magicUrl =
        "https://image.pollinations.ai/prompt/$prompt?nologo=true";

    return Image.network(
      magicUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      // Tampilan saat gambar sedang didownload (Loading)
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey.shade100,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
              color: const Color(0xFF63B685),
            ),
          ),
        );
      },
      // Tampilan jika internet mati / gagal
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, color: Colors.grey, size: 30),
              SizedBox(height: 4),
              Text("No Image",
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // SCAFFOLD DI SINI TANPA NAVBAR (Karena Navbar ada di MainScaffold)
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),

      // Tombol Chat AI Melayang
      floatingActionButton: FloatingActionButton.extended(
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 100),
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
            const SizedBox(height: 24),
            const Text("Rekomendasi Populer 🔥",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildRecommendationList(),
          ],
        ),
      ),
    );
  }

  // --- WIDGET PECAHAN ---

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
              onBackgroundImageError: (_, __) {},
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
    if (_isLoadingFav) return const Center(child: CircularProgressIndicator());
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

              // --- DISINI KITA PANGGIL WIDGET GAMBAR PINTAR TADI ---
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
              child: _buildActionButton("Mode Masak", Icons.mic,
                  const Color(0xFF90CAF9), Colors.blue.shade900,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CookingModeIntroPage()))))
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _buildActionButton("Atur Porsi", Icons.balance,
                  const Color(0xFFEF9A9A), Colors.red.shade900)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildActionButton("Composite\nAssistant", Icons.recycling,
                  const Color(0xFFA5D6A7), Colors.green.shade900))
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

  Widget _buildRecommendationList() {
    // REKOMENDASI POPULER (DUMMY TAPI DETAIL)
    // Format datanya sudah disesuaikan agar kompatibel dengan Detail Page baru
    final List<Map<String, dynamic>> popularRecipes = [
      {
        "nama": "Sate Ayam Madura",
        "waktu": "45m",
        "kalori": "350 kkal",
        "status": "Tersedia",
        "bahan_utama": ["500gr Daging Ayam (Potong dadu)", "Tusuk Sate"],
        "bumbu": [
          "200gr Kacang Tanah (Goreng)",
          "5 sdm Kecap Manis",
          "3 siung Bawang Putih",
          "4 butir Kemiri"
        ],
        "cara": [
          "1. Haluskan semua bahan bumbu kacang...",
          "2. Tusuk daging ayam dengan tusuk sate...",
          "3. Lumuri sate dengan bumbu, lalu bakar hingga matang."
        ]
      },
      {
        "nama": "Soto Ayam",
        "waktu": "40m",
        "kalori": "300 kkal",
        "status": "Tersedia",
        "bahan_utama": [
          "1/2 Ekor Ayam",
          "Soun (Rendam air panas)",
          "Tauge",
          "Telur Rebus"
        ],
        "bumbu": [
          "2 batang Serai",
          "3 lembar Daun Jeruk",
          "1 ruas Kunyit",
          "1 ruas Jahe"
        ],
        "cara": [
          "1. Rebus ayam hingga empuk...",
          "2. Tumis bumbu halus hingga harum...",
          "3. Masukkan bumbu ke rebusan ayam, masak hingga meresap."
        ]
      },
      {
        "nama": "Gudeg Jogja",
        "waktu": "60m",
        "kalori": "500 kkal",
        "status": "Tersedia",
        "bahan_utama": ["1 kg Nangka Muda (Potong)", "3 butir Telur Rebus"],
        "bumbu": [
          "500ml Santan Kental",
          "200gr Gula Merah",
          "5 lembar Daun Salam",
          "Lengkuas"
        ],
        "cara": [
          "1. Masukkan semua bahan dan bumbu ke dalam panci...",
          "2. Masak dengan api kecil selama 2-3 jam hingga kuah menyusut dan nangka empuk."
        ]
      },
      // Data dummy ini tidak punya foto di lokal, jadi dia akan
      // otomatis menarik gambar dari internet menggunakan fungsi _buildRecipeImage
      {
        "nama": "Seblak Bandung",
        "waktu": "15m",
        "kalori": "450 kkal",
        "status": "Tersedia",
        "bahan_utama": ["Kerupuk Kanji", "Telur"],
        "bumbu": ["Kencur", "Bawang Putih", "Cabai Rawit", "Garam"],
        "cara": [
          "1. Rendam kerupuk...",
          "2. Tumis bumbu halus...",
          "3. Masukkan kerupuk dan air."
        ]
      },
    ];

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: popularRecipes.length,
        itemBuilder: (context, index) {
          final resep = popularRecipes[index];
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

              // --- INI KUNCINYA: Mini Card juga pakai gambar internet ---
              child: _buildMiniCard(resep['nama']),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniCard(String title) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                // PANGGIL GAMBAR PINTAR
                child: _buildRecipeImage(title))),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis))
      ]),
    );
  }
}
