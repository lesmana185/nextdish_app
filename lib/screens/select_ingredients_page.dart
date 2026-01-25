import 'package:flutter/material.dart';

class Ingredient {
  final String id;
  final String name;
  final String imagePath;
  bool isSelected;

  Ingredient({
    required this.id,
    required this.name,
    required this.imagePath,
    this.isSelected = false,
  });
}

class SelectIngredientsPage extends StatefulWidget {
  final VoidCallback? onManualInputRequest;

  const SelectIngredientsPage({super.key, this.onManualInputRequest});

  @override
  State<SelectIngredientsPage> createState() => _SelectIngredientsPageState();
}

class _SelectIngredientsPageState extends State<SelectIngredientsPage> {
  // --- DATA DUMMY ---
  // Nanti bisa diganti dengan data dari API/Database
  final List<Ingredient> _allIngredients = [
    Ingredient(
      id: '1',
      name: 'Ayam',
      imagePath: 'assets/images/ingredients/ayam.png',
    ),
    Ingredient(
      id: '2',
      name: 'Wortel',
      imagePath: 'assets/images/ingredients/wortel.png',
    ),
    Ingredient(
      id: '3',
      name: 'Bawang Putih',
      imagePath: 'assets/images/ingredients/bawang.png',
    ),
    Ingredient(
      id: '4',
      name: 'Telur',
      imagePath: 'assets/images/ingredients/telur.png',
      isSelected: true,
    ), // Contoh default terpilih
    Ingredient(
      id: '5',
      name: 'Tomat',
      imagePath: 'assets/images/ingredients/tomat.png',
    ),
    Ingredient(
      id: '6',
      name: 'Cabai',
      imagePath: 'assets/images/ingredients/cabai.png',
    ),
  ];

  // List yang akan ditampilkan (hasil filter)
  List<Ingredient> _foundIngredients = [];

  @override
  void initState() {
    super.initState();
    _foundIngredients = _allIngredients; // Awalnya tampilkan semua
  }

  // Fungsi Pencarian
  void _runFilter(String keyword) {
    List<Ingredient> results = [];
    if (keyword.isEmpty) {
      results = _allIngredients;
    } else {
      results = _allIngredients
          .where(
            (item) => item.name.toLowerCase().contains(keyword.toLowerCase()),
          )
          .toList();
    }

    setState(() {
      _foundIngredients = results;
    });
  }

  // Menghitung jumlah yang terpilih
  int get _selectedCount => _allIngredients.where((i) => i.isSelected).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.chevron_left, size: 32),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Pilih Bahan",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 32), // Spacer penyeimbang
                ],
              ),
            ),

            // --- SEARCH BAR ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  onChanged: (value) => _runFilter(value),
                  decoration: const InputDecoration(
                    hintText: "Cari bahan......",
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // --- LIST CONTENT ATAU EMPTY STATE ---
            Expanded(
              child: _foundIngredients.isNotEmpty
                  ? _buildIngredientList()
                  : _buildEmptyState(),
            ),

            // --- BOTTOM BUTTON ---
            // Hanya muncul jika list tidak kosong (atau sesuai kebutuhan desain)
            if (_foundIngredients.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Aksi Lanjut
                      print("Lanjut dengan $_selectedCount bahan");
                      Navigator.pop(context, true); // Kembali ke dapur
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF38A169,
                      ), // Warna Hijau NextDish
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Lanjut ($_selectedCount bahan)",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // WIDGET: List Bahan
  Widget _buildIngredientList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _foundIngredients.length,
      itemBuilder: (context, index) {
        final ingredient = _foundIngredients[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CheckboxListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            activeColor: const Color(0xFF38A169),
            checkboxShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            value: ingredient.isSelected,
            onChanged: (bool? value) {
              setState(() {
                // Kita update object aslinya di _allIngredients juga
                // Agar counter tetap benar meski sedang difilter
                final originalIndex = _allIngredients.indexWhere(
                  (item) => item.id == ingredient.id,
                );
                if (originalIndex != -1) {
                  _allIngredients[originalIndex].isSelected = value ?? false;
                }
              });
            },
            title: Row(
              children: [
                // Gambar Bahan (Placeholder Icon jika aset belum ada)
                Image.asset(
                  ingredient.imagePath,
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.fastfood,
                    size: 40,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),

                // Nama Bahan
                Expanded(
                  child: Text(
                    ingredient.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                // Icon Centang Hijau (Badge) di kanan sesuai desain
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF63B685),
                  size: 24,
                ),
              ],
            ),
            controlAffinity:
                ListTileControlAffinity.leading, // Checkbox di kiri
          ),
        );
      },
    );
  }

  // WIDGET: Empty State (Bahan Tidak Ditemukan)
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Gambar Sedih
        Image.asset(
          'assets/images/icons/sad.png', // Pastikan aset ini ada
          height: 100,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.sentiment_dissatisfied,
            size: 100,
            color: Colors.amber,
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          "Bahan tidak ditemukan",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 50),
          child: Text(
            "Tambahkan bahan secara manual ke dapur kamu",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),

        const SizedBox(height: 30),

        // Tombol Tambah Manual
        SizedBox(
          width: 250,
          height: 45,
          child: ElevatedButton(
            onPressed: () {
              // Jika tombol ini ditekan, kita bisa trigger modal manual
              if (widget.onManualInputRequest != null) {
                Navigator.pop(context); // Tutup halaman search dulu
                widget.onManualInputRequest!(); // Panggil fungsi buka modal
              } else {
                // Fallback jika tidak ada callback (opsional)
                print("Buka manual input");
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38A169),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Tambah Bahan Manual",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
