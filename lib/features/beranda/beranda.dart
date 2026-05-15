import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';
import 'package:catering_dapur_bu_mon/models/menu_model.dart';
import 'package:catering_dapur_bu_mon/models/ulasan_model.dart';
import 'package:catering_dapur_bu_mon/features/menu/detail-menu.dart';

class BerandaPage extends StatefulWidget {
  final void Function(int? idPesanan)? onLihatDetail;
  const BerandaPage({super.key, this.onLihatDetail});

  @override
  State<BerandaPage> createState() => BerandaPageState();
}

class BerandaPageState extends State<BerandaPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _alamat = 'Memuat lokasi...';
  String _avatar = 'tikus.png';

  List<MenuModel> _semuaMenu = [];
  bool _isLoadingMenu = true;
  String? _errorMenu;

  // ── Menu Terlaris ──────────────────────────────────────────
  List<MenuModel> _menuTerlaris = [];
  bool _isLoadingTerlaris = true;
  // ──────────────────────────────────────────────────────────

  List<UlasanModel> _daftarUlasan = [];
  bool _isLoadingUlasan = true;
  String? _errorUlasan;

  final TextEditingController _ulasanController = TextEditingController();
  int _rating = 5;
  bool _isSubmittingUlasan = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
    _fetchMenu();
    _fetchMenuTerlaris();
    _fetchUlasan();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    try {
      final data = await ApiService.getProfil();
      if (mounted) {
        setState(() {
          _avatar = data['foto_profil'] ?? 'tikus.png';
        });
      }
    } catch (_) {}
  }

  Future<void> refreshAvatar() async => _loadAvatar();

  Future<void> _fetchMenu() async {
    setState(() {
      _isLoadingMenu = true;
      _errorMenu = null;
    });
    try {
      final raw = await ApiService.getMenu();
      setState(() {
        _semuaMenu = raw
            .map((e) => MenuModel.fromJson(e as Map<String, dynamic>))
            .where((menu) => menu.stok > 0)
            .toList();
        _isLoadingMenu = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMenu = e.message;
        _isLoadingMenu = false;
      });
    } catch (_) {
      setState(() {
        _errorMenu = 'Gagal memuat menu.';
        _isLoadingMenu = false;
      });
    }
  }

  // ── Fetch 3 menu terlaris dari endpoint khusus ─────────────
  Future<void> _fetchMenuTerlaris() async {
    setState(() => _isLoadingTerlaris = true);
    try {
      final raw = await ApiService.getMenuTerlaris();
      setState(() {
        _menuTerlaris = raw
            .map((e) => MenuModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoadingTerlaris = false;
      });
    } catch (_) {
      setState(() => _isLoadingTerlaris = false);
    }
  }
  // ──────────────────────────────────────────────────────────

  Future<void> _fetchUlasan() async {
    setState(() {
      _isLoadingUlasan = true;
      _errorUlasan = null;
    });
    try {
      final raw = await ApiService.getUlasan(limit: 3);
      setState(() {
        _daftarUlasan = raw
            .map((e) => UlasanModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoadingUlasan = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorUlasan = e.message;
        _isLoadingUlasan = false;
      });
    } catch (_) {
      setState(() {
        _errorUlasan = 'Gagal memuat ulasan.';
        _isLoadingUlasan = false;
      });
    }
  }

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
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final marks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (marks.isNotEmpty) {
        final p = marks.first;
        setState(() => _alamat =
            '${p.street ?? ''}, ${p.subLocality ?? p.locality ?? ''}');
      }
    } catch (_) {
      setState(() => _alamat = 'Gagal mendapatkan lokasi');
    }
  }

  List<MenuModel> get _menuTerfilter {
    if (_searchQuery.isEmpty) return _semuaMenu;
    return _semuaMenu
        .where((m) =>
            m.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            m.kategori.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<MenuModel> get _menuTersedia {
    return _semuaMenu.where((m) => m.stok > 0).toList();
  }

  void _keDetailMenu(MenuModel menu) {
    if (!menu.isAvailableForToday) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Menu tidak tersedia untuk dipesan saat ini',
            style: GoogleFonts.alexandria(),
          ),
          backgroundColor: const Color(0xFFD05122),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailMenuPage(menu: menu)),
    );
  }

  void _lihatSemuaUlasan() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SemuaUlasanSheet(),
    );
  }

  Future<void> _kirimUlasan() async {
    final komentar = _ulasanController.text.trim();
    if (komentar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Isi ulasan tidak boleh kosong!',
            style: GoogleFonts.alexandria()),
        backgroundColor: const Color(0xFFD05122),
      ));
      return;
    }
    setState(() => _isSubmittingUlasan = true);
    try {
      await ApiService.kirimUlasan(rating: _rating, komentar: komentar);
      _ulasanController.clear();
      setState(() => _rating = 5);
      FocusScope.of(context).unfocus();
      await _fetchUlasan();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ulasan berhasil dikirim!',
              style: GoogleFonts.alexandria(color: Colors.white)),
          backgroundColor: Colors.green,
        ));
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message, style: GoogleFonts.alexandria()),
          backgroundColor: const Color(0xFFD05122),
        ));
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

  @override
  Widget build(BuildContext context) {
    final navbarHeight = kBottomNavigationBarHeight + 60;

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildHeader(context),
        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Text('Tracking Pesanan',
              style: GoogleFonts.alexandria(
                  color: const Color(0xFF1A1818),
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: _TrackingCard(onLihatDetail: widget.onLihatDetail),
        ),
        const SizedBox(height: 24),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Text('Menu Terlaris',
              style: GoogleFonts.alexandria(
                  color: const Color(0xFF1A1818),
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        // ── Menu Terlaris — data dari DB ───────────────────────
        SizedBox(
          height: 210,
          child: _isLoadingTerlaris
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFD05122)))
              : _menuTerlaris.isEmpty
                  ? const SizedBox()
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      itemCount: _menuTerlaris.length,
                      itemBuilder: (_, i) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: GestureDetector(
                            onTap: () => _keDetailMenu(_menuTerlaris[i]),
                            child: _MenuTerlarisCard(menu: _menuTerlaris[i]),
                          ),
                        );
                      },
                    ),
        ),
        // ──────────────────────────────────────────────────────
        const SizedBox(height: 24),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Menu Tersedia',
                  style: GoogleFonts.alexandria(
                      color: const Color(0xFF1A1818),
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: _fetchMenu,
                child: Opacity(
                    opacity: 0.5,
                    child: Row(children: [
                      const Icon(Icons.refresh,
                          size: 14, color: Color(0xFF1A1818)),
                      const SizedBox(width: 4),
                      Text('Refresh',
                          style: GoogleFonts.alexandria(
                              color: const Color(0xFF1A1818),
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ])),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        if (_isLoadingMenu)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
                child: CircularProgressIndicator(color: Color(0xFFD05122))),
          )
        else if (_errorMenu != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
            child: Column(children: [
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                        colors: [Color(0xFFD05122), Color(0xFFEE8B2E)]),
                  ),
                  child: Text('Coba Lagi',
                      style: GoogleFonts.alexandria(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          )
        else if (_menuTerfilter.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
            child: Text('Menu tidak ditemukan',
                style:
                    GoogleFonts.alexandria(color: Colors.grey, fontSize: 13)),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.68,
            ),
            itemCount: _menuTerfilter.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => _keDetailMenu(_menuTerfilter[i]),
              child: _MenuCard(menu: _menuTerfilter[i]),
            ),
          ),
        const SizedBox(height: 24),

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
                        fontWeight: FontWeight.bold)),
              ),
              GestureDetector(
                onTap: _lihatSemuaUlasan,
                child: Opacity(
                  opacity: 0.5,
                  child: Text('Lihat semua',
                      style: GoogleFonts.alexandria(
                          color: const Color(0xFF1A1818),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        if (_isLoadingUlasan)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
                child: CircularProgressIndicator(color: Color(0xFFD05122))),
          )
        else if (_errorUlasan != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
            child: Text(_errorUlasan!,
                style:
                    GoogleFonts.alexandria(color: Colors.grey, fontSize: 12)),
          )
        else if (_daftarUlasan.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
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

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: _buildFormUlasan(),
        ),
        SizedBox(height: navbarHeight),
      ]),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final statusBarH = MediaQuery.of(context).padding.top;
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
              color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))
        ],
      ),
      padding: EdgeInsets.fromLTRB(26, 20 + statusBarH, 26, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
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
                  child: Text(_alamat,
                      style: GoogleFonts.lora(
                          color: const Color(0xFF1A1818), fontSize: 16),
                      overflow: TextOverflow.ellipsis))),
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
                borderRadius: BorderRadius.circular(23)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  'assets/avatars/$_avatar',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.pets,
                    color: Color(0xFFD05122),
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
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
                    offset: const Offset(0, 2))
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              textAlignVertical: TextAlignVertical.center,
              style: GoogleFonts.lora(
                  color: const Color(0xFF1A1818), fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Mau Menu apa hari ini?',
                hintStyle: GoogleFonts.lora(
                    color: const Color(0xFF1A1818).withOpacity(0.5),
                    fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                border: InputBorder.none,
                isDense: false,
              ),
            ),
          )),
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
                    Color(0xFFFBA839)
                  ],
                  stops: [0.18, 0.61, 0.85],
                ),
              ),
              child:
                  const Icon(Icons.search, color: Colors.white, size: 22),
            ),
          ),
        ]),
      ]),
    );
  }

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
              offset: Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Beri Ulasan',
            style: GoogleFonts.alexandria(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
            children: List.generate(5, (i) {
          final star = i + 1;
          return GestureDetector(
            onTap: () => setState(() => _rating = star),
            child: Icon(
              _rating >= star ? Icons.star : Icons.star_border,
              color: const Color(0xFFF79F36),
              size: 28,
            ),
          );
        })),
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
                  fontWeight: FontWeight.w600),
              contentPadding: const EdgeInsets.all(12),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(children: [
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
                          Color(0xFFFBA839)
                        ],
                        stops: [0.18, 0.61, 0.85]),
              ),
              child: Center(
                  child: _isSubmittingUlasan
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text('Kirim',
                          style: GoogleFonts.lora(
                              color: Colors.white, fontSize: 18))),
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
                    Color(0xFFAC3715)
                  ],
                  stops: [0.17, 0.43, 0.61],
                ),
              ),
              child: Center(
                  child: Text('Batal',
                      style: GoogleFonts.lora(
                          color: Colors.white, fontSize: 18))),
            ),
          ),
        ]),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SEMUA ULASAN — BOTTOM SHEET
