import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'page/mulai.dart';
import 'page/navbar.dart';
import 'page/beranda.dart';
import 'page/menu.dart';
import 'page/keranjang.dart';
import 'page/aktivitas.dart';
import 'page/profil.dart';
import 'admin/navbar_owner.dart';
import 'admin/loginadmin.dart';
import 'admin/dashboard_admin.dart';
import 'admin/pesanan_admin.dart';
import 'admin/kelola_menu.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catering Dapur Bu Mon',
      home: const Mulai(),
    );
  }
}

// ── MainScreen untuk Customer ─────────────────────────────────
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    BerandaPage(),
    MenuPage(),
    KeranjangPage(),
    AktivitasPage(),
    ProfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomNavbar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}

// ── MainOwner untuk Owner/Admin ───────────────────────────────
class MainOwner extends StatefulWidget {
  const MainOwner({super.key});

  @override
  State<MainOwner> createState() => _MainOwnerState();
}

class _MainOwnerState extends State<MainOwner> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardAdmin(),                       // ← sudah disambungkan
    _PlaceholderPage(title: 'Pesanan'),
    _PlaceholderPage(title: 'Kelola Menu'),
    _PlaceholderPage(title: 'Data Customer'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavbarOwner(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}

// ── Placeholder sementara ─────────────────────────────────────
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