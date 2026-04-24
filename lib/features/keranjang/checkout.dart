import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';
import 'package:catering_dapur_bu_mon/features/keranjang/keranjang-controller.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _ctrl = KeranjangController.instance;

  final _namaController    = TextEditingController();
  final _alamatController  = TextEditingController();
  final _catatanController = TextEditingController();

  String _selectedMetodeBayar = 'Transfer Bank';
  bool   _isLoading           = false;
  File?  _buktiBayar;

  // ── Dummy rekening (ganti nanti setelah mitra kirim data) ──────────────────
  static const _namaBank    = 'BCA';
  static const _noRekening  = '1234567890';
  static const _namaRekening = 'Dapur Bu Mon';
  // ──────────────────────────────────────────────────────────────────────────

  final List<String> _metodeBayarList = [
    'Transfer Bank',
    'Cash',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Isi dari session manager Anda bila sudah ada
  }

  // ── Upload bukti dari galeri ───────────────────────────────────────────────
  Future<void> _pickBuktiBayar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _buktiBayar = File(picked.path));
    }
  }

  // ── Proses checkout ────────────────────────────────────────────────────────
  Future<void> _prosesCheckout() async {
    if (_namaController.text.isEmpty) {
      _showSnack('Nama pembeli wajib diisi');
      return;
    }
    if (_alamatController.text.isEmpty) {
      _showSnack('Alamat pengiriman wajib diisi');
      return;
    }
    if (_selectedMetodeBayar == 'Transfer Bank' && _buktiBayar == null) {
      _showSnack('Harap upload bukti transfer terlebih dahulu');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.checkout(
        metodeBayar: _selectedMetodeBayar,
        catatan: _catatanController.text,
        // Kirim file bukti bila ada — sesuaikan parameter di ApiService Anda
        // buktiBayar: _buktiBayar,
      );

      if (mounted) {
        if (response['status'] == 'success') {
          await _ctrl.kosongkan();
          _showSuccessDialog();
        } else {
          _showSnack('Checkout gagal: ${response['message'] ?? 'Coba lagi'}',
              isError: true);
        }
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Helper snackbar ────────────────────────────────────────────────────────
  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.alexandria(color: Colors.white)),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // ── Dialog sukses ──────────────────────────────────────────────────────────
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 12),
            Text('Pesanan Berhasil!',
                style: GoogleFonts.alexandria(
                    fontWeight: FontWeight.bold, fontSize: 20)),
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
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD05122),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Kembali ke Menu',
                style: GoogleFonts.alexandria(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final items = _ctrl.items;
    final total = _ctrl.total;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Checkout',
            style: GoogleFonts.alexandria(
                color: Colors.white, fontWeight: FontWeight.w600)),
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
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 220),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Daftar Pesanan ───────────────────────────────────────────
                _buildCard(
                  title: 'Daftar Pesanan',
                  child: Column(
                    children: items.asMap().entries.map((entry) {
                      final idx  = entry.key;
                      final item = entry.value;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 50, height: 50,
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['nama'],
                                          style: GoogleFonts.alexandria(
                                              fontSize: 14)),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_ctrl.formatRupiah(item['harga'])} x ${item['jumlah']}',
                                        style: GoogleFonts.alexandria(
                                            fontSize: 12,
                                            color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
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
                  ),
                ),

                const SizedBox(height: 16),

                // ── Informasi Pembeli ────────────────────────────────────────
                _buildCard(
                  title: 'Informasi Pembeli',
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _namaController,
                          label: 'Nama Pembeli',
                          hint: 'Masukkan nama lengkap',
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _alamatController,
                          label: 'Alamat Pengiriman',
                          hint: 'Masukkan alamat lengkap',
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Catatan ──────────────────────────────────────────────────
                _buildCard(
                  title: 'Catatan (Opsional)',
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _buildTextField(
                      controller: _catatanController,
                      hint: 'Contoh: Level pedas, request khusus, dll',
                      maxLines: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Metode Pembayaran ────────────────────────────────────────
                _buildCard(
                  title: 'Metode Pembayaran',
                  child: Column(
                    children: [
                      // Radio buttons
                      ..._metodeBayarList.map((metode) {
                        return Column(
                          children: [
                            RadioListTile<String>(
                              title: Row(
                                children: [
                                  Icon(
                                    metode == 'Transfer Bank'
                                        ? Icons.account_balance
                                        : Icons.payments_outlined,
                                    color: _selectedMetodeBayar == metode
                                        ? const Color(0xFFD05122)
                                        : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(metode,
                                      style: GoogleFonts.alexandria()),
                                ],
                              ),
                              value: metode,
                              groupValue: _selectedMetodeBayar,
                              activeColor: const Color(0xFFD05122),
                              onChanged: (value) {
                                setState(() {
                                  _selectedMetodeBayar = value!;
                                  // Reset bukti kalau ganti ke Cash
                                  if (value == 'Cash') _buktiBayar = null;
                                });
                              },
                            ),
                            if (metode != _metodeBayarList.last)
                              const Divider(height: 0, thickness: 0.5),
                          ],
                        );
                      }),

                      // ── Info Rekening + Upload (hanya Transfer Bank) ──────
                      if (_selectedMetodeBayar == 'Transfer Bank') ...[
                        const Divider(height: 0, thickness: 1),
                        _buildTransferSection(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom Bar ───────────────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
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
                                fontWeight: FontWeight.bold)),
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
                            Color(0xFFFBA839),
                          ],
                          stops: [0.17, 0.47, 0.60],
                        ),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 24, height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : Text('Pesan Sekarang',
                                style: GoogleFonts.alexandria(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
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
                            Color(0xFFAC3715),
                          ],
                          stops: [0.17, 0.43, 0.61],
                        ),
                      ),
                      child: Center(
                        child: Text('Kembali ke Keranjang',
                            style: GoogleFonts.alexandria(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
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

  // ── Widget: Info Rekening + Upload Bukti ───────────────────────────────────
  Widget _buildTransferSection() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info rekening
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3ED),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD05122), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance,
                        color: Color(0xFFD05122), size: 18),
                    const SizedBox(width: 6),
                    Text('Informasi Rekening',
                        style: GoogleFonts.alexandria(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD05122),
                        )),
                  ],
                ),
                const SizedBox(height: 8),
                _buildRekeningRow('Bank', _namaBank),
                const SizedBox(height: 4),
                _buildRekeningRow('No. Rekening', _noRekening),
                const SizedBox(height: 4),
                _buildRekeningRow('Atas Nama', _namaRekening),
                const SizedBox(height: 8),
                Text(
                  '* Harap transfer sesuai total tagihan dan upload bukti transfer di bawah.',
                  style: GoogleFonts.alexandria(
                      fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Upload bukti
          Text('Bukti Transfer',
              style: GoogleFonts.alexandria(
                  fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),

          GestureDetector(
            onTap: _pickBuktiBayar,
            child: Container(
              width: double.infinity,
              height: _buktiBayar != null ? 180 : 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3ED),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _buktiBayar != null
                      ? const Color(0xFFD05122)
                      : Colors.grey.shade300,
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: _buktiBayar != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.file(
                            _buktiBayar!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Tombol ganti foto
                        Positioned(
                          top: 8, right: 8,
                          child: GestureDetector(
                            onTap: _pickBuktiBayar,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD05122),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.edit,
                                      color: Colors.white, size: 13),
                                  const SizedBox(width: 4),
                                  Text('Ganti',
                                      style: GoogleFonts.alexandria(
                                          color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.upload_file,
                            color: Color(0xFFD05122), size: 32),
                        const SizedBox(height: 6),
                        Text('Tap untuk upload bukti transfer',
                            style: GoogleFonts.alexandria(
                                fontSize: 13,
                                color: const Color(0xFFD05122))),
                        const SizedBox(height: 2),
                        Text('Format: JPG, PNG',
                            style: GoogleFonts.alexandria(
                                fontSize: 11, color: Colors.grey)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper row info rekening ───────────────────────────────────────────────
  Widget _buildRekeningRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label,
              style: GoogleFonts.alexandria(
                  fontSize: 12, color: Colors.grey[700])),
        ),
        Text(': ',
            style: GoogleFonts.alexandria(
                fontSize: 12, color: Colors.grey[700])),
        Text(value,
            style: GoogleFonts.alexandria(
                fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ── Helper card wrapper ────────────────────────────────────────────────────
  Widget _buildCard({required String title, required Widget child}) {
    return Container(
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
            child: Text(title,
                style: GoogleFonts.alexandria(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 0, thickness: 1),
          child,
        ],
      ),
    );
  }

  // ── Helper TextField ───────────────────────────────────────────────────────
  Widget _buildTextField({
    TextEditingController? controller,
    String? label,
    String? hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.alexandria(),
        hintText: hint,
        hintStyle: GoogleFonts.alexandria(color: Colors.grey[400]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD05122)),
        ),
      ),
    );
  }
}