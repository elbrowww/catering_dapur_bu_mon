import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// AKTIVITAS PAGE
// ============================================================
class AktivitasPage extends StatefulWidget {
  const AktivitasPage({super.key});

  @override
  State<AktivitasPage> createState() => _AktivitasPageState();
}

class _AktivitasPageState extends State<AktivitasPage> {
  String _filterAktif = 'Semua';

  final List<Map<String, dynamic>> _semuaAktivitas = [
    {
      'tanggal': '12 Maret 2026',
      'nama': 'Ayam Panggang',
      'harga': 'Rp. 120.000',
      'pembayaran': 'Transfer BCA',
      'bulan': 3,
      'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F523acacd6359d74640c5b9f05994ae4793dcf28fimage%206.png?alt=media&token=9f522f1f-8681-45fa-9d68-c4819e35a856',
    },
    {
      'tanggal': '6 Februari 2026',
      'nama': 'Ayam Panggang',
      'harga': 'Rp. 120.000',
      'pembayaran': 'Transfer BCA',
      'bulan': 2,
      'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F523acacd6359d74640c5b9f05994ae4793dcf28fimage%206.png?alt=media&token=e673ff00-412d-473c-97a9-922c41f84133',
    },
    {
      'tanggal': '6 Februari 2026',
      'nama': 'Ayam Panggang',
      'harga': 'Rp. 120.000',
      'pembayaran': 'Transfer BCA',
      'bulan': 2,
      'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F523acacd6359d74640c5b9f05994ae4793dcf28fimage%206.png?alt=media&token=3022baec-5e8f-4f52-a9d2-0ea2cd2ac6f8',
    },
    {
      'tanggal': '12 Januari 2026',
      'nama': 'Ayam Panggang',
      'harga': 'Rp. 120.000',
      'pembayaran': 'Transfer BCA',
      'bulan': 1,
      'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F523acacd6359d74640c5b9f05994ae4793dcf28fimage%206.png?alt=media&token=9cef7902-36c5-4570-be95-d439e4bb9d7f',
    },
    {
      'tanggal': '12 Januari 2026',
      'nama': 'Ayam Panggang',
      'harga': 'Rp. 120.000',
      'pembayaran': 'Transfer BCA',
      'bulan': 1,
      'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F523acacd6359d74640c5b9f05994ae4793dcf28fimage%206.png?alt=media&token=5ac10971-5eaa-400e-ae24-285f662a89dd',
    },
    {
      'tanggal': '12 Januari 2026',
      'nama': 'Ayam Panggang',
      'harga': 'Rp. 120.000',
      'pembayaran': 'Transfer BCA',
      'bulan': 1,
      'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F523acacd6359d74640c5b9f05994ae4793dcf28fimage%206.png?alt=media&token=d5cd8822-c462-4163-bf20-3296c9725ce2',
    },
    {
      'tanggal': '6 Februari 2026',
      'nama': 'Ayam Panggang',
      'harga': 'Rp. 120.000',
      'pembayaran': 'Transfer BCA',
      'bulan': 2,
      'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F523acacd6359d74640c5b9f05994ae4793dcf28fimage%206.png?alt=media&token=f533d1c0-03b0-4292-93d4-100f83e85c40',
    },
    {
      'tanggal': '6 Februari 2026',
      'nama': 'Ayam Panggang',
      'harga': 'Rp. 120.000',
      'pembayaran': 'Transfer BCA',
      'bulan': 2,
      'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F523acacd6359d74640c5b9f05994ae4793dcf28fimage%206.png?alt=media&token=ec6d524c-c9b5-49c5-a80e-380b885ded37',
    },
    {
      'tanggal': '6 Februari 2026',
      'nama': 'Ayam Panggang',
      'harga': 'Rp. 120.000',
      'pembayaran': 'Transfer BCA',
      'bulan': 2,
      'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F523acacd6359d74640c5b9f05994ae4793dcf28fimage%206.png?alt=media&token=27740357-d795-4d91-83a3-5c4d3b0b81f2',
    },
  ];

