import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/admin/shared/header_admin.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';
import 'package:catering_dapur_bu_mon/services/session_manager.dart';
import 'package:catering_dapur_bu_mon/models/ulasan_model.dart';

class _CustomerData {
  final String nama;
  final String email;
  final String alamat;

  const _CustomerData({
    required this.nama,
    required this.email,
    required this.alamat,
  });

  factory _CustomerData.fromJson(Map<String, dynamic> json) {
    return _CustomerData(
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      alamat: json['alamat'] ?? '',
    );
  }
}

class DataCustomerPage extends StatefulWidget {
  const DataCustomerPage({super.key});

  @override
  State<DataCustomerPage> createState() => _DataCustomerPageState();
}

class _DataCustomerPageState extends State<DataCustomerPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // ── Customer state ──
  List<_CustomerData> _customers = [];
  bool _isLoadingCustomer = true;
  String? _errorCustomer;

  // ── Ulasan state ──
  List<UlasanModel> _ulasanList = [];
  bool _isLoadingUlasan = true;
  String? _errorUlasan;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
    _fetchUlasan();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCustomers() async {
    final token = await SessionManager.getToken();
    final user = await SessionManager.getUser();
    print('🔍 Token: $token');
    print('🔍 User: $user');

    setState(() {
      _isLoadingCustomer = true;
      _errorCustomer = null;
    });
    try {
      final rawList = await ApiService.getDataCustomer();
      setState(() {
        _customers = rawList
            .map((item) => _CustomerData.fromJson(item as Map<String, dynamic>))
            .toList();
        _isLoadingCustomer = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorCustomer = e.message;
        _isLoadingCustomer = false;
      });
    }
  }

  Future<void> _fetchUlasan() async {
    setState(() {
      _isLoadingUlasan = true;
      _errorUlasan = null;
    });
    try {
      final rawList = await ApiService.getUlasan(limit: 20);
      setState(() {
        _ulasanList = rawList
            .map((item) => UlasanModel.fromJson(item as Map<String, dynamic>))
            .toList();
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

  List<_CustomerData> get _filtered {
    if (_searchQuery.isEmpty) return _customers;
    return _customers
        .where((c) =>
            c.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.email.contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const HeaderAdmin(),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Ulasan Slider ──────────────────────────
                    _UlasanSliderCard(
                      ulasanList: _ulasanList,
                      isLoading: _isLoadingUlasan,
                      errorMessage: _errorUlasan,
                      onRetry: _fetchUlasan,
                    ),
                    const SizedBox(height: 20),

                    // ── Data Customer ──────────────────────────
                    Text(
                      'Data Customer',
                      style: GoogleFonts.alexandria(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SearchBar(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                    const SizedBox(height: 12),
                    if (_isLoadingCustomer)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(
                              color: Color(0xFFD05122)),
                        ),
                      )
                    else if (_errorCustomer != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Text(
                                _errorCustomer!,
                                style: GoogleFonts.alexandria(
                                    color: Colors.red, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _fetchCustomers,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD05122)),
                                child: Text('Coba Lagi',
                                    style: GoogleFonts.alexandria(
                                        color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_filtered.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'Tidak ada customer ditemukan.',
                            style: GoogleFonts.alexandria(
                                color: Colors.black54, fontSize: 14),
                          ),
                        ),
                      )
                    else
                      ..._filtered.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _CustomerCard(customer: c),
                          )),
                    const SizedBox(height: 80),
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

// ── Ulasan Slider Card ─────────────────────────────────────────
class _UlasanSliderCard extends StatefulWidget {
  final List<UlasanModel> ulasanList;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  const _UlasanSliderCard({
    required this.ulasanList,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  State<_UlasanSliderCard> createState() => _UlasanSliderCardState();
}

class _UlasanSliderCardState extends State<_UlasanSliderCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            spreadRadius: 0,
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFFD05122), Color(0xFFEE8B2E), Color(0xFFFBA839)],
          stops: [0.17, 0.47, 0.60],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul Ulasan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.network(
                    'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2F33ebd0d8-c586-482a-8c11-26e8d5a85039.png',
                    width: 23,
                    height: 22,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.star, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ulasan',
                    style: GoogleFonts.alexandria(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Indikator halaman
              if (!widget.isLoading &&
                  widget.errorMessage == null &&
                  widget.ulasanList.isNotEmpty)
                Text(
                  '${_currentPage + 1} / ${widget.ulasanList.length}',
                  style: GoogleFonts.alexandria(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Konten: Loading / Error / Empty / Slider
          if (widget.isLoading)
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFD05122)),
              ),
            )
          else if (widget.errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(widget.errorMessage!,
                      style: GoogleFonts.alexandria(
                          color: Colors.red, fontSize: 12),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: widget.onRetry,
                    child: Text('Coba Lagi',
                        style: GoogleFonts.alexandria(
                          color: const Color(0xFFD05122),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ],
              ),
            )
          else if (widget.ulasanList.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Belum ada ulasan dari customer.',
                style: GoogleFonts.alexandria(
                    color: Colors.black54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            )
          else
            Builder(builder: (_) {
              final u = widget.ulasanList[_currentPage];
              return Column(
                children: [
                  // ── Card ulasan + panah kiri kanan ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Tombol prev
                      GestureDetector(
                        onTap: _currentPage > 0
                            ? () => setState(() => _currentPage--)
                            : null,
                        child: Icon(
                          Icons.chevron_left,
                          color: _currentPage > 0
                              ? Colors.white
                              : Colors.white30,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Card ulasan
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x3F000000),
                                spreadRadius: 0,
                                offset: Offset(0, 4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Nama + tanggal
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    u.namaCustomer,
                                    style: GoogleFonts.alexandria(
                                      color: Colors.black,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    u.tanggal,
                                    style: GoogleFonts.alexandria(
                                      color: Colors.black45,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              // Bintang rating
                              Row(
                                children: List.generate(5, (si) {
                                  return Icon(
                                    si < u.rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: const Color(0xFFF79F36),
                                    size: 12,
                                  );
                                }),
                              ),
                              const SizedBox(height: 6),
                              // Komentar FULL
                              Text(
                                u.komentar,
                                style: GoogleFonts.alexandria(
                                  color: Colors.black87,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),
                      // Tombol next
                      GestureDetector(
                        onTap: _currentPage < widget.ulasanList.length - 1
                            ? () => setState(() => _currentPage++)
                            : null,
                        child: Icon(
                          Icons.chevron_right,
                          color: _currentPage < widget.ulasanList.length - 1
                              ? Colors.white
                              : Colors.white30,
                          size: 28,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Dot indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.ulasanList.length, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentPage == i ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? Colors.white
                              : Colors.white54,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }
}

// ── Search Bar ─────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3F000000),
                  spreadRadius: 0,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlignVertical: TextAlignVertical.center,
              style: GoogleFonts.lora(
                  color: const Color(0xFF1A1818), fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari Nama atau Nomor HP',
                hintStyle: GoogleFonts.lora(
                  color: const Color(0xFF1A1818).withOpacity(0.5),
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [Color(0xFFD05122), Color(0xFFEE8B2E), Color(0xFFFBA839)],
              stops: [0.18, 0.61, 0.85],
            ),
          ),
          child: Center(
            child: Image.network(
              'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2Fabbdda7c-5508-4ff4-a21b-ee815edb8318.png',
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Customer Card ──────────────────────────────────────────────
class _CustomerCard extends StatelessWidget {
  final _CustomerData customer;
  const _CustomerCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            spreadRadius: 3,
            offset: Offset(0, 1.7),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFFF79F36),
            child: Text(
              customer.nama.isNotEmpty
                  ? customer.nama[0].toUpperCase()
                  : '?',
              style: GoogleFonts.alexandria(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.nama,
                    style: GoogleFonts.alexandria(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(customer.email,
                    style: GoogleFonts.alexandria(
                        color: const Color(0xFFC98C63),
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                Text(customer.alamat,
                    style: GoogleFonts.alexandria(
                        color: const Color(0xFFC98C63),
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black45),
        ],
      ),
    );
  }
}