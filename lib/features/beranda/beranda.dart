import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';
import 'package:catering_dapur_bu_mon/models/menu_model.dart';
import 'package:catering_dapur_bu_mon/models/ulasan_model.dart';
import 'package:catering_dapur_bu_mon/features/menu/detail-menu.dart';

// ================================================================
// HELPER FUNCTIONS (sama seperti di AktivitasPage)
// ================================================================
String _formattedPrice(dynamic harga) {
  final h = (double.tryParse(harga.toString()) ?? 0).toInt();
  final s = h.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}

String _formattedDate(dynamic tgl) {
  try {
    final dt = DateTime.parse(tgl.toString());
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return tgl?.toString() ?? '-';
  }
}

String _formatTglAntar(dynamic tgl) {
  if (tgl == null || tgl.toString().isEmpty) return 'Belum dijadwalkan';
  try {
    final dt = DateTime.parse(tgl.toString());
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  } catch (_) {
    return tgl.toString();
  }
}

String _formatJamAntar(dynamic jam) {
  if (jam == null || jam.toString().isEmpty) return '';
  final s = jam.toString();
  return s.length >= 5 ? s.substring(0, 5) : s;
}

Color _statusColor(String? status) {
  switch (status) {
    case 'pending':  return const Color(0xFFF39C12);
    case 'diterima': return const Color(0xFF3498DB);
    case 'diproses': return const Color(0xFFEE8B2E);
    case 'selesai':  return const Color(0xFF0FBC5F);
    case 'batal':    return const Color(0xFFE74C3C);
    default:         return Colors.grey;
  }
}

String _statusLabel(String? status) {
  switch (status) {
    case 'pending':  return 'Pending';
    case 'diterima': return 'Diterima';
    case 'diproses': return 'Proses';
    case 'selesai':  return 'Selesai';
    case 'batal':    return 'Batal';
    default:         return status ?? '-';
  }
}

IconData _statusIcon(String? status) {
  switch (status) {
    case 'pending':  return Icons.hourglass_empty_rounded;
    case 'diterima': return Icons.thumb_up_rounded;
    case 'diproses': return Icons.local_fire_department_rounded;
    case 'selesai':  return Icons.check_circle_rounded;
    case 'batal':    return Icons.cancel_rounded;
    default:         return Icons.help_outline;
  }
}

// ================================================================
// BERANDA PAGE
// ================================================================
class BerandaPage extends StatefulWidget {
  final void Function(int? idPesanan)? onLihatDetail;
  const BerandaPage({super.key, this.onLihatDetail});

  @override
  State<BerandaPage> createState() => BerandaPageState();
}

