import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// BERANDA PAGE — StatefulWidget karena ada search & form ulasan
// ============================================================
class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  // ── Search ─────────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ── Ulasan ─────────────────────────────────────────────────
  final TextEditingController _ulasanController = TextEditingController();
  List<Map<String, String>> _daftarUlasan = [
    {
      'username': 'Username',
      'tanggal': '15 Maret 2026',
      'isi': 'Rasanya Mantap, Ga pernah Gagal! Rekomen banget buat yang mau makan enak.',
    },
    {
      'username': 'Username',
      'tanggal': '10 Maret 2026',
      'isi': 'Pelayanan cepat dan makanannya lezat. Pasti balik lagi!',
    },
  ];

  // ── Data menu tersedia ──────────────────────────────────────
  final List<Map<String, String>> _semuaMenu = const [
    {
      'nama': 'Ayam Panggang',
      'harga': 'Rp. 120.000',
      'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F523acacd6359d74640c5b9f05994ae4793dcf28fimage%206.png?alt=media&token=e97220f5-44dc-4197-b2df-34b3c3ea8f8f',
    },
    {
      'nama': 'Ayam Lodho',
      'harga': 'Rp. 130.000',
      'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F5bc84abcc8b704a6f2eb8d5a04879214d400d6c2image%2013.png?alt=media&token=518d40a4-c52c-45d9-aee9-54127deded32',
    },
    {
      'nama': 'Tumpeng',
      'harga': 'Rp. 250.000',
      'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2Fb611dcd57e8a8124c09e46eb95298a801a223e17image%204.png?alt=media&token=d76b27fe-1c4e-4600-815a-ec313f41bdbe',
    },
    {
      'nama': 'Paket Nasi Kotak',
      'harga': 'Rp. 15.000',
      'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F18a7fa0274cf38aa111ffa1eca9095ca82d92887image%204.png?alt=media&token=5fdda0e5-1c56-427d-9226-549dc4b4546f',
    },
    {
      'nama': 'Paket Nasi Hemat',
      'harga': 'Rp. 10.000',
      'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2Fa987c04c57196015702fdfed151f41d5771b925cimage%2014.png?alt=media&token=bd16b1ce-2df7-49d9-ac5e-f471a8aae2bd',
    },
    {
      'nama': 'Putu Ayu',
      'harga': 'Rp. 2.500/pcs',
      'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2Fe2e4435dcec0825005f424dfba6f841d734964b0image%204.png?alt=media&token=2145d1ba-3db3-4ab0-a440-a0cbb6ce1f02',
    },
  ];

  List<Map<String, String>> get _menuTerfilter {
    if (_searchQuery.isEmpty) return _semuaMenu;
    return _semuaMenu
        .where((m) =>
            m['nama']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _kirimUlasan() {
    final isi = _ulasanController.text.trim();
    if (isi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Isi ulasan tidak boleh kosong!',
              style: GoogleFonts.alexandria()),
          backgroundColor: const Color(0xFFD05122),
        ),
      );
      return;
    }
    setState(() {
      _daftarUlasan.insert(0, {
        'username': 'Saya',
        'tanggal': _tanggalSekarang(),
        'isi': isi,
      });
      _ulasanController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ulasan berhasil dikirim!',
            style: GoogleFonts.alexandria(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _batalUlasan() {
    _ulasanController.clear();
    FocusScope.of(context).unfocus();
  }

  String _tanggalSekarang() {
    final now = DateTime.now();
    const bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${now.day} ${bulan[now.month]} ${now.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _ulasanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header oranye ──────────────────────────────
            _buildHeader(),
            const SizedBox(height: 16),

            // ── Tracking Pesanan ───────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Text('Tracking Pesanan',
                  style: GoogleFonts.alexandria(
                    color: const Color(0xFF1A1818),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: _TrackingCard(),
            ),
            const SizedBox(height: 24),

            // ── Menu Terlaris ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Text('Menu Terlaris',
                  style: GoogleFonts.alexandria(
                    color: const Color(0xFF1A1818),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 26),
                itemCount: 4,
                itemBuilder: (_, i) => const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: _MenuTerlarisCard(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Menu Tersedia ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Menu Tersedia',
                      style: GoogleFonts.alexandria(
                        color: const Color(0xFF1A1818),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                  Opacity(
                    opacity: 0.5,
                    child: Text('Lihat semua',
                        style: GoogleFonts.alexandria(
                          color: const Color(0xFF1A1818),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Tampilkan hasil filter search
            _menuTerfilter.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 26, vertical: 16),
                    child: Text('Menu tidak ditemukan',
                        style: GoogleFonts.alexandria(
                            color: Colors.grey, fontSize: 13)),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: _menuTerfilter.length,
                    itemBuilder: (_, i) => _MenuTersediaCard(
                      nama: _menuTerfilter[i]['nama']!,
                      harga: _menuTerfilter[i]['harga']!,
                      imageUrl: _menuTerfilter[i]['imageUrl']!,
                    ),
                  ),
            const SizedBox(height: 24),

            // ── Ulasan ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Opacity(
                    opacity: 0.8,
                    child: Text('Ulasan',
                        style: GoogleFonts.alexandria(
                          color: const Color(0xFF1A1818),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  Opacity(
                    opacity: 0.5,
                    child: Text('Lihat semua',
                        style: GoogleFonts.alexandria(
                          color: const Color(0xFF1A1818),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // List ulasan dinamis
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 26),
              itemCount: _daftarUlasan.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _UlasanCard(
                username: _daftarUlasan[i]['username']!,
                tanggal: _daftarUlasan[i]['tanggal']!,
                isi: _daftarUlasan[i]['isi']!,
              ),
            ),
            const SizedBox(height: 24),

            // ── Form Beri Ulasan ───────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: _buildFormUlasan(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Header dengan search bar berfungsi ─────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEE8B2E), Color(0xFFD05122), Color(0xFFAC3715)],
          stops: [0.17, 0.44, 0.79],
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(26, 20, 26, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris lokasi + notifikasi + avatar
          Row(
            children: [
              Image.network(
                'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F2b2de4d17f51ac8a89f789b2c3fc544c438dac8cGoogle%20Maps.png?alt=media&token=1981c3aa-7e35-4fa9-af86-6bfa499edfc8',
                width: 35,
                height: 35,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Opacity(
                  opacity: 0.8,
                  child: Text(
                    'Jl. Asbdhainjshnsjaian',
                    style: GoogleFonts.lora(
                      color: const Color(0xFF1A1818),
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Image.network(
                'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2Fd154b179abf9d4a6058e12e77678299644c82914Notification.png?alt=media&token=ee7e3277-3227-4e20-bb69-f2a04c1cc16a',
                width: 25,
                height: 25,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 16),
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(23),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(23),
                  child: Image.network(
                    'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMOKhEnss8buSiiHoow%2F23705634-a6c1-4d7f-b1ce-e1f03c5d6330.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Search bar — TextField yang berfungsi
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) =>
                        setState(() => _searchQuery = val),
                    style: GoogleFonts.lora(
                      color: const Color(0xFF1A1818),
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Mau Menu apa hari ini?',
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
              const SizedBox(width: 11),
              // Tombol search
              GestureDetector(
                onTap: () => setState(() => _searchQuery = _searchController.text),
                child: Container(
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Form Beri Ulasan yang berfungsi ────────────────────────
  Widget _buildFormUlasan() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            spreadRadius: 3,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Beri Ulasan',
              style: GoogleFonts.alexandria(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 12),
          // TextField ulasan
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _ulasanController,
              maxLines: 6,
              style: GoogleFonts.alexandria(
                color: const Color(0xFF1A1818),
                fontSize: 12,
              ),
              decoration: InputDecoration(
                hintText: 'Isi Ulasan',
                hintStyle: GoogleFonts.alexandria(
                  color: const Color(0xFF1A1818).withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                contentPadding: const EdgeInsets.all(12),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Tombol Kirim & Batal
          Row(
            children: [
              // Tombol Kirim
              GestureDetector(
                onTap: _kirimUlasan,
                child: Container(
                  width: 102,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFD05122),
                        Color(0xFFEE8B2E),
                        Color(0xFFFBA839),
                      ],
                      stops: [0.18, 0.61, 0.85],
                    ),
                  ),
                  child: Center(
                    child: Text('Kirim',
                        style: GoogleFonts.lora(
                          color: Colors.white,
                          fontSize: 18,
                        )),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Tombol Batal
              GestureDetector(
                onTap: _batalUlasan,
                child: Container(
                  width: 102,
                  height: 46,
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
                    child: Text('Batal',
                        style: GoogleFonts.lora(
                          color: Colors.white,
                          fontSize: 18,
                        )),
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

// ── Tracking Card — elegan & menarik ──────────────────────────
class _TrackingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFAC3715),
            Color(0xFFD05122),
            Color(0xFFEE8B2E),
            Color(0xFFFBA839),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFD05122),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Dekorasi lingkaran di pojok kanan atas
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white10,
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 10,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white10,
              ),
            ),
          ),

          // Konten utama
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris atas: label + badge status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_shipping_rounded,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text('Tracking Pesanan',
                            style: GoogleFonts.alexandria(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            )),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white38, width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF176),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text('Di Proses',
                              style: GoogleFonts.alexandria(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Baris tengah: gambar + nama + step progress
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white24,
                        border: Border.all(color: Colors.white38, width: 1.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.network(
                          'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2Faadbd449f069aaa6819892687e7e3677080fc101Timer.png?alt=media&token=f24e784b-7f4c-459a-9a45-6d39bbd655f2',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.fastfood,
                              color: Colors.white,
                              size: 36),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ayam Panggang',
                              style: GoogleFonts.alexandria(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('Status: Di Proses',
                                style: GoogleFonts.alexandria(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Baris bawah: estimasi + tombol lihat detail
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text('Estimasi selesai: ',
                            style: GoogleFonts.alexandria(
                              color: Colors.white70,
                              fontSize: 11,
                            )),
                        Text('2 Jam',
                            style: GoogleFonts.alexandria(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('Lihat Detail',
                            style: GoogleFonts.alexandria(
                              color: Color(0xFFD05122),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



// ── Menu Terlaris Card ─────────────────────────────────────────
class _MenuTerlarisCard extends StatelessWidget {
  const _MenuTerlarisCard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F6a0353fb7d912965f7d455e118cb1a97189b30e1AYAM%20PANGGANG%20PERSEGI%20PANJANG.png%202.png?alt=media&token=125c9061-066f-4ae3-86b4-40637d18849e',
              width: 300,
              height: 160,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 300,
                height: 160,
                color: const Color(0xFFF79F36),
                child: const Icon(Icons.fastfood, color: Colors.white, size: 60),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Opacity(
                opacity: 0.8,
                child: Text('Ayam Panggang',
                    style: GoogleFonts.alexandria(
                      color: const Color(0xFF1A1818),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    )),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.star, size: 12, color: Color(0xFFF79F36)),
              const SizedBox(width: 2),
              Opacity(
                opacity: 0.8,
                child: Text('5',
                    style: GoogleFonts.alexandria(
                      color: const Color(0xFF1A1818),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    )),
              ),
              const SizedBox(width: 8),
              Opacity(
                opacity: 0.6,
                child: Text('50 Terjual',
                    style: GoogleFonts.alexandria(
                      color: const Color(0xFF1A1818),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Menu Tersedia Card ─────────────────────────────────────────
class _MenuTersediaCard extends StatelessWidget {
  final String nama;
  final String harga;
  final String imageUrl;
  const _MenuTersediaCard({
    required this.nama,
    required this.harga,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF79F36),
              borderRadius: BorderRadius.circular(6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.fastfood, color: Colors.white, size: 36),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Opacity(
              opacity: 0.8,
              child: Text(nama,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.alexandria(
                    color: const Color(0xFF1A1818),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  )),
            ),
          ),
          Opacity(
            opacity: 0.7,
            child: Text(harga,
                textAlign: TextAlign.center,
                style: GoogleFonts.alexandria(
                  color: const Color(0xFF1A1818),
                  fontSize: 7,
                  fontWeight: FontWeight.w500,
                )),
          ),
        ],
      ),
    );
  }
}

// ── Ulasan Card ────────────────────────────────────────────────
class _UlasanCard extends StatelessWidget {
  final String username;
  final String tanggal;
  final String isi;
  const _UlasanCard({
    required this.username,
    required this.tanggal,
    required this.isi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E4E4),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            spreadRadius: 3,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMOKhEnss8buSiiHoow%2F316b1609f20a8554436bf178b307cada634003f6user%201.png?alt=media&token=7e8f650d-fedf-4394-bbc4-445243b57769',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.person, color: Color(0xFFD05122), size: 26),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(username,
                        style: GoogleFonts.alexandria(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        )),
                    Opacity(
                      opacity: 0.5,
                      child: Text(tanggal,
                          style: GoogleFonts.alexandria(
                            color: const Color(0xFF1A1818),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(isi,
                    style: GoogleFonts.alexandria(
                      color: Colors.black,
                      fontSize: 12,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}