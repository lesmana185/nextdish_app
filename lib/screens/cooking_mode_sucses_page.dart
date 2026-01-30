import 'package:flutter/material.dart';
import 'package:nextdish_app/main_scaffold.dart';
import 'home_page.dart';

class CookingModeSuccessPage extends StatelessWidget {
  final String recipeName;

  const CookingModeSuccessPage({super.key, required this.recipeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Mode Masak Selesai",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Serif'),
                    ),
                    const SizedBox(height: 50),

                    // GAMBAR ROBOT SUKSES
                    Image.asset(
                      'assets/images/illustrasi/robotsucses.png',
                      height: 250,
                      errorBuilder: (c, e, s) => const Icon(Icons.check_circle,
                          size: 150, color: Colors.green),
                    ),

                    const SizedBox(height: 30),

                    // UCAPAN SELAMAT
                    Text(
                      "“Selamat! $recipeName kamu sudah siap disajikan.\nTerima kasih sudah memasak bersama NextDish.”",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.5),
                    ),

                    const Spacer(),

                    // TOMBOL KEMBALI KE HOME
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF63B685),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () {
                          // Kembali ke Home dan hapus semua history halaman masak
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const MainScaffold()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        child: const Text("KEMBALI KE BERANDA",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
