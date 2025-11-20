import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestPage extends StatefulWidget {
  final SupabaseClient future;
  const TestPage({super.key, required this.future});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  Future<List<dynamic>> getCars() {
    return widget.future.from('cars').select();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getCars(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("HataCCCC: ${snapshot.error}"));
          }

          final cars = snapshot.data;

          return Center(child: Text("Datas: $cars"));
        },
      ),
    );
  }
}
