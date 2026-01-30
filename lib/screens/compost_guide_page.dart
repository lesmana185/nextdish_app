import 'package:flutter/material.dart';
import 'compost_result_page.dart';

class CompostGuidePage extends StatelessWidget {
  final List<Map<String, dynamic>>
      items; // Data yang dikirim dari halaman sebelumnya

  const CompostGuidePage({super.key, required this.items});

  // --- LOGIKA PANDUAN PINTAR ---
  Map<String, dynamic> _getGuide(String name) {
    final n = name.toLowerCase();

    if (n.contains('susu') ||
        n.contains('yogurt') ||
        n.contains('keju') ||
        n.contains('minyak') ||
        n.contains('daging') ||
        n.contains('ikan')) {
      // KATEGORI NON-KOMPOS (LIMBAH)
      return {
        'type': 'waste',
        'title': '$name (Tidak Bisa Dikompos)',
        'bgColor': const Color(0xFFFFEBEE), // Merah Muda
        'steps': [
          {
            'text': 'Jangan masukkan ke wadah kompos',
            'done': false,
            'color': Colors.red
          },
          {
            'text': 'Buang isi ke saluran air/tong sampah',
            'done': false,
            'color': Colors.orange
          },
          {
            'text': 'Cuci wadahnya sebelum didaur ulang',
            'done': false,
            'color': Colors.blue
          },
        ]
      };
    } else if (n.contains('telur')) {
      // KATEGORI CANGKANG TELUR
      return {
        'type': 'compost',
        'title': 'Cangkang Telur',
        'bgColor': const Color(0xFFE8F5E9),
        'steps': [
          {'text': 'Cuci bersih cangkang', 'done': true},
          {'text': 'Keringkan di bawah sinar matahari', 'done': true},
          {'text': 'Remukkan hingga halus', 'done': false},
          {'text': 'Taburkan ke pot tanaman/kompos', 'done': false},
        ]
      };
    } else {
      // KATEGORI UMUM (SAYUR/BUAH)
      return {
        'type': 'compost',
        'title': 'Sisa Organik ($name)',
        'bgColor': const Color(0xFFFFF8E1), // Kuning Muda
        'steps': [
          {'text': 'Pisahkan dari plastik/karet', 'done': true},
          {'text': 'Potong kecil-kecil agar cepat terurai', 'done': false},
          {
            'text': 'Campurkan dengan sampah coklat (daun kering)',
            'done': false
          },
          {'text': 'Masukkan ke wadah kompos', 'done': false},
        ]
      };
    }
  }

  String _getImageAsset(String name) {
    final n = name.toLowerCase();
    if (n.contains('telur')) return 'assets/images/ingredients/telur.png';
    if (n.contains('susu')) return 'assets/images/ingredients/susu.png';
    if (n.contains('ayam') || n.contains('daging'))
      return 'assets/images/ingredients/ayam.png';
    return 'assets/images/ingredients/sayur.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF63B685),
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        title: const Text("Panduan Pengolahan",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              children: items.map((item) {
                final guide = _getGuide(item['name']);
                return Column(
                  children: [
                    _buildGuideCard(
                      title: guide['title'],
                      imagePath: _getImageAsset(item['name']),
                      bgColor: guide['bgColor'],
                      steps: guide['steps'],
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }).toList(),
            ),
          ),

          // TOMBOL PROSES SELESAI
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Kirim daftar Item yang akan dihapus ke halaman Result
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CompostResultPage(itemsToDelete: items)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38A169),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: const Text("Saya Sudah Melakukannya",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideCard(
      {required String title,
      required String imagePath,
      required Color bgColor,
      required List<Map<String, dynamic>> steps}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(imagePath,
                  width: 40,
                  height: 40,
                  errorBuilder: (c, e, s) =>
                      const Icon(Icons.recycling, size: 30)),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87))),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: steps.map((step) {
                Color dotColor = step.containsKey('color')
                    ? step['color']
                    : (step['done']
                        ? const Color(0xFF00C853)
                        : Colors.grey.shade300);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dotColor == Colors.grey.shade300
                                ? Colors.white
                                : dotColor,
                            border: step['done'] == false &&
                                    !step.containsKey('color')
                                ? Border.all(color: Colors.grey)
                                : null),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(step['text'],
                              style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.3,
                                  fontWeight: FontWeight.w500))),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
