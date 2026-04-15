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
  const _MenuData({required this.name, required this.price, required this.imageUrl});
}

final _menuList = List.generate(
  7,
  (_) => const _MenuData(name: 'Tumpeng', price: 'Rp. 250.000', imageUrl: _imageUrl),
);

// ── Kelola Menu Page ──────────────────────────────────────────────────────────

class KelolaMenuPage extends StatefulWidget {
  const KelolaMenuPage({super.key});

  @override
  State<KelolaMenuPage> createState() => _KelolaMenuPageState();
}

class _KelolaMenuPageState extends State<KelolaMenuPage> {
  int _selectedFilter = 0;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi untuk membuka popup Tambah Menu
  void _showTambahMenu() => showDialog(
        context: context,
        builder: (_) => const TambahMenuDialog(),
      );

  @override
  Widget build(BuildContext context) {
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
                    _SearchBar(controller: _searchController),
                    const SizedBox(height: 10),
                    _TambahMenuButton(onTap: _showTambahMenu), // <-- memanggil popup tambah
                    const SizedBox(height: 10),
                    _FilterRow(
                      selected: _selectedFilter,
                      onSelected: (i) => setState(() => _selectedFilter = i),
                    ),
                    const SizedBox(height: 12),
                    ..._menuList.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _MenuItemCard(item: item),
                      ),
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

class TambahMenuDialog extends StatelessWidget {
  const TambahMenuDialog({super.key});

  TextStyle _alex({
    double size = 14,
    Color color = Colors.black,
    FontWeight weight = FontWeight.normal,
  }) =>
      GoogleFonts.alexandria(fontSize: size, color: color, fontWeight: weight);

  BoxDecoration _fieldDecor() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: _fieldShadow,
      );

  // Input box (kotak field putih dengan shadow)
  Widget _inputBox(double top, {double height = 38}) => Positioned(
        left: 20, top: top,
        child: Container(
          width: 280, height: height,
          clipBehavior: Clip.hardEdge,
          decoration: _fieldDecor(),
        ),
      );

  // Label di atas field (contoh: "Nama Menu", "Harga")
  Widget _fieldLabel(String text, double top) => Positioned(
        left: 16, top: top,
        child: Text(text, style: _alex()),
      );

  // Placeholder di dalam field (opacity 20%)
  Widget _fieldHint(String text, double top) => Positioned(
        left: 29, top: top,
        child: Opacity(opacity: 0.2, child: Text(text, style: _alex())),
      );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320, height: 494,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Input Boxes ───────────────────────────────────────
            _inputBox(113),             // field Nama Menu
            _inputBox(182),             // field Harga
            _inputBox(251),             // field Jenis
            _inputBox(318, height: 95), // area Gambar

            // ── Labels ────────────────────────────────────────────
            _fieldLabel('Nama Menu', 92),
            _fieldLabel('Harga', 161),
            _fieldLabel('Jenis', 229),
            _fieldLabel('Gambar', 297),

            // ── Hints / Placeholders ──────────────────────────────
            _fieldHint('Nama Menu', 122),
            _fieldHint('Harga', 190),

            // ── Jenis: hint + chevron ─────────────────────────────
            Positioned(
              left: 29, top: 260,
              child: Text('Pilih Jenis', style: _alex()),
            ),
            Positioned(
              left: 278, top: 264,
              child: Image.network(
                'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2Ffde4c19b-d6c8-4c2e-8684-b6bf904678db.png',
                width: 7, height: 11, fit: BoxFit.contain,
              ),
            ),

