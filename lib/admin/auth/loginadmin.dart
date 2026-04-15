import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/main.dart';

class LoginAdmin extends StatefulWidget {
  const LoginAdmin({super.key});

  @override
  State<LoginAdmin> createState() => _LoginAdminState();
}

class _LoginAdminState extends State<LoginAdmin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD05122), Color(0xFFEE8B2E), Color(0xFFFBA839)],
              stops: [0.17, 0.47, 0.60],
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
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(46),
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

              /// Tombol Masuk sebagai Admin
              Positioned(
                left: screenWidth * 0.065,
                top: screenHeight * 0.410,
                child: Container(
                  width: screenWidth * 0.871,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
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
                      'Masuk sebagai Admin',
                      style: GoogleFonts.getFont(
                        'Alexandria',
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
              ),

              /// Label No Telp / Email
              Positioned(
                left: screenWidth * 0.139,
                top: screenHeight * 0.499,
                child: Text(
                  'Masukkan No Telp / Email',
                  style: GoogleFonts.getFont(
                    'Alexandria',
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),

              /// Input No Telp / Email
              Positioned(
                left: screenWidth * 0.139,
                top: screenHeight * 0.521,
                child: Container(
                  width: screenWidth * 0.714,
                  height: 48,
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
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'Alexandria',
                    ),
                    decoration: InputDecoration(
                      hintText: 'No Telp / Email',
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.3),
                        fontSize: 15,
                        fontFamily: 'Alexandria',
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              /// Label Password
              Positioned(
                left: screenWidth * 0.139,
                top: screenHeight * 0.594,
                child: Text(
                  'Masukkan Password',
                  style: GoogleFonts.getFont(
                    'Alexandria',
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),

              /// Input Password
              Positioned(
                left: screenWidth * 0.139,
                top: screenHeight * 0.616,
                child: Container(
                  width: screenWidth * 0.714,
                  height: 48,
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
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'Alexandria',
                    ),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.3),
                        fontSize: 15,
                        fontFamily: 'Alexandria',
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: InputBorder.none,
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                        child: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.black26,
                          size: 20,
                        ),
                      ),
                      suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 48),
                    ),
                  ),
                ),
              ),

              /// Tombol Masuk Sekarang
              Positioned(
                left: screenWidth * 0.226,
                top: screenHeight * 0.722,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainOwner()),
                    );
                  },
                  child: Container(
                    width: screenWidth * 0.547,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFD05122),
                          Color(0xFFEE8B2E),
                          Color(0xFFFBA839),
                        ],
                        stops: [0.17, 0.47, 0.60],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x3F000000),
                          spreadRadius: 2,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Masuk Sekarang',
                        style: GoogleFonts.getFont(
                          'Alexandria',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              /// Teks "atau lanjut dengan"
              Positioned(
                left: 0,
                right: 0,
                top: screenHeight * 0.802,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 100, height: 1, color: Colors.black26),
                    const SizedBox(width: 10),
                    Text(
                      'atau lanjut dengan',
                      style: GoogleFonts.getFont(
                        'Alexandria',
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(width: 100, height: 1, color: Colors.black26),
                  ],
                ),
              ),

              /// Tombol WhatsApp
              Positioned(
                left: screenWidth * 0.162,
                top: screenHeight * 0.836,
                child: Container(
                  width: screenWidth * 0.309,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8EF),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2Fb7ea103b-0029-4928-969d-053145869a64.png',
                        width: 25,
                        height: 25,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'WhatsApp',
                        style: GoogleFonts.getFont(
                          'Alexandria',
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// Tombol Google
              Positioned(
                right: screenWidth * 0.162,
                top: screenHeight * 0.836,
                child: Container(
                  width: screenWidth * 0.309,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8EF),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2F66ec4761-22fb-443b-a054-d1c1f5f107ba.png',
                        width: 25,
                        height: 25,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Google',
                        style: GoogleFonts.getFont(
                          'Alexandria',
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ],
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