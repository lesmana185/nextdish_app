import 'package:flutter/material.dart';
import 'home_page.dart'; // Pastikan import Home yang baru
import 'recipe_detail_page.dart'; // Import halaman detail

// Model Data Resep (Kita lengkapi dengan bahan & cara)
class Recipe {
  final String name;
  final String status;
  final String statusText;
  final String time;
  final String calories;
  final String imagePath;
  // Tambahan data agar Halaman Detail tidak error
  final List<String> bahan;
  final List<String> cara;

  Recipe({
    required this.name,
    required this.status,
    required this.statusText,
    required this.time,
    required this.calories,
    required this.imagePath,
    required this.bahan,
    required this.cara,
  });
}

class RecommendationPage extends StatelessWidget {
  final String categoryTitle;

  const RecommendationPage({super.key, required this.categoryTitle});

  @override
  Widget build(BuildContext context) {
    // Ambil padding bawah aman (Safe Area)
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    // DATA DUMMY (Lengkap dengan Bahan & Cara)
    final List<Recipe> recipes = [
      Recipe(
        name: "Nasi Liwet",
        status: 'Tersedia',
        statusText: "Semua Bahan Tersedia",
        time: "45 Menit",
        calories: "500 kkal",
        imagePath: "assets/images/rekomendasi/nasiliwet.jpg",
        bahan: [
          "Beras (2 cup)",
          "Santan (500ml)",
          "Sereh (2 batang, geprek)",
          "Daun salam (3 lembar)",
          "Ikan teri (secukupnya)",
          "Garam & Penyedap"
        ],
        cara: [
          "Cuci beras hingga bersih.",
          "Masukkan beras, santan, sereh, daun salam, dan garam ke panci kastrol/rice cooker.",
          "Masak hingga matang.",
          "Goreng ikan teri, taburkan di atas nasi liwet yang sudah matang.",
          "Sajikan hangat dengan sambal dan lalapan."
        ],
      ),
      Recipe(
        name: "Nasi Goreng Spesial",
        status: 'Sebagian',
        statusText: "2/5 Bahan Tersedia",
        time: "20 Menit",
        calories: "400 kkal",
        imagePath: "assets/images/rekomendasi/nasigoreng.jpg",
        bahan: [
          "Nasi putih (1 piring)",
          "Bawang merah (3 siung)",
          "Bawang putih (2 siung)",
          "Telur (1 butir)",
          "Kecap manis",
          "Sosis/Bakso (opsional)"
        ],
        cara: [
          "Tumis bawang merah dan putih hingga harum.",
          "Masukkan telur, buat orak-arik.",
          "Masukkan nasi putih, aduk rata.",
          "Tambahkan kecap, garam, dan penyedap.",
          "Masak hingga matang merata."
        ],
      ),
      Recipe(
        name: "Nasi Kebuli",
        status: 'Kosong',
        statusText: "Bahan Tidak Tersedia",
        time: "60 Menit",
        calories: "600 kkal",
        imagePath: "assets/images/rekomendasi/Nasikebuli.jpg",
        bahan: [
          "Beras Basmati (500gr)",
          "Daging Kambing/Sapi (300gr)",
          "Bumbu Kebuli Instan",
          "Susu Cair (200ml)",
          "Kismis (secukupnya)"
        ],
        cara: [
          "Tumis bumbu kebuli dan daging hingga berubah warna.",
          "Masukkan air dan susu, masak hingga daging empuk.",
          "Masukkan beras basmati yang sudah dicuci.",
          "Aron nasi hingga air menyusut, lalu kukus hingga matang.",
          "Sajikan dengan taburan kismis."
        ],
      ),
      Recipe(
        name: "Nasi Bakar Ayam",
        status: 'Tersedia',
        statusText: "Semua Bahan Tersedia",
        time: "40 Menit",
        calories: "450 kkal",
        imagePath: "assets/images/rekomendasi/nasigoreng.jpg",
        bahan: [
          "Nasi putih matang",
          "Daun pisang",
          "Ayam suwir kemangi",
          "Tusuk gigi"
        ],
        cara: [
          "Siapkan daun pisang, tata nasi di atasnya.",
          "Isi tengah nasi dengan ayam suwir kemangi.",
          "Gulung dan sematkan lidi di kedua ujung.",
          "Bakar di atas teflon hingga daun kecoklatan dan wangi.",
          "Sajikan."
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // KONTEN UTAMA
          Column(
            children: [
              const SizedBox(height: 50),

              // HEADER CUSTOM
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/home/logosmall.png',
                      height: 40,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.fastfood, color: Colors.green),
                    ),
                    const Text(
                      "NextDish",
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back,
                                color: Colors.white, size: 20),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Rekomendasi Menu $categoryTitle",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18, // Sedikit dikecilkan biar muat
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                              fontFamily: 'Serif',
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // LIST RESEP
              Expanded(
                child: ListView.builder(
                  padding:
                      EdgeInsets.only(bottom: 120 + bottomPadding, top: 10),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    return _buildRecipeCard(context, recipes[index]);
                  },
                ),
              ),
            ],
          ),

          // NAVIGASI BAWAH
          _buildCustomBottomNavBar(context),
        ],
      ),
    );
  }

  // WIDGET KARTU RESEP
  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    Color badgeColor;
    if (recipe.status == 'Tersedia') {
      badgeColor = const Color(0xFF7CB342);
    } else if (recipe.status == 'Sebagian') {
      badgeColor = const Color(0xFFE53935);
    } else {
      badgeColor = const Color(0xFF757575);
    }

    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          // 1. KOTAK PUTIH (CONTENT)
          Container(
            margin: const EdgeInsets.only(right: 40),
            padding: const EdgeInsets.fromLTRB(20, 12, 60, 12),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  recipe.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    recipe.statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      recipe.time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.local_fire_department,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      recipe.calories,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // TOMBOL AKSI (DIPERBAIKI AGAR SESUAI DATA JSON)
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _goToDetail(context, recipe);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF42A5F5),
                        minimumSize: const Size(0, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Mulai Masak",
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        _goToDetail(context, recipe);
                      },
                      child: const Text(
                        "Lihat Detail",
                        style: TextStyle(
                          color: Color(0xFFFFA726),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. GAMBAR BULAT
          Positioned(
            right: 0,
            top: -10,
            bottom: -10,
            child: Container(
              width: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(4, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 65,
                backgroundImage: AssetImage(recipe.imagePath),
                backgroundColor: Colors.grey.shade200,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk pindah ke Halaman Detail dengan Data JSON Buatan
  void _goToDetail(BuildContext context, Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // Kita bungkus data dummy menjadi Map JSON
        // Agar diterima oleh RecipeDetailPage yang baru
        builder: (context) => RecipeDetailPage(
          recipeData: {
            'nama': recipe.name,
            'waktu': recipe.time,
            'kalori': recipe.calories,
            'status': recipe.statusText,
            'bahan': recipe.bahan,
            'cara': recipe.cara,
          },
        ),
      ),
    );
  }

  // --- NAV BAR ---
  Widget _buildCustomBottomNavBar(BuildContext context) {
    final double safeAreaBottom = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: 100 + safeAreaBottom,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 70 + safeAreaBottom,
            padding: EdgeInsets.only(bottom: safeAreaBottom),
            decoration: const BoxDecoration(
              color: Color(0xFF63B685),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  // UPDATE: Pindah ke HomeComplexPage
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  ),
                  child: _navItem(Icons.home, "Home", false),
                ),
                _navItem(Icons.shopping_basket, "Dapur Saya", false),
                const SizedBox(width: 60),
                _navItem(Icons.chat_bubble, "Komunitas", false),
                _navItem(Icons.person, "Profil", false),
              ],
            ),
          ),

          // Tombol Tengah
          Positioned(
            top: 0,
            child: Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(5),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF63B685),
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/home/logosmall.png', height: 30),
                    const Text(
                      "Cari resep",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon,
            color: isActive ? const Color(0xFF1B5E20) : Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF1B5E20) : Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
