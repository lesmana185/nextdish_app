import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiRecipeService {
  static String get apiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  Future<Map<String, dynamic>> generateRecipeFromKitchen() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("Belum login");

      // 1. Ambil Bahan
      final response = await Supabase.instance.client
          .from('user_ingredients')
          .select('name, quantity')
          .eq('user_id', user.id);

      final List<dynamic> data = response;
      String ingredientsList = data.isEmpty
          ? "Telur, Nasi Putih, Bawang Merah, Bawang Putih, Kecap"
          : data.map((e) => "${e['name']}").join(', ');

      // 2. PROMPT UNTUK DAFTAR RESEP (Max 3 biar cepat)
      final prompt = '''
        Saya punya bahan: $ingredientsList.
        
        TUGAS:
        Buatkan 3 (TIGA) Rekomendasi Resep Masakan Indonesia yang bisa dibuat atau dikombinasikan dengan bahan tersebut.
        
        FORMAT OUTPUT HARUS JSON OBJECT SEPERTI INI:
        {
          "recipes": [
            {
              "nama": "Nama Masakan 1",
              "deskripsi": "Deskripsi singkat 1",
              "waktu": "30 Menit",
              "porsi": "2 Orang",
              "kalori": "300 kkal",
              "status": "Tersedia",
              "bahan": ["Bahan A", "Bahan B"],
              "bumbu": ["Bumbu A", "Bumbu B"],
              "cara": ["Langkah 1", "Langkah 2"]
            },
            {
               "nama": "Nama Masakan 2",
               ...
            }
          ]
        }
      ''';

      final jsonString = await _sendToGroqJson(prompt).timeout(
        const Duration(
            seconds: 20), // Tambah waktu dikit karena generate 3 resep
        onTimeout: () => throw TimeoutException("Koneksi lambat"),
      );

      // Bersihkan JSON
      int startIndex = jsonString.indexOf('{');
      int endIndex = jsonString.lastIndexOf('}');
      if (startIndex == -1 || endIndex == -1)
        throw Exception("Format JSON Rusak");

      String cleanJson = jsonString.substring(startIndex, endIndex + 1);
      return jsonDecode(cleanJson);
    } catch (e) {
      print("Error AI: $e");
      // FALLBACK DAFTAR RESEP (OFFLINE)
      return {
        "recipes": [
          {
            "nama": "Nasi Goreng Spesial (Offline)",
            "deskripsi": "Menu darurat saat internetmu putus.",
            "waktu": "15 Menit",
            "porsi": "2 Orang",
            "kalori": "350 kkal",
            "status": "Tersedia",
            "bahan": ["Nasi", "Telur", "Bawang"],
            "cara": ["Tumis bumbu", "Masukan nasi", "Sajikan"]
          },
          {
            "nama": "Telur Dadar Crispy (Offline)",
            "deskripsi": "Telur dadar enak dan renyah.",
            "waktu": "10 Menit",
            "porsi": "1 Orang",
            "kalori": "150 kkal",
            "status": "Tersedia",
            "bahan": ["Telur", "Tepung", "Minyak"],
            "cara": ["Kocok telur", "Goreng kering", "Tiriskan"]
          }
        ]
      };
    }
  }

  Future<String> _sendToGroqJson(String userContent) async {
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
        "temperature": 0.5,
        "max_tokens": 2000
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['choices'][0]['message']['content'];
    } else {
      throw Exception("Gagal: ${response.statusCode}");
    }
  }

  // Fungsi chat tetap sama...
  Future<String> chatWithChef(String userText) async {
    // ... (kode chat sama seperti sebelumnya)
    return ""; // Placeholder biar gak error di copy paste
  }
}
