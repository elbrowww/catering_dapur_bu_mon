import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/features/auth/verifikasi_kode.dart'; // ← tambah import

class LupaPasswordPage extends StatefulWidget {
  const LupaPasswordPage({super.key});

  @override
  State<LupaPasswordPage> createState() => _LupaPasswordPageState();
}

class _LupaPasswordPageState extends State<LupaPasswordPage> {
  int _metodeTerpilih = -1; // 0 = No Telp, 1 = Email

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFAC3715), Color(0xFFD05122), Color(0xFFEE8B2E)],
            stops: [0.21, 0.56, 0.83],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [

            // ── Panel putih bawah ─────────────────────────
            Positioned(
              left: 0,
              top: statusBarHeight + 251,
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

            // ── Ikon gembok ───────────────────────────────
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
                      left: 15,
                      top: 15,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(46),
                        clipBehavior: Clip.hardEdge,
                        child: SizedBox.square(
                          dimension: 120,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 8,
                                top: 8,
                                width: 120,
                                height: 120,
                                child: Image.network(
                                  'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMpkHR7SLEvor999HjP%2Fd9a301e2d64a9171618781d7bcf96f3b5983ca8fpadlock%201.png?alt=media&token=04614254-2b3b-4008-b6f7-f68f1986809f',
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.none,
                                  scale: 4.267,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Judul "Lupa Password" ─────────────────────
            Positioned(
              left: 0,
              right: 0,
              top: statusBarHeight + 194,
              child: Text(
                'Lupa Password',
                textAlign: TextAlign.center,
                style: GoogleFonts.alexandria(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // ── Sub judul ─────────────────────────────────
            Positioned(
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
              top: statusBarHeight + 222,
              child: Text(
                'Ikuti langkah untuk membuat Password Baru',
                textAlign: TextAlign.center,
                style: GoogleFonts.alexandria(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            ),

            // ── Indikator langkah (1, 2, 3) ───────────────
            Positioned(
              left: screenWidth * 0.15,
              right: screenWidth * 0.15,
              top: statusBarHeight + 280,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Step 1 (aktif - kuning)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCE0A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        '1',
                        style: GoogleFonts.alexandria(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Garis
                  Expanded(
                    child: Container(
                      height: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  // Step 2
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F4EE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        '2',
                        style: GoogleFonts.alexandria(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  // Garis
                  Expanded(
                    child: Container(
                      height: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  // Step 3
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F4EE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        '3',
                        style: GoogleFonts.alexandria(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Label langkah ──────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              top: statusBarHeight + 328,
              child: Text(
                'Langkah 1 dari 3 - Pilih Metode',
                textAlign: TextAlign.center,
                style: GoogleFonts.alexandria(
                  color: Colors.black.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ),

            // ── Deskripsi ─────────────────────────────────
            Positioned(
              left: screenWidth * 0.1,
              right: screenWidth * 0.1,
              top: statusBarHeight + 350,
              child: Text(
                'Pilih cara menerima kode verifikasi untuk reset password kamu',
                textAlign: TextAlign.center,
                style: GoogleFonts.alexandria(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // ── Pilihan metode (No Telp & Email) ───────────
            Positioned(
              left: screenWidth * 0.1,
              right: screenWidth * 0.1,
              top: statusBarHeight + 420,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // No Telp
                  GestureDetector(
                    onTap: () => setState(() => _metodeTerpilih = 0),
                    child: Container(
                      width: 130,
                      height: 114,
                      decoration: BoxDecoration(
                        color: _metodeTerpilih == 0
                            ? const Color(0xFFFFCE0A).withOpacity(0.3)
                            : const Color(0xFFF9F4EE),
                        borderRadius: BorderRadius.circular(16),
                        border: _metodeTerpilih == 0
                            ? Border.all(
                                color: const Color(0xFFFFCE0A), width: 2)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMpkHR7SLEvor999HjP%2F7c0ceaeb5d2a85b30fea8aaad333db8896745d7dimage%2019.png?alt=media&token=8e8261d6-d597-498e-8e7d-707d890ba9d3',
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No Telp',
                            style: GoogleFonts.alexandria(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '0812*******',
                            style: GoogleFonts.alexandria(
                              color: Colors.black.withOpacity(0.8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Email
                  GestureDetector(
                    onTap: () => setState(() => _metodeTerpilih = 1),
                    child: Container(
                      width: 130,
                      height: 114,
                      decoration: BoxDecoration(
                        color: _metodeTerpilih == 1
                            ? const Color(0xFFFFCE0A).withOpacity(0.3)
                            : const Color(0xFFF9F4EE),
                        borderRadius: BorderRadius.circular(16),
                        border: _metodeTerpilih == 1
                            ? Border.all(
                                color: const Color(0xFFFFCE0A), width: 2)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMpkHR7SLEvor999HjP%2F9df3eed280f06bfe7d0979f21b474512bf9b4ce1image%2018.png?alt=media&token=3ac50c0a-0006-4396-9c65-83fcda4b955f',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Email',
                            style: GoogleFonts.alexandria(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Tombol Kirim Kode Verifikasi ───────────────
            Positioned(
              left: screenWidth * 0.144,
              right: screenWidth * 0.144,
              top: statusBarHeight + 590,
              child: GestureDetector(
                onTap: () {
                  if (_metodeTerpilih == -1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Pilih metode verifikasi terlebih dahulu!',
                          style: GoogleFonts.alexandria(color: Colors.white),
                        ),
                        backgroundColor: const Color(0xFFD05122),
                      ),
                    );
                    return;
                  }
                  // ← navigasi ke langkah 2
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VerifikasiKodePage(
                        metode: _metodeTerpilih == 0 ? 'telp' : 'email',
                      ),
                    ),
                  );
                },
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
                      'Kirim Kode Verifikasi',
                      style: GoogleFonts.alexandria(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Tombol Batal ───────────────────────────────
            Positioned(
              left: screenWidth * 0.144,
              right: screenWidth * 0.144,
              top: statusBarHeight + 650,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
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
                      style: GoogleFonts.alexandria(
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
    );
  }
}