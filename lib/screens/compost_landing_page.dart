import 'package:flutter/material.dart';
import 'compost_guide_page.dart'; // File halaman selanjutnya
import 'home_page.dart'; // Untuk Nav Bar

class CompostLandingPage extends StatefulWidget {
  const CompostLandingPage({super.key});

  @override
  State<CompostLandingPage> createState() => _CompostLandingPageState();
}

class _CompostLandingPageState extends State<CompostLandingPage> {
  // Data Dummy sesuai gambar
  final List<Map<String, dynamic>> _wasteItems = [
    {
      "name": "Susu",
      "status": "Expired", // Merah
      "img": "assets/images/ingredients/susu.png",
      "selected": true,
    },
    {
      "name": "Cangkang Telur",
      "status": "Sampah", // Merah
      "img": "assets/images/ingredients/telur.png", // Pakai aset telur yg ada
      "selected": true,
    },
    {
      "name": "Pisang",
      "status": "Expired", // Merah
      "img": "assets/images/ingredients/pisang.png",
      "selected": false, // Ceritanya tidak dipilih
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Hitung item terpilih
    int selectedCount = _wasteItems.where((e) => e['selected']).length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF63B685),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Compost Assistant",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset(
              'assets/images/illustrasi/robotmic.png',
              height: 35,
            ), // Robot icon
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Kelola sisa makanan dengan bijak",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),
                const Center(
                  child: Text(
                    "Terdeteksi dari dapur kamu",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 16),

                // LIST ITEM
                Expanded(
                  child: ListView.builder(
                    itemCount: _wasteItems.length,
                    itemBuilder: (context, index) {
                      final item = _wasteItems[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            item['selected'] = !item['selected'];
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: item['selected']
                                ? const Color(0xFFE8F5E9)
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: item['selected']
                                ? Border.all(color: Colors.green.shade200)
                                : Border.all(color: Colors.transparent),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                item['img'],
                                width: 50,
                                height: 50,
                                errorBuilder: (c, e, s) => const Icon(
                                  Icons.delete,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  item['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF5350), // Merah
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  item['status'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // TOMBOL LANJUTKAN
          Positioned(
            bottom: 120, // Di atas navbar
            left: 20,
            right: 20,
            child: SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: selectedCount > 0
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CompostGuidePage(),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38A169),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  "Lanjutkan ($selectedCount item)",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // NAV BAR
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildCustomBottomNavBar(context),
          ),
        ],
      ),
    );
  }

  // --- REUSED NAV BAR ---
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
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomePage()),
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
