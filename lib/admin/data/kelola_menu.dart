import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/admin/shared/header_admin.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const _gradientColors = [Color(0xFFD05122), Color(0xFFEE8B2E), Color(0xFFFBA839)];
const _gradientStops = [0.18, 0.61, 0.85];
const _borderOrange = Color(0xFFDB6626);
const _shadowColor = Color(0x3F000000);

const _listShadow = [
  BoxShadow(color: _shadowColor, spreadRadius: 3, offset: Offset(0, 1.7), blurRadius: 3),
];
const _fieldShadow = [
  BoxShadow(color: _shadowColor, spreadRadius: 3, offset: Offset(0, 1.7), blurRadius: 3),
];

const _filterLabels = ['Semua', 'Paket Nasi', 'Olahan Ayam', 'Jajanan'];

const _imageUrl =
    'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SONxcLGhX9Sc4jqH3qj%2Fb611dcd57e8a8124c09e46eb95298a801a223e17image%203.png?alt=media&token=274a3b20-6268-4ae8-80a1-410fb38711f3';

// ── Data Model ────────────────────────────────────────────────────────────────

class _MenuData {
  final String name;
  final String price;
  final String imageUrl;
  final String deskripsi;
  const _MenuData({required this.name, required this.price, required this.imageUrl, this.deskripsi = ''});
}

// ── Kelola Menu Page ──────────────────────────────────────────────────────────

class KelolaMenuPage extends StatefulWidget {
  const KelolaMenuPage({super.key});

  @override
  State<KelolaMenuPage> createState() => _KelolaMenuPageState();
}

class _KelolaMenuPageState extends State<KelolaMenuPage> {
  int _selectedFilter = 0;
  final _searchController = TextEditingController();

