import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widget/custom_textfield.dart';
// import '../theme/app_theme.dart'; // Hapus ini agar tidak error
import 'package:nextdish_app/screens/home_page.dart'; // Home Baru
import 'login_screen.dart'; // Import Login Screen

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // --- WARNA ---
  // Definisikan warna di sini
  final Color primaryGreen = const Color(0xFF63B685);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- 1. LOGIKA LOGIN GOOGLE ---
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback',
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- 2. LISTENER AUTH ---
  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        _checkUserAndNavigate();
      }
    });
  }

  // --- 3. CEK USER BARU / LAMA ---
  Future<void> _checkUserAndNavigate() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final data = await Supabase.instance.client
        .from('user_ingredients')
        .select()
        .eq('user_id', user.id)
        .limit(1);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (data.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: primaryGreen, // Gunakan variabel lokal
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
                        "Daftar Akun",
                        style: textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "NextDish",
                        style: textTheme.titleMedium?.copyWith(
                          color: primaryGreen, // Gunakan variabel lokal
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        "Kami di sini untuk membantumu mengolah bahan yang ada menjadi hidangan lezat. Siap mulai?",
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Input Fields
                      CustomTextField(
                        hint: "Nama Lengkap",
                        controller: _nameController,
                      ),
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

                      const SizedBox(height: 24),

                      // TOMBOL DAFTAR
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Silakan gunakan Google untuk saat ini",
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
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF7AD9A6), // Hijau terang
                                  Color(0xFF63B685), // Hijau utama
                                ],
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
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

                      // Divider
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

                      // Social Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialButton("assets/images/icons/facebook.png", () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Fitur Facebook belum tersedia"),
                              ),
                            );
                          }),
                          const SizedBox(width: 16),
                          // Google Login (AKTIF)
                          _socialButton("assets/images/icons/google.png", () {
                            _signInWithGoogle();
                          }),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Footer Link ke Login
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text.rich(
                          TextSpan(
                            text: "Sudah punya akun? ",
                            children: [
                              TextSpan(
                                text: "Log In",
                                style: TextStyle(
                                  color: primaryGreen, // Gunakan variabel lokal
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
        padding: const EdgeInsets.all(10),
        child: Image.asset(assetPath, width: 22, height: 22),
      ),
    );
  }
}
