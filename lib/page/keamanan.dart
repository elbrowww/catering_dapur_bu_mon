import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KeamananPage extends StatefulWidget {
  const KeamananPage({super.key});

  @override
  State<KeamananPage> createState() => _KeamananPageState();
}

class _KeamananPageState extends State<KeamananPage> {
  bool _obscurePasswordLama = true;
  bool _obscurePasswordBaru = true;

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
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [

              /// Panel putih bawah
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

              /// Ikon gembok
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
                                    'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMpkHR7SLEvor999HjP%2Fd9a301e2d64a9171618781d7bcf96f3b5983ca8fpadlock%201.png?alt=media&token=96b32c03-5e05-445b-bf68-4353b5ed155e',
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

              /// Judul
              Positioned(
                left: screenWidth * 0.172,
                top: statusBarHeight + 194,
                child: Text(
                  'Keamanan Dan Password',
                  style: GoogleFonts.getFont(
                    'Alexandria',
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              /// Label Password Saat Ini
              Positioned(
                left: screenWidth * 0.139,
                top: statusBarHeight + 300,
                child: Text(
                  'Masukkan Password Saat ini',
                  style: GoogleFonts.getFont(
                    'Alexandria',
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),

              /// Input Password Saat Ini
              Positioned(
                left: screenWidth * 0.142,
                top: statusBarHeight + 326,
                child: Container(
                  width: screenWidth * 0.714,
                  height: 48,
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
                  child: TextField(
                    obscureText: _obscurePasswordLama,
                    style: GoogleFonts.getFont(
                      'Alexandria',
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: '********',
                      hintStyle: GoogleFonts.getFont(
                        'Alexandria',
                        color: Colors.black,
                        fontSize: 15,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      border: InputBorder.none,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscurePasswordLama = !_obscurePasswordLama;
                          });
                        },
                        child: Icon(
                          _obscurePasswordLama
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black26,
                          size: 16,
                        ),
                      ),
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 35,
                      ),
                    ),
                  ),
                ),
              ),

              /// Label Password Baru
              Positioned(
                left: screenWidth * 0.139,
                top: statusBarHeight + 390,
                child: Text(
                  'Masukkan Password Baru',
                  style: GoogleFonts.getFont(
                    'Alexandria',
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),

              /// Input Password Baru
              Positioned(
                left: screenWidth * 0.142,
                top: statusBarHeight + 416,
                child: Container(
                  width: screenWidth * 0.714,
                  height: 48,
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
                  child: TextField(
                    obscureText: _obscurePasswordBaru,
                    style: GoogleFonts.getFont(
                      'Alexandria',
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: '********',
                      hintStyle: GoogleFonts.getFont(
                        'Alexandria',
                        color: Colors.black,
                        fontSize: 15,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      border: InputBorder.none,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscurePasswordBaru = !_obscurePasswordBaru;
                          });
                        },
                        child: Icon(
                          _obscurePasswordBaru
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black26,
                          size: 16,
                        ),
                      ),
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 35,
                      ),
                    ),
                  ),
                ),
              ),

              /// Lupa Password
              Positioned(
                right: screenWidth * 0.139,
                top: statusBarHeight + 475,
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Lupa Password ?',
                    style: GoogleFonts.getFont(
                      'Alexandria',
                      color: const Color(0xFFD05122),
                      fontSize: 10,
                      decoration: TextDecoration.underline,
                      decorationColor: const Color(0xFFD05122),
                    ),
                  ),
                ),
              ),

              /// Tombol Konfirmasi
              Positioned(
                left: screenWidth * 0.144,
                top: statusBarHeight + 590,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: screenWidth * 0.714,
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
                      child: Text(
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

              /// Tombol Batal
              Positioned(
                left: screenWidth * 0.144,
                top: statusBarHeight + 651,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: screenWidth * 0.714,
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
    );
  }
}