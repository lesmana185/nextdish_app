import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'recipe_detail_page.dart';

class RecipeResultPage extends StatefulWidget {
  final Map<String, dynamic> recipeContent;

  const RecipeResultPage({super.key, required this.recipeContent});

  @override
  State<RecipeResultPage> createState() => _RecipeResultPageState();
}

class _RecipeResultPageState extends State<RecipeResultPage> {
  List<dynamic> _recipes = [];
  Map<String, String> _galleryCache = {};
  bool _isLoadingImages = true;

  @override
  void initState() {
    super.initState();
    _parseData();
    _loadAdminImages();
  }

  void _parseData() {
    if (widget.recipeContent.containsKey('recipes') &&
        widget.recipeContent['recipes'] != null) {
      setState(() {
        _recipes = widget.recipeContent['recipes'];
      });
    }
  }

  // --- 1. LOAD DATABASE ADMIN ---
  Future<void> _loadAdminImages() async {
    try {
      final resMenu = await Supabase.instance.client
          .from('food_gallery')
          .select('food_name, image_url');

      final Map<String, String> tempMap = {};

      for (var item in resMenu) {
        if (item['food_name'] != null && item['image_url'] != null) {
          // Simpan key dengan huruf kecil
          String key = item['food_name'].toString().toLowerCase().trim();
          tempMap[key] = item['image_url'];
        }
      }

      if (mounted) {
        setState(() {
          _galleryCache = tempMap;
          _isLoadingImages = false;
        });
      }
    } catch (e) {
      print("Error Load Gambar: $e");
      if (mounted) setState(() => _isLoadingImages = false);
    }
  }

  // --- 2. LOGIKA PENCARI GAMBAR CERDAS ---
  String _findBestImage(String title) {
    String cleanTitle = title.toLowerCase().trim();

    // A. Cek Exact Match (Persis Sama)
    if (_galleryCache.containsKey(cleanTitle)) {
      return _galleryCache[cleanTitle]!;
    }

    // B. Cek Partial Match (Mengandung Kata)
    for (var dbKey in _galleryCache.keys) {
      if (cleanTitle.contains(dbKey)) {
        return _galleryCache[dbKey]!;
      }
    }

    // C. KAMUS SINONIM (Manual Mapping) - FITUR BARU
    // Ini menolong jika nama masakan AI beda dikit dengan Database
    if (cleanTitle.contains('lele') ||
        cleanTitle.contains('gurame') ||
        cleanTitle.contains('nila') ||
        cleanTitle.contains('kakap')) {
      if (_galleryCache.containsKey('ikan')) return _galleryCache['ikan']!;
      if (_galleryCache.containsKey('ikan goreng'))
        return _galleryCache['ikan goreng']!;
    }

    if (cleanTitle.contains('bebek') ||
        cleanTitle.contains('dada') ||
        cleanTitle.contains('paha')) {
      if (_galleryCache.containsKey('ayam')) return _galleryCache['ayam']!;
      if (_galleryCache.containsKey('ayam goreng'))
        return _galleryCache['ayam goreng']!;
    }

    if (cleanTitle.contains('telur') ||
        cleanTitle.contains('dadar') ||
        cleanTitle.contains('ceplok') ||
        cleanTitle.contains('omelet')) {
      if (_galleryCache.containsKey('telur')) return _galleryCache['telur']!;
      if (_galleryCache.containsKey('telur balado'))
        return _galleryCache['telur balado']!;
    }

    if (cleanTitle.contains('mie') || cleanTitle.contains('mi')) {
      if (_galleryCache.containsKey('mie')) return _galleryCache['mie']!;
      if (_galleryCache.containsKey('ramen')) return _galleryCache['ramen']!;
    }

    // D. Cek Kata per Kata (Logika Terakhir)
    List<String> words = cleanTitle.split(' ');
    List<String> ignoredWords = [
      'goreng',
      'bakar',
      'rebus',
      'kuah',
      'pedas',
      'manis',
      'spesial',
      'enak',
      'tumis',
      'lada',
      'garam',
      'gula'
    ];

    for (var word in words) {
      if (word.length < 3 || ignoredWords.contains(word)) continue;

      // Cari di cache apakah ada key yang mengandung kata ini
      for (var dbKey in _galleryCache.keys) {
        if (dbKey.contains(word)) {
          return _galleryCache[dbKey]!;
        }
      }
    }

    // E. Fallback Default
    return 'assets/images/menu_book.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.arrow_back, color: Colors.black)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text("Rekomendasi Menu",
            style: TextStyle(
                color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
      ),
      body: _recipes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/menu_book.png', width: 100),
                  const SizedBox(height: 16),
                  const Text("Tidak ada resep ditemukan.",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _recipes.length,
              itemBuilder: (context, index) {
                return _buildRecipeCard(_recipes[index]);
              },
            ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> resep) {
    String name = resep['nama'] ?? "Menu Spesial";
    String status = resep['status'] ?? "Tersedia";

    Color statusColor = status.toLowerCase().contains('tersedia')
        ? const Color(0xFF63B685)
        : Colors.orange;

    // Cari URL gambar terbaik
    final String imageUrl = _findBestImage(name);
    final bool isNetwork = imageUrl.startsWith('http');

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RecipeDetailPage(
                      recipeData: resep,
                      imageUrl: imageUrl, // Oper URL gambar ke detail
                    )));
      },
      child: Container(
        height: 160,
        margin: const EdgeInsets.only(bottom: 25),
        child: Stack(
          alignment: Alignment.centerLeft,
          clipBehavior: Clip.none,
          children: [
            // KARTU PUTIH (Background)
            Container(
              height: 150,
              margin: const EdgeInsets.only(right: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5))
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 90, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(status,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(resep['waktu'] ?? "30 m",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                        const SizedBox(width: 12),
                        const Icon(Icons.local_fire_department_outlined,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(resep['kalori'] ?? "-",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // GAMBAR BULAT (Floating)
            Positioned(
              right: 5,
              top: 10,
              child: Hero(
                tag: name, // Hero tag unik berdasarkan nama menu
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(5, 5))
                    ],
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: ClipOval(
                    child: _buildImageWidget(imageUrl, isNetwork),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET GAMBAR DENGAN CACHE & ERROR HANDLING ---
  Widget _buildImageWidget(String url, bool isNetwork) {
    if (isNetwork) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        // OPTIMASI: CacheWidth mengurangi penggunaan RAM secara drastis
        cacheWidth: 400,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          // Tampilan loading yang lebih bersih (kotak abu + icon)
          return Container(
            color: Colors.grey.shade100,
            child: Center(
              child: Icon(Icons.image, color: Colors.grey.shade300, size: 40),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // Jika link mati/error, tampilkan buku menu
          return Image.asset('assets/images/menu_book.png', fit: BoxFit.cover);
        },
      );
    } else {
      // Untuk gambar aset lokal
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/images/menu_book.png', fit: BoxFit.cover);
        },
      );
    }
  }
}
