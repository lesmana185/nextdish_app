import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main_scaffold.dart'; // PENTING: Import ini untuk balik ke Home/Dapur dengan benar

class CompostResultPage extends StatefulWidget {
  final List<Map<String, dynamic>> itemsToDelete;

  const CompostResultPage({super.key, required this.itemsToDelete});

  @override
  State<CompostResultPage> createState() => _CompostResultPageState();
}

class _CompostResultPageState extends State<CompostResultPage> {
  bool _isProcessing = true;
  int _deletedCount = 0;

  @override
  void initState() {
    super.initState();
    _processCleanup();
  }

  // --- LOGIKA HAPUS DATA DARI DAPUR ---
  Future<void> _processCleanup() async {
    // Simulasi loading biar user baca "Memproses..."
    await Future.delayed(const Duration(seconds: 1));

    try {
      for (var item in widget.itemsToDelete) {
        await Supabase.instance.client
            .from('user_ingredients')
            .delete()
            .eq('id', item['id']); // Hapus berdasarkan ID
      }

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _deletedCount = widget.itemsToDelete.length;
        });
      }
    } catch (e) {
      debugPrint("Gagal hapus sampah: $e");
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // Gambar Animasi/Status
            _isProcessing
                ? const SizedBox(
                    height: 150,
                    width: 150,
                    child: CircularProgressIndicator(
                        color: Colors.green, strokeWidth: 8),
                  )
                : Image.asset('assets/images/illustrasi/alert.png',
                    height: 250,
                    errorBuilder: (c, e, s) => const Icon(Icons.check_circle,
                        size: 150, color: Colors.green)),

            const SizedBox(height: 40),

            Text(
              _isProcessing
                  ? "Membersihkan Dapur..."
                  : "$_deletedCount Bahan\nBerhasil Diolah!",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333)),
            ),

            const SizedBox(height: 16),

            Text(
              _isProcessing
                  ? "Sedang menghapus item dari database..."
                  : "Kamu membantu mengurangi sampah\nyang masuk ke TPA. Keren! 🌍",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const Spacer(),

            // TOMBOL KEMBALI
            if (!_isProcessing)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // PENTING: Gunakan ini untuk Reset Navigasi ke Dapur
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        // Masuk ke MainScaffold index 1 (Dapur)
                        builder: (context) =>
                            const MainScaffold(initialIndex: 1),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB74D), // Orange
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: const Text("Kembali ke Dapur Saya",
                      style: TextStyle(
                          color: Color(0xFF5D4037),
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
