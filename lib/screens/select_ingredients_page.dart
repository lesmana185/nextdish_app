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

  // --- DATABASE KATALOG BAHAN (HARDCODED) ---
  // Ini daftar bahan umum biar user gampang milih
  final List<Map<String, String>> _catalog = [
    {'name': 'Telur', 'unit': 'Butir', 'category': 'Protein'},
    {'name': 'Ayam', 'unit': 'Kg', 'category': 'Protein'},
    {'name': 'Daging Sapi', 'unit': 'Kg', 'category': 'Protein'},
    {'name': 'Ikan', 'unit': 'Ekor', 'category': 'Protein'},
    {'name': 'Tahu', 'unit': 'Potong', 'category': 'Protein'},
    {'name': 'Tempe', 'unit': 'Papan', 'category': 'Protein'},
    {'name': 'Udang', 'unit': 'Kg', 'category': 'Protein'},
    {'name': 'Wortel', 'unit': 'Buah', 'category': 'Sayur'},
    {'name': 'Bayam', 'unit': 'Ikat', 'category': 'Sayur'},
    {'name': 'Kangkung', 'unit': 'Ikat', 'category': 'Sayur'},
    {'name': 'Brokoli', 'unit': 'Bonggol', 'category': 'Sayur'},
    {'name': 'Tomat', 'unit': 'Buah', 'category': 'Sayur'},
    {'name': 'Kentang', 'unit': 'Kg', 'category': 'Sayur'},
    {'name': 'Bawang Merah', 'unit': 'Siung', 'category': 'Bumbu'},
    {'name': 'Bawang Putih', 'unit': 'Siung', 'category': 'Bumbu'},
    {'name': 'Cabai', 'unit': 'Buah', 'category': 'Bumbu'},
    {'name': 'Beras', 'unit': 'Kg', 'category': 'Karbo'},
    {'name': 'Mie Instan', 'unit': 'Bungkus', 'category': 'Karbo'},
    {'name': 'Roti Tawar', 'unit': 'Lembar', 'category': 'Karbo'},
    {'name': 'Susu', 'unit': 'Liter', 'category': 'Lainnya'},
    {'name': 'Keju', 'unit': 'Balok', 'category': 'Lainnya'},
    {'name': 'Minyak Goreng', 'unit': 'Liter', 'category': 'Lainnya'},
    {'name': 'Garam', 'unit': 'Sdt', 'category': 'Bumbu'},
    {'name': 'Gula', 'unit': 'Sdm', 'category': 'Bumbu'},
  ];

  // Helper Gambar
  String _getImageAsset(String name) {
    final n = name.toLowerCase();
    if (n.contains('telur')) return 'assets/images/ingredients/telur.png';
    if (n.contains('ayam') || n.contains('daging'))
      return 'assets/images/ingredients/ayam.png';
    if (n.contains('susu')) return 'assets/images/ingredients/susu.png';
    if (n.contains('keju')) return 'assets/images/ingredients/keju.png';
    if (n.contains('nasi') || n.contains('beras'))
      return 'assets/images/ingredients/nasi.png';
    if (n.contains('wortel')) return 'assets/images/ingredients/wortel.png';
    if (n.contains('roti')) return 'assets/images/ingredients/roti.png';
    // Default fallback
    return 'assets/images/ingredients/sayur.png';
  }

  // --- LOGIKA SIMPAN KE SUPABASE ---
  Future<void> _saveIngredient(String name, String qty, String unit) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client.from('user_ingredients').insert({
        'user_id': user.id,
        'name': name,
        'quantity': "$qty $unit",
        'status': 'Segar',
        'expiry_date':
            DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$name berhasil ditambahkan! ✅"),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF38A169),
          ),
        );
      }
    } catch (e) {
      debugPrint("Gagal simpan: $e");
    }
  }

  // --- DIALOG INPUT JUMLAH ---
  void _showQuantityDialog(Map<String, String> item) {
    final TextEditingController qtyCtrl = TextEditingController(text: "1");
    final TextEditingController unitCtrl =
        TextEditingController(text: item['unit']);

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
                  Image.asset(_getImageAsset(item['name']!), height: 40),
                  const SizedBox(width: 12),
                  Text("Tambah ${item['name']}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
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
                    Navigator.pop(context); // Tutup Dialog
                    _saveIngredient(item['name']!, qtyCtrl.text, unitCtrl.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38A169),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Simpan",
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
    // Filter pencarian
    final filteredList = _catalog.where((item) {
      return item['name']!.toLowerCase().contains(_keyword.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text("Pilih Bahan",
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
                hintText: "Cari bahan (misal: Ayam)...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),

          // GRID BAHAN
          Expanded(
            child: filteredList.isEmpty
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
                                .onManualInputRequest(); // Balik ke manual input
                          },
                          child: const Text("Input Manual Saja",
                              style: TextStyle(color: Color(0xFF38A169))),
                        )
                      ],
                    ),
                  )
                : GridView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 Kolom
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
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  _getImageAsset(item['name']!),
                                  height: 32,
                                  width: 32,
                                  errorBuilder: (c, e, s) => const Icon(
                                      Icons.restaurant,
                                      color: Color(0xFF38A169),
                                      size: 30),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                item['name']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                item['category']!,
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey.shade500),
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
