import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';
import 'package:catering_dapur_bu_mon/features/keranjang/keranjang-controller.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _ctrl = KeranjangController.instance;
  
  // Form controllers
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _catatanController = TextEditingController();
  
  String _selectedMetodeBayar = 'Transfer Bank';
  bool _isLoading = false;
  
  final List<String> _metodeBayarList = [
    'Transfer Bank',
    'QRIS',
    'COD (Bayar di Tempat)',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    // Load user data dari session
    // Implementasi sesuai session manager Anda
    // Contoh:
    // final user = await SessionManager.getUser();
    // if (user != null) {
    //   setState(() {
    //     _namaController.text = user['nama'] ?? '';
    //     _alamatController.text = user['alamat'] ?? '';
    //   });
    // }
  }

  Future<void> _prosesCheckout() async {
    if (_namaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nama pembeli wajib diisi',
              style: GoogleFonts.alexandria(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_alamatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alamat pengiriman wajib diisi',
              style: GoogleFonts.alexandria(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Panggil API checkout
      final response = await ApiService.checkout(
        metodeBayar: _selectedMetodeBayar,
        catatan: _catatanController.text,
      );
      
      if (mounted) {
        if (response['status'] == 'success') {
          // Kosongkan keranjang setelah sukses
          await _ctrl.kosongkan();
          
          // Tampilkan dialog sukses
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Column(
                children: [
                  const Icon(Icons.check_circle, 
                      color: Colors.green, size: 60),
                  const SizedBox(height: 12),
                  Text('Pesanan Berhasil!',
                      style: GoogleFonts.alexandria(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      )),
                ],
              ),
              content: Text(
                'Pesanan Anda telah diterima. Silakan cek halaman aktivitas untuk melihat status pesanan.',
                style: GoogleFonts.alexandria(),
                textAlign: TextAlign.center,
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup dialog
                    Navigator.pop(context); // Kembali ke keranjang
                    Navigator.pop(context); // Kembali ke menu
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD05122),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Kembali ke Menu',
                      style: GoogleFonts.alexandria(color: Colors.white)),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Checkout gagal: ${response['message'] ?? 'Coba lagi'}',
                  style: GoogleFonts.alexandria(color: Colors.white)),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e',
                style: GoogleFonts.alexandria(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _ctrl.items;
    final total = _ctrl.total;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Checkout',
            style: GoogleFonts.alexandria(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            )),
        backgroundColor: const Color(0xFFD05122),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================================================
                // SECTION: DAFTAR PESANAN
                // ============================================================
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3F000000),
                        spreadRadius: 3,
                        offset: Offset(0, 1.7),
                        blurRadius: 3,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text('Daftar Pesanan',
                            style: GoogleFonts.alexandria(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      const Divider(height: 0, thickness: 1),
                      ...items.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Gambar
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF79F36),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image.network(
                                        item['imageUrl'] ?? '',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.fastfood,
                                                color: Colors.white, size: 24),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item['nama'],
                                            style: GoogleFonts.alexandria(
                                                fontSize: 14)),
                                        const SizedBox(height: 4),
                                        Text(
                                            '${_ctrl.formatRupiah(item['harga'])} x ${item['jumlah']}',
                                            style: GoogleFonts.alexandria(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            )),
                                      ],
                                    ),
                                  ),
                                  // Subtotal
                                  Text(
                                    _ctrl.formatRupiah(
                                        item['harga'] * item['jumlah']),
                                    style: GoogleFonts.alexandria(
                                      color: const Color(0xFFDC6727),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (idx != items.length - 1) 
                                const Divider(height: 0, thickness: 0.5),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ============================================================
                // SECTION: NAMA PEMBELI & ALAMAT
                // ============================================================
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3F000000),
                        spreadRadius: 3,
                        offset: Offset(0, 1.7),
                        blurRadius: 3,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text('Informasi Pembeli',
                            style: GoogleFonts.alexandria(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      const Divider(height: 0, thickness: 1),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            TextField(
                              controller: _namaController,
                              decoration: InputDecoration(
                                labelText: 'Nama Pembeli',
                                labelStyle: GoogleFonts.alexandria(),
                                hintText: 'Masukkan nama lengkap',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFD05122)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _alamatController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                labelText: 'Alamat Pengiriman',
                                labelStyle: GoogleFonts.alexandria(),
                                hintText: 'Masukkan alamat lengkap',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFD05122)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ============================================================
                // SECTION: CATATAN (OPSIONAL)
                // ============================================================
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3F000000),
                        spreadRadius: 3,
                        offset: Offset(0, 1.7),
                        blurRadius: 3,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text('Catatan (Opsional)',
                            style: GoogleFonts.alexandria(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      const Divider(height: 0, thickness: 1),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          controller: _catatanController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Contoh: Level pedas, request khusus, dll',
                            hintStyle: GoogleFonts.alexandria(
                                color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: Color(0xFFD05122)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ============================================================
                // SECTION: METODE PEMBAYARAN
                // ============================================================
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3F000000),
                        spreadRadius: 3,
                        offset: Offset(0, 1.7),
                        blurRadius: 3,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text('Metode Pembayaran',
                            style: GoogleFonts.alexandria(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      const Divider(height: 0, thickness: 1),
                      ..._metodeBayarList.map((metode) {
                        return Column(
                          children: [
                            RadioListTile<String>(
                              title: Text(metode,
                                  style: GoogleFonts.alexandria()),
                              value: metode,
                              groupValue: _selectedMetodeBayar,
                              activeColor: const Color(0xFFD05122),
                              onChanged: (value) {
                                setState(() {
                                  _selectedMetodeBayar = value!;
                                });
                              },
                            ),
                            if (metode != _metodeBayarList.last)
                                const Divider(height: 0, thickness: 0.5),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // BOTTOM BAR: TOTAL + TOMBOL PESAN SEKARANG
          // ============================================================
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
              child: Column(
                children: [
                  // Total
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total',
                            style: GoogleFonts.alexandria(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                        Text(_ctrl.formatRupiah(total),
                            style: GoogleFonts.alexandria(
                              color: const Color(0xFFDC6727),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tombol Pesan Sekarang
                  GestureDetector(
                    onTap: _isLoading ? null : _prosesCheckout,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x3F000000),
                            spreadRadius: 0,
                            offset: Offset(0, 4),
                            blurRadius: 4,
                          )
                        ],
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFD05122),
                            Color(0xFFEE8B2E),
                            Color(0xFFFBA839)
                          ],
                          stops: [0.17, 0.47, 0.60],
                        ),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Pesan Sekarang',
                                style: GoogleFonts.alexandria(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tombol Kembali
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      height: 43,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x3F000000),
                            spreadRadius: 0,
                            offset: Offset(0, 4),
                            blurRadius: 4,
                          )
                        ],
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFAC3715),
                            Color(0xFFD05122),
                            Color(0xFFAC3715)
                          ],
                          stops: [0.17, 0.43, 0.61],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Kembali ke Keranjang',
                          style: GoogleFonts.alexandria(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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