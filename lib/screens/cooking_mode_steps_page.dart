import 'package:flutter/material.dart';
import 'cooking_mode_sucses_page.dart'; // Pastikan nama file ini sesuai di project kamu
import 'home_page.dart';

class CookingModeStepsPage extends StatefulWidget {
  const CookingModeStepsPage({super.key});

  @override
  State<CookingModeStepsPage> createState() => _CookingModeStepsPageState();
}

class _CookingModeStepsPageState extends State<CookingModeStepsPage> {
  int _currentStepIndex = 0;

  // DATA LANGKAH-LANGKAH
  final List<Map<String, String>> _steps = [
    {
      'title': 'Persiapan Bahan',
      'description':
          'Cuci dan potong bawang putih serta bawang merah. Pecahkan telur ke dalam wadah terpisah agar siap digunakan.',
      'trigger': 'lanjut',
    },
    {
      'title': 'Panaskan Wajan',
      'description':
          'Panaskan wajan dengan sedikit minyak di atas api sedang.\nTunggu hingga minyak cukup panas.',
      'trigger': 'lanjut',
    },
    {
      'title': 'Tumis Bumbu',
      'description':
          'Masukkan bawang putih dan bawang merah ke dalam wajan.\nTumis hingga harum dan berubah warna keemasan.',
      'trigger': 'lanjut',
    },
    {
      'title': 'Penyelesaian',
      'description':
          'Masak nasi goreng hingga matang dan harum.\nAngkat dan sajikan selagi hangat.',
      'trigger': 'selesai',
    },
  ];

  void _nextStep() {
    setState(() {
      if (_currentStepIndex < _steps.length - 1) {
        _currentStepIndex++;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CookingModeSuccessPage(),
          ),
        );
      }
    });
  }

  // --- FUNGSI MENAMPILKAN ALERT KELUAR (Sesuai Desain Alert.png) ---
  Future<bool> _showExitConfirmDialog() async {
    return await showDialog(
          context: context,
          barrierDismissible:
              false, // User harus pilih tombol, gabisa klik luar
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 10,
            backgroundColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. HEADER KUNING
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 10,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF59D), // Kuning Pastel
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Keluar Dari Mode Masak ?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),

                // 2. KONTEN TEKS & TOMBOL
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
                  child: Column(
                    children: [
                      const Text(
                        "Kamu belum menyelesaikan proses memasak. Jika keluar sekarang, panduan suara akan dihentikan.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // 3. TOMBOL AKSI (YA / TIDAK)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Tombol YA (Hijau)
                          SizedBox(
                            width: 110,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).pop(true); // Return true (Keluar)
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF38A169),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "YA",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),

                          // Tombol TIDAK (Abu)
                          SizedBox(
                            width: 110,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).pop(false); // Return false (Batal)
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF6C757D,
                                ), // Abu-abu gelap
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "TIDAK",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_currentStepIndex + 1) / _steps.length;

    // PopScope: Menangani tombol Back fisik di Android
    return PopScope(
      canPop: false, // Matikan back default
      onPopInvoked: (didPop) async {
        if (didPop) return;
        // Panggil Dialog Konfirmasi
        final shouldPop = await _showExitConfirmDialog();
        if (shouldPop && context.mounted) {
          Navigator.pop(context); // Keluar jika user pilih YA
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFE8F5E9),
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // --- HEADER ---
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        // TOMBOL BACK (Di-update dengan Dialog)
                        GestureDetector(
                          onTap: () async {
                            // Panggil Dialog Konfirmasi saat tombol back ditekan
                            final shouldPop = await _showExitConfirmDialog();
                            if (shouldPop && context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              size: 20,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              "Mode Masak",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Serif',
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Image.asset(
                              'assets/images/home/logosmall.png',
                              height: 30,
                            ),
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

                  const SizedBox(height: 20),

                  // --- BANNER INSTRUKSI ---
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 5),
                      ],
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/illustrasi/robotmic.png',
                          height: 60,
                          errorBuilder: (ctx, err, s) => const Icon(
                            Icons.smart_toy,
                            size: 40,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 12,
                              ),
                              children: [
                                TextSpan(
                                  text: "Mode masak suara aktif.\nKatakan ",
                                ),
                                TextSpan(
                                  text: "‘lanjut’",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(text: " untuk melanjutkan,\natau "),
                                TextSpan(
                                  text: "‘ulang’",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(text: " untuk mengulangi instruksi"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- PROGRESS BAR ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade300,
                        color: const Color(0xFF63B685),
                        minHeight: 10,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- KARTU LANGKAH ---
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 30,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _steps[_currentStepIndex]['title']!,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _steps[_currentStepIndex]['description']!,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 60),
                          Center(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  const TextSpan(
                                    text: "Jika sudah selesai, ucapkan ",
                                  ),
                                  TextSpan(
                                    text:
                                        "“${_steps[_currentStepIndex]['trigger']}”",
                                    style: const TextStyle(
                                      color: Color(0xFF63B685),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const TextSpan(text: "."),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- TOMBOL MIC ---
            Positioned(
              bottom: 90,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _nextStep,
                  child: Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const Icon(Icons.mic, color: Colors.white, size: 38),
                  ),
                ),
              ),
            ),

            // Nav Bar
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildCustomBottomNavBar(context),
            ),
          ],
        ),
      ),
    );
  }

  // --- REUSED NAV BAR ---
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
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomePage()),
                  ),
                  child: _navItem(Icons.home, "Home", false),
                ),
                _navItem(Icons.shopping_basket, "Dapur Saya", false),
                const SizedBox(width: 60),
                _navItem(Icons.chat_bubble, "Komunitas", false),
                _navItem(Icons.person, "Profil", false),
              ],
            ),
          ),
          Positioned(
            top: 0,
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
                    Image.asset('assets/images/home/logosmall.png', height: 30),
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
