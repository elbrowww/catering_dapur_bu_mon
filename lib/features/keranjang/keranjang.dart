import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/features/keranjang/keranjang-controller.dart';
import 'package:catering_dapur_bu_mon/features/keranjang/checkout.dart';
import 'package:catering_dapur_bu_mon/services/dio_helper.dart';

class KeranjangPage extends StatefulWidget {
  const KeranjangPage({super.key});

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  final _ctrl = KeranjangController.instance;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onUpdate);
    _loadKeranjang();
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    // Tampilkan snackbar error jika ada
    if (_ctrl.errorMessage != null && mounted) {
      final msg = _ctrl.errorMessage!;
      _ctrl.clearError();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg, style: GoogleFonts.alexandria(color: Colors.white)),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    }
    setState(() {});
  }

  Future<void> _loadKeranjang() async {
    await _ctrl.loadKeranjang();
  }

  void _kosongkan() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Kosongkan Keranjang',
            style: GoogleFonts.alexandria(fontWeight: FontWeight.bold)),
        content: Text('Yakin ingin menghapus semua item?',
            style: GoogleFonts.alexandria()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: GoogleFonts.alexandria(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await _ctrl.kosongkan();
              if (mounted) Navigator.pop(context);
            },
            child: Text('Ya, Kosongkan',
                style: GoogleFonts.alexandria(
                    color: const Color(0xFFD05122),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _checkout() {
    if (_ctrl.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Keranjang masih kosong!',
              style: GoogleFonts.alexandria(color: Colors.white)),
          backgroundColor: const Color(0xFFD05122),
        ),
      );
      return;
    }

    // FIX: Gunakan .then() agar saat user kembali dari CheckoutPage,
    // keranjang di-reload ulang. Ini mencegah halaman stuck di loading
    // karena CheckoutPage sebelumnya mengubah state _isLoading pada singleton.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CheckoutPage()),
    ).then((_) {
      if (mounted) {
        _ctrl.loadKeranjang();
      }
    });
  }

  String _getFullImageUrl(String imageUrl) {
    if (imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http')) return imageUrl;
    return '${DioHelper.imageBaseUrl}$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    final items = _ctrl.items;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double navbarHeight = kBottomNavigationBarHeight + 60;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFAC3715), Color(0xFFD05122), Color(0xFFEE8B2E)],
          stops: [0.21, 0.56, 0.83],
        ),
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(24, 16 + statusBarHeight, 24, 0),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(46),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF3F1F0C),
                    Color(0xFFAC3715),
                    Color(0xFFD05122),
                    Color(0xFF66270F),
                  ],
                  stops: [0.13, 0.36, 0.61, 0.82],
                ),
              ),
              child: Center(
                child: Text(
                  'Keranjang',
                  style: GoogleFonts.alexandria(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Body putih ──────────────────────────────────────
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: _ctrl.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFD05122),
                      ),
                    )
                  : items.isEmpty
                      ? _buildKosong()
                      : Column(
                          children: [
                            Expanded(
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                    20, 20, 20, 12),
                                itemCount: items.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, i) => _KeranjangItem(
                                  nama: items[i]['nama'],
                                  harga: _ctrl.formatRupiah(items[i]['harga']),
                                  jumlah: items[i]['jumlah'],
                                  imageUrl: _getFullImageUrl(
                                      items[i]['imageUrl'] ?? ''),
                                  isPreorder: items[i]['is_preorder'] == true,
                                  onTambah: () => _ctrl.tambahSatu(i),
                                  onKurang: () => _ctrl.kurangSatu(i),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                  20, 0, 20, navbarHeight),
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Total',
                                            style: GoogleFonts.alexandria(
                                                color: Colors.black,
                                                fontSize: 16)),
                                        Text(
                                          _ctrl.formatRupiah(_ctrl.total),
                                          style: GoogleFonts.alexandria(
                                            color: const Color(0xFFDC6727),
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  GestureDetector(
                                    onTap:
                                        _ctrl.isLoading ? null : _checkout,
                                    child: Container(
                                      width: double.infinity,
                                      height: 43,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(18),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFEE8B2E),
                                            Color(0xFFD05122),
                                            Color(0xFFAC3715),
                                          ],
                                          stops: [0.17, 0.47, 0.79],
                                        ),
                                      ),
                                      child: Center(
                                        child: _ctrl.isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Text('Checkout',
                                                style: GoogleFonts.alexandria(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                )),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  GestureDetector(
                                    onTap:
                                        _ctrl.isLoading ? null : _kosongkan,
                                    child: Container(
                                      width: double.infinity,
                                      height: 43,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(18),
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
                                        child: Text('Kosongkan Keranjang',
                                            style: GoogleFonts.alexandria(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            )),
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
    );
  }

  Widget _buildKosong() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Keranjang masih kosong',
              style:
                  GoogleFonts.alexandria(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Yuk tambahkan menu favoritmu!',
              style: GoogleFonts.alexandria(
                  color: Colors.grey.shade400, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Item Keranjang ──────────────────────────────────────────────────────────
class _KeranjangItem extends StatelessWidget {
  final String nama;
  final String harga;
  final int jumlah;
  final String imageUrl;
  final bool isPreorder;
  final VoidCallback onTambah;
  final VoidCallback onKurang;

  const _KeranjangItem({
    required this.nama,
    required this.harga,
    required this.jumlah,
    required this.imageUrl,
    required this.isPreorder,
    required this.onTambah,
    required this.onKurang,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
          // Gambar
          Container(
            width: 65,
            height: 80,
            alignment: Alignment.center,
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFFF79F36),
                borderRadius: BorderRadius.circular(5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
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
                          size: 32,
                        ),
                      )
                    : const Icon(Icons.fastfood,
                        color: Colors.white, size: 32),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nama,
                      style: GoogleFonts.alexandria(
                          color: Colors.black, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(harga,
                      style: GoogleFonts.alexandria(
                        color: const Color(0xFFDC6727),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      )),
                  // Badge pre-order per item
                  if (isPreorder) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '⏰ Pre-order',
                        style: GoogleFonts.alexandria(
                          color: Colors.orange.shade800,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Tombol jumlah
          Row(
            children: [
              _TombolJumlah(onTap: onKurang, isReduce: true),
              const SizedBox(width: 2),
              Container(
                width: 26,
                height: 17,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Center(
                  child: Text(
                    '$jumlah',
                    style: GoogleFonts.alexandria(
                      color: const Color(0xFF1A1818),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              _TombolJumlah(onTap: onTambah, isReduce: false),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Tombol + / − ────────────────────────────────────────────────────────────
class _TombolJumlah extends StatelessWidget {
  final VoidCallback onTap;
  final bool isReduce;

  const _TombolJumlah({required this.onTap, required this.isReduce});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 17,
        height: 17,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFD05122),
              Color(0xFFEE8B2E),
              Color(0xFFFBA839),
            ],
            stops: [0.17, 0.47, 0.60],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              spreadRadius: 1,
              offset: Offset(0, 0.6),
              blurRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            isReduce ? Icons.remove : Icons.add,
            size: 11,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}