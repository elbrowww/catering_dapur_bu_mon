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

  // GlobalKey untuk AktivitasPage - sekarang bisa diakses karena state sudah public
  final GlobalKey<AktivitasPageState> _aktivitasKey =
      GlobalKey<AktivitasPageState>();

  // GlobalKey untuk BerandaPage — supaya bisa panggil refreshAvatar()
  final GlobalKey<BerandaPageState> _berandaKey =
      GlobalKey<BerandaPageState>();

  void _bukaDetailAktivitas(int? idPesanan) {
    setState(() => _selectedIndex = 3);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _aktivitasKey.currentState?.bukaDetail(idPesanan);
    });
  }

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      BerandaPage(key: _berandaKey, onLihatDetail: _bukaDetailAktivitas),
      const MenuPage(),
      const KeranjangPage(),
      AktivitasPage(key: _aktivitasKey),
      const ProfilPage(),
    ];
  }

  void _onTabTapped(int index) {
    // Kalau kembali ke tab Beranda (0), refresh avatar
    if (index == 0 && _selectedIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _berandaKey.currentState?.refreshAvatar();
      });
    }
    setState(() => _selectedIndex = index);
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
        onItemTapped: _onTabTapped,
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