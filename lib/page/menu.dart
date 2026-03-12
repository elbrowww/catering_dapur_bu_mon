import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'detail-menu.dart';

// ============================================================
// MENU PAGE
// PENTING: Tidak pakai Scaffold & tidak pakai CustomNavbar
// Navbar sudah dihandle oleh MainScreen di main.dart
// ============================================================

class MenuItemData {
  final String nama;
  final String harga;
  final String imageUrl;
  final String kategori;

  const MenuItemData({
    required this.nama,
    required this.harga,
    required this.imageUrl,
    required this.kategori,
  });
}

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String _kategoriAktif = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _kategoriList = [
    'Semua',
    'Paket Nasi',
    'Olahan Ayam',
    'Jajanan',
  ];

  final List<MenuItemData> _semuaMenu = const [
    MenuItemData(
      nama: 'Ayam Panggang',
      harga: 'Rp. 120.000',
      imageUrl: 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F523acacd6359d74640c5b9f05994ae4793dcf28fimage%206.png?alt=media&token=20386a59-9501-47a7-a1bc-d8a57c2972c8',
      kategori: 'Olahan Ayam',
    ),
    MenuItemData(
      nama: 'Ayam Lodho',
      harga: 'Rp. 130.000',
      imageUrl: 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F5bc84abcc8b704a6f2eb8d5a04879214d400d6c2image%2013.png?alt=media&token=518d40a4-c52c-45d9-aee9-54127deded32',
      kategori: 'Olahan Ayam',
    ),
    MenuItemData(
      nama: 'Tumpeng',
      harga: 'Rp. 250.000',
      imageUrl: 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2Fb611dcd57e8a8124c09e46eb95298a801a223e17image%204.png?alt=media&token=d76b27fe-1c4e-4600-815a-ec313f41bdbe',
      kategori: 'Paket Nasi',
    ),
    MenuItemData(
      nama: 'Paket Nasi Kotak',
      harga: 'Rp. 15.000',
      imageUrl: 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F18a7fa0274cf38aa111ffa1eca9095ca82d92887image%204.png?alt=media&token=5fdda0e5-1c56-427d-9226-549dc4b4546f',
      kategori: 'Paket Nasi',
    ),
    MenuItemData(
      nama: 'Paket Nasi Hemat',
      harga: 'Rp. 10.000',
      imageUrl: 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2Fa987c04c57196015702fdfed151f41d5771b925cimage%2014.png?alt=media&token=bd16b1ce-2df7-49d9-ac5e-f471a8aae2bd',
      kategori: 'Paket Nasi',
    ),
    MenuItemData(
      nama: 'Putu Ayu',
      harga: 'Rp. 2.500/pcs',
      imageUrl: 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2Fe2e4435dcec0825005f424dfba6f841d734964b0image%204.png?alt=media&token=2145d1ba-3db3-4ab0-a440-a0cbb6ce1f02',
      kategori: 'Jajanan',
    ),
    MenuItemData(
      nama: 'Klepon',
      harga: 'Rp. 2.000/pck',
      imageUrl: 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F1eaf1b66f80b139f516c533ef302457c45c29259image%208.png?alt=media&token=bc64cbf7-78df-4e3a-86f0-3542f5cf15cd',
      kategori: 'Jajanan',
    ),
    MenuItemData(
      nama: 'Angsle',
      harga: 'Rp. 6.000',
      imageUrl: 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F543c4f6d10c4816376b5c612a51e9de1a0c92183image%2011.png?alt=media&token=b23d275f-4666-4727-bc27-bfa734d3b910',
      kategori: 'Jajanan',
    ),
    MenuItemData(
      nama: 'Ronde',
      harga: 'Rp. 6.000',
      imageUrl: 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F67b0b68f106f84a678b6ddd8d26c4fe7a0e80051image%2012.png?alt=media&token=e50f72a4-f45f-41d2-88cf-ae8af51ddcd6',
      kategori: 'Jajanan',
    ),
    MenuItemData(
      nama: 'Ongol - ongol',
      harga: 'Rp. 5.000/pck',
      imageUrl: 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F49b0b3fe9d3325a61178c00351a4fd3e187ba3d4image%2013.png?alt=media&token=a5fcde4e-4c07-4513-aa37-92148bb336d1',
      kategori: 'Jajanan',
    ),
    MenuItemData(
      nama: 'Putu Tegal',
      harga: 'Rp. 6.000/pck',
      imageUrl: 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F227157152d6b1e5b3b27b7e863a1e325fbd6f1beimage%2015.png?alt=media&token=3ebded23-6bff-4854-af52-ab76ccaad388',
      kategori: 'Jajanan',
    ),
  ];

  List<MenuItemData> get _menuTerfilter {
    return _semuaMenu.where((item) {
      final cocokKategori =
          _kategoriAktif == 'Semua' || item.kategori == _kategoriAktif;
      final cocokSearch = _searchQuery.isEmpty ||
          item.nama.toLowerCase().contains(_searchQuery.toLowerCase());
      return cocokKategori && cocokSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────
          Container(
            width: double.infinity,
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.04, 0.80),
                end: Alignment(0.98, -0.49),
                colors: [
                  Color(0xFFEE8B2E),
                  Color(0xFFD05122),
                  Color(0xFFAC3715),
                ],
                stops: [0.17, 0.44, 0.79],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
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
                    'Menu',
                    style: GoogleFonts.alexandria(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Search bar ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: GoogleFonts.lora(
                        color: const Color(0xFF1A1818),
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cari menu',
                        hintStyle: GoogleFonts.lora(
                          color: const Color(0xFF1A1818).withOpacity(0.5),
                          fontSize: 14,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFD05122),
                        Color(0xFFEE8B2E),
                        Color(0xFFFBA839),
                      ],
                      stops: [0.18, 0.61, 0.85],
                    ),
                  ),
                  child: const Icon(Icons.search, color: Colors.white, size: 22),
                ),
              ],
            ),
          ),

          // ── Filter Kategori ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _kategoriList.map((kat) {
                  final aktif = _kategoriAktif == kat;
                  return GestureDetector(
                    onTap: () => setState(() => _kategoriAktif = kat),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: aktif
                            ? const Color(0xFFEE8B2E)
                            : Colors.transparent,
                        border: Border.all(
                          color: const Color(0xFFDB6626),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        kat,
                        style: GoogleFonts.lora(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight:
                              aktif ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Grid Menu ──────────────────────────────────
          Expanded(
            child: _menuTerfilter.isEmpty
                ? Center(
                    child: Text(
                      'Menu tidak ditemukan',
                      style: GoogleFonts.alexandria(
                          color: Colors.grey, fontSize: 14),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: _menuTerfilter.length,
                    itemBuilder: (_, i) =>
                        _MenuCard(item: _menuTerfilter[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Menu Card — bisa di-tap ke halaman detail ──────────────────
class _MenuCard extends StatelessWidget {
  final MenuItemData item;
  const _MenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailMenuPage(item: item),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 6,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                color: const Color(0xFFF79F36),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  item.imageUrl,
                  width: 106,
                  height: 106,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.fastfood,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                item.nama,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.alexandria(
                  color: const Color(0xFF1A1818),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.harga,
              style: GoogleFonts.alexandria(
                color: const Color(0xFF1A1818).withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}