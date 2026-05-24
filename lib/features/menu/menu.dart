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

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: RefreshIndicator(
        onRefresh: _refreshMenu,
        child: Column(
          children: [
            // HEADER FIXED
            Container(
              width: double.infinity,
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
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, statusBarHeight + 16, 20, 20),
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
            ),

            // KONTEN YANG DISCROLL
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // SEARCH BAR
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                onChanged: _onSearchChanged,
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
                                  prefixIcon: const Icon(Icons.search,
                                      color: Color(0xFFD05122), size: 20),
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.close,
                                              size: 18, color: Colors.grey),
                                          onPressed: _clearSearch,
                                        )
                                      : null,
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // FILTER JENIS
                    SizedBox(
                      height: 40,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: ['Semua', 'Tersedia', 'Pre-order'].map((jenis) {
                            final aktif = _jenisFilter == jenis;
                            return GestureDetector(
                              onTap: () => setState(() => _jenisFilter = jenis),
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: aktif
                                      ? const Color(0xFFEE8B2E)
                                      : Colors.white,
                                  border: Border.all(
                                    color: const Color(0xFFDB6626),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Text(
                                  jenis,
                                  style: GoogleFonts.lora(
                                    color: aktif ? Colors.white : Colors.black87,
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
                    const SizedBox(height: 8),

                    // FILTER KATEGORI
                    SizedBox(
                      height: 40,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: _kategoriList.map((kat) {
                            final aktif = _kategoriAktif == kat;
                            return GestureDetector(
                              onTap: () => setState(() => _kategoriAktif = kat),
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: aktif
                                      ? const Color(0xFFEE8B2E)
                                      : Colors.white,
                                  border: Border.all(
                                    color: const Color(0xFFDB6626),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Text(
                                  kat,
                                  style: GoogleFonts.lora(
                                    color: aktif ? Colors.white : Colors.black87,
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

                    // ⚠️ PERUBAHAN 1: Kurangi jarak setelah filter kategori
                    const SizedBox(height: 4), // Sebelumnya: 12

                    // INFORMASI JUMLAH HASIL PENCARIAN
                    if (_searchQuery.isNotEmpty && !_isLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Ditemukan ${_menuTerfilter.length} menu untuk "$_searchQuery"',
                            style: GoogleFonts.alexandria(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),

                    // ⚠️ PERUBAHAN 2: Kurangi jarak sebelum content (dari 8 menjadi 0)
                    const SizedBox(height: 0), // Sebelumnya: 8

                    // CONTENT
                    _buildContent(),
                    
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: CircularProgressIndicator(
            color: Color(0xFFD05122),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
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
        ),
      );
    }

    if (_menuTerfilter.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
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
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isEmpty
                    ? 'Tidak ada menu yang tersedia'
                    : 'Tidak ada menu dengan kata "$_searchQuery"',
                style: GoogleFonts.alexandria(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              if (_searchQuery.isNotEmpty) ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _clearSearch,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Grid Menu
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: _menuTerfilter.length,
        itemBuilder: (context, index) {
          return _MenuCard(item: _menuTerfilter[index]);
        },
      ),
    );
  }
}

// Menu Card
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Stack(
              children: [
                Container(
                  width: 105,
                  height: 105,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF79F36),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: item.foto.isNotEmpty
                        ? Image.network(
                            item.imageUrl,
                            width: 100,
                            height: 100,
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
                              size: 40,
                            ),
                          )
                        : const Icon(
                            Icons.fastfood,
                            color: Colors.white,
                            size: 40,
                          ),
                  ),
                ),
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
                if (!item.isAvailableForToday)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                item.nama,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.alexandria(
                  color: const Color(0xFF1A1818),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 0),
            Text(
              item.formattedHarga,
              style: GoogleFonts.alexandria(
                color: const Color(0xFFD05122),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!item.isAvailableForToday)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  '⏰ Pre-order H-1',
                  style: GoogleFonts.alexandria(
                    color: Colors.orange.shade700,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}