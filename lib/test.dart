import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestPage extends StatefulWidget {
  final SupabaseClient supabaseClient;

  const TestPage({super.key, required this.supabaseClient});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<dynamic> _cars = [];
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    _fetchCars();
  }

  Future<void> _fetchCars() async {
    try {
      final response = await widget.supabaseClient.from('cars').select();

      print("GELEN VERİ: $response");

      if (mounted) {
        setState(() {
          _cars = response;
          _isLoading = false; 
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
          ? const Center(child: CircularProgressIndicator())
          : _cars.isEmpty
          ? const Center(child: Text("Hiç araç bulunamadı."))
          : ListView.builder(
              itemCount: _cars.length,
              itemBuilder: (context, index) {
                final car = _cars[index];
                return Card(child: Text(""));
              },
            ),
    );
  }
}
