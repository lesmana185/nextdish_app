import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'compost_guide_page.dart';

class CompostLandingPage extends StatefulWidget {
  const CompostLandingPage({super.key});

  @override
  State<CompostLandingPage> createState() => _CompostLandingPageState();
}

class _CompostLandingPageState extends State<CompostLandingPage> {
  List<Map<String, dynamic>> _wasteItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSpoiledItems();
  }

  // AMBIL DATA YANG HAMPIR BASI DARI SUPABASE
  Future<void> _fetchSpoiledItems() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('user_ingredients')
          .select()
          .eq('user_id', user.id)
          .order('expiry_date', ascending: true);

      final List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(response);

      // Filter Logic: Ambil yang sisa harinya <= 3 (Hampir Basi)
      final spoiled = data.where((item) {
        final expiryStr = item['expiry_date'] ?? '';
        if (expiryStr.isEmpty) return false;
        final expiry = DateTime.parse(expiryStr);
        final diff = expiry.difference(DateTime.now()).inDays;
        return diff <= 3;
      }).toList();

      setState(() {
        // Tambahkan properti 'selected' untuk UI checkbox
        _wasteItems = spoiled.map((e) => {...e, 'selected': true}).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching compost items: $e");
      setState(() => _isLoading = false);
    }
  }

  // Helper Gambar
  String _getImageAsset(String name) {
    final n = name.toLowerCase();
    if (n.contains('telur')) return 'assets/images/ingredients/telur.png';
    if (n.contains('susu')) return 'assets/images/ingredients/susu.png';
    if (n.contains('pisang')) return 'assets/images/ingredients/pisang.png';
    if (n.contains('ayam') || n.contains('daging'))
      return 'assets/images/ingredients/ayam.png';
    if (n.contains('sayur') || n.contains('bayam'))
      return 'assets/images/ingredients/sayur.png';
    return 'assets/images/ingredients/sayur.png';
  }

  @override
  Widget build(BuildContext context) {
    int selectedCount = _wasteItems.where((e) => e['selected']).length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF63B685),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Compost Assistant",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset('assets/images/illustrasi/robotmic.png',
                height: 35),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF63B685)))
          : Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const Text("Kelola sisa makanan dengan bijak",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 30),
                      const Center(
                          child: Text("Terdeteksi Hampir Basi / Expired",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black54))),
                      const SizedBox(height: 16),

                      // LIST ITEM
                      Expanded(
                        child: _wasteItems.isEmpty
                            ? Center(
                                child: Text(
                                    "Wah, dapurmu aman! Tidak ada sampah.",
                                    style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                                itemCount: _wasteItems.length,
                                itemBuilder: (context, index) {
                                  final item = _wasteItems[index];
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        item['selected'] = !item['selected'];
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: item['selected']
                                            ? const Color(0xFFE8F5E9)
                                            : Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(16),
                                        border: item['selected']
                                            ? Border.all(
                                                color: Colors.green.shade200)
                                            : Border.all(
                                                color: Colors.transparent),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
                                              blurRadius: 5,
                                              offset: const Offset(0, 2))
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            _getImageAsset(item['name']),
                                            width: 50,
                                            height: 50,
                                            errorBuilder: (c, e, s) =>
                                                const Icon(Icons.delete_outline,
                                                    size: 40,
                                                    color: Colors.grey),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(item['name'],
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16)),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                                color: const Color(0xFFEF5350),
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: const Text("Action Needed",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          const SizedBox(width: 10),
                                          Icon(
                                            item['selected']
                                                ? Icons.check_circle
                                                : Icons.circle_outlined,
                                            color: item['selected']
                                                ? Colors.green
                                                : Colors.grey,
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 80), // Space for button
                    ],
                  ),
                ),

                // TOMBOL LANJUTKAN
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: selectedCount > 0
                          ? () {
                              // Ambil hanya item yang dipilih
                              final selectedItems = _wasteItems
                                  .where((e) => e['selected'] == true)
                                  .toList();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  // KIRIM DATA KE HALAMAN GUIDE
                                  builder: (context) =>
                                      CompostGuidePage(items: selectedItems),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38A169),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                      child: Text("Lanjutkan ($selectedCount item)",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
