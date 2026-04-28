import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({super.key});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  // Controller untuk setiap field input
  final _namaController   = TextEditingController();
  final _noTelpController = TextEditingController();
  final _alamatController = TextEditingController();

  bool _isLoading = true;  // Loading data awal
  bool _isSaving  = false; // Loading saat simpan

  String _email = ''; // Email ditampilkan tapi tidak bisa diubah

  @override
  void initState() {
    super.initState();
    _loadProfil();
    // FIX 1: Listener agar nama di header ikut update saat user mengetik
    _namaController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noTelpController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  // Ambil data profil dari API dan isi ke controller
  Future<void> _loadProfil() async {
    try {
      final data = await ApiService.getProfil();
      setState(() {
        _namaController.text   = data['nama']    ?? '';
        _noTelpController.text = data['no_telp'] ?? '';
        _alamatController.text = data['alamat']  ?? '';
        _email                 = data['email']   ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat profil: $e')),
        );
      }
    }
  }

  // Simpan perubahan ke API
  Future<void> _simpanProfil() async {
    // FIX 3: Validasi nama tidak boleh kosong sebelum kirim ke API
    if (_namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama tidak boleh kosong'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ApiService.editProfil(
        nama:   _namaController.text.trim(),
        noTelp: _noTelpController.text.trim(),
        alamat: _alamatController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Kembali ke ProfilPage
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double screenWidth     = MediaQuery.of(context).size.width;
    final double screenHeight    = MediaQuery.of(context).size.height;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              width: screenWidth,
              height: screenHeight,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFAC3715), Color(0xFFD05122), Color(0xFFEE8B2E)],
                  stops: [0.21, 0.56, 0.83],
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                // FIX 2: SingleChildScrollView agar tombol tidak terpotong
                // di layar kecil
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: SizedBox(
                    // Minimal setinggi layar agar gradient tetap penuh
                    height: screenHeight * 1.05,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [

                        // ── Panel putih bawah ─────────────────────
                        Positioned(
                          left: 0,
                          top: statusBarHeight + 237,
                          child: Container(
                            width: screenWidth,
                            height: screenHeight,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(46),
                            ),
                          ),
                        ),

                        // ── Foto profil ───────────────────────────
                        Positioned(
                          left: screenWidth * 0.313,
                          top: statusBarHeight + 30,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(75),
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  left: 10,
                                  top: 10,
                                  child: Image.network(
                                    'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2F988b443c-cf48-42ae-9b9d-4ea1a53dfaa5.png',
                                    width: 130,
                                    height: 130,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ── Ikon edit foto ────────────────────────
                        Positioned(
                          left: screenWidth * 0.572,
                          top: statusBarHeight + 144,
                          child: Image.network(
                            'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2Fc6f7abf4-bbd0-4265-9843-7332090b758c.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          left: screenWidth * 0.585,
                          top: statusBarHeight + 149,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(200),
                            clipBehavior: Clip.hardEdge,
                            child: Image.network(
                              'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMpkHR7SLEvor999HjP%2Fdbc746d275f5080798ce1a4d831e54481b78d1c4Create%20profile%20-%20empty.png?alt=media&token=d572421f-71e8-4990-b603-9eb3f8d1352b',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // ── Nama pengguna (reaktif saat mengetik) ─
                        // FIX 1 diterapkan: _namaController.addListener
                        // di initState membuat widget ini rebuild otomatis
                        Positioned(
                          left: screenWidth * 0.05,
                          right: screenWidth * 0.05,
                          top: statusBarHeight + 195,
                          child: Text(
                            _namaController.text.isEmpty
                                ? '-'
                                : _namaController.text,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.getFont(
                              'Alexandria',
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // ── Field: No Telp ────────────────────────
                        Positioned(
                          left: screenWidth * 0.147,
                          top: statusBarHeight + 286,
                          child: Text(
                            'No Telp',
                            style: GoogleFonts.getFont(
                              'Alexandria',
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Positioned(
                          left: screenWidth * 0.144,
                          right: screenWidth * 0.144,
                          top: statusBarHeight + 311,
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  spreadRadius: 3,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _noTelpController,
                              keyboardType: TextInputType.phone,
                              style: GoogleFonts.getFont(
                                'Alexandria',
                                fontSize: 14,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 8,
                                ),
                                border: InputBorder.none,
                                hintText: '08123456789',
                                hintStyle: GoogleFonts.getFont(
                                  'Alexandria',
                                  fontSize: 14,
                                  color: Colors.black38,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ── Field: Nama ───────────────────────────
                        Positioned(
                          left: screenWidth * 0.147,
                          top: statusBarHeight + 374,
                          child: Text(
                            'Nama',
                            style: GoogleFonts.getFont(
                              'Alexandria',
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Positioned(
                          left: screenWidth * 0.144,
                          right: screenWidth * 0.144,
                          top: statusBarHeight + 399,
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  spreadRadius: 3,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _namaController,
                              style: GoogleFonts.getFont(
                                'Alexandria',
                                fontSize: 14,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 8,
                                ),
                                border: InputBorder.none,
                                hintText: 'Nama lengkap',
                                hintStyle: GoogleFonts.getFont(
                                  'Alexandria',
                                  fontSize: 14,
                                  color: Colors.black38,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ── Field: Email (read-only) ──────────────
                        Positioned(
                          left: screenWidth * 0.147,
                          top: statusBarHeight + 462,
                          child: Text(
                            'Email',
                            style: GoogleFonts.getFont(
                              'Alexandria',
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Positioned(
                          left: screenWidth * 0.144,
                          right: screenWidth * 0.144,
                          top: statusBarHeight + 487,
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  spreadRadius: 3,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 8,
                              ),
                              child: Text(
                                _email.isEmpty ? '-' : _email,
                                style: GoogleFonts.getFont(
                                  'Alexandria',
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ── Field: Alamat ─────────────────────────
                        Positioned(
                          left: screenWidth * 0.147,
                          top: statusBarHeight + 550,
                          child: Text(
                            'Alamat',
                            style: GoogleFonts.getFont(
                              'Alexandria',
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Positioned(
                          left: screenWidth * 0.144,
                          right: screenWidth * 0.144,
                          top: statusBarHeight + 575,
                          child: Container(
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  spreadRadius: 3,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _alamatController,
                              maxLines: 3,
                              style: GoogleFonts.getFont(
                                'Alexandria',
                                fontSize: 14,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 8,
                                ),
                                border: InputBorder.none,
                                hintText: 'Jalan, Kelurahan, Kecamatan...',
                                hintStyle: GoogleFonts.getFont(
                                  'Alexandria',
                                  fontSize: 14,
                                  color: Colors.black38,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ── Tombol Konfirmasi (Simpan) ────────────
                        // FIX 2: dibungkus SingleChildScrollView agar
                        // tidak terpotong di layar kecil
                        Positioned(
                          left: screenWidth * 0.144,
                          right: screenWidth * 0.144,
                          top: statusBarHeight + 690,
                          child: GestureDetector(
                            onTap: _isSaving ? null : _simpanProfil,
                            child: Container(
                              height: 47,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x3F000000),
                                    spreadRadius: 3,
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
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
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Konfirmasi',
                                        style: GoogleFonts.getFont(
                                          'Alexandria',
                                          color: Colors.black,
                                          fontSize: 20,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),

                        // ── Tombol Batal ──────────────────────────
                        Positioned(
                          left: screenWidth * 0.144,
                          right: screenWidth * 0.144,
                          top: statusBarHeight + 751,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 47,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x3F000000),
                                    spreadRadius: 3,
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
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
                                child: Text(
                                  'Batal',
                                  style: GoogleFonts.getFont(
                                    'Alexandria',
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
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
            ),
    );
  }
}