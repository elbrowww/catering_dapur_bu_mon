import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'editprofil.dart';
import 'login.dart';
import 'keamanan.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

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

            // ── Nama pengguna ─────────────────────────────────────
            Positioned(
              left: screenWidth * 0.243,
              top: statusBarHeight + 188,
              child: Text(
                'Christoper Colombus',
                style: GoogleFonts.getFont(
                  'Alexandria',
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

            // ── Tombol Logout ─────────────────────────────────────
            Positioned(
              left: screenWidth * 0.144,
              top: statusBarHeight + 650,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const Login()),
                    (route) => false,
                  );
                },
                child: Container(
                  width: screenWidth * 0.714,
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
                      style: GoogleFonts.getFont(
                        'Alexandria',
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Label "Akun Saya" ─────────────────────────────────
            Positioned(
              left: screenWidth * 0.109,
              top: statusBarHeight + 283,
              child: Text(
                'Akun Saya',
                style: GoogleFonts.getFont(
                  'Alexandria',
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),

            // ── Card Edit Profil ──────────────────────────────────
            Positioned(
              left: screenWidth * 0.112,
              top: statusBarHeight + 327,
              child: Container(
                width: screenWidth * 0.779,
                height: 104,
                clipBehavior: Clip.hardEdge,
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
              ),
            ),
            Positioned(
              left: screenWidth * 0.157,
              top: statusBarHeight + 344,
              child: Container(
                width: 70,
                height: 70,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            Positioned(
              left: screenWidth * 0.182,
              top: statusBarHeight + 354,
              child: Image.network(
                'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMpkHR7SLEvor999HjP%2F316b1609f20a8554436bf178b307cada634003f6user%201.png?alt=media&token=0dd54a77-ed31-408c-9241-66cd7452900f',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: screenWidth * 0.363,
              top: statusBarHeight + 350,
              child: Text(
                'Edit Profil',
                style: GoogleFonts.getFont(
                  'Alexandria',
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              left: screenWidth * 0.363,
              top: statusBarHeight + 375,
              child: Text(
                'Ubah nama, alamat, foto, dll',
                style: GoogleFonts.getFont(
                  'Alexandria',
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ),

            // ── Panah Edit Profil ─────────────────────────────────
            Positioned(
              left: screenWidth * 0.791,
              top: statusBarHeight + 361,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfilPage(),
                    ),
                  );
                },
                child: Transform.rotate(
                  angle: 180 * pi / 180,
                  child: Container(
                    width: 30,
                    height: 30,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: 9,
                          top: 7,
                          child: Transform.rotate(
                            angle: 180 * pi / 180,
                            child: Image.network(
                              'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2Fcd195282-f4ee-433e-af97-7beeb4fbc7f4.png',
                              width: 9,
                              height: 16,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Card Keamanan & Password ──────────────────────────
            Positioned(
              left: screenWidth * 0.112,
              top: statusBarHeight + 474,
              child: Container(
                width: screenWidth * 0.779,
                height: 104,
                clipBehavior: Clip.hardEdge,
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
              ),
            ),
            Positioned(
              left: screenWidth * 0.149,
              top: statusBarHeight + 493,
              child: Container(
                width: 70,
                height: 70,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8EF),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            Positioned(
              left: screenWidth * 0.147,
              top: statusBarHeight + 488,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(46),
                clipBehavior: Clip.hardEdge,
                child: SizedBox.square(
                  dimension: 70,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 5,
                        top: 5,
                        width: 70,
                        height: 70,
                        child: Image.network(
                          'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMpkHR7SLEvor999HjP%2Fd9a301e2d64a9171618781d7bcf96f3b5983ca8fpadlock%201.png?alt=media&token=c787a911-aa18-4b7d-90ba-f77d1988788c',
                          width: 70,
                          height: 70,
                          fit: BoxFit.none,
                          scale: 7.314,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: screenWidth * 0.363,
              top: statusBarHeight + 490,
              child: Text(
                'Keamanan dan Password',
                style: GoogleFonts.getFont(
                  'Alexandria',
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              left: screenWidth * 0.363,
              top: statusBarHeight + 542,
              child: Text(
                'Ubah Password',
                style: GoogleFonts.getFont(
                  'Alexandria',
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ),

            // ── Panah Keamanan ────────────────────────────────────
            Positioned(
              left: screenWidth * 0.794,
              top: statusBarHeight + 511,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const KeamananPage(),
                    ),
                  );
                },
                child: Transform.rotate(
                  angle: 180 * pi / 180,
                  child: Container(
                    width: 30,
                    height: 30,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: 9,
                          top: 7,
                          child: Transform.rotate(
                            angle: 180 * pi / 180,
                            child: Image.network(
                              'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2F24228ec4-7dfe-4878-a30e-ae6b434c104c.png',
                              width: 9,
                              height: 16,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Header "Profil" ───────────────────────────────────
            Positioned(
              left: screenWidth * 0.060,
              top: statusBarHeight + 14,
              child: Container(
                width: screenWidth * 0.883,
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
                    style: GoogleFonts.getFont(
                      'Alexandria',
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
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