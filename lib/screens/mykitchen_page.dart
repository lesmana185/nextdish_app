import 'package:flutter/material.dart';
import 'home_complex_page.dart'; // Pastikan import ini sesuai nama file kamu

class MyKitchenPage extends StatelessWidget {
  const MyKitchenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. KONTEN UTAMA
          Column(
            children: [
              // HEADER
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 15),
                  child: Center(
                    child: Text(
                      "Dapur Saya",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(thickness: 1, color: Colors.grey),

              // EMPTY STATE (ILUSTRASI DAPUR)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Image.asset(
                        'assets/images/dapur/kitchen.jpg', // Pastikan aset ada
                        height: 250,
                        fit: BoxFit.contain,
                      ),
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

                    // TOMBOL CTA UTAMA: TAMBAH BAHAN
                    GestureDetector(
                      onTap: () {
                        _showAddOptionModal(context);
                      },
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
                    const SizedBox(height: 100), // Spacer bawah
                  ],
                ),
              ),
            ],
          ),

          // CHAT AI BUTTON
          Positioned(right: 20, bottom: 110, child: _buildChatAIButton()),

          // BOTTOM NAV BAR
          _buildCustomBottomNavBar(context),
        ],
      ),
    );
  }

  // MODAL 1: PILIH CARA TAMBAH (Ketik Manual / Daftar)
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
              // Header Modal
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.chevron_left, size: 32),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Pilih cara tambah",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 32), // Spacer dummy
                ],
              ),
              const SizedBox(height: 30),

              // Pilihan 1: Ketik Manual
              _buildOptionButton(
                title: "Ketik Manual",
                subtitle: "Input bahan secara manual",
                icon: Icons.edit_note,
                color: const Color(0xFF63B685),
                textColor: Colors.white,
                isOutlined: false,
                onTap: () {
                  Navigator.pop(context); // Tutup modal pilihan
                  _showManualInputModal(context); // Buka modal input manual
                },
              ),

              const SizedBox(height: 16),

              // Pilihan 2: Pilih dari Daftar
              _buildOptionButton(
                title: "Pilih dari daftar",
                subtitle: "Pilih bahan dari daftar",
                icon: Icons.checklist_rtl,
                color: Colors.white,
                textColor: Colors.black87,
                isOutlined: true,
                onTap: () {
                  print("Pilih Daftar clicked");
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // MODAL 2: FORM INPUT MANUAL
  void _showManualInputModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled:
          true, // Agar modal bisa full height jika keyboard muncul
      builder: (context) {
        // StatefulBuilder digunakan agar Dropdown bisa berubah nilai saat dipilih
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height:
                  MediaQuery.of(context).size.height * 0.85, // Tinggi 85% layar
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle (Garis Abu di atas)
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Header Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(Icons.chevron_left, size: 32),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Ilustrasi Kecil (Opsional, sesuai gambar Manual.png di background)
                  // Jika ingin simple, langsung form saja.
                  const SizedBox(height: 20),

                  // INPUT 1: NAMA BAHAN
                  const Text(
                    "Nama Bahan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(hint: "Contoh : Telur"),

                  const SizedBox(height: 20),

                  // INPUT 2: JUMLAH & SATUAN (Row)
                  const Text(
                    "Jumlah & Satuan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(flex: 2, child: _buildDropdown(hint: "10")),
                      const SizedBox(width: 16),
                      Expanded(flex: 3, child: _buildDropdown(hint: "Butir")),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // INPUT 3: TANGGAL KEDALUWARSA
                  const Text(
                    "Tanggal Kedaluwarsa",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    hint: "Pilih Tanggal",
                    icon: Icons.chevron_right,
                  ),

                  const Spacer(),

                  // BUTTON: SIMPAN KE DAPUR
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        print("Disimpan ke dapur");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38A169),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Simpan ke Dapur",
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
            );
          },
        );
      },
    );
  }

  // --- WIDGET HELPER FORM ---

  Widget _buildTextField({required String hint, IconData? icon}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        ),
      ),
    );
  }

  Widget _buildDropdown({required String hint}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade600)),
          icon: const Icon(Icons.keyboard_arrow_down),
          items: const [], // Isi list item di sini nanti
          onChanged: (val) {},
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color textColor,
    required bool isOutlined,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: isOutlined ? Border.all(color: Colors.grey.shade400) : null,
          boxShadow: isOutlined
              ? []
              : [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isOutlined
                    ? Colors.grey.shade100
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isOutlined ? Colors.black87 : Colors.white,
              ),
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
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isOutlined
                        ? Colors.grey.shade600
                        : Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET PENDUKUNG LAIN (Sama seperti sebelumnya) ---

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
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const HomeComplexPage(),
                        transitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: _navItem(Icons.home, "Home", false),
                ),
                _navItem(Icons.shopping_basket, "Dapur Saya", true),
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
