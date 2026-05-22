import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/features/menu/detail-menu.dart';
import 'package:catering_dapur_bu_mon/models/menu_model.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String _kategoriAktif = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String _jenisFilter = 'Semua';

  List<MenuModel> _semuaMenu = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<String> _kategoriList = ['Semua'];

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  Future<void> _fetchMenu() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getMenu();

      if (response.isEmpty) {
        setState(() {
          _semuaMenu = [];
        });
      } else {
        final List<MenuModel> menuList = [];
        for (var item in response) {
          menuList.add(MenuModel.fromJson(item));
        }

        setState(() {
          _semuaMenu = menuList;
        });

        final kategoriSet = <String>{};
        for (var menu in _semuaMenu) {
          if (menu.kategori.isNotEmpty && menu.kategori != 'Lainnya') {
            kategoriSet.add(menu.kategori);
          }
        }
        _kategoriList = ['Semua', ...kategoriSet.toList()];
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat menu: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshMenu() async {
    await _fetchMenu();
  }

  List<MenuModel> get _menuTerfilter {
    return _semuaMenu.where((item) {
      final cocokKategori =
          _kategoriAktif == 'Semua' || item.kategori == _kategoriAktif;

      final cocokSearch = _searchQuery.isEmpty ||
          item.nama.toLowerCase().contains(_searchQuery.toLowerCase());

      bool cocokJenis = true;
      switch (_jenisFilter) {
        case 'Tersedia':
          cocokJenis = item.isAvailableForToday;
          break;
        case 'Pre-order':
          cocokJenis = !item.isAvailableForToday;
          break;
        default:
          cocokJenis = true;
      }

      return cocokKategori && cocokSearch && cocokJenis;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return RefreshIndicator(
      onRefresh: _refreshMenu,
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, statusBarHeight + 16, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFEE8B2E),
                  Color(0xFFD05122),
                  Color(0xFFAC3715),
                ],
                stops: [0.17, 0.44, 0.79],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Menu',
                        style: GoogleFonts.alexandria(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Pilih makanan favoritmu',
                        style: GoogleFonts.alexandria(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Search bar ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
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
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      textAlignVertical: TextAlignVertical.center,
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
                ),
                const SizedBox(width: 10),
                Container(
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
              ],
            ),
          ),

          // ── Filter Jenis (Semua / Tersedia / Pre-order) ─
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Semua', 'Tersedia', 'Pre-order'].map((jenis) {
                  final aktif = _jenisFilter == jenis;
                  return GestureDetector(
                    onTap: () => setState(() => _jenisFilter = jenis),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: aktif
                            ? const Color(0xFFEE8B2E)
                            : Colors.transparent,
                        border: Border.all(
                          color: const Color(0xFFDB6626),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        jenis,
                        style: GoogleFonts.lora(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight:
                              aktif ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Filter Kategori ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _kategoriList.map((kat) {
                  final aktif = _kategoriAktif == kat;
                  return GestureDetector(
                    onTap: () => setState(() => _kategoriAktif = kat),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: aktif
                            ? const Color(0xFFEE8B2E)
                            : Colors.transparent,
                        border: Border.all(
                          color: const Color(0xFFDB6626),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        kat,
                        style: GoogleFonts.lora(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight:
                              aktif ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Content ────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFD05122),
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage!,
                              style: GoogleFonts.alexandria(
                                  color: Colors.grey, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchMenu,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD05122),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : _menuTerfilter.isEmpty
                        ? Center(
                            child: Text(
                              'Menu tidak ditemukan',
                              style: GoogleFonts.alexandria(
                                  color: Colors.grey, fontSize: 14),
                            ),
                          )
                        : GridView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.95,
                            ),
                            itemCount: _menuTerfilter.length,
                            itemBuilder: (_, i) =>
                                _MenuCard(item: _menuTerfilter[i]),
                          ),
          ),
        ],
      ),
    );
  }
}

// ── Menu Card ───────────────────────────────────────────────────
class _MenuCard extends StatelessWidget {
  final MenuModel item;
  const _MenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailMenuPage(menu: item),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 6,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: 118,
                  height: 118,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF79F36),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: item.foto.isNotEmpty
                        ? Image.network(
                            item.imageUrl,
                            width: 106,
                            height: 106,
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
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.fastfood,
                              color: Colors.white,
                              size: 48,
                            ),
                          )
                        : const Icon(
                            Icons.fastfood,
                            color: Colors.white,
                            size: 48,
                          ),
                  ),
                ),
                // Badge status
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.isAvailableForToday
                          ? Colors.green
                          : Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      item.isAvailableForToday ? 'Tersedia' : 'Pre-order',
                      style: GoogleFonts.alexandria(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Overlay gelap jika pre-order
                if (!item.isAvailableForToday)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                item.nama,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.alexandria(
                  color: const Color(0xFF1A1818),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.formattedHarga,
              style: GoogleFonts.alexandria(
                color: const Color(0xFF1A1818).withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!item.isAvailableForToday)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '⏰ Pre-order H-1',
                  style: GoogleFonts.alexandria(
                    color: Colors.orange.shade700,
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}