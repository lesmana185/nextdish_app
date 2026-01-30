import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cooking_mode_intro_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../main_scaffold.dart'; // Import ini untuk akses MainScaffold

class RecipeDetailPage extends StatefulWidget {
  final Map<String, dynamic> recipeData;

  const RecipeDetailPage({super.key, required this.recipeData});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  int _portionCount = 1;
  bool _isFavorite = false;
  bool _isLoadingFav = true;
  Map<String, String> _adminImages = {};

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _loadAdminImages();
  }

  // Ambil gambar admin untuk konsistensi
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
    } catch (e) {/* Silent error */}
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
      if (mounted) setState(() => _isLoadingFav = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Login dulu ya!")));
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
      } else {
        await Supabase.instance.client
            .from('favorite_recipes')
            .delete()
            .eq('user_id', user.id)
            .eq('recipe_name', widget.recipeData['nama']);
      }
    } catch (e) {
      setState(() => _isFavorite = !_isFavorite);
    }
  }

  // --- LOGIKA GAMBAR KONSISTEN ---
  Widget _buildHeaderImage(String title) {
    final t = title.toLowerCase();

    // 1. Cek Admin
    for (var key in _adminImages.keys) {
      if (t.contains(key)) return _buildNetImage(_adminImages[key]!);
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
    else if (t.contains('ikan')) local = 'assets/images/resep/ikan.jpg';

    if (local != null)
      return Image.asset(local,
          fit: BoxFit.cover, width: double.infinity, height: 350);

    // 3. Fallback Pollinations
    final prompt = Uri.encodeComponent("$title food 4k");
    return _buildNetImage(
        "https://image.pollinations.ai/prompt/$prompt?nologo=true");
  }

  Widget _buildNetImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 350,
      loadingBuilder: (c, child, p) =>
          p == null ? child : Container(color: Colors.grey.shade200),
      errorBuilder: (c, e, s) =>
          Image.asset('assets/images/home/bannerfood.png', fit: BoxFit.cover),
    );
  }

  void _increment() => setState(() => _portionCount++);
  void _decrement() => setState(() {
        if (_portionCount > 1) _portionCount--;
      });

  @override
  Widget build(BuildContext context) {
    final String title = widget.recipeData['nama'] ?? "Resep Spesial";
    final List<dynamic> ingredients = widget.recipeData['bahan'] ?? [];
    final List<dynamic> steps = widget.recipeData['cara'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: Stack(
        children: [
          // GAMBAR
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 350,
              child: _buildHeaderImage(title)),

          // TOMBOL BACK & GRADIENT
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 100,
              child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black54, Colors.transparent])))),
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.arrow_back, color: Colors.black)),
            ),
          ),

          // KONTEN
          Positioned.fill(
            top: 280,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
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
                    _sectionTitle(Icons.kitchen, "Bahan-bahan"),
                    ...ingredients.map((item) => _dynamicIng(item.toString())),
                    const SizedBox(height: 24),
                    _sectionTitle(Icons.menu_book, "Cara Memasak"),
                    ...steps
                        .asMap()
                        .entries
                        .map((e) => _stepItem(e.key + 1, e.value.toString())),
                  ],
                ),
              ),
            ),
          ),

          // PORSI ADJUSTER
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
                      BoxShadow(color: Colors.black12, blurRadius: 10)
                    ]),
                child: Row(children: [
                  Expanded(
                      child: InkWell(
                          onTap: _decrement,
                          child:
                              const Icon(Icons.remove, color: Colors.green))),
                  Text("$_portionCount Porsi",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                      child: InkWell(
                          onTap: _increment,
                          child: const Icon(Icons.add, color: Colors.green))),
                ]),
              ),
            ),
          ),

          // SIDE BUTTONS
          Positioned(
            top: 310,
            right: 20,
            child: Column(children: [
              GestureDetector(
                onTap: _toggleFavorite,
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFEF5350),
                  child: _isLoadingFav
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => CookingModeIntroPage(
                              recipeData: widget.recipeData)));
                },
                child: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF42A5F5),
                    child: Icon(Icons.mic, color: Colors.white)),
              ),
            ]),
          ),

          // NAVBAR (Panggil MainScaffold dengan index Dapur)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 70,
              decoration: const BoxDecoration(
                  color: Color(0xFF63B685),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(30))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navBtn(
                      Icons.home,
                      "Home",
                      () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const MainScaffold(initialIndex: 0)),
                          (r) => false)),
                  _navBtn(
                      Icons.shopping_basket,
                      "Dapur",
                      () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const MainScaffold(initialIndex: 1)),
                          (r) => false)),
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

  Widget _sectionTitle(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Icon(icon, color: Colors.green),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
      ]));

  Widget _dynamicIng(String text) {
    // Logic Porsi Sederhana: Kalikan angka pertama yang ditemukan
    String display = text.replaceAllMapped(RegExp(r'(\d+)'),
        (m) => (int.parse(m.group(0)!) * _portionCount).toString());
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(display))
        ]));
  }

  Widget _stepItem(int num, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(
            radius: 14,
            backgroundColor: Colors.green,
            child: Text("$num",
                style: const TextStyle(color: Colors.white, fontSize: 12))),
        const SizedBox(width: 12),
        Expanded(
            child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300)),
                child: Text(text)))
      ]));

  Widget _navBtn(IconData icon, String label, VoidCallback onTap) =>
      GestureDetector(
          onTap: onTap,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: Colors.white),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 10))
          ]));
}
