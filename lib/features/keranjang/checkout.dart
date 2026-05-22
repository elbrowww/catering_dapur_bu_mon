import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';
import 'package:catering_dapur_bu_mon/features/keranjang/keranjang-controller.dart';
import 'package:catering_dapur_bu_mon/main.dart';
import 'package:catering_dapur_bu_mon/services/dio_helper.dart';

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

  // ── SEMUA LOGIKA TIDAK DIUBAH ──────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadUserData();
    if (_ctrl.items.isEmpty) {
      _ctrl.loadKeranjang(showLoading: false);
    }
  }

  String _getFullImageUrl(String imageUrl) {
    if (imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http')) return imageUrl;
    return '${DioHelper.imageBaseUrl}$imageUrl';
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
          colorScheme: const ColorScheme.light(primary: Color(0xFFD05122)),
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
          colorScheme: const ColorScheme.light(primary: Color(0xFFD05122)),
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
        buktiBayar     : kIsWeb ? null : (_buktiBayar != null ? File(_buktiBayar!.path) : null),
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
        content: Text(msg, style: GoogleFonts.alexandria(color: Colors.white)),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessDialog() {
    final isPreorder = _adaItemPreorder;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isPreorder
                        ? [Colors.orange.shade700, Colors.orange.shade400]
                        : const [Color(0xFFD05122), Color(0xFFEE8B2E), Color(0xFFFBA839)],
                    stops: isPreorder ? [0.0, 1.0] : [0.17, 0.55, 0.85],
                  ),
                ),
                child: Icon(
                  isPreorder ? Icons.schedule_rounded : Icons.check_rounded,
                  color: Colors.white, size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isPreorder ? '⏰ Pre-order Masuk!' : '🎉 Pesanan Masuk!',
                style: GoogleFonts.alexandria(
                    fontSize: 22, fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1818)),
              ),
              const SizedBox(height: 6),
              Text(
                isPreorder
                    ? 'Pre-order Anda telah diterima\noleh Dapur Bu Mon 🍱'
                    : 'Terima kasih telah memesan\ndi Dapur Bu Mon 🍱',
                style: GoogleFonts.alexandria(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: isPreorder ? Colors.orange.shade700 : const Color(0xFFD05122)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isPreorder
                    ? 'Bu Mon akan mempersiapkan masakan Anda sesuai tanggal yang dipilih. Pantau status di halaman Aktivitas ya! 😊'
                    : 'Kami sudah menerima pesanan Anda dan sedang mempersiapkan hidangan terbaik. Pantau status pesanan di halaman Aktivitas ya! 😊',
                style: GoogleFonts.alexandria(
                    fontSize: 12, color: Colors.grey[600], height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                    (route) => false,
                  );
                },
                child: Container(
                  width: double.infinity, height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: isPreorder
                          ? [Colors.orange.shade700, Colors.orange.shade400]
                          : const [Color(0xFFD05122), Color(0xFFEE8B2E), Color(0xFFFBA839)],
                      stops: isPreorder ? [0.0, 1.0] : [0.17, 0.55, 0.85],
                    ),
                  ),
                  child: Center(
                    child: Text('Kembali ke Beranda',
                        style: GoogleFonts.alexandria(
                            color: Colors.white, fontSize: 15,
                            fontWeight: FontWeight.bold)),
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
  // ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final items = _ctrl.items;
    final total = _ctrl.total;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F4),
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Banner tipe pesanan (simpel) ──────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _adaItemPreorder
                        ? const Color(0xFFFFF3E0)
                        : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(children: [
                    Icon(
                      _adaItemPreorder
                          ? Icons.schedule_rounded
                          : Icons.check_circle_outline,
                      size: 16,
                      color: _adaItemPreorder
                          ? Colors.orange.shade700
                          : Colors.green.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _adaItemPreorder
                            ? 'Pesanan Pre-order — pilih tanggal minimal besok.'
                            : 'Pesanan Tersedia — bisa dipesan untuk hari ini.',
                        style: GoogleFonts.alexandria(
                          fontSize: 12,
                          color: _adaItemPreorder
                              ? Colors.orange.shade800
                              : Colors.green.shade800,
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 14),

                // ── Daftar Pesanan ────────────────────────────
                _SectionCard(
                  title: 'Daftar Pesanan',
                  child: Column(
                    children: items.asMap().entries.map((entry) {
                      final idx  = entry.key;
                      final item = entry.value;
                      final isItemPreorder = item['is_preorder'] == true;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            child: Row(children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 48, height: 48,
                                  color: const Color(0xFFF79F36),
                                  child: _buildMenuImage(
                                      item['imageUrl'] ?? ''),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['nama'],
                                        style: GoogleFonts.alexandria(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${_ctrl.formatRupiah(item['harga'])} × ${item['jumlah']}',
                                      style: GoogleFonts.alexandria(
                                          fontSize: 11,
                                          color: Colors.grey[500]),
                                    ),
                                    if (isItemPreorder) ...[
                                      const SizedBox(height: 4),
                                      Text('⏰ Pre-order',
                                          style: GoogleFonts.alexandria(
                                              fontSize: 10,
                                              color: Colors.orange.shade700,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ],
                                ),
                              ),
                              Text(
                                _ctrl.formatRupiah(
                                    item['harga'] * item['jumlah']),
                                style: GoogleFonts.alexandria(
                                    color: const Color(0xFFD05122),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                            ]),
                          ),
                          if (idx != items.length - 1)
                            Divider(
                                height: 0,
                                thickness: 0.5,
                                color: Colors.grey.shade200),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Informasi Pembeli ─────────────────────────
                _SectionCard(
                  title: 'Informasi Pembeli',
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                    child: Column(children: [
                      _SimpleField(
                          controller: _namaController,
                          label: 'Nama Pembeli',
                          hint: 'Nama lengkap'),
                      const SizedBox(height: 10),
                      _SimpleField(
                          controller: _alamatController,
                          label: 'Alamat',
                          hint: 'Alamat lengkap',
                          maxLines: 2),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Catatan ───────────────────────────────────
                _SectionCard(
                  title: 'Catatan (Opsional)',
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                    child: _SimpleField(
                        controller: _catatanController,
                        hint: 'Level pedas, request khusus, dll',
                        maxLines: 3),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Jadwal ────────────────────────────────────
                _SectionCard(
                  title: 'Jadwal',
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tipe pengiriman
                        Row(children: [
                          Expanded(
                            child: _TipeBtn(
                              label: 'Ambil Sendiri',
                              icon: Icons.store_rounded,
                              isSelected: _tipePengiriman == 'ambil',
                              onTap: () =>
                                  setState(() => _tipePengiriman = 'ambil'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _TipeBtn(
                              label: 'Diantar',
                              icon: Icons.delivery_dining_rounded,
                              isSelected: _tipePengiriman == 'antar',
                              onTap: () =>
                                  setState(() => _tipePengiriman = 'antar'),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 12),

                        // Pilih tanggal
                        GestureDetector(
                          onTap: _pilihTanggal,
                          child: _PickerRow(
                            icon: Icons.calendar_today_rounded,
                            isSelected: _tglAntar != null,
                            label: _tglAntar != null
                                ? '${_tglAntar!.day.toString().padLeft(2, '0')}/'
                                    '${_tglAntar!.month.toString().padLeft(2, '0')}/'
                                    '${_tglAntar!.year}'
                                    '${_isOrderHariIni ? ' · Hari ini' : ' · Pre-order'}'
                                : 'Pilih tanggal',
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Pilih jam
                        GestureDetector(
                          onTap: _pilihWaktu,
                          child: _PickerRow(
                            icon: Icons.access_time_rounded,
                            isSelected: _jamAntar != null,
                            label: _jamAntar != null
                                ? '${_jamAntar!.hour.toString().padLeft(2, '0')}:'
                                    '${_jamAntar!.minute.toString().padLeft(2, '0')}'
                                : 'Pilih jam',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Metode Pembayaran ─────────────────────────
                _SectionCard(
                  title: 'Pembayaran',
                  child: Column(
                    children: [
                      ..._metodeBayarList.map((metode) {
                        final isSelected = _selectedMetodeBayar == metode;
                        return Column(children: [
                          InkWell(
                            onTap: () => setState(() {
                              _selectedMetodeBayar = metode;
                              if (metode == 'Cash') {
                                _buktiBayar      = null;
                                _buktiBayarBytes = null;
                              }
                            }),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              child: Row(children: [
                                Icon(
                                  metode == 'Transfer Bank'
                                      ? Icons.account_balance_outlined
                                      : Icons.payments_outlined,
                                  size: 20,
                                  color: isSelected
                                      ? const Color(0xFFD05122)
                                      : Colors.grey.shade400,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(metode,
                                      style: GoogleFonts.alexandria(
                                          fontSize: 13,
                                          color: isSelected
                                              ? const Color(0xFF1A1818)
                                              : Colors.grey.shade500)),
                                ),
                                Container(
                                  width: 18, height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFD05122)
                                          : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Center(
                                          child: Container(
                                            width: 8, height: 8,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFFD05122),
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              ]),
                            ),
                          ),
                          if (metode != _metodeBayarList.last)
                            Divider(
                                height: 0,
                                thickness: 0.5,
                                color: Colors.grey.shade200),
                        ]);
                      }),

                      // Info rekening & upload bukti
                      if (_selectedMetodeBayar == 'Transfer Bank') ...[
                        Divider(
                            height: 0,
                            thickness: 0.5,
                            color: Colors.grey.shade200),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
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
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('Rekening Tujuan',
                                        style: GoogleFonts.alexandria(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                const Color(0xFFD05122))),
                                    const SizedBox(height: 8),
                                    _RekeningRow('Bank', _namaBank),
                                    _RekeningRow(
                                        'No. Rek', _noRekening),
                                    _RekeningRow(
                                        'Atas Nama', _namaRekening),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Upload bukti
                              Text('Bukti Transfer',
                                  style: GoogleFonts.alexandria(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: _pickBuktiBayar,
                                child: Container(
                                  width: double.infinity,
                                  height: _buktiBayar != null ? 160 : 90,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAF9F7),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _buktiBayar != null
                                          ? const Color(0xFFD05122)
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: _buktiBayar != null &&
                                          _buktiBayarBytes != null
                                      ? Stack(children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(7),
                                            child: Image.memory(
                                              _buktiBayarBytes!,
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: 8, right: 8,
                                            child: GestureDetector(
                                              onTap: _pickBuktiBayar,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                      0xFFD05122),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20),
                                                ),
                                                child: Text('Ganti',
                                                    style:
                                                        GoogleFonts.alexandria(
                                                            color: Colors
                                                                .white,
                                                            fontSize: 11)),
                                              ),
                                            ),
                                          ),
                                        ])
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.upload_file_outlined,
                                                color: Colors.grey.shade400,
                                                size: 28),
                                            const SizedBox(height: 6),
                                            Text(
                                                'Tap untuk upload bukti transfer',
                                                style:
                                                    GoogleFonts.alexandria(
                                                        fontSize: 12,
                                                        color: Colors
                                                            .grey.shade400)),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom Bar ──────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total',
                          style: GoogleFonts.alexandria(
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      Text(
                        _ctrl.formatRupiah(total),
                        style: GoogleFonts.alexandria(
                            color: const Color(0xFFD05122),
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _isLoading ? null : _prosesCheckout,
                    child: Container(
                      width: double.infinity, height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
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
                                width: 22, height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text('Pesan Sekarang',
                                style: GoogleFonts.alexandria(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity, height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
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
                                color: Colors.white,
                                fontSize: 15,
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
      return const Icon(Icons.fastfood, color: Colors.white, size: 22);
    }
    return Image.network(
      fullUrl,
      fit: BoxFit.cover,
      width: 48, height: 48,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: SizedBox(
            width: 18, height: 18,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.fastfood, color: Colors.white, size: 22),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Text(title,
                style: GoogleFonts.alexandria(
                    fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          Divider(height: 0, thickness: 0.5, color: Colors.grey.shade200),
          child,
        ],
      ),
    );
  }
}

class _SimpleField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final int maxLines;
  const _SimpleField({
    this.controller,
    this.label,
    this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!,
              style: GoogleFonts.alexandria(
                  fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 5),
        ],
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.alexandria(fontSize: 13, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.alexandria(
                color: Colors.grey.shade400, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color(0xFFD05122)),
            ),
          ),
        ),
      ],
    );
  }
}

class _TipeBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _TipeBtn({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD05122)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFD05122)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 15,
                color: isSelected
                    ? Colors.white
                    : Colors.grey.shade500),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.alexandria(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final String label;
  const _PickerRow({
    required this.icon,
    required this.isSelected,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected
              ? const Color(0xFFD05122)
              : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Icon(icon,
            size: 16,
            color: isSelected
                ? const Color(0xFFD05122)
                : Colors.grey.shade400),
        const SizedBox(width: 10),
        Text(label,
            style: GoogleFonts.alexandria(
                fontSize: 13,
                color: isSelected
                    ? Colors.black87
                    : Colors.grey.shade400)),
      ]),
    );
  }
}

class _RekeningRow extends StatelessWidget {
  final String label;
  final String value;
  const _RekeningRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        SizedBox(
          width: 72,
          child: Text(label,
              style: GoogleFonts.alexandria(
                  fontSize: 11, color: Colors.grey.shade600)),
        ),
        Text(': ',
            style: GoogleFonts.alexandria(
                fontSize: 11, color: Colors.grey.shade600)),
        Text(value,
            style: GoogleFonts.alexandria(
                fontSize: 11, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}