  final int _bulanSekarang = 3;
  final int _bulanLalu = 2;

  List<Map<String, dynamic>> get _terfilter {
    if (_filterAktif == 'Bulan ini') {
      return _semuaAktivitas.where((a) => a['bulan'] == _bulanSekarang).toList();
    } else if (_filterAktif == 'Bulan Lalu') {
      return _semuaAktivitas.where((a) => a['bulan'] == _bulanLalu).toList();
    }
    return _semuaAktivitas;
  }

  Map<String, List<Map<String, dynamic>>> get _perTanggal {
    final Map<String, List<Map<String, dynamic>>> result = {};
    for (final item in _terfilter) {
      final tgl = item['tanggal'] as String;
      result.putIfAbsent(tgl, () => []).add(item);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Ambil tinggi status bar
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFAC3715), Color(0xFFD05122), Color(0xFFEE8B2E)],
          stops: [0.21, 0.56, 0.83],
        ),
      ),
      child: Column( // ✅ Hapus SafeArea, ganti Column biasa
        children: [
          // ── Header "Aktivitas" ─────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(23, 14 + statusBarHeight, 23, 0), // ✅ Tambah statusBarHeight
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
                  'Aktivitas',
                  style: GoogleFonts.alexandria(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Body putih ─────────────────────────────────
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  // ── Filter chips ───────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(34, 18, 34, 12),
                    child: Row(
                      children: ['Semua', 'Bulan ini', 'Bulan Lalu']
                          .map((f) => Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: _FilterChip(
                                  label: f,
                                  aktif: _filterAktif == f,
                                  onTap: () =>
                                      setState(() => _filterAktif = f),
                                ),
                              ))
                          .toList(),
                    ),
                  ),

                  // ── List aktivitas ─────────────────────
                  Expanded(
                    child: _terfilter.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long_outlined,
                                    size: 64, color: Colors.grey.shade300),
                                const SizedBox(height: 12),
                                Text('Belum ada aktivitas',
                                    style: GoogleFonts.alexandria(
                                        color: Colors.grey, fontSize: 15)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
                            itemCount: _perTanggal.keys.length,
                            itemBuilder: (_, i) {
                              final tgl = _perTanggal.keys.elementAt(i);
                              final items = _perTanggal[tgl]!;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 6, top: 4),
                                    child: Opacity(
                                      opacity: 0.5,
                                      child: Text(
                                        tgl,
                                        style: GoogleFonts.alexandria(
                                          color: const Color(0xFF1A1818),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  ...items.map((item) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: _AktivitasItem(
                                          nama: item['nama'],
                                          harga: item['harga'],
                                          pembayaran: item['pembayaran'],
                                          imageUrl: item['imageUrl'],
                                        ),
                                      )),
                                ],
                              );
                            },
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
}

// ── Filter Chip ────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool aktif;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.aktif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 25,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: aktif ? const Color(0xFFEE8B2E) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            width: 1.5,
            color: const Color(0xFFDB6626),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.lora(
              color: Colors.black,
              fontSize: 12,
              fontWeight: aktif ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Item Aktivitas ─────────────────────────────────────────────
class _AktivitasItem extends StatelessWidget {
  final String nama;
  final String harga;
  final String pembayaran;
  final String imageUrl;

  const _AktivitasItem({
    required this.nama,
    required this.harga,
    required this.pembayaran,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.all(8),
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
                Text(harga,
                    style: GoogleFonts.alexandria(
                      color: const Color(0xFFDC6727),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    )),
                Opacity(
                  opacity: 0.7,
                  child: Text(pembayaran,
                      style: GoogleFonts.alexandria(
                        color: Colors.black,
                        fontSize: 14,
                      )),
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () {},
              child: Opacity(
                opacity: 0.5,
                child: Text(
                  'Lihat Detail',
                  style: GoogleFonts.alexandria(
                    color: const Color(0xFF1A1818),
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}