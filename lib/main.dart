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
import 'admin/data/data_customer.dart';
import 'services/dio_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DioHelper.init();
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

  // [FIX] Key untuk AktivitasPage agar bisa memanggil method-nya dari luar
  final GlobalKey<AktivitasPageState> _aktivitasKey =
      GlobalKey<AktivitasPageState>();

  // [FIX] Callback yang dikirim ke BerandaPage:
  // saat tombol "Lihat Detail" ditekan → pindah ke tab Aktivitas (index 3)
  // lalu suruh AktivitasPage expand item dengan id tertentu
  void _bukaDetailAktivitas(int? idPesanan) {
    setState(() => _selectedIndex = 3);
    // Tunggu frame selesai dulu baru expand, supaya widget sudah mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _aktivitasKey.currentState?.bukaDetail(idPesanan);
    });
  }

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      // [FIX] BerandaPage menerima callback onLihatDetail
      BerandaPage(onLihatDetail: _bukaDetailAktivitas),
      const MenuPage(),
      const KeranjangPage(),
      // [FIX] AktivitasPage diberi GlobalKey agar state-nya bisa diakses
      AktivitasPage(key: _aktivitasKey),
      const ProfilPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
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
    DashboardAdmin(),
    PesananAdminPage(),
    KelolaMenuPage(),
    DataCustomerPage(),
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