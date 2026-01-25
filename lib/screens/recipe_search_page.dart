import 'dart:convert';
import 'package:flutter/material.dart';
import 'recipe_detail_page.dart';

class RecipeResultPage extends StatefulWidget {
  final String recipeContent;

  const RecipeResultPage({super.key, required this.recipeContent});

  @override
  State<RecipeResultPage> createState() => _RecipeResultPageState();
}

class _RecipeResultPageState extends State<RecipeResultPage> {
  List<dynamic> _recipes = [];

  @override
  void initState() {
    super.initState();
    _parseJsonData();
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

  // --- LOGIKA GAMBAR PINTAR (DIPERLUAS) ---
  String _getImageAsset(String title) {
    final t = title.toLowerCase();

    // Mapping Manual ke Aset yang mungkin kamu punya
    // Pastikan file-file ini ada di folder assets kamu, kalau tidak dia akan pakai default
    if (t.contains('sate'))
      return 'assets/images/resep/sate.jpg'; // Harap sediakan gambar sate
    if (t.contains('gudeg')) return 'assets/images/resep/gudeg.jpg';
    if (t.contains('soto')) return 'assets/images/resep/soto.jpg';
    if (t.contains('rendang')) return 'assets/images/resep/dagingsapi.jpeg';

    if (t.contains('nasi goreng')) return 'assets/images/resep/nasigoreng.jpg';
    if (t.contains('nasi liwet')) return 'assets/images/resep/nasiliwet.jpg';
    if (t.contains('nasi kebuli')) return 'assets/images/resep/nasikebuli.jpg';
    if (t.contains('nasi')) return 'assets/images/resep/nasi.jpg';

    if (t.contains('ayam')) return 'assets/images/resep/ayam.jpg';
    if (t.contains('ikan') || t.contains('lele'))
      return 'assets/images/resep/ikan.jpg';
    if (t.contains('telur')) return 'assets/images/ingredients/telur.png';

    return 'assets/images/home/bannerfood.png'; // Gambar Default
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
            backgroundColor: Colors.grey,
            child: Icon(Icons.arrow_back, color: Colors.white),
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
          ? const Center(child: CircularProgressIndicator())
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
    // Logika Warna Badge Berdasarkan Status
    Color badgeColor = Colors.grey;
    String statusKey = (resep['status'] ?? "").toLowerCase();

    if (statusKey.contains('tersedia')) {
      badgeColor = const Color(0xFF63B685); // Hijau
    } else if (statusKey.contains('sebagian')) {
      badgeColor = Colors.orange; // Kuning/Oranye
    } else {
      badgeColor = const Color(0xFF757575); // Abu-abu (Tidak tersedia)
    }

    // Jika AI kasih status text yang panjang, kita pakai, kalau tidak pake default
    String statusText = resep['status_text'] ?? resep['status'] ?? "Cek Bahan";

    return Container(
      height: 170,
      margin: const EdgeInsets.only(bottom: 25),
      child: Stack(
        alignment: Alignment.centerLeft,
        clipBehavior: Clip.none, // Biar gambar bisa menonjol keluar
        children: [
          // 1. KOTAK KARTU
          Container(
            height: 160,
            margin: const EdgeInsets.only(right: 30), // Ruang untuk gambar
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 70, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nama Resep
                  Text(
                    resep['nama'] ?? "Menu Spesial",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Badge Status
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Info Waktu & Kalori
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

                  // Tombol Aksi
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Siap memasak ${resep['nama']}!")));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF42A5F5),
                            borderRadius: BorderRadius.circular(20),
                          ),
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
                                  RecipeDetailPage(recipeData: resep),
                            ),
                          );
                        },
                        child: Text(
                          "Lihat Detail",
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          // 2. GAMBAR BULAT (BESAR & MENONJOL)
          Positioned(
            right: 0,
            top: 0,
            bottom: 10,
            child: Container(
              width: 135,
              height: 135,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(5, 5),
                  ),
                ],
                border: Border.all(color: Colors.white, width: 4),
                image: DecorationImage(
                  image: AssetImage(_getImageAsset(resep['nama'] ?? "")),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