// ══════════════════════════════════════════════════════════════
class _SemuaUlasanSheet extends StatefulWidget {
  const _SemuaUlasanSheet();

  @override
  State<_SemuaUlasanSheet> createState() => _SemuaUlasanSheetState();
}

class _SemuaUlasanSheetState extends State<_SemuaUlasanSheet> {
  List<UlasanModel> _list = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final raw = await ApiService.getUlasan(limit: 100);
      setState(() {
        _list = raw
            .map((e) => UlasanModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Gagal memuat ulasan.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Semua Ulasan',
                        style: GoogleFonts.alexandria(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 18, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Divider(color: Colors.grey.shade200, thickness: 1),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFFD05122)))
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
                                  onTap: _fetch,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: const LinearGradient(colors: [
                                        Color(0xFFD05122),
                                        Color(0xFFEE8B2E)
                                      ]),
                                    ),
                                    child: Text('Coba Lagi',
                                        style: GoogleFonts.alexandria(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _list.isEmpty
                            ? Center(
                                child: Text('Belum ada ulasan.',
                                    style: GoogleFonts.alexandria(
                                        color: Colors.grey, fontSize: 13)))
                            : ListView.separated(
                                controller: scrollController,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                itemCount: _list.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (_, i) =>
                                    _UlasanCard(ulasan: _list[i]),
                              ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  TRACKING CARD
// ══════════════════════════════════════════════════════════════
class _TrackingCard extends StatefulWidget {
  final void Function(int? idPesanan)? onLihatDetail;
  const _TrackingCard({this.onLihatDetail});

  @override
  State<_TrackingCard> createState() => _TrackingCardState();
}

class _TrackingCardState extends State<_TrackingCard> {
  Map<String, dynamic>? _pesanan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await ApiService.getPesanan();
      final aktif = list.cast<Map<String, dynamic>>().firstWhere(
            (p) => !['selesai', 'batal'].contains(p['status']),
            orElse: () => {},
          );
      setState(() {
        _pesanan = aktif.isEmpty ? null : aktif;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  int _resolveItemCount(Map<String, dynamic> p) {
    final fromField = int.tryParse(p['item_count']?.toString() ?? '');
    if (fromField != null) return fromField;
    final items = p['items'];
    if (items is List) return items.length;
    return 0;
  }

  String _statusLabel(String? s) {
    switch (s) {
      case 'pending':
        return 'Menunggu';
      case 'diterima':
        return 'Diterima';
      case 'diproses':
        return 'Di Proses';
      default:
        return s ?? '-';
    }
  }

  String _jadwalLabel(Map<String, dynamic> p) {
    final tgl = p['tgl_antar']?.toString() ?? '';
    final jam = p['jam_antar']?.toString() ?? '';
    final tipe = p['tipe_pengiriman']?.toString() ?? 'ambil';
    if (tgl.isEmpty) return 'Jadwal belum diatur';
    try {
      final dt = DateTime.parse(tgl);
      const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      final hari = days[dt.weekday - 1];
      final tglFmt =
          '$hari, ${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      final jamFmt = jam.length >= 5 ? ' • ${jam.substring(0, 5)}' : '';
      final icon = tipe == 'antar' ? '🚗' : '🏪';
      final label = tipe == 'antar' ? 'Diantar' : 'Ambil';
      return '$icon $label  $tglFmt$jamFmt';
    } catch (_) {
      return tgl;
    }
  }

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
            Color(0xFFFBA839)
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
        boxShadow: const [
          BoxShadow(
              color: Color(0xFFD05122), blurRadius: 18, offset: Offset(0, 8))
        ],
      ),
      child: Stack(children: [
        Positioned(
            right: -30,
            top: -30,
            child: Container(
                width: 130,
                height: 130,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.white10))),
        Positioned(
            right: 20,
            top: 10,
            child: Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.white10))),
        Padding(
          padding: const EdgeInsets.all(18),
          child: _isLoading
              ? const SizedBox(
                  height: 80,
                  child: Center(
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)))
              : _pesanan == null
                  ? _buildKosong()
                  : _buildAktif(),
        ),
      ]),
    );
  }

  Widget _buildKosong() => Column(children: [
        Row(children: [
          const Icon(Icons.local_shipping_rounded,
              color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text('Tracking Pesanan',
              style: GoogleFonts.alexandria(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 16),
        const Icon(Icons.receipt_long_outlined,
            color: Colors.white54, size: 36),
        const SizedBox(height: 8),
        Text('Belum ada pesanan aktif',
            style:
                GoogleFonts.alexandria(color: Colors.white70, fontSize: 13)),
      ]);

  Widget _buildAktif() {
    final p = _pesanan!;
    final status = p['status'] as String?;
    final itemCount = _resolveItemCount(p);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          const Icon(Icons.local_shipping_rounded,
              color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text('Tracking Pesanan',
              style: GoogleFonts.alexandria(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white38, width: 1)),
          child: Row(children: [
            Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: Color(0xFFFFF176), shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Text(_statusLabel(status),
                style: GoogleFonts.alexandria(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ]),
        ),
      ]),
      const SizedBox(height: 14),
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white24,
                border: Border.all(color: Colors.white38, width: 1.5)),
            child: const Icon(Icons.fastfood_rounded,
                color: Colors.white, size: 30)),
        const SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              itemCount > 0 ? '$itemCount item pesanan' : 'Pesanan aktif',
              style: GoogleFonts.alexandria(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10)),
              child: Text('Status: ${_statusLabel(status)}',
                  style: GoogleFonts.alexandria(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600))),
        ])),
      ]),
      const SizedBox(height: 14),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
            child: Row(children: [
          const Icon(Icons.event_rounded, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Expanded(
              child: Text(_jadwalLabel(p),
                  style: GoogleFonts.alexandria(
                      color: Colors.white, fontSize: 11),
                  overflow: TextOverflow.ellipsis)),
        ])),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => widget.onLihatDetail?.call(p['id_pesanan'] as int?),
          child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20)),
              child: Text('Lihat Detail',
                  style: GoogleFonts.alexandria(
                      color: const Color(0xFFD05122),
                      fontSize: 11,
                      fontWeight: FontWeight.bold))),
        ),
      ]),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════
