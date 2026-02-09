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
  late Future<List<Map<String, dynamic>>> _ingredientsFuture;

  // Controller Manual Input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _refreshList() {
    setState(() {
      _ingredientsFuture = _fetchIngredients();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchIngredients() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];

    // Kita ambil semua kolom, termasuk 'image_path'
    final response = await Supabase.instance.client
        .from('user_ingredients')
        .select()
        .eq('user_id', user.id)
        .order('expiry_date', ascending: true); // Yang mau basi di atas

    return List<Map<String, dynamic>>.from(response);
  }

  // --- LOGIKA CERDAS: ESTIMASI KADALUARSA ---
  DateTime _estimateExpiry(String name) {
    final n = name.toLowerCase();
    int days = 7; // Default 1 minggu

    if (n.contains('ayam') ||
        n.contains('ikan') ||
        n.contains('udang') ||
        n.contains('daging')) {
      days = 3; // Protein Hewani
    } else if (n.contains('tahu') ||
        n.contains('tempe') ||
        n.contains('susu') ||
        n.contains('roti')) {
      days = 4; // Olahan
    } else if (n.contains('bayam') ||
        n.contains('kangkung') ||
        n.contains('sawi')) {
      days = 3; // Sayuran daun
    } else if (n.contains('wortel') ||
        n.contains('kentang') ||
        n.contains('bawang') ||
        n.contains('telur')) {
      days = 14; // Sayuran keras & telur
    } else if (n.contains('beras') ||
        n.contains('minyak') ||
        n.contains('kecap') ||
        n.contains('gula')) {
      days = 30; // Bahan kering
    }
    return DateTime.now().add(Duration(days: days));
  }

  // --- HELPER: FALLBACK GAMBAR LOKAL ---
  // Ini dipakai kalau User input manual ATAU data di server gak ketemu
  String _getLocalAssetPath(String name) {
    final n = name.toLowerCase();
    if (n.contains('telur')) return 'assets/images/ingredients/telur.png';
    if (n.contains('susu')) return 'assets/images/ingredients/susu.png';
    if (n.contains('ayam') || n.contains('daging') || n.contains('ikan'))
      return 'assets/images/ingredients/ayam.png';
    if (n.contains('keju')) return 'assets/images/ingredients/keju.png';
    if (n.contains('nasi') || n.contains('beras'))
      return 'assets/images/ingredients/nasi.png';
    if (n.contains('wortel')) return 'assets/images/ingredients/wortel.png';
    if (n.contains('roti')) return 'assets/images/ingredients/roti.png';
    return 'assets/images/ingredients/sayur.png'; // Default
  }

  // --- CRUD FUNCTIONS (YANG DIPERBARUI) ---

  // Fungsi ini sekarang Cerdas: Cari gambar di DB dulu sebelum simpan
  Future<void> _addManualIngredient(
      String name, String qty, String unit) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    Navigator.pop(context); // Tutup Modal
    FocusScope.of(context).unfocus(); // Tutup Keyboard

    // Feedback Loading kecil
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Sedang memproses..."),
        duration: Duration(milliseconds: 800)));

    try {
      final expiryDate = _estimateExpiry(name);
      String? foundImageUrl;

      // 1. CARI GAMBAR DI DATABASE ADMIN (AUTO-MATCH)
      try {
        final List<dynamic> searchResult = await Supabase.instance.client
            .from('ingredient_gallery')
            .select('image_url')
            .ilike('name', "%$name%") // Cari nama yang mirip
            .limit(1);

        if (searchResult.isNotEmpty) {
          foundImageUrl = searchResult[0]['image_url']; // KETEMU!
        }
      } catch (e) {
        debugPrint("Gak nemu gambar di server, pakai lokal aja.");
      }

      // 2. SIMPAN KE USER INGREDIENTS
      await Supabase.instance.client.from('user_ingredients').insert({
        'user_id': user.id,
        'name': name,
        'quantity': "$qty $unit",
        'status': 'Segar',
        'expiry_date': expiryDate.toIso8601String(),
        // Kalau ketemu pakai URL, kalau tidak pakai null (nanti jadi lokal)
        'image_path': foundImageUrl,
      });

      _refreshList();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Bahan '$name' tersimpan! ${foundImageUrl != null ? '📸' : '📁'}"),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      debugPrint("Error save: $e");
    }
  }

  Future<void> _deleteIngredient(String id) async {
    try {
      await Supabase.instance.client
          .from('user_ingredients')
          .delete()
          .eq('id', id);
      _refreshList();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Dihapus"), duration: Duration(seconds: 1)));
    } catch (e) {/* Silent */}
  }

  Future<void> _deleteAll() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Semua?"),
        content: const Text("Dapur akan menjadi kosong."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child:
                  const Text("Hapus", style: TextStyle(color: Colors.white))),
        ],
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client
          .from('user_ingredients')
          .delete()
          .eq('user_id', user.id);
      _refreshList();
    }
  }

  int _getDaysRemaining(String expiryDateStr) {
    if (expiryDateStr.isEmpty) return 7;
    return DateTime.parse(expiryDateStr).difference(DateTime.now()).inDays;
  }

  // --- UI BUILDER ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ingredientsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF38A169)));
          }

          final allData = snapshot.data ?? [];
          final bool isEmpty = allData.isEmpty;

          // Pisahkan Segar vs Hampir Basi (<= 3 hari)
          final freshList = allData
              .where((i) => _getDaysRemaining(i['expiry_date'] ?? '') > 3)
              .toList();
          final spoiledList = allData
              .where((i) => _getDaysRemaining(i['expiry_date'] ?? '') <= 3)
              .toList();

          return Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  if (!isEmpty)
                    _buildTabs(freshList.length, spoiledList.length),
                  Expanded(
                    child: isEmpty
                        ? _buildEmptyState()
                        : _buildIngredientList(freshList, spoiledList),
                  ),
                ],
              ),
              // Bottom Actions (Hanya muncul jika ada isi)
              if (!isEmpty)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: _buildBottomActions(allData.length),
                ),
              // Tombol Chat AI (Hanya muncul jika kosong biar gak sepi)
              if (isEmpty)
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ChatAIPage())),
                    child: _buildChatAIButton(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 50, bottom: 15, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Dapur Saya",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Column(
            children: [
              Image.asset('assets/images/home/logosmall.png',
                  height: 30), // Pastikan aset ini ada
              const Text("NextDish",
                  style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 8,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(int freshCount, int spoiledCount) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
              child: _buildTabButton(
                  0, "$freshCount Segar", Colors.green, Icons.check_circle)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildTabButton(1, "$spoiledCount Hampir Basi",
                  Colors.redAccent, Icons.warning)),
        ],
      ),
    );
  }

  Widget _buildIngredientList(
      List<Map<String, dynamic>> fresh, List<Map<String, dynamic>> spoiled) {
    final listToShow = _currentTab == 0 ? fresh : spoiled;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          20, 10, 20, 100), // Bottom padding besar biar gak ketutup tombol
      children: [
        if (_currentTab == 1 && spoiled.isNotEmpty) _buildWarningBanner(),
        if (listToShow.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Center(
                child: Text(
                    _currentTab == 0
                        ? "Tidak ada bahan segar."
                        : "Aman! Tidak ada bahan hampir basi.",
                    style: TextStyle(color: Colors.grey.shade400))),
          )
        else
          ...listToShow.map((item) => _buildIngredientCard(item)).toList(),
      ],
    );
  }

  // --- KARTU BAHAN (HYBRID: URL / LOKAL) ---
  Widget _buildIngredientCard(Map<String, dynamic> item) {
    final String name = item['name'] ?? 'Bahan';
    final String qty = item['quantity'] ?? '1 pcs';
    final String id = item['id'].toString();
    final int daysLeft = _getDaysRemaining(item['expiry_date'] ?? '');
    final bool isSpoiled = daysLeft <= 3;

    // --- LOGIC GAMBAR ---
    // Cek apakah ada URL dari Internet
    final String? imagePath = item['image_path'];
    final bool isNetworkImage =
        imagePath != null && imagePath.startsWith('http');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isSpoiled ? const Color(0xFFFFFDE7) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
        border: isSpoiled
            ? Border.all(color: Colors.orange.withOpacity(0.3))
            : null,
      ),
      child: Row(
        children: [
          // GAMBAR
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isNetworkImage
                ? Image.network(
                    imagePath!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Icon(Icons.broken_image,
                        size: 40, color: Colors.grey),
                  )
                : Image.asset(
                    _getLocalAssetPath(name), // Fallback ke aset lokal
                    width: 50, height: 50, fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Icon(Icons.kitchen,
                        size: 40, color: Colors.orange),
                  ),
          ),

          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(qty,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSpoiled
                            ? Colors.red.shade100
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        daysLeft < 0 ? "Basi" : "$daysLeft hari",
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSpoiled ? Colors.red : Colors.green),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _deleteIngredient(id),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.kitchen, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text("Dapur kosong melompong",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey)),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _showAddOptionModal(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38A169),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Isi Kulkas",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(int totalCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // TOMBOL RESET
        GestureDetector(
          onTap: _deleteAll,
          child: Container(
            height: 50,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_sweep, color: Colors.red.shade400, size: 20),
                Text("Reset",
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700)),
              ],
            ),
          ),
        ),

        // TOMBOL TAMBAH (TENGAH)
        GestureDetector(
          onTap: () => _showAddOptionModal(context),
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF38A169),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),

        // TOMBOL CARI RESEP
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SearchLoadingPage())),
          child: Container(
            height: 50,
            width: 140,
            decoration: BoxDecoration(
              color: const Color(0xFF38A169),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 5)
              ],
            ),
            alignment: Alignment.center,
            child: Text("Cari Resep\n($totalCount bahan)",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningBanner() {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const CompostLandingPage())),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFECB3))),
        child: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 30),
            SizedBox(width: 12),
            Expanded(
                child: Text("Bahan hampir basi! Ketuk untuk kelola kompos.",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String text, Color color, IconData icon) {
    bool isActive = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isActive ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? Colors.white : color, size: 18),
            const SizedBox(width: 8),
            Text(text,
                style: TextStyle(
                    color: isActive ? Colors.white : color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildChatAIButton() {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: const Color(0xFF38A169), width: 2),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]),
      child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF38A169)),
    );
  }

  void _showAddOptionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text("Tambah Bahan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF38A169)),
              title: const Text("Input Manual"),
              subtitle: const Text("Ketik nama sendiri"),
              onTap: () {
                Navigator.pop(context);
                _showManualInputModal(context);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.cloud_download, color: Color(0xFF38A169)),
              title: const Text("Pilih Online"),
              subtitle: const Text("Dari database Admin"),
              onTap: () async {
                Navigator.pop(context);
                // Navigasi ke Halaman Pilih Bahan, tunggu dia balik
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SelectIngredientsPage(
                            onManualInputRequest: () {})));
                // REFRESH LIST SETELAH BALIK (PENTING!)
                _refreshList();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showManualInputModal(BuildContext context) {
    _nameController.clear();
    _qtyController.clear();
    _unitController.text = "Pcs";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Input Manual",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: "Nama Bahan (Contoh: Telur)",
                      border: OutlineInputBorder())),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: _qtyController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: "Jumlah",
                            border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                Expanded(
                    child: TextField(
                        controller: _unitController,
                        decoration: const InputDecoration(
                            labelText: "Satuan",
                            border: OutlineInputBorder()))),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty)
                      _addManualIngredient(_nameController.text,
                          _qtyController.text, _unitController.text);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38A169)),
                  child: const Text("Simpan",
                      style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
