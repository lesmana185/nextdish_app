import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiRecipeService {
  static String get apiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  // --- 1. FITUR CARI RESEP (HASILKAN JSON LIST) ---
  Future<Map<String, dynamic>> generateRecipeFromKitchen() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("Belum login");

      // Ambil Bahan dari Supabase
      final response = await Supabase.instance.client
          .from('user_ingredients')
          .select('name, quantity')
          .eq('user_id', user.id);

      final List<dynamic> data = response;
      String ingredientsList = data.isEmpty
          ? "Telur, Nasi Putih, Bawang Merah, Bawang Putih, Kecap, Garam, Gula, Minyak Goreng"
          : data.map((e) => "${e['name']}").join(', ');

      // --- PROMPT BARU: KOMBINASI SIMPLE & DETAIL ---
      final prompt = '''
        Saya punya stok bahan di dapur: $ingredientsList.
        
        TUGAS:
        Buatkan 6 (ENAM) sampai 8 (DELAPAN) Rekomendasi Resep Masakan Indonesia sehari-hari yang SIMPLE dan WAJAR.

        ATURAN MUTLAK (WAJIB DIPATUHI):
        1. **PISAHKAN BAHAN UTAMA!** Jangan memaksakan semua bahan masuk ke satu resep.
           - Jika ada Ayam dan Roti, buatlah resep "Ayam Goreng" (Terpisah) dan "Roti Bakar" (Terpisah). JANGAN DIGABUNG.
           - Prioritaskan satu bahan utama per resep.
        
        2. **NAMA MASAKAN HARUS PENDEK & UMUM (Sesuai Database Gambar).**
           - Gunakan nama menu standar restoran.
           - Hapus kata sifat berlebihan di Judul (seperti "Pedas", "Spesial", "Lada Hitam").
           - CONTOH BENAR: "Ayam Goreng", "Nasi Goreng", "Soto Ayam", "Roti Bakar", "Telur Dadar".
           - CONTOH SALAH: "Ayam Goreng Lada Garam", "Roti Bakar Spesial Telur".

        3. **TARGET PENGGUNA:** Pemula yang TIDAK BISA MEMASAK. 
           - Bagian "cara" HARUS SANGAT DETAIL (seperti script video tutorial). 
           - Jelaskan besar api kompor, tanda kematangan (warna/bau), dan teknik memotong.
           - Pastikan semua bahan yang tertulis benar-benar dipakai di langkah-langkahnya.

        FORMAT OUTPUT HARUS JSON OBJECT MURNI:
        {
          "recipes": [
            {
              "nama": "Nama Umum (Contoh: Ayam Goreng)",
              "deskripsi": "Deskripsi singkat yang menggugah selera.",
              "waktu": "XX Menit",
              "porsi": "X Orang",
              "kalori": "XXX kkal",
              "status": "Tersedia",
              "bahan": ["Bahan 1 (takaran)", "Bahan 2 (takaran)"],
              "cara": [
                " Penjelasan detail...",
                " Penjelasan detail..."
              ]
            }
          ]
        }
      ''';

      // Timeout 60 detik agar AI sempat menulis detail
      final jsonString = await _sendToGroqJson(prompt).timeout(
        const Duration(seconds: 60),
        onTimeout: () =>
            throw TimeoutException("AI sedang berpikir keras, coba lagi..."),
      );

      // Bersihkan JSON
      int startIndex = jsonString.indexOf('{');
      int endIndex = jsonString.lastIndexOf('}');
      if (startIndex == -1 || endIndex == -1) {
        throw Exception("Format JSON Rusak");
      }

      String cleanJson = jsonString.substring(startIndex, endIndex + 1);
      return jsonDecode(cleanJson);
    } catch (e) {
      print("Error AI: $e");
      // FALLBACK DAFTAR RESEP (OFFLINE)
      return {
        "recipes": [
          {
            "nama": "Nasi Goreng",
            "deskripsi": "Resep darurat saat koneksi internet terputus.",
            "waktu": "20 Menit",
            "porsi": "2 Orang",
            "kalori": "400 kkal",
            "status": "Tersedia",
            "bahan": [
              "Nasi Putih",
              "2 butir Telur",
              "Bawang Merah",
              "Kecap Manis"
            ],
            "cara": [
              "Iris tipis bawang merah. Siapkan wajan dengan api sedang.",
              "Tuang sedikit minyak, tumis bawang sampai harum.",
              "Masukkan telur, orak-arik sampai matang.",
              "Masukkan nasi dan kecap, aduk rata. Sajikan."
            ]
          },
          {
            "nama": "Telur Dadar",
            "deskripsi": "Lauk simpel dan cepat.",
            "waktu": "10 Menit",
            "porsi": "1 Orang",
            "kalori": "200 kkal",
            "status": "Tersedia",
            "bahan": ["2 butir Telur", "Garam", "Minyak Goreng"],
            "cara": [
              "Kocok telur dengan sedikit garam.",
              "Panaskan minyak di wajan.",
              "Goreng telur hingga matang kedua sisinya."
            ]
          }
        ]
      };
    }
  }

  // --- 2. FITUR CHATBOT ---
  Future<String> chatWithChef(String userText) async {
    const systemMessage =
        "Kamu adalah Chef Senior yang ramah. Jawablah pertanyaan seputar masakan dengan detail dan mudah dimengerti untuk pemula.";
    return await _sendToGroqChat(systemMessage, userText);
  }

  // --- HELPER 1: KIRIM JSON ---
  Future<String> _sendToGroqJson(String userContent) async {
    try {
      final url = Uri.parse(_baseUrl);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "response_format": {"type": "json_object"},
          "messages": [
            {
              "role": "system",
              "content": "Kamu adalah API Resep. Outputmu HANYA JSON."
            },
            {"role": "user", "content": userContent}
          ],
          "temperature": 0.5, // Temperature rendah agar patuh aturan nama
          "max_tokens": 6000
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['choices'][0]['message']['content'];
      } else {
        throw Exception("Gagal: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Gagal koneksi AI: $e");
    }
  }

  // --- HELPER 2: KIRIM CHAT BIASA ---
  Future<String> _sendToGroqChat(String sys, String user) async {
    try {
      final url = Uri.parse(_baseUrl);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {"role": "system", "content": sys},
            {"role": "user", "content": user}
          ],
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['choices'][0]['message']['content'];
      } else {
        return "Maaf, Chef sedang sibuk. (Error ${response.statusCode})";
      }
    } catch (e) {
      return "Koneksi internetmu sepertinya bermasalah.";
    }
  }
}
