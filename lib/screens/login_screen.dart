import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widget/custom_textfield.dart';
// Import MainScaffold (Wadah Utama Aplikasi)
import '../main_scaffold.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  final Color primaryGreen = const Color(0xFF63B685);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- 1. LISTENER AUTH (PENTING) ---
  @override
  void initState() {
    super.initState();
    // Mendengarkan perubahan status login (misal setelah balik dari browser Google)
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        _goToHome();
      }
    });
  }

  // --- 2. LOGIKA LOGIN GOOGLE ---
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      // Ganti URL ini dengan URL Project kamu jika perlu
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback',
      );
      // Catatan: Setelah ini sukses, browser akan terbuka.
      // Saat kembali ke aplikasi, listener di initState akan menangkap event 'signedIn'.
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error Login: $error'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // --- 3. NAVIGASI KE RUMAH UTAMA (PERBAIKAN DISINI) ---
  void _goToHome() {
    if (!mounted) return;

    // Matikan loading
    setState(() => _isLoading = false);

    // KITA TIDAK PERLU CEK DATABASE LAGI.
    // HomePage (Smart Home) yang akan otomatis mengecek isi kulkas nanti.
    // Kita langsung lempar user ke MainScaffold (Induk Navigasi).

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainScaffold()),
      (route) =>
          false, // Hapus riwayat agar user tidak bisa tekan Back ke Login
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: primaryGreen,
      body: SafeArea(
        child: Stack(
          children: [
            // Tombol Kembali
            Positioned(
              top: 16,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  "‹ Kembali",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            // Card Putih Utama
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
                      Text(
                        "Log In",
                        style: textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "NextDish",
                        style: textTheme.titleMedium?.copyWith(
                          color: primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Siap melanjutkan perjalanan memasakmu?\nSemua inspirasinya ada di sini.",
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Input Field (UI Saja, karena pakai Google Login)
                      CustomTextField(
                        hint: "Email",
                        controller: _emailController,
                      ),
                      CustomTextField(
                        hint: "Password",
                        obscure: true,
                        suffix: const Icon(Icons.visibility_off),
                        controller: _passwordController,
                      ),

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: false,
                                onChanged: (v) {},
                                activeColor: primaryGreen,
                              ),
                              const Text("Ingat saya"),
                            ],
                          ),
                          const Spacer(),
                          const Text(
                            "Lupa password?",
                            style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tombol Login Manual (Dummy)
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Silakan gunakan tombol Google di bawah 👇",
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF1B5E20)],
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
                          _socialButton(
                            "assets/images/icons/facebook.png",
                            () {},
                          ),
                          const SizedBox(width: 16),
                          // TOMBOL GOOGLE (YANG BEKERJA)
                          _socialButton(
                            "assets/images/icons/google.png",
                            _signInWithGoogle,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text.rich(
                          TextSpan(
                            text: "Belum punya akun? ",
                            children: [
                              TextSpan(
                                text: "Daftar",
                                style: TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Loading Overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _socialButton(String assetPath, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Image.asset(assetPath, width: 22, height: 22),
      ),
    );
  }
}
