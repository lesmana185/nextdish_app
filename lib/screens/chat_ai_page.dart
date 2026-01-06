import 'package:flutter/material.dart';

// Model Data Chat Sederhana
class ChatMessage {
  final String senderName;
  final String message;
  final bool isUser; // True = User, False = AI
  final String avatarPath;

  ChatMessage({
    required this.senderName,
    required this.message,
    required this.isUser,
    required this.avatarPath,
  });
}

class ChatAIPage extends StatefulWidget {
  const ChatAIPage({super.key});

  @override
  State<ChatAIPage> createState() => _ChatAIPageState();
}

class _ChatAIPageState extends State<ChatAIPage> {
  final TextEditingController _textController = TextEditingController();

  // DATA DUMMY CHAT (Sesuai gambar)
  final List<ChatMessage> _messages = [
    ChatMessage(
      senderName: "Christal",
      isUser: true,
      avatarPath:
          "assets/images/home/profile.png", // Ganti sesuai aset user kamu
      message:
          "Di dapur masih ada nanas, sarden, sama santan. Ada rekomendasi masakan nggak?",
    ),
    ChatMessage(
      senderName: "AI",
      isUser: false,
      avatarPath:
          "assets/images/home/logochat.png", // Ganti sesuai aset robot kamu
      message:
          "“Siap! Dari nanas, sarden, dan santan, kamu bisa mencoba beberapa menu berikut 👇”\n"
          "🍲 Rekomendasi Menu:\n"
          "1. Sarden Masak Santan Nanas\n"
          "    Gurih, segar, dan cocok untuk lauk nasi hangat.\n"
          "2. Gulai Sarden Nanas\n"
          "    Perpaduan asam nanas dan santan yang kaya rasa.\n"
          "3. Sarden Kuah Santan Asam Manis\n"
          "    Ringan dan menyegarkan, pas untuk menu sehari-hari.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // Hijau Muda Background
      body: Column(
        children: [
          // 1. HEADER (Hijau Tua)
          Container(
            padding: const EdgeInsets.only(
              top: 40,
              bottom: 15,
              left: 10,
              right: 10,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFA5D6A7), // Hijau Header (Mirip desain)
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      size: 18,
                      color: Colors.black54,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      "Mode Chat AI",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                        color: Color(0xFF2E7D32), // Hijau Gelap Teks
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40), // Spacer penyeimbang
              ],
            ),
          ),

          // 2. LIST CHAT & MASCOT
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                // Mascot di Tengah Atas
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Image.asset(
                      'assets/images/illustrasi/robottunjuk.png', // Pastikan ada aset ini (robot nunjuk)
                      height: 100,
                      errorBuilder: (ctx, err, s) => const Icon(
                        Icons.smart_toy,
                        size: 80,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),

                // Render List Pesan
                ..._messages.map((msg) => _buildChatBubble(msg)).toList(),

                // Ruang kosong di bawah agar chat tidak ketutup input bar
                const SizedBox(height: 80),
              ],
            ),
          ),

          // 3. INPUT BAR (Floating Bottom)
          _buildInputBar(),
        ],
      ),
    );
  }

  // WIDGET: BUBBLE CHAT
  Widget _buildChatBubble(ChatMessage msg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: AssetImage(msg.avatarPath),
          ),
          const SizedBox(width: 12),

          // Nama & Pesan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.senderName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  msg.message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF555555), // Abu tua
                    height: 1.5, // Jarak antar baris
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET: INPUT BAR
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        10,
        20,
        30,
      ), // Padding bawah besar utk area safe
      decoration: const BoxDecoration(
        color: Colors.transparent, // Transparan agar menyatu dengan background
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFF63B685),
            width: 1.5,
          ), // Border Hijau
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: "Tanyakan Sesuatu...",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            // Icon Kamera
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.black54,
              ),
            ),
            // Icon Mic (Ada plus kecilnya di desain)
            Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.mic, color: Colors.black54),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, size: 8, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
