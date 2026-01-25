import 'package:flutter/material.dart';
import 'mykitchen_page.dart'; // Balik ke dapur

class CompostResultPage extends StatelessWidget {
  const CompostResultPage({super.key});

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
            // Gambar Bumi
            Image.asset(
              'assets/images/illustrasi/alert.png',
              height: 250,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.public, size: 200, color: Colors.green),
            ),

            const SizedBox(height: 40),

            const Text(
              "0,4 kg sampah\nberhasil diselamatkan",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "Kamu membantu mengurangi sampah\nyang masuk ke TPA",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const SizedBox(height: 30),

            // Robot Kecil
            Image.asset('assets/images/illustrasi/robotmic.png', height: 100),

            const Spacer(),

            // TOMBOL KEMBALI
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Kembali ke Dapur Saya
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyKitchenPage(),
                    ),
                    (route) => false, // Hapus stack history
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFFFFB74D,
                  ), // Orange sesuai gambar
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  "Kembali ke Dapur Saya",
                  style: TextStyle(
                    color: Color(0xFF5D4037),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
