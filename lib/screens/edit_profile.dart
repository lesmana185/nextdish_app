import 'package:flutter/material.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF63B685),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  "Edit Profil",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black54,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // FORM CONTAINER
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Hijau Kecil
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF63B685),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        "Profil Saya",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Foto Profil
                  const Text(
                    "Foto Profil",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black87),
                    ),
                    child: const Center(
                      child: Icon(Icons.edit_square, size: 40),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Input Username
                  const Text(
                    "Username",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(),

                  const SizedBox(height: 20),

                  // Input Email
                  const Text(
                    "Email",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(),

                  const SizedBox(height: 40),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7CB342),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Simpan",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA6AAA9),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Batal",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black87),
      ),
      child: const TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
