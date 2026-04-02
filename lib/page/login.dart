import 'package:catering_dapur_bu_mon/main.dart';
import 'package:flutter/material.dart';
import 'daftar.dart';
import 'beranda.dart';
import '../admin/loginadmin.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  int _logoTapCount = 0;

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

              /// Logo (klik 3x → Login Admin)
              Positioned(
                left: screenWidth * 0.276,
                top: screenHeight * 0.080,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _logoTapCount++;
                      if (_logoTapCount >= 3) {
                        _logoTapCount = 0;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginAdmin(),
                          ),
                        );
                      }
                    });
                  },
                  child: Image.asset(
                    "assets/icons/icons.png",
                    width: screenWidth * 0.448,
                    height: screenWidth * 0.448,
                    fit: BoxFit.cover,
                  ),
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
                      /// Tab Masuk (aktif)
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
                          child: const Center(
                            child: Text(
                              'Masuk',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontFamily: 'Alexandria',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                      /// Tab Daftar (tidak aktif)
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const Daftar()),
                            );
                          },
                          child: const Center(
                            child: Opacity(
                              opacity: 0.50,
                              child: Text(
                                'Daftar',
                                style: TextStyle(
                                  color: Color(0xFFD9D9D9),
                                  fontSize: 24,
                                  fontFamily: 'Alexandria',
                                  fontWeight: FontWeight.w400,
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

              /// Label No Telp / Email
              Positioned(
                left: screenWidth * 0.142,
                top: screenHeight * 0.500,
                child: const Text(
                  'Masukkan No Telp / Email',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Alexandria',
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
                child: const Text(
                  'Masukkan Password',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Alexandria',
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      border: InputBorder.none,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        child: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.black26,
                          size: 18,
                        ),
                      ),
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 48,
                      ),
                    ),
                  ),
                ),
              ),

              /// Lupa Password
              Positioned(
                right: screenWidth * 0.142,
                top: screenHeight * 0.673,
                child: GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Lupa Password ?',
                    style: TextStyle(
                      color: Color(0xFFD05122),
                      fontSize: 12,
                      fontFamily: 'Alexandria',
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFFD05122),
                    ),
                  ),
                ),
              ),

              /// Tombol Masuk Sekarang
              Positioned(
                left: screenWidth * 0.226,
                top: screenHeight * 0.763,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(),
                      ),
                    );
                  },
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
                    child: const Center(
                      child: Text(
                        'Masuk Sekarang',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Alexandria',
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