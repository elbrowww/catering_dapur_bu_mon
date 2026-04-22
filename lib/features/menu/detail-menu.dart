import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/models/menu_model.dart';
// import 'package:catering_dapur_bu_mon/services/api_service.dart';
import 'package:catering_dapur_bu_mon/features/keranjang/keranjang-controller.dart';

// ============================================================
// DETAIL MENU PAGE
// Dipanggil via Navigator.push dari _MenuCard di menu.dart
// Menerima MenuModel dari API
// ============================================================
class DetailMenuPage extends StatefulWidget {
  final MenuModel menu;
  const DetailMenuPage({super.key, required this.menu});

  @override
  State<DetailMenuPage> createState() => _DetailMenuPageState();
}

class _DetailMenuPageState extends State<DetailMenuPage> {
  int _jumlah = 1;
  bool _isLoading = false;

  void _tambah() {
    // Jangan bisa tambah melebihi stok
    if (_jumlah < widget.menu.stok) {
      setState(() => _jumlah++);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stok hanya tersisa ${widget.menu.stok}',
            style: GoogleFonts.alexandria(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFFFA726),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _kurang() => setState(() {
        if (_jumlah > 1) _jumlah--;
      });

  Future<void> _tambahKeranjang() async {
    // Jangan bisa pesan jika stok habis
    if (widget.menu.isHabis) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stok ${widget.menu.nama} sedang habis.',
            style: GoogleFonts.alexandria(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFE53935),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await KeranjangController.instance.tambah(
        nama: widget.menu.nama,
        harga: widget.menu.harga.toInt(),
        imageUrl: widget.menu.foto,
        jumlah: _jumlah,
        idMenu: widget.menu.idMenu,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$_jumlah× ${widget.menu.nama} ditambahkan ke keranjang!',
                      style: GoogleFonts.alexandria(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$_jumlah× ${widget.menu.nama} ditambahkan ke keranjang! (Lokal)',
                      style: GoogleFonts.alexandria(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$_jumlah× ${widget.menu.nama} ditambahkan',
              style: GoogleFonts.alexandria(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool habis = widget.menu.isHabis;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Hero gambar ─────────────────────────────────
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            child: SizedBox(
              height: 300,
              child: Stack(
                children: [
                  // Background gradient oranye
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFEE8B2E),
                            Color(0xFFD05122),
                            Color(0xFFAC3715),
                          ],
                          stops: [0.17, 0.55, 0.90],
                        ),
                      ),
                    ),
                  ),
                  // Layer overlay dekorasi
                  Positioned.fill(
                    child: Image.network(
                      'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMOKhEnss8buSiiHoow%2Fb772f011-4b7a-4be1-bd2b-4419616209dc.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),
                  // Gambar makanan di tengah
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 201,
                          height: 201,
                          margin: const EdgeInsets.only(top: 50),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF79F36),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: widget.menu.foto.isNotEmpty
                                ? Image.network(
                                    widget.menu.foto,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.fastfood,
                                      color: Colors.white,
                                      size: 80,
                                    ),
                                  )
                                : const Icon(
                                    Icons.fastfood,
                                    color: Colors.white,
                                    size: 80,
                                  ),
                          ),
                        ),
                        // Overlay "Stok Habis" di atas gambar
                        if (habis)
                          Positioned(
                            top: 50,
                            child: Container(
                              width: 201,
                              height: 201,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.45),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE53935),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    'Stok Habis',
                                    style: GoogleFonts.alexandria(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
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

          // ── Tombol back ─────────────────────────────────
          Positioned(
            top: 48,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    size: 18, color: Color(0xFF1A1818)),
              ),
            ),
          ),

          // ── Panel info (putih, rounded atas) ────────────
          Positioned(
            top: 265,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(26, 22, 26, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama + rating
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.menu.nama,
                            style: GoogleFonts.alexandria(
                              color:
                                  const Color(0xFF1A1818).withOpacity(0.85),
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Color(0xFFF79F36), size: 24),
                            const SizedBox(width: 2),
                            Text(
                              '5',
                              style: GoogleFonts.alexandria(
                                color: const Color(0xFF1A1818)
                                    .withOpacity(0.8),
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Harga + Badge Stok berdampingan
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.menu.formattedHarga,
                          style: GoogleFonts.alexandria(
                            color: const Color(0xFFD76025),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Badge stok
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Color(widget.menu.warnaStok),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.menu.isHabis
                                    ? Icons.remove_shopping_cart_rounded
                                    : Icons.inventory_2_rounded,
                                color: Colors.white,
                                size: 13,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                widget.menu.labelStok,
                                style: GoogleFonts.alexandria(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Estimasi
                    Text(
                      'Estimasi Pembuatan 2 Jam  |  Minimal booking H-2',
                      style: GoogleFonts.alexandria(
                        color: const Color(0xFF1A1818).withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 14),

                    // Deskripsi
                    Text(
                      'Deskripsi',
                      style: GoogleFonts.alexandria(
                        color: const Color(0xFF1A1818).withOpacity(0.85),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.menu.deskripsi.isNotEmpty
                          ? widget.menu.deskripsi
                          : 'Menu spesial Dapur Bu Mon yang dimasak dengan bumbu rempah pilihan. '
                              'Cocok untuk berbagai acara seperti arisan, pernikahan, maupun pesanan harian. '
                              'Dijamin lezat dan higienis, disiapkan dengan penuh cinta oleh Bu Mon.',
                      style: GoogleFonts.alexandria(
                        color: const Color(0xFF1A1818).withOpacity(0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom bar ──────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Tombol kurang — disabled jika habis
                  _TombolBulat(
                    icon: Icons.remove,
                    onTap: habis ? () {} : _kurang,
                    disabled: habis,
                  ),
                  const SizedBox(width: 8),

                  // Angka jumlah
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        habis ? '0' : '$_jumlah',
                        style: GoogleFonts.alexandria(
                          color: const Color(0xFF1A1818),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Tombol tambah — disabled jika habis
                  _TombolBulat(
                    icon: Icons.add,
                    onTap: habis ? () {} : _tambah,
                    disabled: habis,
                  ),
                  const SizedBox(width: 14),

                  // Tombol Tambah Keranjang
                  Expanded(
                    child: GestureDetector(
                      onTap: (_isLoading || habis) ? null : _tambahKeranjang,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: habis
                                ? [
                                    Colors.grey.shade400,
                                    Colors.grey.shade500,
                                  ]
                                : const [
                                    Color(0xFFEE8B2E),
                                    Color(0xFFD05122),
                                    Color(0xFFAC3715),
                                  ],
                            stops: habis ? [0.0, 1.0] : [0.0, 0.5, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: habis
                                  ? Colors.grey.withOpacity(0.3)
                                  : const Color(0xFFD05122).withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _isLoading
                            ? const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    habis
                                        ? Icons.remove_shopping_cart_rounded
                                        : Icons.shopping_cart_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    habis
                                        ? 'Stok Habis'
                                        : 'Tambah Keranjang',
                                    style: GoogleFonts.alexandria(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                      ),
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

// ── Tombol + / − bulat ─────────────────────────────────────────
class _TombolBulat extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool disabled;
  const _TombolBulat({
    required this.icon,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: disabled
                ? [Colors.grey.shade400, Colors.grey.shade400]
                : const [
                    Color(0xFFD05122),
                    Color(0xFFEE8B2E),
                    Color(0xFFFBA839),
                  ],
            stops: disabled ? [0.0, 1.0] : [0.17, 0.47, 0.60],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              spreadRadius: 1,
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}