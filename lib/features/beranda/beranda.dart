import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';
import 'package:catering_dapur_bu_mon/models/menu_model.dart';
import 'package:catering_dapur_bu_mon/models/ulasan_model.dart';
import 'package:catering_dapur_bu_mon/features/menu/detail-menu.dart';

// ── Beranda Page ───────────────────────────────────────────────
class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _alamat = 'Memuat lokasi...';

  // ── State Menu dari Backend ──
  List<MenuModel> _semuaMenu = [];
  bool _isLoadingMenu = true;
  String? _errorMenu;

  // ── State Ulasan dari Backend ──
  List<UlasanModel> _daftarUlasan = [];
  bool _isLoadingUlasan = true;
  String? _errorUlasan;

  // ── Form Ulasan ──
  final TextEditingController _ulasanController = TextEditingController();
  int _rating = 5;
  bool _isSubmittingUlasan = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
    _fetchMenu();
    _fetchUlasan();
  }

  // ── Fetch Menu ───────────────────────────────────────────────
  Future<void> _fetchMenu() async {
    setState(() {
      _isLoadingMenu = true;
      _errorMenu = null;
    });
    try {
      final raw = await ApiService.getMenu();
      final list = raw
          .map((e) => MenuModel.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _semuaMenu = list;
        _isLoadingMenu = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMenu = e.message;
        _isLoadingMenu = false;
      });
    } catch (e) {
      setState(() {
        _errorMenu = 'Gagal memuat menu.';
        _isLoadingMenu = false;
      });
    }
  }

  // ── Fetch Ulasan dari API ────────────────────────────────────
  Future<void> _fetchUlasan() async {
    setState(() {
      _isLoadingUlasan = true;
      _errorUlasan = null;
    });
    try {
      final raw = await ApiService.getUlasan(limit: 3);
      final list = raw
          .map((e) => UlasanModel.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _daftarUlasan = list;
        _isLoadingUlasan = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorUlasan = e.message;
        _isLoadingUlasan = false;
      });
    } catch (e) {
      setState(() {
        _errorUlasan = 'Gagal memuat ulasan.';
        _isLoadingUlasan = false;
      });
    }
  }

  // ── Lokasi ──────────────────────────────────────────────────
  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _alamat = 'GPS tidak aktif');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _alamat = 'Izin lokasi ditolak');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _alamat = 'Izin lokasi diblokir');
        return;
      }
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        setState(() {
          _alamat =
              '${place.street ?? ''}, ${place.subLocality ?? place.locality ?? ''}';
        });
      }
    } catch (e) {
      setState(() => _alamat = 'Gagal mendapatkan lokasi');
    }
  }

  // ── Filter Menu ──────────────────────────────────────────────
  List<MenuModel> get _menuTerfilter {
    if (_searchQuery.isEmpty) return _semuaMenu;
    return _semuaMenu
        .where((m) =>
            m.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            m.kategori.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // ── Navigasi ke Detail Menu ──────────────────────────────────
  void _keDetailMenu(MenuModel menu) {
    if (menu.isHabis) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailMenuPage(menu: menu)),
    );
  }

  // ── Kirim Ulasan ke API ──────────────────────────────────────
  Future<void> _kirimUlasan() async {
    final komentar = _ulasanController.text.trim();

    if (komentar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Isi ulasan tidak boleh kosong!',
              style: GoogleFonts.alexandria()),
          backgroundColor: const Color(0xFFD05122),
        ),
      );
      return;
    }

    setState(() => _isSubmittingUlasan = true);

    try {
      await ApiService.kirimUlasan(
        rating: _rating,
        komentar: komentar,
      );

      _ulasanController.clear();
      setState(() => _rating = 5);
      FocusScope.of(context).unfocus();

      // Refresh daftar ulasan
      await _fetchUlasan();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ulasan berhasil dikirim!',
                style: GoogleFonts.alexandria(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message, style: GoogleFonts.alexandria()),
            backgroundColor: const Color(0xFFD05122),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmittingUlasan = false);
    }
  }

  void _batalUlasan() {
    _ulasanController.clear();
    setState(() => _rating = 5);
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _ulasanController.dispose();
    super.dispose();
  }

  // ── BUILD ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final double navbarHeight = kBottomNavigationBarHeight + 60;

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),

          // Tracking Pesanan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Text('Tracking Pesanan',
                style: GoogleFonts.alexandria(
                  color: const Color(0xFF1A1818),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: _TrackingCard(),
          ),
          const SizedBox(height: 24),

          // Menu Terlaris
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Text('Menu Terlaris',
                style: GoogleFonts.alexandria(
                  color: const Color(0xFF1A1818),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                )),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 210,
            child: _isLoadingMenu
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD05122)))
                : _semuaMenu.isEmpty
                    ? const SizedBox()
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                        itemCount: _semuaMenu
                            .where((m) => m.stok > 0)
                            .take(4)
                            .length,
                        itemBuilder: (_, i) {
                          final tersedia =
                              _semuaMenu.where((m) => m.stok > 0).toList();
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: GestureDetector(
                              onTap: () => _keDetailMenu(tersedia[i]),
                              child: _MenuTerlarisCard(menu: tersedia[i]),
                            ),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 24),

          // Menu Tersedia
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Menu Tersedia',
                    style: GoogleFonts.alexandria(
                      color: const Color(0xFF1A1818),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
                GestureDetector(
                  onTap: _fetchMenu,
                  child: Opacity(
                    opacity: 0.5,
                    child: Row(
                      children: [
                        const Icon(Icons.refresh,
                            size: 14, color: Color(0xFF1A1818)),
                        const SizedBox(width: 4),
                        Text('Refresh',
                            style: GoogleFonts.alexandria(
                              color: const Color(0xFF1A1818),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // State: Loading / Error / Empty / Data
          if (_isLoadingMenu)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFD05122))),
            )
          else if (_errorMenu != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
              child: Column(
                children: [
                  Icon(Icons.wifi_off_rounded,
                      color: Colors.grey.shade400, size: 40),
                  const SizedBox(height: 8),
                  Text(_errorMenu!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.alexandria(
                          color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _fetchMenu,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD05122), Color(0xFFEE8B2E)],
                        ),
                      ),
                      child: Text('Coba Lagi',
                          style: GoogleFonts.alexandria(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ),
                ],
              ),
            )
          else if (_menuTerfilter.isEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
              child: Text('Menu tidak ditemukan',
                  style:
                      GoogleFonts.alexandria(color: Colors.grey, fontSize: 13)),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 26),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemCount: _menuTerfilter.length,
              itemBuilder: (_, i) => GestureDetector(
                onTap: _menuTerfilter[i].isHabis
                    ? null
                    : () => _keDetailMenu(_menuTerfilter[i]),
                child: _MenuTersediaCard(menu: _menuTerfilter[i]),
              ),
            ),
          const SizedBox(height: 24),

          // ── Ulasan Section ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Opacity(
                  opacity: 0.8,
                  child: Text('Ulasan',
                      style: GoogleFonts.alexandria(
                        color: const Color(0xFF1A1818),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SemuaUlasanPage(),
                      ),
                    );
                  },
                  child: Opacity(
                    opacity: 0.5,
                    child: Text('Lihat semua',
                        style: GoogleFonts.alexandria(
                          color: const Color(0xFF1A1818),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // State Ulasan: Loading / Error / Empty / Data
          if (_isLoadingUlasan)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFD05122))),
            )
          else if (_errorUlasan != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
              child: Text(_errorUlasan!,
                  style:
                      GoogleFonts.alexandria(color: Colors.grey, fontSize: 12)),
            )
          else if (_daftarUlasan.isEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
              child: Text('Belum ada ulasan.',
                  style:
                      GoogleFonts.alexandria(color: Colors.grey, fontSize: 13)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 26),
              itemCount: _daftarUlasan.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _UlasanCard(ulasan: _daftarUlasan[i]),
            ),

          const SizedBox(height: 24),

          // Form Ulasan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: _buildFormUlasan(),
          ),

          SizedBox(height: navbarHeight),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEE8B2E), Color(0xFFD05122), Color(0xFFAC3715)],
          stops: [0.17, 0.44, 0.79],
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(26, 20 + statusBarHeight, 26, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _getLocation,
                child: Image.network(
                  'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F2b2de4d17f51ac8a89f789b2c3fc544c438dac8cGoogle%20Maps.png?alt=media&token=1981c3aa-7e35-4fa9-af86-6bfa499edfc8',
                  width: 35,
                  height: 35,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Opacity(
                  opacity: 0.8,
                  child: Text(
                    _alamat,
                    style: GoogleFonts.lora(
                        color: const Color(0xFF1A1818), fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Image.network(
                'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2Fd154b179abf9d4a6058e12e77678299644c82914Notification.png?alt=media&token=ee7e3277-3227-4e20-bb69-f2a04c1cc16a',
                width: 25,
                height: 25,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 16),
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(23),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(23),
                  child: Image.network(
                    'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMOKhEnss8buSiiHoow%2F23705634-a6c1-4d7f-b1ce-e1f03c5d6330.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    textAlignVertical: TextAlignVertical.center,
                    style: GoogleFonts.lora(
                        color: const Color(0xFF1A1818), fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Mau Menu apa hari ini?',
                      hintStyle: GoogleFonts.lora(
                        color: const Color(0xFF1A1818).withOpacity(0.5),
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: InputBorder.none,
                      isDense: false,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 11),
              GestureDetector(
                onTap: () =>
                    setState(() => _searchQuery = _searchController.text),
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFD05122),
                        Color(0xFFEE8B2E),
                        Color(0xFFFBA839),
                      ],
                      stops: [0.18, 0.61, 0.85],
                    ),
                  ),
                  child:
                      const Icon(Icons.search, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Form Ulasan ──────────────────────────────────────────────
  Widget _buildFormUlasan() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            spreadRadius: 3,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Beri Ulasan',
              style: GoogleFonts.alexandria(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 8),

          // Rating bintang
          Row(
            children: List.generate(5, (index) {
              final star = index + 1;
              return GestureDetector(
                onTap: () => setState(() => _rating = star),
                child: Icon(
                  _rating >= star ? Icons.star : Icons.star_border,
                  color: const Color(0xFFF79F36),
                  size: 28,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _ulasanController,
              maxLines: 6,
              maxLength: 150,
              style: GoogleFonts.alexandria(
                  color: const Color(0xFF1A1818), fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Isi Ulasan',
                hintStyle: GoogleFonts.alexandria(
                  color: const Color(0xFF1A1818).withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                contentPadding: const EdgeInsets.all(12),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              GestureDetector(
                onTap: _isSubmittingUlasan ? null : _kirimUlasan,
                child: Container(
                  width: 102,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: _isSubmittingUlasan
                        ? const LinearGradient(
                            colors: [Colors.grey, Colors.grey])
                        : const LinearGradient(
                            colors: [
                              Color(0xFFD05122),
                              Color(0xFFEE8B2E),
                              Color(0xFFFBA839),
                            ],
                            stops: [0.18, 0.61, 0.85],
                          ),
                  ),
                  child: Center(
                    child: _isSubmittingUlasan
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text('Kirim',
                            style: GoogleFonts.lora(
                                color: Colors.white, fontSize: 18)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _batalUlasan,
                child: Container(
                  width: 102,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFAC3715),
                        Color(0xFFD05122),
                        Color(0xFFAC3715),
                      ],
                      stops: [0.17, 0.43, 0.61],
                    ),
                  ),
                  child: Center(
                    child: Text('Batal',
                        style: GoogleFonts.lora(
                            color: Colors.white, fontSize: 18)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Tracking Card ──────────────────────────────────────────────
class _TrackingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFAC3715),
            Color(0xFFD05122),
            Color(0xFFEE8B2E),
            Color(0xFFFBA839),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFD05122),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white10),
            ),
          ),
          Positioned(
            right: 20,
            top: 10,
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_shipping_rounded,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text('Tracking Pesanan',
                            style: GoogleFonts.alexandria(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            )),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white38, width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                                color: Color(0xFFFFF176),
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 5),
                          Text('Di Proses',
                              style: GoogleFonts.alexandria(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white24,
                        border:
                            Border.all(color: Colors.white38, width: 1.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.network(
                          'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2Faadbd449f069aaa6819892687e7e3677080fc101Timer.png?alt=media&token=f24e784b-7f4c-459a-9a45-6d39bbd655f2',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.fastfood,
                              color: Colors.white,
                              size: 36),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ayam Panggang',
                              style: GoogleFonts.alexandria(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('Status: Di Proses',
                                style: GoogleFonts.alexandria(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text('Estimasi selesai: ',
                            style: GoogleFonts.alexandria(
                                color: Colors.white70, fontSize: 11)),
                        Text('2 Jam',
                            style: GoogleFonts.alexandria(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('Lihat Detail',
                            style: GoogleFonts.alexandria(
                              color: const Color(0xFFD05122),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Menu Terlaris Card ─────────────────────────────────────────
class _MenuTerlarisCard extends StatelessWidget {
  final MenuModel menu;
  const _MenuTerlarisCard({required this.menu});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: menu.foto.isNotEmpty
                ? Image.network(
                    menu.foto,
                    width: 300,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Flexible(
                child: Opacity(
                  opacity: 0.8,
                  child: Text(menu.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.alexandria(
                        color: const Color(0xFF1A1818),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      )),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.star, size: 12, color: Color(0xFFF79F36)),
              const SizedBox(width: 2),
              Opacity(
                opacity: 0.8,
                child: Text('5',
                    style: GoogleFonts.alexandria(
                      color: const Color(0xFF1A1818),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    )),
              ),
              const SizedBox(width: 8),
              if (menu.kategori.isNotEmpty)
                Opacity(
                  opacity: 0.6,
                  child: Text(menu.kategori,
                      style: GoogleFonts.alexandria(
                        color: const Color(0xFF1A1818),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      )),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 300,
        height: 160,
        color: const Color(0xFFF79F36),
        child: const Icon(Icons.fastfood, color: Colors.white, size: 60),
      );
}

// ── Menu Tersedia Card ─────────────────────────────────────────
class _MenuTersediaCard extends StatelessWidget {
  final MenuModel menu;
  const _MenuTersediaCard({required this.menu});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF79F36),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: menu.foto.isNotEmpty
                      ? Image.network(
                          menu.foto,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.fastfood,
                              color: Colors.white,
                              size: 36),
                        )
                      : const Icon(Icons.fastfood,
                          color: Colors.white, size: 36),
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Opacity(
                  opacity: 0.8,
                  child: Text(menu.nama,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.alexandria(
                        color: const Color(0xFF1A1818),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      )),
                ),
              ),
              Opacity(
                opacity: 0.7,
                child: Text(menu.formattedHarga,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.alexandria(
                      color: const Color(0xFF1A1818),
                      fontSize: 7,
                      fontWeight: FontWeight.w500,
                    )),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(menu.warnaStok),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  menu.labelStok,
                  style: GoogleFonts.alexandria(
                    color: Colors.white,
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (menu.isHabis)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Ulasan Card ────────────────────────────────────────────────
class _UlasanCard extends StatelessWidget {
  final UlasanModel ulasan;
  const _UlasanCard({required this.ulasan});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E4E4),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            spreadRadius: 3,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F316b1609f20a8554436bf178b307cada634003f6user%201.png?alt=media&token=7e8f650d-fedf-4394-bbc4-445243b57769',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.person,
                    color: Color(0xFFD05122), size: 26),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(ulasan.namaCustomer,
                        style: GoogleFonts.alexandria(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        )),
                    Opacity(
                      opacity: 0.5,
                      child: Text(ulasan.tanggal,
                          style: GoogleFonts.alexandria(
                            color: const Color(0xFF1A1818),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ],
                ),
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      i < ulasan.rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFFF79F36),
                      size: 14,
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text(ulasan.komentar,
                    style: GoogleFonts.alexandria(
                        color: Colors.black, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Semua Ulasan Page ──────────────────────────────────────────
class SemuaUlasanPage extends StatefulWidget {
  const SemuaUlasanPage({super.key});

  @override
  State<SemuaUlasanPage> createState() => _SemuaUlasanPageState();
}

class _SemuaUlasanPageState extends State<SemuaUlasanPage> {
  List<UlasanModel> _ulasanList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUlasan();
  }

  Future<void> _fetchUlasan() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final raw = await ApiService.getUlasan(limit: 100);
      setState(() {
        _ulasanList = raw
            .map((e) => UlasanModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat ulasan.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFD05122),
        foregroundColor: Colors.white,
        title: Text(
          'Semua Ulasan',
          style: GoogleFonts.alexandria(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD05122)),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off_rounded,
                          color: Colors.grey.shade400, size: 40),
                      const SizedBox(height: 8),
                      Text(_error!,
                          style: GoogleFonts.alexandria(
                              color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _fetchUlasan,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD05122), Color(0xFFEE8B2E)],
                            ),
                          ),
                          child: Text('Coba Lagi',
                              style: GoogleFonts.alexandria(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ),
                    ],
                  ),
                )
              : _ulasanList.isEmpty
                  ? Center(
                      child: Text('Belum ada ulasan.',
                          style: GoogleFonts.alexandria(
                              color: Colors.grey, fontSize: 13)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 26, vertical: 16),
                      itemCount: _ulasanList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) =>
                          _UlasanCard(ulasan: _ulasanList[i]),
                    ),
    );
  }
}