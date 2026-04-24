import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/admin/shared/header_admin.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const _gradientColors = [Color(0xFFD05122), Color(0xFFEE8B2E), Color(0xFFFBA839)];
const _gradientStops  = [0.18, 0.61, 0.85];
const _borderOrange   = Color(0xFFDB6626);
const _shadowColor    = Color(0x3F000000);

const _listShadow = [
  BoxShadow(color: _shadowColor, spreadRadius: 3, offset: Offset(0, 1.7), blurRadius: 3),
];

const _dummyImageUrl =
    'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SONxcLGhX9Sc4jqH3qj%2Fb611dcd57e8a8124c09e46eb95298a801a223e17image%203.png?alt=media&token=274a3b20-6268-4ae8-80a1-410fb38711f3';

// ── Kelola Menu Page ──────────────────────────────────────────────────────────

class KelolaMenuPage extends StatefulWidget {
  const KelolaMenuPage({super.key});

  @override
  State<KelolaMenuPage> createState() => _KelolaMenuPageState();
}

class _KelolaMenuPageState extends State<KelolaMenuPage> {
  int    _selectedFilter = 0;
  bool   _isLoading      = true;
  String _errorMsg       = '';

  // ── PERUBAHAN: kategori dinamis dari DB (tidak hardcode) ──────────────────
  List<String> _kategoriList = ['Semua'];

  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _menuList = [];

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Load semua menu dari API ───────────────────────────────────────────────
  Future<void> _loadMenu() async {
    setState(() { _isLoading = true; _errorMsg = ''; });
    try {
      final data = await ApiService.getMenu();

      // ── PERUBAHAN: generate kategori unik dari data DB ────────────────────
      final kategoriSet = <String>{};
      for (var item in data) {
        final kat = (item['kategori'] ?? '').toString().trim();
        if (kat.isNotEmpty) kategoriSet.add(kat);
      }

      setState(() {
        _menuList      = data.map((e) => Map<String, dynamic>.from(e)).toList();
        _kategoriList  = ['Semua', ...kategoriSet.toList()];
        _isLoading     = false;
      });
    } catch (e) {
      setState(() { _errorMsg = e.toString(); _isLoading = false; });
    }
  }

  // ── PERUBAHAN: filter pakai perbandingan langsung seperti customer ─────────
  List<Map<String, dynamic>> get _filteredList {
    return _menuList.where((item) {
      final nama     = (item['nama'] ?? '').toString().toLowerCase();
      final query    = _searchController.text.toLowerCase();
      final kategori = (item['kategori'] ?? '').toString().trim();

      final matchSearch   = query.isEmpty || nama.contains(query);
      final matchKategori = _selectedFilter == 0 ||
          kategori == _kategoriList[_selectedFilter];

      return matchSearch && matchKategori;
    }).toList();
  }