            // ── Gambar: icon upload di tengah ─────────────────────
            Positioned(
              left: 136, top: 346,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(200),
                child: Image.network(
                  'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SONxcLGhX9Sc4jqH3qj%2Fdbc746d275f5080798ce1a4d831e54481b78d1c4Create%20profile%20-%20empty.png?alt=media&token=f51e579f-0be1-4440-bdd3-bf3d81dc4533',
                  width: 40, height: 40, fit: BoxFit.cover,
                ),
              ),
            ),

            // ── Header orange ─────────────────────────────────────
            Positioned(
              left: 0, top: 0,
              child: Container(
                width: 320, height: 76,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8891A),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2Fe92ca0c0-6f04-421d-999e-84ebb9a89b71.png',
                      width: 19, height: 18, fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    Text('TAMBAH MENU', style: _alex(size: 16, color: Colors.white, weight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            // ── Tombol Simpan ─────────────────────────────────────
            Positioned(
              left: 20, top: 432,
              child: Container(
                width: 172, height: 40,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: _gradientColors,
                    stops: [0.17, 0.47, 0.60],
                  ),
                ),
                child: Center(
                  child: Text('Simpan Menu', style: _alex(color: Colors.white)),
                ),
              ),
            ),

            // ── Tombol Batal ──────────────────────────────────────
            Positioned(
              left: 198, top: 432,
              child: GestureDetector(
                onTap: () => Navigator.pop(context), // menutup popup
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2F7edc2170-95fb-4b71-a2ba-9bc2ae404644.png',
                    width: 102, height: 40, fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 230, top: 442,
              child: IgnorePointer(
                child: Text('Batal', style: _alex(color: Colors.white)),
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
      child: Container(
        width: 320, height: 320,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Header orange ─────────────────────────────────────
            Positioned(
              left: 0, top: 0,
              child: Container(
                width: 320, height: 57,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8891A),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2Ff94227fd-8aed-4214-9b65-2323689667af.png',
                      width: 18, height: 20, fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'HAPUS MENU',
                      style: GoogleFonts.alexandria(
                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Icon warning ──────────────────────────────────────
            Positioned(
              left: 115, top: 82,
              child: Image.network(
                'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SONxcLGhX9Sc4jqH3qj%2F5caf00cadf9098c502dbfb760ef03f80e756b367warning-sign%201.png?alt=media&token=ca740e51-d4ce-4f9c-a171-06230ff6475b',
                width: 90, height: 90, fit: BoxFit.cover,
              ),
            ),

            // ── Teks konfirmasi (nama menu dinamis) ───────────────
            Positioned(
              left: 47, top: 184,
              child: SizedBox(
                width: 226, height: 50,
                child: Text(
                  'Yakin ingin hapus menu $namaMenu dari menu?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lora(color: Colors.black, fontSize: 16),
                ),
              ),
            ),

            // ── Tombol Tidak ──────────────────────────────────────
            Positioned(
              left: 23, top: 258,
              child: GestureDetector(
                onTap: () => Navigator.pop(context), // menutup popup tanpa hapus
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2F71eec5f6-3643-477d-be43-8b92f3f8e921.png',
                    width: 130, height: 40, fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 67, top: 268,
              child: IgnorePointer(
                child: Text('Tidak', style: GoogleFonts.alexandria(color: Colors.white, fontSize: 14)),
              ),
            ),

            // ── Tombol Ya ─────────────────────────────────────────
            Positioned(
              left: 167, top: 258,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context); // menutup popup
                  // TODO: tambahkan logika hapus menu di sini
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2F74b56088-0daa-4a79-b289-780e3b370b09.png',
                    width: 130, height: 40, fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 222, top: 268,
              child: IgnorePointer(
                child: Text('Ya', style: GoogleFonts.alexandria(color: Colors.white, fontSize: 14)),
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

class EditMenuDialog extends StatelessWidget {
  final String namaMenu;
  final String harga;
  final String jenis;
  const EditMenuDialog({
    super.key,
    required this.namaMenu,
    required this.harga,
    required this.jenis,
  });

  TextStyle _alex({
    double size = 14,
    Color color = Colors.black,
    FontWeight weight = FontWeight.normal,
  }) =>
      GoogleFonts.alexandria(fontSize: size, color: color, fontWeight: weight);

  BoxDecoration _fieldDecor() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: _fieldShadow,
      );

  // Input box (kotak field putih dengan shadow)
  Widget _inputBox(double top, {double height = 38}) => Positioned(
        left: 20, top: top,
        child: Container(
          width: 280, height: height,
          clipBehavior: Clip.hardEdge,
          decoration: _fieldDecor(),
        ),
      );

  // Label di atas field (contoh: "Nama Menu", "Harga")
  Widget _fieldLabel(String text, double top) => Positioned(
        left: 16, top: top,
        child: Text(text, style: _alex()),
      );

  // Nilai existing di dalam field (data yang sudah ada sebelumnya)
  Widget _fieldValue(String text, double top) => Positioned(
        left: 29, top: top,
        child: Text(text, style: _alex()),
      );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320, height: 494,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Input Boxes ───────────────────────────────────────
            _inputBox(113), // field Nama Menu
            _inputBox(182), // field Harga
            _inputBox(251), // field Jenis

            // ── Labels ────────────────────────────────────────────
            _fieldLabel('Nama Menu', 92),
            _fieldLabel('Harga', 161),
            _fieldLabel('Jenis', 229),
            _fieldLabel('Gambar', 297),

            // ── Nilai existing (data yang sudah ada) ──────────────
            _fieldValue(namaMenu, 122), // menampilkan nama menu saat ini
            _fieldValue(harga, 190),    // menampilkan harga saat ini
            _fieldValue(jenis, 260),    // menampilkan jenis saat ini

            // ── Jenis: chevron ────────────────────────────────────
            Positioned(
              left: 278, top: 264,
              child: Image.network(
                'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2Ffdbfbbea-4dd0-43ed-9109-cd410daf7d9f.png',
                width: 7, height: 11, fit: BoxFit.contain,
              ),
            ),

            // ── Gambar: preview gambar existing ───────────────────
            Positioned(
              left: 115, top: 318,
              child: Container(
                width: 91, height: 91,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: _fieldShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.network(
                    'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SONxcLGhX9Sc4jqH3qj%2Fb611dcd57e8a8124c09e46eb95298a801a223e17image%203.png?alt=media&token=c02112d7-1e83-464f-98c1-6f5c93a6ac46',
                    width: 91, height: 91, fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Icon overlay untuk ganti gambar
            Positioned(
              left: 140, top: 344,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(200),
                child: Image.network(
                  'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SONxcLGhX9Sc4jqH3qj%2Fdbc746d275f5080798ce1a4d831e54481b78d1c4Create%20profile%20-%20empty.png?alt=media&token=a593962a-6416-45de-affa-3289ec53f26d',
                  width: 40, height: 40, fit: BoxFit.cover,
                ),
              ),
            ),

            // ── Header orange ─────────────────────────────────────
            Positioned(
              left: 0, top: 0,
              child: Container(
                width: 320, height: 76,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8891A),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2F00aaa6e7-b0e8-4edb-a085-09164368cb18.png',
                      width: 18, height: 18, fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    Text('EDIT MENU', style: _alex(size: 16, color: Colors.white, weight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            // ── Tombol Simpan ─────────────────────────────────────
            Positioned(
              left: 20, top: 432,
              child: Container(
                width: 172, height: 40,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: _gradientColors,
                    stops: [0.17, 0.47, 0.60],
                  ),
                ),
                child: Center(
                  child: Text('Simpan Menu', style: _alex(color: Colors.white)),
                ),
              ),
            ),

            // ── Tombol Batal ──────────────────────────────────────
            Positioned(
              left: 198, top: 432,
              child: GestureDetector(
                onTap: () => Navigator.pop(context), // menutup popup
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2Fd4e8001b-c2b9-48a5-8184-4613dacd16bc.png',
                    width: 102, height: 40, fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 230, top: 442,
              child: IgnorePointer(
                child: Text('Batal', style: _alex(color: Colors.white)),
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
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2F1b9c73ec-6782-4b31-808d-6b3269237049.png',
              height: 45, fit: BoxFit.contain,
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
  const _MenuItemCard({required this.item});

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
              // Tombol merah = hapus menu, membuka HapusMenuDialog
              _ActionButton(
                color: const Color(0xFFFD4141),
                iconUrl: 'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2Fed786f6d-10b1-4bfb-8dc7-658ed3877c73.png',
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => HapusMenuDialog(namaMenu: item.name), // <-- memanggil popup hapus
                ),
              ),
              const SizedBox(height: 4),
              // Tombol hijau = edit menu, membuka EditMenuDialog
              _ActionButton(
                color: const Color(0xFF0FBC5F),
                iconUrl: 'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2F4201a3cd-540d-4e5f-ade7-22dd16fb4eb1.png',
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => EditMenuDialog(
                    namaMenu: item.name,  // <-- kirim nama menu
                    harga: item.price,    // <-- kirim harga
                    jenis: 'Paket Nasi',  // <-- kirim jenis (sesuaikan kalau sudah ada di _MenuData)
                  ),
                ),
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