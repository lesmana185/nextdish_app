import 'package:flutter/material.dart';
import '../widget/custom_textfield.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.primaryGreen,
      body: SafeArea(
        child: Stack(
          children: [
            // Back
            Positioned(
              top: 16,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  "‹ Kembali",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            // Card putih
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      Text("Daftar Akun", style: textTheme.headlineLarge),

                      const SizedBox(height: 4),

                      Text("NextDish", style: textTheme.titleMedium),

                      const SizedBox(height: 12),

                      Text(
                        "Kami di sini untuk membantumu mengolah bahan yang ada menjadi hidangan lezat. Siap mulai?",
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 24),

                      const CustomTextField(hint: "Nama Lengkap"),
                      const CustomTextField(hint: "Email"),
                      const CustomTextField(
                        hint: "Password",
                        obscure: true,
                        suffix: Icon(Icons.visibility_off),
                      ),

                      const SizedBox(height: 24),

                      // Button dari theme
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF7AD9A6), // hijau terang (highlight)
                                  Color(0xFF63B685), // hijau utama
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Daftar",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text("Atau daftar dengan"),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialButton("assets/images/icons/facebook.png"),
                          const SizedBox(width: 16),
                          _socialButton("assets/images/icons/google.png"),
                        ],
                      ),

                      const SizedBox(height: 24),

                      GestureDetector(
                        onTap: () {},
                        child: Text.rich(
                          TextSpan(
                            text: "Sudah punya akun? ",
                            children: [
                              TextSpan(
                                text: "Log In",
                                style: TextStyle(
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _socialButton(String assetPath) {
  return InkWell(
    borderRadius: BorderRadius.circular(22),
    onTap: () {},
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Center(child: Image.asset(assetPath, width: 22, height: 22)),
    ),
  );
}
