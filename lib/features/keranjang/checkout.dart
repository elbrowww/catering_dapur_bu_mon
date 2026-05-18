import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';
import 'package:catering_dapur_bu_mon/features/keranjang/keranjang-controller.dart';
import 'package:catering_dapur_bu_mon/main.dart';
import 'package:catering_dapur_bu_mon/services/config.dart';

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

  String     _selectedMetodeBayar = 'Transfer Bank';
  String     _tipePengiriman      = 'ambil';
  DateTime?  _tglAntar;
  TimeOfDay? _jamAntar;
  bool       _isLoading           = false;

  XFile?     _buktiBayar;
  Uint8List? _buktiBayarBytes;

  static const _namaBank     = 'BCA';
  static const _noRekening   = '1234567890';
  static const _namaRekening = 'Dapur Bu Mon';

  final List<String> _metodeBayarList = ['Transfer Bank', 'Cash'];

  bool get _isOrderHariIni {
    if (_tglAntar == null) return false;
    final today = DateTime.now();
    return _tglAntar!.year == today.year &&
        _tglAntar!.month == today.month &&
        _tglAntar!.day == today.day;
  }

  bool get _adaItemPreorder => _ctrl.kartTipe == 'preorder';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // FIX: Hapus _ctrl.loadKeranjang() dari sini.
    // Data keranjang sudah dimuat oleh KeranjangPage sebelumnya.
    // Memanggil loadKeranjang() di sini menyebabkan _isLoading = true
    // pada singleton, sehingga KeranjangPage stuck loading saat user kembali.
    // Hanya muat ulang jika keranjang benar-benar kosong (fallback).
    if (_ctrl.items.isEmpty) {
      _ctrl.loadKeranjang(showLoading: false);
    }
  }

  String _getFullImageUrl(String imageUrl) {
    if (imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http')) return imageUrl;
    return '${AppConfig.imageBaseUrl}$imageUrl';
  }

  Future<void> _loadUserData() async {
    try {
      final profil = await ApiService.getProfil();
      if (mounted) {
        _namaController.text   = profil['nama']   ?? '';
        _alamatController.text = profil['alamat'] ?? '';
      }
    } catch (_) {}
  }

  Future<void> _pickBuktiBayar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _buktiBayar      = picked;
        _buktiBayarBytes = bytes;
      });
    }
  }

  Future<void> _pilihTanggal() async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final firstDate = _adaItemPreorder
        ? todayDate.add(const Duration(days: 1))
        : todayDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: today.add(const Duration(days: 60)),
      helpText: _adaItemPreorder
          ? 'Pilih tanggal pre-order (min. besok)'
          : 'Pilih tanggal pesanan',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              const ColorScheme.light(primary: Color(0xFFD05122)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tglAntar = picked);
  }

  Future<void> _pilihWaktu() async {
    final now = TimeOfDay.now();

    final initialTime = _isOrderHariIni
        ? TimeOfDay(hour: now.hour, minute: now.minute)
        : const TimeOfDay(hour: 10, minute: 0);

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              const ColorScheme.light(primary: Color(0xFFD05122)),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      if (_isOrderHariIni) {
        final nowMinutes  = now.hour * 60 + now.minute;
        final pickMinutes = picked.hour * 60 + picked.minute;
        if (pickMinutes <= nowMinutes) {
          if (mounted) {
            _showSnack(
              'Jam tidak valid. Pilih jam setelah '
              '${now.hour.toString().padLeft(2, '0')}:'
              '${now.minute.toString().padLeft(2, '0')}',
              isError: true,
            );
          }
          return;
        }
      }
      setState(() => _jamAntar = picked);
    }
  }

  Future<void> _prosesCheckout() async {
    final nama   = _namaController.text.trim();
    final alamat = _alamatController.text.trim();

    if (nama.isEmpty)   { _showSnack('Nama pembeli wajib diisi'); return; }
    if (alamat.isEmpty) { _showSnack('Alamat wajib diisi'); return; }
    if (_selectedMetodeBayar == 'Transfer Bank' && _buktiBayar == null) {
      _showSnack('Harap upload bukti transfer terlebih dahulu');
      return;
    }
    if (_ctrl.items.isEmpty) { _showSnack('Keranjang kosong'); return; }
    if (_tglAntar == null) {
      _showSnack('Pilih tanggal pengiriman/pengambilan');
      return;
    }
    if (_jamAntar == null) {
      _showSnack('Pilih jam pengiriman/pengambilan');
      return;
    }

    if (_adaItemPreorder && _isOrderHariIni) {
      _showSnack('Semua menu adalah pre-order. Pilih tanggal minimal besok.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tglStr =
          '${_tglAntar!.year}-'
          '${_tglAntar!.month.toString().padLeft(2, '0')}-'
          '${_tglAntar!.day.toString().padLeft(2, '0')}';
      final jamStr =
          '${_jamAntar!.hour.toString().padLeft(2, '0')}:'
          '${_jamAntar!.minute.toString().padLeft(2, '0')}:00';

      final response = await ApiService.checkout(
        namaPembeli    : nama,
        alamat         : alamat,
        metodeBayar    : _selectedMetodeBayar,
        catatan        : _catatanController.text.trim(),
        tglAntar       : tglStr,
        jamAntar       : jamStr,
        tipePengiriman : _tipePengiriman,
        buktiBayar     : kIsWeb
            ? null
            : (_buktiBayar != null ? File(_buktiBayar!.path) : null),
        buktiBayarBytes: _buktiBayarBytes,
        buktiBayarName : _buktiBayar?.name,
      );

      if (mounted) {
        if (response['status'] == 'success') {
          await _ctrl.kosongkan();
          _showSuccessDialog();
        } else {
          _showSnack(
            'Checkout gagal: ${response['message'] ?? response['error'] ?? 'Coba lagi'}',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(msg, style: GoogleFonts.alexandria(color: Colors.white)),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessDialog() {
    final isPreorder = _adaItemPreorder;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isPreorder
                        ? [Colors.orange.shade700, Colors.orange.shade400]
                        : const [
                            Color(0xFFD05122),
                            Color(0xFFEE8B2E),
                            Color(0xFFFBA839),
                          ],
                    stops: isPreorder ? [0.0, 1.0] : [0.17, 0.55, 0.85],
                  ),
                ),
                child: Icon(
                  isPreorder
                      ? Icons.schedule_rounded
                      : Icons.check_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isPreorder ? '⏰ Pre-order Masuk!' : '🎉 Pesanan Masuk!',
                style: GoogleFonts.alexandria(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1818)),
              ),
              const SizedBox(height: 6),
              Text(
                isPreorder
                    ? 'Pre-order Anda telah diterima\noleh Dapur Bu Mon 🍱'
                    : 'Terima kasih telah memesan\ndi Dapur Bu Mon 🍱',
                style: GoogleFonts.alexandria(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isPreorder
                        ? Colors.orange.shade700
                        : const Color(0xFFD05122)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isPreorder
                    ? 'Bu Mon akan mempersiapkan masakan Anda sesuai tanggal yang dipilih. Pantau status di halaman Aktivitas ya! 😊'
                    : 'Kami sudah menerima pesanan Anda dan sedang mempersiapkan hidangan terbaik. Pantau status pesanan di halaman Aktivitas ya! 😊',
                style: GoogleFonts.alexandria(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MainScreen()),
                    (route) => false,
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: isPreorder
                          ? [
                              Colors.orange.shade700,
                              Colors.orange.shade400,
                            ]
                          : const [
                              Color(0xFFD05122),
                              Color(0xFFEE8B2E),
                              Color(0xFFFBA839),
                            ],
                      stops: isPreorder ? [0.0, 1.0] : [0.17, 0.55, 0.85],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Kembali ke Beranda',
                      style: GoogleFonts.alexandria(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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

                // Banner info tipe pesanan
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _adaItemPreorder
                        ? Colors.orange.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _adaItemPreorder
                          ? Colors.orange.shade300
                          : Colors.green.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _adaItemPreorder
                            ? Icons.schedule_rounded
                            : Icons.check_circle_outline,
                        color: _adaItemPreorder
                            ? Colors.orange.shade700
                            : Colors.green.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _adaItemPreorder
                              ? 'Pesanan Pre-order — pilih tanggal minimal besok.'
                              : 'Pesanan Tersedia — bisa dipesan untuk hari ini.',
                          style: GoogleFonts.alexandria(
                            color: _adaItemPreorder
                                ? Colors.orange.shade800
                                : Colors.green.shade800,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Daftar Pesanan ──────────────────────────────
                _buildCard(
                  title: 'Daftar Pesanan',
                  child: Column(
                    children: items.asMap().entries.map((entry) {
                      final idx  = entry.key;
                      final item = entry.value;
                      final isItemPreorder =
                          item['is_preorder'] == true;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF79F36),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: _buildMenuImage(
                                        item['imageUrl'] ?? ''),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item['nama'],
                                          style: GoogleFonts.alexandria(
                                              fontSize: 14)),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${_ctrl.formatRupiah(item['harga'])} x ${item['jumlah']}',
                                        style: GoogleFonts.alexandria(
                                            fontSize: 12,
                                            color: Colors.grey[600]),
                                      ),
                                      if (isItemPreorder) ...[
                                        const SizedBox(height: 3),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade100,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '⏰ Pre-order',
                                            style: GoogleFonts.alexandria(
                                              color:
                                                  Colors.orange.shade700,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
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

                // ── Informasi Pembeli ───────────────────────────
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

                // ── Catatan ─────────────────────────────────────
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

                // ── Jadwal ──────────────────────────────────────
                _buildCard(
                  title: 'Jadwal Pengiriman / Pengambilan',
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: _adaItemPreorder
                                ? Colors.orange.shade50
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _adaItemPreorder
                                ? '⏰ Pre-order → pilih tanggal minimal besok'
                                : '📅 Pesan hari ini atau jadwalkan untuk hari lain',
                            style: GoogleFonts.alexandria(
                              fontSize: 11,
                              color: _adaItemPreorder
                                  ? Colors.orange.shade700
                                  : Colors.blue.shade700,
                            ),
                          ),
                        ),

                        Row(
                          children: [
                            Expanded(
                              child: _buildTipeBtn('ambil', 'Ambil Sendiri',
                                  Icons.store_rounded),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTipeBtn('antar', 'Diantar',
                                  Icons.delivery_dining_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        GestureDetector(
                          onTap: _pilihTanggal,
                          child: _buildPickerRow(
                            icon: Icons.calendar_today_rounded,
                            isSelected: _tglAntar != null,
                            label: _tglAntar != null
                                ? '${_tglAntar!.day.toString().padLeft(2, '0')}/'
                                    '${_tglAntar!.month.toString().padLeft(2, '0')}/'
                                    '${_tglAntar!.year}'
                                    '${_isOrderHariIni ? ' (Hari ini)' : ' (Pre-order)'}'
                                : 'Pilih tanggal ${_tipePengiriman == 'antar' ? 'pengiriman' : 'pengambilan'}',
                          ),
                        ),
                        const SizedBox(height: 10),

                        GestureDetector(
                          onTap: _pilihWaktu,
                          child: _buildPickerRow(
                            icon: Icons.access_time_rounded,
                            isSelected: _jamAntar != null,
                            label: _jamAntar != null
                                ? '${_jamAntar!.hour.toString().padLeft(2, '0')}:'
                                    '${_jamAntar!.minute.toString().padLeft(2, '0')}'
                                : 'Pilih jam ${_tipePengiriman == 'antar' ? 'pengiriman' : 'pengambilan'}',
                          ),
                        ),

                        if (_tglAntar != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: _isOrderHariIni
                                  ? Colors.green.shade50
                                  : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _isOrderHariIni
                                    ? Colors.green.shade200
                                    : Colors.orange.shade200,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isOrderHariIni
                                      ? Icons.check_circle_outline
                                      : Icons.schedule_rounded,
                                  size: 14,
                                  color: _isOrderHariIni
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isOrderHariIni
                                      ? 'Pesanan hari ini'
                                      : 'Pre-order',
                                  style: GoogleFonts.alexandria(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _isOrderHariIni
                                        ? Colors.green.shade700
                                        : Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Metode Pembayaran ───────────────────────────
                _buildCard(
                  title: 'Metode Pembayaran',
                  child: Column(
                    children: [
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
                                  if (value == 'Cash') {
                                    _buktiBayar      = null;
                                    _buktiBayarBytes = null;
                                  }
                                });
                              },
                            ),
                            if (metode != _metodeBayarList.last)
                              const Divider(height: 0, thickness: 0.5),
                          ],
                        );
                      }),
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

          // ── Bottom Bar ─────────────────────────────────────────
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
                        Text(
                          _ctrl.formatRupiah(total),
                          style: GoogleFonts.alexandria(
                            color: const Color(0xFFDC6727),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _isLoading ? null : _prosesCheckout,
                    child: Container(
                      width: double.infinity,
                      height: 50,
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
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
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
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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

  Widget _buildMenuImage(String imageUrl) {
    final fullUrl = _getFullImageUrl(imageUrl);
    if (fullUrl.isEmpty) {
      return const Icon(Icons.fastfood, color: Colors.white, size: 24);
    }
    return Image.network(
      fullUrl,
      fit: BoxFit.cover,
      width: 50,
      height: 50,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.fastfood, color: Colors.white, size: 24),
    );
  }

  Widget _buildTipeBtn(String tipe, String label, IconData icon) {
    final isSelected = _tipePengiriman == tipe;
    return GestureDetector(
      onTap: () => setState(() => _tipePengiriman = tipe),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD05122) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD05122)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color:
                    isSelected ? Colors.white : const Color(0xFFD05122)),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.alexandria(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFFD05122))),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerRow({
    required IconData icon,
    required bool isSelected,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        border: Border.all(
            color: isSelected
                ? const Color(0xFFD05122)
                : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color: isSelected ? const Color(0xFFD05122) : Colors.grey),
          const SizedBox(width: 10),
          Text(label,
              style: GoogleFonts.alexandria(
                  fontSize: 13,
                  color:
                      isSelected ? Colors.black87 : Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildTransferSection() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3ED),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD05122)),
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
                            color: const Color(0xFFD05122))),
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
                ),
              ),
              child: _buktiBayar != null && _buktiBayarBytes != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.memory(
                            _buktiBayarBytes!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
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
                                          color: Colors.white,
                                          fontSize: 12)),
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
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD05122)),
        ),
      ),
    );
  }
}