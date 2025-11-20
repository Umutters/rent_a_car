import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestPage extends StatefulWidget {
  final SupabaseClient supabaseClient;

  const TestPage({super.key, required this.supabaseClient});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  // Verileri tutacağımız liste
  List<dynamic> _cars = [];
  bool _isLoading = true; // Yükleniyor mu?

  @override
  void initState() {
    super.initState();
    _fetchCars();
  }

  Future<void> _fetchCars() async {
    try {
      // 1. Veriyi çek (parametre olarak gelen client'ı kullan)
      final response = await widget.supabaseClient.from('cars').select();

      // 2. Konsola yazdır (Emin olmak için)
      print("GELEN VERİ: $response");

      // 3. EKRANI GÜNCELLE (En önemli kısım burası!)
      if (mounted) {
        setState(() {
          _cars = response;
          _isLoading = false; // Yükleme bitti
        });
      }
    } catch (e) {
      print("HATA: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Araç Listesi")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Yükleniyor...
          : _cars.isEmpty
          ? const Center(child: Text("Hiç araç bulunamadı."))
          : ListView.builder(
              itemCount: _cars.length,
              itemBuilder: (context, index) {
                final car = _cars[index];
                // DİKKAT: Buradaki 'brand' veya 'model' veritabanındaki
                // kolon isimlerinle BİREBİR aynı olmalı!
                return Card(child: Text(""));
              },
            ),
    );
  }
}
