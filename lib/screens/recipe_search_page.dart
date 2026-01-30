import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'recipe_detail_page.dart'; // Pastikan import halaman detail

class RecipeResultPage extends StatefulWidget {
  final Map<String, dynamic>
      recipeContent; // Menerima JSON { "recipes": [...] }

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
    _parseData();
    _loadAdminImages();
  }

  void _parseData() {
    // Ambil list dari key "recipes"
    if (widget.recipeContent.containsKey('recipes')) {
      setState(() {
        _recipes = widget.recipeContent['recipes'];
      });
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
    } catch (e) {}
  }

  // --- LOGIKA GAMBAR PINTAR ---
  Widget _buildSmartImage(String title) {
    final t = title.toLowerCase();

    // 1. Cek Admin
    for (var key in _adminImages.keys) {
      if (t.contains(key)) return _netImage(_adminImages[key]!);
    }

    // 2. Cek Lokal
    String? local;
    if (t.contains('sate'))
      local = 'assets/images/resep/sate.jpg';
    else if (t.contains('gudeg'))
      local = 'assets/images/resep/gudeg.jpg';
    else if (t.contains('soto'))
      local = 'assets/images/resep/soto.jpg';
    else if (t.contains('nasi goreng'))
      local = 'assets/images/resep/nasigoreng.jpg';
    else if (t.contains('ayam'))
      local = 'assets/images/resep/ayam.jpg';
    else if (t.contains('ikan'))
      local = 'assets/images/resep/ikan.jpg';
    else if (t.contains('telur')) local = 'assets/images/ingredients/telur.png';

    if (local != null)
      return Image.asset(local, fit: BoxFit.cover, height: 135, width: 135);

    // 3. Internet (Pollinations)
    final prompt = Uri.encodeComponent("$title food");
    return _netImage(
        "https://image.pollinations.ai/prompt/$prompt?nologo=true");
  }

  Widget _netImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      height: 135,
      width: 135,
      loadingBuilder: (c, child, p) =>
          p == null ? child : Container(color: Colors.grey.shade100),
      errorBuilder: (c, e, s) =>
          Image.asset('assets/images/home/logosmall.png', fit: BoxFit.contain),
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
              child: Icon(Icons.arrow_back, color: Colors.black)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text("Rekomendasi Menu",
            style: TextStyle(
                color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
      ),
      body: _recipes.isEmpty
          ? const Center(child: Text("Tidak ada resep ditemukan."))
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

    return GestureDetector(
      onTap: () {
        // NAVIGASI KE DETAIL SAAT CARD DIKLIK
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RecipeDetailPage(recipeData: resep)));
      },
      child: Container(
        height: 160,
        margin: const EdgeInsets.only(bottom: 25),
        child: Stack(
          alignment: Alignment.centerLeft,
          clipBehavior: Clip.none,
          children: [
            // KARTU PUTIH
            Container(
              height: 150,
              margin: const EdgeInsets.only(right: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5))
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 70, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(status,
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
                        Text(resep['waktu'] ?? "-",
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                        const SizedBox(width: 10),
                        const Icon(Icons.local_fire_department,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(resep['kalori'] ?? "-",
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    const Spacer(),
                    Text("Lihat Detail >",
                        style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            // GAMBAR BULAT DI KANAN
            Positioned(
              right: 0,
              top: 0,
              bottom: 10,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(5, 5))
                  ],
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: ClipOval(child: _buildSmartImage(name)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
