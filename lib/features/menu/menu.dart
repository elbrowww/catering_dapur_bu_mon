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

  final TextEditingController _searchController =
      TextEditingController();

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

  // ============================================================
  // FETCH MENU
  // ============================================================
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
          if (menu.kategori.isNotEmpty &&
              menu.kategori != 'Lainnya') {
            kategoriSet.add(menu.kategori);
          }
        }

        _kategoriList = [
          'Semua',
          ...kategoriSet.toList(),
        ];
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat menu: $e'),
        ),
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

  // ============================================================
  // FILTER MENU
  // ============================================================
  List<MenuModel> get _menuTerfilter {
    return _semuaMenu.where((item) {
      final cocokKategori =
          _kategoriAktif == 'Semua' ||
              item.kategori == _kategoriAktif;

      final cocokSearch = _searchQuery.isEmpty ||
          item.nama
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

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

      return cocokKategori &&
          cocokSearch &&
          cocokJenis;
    }).toList();
  }

  // ============================================================
  // SEARCH
  // ============================================================
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

  // ============================================================
  // UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final double statusBarHeight =
        MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      body: RefreshIndicator(
        onRefresh: _refreshMenu,

        child: Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================
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
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),

                boxShadow: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),

              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  statusBarHeight + 16,
                  20,
                  20,
                ),

                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),

                        borderRadius:
                            BorderRadius.circular(14),
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
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Text(
                            'Menu',
                            style:
                                GoogleFonts.alexandria(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          Text(
                            'Pilih makanan favoritmu',
                            style:
                                GoogleFonts.alexandria(
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

            // ==================================================
            // CONTENT
            // ==================================================
            Expanded(
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // ==========================================
                    // SEARCH BAR
                    // ==========================================
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),

                      child: Container(
                        height: 50,

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                              BorderRadius.circular(18),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),

                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,

                          style:
                              GoogleFonts.alexandria(
                            fontSize: 14,
                            color:
                                const Color(0xFF1A1818),
                          ),

                          decoration: InputDecoration(
                            hintText: 'Cari menu...',
                            hintStyle:
                                GoogleFonts.alexandria(
                              color:
                                  Colors.grey.shade500,
                              fontSize: 14,
                            ),

                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFFD05122),
                            ),

                            suffixIcon:
                                _searchQuery.isNotEmpty
                                    ? IconButton(
                                        onPressed:
                                            _clearSearch,

                                        icon: const Icon(
                                          Icons.close,
                                          size: 18,
                                        ),
                                      )
                                    : null,

                            border: InputBorder.none,

                            contentPadding:
                                const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ==========================================
                    // FILTER JENIS
                    // ==========================================
                    SizedBox(
                      height: 40,

                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,

                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),

                        child: Row(
                          children: [
                            'Semua',
                            'Tersedia',
                            'Pre-order'
                          ].map((jenis) {
                            final aktif =
                                _jenisFilter == jenis;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _jenisFilter = jenis;
                                });
                              },

                              child: Container(
                                margin:
                                    const EdgeInsets.only(
                                  right: 10,
                                ),

                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),

                                decoration: BoxDecoration(
                                  color: aktif
                                      ? const Color(
                                          0xFFEE8B2E)
                                      : Colors.white,

                                  borderRadius:
                                      BorderRadius
                                          .circular(22),

                                  border: Border.all(
                                    color:
                                        const Color(
                                      0xFFDB6626,
                                    ),
                                    width: 1.4,
                                  ),
                                ),

                                child: Text(
                                  jenis,

                                  style:
                                      GoogleFonts
                                          .alexandria(
                                    color: aktif
                                        ? Colors.white
                                        : Colors.black87,

                                    fontSize: 12,

                                    fontWeight: aktif
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ==========================================
                    // FILTER KATEGORI
                    // ==========================================
                    SizedBox(
                      height: 40,

                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,

                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),

                        child: Row(
                          children:
                              _kategoriList.map((kat) {
                            final aktif =
                                _kategoriAktif == kat;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _kategoriAktif =
                                      kat;
                                });
                              },

                              child: Container(
                                margin:
                                    const EdgeInsets.only(
                                  right: 10,
                                ),

                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),

                                decoration: BoxDecoration(
                                  color: aktif
                                      ? const Color(
                                          0xFFEE8B2E)
                                      : Colors.white,

                                  borderRadius:
                                      BorderRadius
                                          .circular(22),

                                  border: Border.all(
                                    color:
                                        const Color(
                                      0xFFDB6626,
                                    ),
                                    width: 1.4,
                                  ),
                                ),

                                child: Text(
                                  kat,

                                  style:
                                      GoogleFonts
                                          .alexandria(
                                    color: aktif
                                        ? Colors.white
                                        : Colors.black87,

                                    fontSize: 12,

                                    fontWeight: aktif
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // ==========================================
                    // JARAK LEBIH RAPAT
                    // ==========================================
                    const SizedBox(height: 4),

                    // ==========================================
                    // INFO SEARCH
                    // ==========================================
                    if (_searchQuery.isNotEmpty &&
                        !_isLoading)
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),

                        child: Align(
                          alignment:
                              Alignment.centerLeft,

                          child: Text(
                            'Ditemukan ${_menuTerfilter.length} menu untuk "$_searchQuery"',

                            style:
                                GoogleFonts.alexandria(
                              color:
                                  Colors.grey.shade600,
                              fontSize: 12,
                              fontStyle:
                                  FontStyle.italic,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 4),

                    // ==========================================
                    // CONTENT
                    // ==========================================
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

  // ============================================================
  // BUILD CONTENT
  // ============================================================
  Widget _buildContent() {
    // ==========================================================
    // LOADING
    // ==========================================================
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding:
              EdgeInsets.symmetric(vertical: 32),

          child: CircularProgressIndicator(
            color: Color(0xFFD05122),
          ),
        ),
      );
    }

    // ==========================================================
    // ERROR
    // ==========================================================
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: 32),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.grey[400],
              ),

              const SizedBox(height: 12),

              Text(
                _errorMessage!,
                textAlign: TextAlign.center,

                style:
                    GoogleFonts.alexandria(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _fetchMenu,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFD05122),

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),

                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // ==========================================================
    // EMPTY
    // ==========================================================
    if (_menuTerfilter.isEmpty) {
      return Center(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: 32),

          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey.shade400,
              ),

              const SizedBox(height: 16),

              Text(
                'Menu Tidak Ditemukan',

                style:
                    GoogleFonts.alexandria(
                  color: Colors.grey.shade700,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _searchQuery.isEmpty
                    ? 'Tidak ada menu tersedia'
                    : 'Tidak ada menu dengan kata "$_searchQuery"',

                style:
                    GoogleFonts.alexandria(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ==========================================================
    // GRID MENU
    // ==========================================================
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(14, 6, 14, 0),

      child: GridView.builder(
        shrinkWrap: true,

        physics:
            const NeverScrollableScrollPhysics(),

        itemCount: _menuTerfilter.length,

        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,

          childAspectRatio: 0.70,

          crossAxisSpacing: 12,
          mainAxisSpacing: 14,
        ),

        itemBuilder: (context, index) {
          return _MenuCard(
            item: _menuTerfilter[index],
          );
        },
      ),
    );
  }
}

// ================================================================
// MENU CARD
// ================================================================
class _MenuCard extends StatelessWidget {
  final MenuModel item;

  const _MenuCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPreorder =
        !item.isAvailableForToday;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DetailMenuPage(menu: item),
        ),
      ),

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(24),

          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // =================================================
            // IMAGE
            // =================================================
            Expanded(
              flex: 6,

              child: Stack(
                children: [
                  Container(
                    width: double.infinity,

                    margin:
                        const EdgeInsets.all(10),

                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(20),

                      gradient:
                          const LinearGradient(
                        begin: Alignment.topLeft,
                        end:
                            Alignment.bottomRight,
                        colors: [
                          Color(0xFFEE8B2E),
                          Color(0xFFD05122),
                        ],
                      ),
                    ),

                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(20),

                      child: item.foto.isNotEmpty
                          ? Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,

                              loadingBuilder:
                                  (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress ==
                                    null) {
                                  return child;
                                }

                                return const Center(
                                  child:
                                      CircularProgressIndicator(
                                    color:
                                        Colors.white,
                                    strokeWidth: 2,
                                  ),
                                );
                              },

                              errorBuilder:
                                  (_, __, ___) {
                                return const Center(
                                  child: Icon(
                                    Icons.fastfood,
                                    color:
                                        Colors.white,
                                    size: 46,
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Icon(
                                Icons.fastfood,
                                color: Colors.white,
                                size: 46,
                              ),
                            ),
                    ),
                  ),

                  // =============================================
                  // BADGE
                  // =============================================
                  Positioned(
                    top: 18,
                    right: 18,

                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),

                      decoration: BoxDecoration(
                        color: isPreorder
                            ? Colors.orange
                            : Colors.green,

                        borderRadius:
                            BorderRadius.circular(
                                20),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.15),
                            blurRadius: 4,
                            offset:
                                const Offset(0, 2),
                          ),
                        ],
                      ),

                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min,

                        children: [
                          Icon(
                            isPreorder
                                ? Icons
                                    .schedule_rounded
                                : Icons
                                    .check_circle,

                            size: 11,
                            color: Colors.white,
                          ),

                          const SizedBox(width: 4),

                          Text(
                            isPreorder
                                ? 'Pre-order'
                                : 'Tersedia',

                            style:
                                GoogleFonts
                                    .alexandria(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =================================================
            // CONTENT
            // =================================================
            Expanded(
              flex: 4,

              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  14,
                  2,
                  14,
                  12,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [
                    // =========================================
                    // NAMA MENU
                    // =========================================
                    Text(
                      item.nama,

                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          GoogleFonts.alexandria(
                        fontSize: 14,
                        height: 1.3,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            const Color(0xFF1A1818),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // =========================================
                    // HARGA
                    // =========================================
                    Text(
                      item.formattedHarga,

                      style:
                          GoogleFonts.alexandria(
                        color:
                            const Color(0xFFD05122),
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    // =========================================
                    // PREORDER TEXT
                    // =========================================
                    if (isPreorder)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          top: 4,
                        ),

                        child: Row(
                          children: [
                            Icon(
                              Icons
                                  .access_time_rounded,
                              size: 12,
                              color: Colors
                                  .orange.shade700,
                            ),

                            const SizedBox(width: 4),

                            Expanded(
                              child: Text(
                                'Pre-order H-1',

                                overflow:
                                    TextOverflow
                                        .ellipsis,

                                style:
                                    GoogleFonts
                                        .alexandria(
                                  color: Colors
                                      .orange
                                      .shade700,
                                  fontSize: 10,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}