  List<_MenuData> _menuList = [
    const _MenuData(name: 'Tumpeng', price: 'Rp. 250.000', imageUrl: _imageUrl),
    const _MenuData(name: 'Ayam Bakar', price: 'Rp. 150.000', imageUrl: _imageUrl),
    const _MenuData(name: 'Nasi Kuning Kotak', price: 'Rp. 30.000', imageUrl: _imageUrl),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi untuk membuka popup Tambah Menu
  void _showTambahMenu() async {
    final result = await showDialog<_MenuData>(
      context: context,
      builder: (_) => const TambahMenuDialog(),
    );
    if (result != null) {
      setState(() => _menuList.insert(0, result));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _menuList.where((item) {
      if (_searchController.text.isEmpty) return true;
      return item.name.toLowerCase().contains(_searchController.text.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const HeaderAdmin(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SearchBar(
                      controller: _searchController,
                      onChanged: (val) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    _TambahMenuButton(onTap: _showTambahMenu), // <-- memanggil popup tambah
                    const SizedBox(height: 10),
                    _FilterRow(
                      selected: _selectedFilter,
                      onSelected: (i) => setState(() => _selectedFilter = i),
                    ),
                    const SizedBox(height: 12),
                    ...filteredList.map(
                      (item) {
                        final index = _menuList.indexOf(item);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _MenuItemCard(
                            item: item,
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => HapusMenuDialog(namaMenu: item.name),
                              );
                              if (confirm == true) {
                                setState(() => _menuList.removeAt(index));
                              }
                            },
                            onEdit: () async {
                              final result = await showDialog<_MenuData>(
                                context: context,
                                builder: (_) => EditMenuDialog(
                                  namaMenu: item.name,
                                  harga: item.price,
                                  jenis: 'Paket Nasi',
                                  deskripsi: item.deskripsi,
                                ),
                              );
                              if (result != null) {
                                setState(() => _menuList[index] = result);
                              }
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 80),
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
// ║                        POPUP TAMBAH MENU                                 ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

class TambahMenuDialog extends StatefulWidget {
  const TambahMenuDialog({super.key});

  @override
  State<TambahMenuDialog> createState() => _TambahMenuDialogState();
}

class _TambahMenuDialogState extends State<TambahMenuDialog> {
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  String? _selectedJenis;

  TextStyle _alex({double size = 14, Color color = Colors.black, FontWeight weight = FontWeight.normal}) =>
      GoogleFonts.alexandria(fontSize: size, color: color, fontWeight: weight);

  BoxDecoration _fieldDecor() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: const [BoxShadow(color: Color(0x3F000000), spreadRadius: 3, offset: Offset(0, 1.7), blurRadius: 3)],
      );

  Widget _buildTextField(String label, String hint, TextEditingController controller, {TextInputType type = TextInputType.text, int maxLines = 1, double height = 48}) {
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
              hint: Text('Pilih Jenis', style: _alex(color: Colors.black.withOpacity(0.2))),
              icon: Image.network(
                'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2Ffde4c19b-d6c8-4c2e-8684-b6bf904678db.png',
                width: 12, height: 12,
              ),
              items: ['Paket Nasi', 'Olahan Ayam', 'Jajanan']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e, style: _alex())))
                  .toList(),
              onChanged: (val) => setState(() => _selectedJenis = val),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: 320,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity, height: 70,
              decoration: const BoxDecoration(color: Color(0xFFE8891A), borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Image.network('https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2Fe92ca0c0-6f04-421d-999e-84ebb9a89b71.png', width: 20, height: 20),
                  const SizedBox(width: 8),
                  Text('TAMBAH MENU', style: _alex(size: 16, color: Colors.white, weight: FontWeight.bold)),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField('Nama Menu', 'Masukkan nama menu', _namaController),
                    _buildTextField('Harga', 'Rp. 0', _hargaController, type: TextInputType.number),
                    _buildTextField('Deskripsi Menu', 'Tulis deskripsi singkat menu', _deskripsiController, maxLines: 4, height: 100),
                    _buildDropdown('Jenis'),
                    Text('Gambar', style: _alex()),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity, height: 100,
                      decoration: _fieldDecor(),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(200),
                          child: Image.network('https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SONxcLGhX9Sc4jqH3qj%2Fdbc746d275f5080798ce1a4d831e54481b78d1c4Create%20profile%20-%20empty.png?alt=media&token=f51e579f-0be1-4440-bdd3-bf3d81dc4533', width: 45, height: 45, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: () {
                              if (_namaController.text.isNotEmpty && _hargaController.text.isNotEmpty) {
                                Navigator.pop(context, _MenuData(name: _namaController.text, price: _hargaController.text, imageUrl: _imageUrl, deskripsi: _deskripsiController.text));
                              }
                            },
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: const LinearGradient(colors: _gradientColors, stops: [0.17, 0.47, 0.60]),
                              ),
                              child: Center(child: Text('Simpan Menu', style: _alex(color: Colors.white, weight: FontWeight.bold))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: SizedBox(
                              height: 45,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network('https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2F7edc2170-95fb-4b71-a2ba-9bc2ae404644.png', width: double.infinity, height: 45, fit: BoxFit.cover),
                                  ),
                                  Text('Batal', style: _alex(color: Colors.white, weight: FontWeight.bold)),
                                ],
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
// ║                        END POPUP TAMBAH MENU                             ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity, height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFE8891A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network('https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2Ff94227fd-8aed-4214-9b65-2323689667af.png', width: 20, height: 20),
                  const SizedBox(width: 10),
                  Text('HAPUS MENU', style: GoogleFonts.alexandria(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                children: [
                   Image.network('https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SONxcLGhX9Sc4jqH3qj%2F5caf00cadf9098c502dbfb760ef03f80e756b367warning-sign%201.png?alt=media&token=ca740e51-d4ce-4f9c-a171-06230ff6475b', width: 90, height: 90),
                   const SizedBox(height: 20),
                   Text(
                     'Yakin ingin hapus menu $namaMenu dari menu?',
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
                      child: SizedBox(
                        height: 45,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network('https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2F71eec5f6-3643-477d-be43-8b92f3f8e921.png', width: double.infinity, height: 45, fit: BoxFit.cover),
                            ),
                            Text('Tidak', style: GoogleFonts.alexandria(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
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
                        child: Center(child: Text('Ya', style: GoogleFonts.alexandria(color: Colors.white, fontWeight: FontWeight.bold))),
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
// ║                        END POPUP HAPUS MENU                              ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

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
    _namaController = TextEditingController(text: widget.namaMenu);
    _hargaController = TextEditingController(text: widget.harga);
    _deskripsiController = TextEditingController(text: widget.deskripsi);
    _selectedJenis = ['Paket Nasi', 'Olahan Ayam', 'Jajanan'].contains(widget.jenis) ? widget.jenis : 'Paket Nasi';
  }

  TextStyle _alex({double size = 14, Color color = Colors.black, FontWeight weight = FontWeight.normal}) =>
      GoogleFonts.alexandria(fontSize: size, color: color, fontWeight: weight);

  BoxDecoration _fieldDecor() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: const [BoxShadow(color: Color(0x3F000000), spreadRadius: 3, offset: Offset(0, 1.7), blurRadius: 3)],
      );

  Widget _buildTextField(String label, String hint, TextEditingController controller, {TextInputType type = TextInputType.text, int maxLines = 1, double height = 48}) {
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
              hint: Text('Pilih Jenis', style: _alex(color: Colors.black.withOpacity(0.2))),
              icon: Image.network(
                'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2Ffdbfbbea-4dd0-43ed-9109-cd410daf7d9f.png',
                width: 12, height: 12,
              ),
              items: ['Paket Nasi', 'Olahan Ayam', 'Jajanan']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e, style: _alex())))
                  .toList(),
              onChanged: (val) => setState(() => _selectedJenis = val),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: 320,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity, height: 70,
              decoration: const BoxDecoration(color: Color(0xFFE8891A), borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Image.network('https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2F00aaa6e7-b0e8-4edb-a085-09164368cb18.png', width: 20, height: 20),
                  const SizedBox(width: 8),
                  Text('EDIT MENU', style: _alex(size: 16, color: Colors.white, weight: FontWeight.bold)),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField('Nama Menu', 'Masukkan nama menu', _namaController),
                    _buildTextField('Harga', 'Rp. 0', _hargaController, type: TextInputType.number),
                    _buildTextField('Deskripsi Menu', 'Tulis deskripsi singkat menu', _deskripsiController, maxLines: 4, height: 100),
                    _buildDropdown('Jenis'),
                    Text('Gambar', style: _alex()),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity, height: 120,
                      decoration: _fieldDecor(),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: Image.network('https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SONxcLGhX9Sc4jqH3qj%2Fb611dcd57e8a8124c09e46eb95298a801a223e17image%203.png?alt=media&token=c02112d7-1e83-464f-98c1-6f5c93a6ac46', width: 100, height: 100, fit: BoxFit.cover),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(200),
                            child: Image.network('https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SONxcLGhX9Sc4jqH3qj%2Fdbc746d275f5080798ce1a4d831e54481b78d1c4Create%20profile%20-%20empty.png?alt=media&token=a593962a-6416-45de-affa-3289ec53f26d', width: 45, height: 45, fit: BoxFit.cover),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: () {
                              if (_namaController.text.isNotEmpty && _hargaController.text.isNotEmpty) {
                                Navigator.pop(context, _MenuData(name: _namaController.text, price: _hargaController.text, imageUrl: _imageUrl, deskripsi: _deskripsiController.text));
                              }
                            },
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: const LinearGradient(colors: _gradientColors, stops: [0.17, 0.47, 0.60]),
                              ),
                              child: Center(child: Text('Simpan Menu', style: _alex(color: Colors.white, weight: FontWeight.bold))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: SizedBox(
                              height: 45,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network('https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2Fd4e8001b-c2b9-48a5-8184-4613dacd16bc.png', width: double.infinity, height: 45, fit: BoxFit.cover),
                                  ),
                                  Text('Batal', style: _alex(color: Colors.white, weight: FontWeight.bold)),
                                ],
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
// ║                        END POPUP EDIT MENU                               ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

// ── Sub-widgets Kelola Menu ───────────────────────────────────────────────────

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
              boxShadow: const [BoxShadow(color: Color(0x3F000000), spreadRadius: 1, blurRadius: 4, offset: Offset(0, 1))],
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: GoogleFonts.alexandria(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari menu...',
                hintStyle: GoogleFonts.alexandria(color: Colors.black.withOpacity(0.3)),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 45, height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(colors: _gradientColors, stops: _gradientStops),
          ),
          child: Center(
            child: Image.network(
              'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2F404dc9f9-a237-4b20-bbb2-c805bfaff268.png',
              width: 20, height: 20, fit: BoxFit.contain,
            ),
          ),
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
            BoxShadow(color: _shadowColor, spreadRadius: 0, offset: Offset(0, 4), blurRadius: 4),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2Ffe80fd8b-4116-4353-990c-07e18f6b21b6.png',
              width: 19, height: 18, fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Text(
              'TAMBAH MENU',
              style: GoogleFonts.alexandria(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;
  const _FilterRow({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          _filterLabels.length,
          (i) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: i == selected ? const Color(0xFFEE8B2E) : Colors.transparent,
                  border: Border.all(width: 1.5, color: _borderOrange),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  _filterLabels[i],
                  style: GoogleFonts.lora(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: i == selected ? FontWeight.bold : FontWeight.w500,
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
  final _MenuData item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  
  const _MenuItemCard({required this.item, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: _listShadow,
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.network(item.imageUrl, width: 65, height: 65, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: GoogleFonts.alexandria(fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  item.price,
                  style: GoogleFonts.alexandria(
                    color: const Color(0xFFDC6727),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              // Tombol merah = hapus menu, memanggil onDelete callback
              _ActionButton(
                color: const Color(0xFFFD4141),
                iconUrl: 'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2Fed786f6d-10b1-4bfb-8dc7-658ed3877c73.png',
                onTap: onDelete,
              ),
              const SizedBox(height: 4),
              // Tombol hijau = edit menu, memanggil onEdit callback
              _ActionButton(
                color: const Color(0xFF0FBC5F),
                iconUrl: 'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2F4201a3cd-540d-4e5f-ade7-22dd16fb4eb1.png',
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
  final String iconUrl;
  final VoidCallback onTap;
  const _ActionButton({required this.color, required this.iconUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26, height: 26,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
        child: Center(
          child: Opacity(
            opacity: 0.85,
            child: Image.network(iconUrl, width: 13, height: 13, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}