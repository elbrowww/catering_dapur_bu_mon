import 'package:flutter/material.dart';
import 'page/mulai.dart';
import 'page/navbar.dart';
import 'page/beranda.dart';
import 'page/menu.dart';

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
      home: Mulai(), // Halaman pertama (splash/onboarding)
    );
  }
}

// ============================================================
// MAIN SCREEN — satu-satunya tempat navbar dipanggil
// Dipanggil setelah login berhasil dari login.dart
// ============================================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    BerandaPage(),                        // index 0 - Beranda
    MenuPage(),                           // index 1 - Menu
    _PlaceholderPage(title: 'Keranjang'), // index 2 - Keranjang
    _PlaceholderPage(title: 'Aktivitas'), // index 3 - Aktivitas
    _PlaceholderPage(title: 'Profil'),    // index 4 - Profil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],
      // Navbar dipanggil SEKALI, otomatis muncul di semua halaman
      bottomNavigationBar: CustomNavbar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Halaman $title',
        style: const TextStyle(fontSize: 24, color: Colors.black54),
      ),
    );
  }
}