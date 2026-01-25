import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final bool obscure;
  final Widget? suffix;
  // 1. Definisikan variabel controller agar bisa disimpan
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.hint,
    this.obscure = false,
    this.suffix,
    // 2. Tambahkan di constructor (boleh null/optional)
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: controller, // 3. Pasang controller ke TextField asli
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon: suffix,
        ),
      ),
    );
  }
}
