import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'editprofil.dart';
import 'login.dart';
import 'keamanan.dart'; // ← tambahan import

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 402,
      height: 874,
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
              left: 144,
              top: 133,
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
              left: 98,
              top: 251,
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
              top: 303,
              child: Container(
                width: 402,
                height: 622,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

            // ── Tombol Logout ─────────────────────────────────────
            Positioned(
              left: 58,
              top: 710,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const Login()),
                    (route) => false,
                  );
                },
                child: Container(
                  width: 287,
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
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 107,
                        top: 11,
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
                    ],
                  ),
                ),
              ),
            ),

            // ── Label "Akun Saya" ─────────────────────────────────
            Positioned(
              left: 44,
              top: 346,
              child: SizedBox(
                width: 122,
                height: 28,
                child: Text(
                  'Akun Saya',
                  style: GoogleFonts.getFont(
                    'Alexandria',
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
            ),

            // ── Card Edit Profil ──────────────────────────────────
            Positioned(
              left: 45,
              top: 390,
              child: Container(
                width: 313,
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
              left: 63,
              top: 407,
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
              left: 73,
              top: 417,
              child: Image.network(
                'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMpkHR7SLEvor999HjP%2F316b1609f20a8554436bf178b307cada634003f6user%201.png?alt=media&token=0dd54a77-ed31-408c-9241-66cd7452900f',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 146,
              top: 413,
              child: SizedBox(
                width: 164,
                height: 57,
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
            ),
            Positioned(
              left: 146,
              top: 438,
              child: SizedBox(
                width: 188,
                height: 57,
                child: Text(
                  'Ubah nama, alamat, foto, dll',
                  style: GoogleFonts.getFont(
                    'Alexandria',
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            // ── Panah Edit Profil (klik → EditProfilPage) ─────────
            Positioned(
              left: 318,
              top: 424,
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
              left: 45,
              top: 537,
              child: Container(
                width: 313,
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
              left: 60,
              top: 556,
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
              left: 59,
              top: 551,
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
              left: 146,
              top: 553,
              child: SizedBox(
                width: 164,
                height: 32,
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
            ),
            Positioned(
              left: 146,
              top: 605,
              child: SizedBox(
                width: 188,
                height: 32,
                child: Text(
                  'Ubah Password',
                  style: GoogleFonts.getFont(
                    'Alexandria',
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            // ── Panah Keamanan (klik → KeamananPage) ─────────────
            Positioned(
              left: 319,
              top: 574,
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
              left: 24,
              top: 62,
              child: Container(
                width: 355,
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
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 144,
                      top: 10,
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