//  MENU TERLARIS CARD — tanpa bintang
// ══════════════════════════════════════════════════════════════
class _MenuTerlarisCard extends StatelessWidget {
  final MenuModel menu;
  const _MenuTerlarisCard({required this.menu});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: menu.foto.isNotEmpty
              ? Image.network(
                  menu.imageUrl,
                  width: 300,
                  height: 160,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => _placeholder())
              : _placeholder(),
        ),
        const SizedBox(height: 6),
        // ── Info nama & kategori saja, tanpa bintang ───────────
        Row(children: [
          Flexible(
            child: Opacity(
              opacity: 0.8,
              child: Text(
                menu.nama,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.alexandria(
                    color: const Color(0xFF1A1818),
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          if (menu.kategori.isNotEmpty) ...[
            const SizedBox(width: 8),
            Opacity(
              opacity: 0.6,
              child: Text(
                menu.kategori,
                style: GoogleFonts.alexandria(
                    color: const Color(0xFF1A1818),
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ]),
        // ──────────────────────────────────────────────────────
      ]),
    );
  }

  Widget _placeholder() => Container(
      width: 300,
      height: 160,
      color: const Color(0xFFF79F36),
      child: const Icon(Icons.fastfood, color: Colors.white, size: 60));
}

// ══════════════════════════════════════════════════════════════
//  MENU CARD
// ══════════════════════════════════════════════════════════════
class _MenuCard extends StatelessWidget {
  final MenuModel menu;
  const _MenuCard({required this.menu});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 2))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            child: menu.foto.isNotEmpty
                ? Image.network(
                    menu.imageUrl,
                    width: double.infinity,
                    height: 80,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 5, 6, 6),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(menu.nama,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.alexandria(
                      color: const Color(0xFF1A1818),
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(menu.formattedHarga,
                  style: GoogleFonts.alexandria(
                      color: const Color(0xFFD05122),
                      fontSize: 9,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(menu.warnaStok).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Color(menu.warnaStok), width: 0.8),
                ),
                child: Text(menu.labelStok,
                    style: GoogleFonts.alexandria(
                        color: Color(menu.warnaStok),
                        fontSize: 8,
                        fontWeight: FontWeight.bold)),
              ),
            ]),
          ),
        ]),
      ),
    ]);
  }

  Widget _placeholder() => Container(
      width: double.infinity,
      height: 80,
      color: const Color(0xFFF79F36),
      child: const Icon(Icons.fastfood, color: Colors.white, size: 30));
}

