import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 1. Import ini untuk keamanan

class AiRecipeService {
  // 2. GANTI HARDCODED KEY DENGAN DOTENV
  // static const String apiKey = '...'; <--- INI BAHAYA

  // GUNAKAN INI (Pastikan di file .env sudah ada GROQ_API_KEY):
  static String get apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  // --- FUNGSI 1: CARI RESEP (LOGIKA BARU - SUPER DETAIL & BANYAK) ---
  Future<String> generateRecipeFromKitchen() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return "Error: Kamu belum login.";

      final response = await Supabase.instance.client
          .from('user_ingredients')
          .select('name, quantity')
          .eq('user_id', user.id);

      final List<dynamic> data = response;
      String ingredientsList = data.isEmpty
          ? "Bahan dasar rumahan (Telur, Nasi, Bawang)"
          : data.map((e) => "${e['name']}").join(', ');

      // --- PROMPT BARU: MODE INSTRUKTUR CEREWET & TELITI ---
      final prompt = '''
        Saya punya bahan: $ingredientsList.
        
        PERANMU:
        Kamu adalah Chef Profesional yang sangat perfeksionis dan sedang mengajari orang yang TIDAK BISA MASAK sama sekali (Pemula Total).
        
        TUGAS UTAMA:
        Buatkan 15-20 Rekomendasi Resep Masakan Indonesia yang LEZAT.
        
        ATURAN FATAL (JANGAN DILANGGAR):
        1. **CONSISTENCY CHECK**: SEMUA bahan yang kamu tulis di list 'bahan_utama' dan 'bumbu' WAJIB, HARUS, KUDU muncul di dalam langkah-langkah 'cara'. Jangan sampai ada bahan yang ditulis tapi tidak disuruh memasukkannya.
        2. **MICRO-STEPS**: Jangan menyingkat langkah. 
           - SALAH: "Tumis bumbu halus."
           - BENAR: "Siapkan wajan di atas kompor. Tuang 3 sdm minyak goreng. Nyalakan api sedang. Tunggu 1 menit sampai minyak panas. Masukkan bumbu halus. Aduk terus jangan berhenti selama 3 menit sampai warnanya menggelap dan baunya harum."
        3. **PREPARATION FIRST**: Langkah awal harus selalu persiapan (Cuci, Potong, Kupas) sebelum menyalakan kompor.
        4. **TAKARAN JELAS**: Gunakan takaran sendok (sdm/sdt), butir, atau gram. Jangan "secukupnya" jika bisa dihindari.
        
        FORMAT OUTPUT (JSON ARRAY):
        [
          {
            "nama": "Nama Masakan",
            "waktu": "45 Menit",
            "kalori": "350 kkal",
            "status": "Tersedia", 
            "status_text": "Semua Bahan Tersedia",
            "bahan_utama": ["500 gr Daging Ayam (Potong dadu)", "2 piring Nasi Putih"],
            "bumbu": ["1 sdt Garam", "3 sdm Kecap Manis", "2 siung Bawang Putih", "300 ml Air", "Minyak Goreng"],
            "cara": [
               "1. (Persiapan) Cuci bersih daging ayam di air mengalir, lalu tiriskan agar tidak berair.", 
               "2. (Persiapan Bumbu) Kupas bawang putih, lalu cincang sangat halus di atas talenan.",
               "3. (Memasak) Siapkan wajan, tuang 5 sdm minyak goreng. Nyalakan api sedang.",
               "4. Tunggu minyak panas (sekitar 30 detik), lalu masukkan cincangan bawang putih.",
               "5. Tumis bawang sebentar sampai layu, lalu masukkan Daging Ayam.",
               "6. Aduk-aduk ayam sampai warnanya berubah jadi putih pucat (setengah matang).",
               "7. Tuangkan 300ml Air ke dalam wajan. Biarkan mendidih.",
               "8. Masukkan 3 sdm Kecap Manis dan 1 sdt Garam. Aduk rata.",
               "9. Kecilkan api (api lilin), tutup wajan, dan biarkan selama 15 menit agar bumbu meresap (proses ungkep).",
               "10. Cicipi sedikit kuahnya. Jika kurang asin, tambahkan sedikit garam.",
               "11. Matikan kompor. Sajikan di piring selagi hangat."
            ]
          }
        ]
      ''';

      return await _sendToGroqJson(prompt);
    } catch (e) {
      return "Error Sistem: $e";
    }
  }

  // --- FUNGSI 2: CHATBOT ---
  Future<String> chatWithChef(String userText) async {
    const systemMessage =
        "Kamu adalah Chef Pembimbing yang sabar. Disini kamu HANYA MENJELASKAN TENTANG MAKANAN DAN RESEP Jelaskan jawabanmu langkah demi langkah untuk pemula. Dan JIKA ADA YANG MENANYAKAN TENTANG YANG BUKAN SOAL MAKANAN ATAU RESEP MAKANAN ada meminta maaf karena tidak bisa menjawabnya kamu hanya bisa menjawab tentang MAKANAN, MINUMAN DAN RESEPNYA";
    return await _sendToGroqChat(systemMessage, userText);
  }

  // --- PRIVATE HELPER (JSON) ---
  Future<String> _sendToGroqJson(String userContent) async {
    try {
      final url = Uri.parse(_baseUrl);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey', // Ini sekarang membaca dari .env
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "response_format": {"type": "json_object"},
          "messages": [
            {
              "role": "system",
              "content":
                  "Kamu adalah API Resep. Outputmu HANYA JSON Object dengan key 'recipes' berisi array resep."
            },
            {"role": "user", "content": userContent}
          ],
          "temperature": 0.4
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['choices'][0]['message']['content'];
      } else {
        return "[]";
      }
    } catch (e) {
      return "[]";
    }
  }

  // --- PRIVATE HELPER (CHAT) ---
  Future<String> _sendToGroqChat(String sys, String user) async {
    try {
      final url = Uri.parse(_baseUrl);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey', // Ini sekarang membaca dari .env
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {"role": "system", "content": sys},
            {"role": "user", "content": user}
          ],
          "temperature": 0.7
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['choices'][0]['message']['content'];
      } else {
        return "Error API: ${response.statusCode}";
      }
    } catch (e) {
      return "Error Koneksi: $e";
    }
  }
}
