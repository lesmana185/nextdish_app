import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'recipe_detail_page.dart';

class RecipeResultPage extends StatefulWidget {
  final String recipeContent;

  const RecipeResultPage({super.key, required this.recipeContent});

  @override
  State<RecipeResultPage> createState() => _RecipeResultPageState();
}

class _RecipeResultPageState extends State<RecipeResultPage> {
  List<dynamic> _recipes = [];
  Map<String, String> _adminImages = {};

  @override
  void initState() {
    super.initState();
    _parseJsonData();
    _loadAdminImages();
  }

  void _parseJsonData() {
    try {
      var cleanJson =
          widget.recipeContent.replaceAll('```json', '').replaceAll('```', '');
      final parsed = jsonDecode(cleanJson);
      if (parsed is Map && parsed.containsKey('recipes')) {
        _recipes = parsed['recipes'];
      } else if (parsed is List) {
        _recipes = parsed;
      }
      setState(() {});
    } catch (e) {
      debugPrint("Gagal parsing JSON: $e");
    }
  }

  // --- 1. AMBIL DATA GAMBAR DARI SUPABASE ---
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

      if (mounted) {
        setState(() => _adminImages = imageMap);
      }
    } catch (e) {
      debugPrint("Gagal load gambar admin: $e");
    }
  }

  // --- 2. LOGIKA GAMBAR PINTAR (URUTAN: ADMIN -> LOKAL -> INTERNET -> LOGO) ---
  Widget _buildSmartImage(String title) {
    final t = title.toLowerCase();

    // A. CEK DATABASE ADMIN (Prioritas Tertinggi)
    String? adminUrl;
    for (var key in _adminImages.keys) {
      if (t.contains(key)) {
        adminUrl = _adminImages[key];
        break;
      }
    }

    if (adminUrl != null) {
      return Image.network(
        adminUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackLogo(),
      );
    }

    // B. CEK ASET LOKAL (Hanya jika yakin asetnya ada)
    // Pastikan file-file ini BENAR-BENAR ADA di folder assets kamu
    String? localAsset;
    if (t.contains('sate'))
      localAsset = 'assets/images/resep/sate.jpg';
    else if (t.contains('gudeg'))
      localAsset = 'assets/images/resep/gudeg.jpg';
    else if (t.contains('soto'))
      localAsset = 'assets/images/resep/soto.jpg';
    else if (t.contains('nasi goreng'))
      localAsset = 'assets/images/resep/nasigoreng.jpg';
    else if (t.contains('ayam'))
      localAsset = 'assets/images/resep/ayam.jpg';
    else if (t.contains('ikan') || t.contains('lele'))
      localAsset = 'assets/images/resep/ikan.jpg';
    else if (t.contains('telur'))
      localAsset = 'assets/images/ingredients/telur.png';

    if (localAsset != null) {
      return Image.asset(
        localAsset,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildImageFromInternet(title),
      );
    }

    // C. Cek Internet (Jika Admin & Lokal Kosong)
    // Ini solusi agar "Jagung Manis" dapat gambar Jagung, bukan Nasi Goreng
    return _buildImageFromInternet(title);
  }

  // Fungsi ambil gambar dari Internet (AI Pollinations)
  Widget _buildImageFromInternet(String title) {
    // Encode nama makanan agar URL valid
    final String prompt =
        Uri.encodeComponent("$title delicious food photorealistic");
    final String url =
        "https://image.pollinations.ai/prompt/$prompt?nologo=true";

    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey.shade100,
          child: const Center(
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.green))),
        );
      },
      // D. FALLBACK TERAKHIR: LOGO (Sesuai Permintaan)
      // Jika internet mati atau error, pakai LOGO, jangan gambar makanan lain.
      errorBuilder: (context, error, stackTrace) => _buildFallbackLogo(),
    );
  }

  // Widget Gambar Logo (Netral)
  Widget _buildFallbackLogo() {
    return Container(
      color: Colors.white, // Background putih bersih
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Image.asset(
          'assets/images/home/logosmall.png', // Pastikan ini logo kecil NextDish
          fit: BoxFit.contain,
          errorBuilder: (c, e, s) =>
              const Icon(Icons.restaurant, color: Colors.green),
        ),
      ),
    );
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
            child: Icon(Icons.arrow_back, color: Colors.black),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Rekomendasi Menu Spesial",
          style: TextStyle(
            color: Color(0xFF2E7D32),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif',
          ),
        ),
      ),
      body: _recipes.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF63B685)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _recipes.length,
              itemBuilder: (context, index) {
                return _buildRecipeCard(_recipes[index]);
              },
            ),
    );
  }

  Widget _buildRecipeCard(dynamic resep) {
    Color badgeColor = Colors.grey;
    String statusKey = (resep['status'] ?? "").toLowerCase();

    if (statusKey.contains('tersedia')) {
      badgeColor = const Color(0xFF63B685);
    } else if (statusKey.contains('sebagian')) {
      badgeColor = Colors.orange;
    } else {
      badgeColor = const Color(0xFF757575);
    }

    String statusText = resep['status_text'] ?? resep['status'] ?? "Cek Bahan";
    String recipeName = resep['nama'] ?? "Menu Spesial";

    return Container(
      height: 170,
      margin: const EdgeInsets.only(bottom: 25),
      child: Stack(
        alignment: Alignment.centerLeft,
        clipBehavior: Clip.none,
        children: [
          // 1. KOTAK KARTU
          Container(
            height: 160,
            margin: const EdgeInsets.only(right: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 70, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    recipeName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(statusText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(resep['waktu'] ?? "30m",
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                      const SizedBox(width: 10),
                      const Icon(Icons.local_fire_department,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(resep['kalori'] ?? "400cal",
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      RecipeDetailPage(recipeData: resep)));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                              color: const Color(0xFF42A5F5),
                              borderRadius: BorderRadius.circular(20)),
                          child: const Text("Mulai Masak",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      RecipeDetailPage(recipeData: resep)));
                        },
                        child: Text("Lihat Detail",
                            style: TextStyle(
                                color: Colors.orange.shade700,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          // 2. GAMBAR BULAT (DIPERBAIKI)
          Positioned(
            right: 0,
            top: 0,
            bottom: 10,
            child: Container(
              width: 135,
              height: 135,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(5, 5)),
                ],
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: ClipOval(
                // Menggunakan _buildSmartImage yang sudah diperbaiki
                child: _buildSmartImage(recipeName),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