  // ── Tambah Menu ────────────────────────────────────────────────────────────
  void _showTambahMenu() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const TambahMenuDialog(),
    );
    if (result == null) return;

    setState(() => _isLoading = true);
    try {
      await ApiService.tambahMenu(
        nama      : result['nama'],
        deskripsi : result['deskripsi'],
        harga     : double.tryParse(result['harga'].toString()) ?? 0,
        foto      : _dummyImageUrl,
        kategori  : result['jenis'] ?? '',
      );
      _showSnack('Menu berhasil ditambahkan', isError: false);
      await _loadMenu();
    } catch (e) {
      _showSnack('Gagal tambah menu: $e');
      setState(() => _isLoading = false);
    }
  }

  // ── Edit Menu ──────────────────────────────────────────────────────────────
  void _showEditMenu(Map<String, dynamic> item) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => EditMenuDialog(
        namaMenu  : item['nama']      ?? '',
        harga     : item['harga'].toString(),
        jenis     : item['kategori']  ?? 'Paket Nasi',
        deskripsi : item['deskripsi'] ?? '',
      ),
    );
    if (result == null) return;

    setState(() => _isLoading = true);
    try {
      await ApiService.editMenu(
        item['id_menu'] as int,
        {
          'nama'      : result['nama'],
          'deskripsi' : result['deskripsi'],
          'harga'     : double.tryParse(result['harga'].toString()) ?? 0,
          'kategori'  : result['jenis'],
          'foto'      : item['foto'] ?? _dummyImageUrl,
        },
      );
      _showSnack('Menu berhasil diperbarui', isError: false);
      await _loadMenu();
    } catch (e) {
      _showSnack('Gagal edit menu: $e');
      setState(() => _isLoading = false);
    }
  }

  // ── Hapus Menu ─────────────────────────────────────────────────────────────
  void _hapusMenu(Map<String, dynamic> item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => HapusMenuDialog(namaMenu: item['nama'] ?? ''),
    );
    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await ApiService.hapusMenu(item['id_menu'] as int);
      _showSnack('Menu berhasil dihapus', isError: false);
      await _loadMenu();
    } catch (e) {
      _showSnack('Gagal hapus menu: $e');
      setState(() => _isLoading = false);
    }
  }

  // ── Helper snackbar ────────────────────────────────────────────────────────
  void _showSnack(String msg, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: GoogleFonts.alexandria(color: Colors.white)),
        backgroundColor: isError ? Colors.red : const Color(0xFF0FBC5F),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const HeaderAdmin(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFD05122)))
                  : _errorMsg.isNotEmpty
                      ? _buildError()
                      : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error state ────────────────────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            Text('Gagal memuat menu',
                style: GoogleFonts.alexandria(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(_errorMsg,
                style: GoogleFonts.alexandria(
                    fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadMenu,
              icon: const Icon(Icons.refresh),
              label: Text('Coba Lagi',
                  style: GoogleFonts.alexandria()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD05122),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Content ────────────────────────────────────────────────────────────────
  Widget _buildContent() {
    final filtered = _filteredList;

    return RefreshIndicator(
      color: const Color(0xFFD05122),
      onRefresh: _loadMenu,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SearchBar(
              controller: _searchController,
              onChanged: (val) => setState(() {}),
            ),
            const SizedBox(height: 10),
            _TambahMenuButton(onTap: _showTambahMenu),
            const SizedBox(height: 10),
            // ── PERUBAHAN: kirim _kategoriList dinamis ─────────────────────
            _FilterRow(
              labels    : _kategoriList,
              selected  : _selectedFilter,
              onSelected: (i) => setState(() => _selectedFilter = i),
            ),
            const SizedBox(height: 12),

            if (filtered.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      const Icon(Icons.restaurant_menu,
                          size: 60, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text('Tidak ada menu ditemukan',
                          style: GoogleFonts.alexandria(
                              color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
              ...filtered.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _MenuItemCard(
                    item      : item,
                    onDelete  : () => _hapusMenu(item),
                    onEdit    : () => _showEditMenu(item),
                  ),
                ),
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║                        POPUP TAMBAH MENU                                 ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

class TambahMenuDialog extends StatefulWidget {
  const TambahMenuDialog({super.key});

  @override
  State<TambahMenuDialog> createState() => _TambahMenuDialogState();
}

class _TambahMenuDialogState extends State<TambahMenuDialog> {
  final _namaController      = TextEditingController();
  final _hargaController     = TextEditingController();
  final _deskripsiController = TextEditingController();
  String? _selectedJenis;

  TextStyle _alex({double size = 14, Color color = Colors.black,
      FontWeight weight = FontWeight.normal}) =>
      GoogleFonts.alexandria(fontSize: size, color: color, fontWeight: weight);

  BoxDecoration _fieldDecor() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: const [
          BoxShadow(color: Color(0x3F000000), spreadRadius: 3,
              offset: Offset(0, 1.7), blurRadius: 3)
        ],
      );

  Widget _buildTextField(String label, String hint,
      TextEditingController controller,
      {TextInputType type = TextInputType.text,
      int maxLines = 1,
      double height = 48}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _alex()),
        const SizedBox(height: 6),
        Container(
          height: height,
          decoration: _fieldDecor(),
          child: TextField(
            controller: controller,
            keyboardType: type,
            maxLines: maxLines,
            style: _alex(),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: _alex(color: Colors.black.withOpacity(0.2)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _alex()),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: _fieldDecor(),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedJenis,
              hint: Text('Pilih Jenis',
                  style: _alex(color: Colors.black.withOpacity(0.2))),
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: Colors.grey, size: 20),
              items: ['Paket Nasi', 'Olahan Ayam', 'Jajanan']
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e, style: _alex())))
                  .toList(),
              onChanged: (val) => setState(() => _selectedJenis = val),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _simpan() {
    if (_namaController.text.isEmpty) return;
    if (_hargaController.text.isEmpty) return;
    if (_selectedJenis == null) return;

    Navigator.pop(context, {
      'nama'      : _namaController.text,
      'harga'     : _hargaController.text,
      'deskripsi' : _deskripsiController.text,
      'jenis'     : _selectedJenis,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: 320,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity, height: 70,
              decoration: const BoxDecoration(
                  color: Color(0xFFE8891A),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(15))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_circle_outline,
                      color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text('TAMBAH MENU',
                      style: _alex(
                          size: 16,
                          color: Colors.white,
                          weight: FontWeight.bold)),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                        'Nama Menu', 'Masukkan nama menu', _namaController),
                    _buildTextField('Harga', 'Rp. 0', _hargaController,
                        type: TextInputType.number),
                    _buildTextField(
                        'Deskripsi Menu', 'Tulis deskripsi singkat menu',
                        _deskripsiController,
                        maxLines: 4, height: 100),
                    _buildDropdown('Jenis'),
                    Text('Gambar', style: _alex()),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity, height: 70,
                      decoration: _fieldDecor(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image_outlined,
                              color: Colors.grey, size: 24),
                          const SizedBox(width: 8),
                          Text('Foto default (sementara)',
                              style: _alex(color: Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: _simpan,
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: const LinearGradient(
                                    colors: _gradientColors,
                                    stops: [0.17, 0.47, 0.60]),
                              ),
                              child: Center(
                                child: Text('Simpan Menu',
                                    style: _alex(
                                        color: Colors.white,
                                        weight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                color: const Color(0xFFAC3715),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: Text('Batal',
                                    style: _alex(
                                        color: Colors.white,
                                        weight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ),
                      ],
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
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║                        POPUP HAPUS MENU                                  ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

class HapusMenuDialog extends StatelessWidget {
  final String namaMenu;
  const HapusMenuDialog({super.key, required this.namaMenu});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: 320,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity, height: 60,
              decoration: const BoxDecoration(
                  color: Color(0xFFE8891A),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(15))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delete_outline,
                      color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Text('HAPUS MENU',
                      style: GoogleFonts.alexandria(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFE8891A), size: 70),
                  const SizedBox(height: 20),
                  Text(
                    'Yakin ingin hapus menu "$namaMenu" dari daftar menu?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lora(color: Colors.black, fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 25),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: const Color(0xFFAC3715),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text('Tidak',
                              style: GoogleFonts.alexandria(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0FBC5F),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text('Ya, Hapus',
                              style: GoogleFonts.alexandria(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
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
    );
  }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║                        POPUP EDIT MENU                                   ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

class EditMenuDialog extends StatefulWidget {
  final String namaMenu;
  final String harga;
  final String jenis;
  final String deskripsi;

  const EditMenuDialog({
    super.key,
    required this.namaMenu,
    required this.harga,
    required this.jenis,
    this.deskripsi = '',
  });

  @override
  State<EditMenuDialog> createState() => _EditMenuDialogState();
}

class _EditMenuDialogState extends State<EditMenuDialog> {
  late TextEditingController _namaController;
  late TextEditingController _hargaController;
  late TextEditingController _deskripsiController;
  String? _selectedJenis;

  @override
  void initState() {
    super.initState();
    _namaController      = TextEditingController(text: widget.namaMenu);
    _hargaController     = TextEditingController(text: widget.harga);
    _deskripsiController = TextEditingController(text: widget.deskripsi);

    // ── PERUBAHAN: mapping langsung tanpa toLowerCase ─────────────────────
    const jenisValid = ['Paket Nasi', 'Olahan Ayam', 'Jajanan'];
    _selectedJenis = jenisValid.contains(widget.jenis.trim())
        ? widget.jenis.trim()
        : 'Paket Nasi';
  }

  TextStyle _alex({double size = 14, Color color = Colors.black,
      FontWeight weight = FontWeight.normal}) =>
      GoogleFonts.alexandria(fontSize: size, color: color, fontWeight: weight);

  BoxDecoration _fieldDecor() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: const [
          BoxShadow(color: Color(0x3F000000), spreadRadius: 3,
              offset: Offset(0, 1.7), blurRadius: 3)
        ],
      );

  Widget _buildTextField(String label, String hint,
      TextEditingController controller,
      {TextInputType type = TextInputType.text,
      int maxLines = 1,
      double height = 48}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _alex()),
        const SizedBox(height: 6),
        Container(
          height: height,
          decoration: _fieldDecor(),
          child: TextField(
            controller: controller,
            keyboardType: type,
            maxLines: maxLines,
            style: _alex(),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: _alex(color: Colors.black.withOpacity(0.2)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _alex()),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: _fieldDecor(),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedJenis,
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: Colors.grey, size: 20),
              items: ['Paket Nasi', 'Olahan Ayam', 'Jajanan']
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e, style: _alex())))
                  .toList(),
              onChanged: (val) => setState(() => _selectedJenis = val),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _simpan() {
    if (_namaController.text.isEmpty) return;
    if (_hargaController.text.isEmpty) return;

    Navigator.pop(context, {
      'nama'      : _namaController.text,
      'harga'     : _hargaController.text,
      'deskripsi' : _deskripsiController.text,
      'jenis'     : _selectedJenis ?? widget.jenis,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: 320,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity, height: 70,
              decoration: const BoxDecoration(
                  color: Color(0xFFE8891A),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(15))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit_outlined,
                      color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text('EDIT MENU',
                      style: _alex(
                          size: 16,
                          color: Colors.white,
                          weight: FontWeight.bold)),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                        'Nama Menu', 'Masukkan nama menu', _namaController),
                    _buildTextField('Harga', 'Rp. 0', _hargaController,
                        type: TextInputType.number),
                    _buildTextField(
                        'Deskripsi Menu', 'Tulis deskripsi singkat menu',
                        _deskripsiController,
                        maxLines: 4, height: 100),
                    _buildDropdown('Jenis'),
                    Text('Gambar', style: _alex()),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity, height: 90,
                      decoration: _fieldDecor(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image_outlined,
                              color: Colors.grey, size: 24),
                          const SizedBox(width: 8),
                          Text('Foto default (sementara)',
                              style: _alex(color: Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: _simpan,
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: const LinearGradient(
                                    colors: _gradientColors,
                                    stops: [0.17, 0.47, 0.60]),
                              ),
                              child: Center(
                                child: Text('Simpan Menu',
                                    style: _alex(
                                        color: Colors.white,
                                        weight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                color: const Color(0xFFAC3715),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: Text('Batal',
                                    style: _alex(
                                        color: Colors.white,
                                        weight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ),
                      ],
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
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  const _SearchBar({required this.controller, this.onChanged});

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
                BoxShadow(color: Color(0x3F000000), spreadRadius: 1,
                    blurRadius: 4, offset: Offset(0, 1))
              ],
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: GoogleFonts.alexandria(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari menu...',
                hintStyle: GoogleFonts.alexandria(
                    color: Colors.black.withOpacity(0.3)),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 45, height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
                colors: _gradientColors, stops: _gradientStops),
          ),
          child: const Icon(Icons.tune, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}

class _TambahMenuButton extends StatelessWidget {
  final VoidCallback onTap;
  const _TambahMenuButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFE8891A),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(color: _shadowColor, spreadRadius: 0,
                offset: Offset(0, 4), blurRadius: 4),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('TAMBAH MENU',
                style: GoogleFonts.alexandria(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// ── PERUBAHAN: _FilterRow terima List<String> labels dinamis ──────────────────
class _FilterRow extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;
  const _FilterRow({
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          labels.length,
          (i) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(i),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: i == selected
                      ? const Color(0xFFEE8B2E)
                      : Colors.transparent,
                  border: Border.all(width: 1.5, color: _borderOrange),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  labels[i],
                  style: GoogleFonts.lora(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: i == selected
                        ? FontWeight.bold
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _MenuItemCard({
    required this.item,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final foto  = (item['foto'] ?? '').toString();
    final nama  = (item['nama'] ?? '-').toString();
    final harga = item['harga'];

    String hargaStr;
    if (harga is num) {
      hargaStr = 'Rp. ${harga.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.',
          )}';
    } else {
      hargaStr = harga?.toString() ?? '-';
    }

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          boxShadow: _listShadow),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.network(
              foto.isNotEmpty ? foto : _dummyImageUrl,
              width: 65, height: 65, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 65, height: 65,
                color: const Color(0xFFF79F36),
                child: const Icon(Icons.fastfood,
                    color: Colors.white, size: 28),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama,
                    style: GoogleFonts.alexandria(fontSize: 14)),
                const SizedBox(height: 4),
                Text(hargaStr,
                    style: GoogleFonts.alexandria(
                      color: const Color(0xFFDC6727),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
          Column(
            children: [
              _ActionButton(
                color: const Color(0xFFFD4141),
                icon: Icons.delete_outline,
                onTap: onDelete,
              ),
              const SizedBox(height: 4),
              _ActionButton(
                color: const Color(0xFF0FBC5F),
                icon: Icons.edit_outlined,
                onTap: onEdit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.color, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26, height: 26,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, color: Colors.white, size: 15),
      ),
    );
  }
}