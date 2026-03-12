import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// KERANJANG PAGE
// Tidak pakai Scaffold & tidak pakai CustomNavbar
// Navbar sudah dihandle oleh MainScreen di main.dart
// ============================================================
class KeranjangPage extends StatefulWidget {
  const KeranjangPage({super.key});

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  // Data keranjang — bisa ditambah/kurangi secara dinamis
  final List<Map<String, dynamic>> _items = [
    {
      'nama': 'Ayam Panggang',
      'harga': 120000,
      'jumlah': 1,
      'imageUrl':
          'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F523acacd6359d74640c5b9f05994ae4793dcf28fimage%206.png?alt=media&token=7416cb0c-e12e-49f2-bdb8-2d7feafeb80e',
    },
    {
      'nama': 'Ayam Panggang',
      'harga': 120000,
      'jumlah': 1,
      'imageUrl':
          'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F523acacd6359d74640c5b9f05994ae4793dcf28fimage%206.png?alt=media&token=84fc86f9-2959-4e8b-8727-c612b02fd370',
    },
  ];

  int get _total =>
      _items.fold(0, (sum, item) => sum + (item['harga'] as int) * (item['jumlah'] as int));

  String _formatRupiah(int value) {
    final s = value.toString();
    final result = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) result.write('.');
      result.write(s[i]);
    }
    return 'Rp. ${result.toString()}';
  }

  void _tambah(int i) => setState(() => _items[i]['jumlah']++);

  void _kurang(int i) {
    setState(() {
      if (_items[i]['jumlah'] > 1) {
        _items[i]['jumlah']--;
      } else {
        _items.removeAt(i);
      }
    });
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
            onPressed: () {
              setState(() => _items.clear());
              Navigator.pop(context);
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
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Keranjang masih kosong!',
              style: GoogleFonts.alexandria(color: Colors.white)),
          backgroundColor: const Color(0xFFD05122),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Checkout berhasil! Total: ${_formatRupiah(_total)}',
            style: GoogleFonts.alexandria(color: Colors.white)),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFAC3715), Color(0xFFD05122), Color(0xFFEE8B2E)],
          stops: [0.21, 0.56, 0.83],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── Header "Keranjang" ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
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

            // ── Body putih ────────────────────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: _items.isEmpty
                    ? _buildKosong()
                    : Column(
                        children: [
                          // List item keranjang
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                              itemCount: _items.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, i) =>
                                  _KeranjangItem(
                                nama: _items[i]['nama'],
                                harga: _formatRupiah(_items[i]['harga']),
                                jumlah: _items[i]['jumlah'],
                                imageUrl: _items[i]['imageUrl'],
                                onTambah: () => _tambah(i),
                                onKurang: () => _kurang(i),
                              ),
                            ),
                          ),

                          // ── Total + tombol ─────────────────
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20, 12, 20, 16),
                            child: Column(
                              children: [
                                // Garis total
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
                                            fontSize: 16,
                                          )),
                                      Text(_formatRupiah(_total),
                                          style: GoogleFonts.alexandria(
                                            color: const Color(0xFFDC6727),
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Tombol Checkout
                                GestureDetector(
                                  onTap: _checkout,
                                  child: Container(
                                    width: double.infinity,
                                    height: 43,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
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
                                          spreadRadius: 3,
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text('Checkout',
                                          style: GoogleFonts.alexandria(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Tombol Kosongkan Keranjang
                                GestureDetector(
                                  onTap: _kosongkan,
                                  child: Container(
                                    width: double.infinity,
                                    height: 43,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
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
              style: GoogleFonts.alexandria(
                  color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Yuk tambahkan menu favoritmu!',
              style: GoogleFonts.alexandria(
                  color: Colors.grey.shade400, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Item Keranjang ─────────────────────────────────────────────
class _KeranjangItem extends StatelessWidget {
  final String nama;
  final String harga;
  final int jumlah;
  final String imageUrl;
  final VoidCallback onTambah;
  final VoidCallback onKurang;

  const _KeranjangItem({
    required this.nama,
    required this.harga,
    required this.jumlah,
    required this.imageUrl,
    required this.onTambah,
    required this.onKurang,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
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
          // Gambar menu
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: const Color(0xFFF79F36),
              borderRadius: BorderRadius.circular(5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.fastfood, color: Colors.white, size: 32),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Nama & harga
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama,
                    style: GoogleFonts.alexandria(
                      color: Colors.black,
                      fontSize: 14,
                    )),
                const SizedBox(height: 2),
                Text(harga,
                    style: GoogleFonts.alexandria(
                      color: const Color(0xFFDC6727),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),

          // Kontrol jumlah: kurang | angka | tambah
          Row(
            children: [
              // Tombol kurang (−)
              _TombolJumlah(
                imageUrl:
                    'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMOKhEnss8buSiiHoow%2F1f515d82-8a3a-479c-81ec-e3b01d36f91f.png',
                onTap: onKurang,
                isReduce: true,
              ),
              const SizedBox(width: 2),
              // Angka jumlah
              Container(
                width: 26,
                height: 17,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Center(
                  child: Text('$jumlah',
                      style: GoogleFonts.alexandria(
                        color: const Color(0xFF1A1818),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
              const SizedBox(width: 2),
              // Tombol tambah (+)
              _TombolJumlah(
                imageUrl:
                    'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMOKhEnss8buSiiHoow%2F9e178141-7188-45f0-bcdd-c5c667a5fc47.png',
                onTap: onTambah,
                isReduce: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Tombol + / − ───────────────────────────────────────────────
class _TombolJumlah extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;
  final bool isReduce;

  const _TombolJumlah({
    required this.imageUrl,
    required this.onTap,
    required this.isReduce,
  });

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
            colors: [Color(0xFFD05122), Color(0xFFEE8B2E), Color(0xFFFBA839)],
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