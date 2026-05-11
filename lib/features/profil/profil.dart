import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/features/profil/editprofil.dart';
import 'package:catering_dapur_bu_mon/features/auth/login.dart';
import 'package:catering_dapur_bu_mon/features/profil/keamanan.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String _nama = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  Future<void> _loadProfil() async {
    try {
      final data = await ApiService.getProfil();
      setState(() {
        _nama = data['nama'] ?? '';
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

  // ── Popup konfirmasi logout ───────────────────────────────
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon dalam lingkaran gradasi
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFAC3715), Color(0xFFD05122), Color(0xFFEE8B2E)],
                    stops: [0.21, 0.56, 0.83],
                  ),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: Colors.white, size: 36),
              ),
              const SizedBox(height: 20),

              Text(
                'Yakin mau Logout?',
                style: GoogleFonts.alexandria(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1818)),
              ),
              const SizedBox(height: 10),

              Text(
                'Kamu akan keluar dari akun ini.\nSampai jumpa lagi di Dapur Bu Mon! 👋',
                style: GoogleFonts.alexandria(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Tombol Logout
              GestureDetector(
                onTap: () async {
                  Navigator.pop(context); // tutup dialog
                  await ApiService.logout();
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const Login()),
                      (route) => false,
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD05122), Color(0xFFEE8B2E), Color(0xFFFBA839)],
                      stops: [0.17, 0.55, 0.85],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Ya, Logout',
                      style: GoogleFonts.alexandria(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Tombol Batal
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD05122), width: 1.5),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      'Batal',
                      style: GoogleFonts.alexandria(
                          color: const Color(0xFFD05122),
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
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
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
        child: Stack(
          clipBehavior: Clip.none,
          children: [

            // ── Header "Profil" ───────────────────────────────────
            Positioned(
              left: screenWidth * 0.060,
              top: statusBarHeight + 14,
              right: screenWidth * 0.060,
              child: Container(
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
                    'Profil',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.alexandria(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // ── Foto profil ──────────────────────────────────────
            Positioned(
              left: screenWidth * 0.358,
              top: statusBarHeight + 70,
              child: Container(
                width: 114,
                height: 114,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(78),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Image.network(
                        'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2F318c088e-cfcf-4c5f-8b12-6758519bb506.png',
                        width: 93,
                        height: 93,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Nama pengguna (dari API) ─────────────────────────
            Positioned(
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
              top: statusBarHeight + 188,
              child: _isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : Text(
                      _nama.isEmpty ? '-' : _nama,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.alexandria(
                        color: Colors.black,
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
            ),

            // ── Panel putih bawah ─────────────────────────────────
            Positioned(
              left: 0,
              top: statusBarHeight + 240,
              child: Container(
                width: screenWidth,
                height: screenHeight,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

            // ── Label "Akun Saya" ─────────────────────────────────
            Positioned(
              left: screenWidth * 0.109,
              top: statusBarHeight + 283,
              child: Text(
                'Akun Saya',
                style: GoogleFonts.alexandria(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),

            // ── Card Edit Profil ──────────────────────────────────
            Positioned(
              left: screenWidth * 0.056,
              right: screenWidth * 0.056,
              top: statusBarHeight + 327,
              child: GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfilPage(),
                    ),
                  );
                  _loadProfil();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMpkHR7SLEvor999HjP%2F316b1609f20a8554436bf178b307cada634003f6user%201.png?alt=media&token=0dd54a77-ed31-408c-9241-66cd7452900f',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Profil',
                              style: GoogleFonts.alexandria(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Ubah nama, alamat, foto, dll',
                              style: GoogleFonts.alexandria(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.black54),
                    ],
                  ),
                ),
              ),
            ),

            // ── Card Keamanan & Password ──────────────────────────
            Positioned(
              left: screenWidth * 0.056,
              right: screenWidth * 0.056,
              top: statusBarHeight + 457,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const KeamananPage(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8EF),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMpkHR7SLEvor999HjP%2Fd9a301e2d64a9171618781d7bcf96f3b5983ca8fpadlock%201.png?alt=media&token=c787a911-aa18-4b7d-90ba-f77d1988788c',
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Keamanan dan Password',
                              style: GoogleFonts.alexandria(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Ubah Password',
                              style: GoogleFonts.alexandria(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.black54),
                    ],
                  ),
                ),
              ),
            ),

            // ── Tombol Logout ─────────────────────────────────────
            Positioned(
              left: screenWidth * 0.144,
              right: screenWidth * 0.144,
              top: statusBarHeight + 620,
              child: GestureDetector(
                onTap: () => _showLogoutDialog(),
                child: Container(
                  height: 47,
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
                    child: Text(
                      'Logout',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.alexandria(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}