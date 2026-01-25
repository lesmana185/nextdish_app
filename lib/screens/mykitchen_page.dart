import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_ai_page.dart';
import 'select_ingredients_page.dart';
import 'search_loading_page.dart';
import 'compost_landing_page.dart';

class MyKitchenPage extends StatefulWidget {
  const MyKitchenPage({super.key});

  @override
  State<MyKitchenPage> createState() => _MyKitchenPageState();
}

class _MyKitchenPageState extends State<MyKitchenPage> {
  // --- STATE ---
  int _currentTab = 0; // 0 = Segar, 1 = Basi/Hampir Basi

  // Controller untuk Input Manual
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  // Stream langsung dari Supabase
  // Menggunakan .stream() agar UI otomatis update saat ada perubahan data
  final _ingredientsStream = Supabase.instance.client
      .from('user_ingredients')
      .stream(primaryKey: ['id'])
      .eq('user_id', Supabase.instance.client.auth.currentUser?.id ?? '')
      .order('created_at', ascending: false);

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  // --- FUNGSI SUPABASE ---

  // 1. Tambah Bahan
  Future<void> _addIngredientToSupabase(
    String name,
    String qty,
    String unit,
  ) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // Tutup modal dulu biar responsif
    Navigator.pop(context);

    try {
      await Supabase.instance.client.from('user_ingredients').insert({
        'user_id': user.id,
        'name': name,
        'quantity': "$qty $unit",
        'status': 'Segar', // Default
        'expiry_date': DateTime.now()
            .add(const Duration(days: 7))
            .toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bahan berhasil disimpan! ☁️"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // 2. Hapus Bahan
  Future<void> _deleteIngredient(String id) async {
    try {
      // Kita hapus print, pakai SnackBar biar kelihatan di layar HP
      await Supabase.instance.client
          .from('user_ingredients')
          .delete()
          .eq('id', id); // Pastikan ID ini cocok

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Item berhasil dihapus")));
      }
    } catch (e) {
      if (mounted) {
        // Ini akan memberitahu kita KENAPA gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal hapus: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 3. Hapus Semua (Reset)
  // Update Fungsi Reset / Hapus Semua
  Future<void> _deleteAll() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // Tampilkan konfirmasi dulu biar tidak kepencet
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Kosongkan Dapur?"),
        content: const Text("Semua bahan akan dihapus permanen."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              "Hapus Semua",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await Supabase.instance.client
          .from('user_ingredients')
          .delete()
          .eq('user_id', user.id); // Hapus berdasarkan ID Pemilik

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dapur berhasil dikosongkan! 🧹")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal reset: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ PENTING: Tidak ada bottomNavigationBar di sini!
    // Navigasi sudah diurus oleh MainScaffold.
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _ingredientsStream,
        builder: (context, snapshot) {
          // Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Data Handler
          final allData = snapshot.data ?? [];
          final bool isEmpty = allData.isEmpty;

          // Filter Data
          final freshList = allData
              .where((i) => i['status'] == 'Segar')
              .toList();
          final spoiledList = allData
              .where((i) => i['status'] != 'Segar')
              .toList();

          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // KONTEN UTAMA
              isEmpty
                  ? _buildEmptyState()
                  : _buildFilledState(freshList, spoiledList, allData.length),

              // CHAT AI BUTTON (Hanya muncul jika kosong, opsional)
              if (isEmpty)
                Positioned(
                  right: 20,
                  bottom:
                      20, // Posisi disesuaikan karena tidak ada navbar ganda
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatAIPage()),
                    ),
                    child: _buildChatAIButton(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/dapur/kitchen.jpg',
            height: 200,
            fit: BoxFit.contain,
            errorBuilder: (c, e, s) =>
                const Icon(Icons.kitchen, size: 100, color: Colors.grey),
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
        ],
      ),
    );
  }

  Widget _buildFilledState(
    List<Map<String, dynamic>> fresh,
    List<Map<String, dynamic>> spoiled,
    int totalCount,
  ) {
    return Column(
      children: [
        // Header
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

        // Tabs
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  0,
                  "${fresh.length} Segar",
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTabButton(
                  1,
                  "${spoiled.length} Hampir Basi",
                  Colors.redAccent,
                  Icons.warning,
                ),
              ),
            ],
          ),
        ),

        // List Items
        Expanded(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  100,
                ), // Padding bawah disesuaikan
                child: Column(
                  children: [
                    if (_currentTab == 1 && spoiled.isNotEmpty)
                      _buildWarningBanner(),

                    // Render List
                    if (_currentTab == 0)
                      ...fresh
                          .map((item) => _buildIngredientCard(item))
                          .toList()
                    else
                      ...spoiled
                          .map((item) => _buildIngredientCard(item))
                          .toList(),

                    if ((_currentTab == 0 && fresh.isEmpty) ||
                        (_currentTab == 1 && spoiled.isEmpty))
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

              // Floating Actions Bottom
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tombol Reset
                    GestureDetector(
                      onTap: _deleteAll,
                      child: Container(
                        height: 50,
                        width: 90,
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
                            const SizedBox(width: 4),
                            Text(
                              "Reset",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tombol Tambah (Bulat)
                    GestureDetector(
                      onTap: () => _showAddOptionModal(context),
                      child: Container(
                        height: 45,
                        width: 45,
                        decoration: const BoxDecoration(
                          color: Color(0xFF38A169),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),

                    // Tombol Cari Resep
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SearchLoadingPage(),
                        ),
                      ),
                      child: Container(
                        height: 50,
                        width: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFF38A169),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Cari Resep\n($totalCount bahan)",
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

  // --- LOGIKA CARD BAHAN ---
  Widget _buildIngredientCard(Map<String, dynamic> item) {
    final String name = item['name'] ?? 'Bahan';
    final String qty = item['quantity'] ?? '1 pcs';
    final String status = item['status'] ?? 'Segar';
    final bool isSpoiled = status != 'Segar';
    final String id = item['id'].toString();

    // Warna Card
    Color bgColor = isSpoiled ? const Color(0xFFFFFDE7) : Colors.white;

    // Icon Mapping Sederhana
    String imgPath = 'assets/images/ingredients/sayur.png'; // Default
    final lowerName = name.toLowerCase();
    if (lowerName.contains('telur'))
      imgPath = 'assets/images/ingredients/telur.png';
    else if (lowerName.contains('susu'))
      imgPath = 'assets/images/ingredients/susu.png';
    else if (lowerName.contains('ayam'))
      imgPath = 'assets/images/ingredients/ayam.png';
    else if (lowerName.contains('keju'))
      imgPath = 'assets/images/ingredients/keju.png';
    else if (lowerName.contains('nasi'))
      imgPath = 'assets/images/ingredients/nasi.png';

    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteIngredient(id);
      },
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
              imgPath,
              width: 50,
              height: 50,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.fastfood, size: 40, color: Colors.orange),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$qty • $status",
                    style: TextStyle(
                      fontSize: 12,
                      color: isSpoiled ? Colors.orange : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _deleteIngredient(id),
            ),
          ],
        ),
      ),
    );
  }

  // --- MODAL INPUT ---
  void _showManualInputModal(BuildContext context) {
    _nameController.clear();
    _qtyController.clear();
    _unitController.text = "Pcs";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Tambah Bahan Manual",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Nama Bahan",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nameController,
                  hint: "Contoh: Telur",
                ),
                const SizedBox(height: 20),
                const Text(
                  "Jumlah",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _qtyController,
                        hint: "10",
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _unitController,
                        hint: "Butir/Kg",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.isNotEmpty) {
                        _addIngredientToSupabase(
                          _nameController.text,
                          _qtyController.text,
                          _unitController.text,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38A169),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Simpan ke Cloud",
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
          ),
        );
      },
    );
  }

  // --- MODAL PILIHAN ---
  void _showAddOptionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
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
              const Text(
                "Pilih cara tambah",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              _buildOptionButton(
                title: "Ketik Manual",
                subtitle: "Input bahan sendiri",
                icon: Icons.edit_note,
                isSelected: true,
                onTap: () {
                  Navigator.pop(context);
                  _showManualInputModal(context);
                },
              ),
              const SizedBox(height: 16),
              _buildOptionButton(
                title: "Pilih dari daftar",
                subtitle: "Pilih icon bahan",
                icon: Icons.checklist_rtl,
                isSelected: false,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SelectIngredientsPage(onManualInputRequest: () {}),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGET PENDUKUNG ---

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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF63B685) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? null : Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.white : Colors.black87,
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
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),
              ],
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
          const Expanded(
            child: Text(
              "Ada bahan yang perlu ditangani",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CompostLandingPage()),
            ),
            child: const Icon(Icons.eco, size: 24, color: Colors.green),
          ),
        ],
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
}
