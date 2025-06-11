import 'package:flutter/material.dart';
import 'home_page.dart';
import 'chat_page.dart';
import 'community_page.dart';
import 'irrigation_page.dart'; 

class SoilPage extends StatelessWidget {
  const SoilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Soil Analysis')),
      body: const Center(
        child: Text('This is the Soil Analysis Page', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}


