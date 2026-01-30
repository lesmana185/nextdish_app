import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'cooking_mode_sucses_page.dart'; // Pastikan nama file sesuai

class CookingModeStepsPage extends StatefulWidget {
  final String recipeName;
  final List<dynamic> steps; // Data langkah dinamis

  const CookingModeStepsPage(
      {super.key, required this.recipeName, required this.steps});

  @override
  State<CookingModeStepsPage> createState() => _CookingModeStepsPageState();
}

class _CookingModeStepsPageState extends State<CookingModeStepsPage> {
  final FlutterTts _flutterTts = FlutterTts();
  int _currentStepIndex = 0;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initCookingMode();
  }

  void _initCookingMode() async {
    // 1. Agar layar HP tidak mati
    WakelockPlus.enable();

    // 2. Setting Suara Bahasa Indonesia
    await _flutterTts.setLanguage("id-ID");
    await _flutterTts.setSpeechRate(0.5);

    // 3. Baca langkah pertama otomatis (tunggu 1 detik biar transisi smooth)
    await Future.delayed(const Duration(seconds: 1));
    _speakCurrentStep();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    WakelockPlus.disable(); // Matikan fitur layar nyala
    super.dispose();
  }

  Future<void> _speakCurrentStep() async {
    // Ambil teks langkah saat ini
    String text = widget.steps[_currentStepIndex].toString();

    // Hiasan sedikit agar robot lebih ramah
    String intro = "Langkah ke-${_currentStepIndex + 1}. ";

    setState(() => _isSpeaking = true);
    await _flutterTts.speak(intro + text);
    setState(() => _isSpeaking = false);
  }

  void _stopSpeaking() async {
    await _flutterTts.stop();
    setState(() => _isSpeaking = false);
  }

  void _nextStep() {
    _stopSpeaking();
    if (_currentStepIndex < widget.steps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
      _speakCurrentStep(); // Baca langkah selanjutnya
    } else {
      // Selesai, pindah ke halaman sukses
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CookingModeSuccessPage(recipeName: widget.recipeName),
        ),
      );
    }
  }

  void _prevStep() {
    _stopSpeaking();
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
      });
      _speakCurrentStep();
    }
  }

  // --- DIALOG KELUAR ---
  Future<bool> _showExitConfirmDialog() async {
    _stopSpeaking(); // Diamkan suara saat dialog muncul
    return await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 10,
            backgroundColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF59D),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                  ),
                  child: const Center(
                    child: Text(
                      "Keluar Dari Mode Masak?",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Serif'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        "Proses masak belum selesai. Panduan suara akan berhenti.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF38A169)),
                            child: const Text("YA",
                                style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey),
                            child: const Text("TIDAK",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_currentStepIndex + 1) / widget.steps.length;
    String currentStepText = widget.steps[_currentStepIndex].toString();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmDialog();
        if (shouldPop && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFE8F5E9),
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // --- HEADER ---
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final shouldPop = await _showExitConfirmDialog();
                            if (shouldPop && context.mounted)
                              Navigator.pop(context);
                          },
                          child: const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.close, color: Colors.black),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              widget.recipeName, // Judul Dinamis
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Serif'),
                            ),
                          ),
                        ),
                        // Indikator Suara
                        Icon(
                          _isSpeaking ? Icons.volume_up : Icons.volume_mute,
                          color: _isSpeaking ? Colors.green : Colors.grey,
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- BANNER INSTRUKSI ---
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 5)
                      ],
                    ),
                    child: Row(
                      children: [
                        Image.asset('assets/images/illustrasi/robotmic.png',
                            height: 50,
                            errorBuilder: (c, e, s) =>
                                const Icon(Icons.smart_toy)),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Ketuk kartu di bawah untuk membaca ulang suara.",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- PROGRESS BAR ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                            "Langkah ${_currentStepIndex + 1}/${widget.steps.length}",
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey.shade300,
                            color: const Color(0xFF63B685),
                            minHeight: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- KARTU LANGKAH (Bisa Diklik untuk Baca Ulang) ---
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_isSpeaking) {
                          _stopSpeaking();
                        } else {
                          _speakCurrentStep();
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: _isSpeaking
                              ? Border.all(color: Colors.green, width: 3)
                              : null,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Center(
                          child: SingleChildScrollView(
                            child: Text(
                              currentStepText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24, // Huruf Besar agar terbaca
                                height: 1.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- TOMBOL NAVIGASI BAWAH ---
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol Mundur
                  FloatingActionButton(
                    heroTag: "btn1",
                    onPressed: _currentStepIndex == 0 ? null : _prevStep,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),

                  // Tombol Lanjut (Next) - Paling Besar
                  SizedBox(
                    height: 70,
                    width: 70,
                    child: FloatingActionButton(
                      heroTag: "btn2",
                      onPressed: _nextStep,
                      backgroundColor: const Color(0xFF63B685),
                      child: const Icon(Icons.arrow_forward,
                          color: Colors.white, size: 30),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
