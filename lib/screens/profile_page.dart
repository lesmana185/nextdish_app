import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_profile.dart'; // Pastikan file ini ada
import 'help_center_page.dart'; // Pastikan file ini ada

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Variabel Data User
  String _userName = "Loading...";
  String _email = "Loading...";
  String? _avatarUrl;

  // Variabel Statistik
  int _sharedCount = 0;
  int _favCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadStats();
  }

  // 1. AMBIL DATA USER
  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      if (mounted) {
        setState(() {
          _userName = user.userMetadata?['full_name'] ?? "Chef NextDish";
          _email = user.email ?? "";
          _avatarUrl = user.userMetadata?['avatar_url'];
        });
      }
    }
  }

  // 2. HITUNG STATISTIK
  Future<void> _loadStats() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final sharedResponse = await Supabase.instance.client
          .from('community_posts')
          .count(CountOption.exact)
          .eq('user_id', user.id);

      final favResponse = await Supabase.instance.client
          .from('favorite_recipes')
          .count(CountOption.exact)
          .eq('user_id', user.id);

      if (mounted) {
        setState(() {
          _sharedCount = sharedResponse;
          _favCount = favResponse;
        });
      }
    } catch (e) {
      debugPrint("Gagal load statistik: $e");
    }
  }

  // 3. FUNGSI LOGOUT
  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      // Kembali ke halaman Login
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      // TIDAK ADA BOTTOM NAVIGATION BAR DISINI (Sudah diurus MainScaffold)

      body: Column(
        children: [
          // 1. HEADER HIJAU LENGKUNG
          Container(
            height: 120,
            decoration: const BoxDecoration(
              color: Color(0xFF81C784),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  "Profil",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),

          // 2. KONTEN SCROLLABLE
          Expanded(
            child: SingleChildScrollView(
              // Tambahkan padding bawah agar konten terbawah tidak tertutup Nav Bar Induk
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
              child: Column(
                children: [
                  // KARTU USER
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 5)
                      ],
                    ),
                    child: Row(
                      children: [
                        // Foto Profil
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 32,
                            backgroundImage: _avatarUrl != null
                                ? NetworkImage(_avatarUrl!)
                                : const AssetImage(
                                        'assets/images/home/profile.png')
                                    as ImageProvider,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _email,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),

                              // Tombol Edit Profil
                              GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const EditProfilePage()),
                                  );
                                  _loadUserData(); // Refresh setelah edit
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7CB342),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    "Edit Profil",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Tombol Logout
                        IconButton(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout,
                              color: Colors.brown, size: 28),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Statistik",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 20),

                  // GRID STATISTIK
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildStatCard("$_sharedCount", "Resep\nDi Share"),
                            const SizedBox(height: 16),
                            _buildStatCard("$_favCount", "Resep\nFavorit"),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 220,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA5D6A7),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 5)
                            ],
                          ),
                          child: Stack(
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("5,3 kg",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text("Sampah\nDikomposkan",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black87)),
                                ],
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Image.asset(
                                  'assets/images/illustrasi/robotmic.png',
                                  height: 80,
                                  errorBuilder: (c, e, s) =>
                                      const Icon(Icons.smart_toy, size: 60),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // TOMBOL PUSAT BANTUAN
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HelpCenterPage()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA6AAA9),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: const Text("Pusat Bantuan",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String count, String label) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(count,
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87)),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
