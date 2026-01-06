import 'package:flutter/material.dart';
import '../widget/custom_textfield.dart';
import '../theme/app_theme.dart';
import 'package:nextdish_app/screens/home_complex_page.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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

                      Text("Log In", style: textTheme.headlineLarge),

                      const SizedBox(height: 4),

                      Text("NextDish", style: textTheme.titleMedium),

                      const SizedBox(height: 12),

                      Text(
                        "Siap melanjutkan perjalanan memasakmu?\nSemua inspirasinya ada di sini.",
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 24),

                      const CustomTextField(hint: "Email"),
                      const CustomTextField(
                        hint: "Password",
                        obscure: true,
                        suffix: Icon(Icons.visibility_off),
                      ),

                      const SizedBox(height: 12),

                      // Remember & Forgot
                      Row(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: false,
                                onChanged: (value) {},
                                activeColor: AppTheme.primaryGreen,
                              ),
                              const Text("Ingat saya"),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            "Lupa password?",
                            style: TextStyle(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Gradient Button Login
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeComplexPage(),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(
                                  0xFF4CAF50,
                                ), // Hijau yang sama dengan Home Page
                                Color(0xFF1B5E20), // Hijau tua
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1B5E20).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "Log In",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text("Atau masuk dengan"),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Social Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialButton("assets/images/icons/facebook.png"),
                          const SizedBox(width: 16),
                          _socialButton("assets/images/icons/google.png"),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Register redirect
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // balik ke Register
                        },
                        child: Text.rich(
                          TextSpan(
                            text: "Belum punya akun? ",
                            children: [
                              TextSpan(
                                text: "Daftar",
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

// Social Button Widget
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
