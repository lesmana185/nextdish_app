import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart'; // <--- Import ini penting
import 'package:supabase_flutter/supabase_flutter.dart';

class ShareRecipePage extends StatefulWidget {
  const ShareRecipePage({super.key});

  @override
  State<ShareRecipePage> createState() => _ShareRecipePageState();
}

class _ShareRecipePageState extends State<ShareRecipePage> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _recipeDetailController = TextEditingController();

  File? _imageFile;
  bool _isUploading = false;

  // 1. FUNGSI PILIH GAMBAR
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Setelah pilih, lempar ke fungsi crop
      _cropImage(image.path);
    }
  }

  // 2. FUNGSI CROP FOTO (DENGAN PILIHAN RASIO)
  Future<void> _cropImage(String filePath) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        // Kita tidak memaksa aspectRatio, tapi memberi preset pilihan
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Foto Masakan',
            toolbarColor: const Color(0xFF63B685), // Warna Hijau NextDish
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset
                .ratio4x3, // Default 4:3 (cocok utk makanan)
            lockAspectRatio: false, // User BOLEH ganti rasio sesuka hati
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square, // 1:1
              CropAspectRatioPreset.ratio4x3, // 4:3
              CropAspectRatioPreset.ratio16x9, // 16:9
            ],
          ),
          IOSUiSettings(
            title: 'Edit Foto Masakan',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _imageFile = File(croppedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Gagal crop: $e");
    }
  }

  // 3. FUNGSI UPLOAD KE SUPABASE
  Future<void> _sharePost() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Harap login dulu!")));
      return;
    }

    if (_imageFile == null || _captionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gambar dan Caption wajib diisi!")));
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Upload Gambar ke Storage
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${user.id}.jpg';

      await Supabase.instance.client.storage
          .from('community_images')
          .upload(fileName, _imageFile!);

      final String imageUrl = Supabase.instance.client.storage
          .from('community_images')
          .getPublicUrl(fileName);

      // Simpan Data ke Database
      await Supabase.instance.client.from('community_posts').insert({
        'user_id': user.id,
        'user_name': user.userMetadata?['full_name'] ?? 'Chef NextDish',
        'user_avatar': user.userMetadata?['avatar_url'],
        'caption': _captionController.text,
        'recipe_title': _recipeDetailController.text,
        'image_url': imageUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Resep Berhasil Dibagikan! 🎉")));
        Navigator.pop(context, true); // Kirim sinyal sukses
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Gagal upload: $e")));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Komunitas",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF388E3C),
                              fontFamily: 'Serif')),
                      Text("Berbagi resep dengan\npengguna NextDish Lainnya",
                          style:
                              TextStyle(fontSize: 12, color: Colors.black87)),
                    ],
                  ),
                  Column(
                    children: [
                      Image.asset('assets/images/home/logosmall.png',
                          height: 40),
                      const Text("NextDish",
                          style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // CARD FORM
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: [
                    // Header Hijau
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: const BoxDecoration(
                        color: Color(0xFF63B685),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20)),
                      ),
                      child: const Center(
                          child: Text("Bagikan Resep Kamu",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16))),
                    ),

                    // Form Inputs
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Input Caption
                          _buildTextField(
                              controller: _captionController,
                              hint: "Caption (Misal: Resep andalan keluarga!)",
                              height: 50),
                          const SizedBox(height: 16),

                          // Image Upload Area (PREVIEW)
                          GestureDetector(
                            onTap:
                                _pickImage, // KLIK DISINI MEMBUKA GALLERY & CROP
                            child: Container(
                              height:
                                  200, // Sedikit lebih tinggi biar puas lihat fotonya
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.black87),
                                  image: _imageFile != null
                                      ? DecorationImage(
                                          image: FileImage(_imageFile!),
                                          fit: BoxFit
                                              .cover) // Tampilkan hasil crop
                                      : null),
                              child: _imageFile == null
                                  ? const Center(
                                      child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo,
                                            size: 32, color: Colors.grey),
                                        Text("Ketuk untuk tambah & crop foto",
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey))
                                      ],
                                    ))
                                  : null, // Kosongkan child jika gambar ada
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Input Detail Resep
                          _buildTextField(
                            controller: _recipeDetailController,
                            hint: "Nama Masakan / Detail Singkat",
                            height: 80,
                            maxLines: 3,
                          ),

                          const SizedBox(height: 24),

                          // Tombol Aksi
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isUploading ? null : _sharePost,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7CB342),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  child: _isUploading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2))
                                      : const Text("Bagikan",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFA6AAA9),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  child: const Text("Batal",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String hint,
      double? height,
      int maxLines = 1}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black87),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontWeight: FontWeight.normal, color: Colors.grey, fontSize: 12),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
