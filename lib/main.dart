import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'features/beranda/mulai.dart';
import 'features/shared/navbar.dart';
import 'features/beranda/beranda.dart';
import 'features/menu/menu.dart';
import 'features/keranjang/keranjang.dart';
import 'features/aktivitas/aktivitas.dart';
import 'features/profil/profil.dart';
import 'admin/shared/navbar_owner.dart';

import 'admin/dashboard/dashboard_admin.dart';
import 'admin/data/pesanan_admin.dart';
import 'admin/data/kelola_menu.dart';
import 'admin/data/data_customer.dart'; // ← tambah import
import 'services/dio_helper.dart'; // ← tambah ini

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  DioHelper.init(); // 🔥 WAJIB (init interceptor)

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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
    DashboardAdmin(),    // index 0
    PesananAdminPage(),  // index 1
    KelolaMenuPage(),    // index 2
    DataCustomerPage(),  // index 3 ← ganti dari _PlaceholderPage
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