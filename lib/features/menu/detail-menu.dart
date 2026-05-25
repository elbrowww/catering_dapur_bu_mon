import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/models/menu_model.dart';
import 'package:catering_dapur_bu_mon/features/keranjang/keranjang-controller.dart';

// ============================================================
// DETAIL MENU PAGE
// ============================================================
class DetailMenuPage extends StatefulWidget {
  final MenuModel menu;

  const DetailMenuPage({
    super.key,
    required this.menu,
  });

  @override
  State<DetailMenuPage> createState() => _DetailMenuPageState();
}

class _DetailMenuPageState extends State<DetailMenuPage> {
  int _jumlah = 1;
  bool _isLoading = false;

  // ============================================================
  // TAMBAH JUMLAH
  // ============================================================
  void _tambah() {
    if (widget.menu.isHabis) {
      setState(() => _jumlah++);
    } else {
      if (_jumlah < widget.menu.stok) {
        setState(() => _jumlah++);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Stok hanya tersisa ${widget.menu.stok} untuk hari ini',
              style: GoogleFonts.alexandria(
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color(0xFFFFA726),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }
    }
  }

  // ============================================================
  // KURANG JUMLAH
  // ============================================================
  void _kurang() {
    setState(() {
      if (_jumlah > 1) {
        _jumlah--;
      }
    });
  }

  // ============================================================
  // TAMBAH KE KERANJANG
  // ============================================================
  Future<void> _tambahKeranjang() async {
    setState(() => _isLoading = true);

    try {
      final success = await KeranjangController.instance.tambah(
        nama: widget.menu.nama,
        harga: widget.menu.harga.toInt(),
        imageUrl: widget.menu.foto,
        jumlah: _jumlah,
        idMenu: widget.menu.idMenu,
        stok: widget.menu.stok,
      );

      if (mounted) {
        if (success) {
          final isPreorder = widget.menu.isHabis;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor:
                  isPreorder ? Colors.orange : Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              content: Row(
                children: [
                  Icon(
                    isPreorder
                        ? Icons.schedule_rounded
                        : Icons.check_circle,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isPreorder
                          ? '$_jumlah× ${widget.menu.nama} ditambahkan (Pre-order)'
                          : '$_jumlah× ${widget.menu.nama} ditambahkan ke keranjang',
                      style: GoogleFonts.alexandria(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Gagal menambahkan ke keranjang',
                style: GoogleFonts.alexandria(
                  color: Colors.white,
                ),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              '$_jumlah× ${widget.menu.nama} ditambahkan',
              style: GoogleFonts.alexandria(
                color: Colors.white,
              ),
            ),
          ),
        );

        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ============================================================
  // UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final bool isPreorder = widget.menu.isHabis;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      // ========================================================
      // BODY
      // ========================================================
      body: Stack(
        children: [
          // ====================================================
          // HEADER BACKGROUND
          // ====================================================
          Container(
            height: size.height * 0.38,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFEE8B2E),
                  Color(0xFFD05122),
                  Color(0xFFAC3715),
                ],
              ),
            ),
          ),

          // ====================================================
          // TEXTURE
          // ====================================================
          Positioned.fill(
            child: Opacity(
              opacity: 0.07,
              child: Image.network(
                'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMOKhEnss8buSiiHoow%2Fb772f011-4b7a-4be1-bd2b-4419616209dc.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ====================================================
          // CONTENT
          // ====================================================
          SafeArea(
            child: Column(
              children: [
                // =================================================
                // APPBAR
                // =================================================
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                            color: Color(0xFF1A1818),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // =================================================
                // BODY SCROLL
                // =================================================
                Expanded(
                  child: SingleChildScrollView(
                    physics:
                        const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      140,
                    ),
                    child: Column(
                      children: [
                        // ==========================================
                        // IMAGE
                        // ==========================================
                        Stack(
                          children: [
                            Center(
                              child: Container(
                                constraints:
                                    const BoxConstraints(
                                  maxWidth: 320,
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(
                                              30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withOpacity(0.18),
                                          blurRadius: 24,
                                          offset:
                                              const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(
                                              30),
                                      child: widget
                                              .menu.foto.isNotEmpty
                                          ? Image.network(
                                              widget
                                                  .menu.imageUrl,
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
                                                  ),
                                                );
                                              },
                                              errorBuilder:
                                                  (
                                                _,
                                                __,
                                                ___,
                                              ) {
                                                return Container(
                                                  color:
                                                      Colors.orange,
                                                  child:
                                                      const Icon(
                                                    Icons
                                                        .fastfood,
                                                    size: 90,
                                                    color: Colors
                                                        .white,
                                                  ),
                                                );
                                              },
                                            )
                                          : Container(
                                              color:
                                                  Colors.orange,
                                              child: const Icon(
                                                Icons.fastfood,
                                                size: 90,
                                                color:
                                                    Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // ======================================
                            // PREORDER BADGE
                            // ======================================
                            if (isPreorder)
                              Positioned(
                                top: 18,
                                right: 18,
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.orange.shade700,
                                    borderRadius:
                                        BorderRadius.circular(
                                            30),
                                  ),
                                  child: Row(
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons
                                            .schedule_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(
                                          width: 6),
                                      Text(
                                        'Pre-order',
                                        style:
                                            GoogleFonts
                                                .alexandria(
                                          color:
                                              Colors.white,
                                          fontSize: 12,
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

                        const SizedBox(height: 28),

                        // ==========================================
                        // CARD INFO
                        // ==========================================
                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.05),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              // ==============================
                              // NAMA MENU
                              // ==============================
                              Text(
                                widget.menu.nama,
                                style:
                                    GoogleFonts.alexandria(
                                  fontSize: 25,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      const Color(0xFF1A1818),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // ==============================
                              // HARGA + STOK
                              // ==============================
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                crossAxisAlignment:
                                    WrapCrossAlignment
                                        .center,
                                children: [
                                  Text(
                                    widget
                                        .menu.formattedHarga,
                                    style:
                                        GoogleFonts
                                            .alexandria(
                                      color:
                                          const Color(
                                              0xFFD76025),
                                      fontSize: 28,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  // ==========================
                                  // BADGE STOK
                                  // ==========================
                                  Container(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal: 14,
                                      vertical: 7,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                      color: Color(widget
                                          .menu
                                          .warnaStok),
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  30),
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
                                                  .inventory_2_rounded,
                                          color:
                                              Colors.white,
                                          size: 14,
                                        ),
                                        const SizedBox(
                                            width: 6),
                                        Text(
                                          isPreorder
                                              ? 'Pre-order'
                                              : widget.menu
                                                  .labelStok,
                                          style:
                                              GoogleFonts
                                                  .alexandria(
                                            color: Colors
                                                .white,
                                            fontSize: 12,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              // ==============================
                              // INFO
                              // ==============================
                              Text(
                                isPreorder
                                    ? '⏰ Pilih tanggal saat checkout'
                                    : 'Estimasi pembuatan ± 2 jam',
                                style:
                                    GoogleFonts.alexandria(
                                  fontSize: 13,
                                  color:
                                      Colors.grey.shade600,
                                ),
                              ),

                              // ==============================
                              // PREORDER INFO
                              // ==============================
                              if (isPreorder) ...[
                                const SizedBox(height: 18),

                                Container(
                                  width:
                                      double.infinity,
                                  padding:
                                      const EdgeInsets
                                          .all(14),
                                  decoration:
                                      BoxDecoration(
                                    color: Colors
                                        .orange.shade50,
                                    borderRadius:
                                        BorderRadius
                                            .circular(16),
                                    border: Border.all(
                                      color: Colors
                                          .orange
                                          .shade200,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Icon(
                                        Icons
                                            .info_outline,
                                        color: Colors
                                            .orange
                                            .shade700,
                                      ),
                                      const SizedBox(
                                          width: 10),
                                      Expanded(
                                        child: Text(
                                          'Menu ini tersedia lewat sistem pre-order dan akan dimasak khusus sesuai tanggal pilihan Anda.',
                                          style:
                                              GoogleFonts
                                                  .alexandria(
                                            fontSize: 12,
                                            height: 1.6,
                                            color: Colors
                                                .orange
                                                .shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 28),

                              // ==============================
                              // DESKRIPSI
                              // ==============================
                              Text(
                                'Deskripsi',
                                style:
                                    GoogleFonts.alexandria(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                widget.menu.deskripsi
                                        .isNotEmpty
                                    ? widget
                                        .menu.deskripsi
                                    : 'Menu spesial Dapur Bu Mon yang dimasak dengan bahan terbaik dan rempah pilihan.',
                                style:
                                    GoogleFonts.alexandria(
                                  fontSize: 14,
                                  height: 1.8,
                                  color:
                                      Colors.grey.shade700,
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

          // ====================================================
          // BOTTOM BAR
          // ====================================================
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  14,
                  18,
                  18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // ============================================
                    // MINUS
                    // ============================================
                    _TombolBulat(
                      icon: Icons.remove,
                      onTap: _kurang,
                      disabled: false,
                    ),

                    const SizedBox(width: 10),

                    // ============================================
                    // JUMLAH
                    // ============================================
                    Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F3F3),
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: Text(
                        '$_jumlah',
                        style:
                            GoogleFonts.alexandria(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // ============================================
                    // PLUS
                    // ============================================
                    _TombolBulat(
                      icon: Icons.add,
                      onTap: _tambah,
                      disabled: false,
                    ),

                    const SizedBox(width: 14),

                    // ============================================
                    // BUTTON
                    // ============================================
                    Expanded(
                      child: GestureDetector(
                        onTap: _isLoading
                            ? null
                            : _tambahKeranjang,
                        child: Container(
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(
                                    20),
                            gradient: LinearGradient(
                              colors: isPreorder
                                  ? [
                                      Colors.orange
                                          .shade600,
                                      Colors.orange
                                          .shade400,
                                    ]
                                  : const [
                                      Color(0xFFEE8B2E),
                                      Color(0xFFD05122),
                                    ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isPreorder
                                    ? Colors.orange
                                        .withOpacity(
                                            0.35)
                                    : const Color(
                                            0xFFD05122)
                                        .withOpacity(
                                            0.35),
                                blurRadius: 10,
                                offset:
                                    const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child:
                                        CircularProgressIndicator(
                                      color:
                                          Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Icon(
                                        isPreorder
                                            ? Icons
                                                .schedule_rounded
                                            : Icons
                                                .shopping_cart_outlined,
                                        color:
                                            Colors.white,
                                      ),
                                      const SizedBox(
                                          width: 8),
                                      Flexible(
                                        child: Text(
                                          isPreorder
                                              ? 'Pre-order'
                                              : 'Tambah Keranjang',
                                          overflow:
                                              TextOverflow
                                                  .ellipsis,
                                          style:
                                              GoogleFonts
                                                  .alexandria(
                                            color: Colors
                                                .white,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TOMBOL BULAT
// ============================================================
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
      onTap: disabled ? null : onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: disabled
              ? LinearGradient(
                  colors: [
                    Colors.grey.shade400,
                    Colors.grey.shade400,
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFD05122),
                    Color(0xFFEE8B2E),
                  ],
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}