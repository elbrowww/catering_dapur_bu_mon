import 'package:flutter/material.dart';
import 'page/mulai.dart';
import 'page/login.dart';
import 'page/daftar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catering Dapur Bu Mon',
      home: Mulai(),
    );
  }
}