import 'package:flutter/material.dart';
import 'home_complex_page.dart';
import 'select_ingredients_page.dart';
import 'search_loading_page.dart'; // Import Search
import 'chat_ai_page.dart'; // Import Chat AI
import 'comunity_page.dart'; // Import Komunitas
import 'profile_page.dart'; // Import Profil
import 'compost_landing_page.dart';

// Model Data Bahan
class KitchenIngredient {
  final String name;
  final String quantity;
  final String expiryInfo;
  final String imagePath;
  final bool isExpired;
  final bool isNearExpiry;
  bool isSelected;

  KitchenIngredient({
    required this.name,
    required this.quantity,
    required this.expiryInfo,
    required this.imagePath,
    this.isExpired = false,
    this.isNearExpiry = false,
    this.isSelected = false,
  });
}

class MyKitchenPage extends StatefulWidget {
  const MyKitchenPage({super.key});

  @override
  State<MyKitchenPage> createState() => _MyKitchenPageState();
}

class _MyKitchenPageState extends State<MyKitchenPage> {
  // --- STATE DATA ---
  final List<KitchenIngredient> _myIngredients = [];

  int _currentTab = 0; // 0 = Segar, 1 = Basi

  List<KitchenIngredient> get _freshList =>
      _myIngredients.where((i) => !i.isExpired && !i.isNearExpiry).toList();
  List<KitchenIngredient> get _spoiledList =>
      _myIngredients.where((i) => i.isExpired || i.isNearExpiry).toList();

  int get _totalSelected => _myIngredients.where((i) => i.isSelected).length;

