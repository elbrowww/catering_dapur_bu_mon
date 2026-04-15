import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/features/auth/login.dart';

class Daftar extends StatefulWidget {
  const Daftar({super.key});

  @override
  State<Daftar> createState() => _DaftarState();
}

class _DaftarState extends State<Daftar> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _konfirmasiController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureKonfirmasi = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Container(
          width: screenWidth,
          height: screenHeight,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.45, 1.25),
              end: Alignment(0.45, -0.64),
              colors: [Color(0xFFD05122), Color(0xFFEE8B2E), Color(0xFFFBA839)],
            ),
          ),
          child: Stack(
            children: [

              /// Background putih bawah
              Positioned(
                left: 0,
                top: screenHeight * 0.372,
                child: Container(
                  width: screenWidth,
                  height: screenHeight,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(46),
                    ),
                  ),
                ),
              ),

              /// Logo
              Positioned(
                left: screenWidth * 0.276,
                top: screenHeight * 0.080,
                child: Image.asset(
                  "assets/icons/icons.png",
                  width: screenWidth * 0.448,
                  height: screenWidth * 0.448,
                  fit: BoxFit.cover,
                ),
              ),

              /// Tab Masuk & Daftar
              Positioned(
                left: screenWidth * 0.087,
                top: screenHeight * 0.397,
                child: Container(
                  width: screenWidth * 0.826,
                  height: 53,
                  padding: const EdgeInsets.only(top: 4, left: 3, right: 3, bottom: 3),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFFF0D8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      /// Tab Masuk (tidak aktif)
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const Login()),
                            );
                          },
                          child: Center(
                            child: Opacity(
                              opacity: 0.50,
                              child: Text(
                                'Masuk',
                                style: GoogleFonts.alexandria( // ✅
                                  color: const Color(0xFFD9D9D9),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      /// Tab Daftar (aktif)
                      Expanded(
                        child: Container(
                          height: 45.54,
                          decoration: ShapeDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment(0.45, 1.25),
                              end: Alignment(0.45, -0.64),
                              colors: [Color(0xFFD05122), Color(0xFFEE8B2E), Color(0xFFFBA839)],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Daftar',
                              style: GoogleFonts.alexandria( // ✅
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// Label No Telp / Email
              Positioned(
                left: screenWidth * 0.142,
                top: screenHeight * 0.500,
                child: Text(
                  'Masukkan No Telp / Email',
                  style: GoogleFonts.alexandria( // ✅
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),

              /// Input No Telp / Email
              Positioned(
                left: screenWidth * 0.142,
                top: screenHeight * 0.524,
                child: Container(
                  width: screenWidth * 0.714,
                  height: 48,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.alexandria( // ✅
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'No Telp / Email',
                      hintStyle: GoogleFonts.alexandria( // ✅
                        color: Colors.black.withOpacity(0.3),
                        fontSize: 15,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              /// Label Password
              Positioned(
                left: screenWidth * 0.142,
                top: screenHeight * 0.585,
                child: Text(
                  'Masukkan Password',
                  style: GoogleFonts.alexandria( // ✅
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),

              /// Input Password
              Positioned(
                left: screenWidth * 0.142,
                top: screenHeight * 0.608,
                child: Container(
                  width: screenWidth * 0.714,
                  height: 48,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textAlignVertical: TextAlignVertical.center,
                    style: GoogleFonts.alexandria( // ✅
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: GoogleFonts.alexandria( // ✅
                        color: Colors.black.withOpacity(0.3),
                        fontSize: 15,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      border: InputBorder.none,
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                        child: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.black26,
                          size: 18,
                        ),
                      ),
                      suffixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 48),
                    ),
                  ),
                ),
              ),

              /// Label Konfirmasi Password
              Positioned(
                left: screenWidth * 0.142,
                top: screenHeight * 0.666,
                child: Text(
                  'Masukkan Ulang Password',
                  style: GoogleFonts.alexandria( // ✅
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),

              /// Input Konfirmasi Password
              Positioned(
                left: screenWidth * 0.142,
                top: screenHeight * 0.689,
                child: Container(
                  width: screenWidth * 0.714,
                  height: 48,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _konfirmasiController,
                    obscureText: _obscureKonfirmasi,
                    textAlignVertical: TextAlignVertical.center,
                    style: GoogleFonts.alexandria( // ✅
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: GoogleFonts.alexandria( // ✅
                        color: Colors.black.withOpacity(0.3),
                        fontSize: 15,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      border: InputBorder.none,
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _obscureKonfirmasi = !_obscureKonfirmasi),
                        child: Icon(
                          _obscureKonfirmasi ? Icons.visibility_off : Icons.visibility,
                          color: Colors.black26,
                          size: 18,
                        ),
                      ),
                      suffixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 48),
                    ),
                  ),
                ),
              ),

              /// Tombol Konfirmasi
              Positioned(
                left: screenWidth * 0.226,
                top: screenHeight * 0.780,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: screenWidth * 0.547,
                    height: 45.54,
                    decoration: ShapeDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment(0.45, 1.25),
                        end: Alignment(0.45, -0.64),
                        colors: [Color(0xFFD05122), Color(0xFFEE8B2E), Color(0xFFFBA839)],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Konfirmasi',
                        style: GoogleFonts.alexandria( // ✅
                          color: Colors.white,
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
      ),
    );
  }
}