class BerandaPageState extends State<BerandaPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _avatar = 'tikus.png';

  List<MenuModel> _semuaMenu = [];
  bool _isLoadingMenu = true;
  String? _errorMenu;

  List<MenuModel> _menuTerlaris = [];
  bool _isLoadingTerlaris = true;

  List<UlasanModel> _daftarUlasan = [];
  bool _isLoadingUlasan = true;
  String? _errorUlasan;

  final TextEditingController _ulasanController = TextEditingController();
  int _rating = 5;
  bool _isSubmittingUlasan = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
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

  List<MenuModel> get _menuTerfilter {
    if (_searchQuery.isEmpty) return _semuaMenu;
    return _semuaMenu
        .where((m) =>
            m.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            m.kategori.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
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

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  void _onSearchSubmitted(String value) {
    setState(() {
      _searchQuery = value;
    });
    
    if (value.isNotEmpty && _scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            500,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  // ================================================================
// METHOD UNTUK MENAMPILKAN DETAIL PESANAN (POPUP) - VERSI PERBAIKAN
// ================================================================
void _showDetailPesanan(Map<String, dynamic> pesanan) {
  if (!mounted) return;
  showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => _CustomerDetailDialog(pesanan: pesanan),
  );
}

void _keDetailPesanan(int? idPesanan) async {
  if (idPesanan == null || !mounted) return;
  
  // Tampilkan loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(color: Color(0xFFD05122)),
    ),
  );

  try {
    // Konversi ke int dengan aman
    final int id = int.tryParse(idPesanan.toString()) ?? 0;
    if (id == 0) throw Exception('ID Pesanan tidak valid');
    
    final detail = await ApiService.getDetailPesanan(id);
    
    if (!mounted) return;
    Navigator.pop(context); // Tutup loading
    
    final pesananData = {
      'id_pesanan': int.tryParse(detail['id_pesanan'].toString()) ?? 0,
      'customer_name': detail['customer_name']?.toString() ?? 'Customer',
      'customer_alamat': detail['customer_alamat']?.toString() ?? 'Alamat tidak tersedia',
      'status': detail['status']?.toString() ?? 'pending',
      'tgl_pesan': detail['tgl_pesan']?.toString() ?? DateTime.now().toIso8601String(),
      'tgl_antar': detail['tgl_antar']?.toString(),
      'jam_antar': detail['jam_antar']?.toString(),
      'total_harga': double.tryParse(detail['total_harga'].toString()) ?? 0,
      'metode_bayar': detail['metode_bayar']?.toString() ?? detail['metode']?.toString() ?? '',
      'catatan': detail['catatan']?.toString() ?? '',
      'items': (detail['items'] as List<dynamic>?)?.map((item) {
        return {
          'id_item': int.tryParse(item['id_item'].toString()) ?? 0,
          'id_menu': int.tryParse(item['id_menu'].toString()) ?? 0,
          'nama': item['nama']?.toString() ?? '-',
          'jumlah': int.tryParse(item['jumlah'].toString()) ?? 0,
          'harga_satuan': double.tryParse(item['harga_satuan'].toString()) ?? 0,
        };
      }).toList() ?? [],
    };
    
    if (mounted) _showDetailPesanan(pesananData);
    
  } catch (e) {
    if (mounted) {
      Navigator.pop(context); // Tutup loading jika error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat detail pesanan: $e',
              style: GoogleFonts.alexandria(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

  @override
  void dispose() {
    _searchController.dispose();
    _ulasanController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight;

    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.only(bottom: bottomPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: _buildSearchBar(),
                ),
                const SizedBox(height: 16),

                if (_searchQuery.isNotEmpty && !_isLoadingMenu)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    child: Text(
                      'Ditemukan ${_menuTerfilter.length} menu untuk "$_searchQuery"',
                      style: GoogleFonts.alexandria(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                
                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Text(
                    'Tracking Pesanan',
                    style: GoogleFonts.alexandria(
                        color: const Color(0xFF1A1818),
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: _TrackingCard(
                    onLihatDetail: _keDetailPesanan, // ← TERHUBUNG KE POPUP
                  ),
                ),
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Text(
                    'Menu Terlaris',
                    style: GoogleFonts.alexandria(
                        color: const Color(0xFF1A1818),
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 210,
                  child: _isLoadingTerlaris
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFD05122)))
                      : _menuTerlaris.isEmpty
                          ? const SizedBox()
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 26),
                              itemCount: _menuTerlaris.length,
                              itemBuilder: (_, i) => Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: GestureDetector(
                                  onTap: () => _keDetailMenu(_menuTerlaris[i]),
                                  child: _MenuTerlarisCard(menu: _menuTerlaris[i]),
                                ),
                              ),
                            ),
                ),
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _searchQuery.isEmpty ? 'Menu Tersedia' : 'Hasil Pencarian',
                        style: GoogleFonts.alexandria(
                            color: const Color(0xFF1A1818),
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: _clearSearch,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Text('Batal',
                                    style: GoogleFonts.alexandria(
                                        color: const Color(0xFFD05122),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
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
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                if (_isLoadingMenu)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFFD05122))),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(colors: [
                              Color(0xFFD05122),
                              Color(0xFFEE8B2E),
                            ]),
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
                else if (_semuaMenu.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                    child: Column(
                      children: [
                        Icon(Icons.restaurant_menu, color: Colors.grey.shade400, size: 48),
                        const SizedBox(height: 8),
                        Text('Belum ada menu tersedia',
                            style: GoogleFonts.alexandria(
                                color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  )
                else if (_menuTerfilter.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, color: Colors.grey.shade400, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'Menu Tidak Ditemukan',
                          style: GoogleFonts.alexandria(
                              color: Colors.grey.shade700,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Maaf, tidak ada menu dengan kata "$_searchQuery"',
                          style: GoogleFonts.alexandria(
                              color: Colors.grey.shade600,
                              fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Coba kata kunci lain atau lihat menu tersedia lainnya',
                          style: GoogleFonts.alexandria(
                              color: Colors.grey.shade500,
                              fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: _clearSearch,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFD05122),
                                  Color(0xFFEE8B2E),
                                ],
                              ),
                            ),
                            child: Text(
                              'Hapus Pencarian',
                              style: GoogleFonts.alexandria(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                        child: CircularProgressIndicator(
                            color: Color(0xFFD05122))),
                  )
                else if (_errorUlasan != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
                    child: Text(_errorUlasan!,
                        style: GoogleFonts.alexandria(
                            color: Colors.grey, fontSize: 12)),
                  )
                else if (_daftarUlasan.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
                    child: Text('Belum ada ulasan.',
                        style: GoogleFonts.alexandria(
                            color: Colors.grey, fontSize: 13)),
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
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
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
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4))
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, 12 + statusBarH, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang,',
                style: GoogleFonts.lora(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 0),
              Text(
                'Apa yang ingin kamu pesan hari ini?',
                style: GoogleFonts.lora(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: Image.asset(
                'assets/avatars/$_avatar',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFD05122),
                  child: const Icon(Icons.person, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: _onSearchSubmitted,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.search,
              style: GoogleFonts.lora(
                color: const Color(0xFF1A1818),
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Cari menu',
                hintStyle: GoogleFonts.lora(
                  color: const Color(0xFF1A1818).withOpacity(0.5),
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: InputBorder.none,
                isDense: false,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              _onSearchSubmitted(_searchController.text);
            },
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
              child: const Icon(Icons.search, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      ? const LinearGradient(colors: [Colors.grey, Colors.grey])
                      : const LinearGradient(colors: [
                          Color(0xFFD05122),
                          Color(0xFFEE8B2E),
                          Color(0xFFFBA839),
                        ], stops: [0.18, 0.61, 0.85]),
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
                      style: GoogleFonts.lora(color: Colors.white, fontSize: 18)),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ================================================================
// SEMUA ULASAN - BOTTOM SHEET
// ================================================================
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
                                        Color(0xFFEE8B2E),
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

// ================================================================
// TRACKING CARD
// ================================================================
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
            Color(0xFFFBA839),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          ],
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      itemCount > 0
                          ? '$itemCount item pesanan'
                          : 'Pesanan aktif',
                      style: GoogleFonts.alexandria(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text('Status: ${_statusLabel(status)}',
                          style: GoogleFonts.alexandria(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600))),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(children: [
                const Icon(Icons.event_rounded,
                    color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(_jadwalLabel(p),
                      style: GoogleFonts.alexandria(
                          color: Colors.white, fontSize: 11),
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
            ),
            const SizedBox(width: 8),
            // Di dalam _buildAktif() method, ganti GestureDetector untuk Lihat Detail
GestureDetector(
  onTap: () {
    final rawId = p['id_pesanan'];
    final int idPesanan = int.tryParse(rawId.toString()) ?? 0;
    if (widget.onLihatDetail != null && idPesanan > 0) {
      widget.onLihatDetail!(idPesanan);
    }
  },
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20)),
    child: Text('Lihat Detail',
        style: GoogleFonts.alexandria(
            color: const Color(0xFFD05122),
            fontSize: 11,
            fontWeight: FontWeight.bold)),
  ),
),
          ],
        ),
      ],
    );
  }
}

// ================================================================
// DIALOG DETAIL PESANAN (POPUP)
// ================================================================
class _CustomerDetailDialog extends StatelessWidget {
  final Map<String, dynamic> pesanan;
  const _CustomerDetailDialog({required this.pesanan});

  static const _timelineSteps = [
    {'key': 'pending',  'label': 'Pending'},
    {'key': 'diterima', 'label': 'Diterima'},
    {'key': 'diproses', 'label': 'Diproses'},
    {'key': 'selesai',  'label': 'Selesai'},
  ];

  int _currentStepIndex(String? status) {
    switch (status) {
      case 'pending':  return 0;
      case 'diterima': return 1;
      case 'diproses': return 2;
      case 'selesai':  return 3;
      default:         return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = pesanan['status'] as String?;
    final color = _statusColor(status);
    final currentStep = _currentStepIndex(status);
    final isBatal = status == 'batal';
    final alamat = pesanan['customer_alamat'] ?? 'Alamat tidak tersedia';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFEE8B2E),
                  Color(0xFFD05122),
                  Color(0xFFAC3715),
                ],
                stops: [0.17, 0.44, 0.79],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Detail Pesanan',
                          style: GoogleFonts.alexandria(
                              fontSize: 12, color: Colors.white70)),
                      Text('#${pesanan['id_pesanan']}',
                          style: GoogleFonts.alexandria(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Body
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isBatal) ...[
                    const Text('Status Pesanan',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    const SizedBox(height: 10),
                    _CustomerTimelineWidget(
                        steps: _timelineSteps, currentStep: currentStep),
                    const SizedBox(height: 20),
                  ],
                  const Text('Info Pesanan',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  const SizedBox(height: 10),
                  _CustomerInfoGridWidget(items: [
                    _InfoItemData(
                        icon: Icons.payment_rounded,
                        label: 'Metode Bayar',
                        value: pesanan['metode_bayar']?.toString() ?? '-'),
                    _InfoItemData(
                        icon: Icons.calendar_today_rounded,
                        label: 'Tanggal',
                        value: _formattedDate(pesanan['tgl_pesan'])),
                    _InfoItemData(
                        icon: Icons.info_outline_rounded,
                        label: 'Status',
                        value: _statusLabel(status),
                        valueColor: color),
                    _InfoItemData(
                        icon: Icons.location_on_rounded,
                        label: 'Alamat',
                        value: alamat,
                        valueColor: const Color(0xFFD05122)),
                    _InfoItemData(
                        icon: Icons.event_available_rounded,
                        label: 'Tgl Antar',
                        value: _formatTglAntar(pesanan['tgl_antar'])),
                    _InfoItemData(
                        icon: Icons.access_time_rounded,
                        label: 'Jam Antar',
                        value: _formatJamAntar(pesanan['jam_antar'])
                                .isNotEmpty
                            ? _formatJamAntar(pesanan['jam_antar'])
                            : '-'),
                  ]),
                  if (pesanan['catatan'] != null &&
                      pesanan['catatan'].toString().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFFCC02)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.sticky_note_2_outlined,
                              size: 16, color: Color(0xFFF39C12)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                                pesanan['catatan'].toString(),
                                style: GoogleFonts.alexandria(
                                    fontSize: 12,
                                    color: const Color(0xFF7D5A00))),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text('Item Pesanan',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        ...(pesanan['items'] as List<dynamic>? ?? [])
                            .asMap()
                            .entries
                            .map((e) => _ItemRowWidget(
                                  item: e.value,
                                  isLast: e.key ==
                                      ((pesanan['items'] as List<dynamic>?)?.length ?? 0) - 1,
                                )),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFAFA),
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(10)),
                            border: Border(
                                top: BorderSide(color: Colors.grey.shade200)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total',
                                  style: GoogleFonts.alexandria(
                                      fontSize: 13, fontWeight: FontWeight.bold)),
                              Text(
                                _formattedPrice(pesanan['total_harga'] ?? 0),
                                style: GoogleFonts.alexandria(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFD05122)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (status == 'selesai')
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F8EF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF0FBC5F), size: 18),
                          const SizedBox(width: 8),
                          Text('Pesanan telah selesai',
                              style: GoogleFonts.alexandria(
                                  fontSize: 13,
                                  color: const Color(0xFF0FBC5F),
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  else if (status == 'batal')
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cancel_rounded,
                              color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Text('Pesanan telah dibatalkan',
                              style: GoogleFonts.alexandria(
                                  fontSize: 13,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Close button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD05122),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Tutup',
                    style: GoogleFonts.alexandria(
                        fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Timeline Widget
class _CustomerTimelineWidget extends StatelessWidget {
  final List<Map<String, String?>> steps;
  final int currentStep;
  const _CustomerTimelineWidget(
      {required this.steps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: steps.asMap().entries.map((e) {
        final i = e.key;
        final step = e.value;
        final isDone = i < currentStep;
        final isActive = i == currentStep;
        final isLast = i == steps.length - 1;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? const Color(0xFF0FBC5F)
                            : isActive
                                ? const Color(0xFFD05122)
                                : Colors.grey.shade200,
                        border: isActive
                            ? Border.all(
                                color: const Color(0xFFD05122), width: 2)
                            : null,
                      ),
                      child: Icon(
                        isDone
                            ? Icons.check_rounded
                            : isActive
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_unchecked_rounded,
                        size: 14,
                        color: isDone || isActive
                            ? Colors.white
                            : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step['label'] ?? '',
                      style: GoogleFonts.alexandria(
                        fontSize: 9,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isDone
                            ? const Color(0xFF0FBC5F)
                            : isActive
                                ? const Color(0xFFD05122)
                                : Colors.grey.shade400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 18),
                    color: i < currentStep
                        ? const Color(0xFF0FBC5F)
                        : Colors.grey.shade200,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// Info Item Data
class _InfoItemData {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoItemData({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
}

// Info Grid Widget
class _CustomerInfoGridWidget extends StatelessWidget {
  final List<_InfoItemData> items;
  const _CustomerInfoGridWidget({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: items
          .map((item) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(item.icon, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item.label,
                              style: GoogleFonts.alexandria(
                                  fontSize: 10,
                                  color: Colors.grey[500]),
                              overflow: TextOverflow.ellipsis),
                          Text(item.value,
                              style: GoogleFonts.alexandria(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      item.valueColor ?? Colors.black87),
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

// Item Row Widget
class _ItemRowWidget extends StatelessWidget {
  final dynamic item;
  final bool isLast;
  const _ItemRowWidget({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E8),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text('${item['jumlah']}x',
                  style: GoogleFonts.alexandria(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD05122))),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(item['nama'] ?? '-',
                style: GoogleFonts.alexandria(fontSize: 13)),
          ),
          Text(
            _formattedPrice(item['harga_satuan'] ?? 0),
            style: GoogleFonts.alexandria(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// MENU TERLARIS CARD
// ================================================================
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
                    menu.imageUrl,
                    width: 300,
                    height: 160,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      );
                    },
                    errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
          ),
          const SizedBox(height: 6),
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
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
      width: 300,
      height: 160,
      color: const Color(0xFFF79F36),
      child: const Icon(Icons.fastfood, color: Colors.white, size: 60));
}

// ================================================================
// MENU CARD
// ================================================================
class _MenuCard extends StatelessWidget {
  final MenuModel menu;
  const _MenuCard({required this.menu});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 6,
              offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12)),
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
                            color: Colors.white, strokeWidth: 2),
                      );
                    },
                    errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 5, 6, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Color(menu.warnaStok).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Color(menu.warnaStok), width: 0.8),
                  ),
                  child: Text(menu.labelStok,
                      style: GoogleFonts.alexandria(
                          color: Color(menu.warnaStok),
                          fontSize: 8,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
      width: double.infinity,
      height: 80,
      color: const Color(0xFFF79F36),
      child: const Icon(Icons.fastfood, color: Colors.white, size: 30));
}

// ================================================================
// ULASAN CARD
// ================================================================
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10)),
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
                            fontWeight: FontWeight.bold)),
                    Opacity(
                        opacity: 0.5,
                        child: Text(ulasan.tanggal,
                            style: GoogleFonts.alexandria(
                                color: const Color(0xFF1A1818),
                                fontSize: 11,
                                fontWeight: FontWeight.w600))),
                  ],
                ),
                Row(
                  children: List.generate(
                      5,
                      (i) => Icon(
                          i < ulasan.rating ? Icons.star : Icons.star_border,
                          color: const Color(0xFFF79F36),
                          size: 14)),
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

// ================================================================
// AVATAR INISIAL
// ================================================================
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