  void _addDummyIngredient() {
    setState(() {
      _myIngredients.addAll([
        KitchenIngredient(
          name: "Ayam",
          quantity: "5 potong",
          expiryInfo: "Exp 5 hari lagi",
          imagePath: "assets/images/ingredients/ayam.png",
        ),
        KitchenIngredient(
          name: "Telur",
          quantity: "12 butir",
          expiryInfo: "Exp 13 hari lagi",
          imagePath: "assets/images/ingredients/telur.png",
          isSelected: true,
        ),
        KitchenIngredient(
          name: "Susu",
          quantity: "1 liter",
          expiryInfo: "Expired",
          imagePath: "assets/images/ingredients/susu.png",
          isExpired: true,
        ),
        KitchenIngredient(
          name: "Keju",
          quantity: "1 balok",
          expiryInfo: "Exp 1 hari lagi",
          imagePath: "assets/images/ingredients/keju.png",
          isNearExpiry: true,
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isEmpty = _myIngredients.isEmpty;

    return Scaffold(
      backgroundColor: isEmpty ? Colors.white : const Color(0xFFFAFAFA),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // KONTEN UTAMA
          isEmpty ? _buildEmptyState() : _buildFilledState(),

          // 2. CHAT AI FLOATING BUTTON (DIHUBUNGKAN)
          // Hanya muncul jika list kosong (agar tidak menumpuk di list)
          // atau bisa dimunculkan terus sesuai selera.
          if (isEmpty)
            Positioned(
              right: 20,
              bottom: 110,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatAIPage()),
                  );
                },
                child: _buildChatAIButton(),
              ),
            ),

          // NAVIGASI BAWAH
          _buildCustomBottomNavBar(context),
        ],
      ),
    );
  }

  // TAMPILAN 1: EMPTY STATE
  Widget _buildEmptyState() {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 15),
            child: Center(
              child: Text(
                "Dapur Saya",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
        const Divider(thickness: 1, color: Colors.grey),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Image.asset(
                  'assets/images/dapur/kitchen.jpg', // Pastikan aset benar
                  height: 250,
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) =>
                      const Icon(Icons.kitchen, size: 100, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Belum ada bahan di dapur",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A4A4A),
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () => _showAddOptionModal(context),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  height: 55,
                  decoration: BoxDecoration(
                    color: const Color(0xFF38A169),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add, color: Colors.white, size: 28),
                      SizedBox(width: 8),
                      Text(
                        "Tambah Bahan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  // TAMPILAN 2: FILLED STATE
  Widget _buildFilledState() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(
            top: 50,
            bottom: 15,
            left: 20,
            right: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Dapur Saya",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
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
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  0,
                  "${_freshList.length} Segar",
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTabButton(
                  1,
                  "${_spoiledList.length} Hampir Basi",
                  Colors.redAccent,
                  Icons.warning,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 160),
                child: Column(
                  children: [
                    if (_currentTab == 1 && _spoiledList.isNotEmpty)
                      _buildWarningBanner(),
                    if (_currentTab == 0)
                      ..._freshList
                          .map((item) => _buildIngredientCard(item))
                          .toList()
                    else
                      ..._spoiledList
                          .map((item) => _buildIngredientCard(item))
                          .toList(),
                    if ((_currentTab == 0 && _freshList.isEmpty) ||
                        (_currentTab == 1 && _spoiledList.isEmpty))
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Text(
                          "Tidak ada bahan di kategori ini",
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                bottom: 110,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _myIngredients.clear();
                        });
                      },
                      child: Container(
                        height: 50,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: Colors.grey.shade700,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Hapus",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 45,
                      width: 45,
                      decoration: const BoxDecoration(
                        color: Color(0xFF38A169),
                        shape: BoxShape.circle,
                      ),
                      child: GestureDetector(
                        onTap: () => _showAddOptionModal(context),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),

                    // TOMBOL CARI RESEP (HIJAU) - DIHUBUNGKAN KE SEARCH
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchLoadingPage(),
                          ),
                        );
                      },
                      child: Container(
                        height: 50,
                        width: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFF38A169),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Cari Resep\n($_totalSelected bahan)",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // WIDGET HELPERS
  Widget _buildTabButton(int index, String text, Color color, IconData icon) {
    bool isActive = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isActive ? null : Border.all(color: Colors.grey.shade300),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? Colors.white : color, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFECB3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber,
            size: 36,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Ada bahan yang perlu ditangani",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  "Susu & Cangkang telur terdeteksi",
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),

          // --- IKON COMPOST YANG BISA DIKLIK ---
          GestureDetector(
            onTap: () {
              // Navigasi ke Halaman Compost Landing Page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CompostLandingPage(),
                ),
              );
            },
            child: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              radius: 14,
              child: Image.asset(
                'assets/images/icons/compost.png',
                width: 18,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.eco, size: 18, color: Colors.green),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientCard(KitchenIngredient item) {
    Color bgColor = item.isExpired
        ? const Color(0xFFFFEBEE)
        : (item.isNearExpiry
              ? const Color(0xFFFFFDE7)
              : (item.isSelected ? const Color(0xFFE8F5E9) : Colors.white));
    Color expColor = item.isExpired ? Colors.red : Colors.grey;
    return GestureDetector(
      onTap: () => setState(() => item.isSelected = !item.isSelected),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              item.imagePath,
              width: 50,
              height: 50,
              errorBuilder: (c, e, s) => Icon(Icons.fastfood, size: 40),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      children: [
                        TextSpan(
                          text: "${item.quantity}  •  ",
                          style: TextStyle(color: Colors.orange.shade700),
                        ),
                        TextSpan(
                          text: item.expiryInfo,
                          style: TextStyle(
                            color: expColor,
                            fontWeight: item.isExpired
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: item.isSelected ? const Color(0xFF63B685) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: item.isSelected
                      ? const Color(0xFF63B685)
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: item.isSelected
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // MODAL LOGIC
  void _showAddOptionModal(BuildContext context) {
    String selectedOption = 'manual';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.chevron_left, size: 32),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Pilih cara tambah",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildOptionButton(
                    title: "Ketik Manual",
                    subtitle: "Input bahan secara manual",
                    icon: Icons.edit_note,
                    isSelected: selectedOption == 'manual',
                    onTap: () async {
                      setState(() => selectedOption = 'manual');
                      await Future.delayed(const Duration(milliseconds: 200));
                      if (context.mounted) {
                        Navigator.pop(context);
                        _showManualInputModal(context);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildOptionButton(
                    title: "Pilih dari daftar",
                    subtitle: "Pilih bahan dari daftar",
                    icon: Icons.checklist_rtl,
                    isSelected: selectedOption == 'list',
                    onTap: () async {
                      setState(() => selectedOption = 'list');
                      await Future.delayed(const Duration(milliseconds: 200));
                      if (context.mounted) {
                        Navigator.pop(context);
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectIngredientsPage(
                              onManualInputRequest: () {
                                Future.delayed(
                                  const Duration(milliseconds: 200),
                                  () {
                                    _showManualInputModal(context);
                                  },
                                );
                              },
                            ),
                          ),
                        );
                        if (result == true) {
                          _addDummyIngredient();
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showManualInputModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(Icons.chevron_left, size: 32),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Nama Bahan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(hint: "Contoh : Telur"),
                  const SizedBox(height: 20),
                  const Text(
                    "Jumlah & Satuan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(flex: 2, child: _buildDropdown(hint: "10")),
                      const SizedBox(width: 16),
                      Expanded(flex: 3, child: _buildDropdown(hint: "Butir")),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Tanggal Kedaluwarsa",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    hint: "Pilih Tanggal",
                    icon: Icons.chevron_right,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _addDummyIngredient();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38A169),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Simpan ke Dapur",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // HELPER WIDGETS
  Widget _buildTextField({required String hint, IconData? icon}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        ),
      ),
    );
  }

  Widget _buildDropdown({required String hint}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade600)),
          icon: const Icon(Icons.keyboard_arrow_down),
          items: const [],
          onChanged: (val) {},
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final Color backgroundColor = isSelected
        ? const Color(0xFF63B685)
        : Colors.white;
    final Color textColor = isSelected ? Colors.white : Colors.black87;
    final Color subTextColor = isSelected
        ? Colors.white.withOpacity(0.9)
        : Colors.grey.shade600;
    final Color iconColor = isSelected ? Colors.white : Colors.black87;
    final BoxBorder? border = isSelected
        ? null
        : Border.all(color: Colors.grey.shade400);
    final List<BoxShadow> shadows = isSelected
        ? [
            BoxShadow(
              color: const Color(0xFF63B685).withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ]
        : [];
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: border,
          boxShadow: shadows,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 28, color: iconColor),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: subTextColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatAIButton() {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE8F5E9),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/home/logochat.png', height: 30),
          const Text(
            "Chat AI",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

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
                _navItem(Icons.shopping_basket, "Dapur Saya", true),
                const SizedBox(width: 60),

                // KOMUNITAS (DIHUBUNGKAN)
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

                // PROFIL (DIHUBUNGKAN)
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

          // TOMBOL TENGAH: CARI RESEP (DIHUBUNGKAN)
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchLoadingPage(),
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
