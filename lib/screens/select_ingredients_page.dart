import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SelectIngredientsPage extends StatefulWidget {
  final VoidCallback onManualInputRequest;

  const SelectIngredientsPage({super.key, required this.onManualInputRequest});

  @override
  State<SelectIngredientsPage> createState() => _SelectIngredientsPageState();
}

class _SelectIngredientsPageState extends State<SelectIngredientsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _keyword = "";

  // List Bahan Kosong (Nanti diisi dari Supabase)
  List<Map<String, dynamic>> _catalog = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchIngredients();
  }

  // --- 1. AMBIL DATA DARI SUPABASE (Fix: Koneksi ke Admin) ---
  Future<void> _fetchIngredients() async {
    try {
      final response = await Supabase.instance.client
          .from('ingredient_gallery') // Ambil dari tabel gallery
          .select()
          .order('name', ascending: true);

      if (mounted) {
        setState(() {
          _catalog = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error ambil bahan: $e");
      // Jika error (misal internet mati), matikan loading biar gak muter terus
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 2. SIMPAN KE DAPUR USER (Fix: Simpan Image URL) ---
  Future<void> _saveIngredient(
      Map<String, dynamic> item, String qty, String unit) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client.from('user_ingredients').insert({
        'user_id': user.id,
        'name': item['name'],
        'quantity': "$qty $unit",
        'status': 'Segar',
        'expiry_date':
            DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        // PENTING: Simpan link gambar agar di halaman Dapur muncul
        'image_path': item['image_url'],
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${item['name']} berhasil ditambahkan! ✅"),
            backgroundColor: const Color(0xFF38A169),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("Gagal simpan: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal menyimpan bahan ❌")));
      }
    }
  }

  // --- DIALOG INPUT JUMLAH ---
  void _showQuantityDialog(Map<String, dynamic> item) {
    final TextEditingController qtyCtrl = TextEditingController(text: "1");
    // Ambil satuan dari database, kalau kosong default 'Pcs'
    final TextEditingController unitCtrl =
        TextEditingController(text: item['unit'] ?? 'Pcs');

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
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Fix: Tampilkan Gambar Kecil dari URL
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item['image_url'] ?? '',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.image, size: 40, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Tambah ${item['name']}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: "Jumlah",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: unitCtrl,
                      decoration: InputDecoration(
                        labelText: "Satuan",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _saveIngredient(item, qtyCtrl.text, unitCtrl.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38A169),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("SIMPAN KE DAPUR",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter Pencarian (Client Side)
    final filteredList = _catalog.where((item) {
      final name = item['name'].toString().toLowerCase();
      return name.contains(_keyword.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text("Pilih Bahan Online",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _keyword = val),
              decoration: InputDecoration(
                hintText: "Cari bahan (misal: Bayam)...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
            ),
          ),

          // CONTENT
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF38A169))) // Loading Indicator
                : filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off,
                                size: 60, color: Colors.grey),
                            const SizedBox(height: 10),
                            Text("Tidak ditemukan '$_keyword'",
                                style: const TextStyle(color: Colors.grey)),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                widget
                                    .onManualInputRequest(); // Tombol ke Manual
                              },
                              child: const Text("Input Manual Saja",
                                  style: TextStyle(color: Color(0xFF38A169))),
                            )
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          return GestureDetector(
                            onTap: () => _showQuantityDialog(item),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2))
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // GAMBAR DARI INTERNET (SUPABASE)
                                  Container(
                                    padding: const EdgeInsets.all(
                                        2), // Padding tipis
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                        item['image_url'] ?? '',
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.cover,
                                        // Loading: Tampilkan icon jam pasir
                                        loadingBuilder: (c, child, progress) {
                                          if (progress == null) return child;
                                          return const SizedBox(
                                              width: 50,
                                              height: 50,
                                              child: Icon(Icons.hourglass_empty,
                                                  size: 20,
                                                  color: Colors.grey));
                                        },
                                        // Error: Tampilkan icon makanan
                                        errorBuilder: (c, e, s) => const Icon(
                                            Icons.restaurant,
                                            color: Color(0xFF38A169),
                                            size: 30),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: Text(
                                      item['name'] ?? 'Tanpa Nama',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                    ),
                                  ),
                                  Text(
                                    item['category'] ?? 'Umum',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade500),
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
    );
  }
}