// ══════════════════════════════════════════════════════════════
//  ULASAN CARD
// ══════════════════════════════════════════════════════════════
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
              offset: Offset(0, 2))
        ],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Avatar customer sesuai foto_profil ──
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Image.asset(
                'assets/avatars/${ulasan.fotoProfil}',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    _AvatarInisial(nama: ulasan.namaCustomer),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(ulasan.namaCustomer,
                      style: GoogleFonts.alexandria(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  Opacity(
                      opacity: 0.5,
                      child: Text(ulasan.tanggal,
                          style: GoogleFonts.alexandria(
                              color: const Color(0xFF1A1818),
                              fontSize: 11,
                              fontWeight: FontWeight.w600))),
                ]),
            Row(
                children: List.generate(
                    5,
                    (i) => Icon(
                        i < ulasan.rating ? Icons.star : Icons.star_border,
                        color: const Color(0xFFF79F36),
                        size: 14))),
            const SizedBox(height: 4),
            Text(ulasan.komentar,
                style: GoogleFonts.alexandria(
                    color: Colors.black, fontSize: 12)),
          ]),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  AVATAR INISIAL — fallback jika asset tidak ditemukan
// ══════════════════════════════════════════════════════════════
class _AvatarInisial extends StatelessWidget {
  final String nama;
  const _AvatarInisial({required this.nama});

  Color get _warnaBg {
    const colors = [
      Color(0xFFD05122),
      Color(0xFFEE8B2E),
      Color(0xFF4CAF50),
      Color(0xFF2196F3),
      Color(0xFF9C27B0),
      Color(0xFFFF5722),
      Color(0xFF00BCD4),
    ];
    if (nama.isEmpty) return colors[0];
    return colors[nama.codeUnitAt(0) % colors.length];
  }

  String get _inisial {
    if (nama.isEmpty) return '?';
    final parts = nama.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nama[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _warnaBg,
      child: Center(
        child: Text(
          _inisial,
          style: GoogleFonts.alexandria(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}