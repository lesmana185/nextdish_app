import 'package:flutter/material.dart';
import 'home_complex_page.dart'; // Import Home
import 'recomendation_page.dart'; // Import Rekomendasi
import 'mykitchen_page.dart'; // <--- Import Dapur
import 'comunity_page.dart'; // <--- Import Komunitas
import 'profile_page.dart'; // <--- Import Profil
import 'search_loading_page.dart'; // <--- Import Search Loading

class RecipeSearchPage extends StatefulWidget {
  const RecipeSearchPage({super.key});

  @override
  State<RecipeSearchPage> createState() => _RecipeSearchPageState();
}

class _RecipeSearchPageState extends State<RecipeSearchPage> {
  // Controller untuk menangani input teks dan tombol 'X'
  final TextEditingController _searchController = TextEditingController();

  // Data Dummy Kategori Resep
  final List<Map<String, String>> _allCategories = [
    {'title': 'Mie', 'img': 'assets/images/resep/ramen.jpg'},
    {'title': 'Nasi', 'img': 'assets/images/resep/nasi.jpg'},
    {'title': 'Dessert', 'img': 'assets/images/resep/dessert.jpg'},
    {'title': 'Ayam', 'img': 'assets/images/resep/ayam.jpg'},
    {'title': 'Sup', 'img': 'assets/images/resep/sup.jpeg'},
    {'title': 'Seafood', 'img': 'assets/images/resep/seafood.jpg'},
    {'title': 'Ikan', 'img': 'assets/images/resep/ikan.jpg'},
    {'title': 'Daging Sapi', 'img': 'assets/images/resep/dagingsapi.jpeg'},
    {'title': 'Pasta', 'img': 'assets/images/resep/pasta.jpg'},
    {'title': 'Minuman', 'img': 'assets/images/resep/minuman.jpg'},
  ];

  // List yang akan ditampilkan
  List<Map<String, String>> _foundCategories = [];

  @override
  void initState() {
    super.initState();
    _foundCategories = _allCategories;
  }

  void _runFilter(String keyword) {
    List<Map<String, String>> results = [];
    if (keyword.isEmpty) {
      results = _allCategories;
    } else {
      results = _allCategories
          .where(
            (item) =>
                item['title']!.toLowerCase().contains(keyword.toLowerCase()),
          )
          .toList();
    }

    setState(() {
      _foundCategories = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // KONTEN UTAMA
          Padding(
            padding: const EdgeInsets.only(bottom: 90),
            child: Column(
              children: [
                const SizedBox(height: 50),

                // HEADER
                _buildHeader(),

                const SizedBox(height: 20),

                // SEARCH BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => _runFilter(value),
                      decoration: InputDecoration(
                        hintText: "Cari resep...",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _runFilter('');
                                  setState(() {});
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // KONTEN: GRID ATAU EMPTY STATE
                Expanded(
                  child: _foundCategories.isNotEmpty
                      ? GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.5,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: _foundCategories.length,
                          itemBuilder: (context, index) {
                            return _buildCategoryCard(
                              context,
                              _foundCategories[index]['title']!,
                              _foundCategories[index]['img']!,
                            );
                          },
                        )
                      : _buildEmptyState(),
                ),
              ],
            ),
          ),

          // NAVIGASI BAWAH (SUDAH DIHUBUNGKAN)
          _buildCustomBottomNavBar(context),
        ],
      ),
    );
  }

  // WIDGET: EMPTY STATE
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Image.asset(
            'assets/images/illustrasi/emptyrobot.png',
            height: 220,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.sentiment_dissatisfied,
              size: 150,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Resep tidak ditemukan",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Text(
              "Maaf, kami tidak dapat menemukan resep yang sesuai. Coba kata kunci lain.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET: CARD KATEGORI
  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    String imgPath,
  ) {
    return GestureDetector(
      onTap: () {
        if (title == "Nasi") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecommendationPage(categoryTitle: title),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecommendationPage(categoryTitle: title),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(image: AssetImage(imgPath), fit: BoxFit.cover),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF63B685).withOpacity(0.9),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- REUSED WIDGETS ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage('assets/images/home/profile.png'),
            backgroundColor: Colors.green,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Text(
                    "Hello Christal,",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.notifications_active,
                    color: Colors.amber,
                    size: 18,
                  ),
                ],
              ),
              const Text(
                "Mau masak apa hari ini?",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Column(
            children: [
              Image.asset('assets/images/home/logosmall.png', height: 30),
              const Text(
                "NextDish",
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- NAV BAR TERHUBUNG ---
  Widget _buildCustomBottomNavBar(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 70,
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
                // KE HOME
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const HomeComplexPage(),
                        transitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: _navItem(Icons.home, "Home", false),
                ),

                // KE DAPUR
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const MyKitchenPage(),
                        transitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: _navItem(Icons.shopping_basket, "Dapur Saya", false),
                ),

                const SizedBox(width: 60),

                // KE KOMUNITAS
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const CommunityPage(),
                        transitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: _navItem(Icons.chat_bubble, "Komunitas", false),
                ),

                // KE PROFIL
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const ProfilePage(),
                        transitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: _navItem(Icons.person, "Profil", false),
                ),
              ],
            ),
          ),

          // TOMBOL TENGAH (CARI RESEP) - KARENA SEDANG DI CARI RESEP, BISA RELOAD ATAU DIAM
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: () {
                // Opsional: Reset pencarian atau kembali ke loading search
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const SearchLoadingPage(),
                    transitionDuration: Duration.zero,
                  ),
                );
              },
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
                      Image.asset(
                        'assets/images/home/logosmall.png',
                        height: 30,
                      ),
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
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFF1B5E20) : Colors.white,
          size: 28,
        ),
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
