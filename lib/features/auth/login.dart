import 'package:catering_dapur_bu_mon/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/features/auth/daftar.dart';
import 'package:catering_dapur_bu_mon/admin/auth/loginadmin.dart';
import 'package:catering_dapur_bu_mon/features/auth/lupa_password.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';

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
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // FUNGSI LOGIN
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validasi
    if (email.isEmpty) {
      _showSnackbar('Email/No Telepon harus diisi');
      return;
    }
    if (password.isEmpty) {
      _showSnackbar('Password harus diisi');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.login(
        email: email,
        password: password,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        _showSnackbar('Login berhasil! Selamat datang ${result['user']['nama']}', isError: false);
        
        // Transisi smooth ke MainScreen
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackbar(e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackbar('Terjadi kesalahan: $e');
      }
    }
  }

  void _showSnackbar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
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
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const LoginAdmin(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);
                              return SlideTransition(position: offsetAnimation, child: child);
                            },
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
                          child: Center(
                            child: Text(
                              'Masuk',
                              style: GoogleFonts.alexandria(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                      /// Tab Daftar (tidak aktif) - dengan transisi smooth
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => const Daftar(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(-1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;
                                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);
                                  return SlideTransition(position: offsetAnimation, child: child);
                                },
                                transitionDuration: const Duration(milliseconds: 400),
                              ),
                            );
                          },
                          child: Center(
                            child: Opacity(
                              opacity: 0.50,
                              child: Text(
                                'Daftar',
                                style: GoogleFonts.alexandria(
                                  color: const Color(0xFFD9D9D9),
                                  fontSize: 24,
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

              /// Label Email / No Telp
              Positioned(
                left: screenWidth * 0.142,
                top: screenHeight * 0.500,
                child: Text(
                  'Masukkan Email / No Telp',
                  style: GoogleFonts.alexandria(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),

              /// Input Email / No Telp
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
                    style: GoogleFonts.alexandria(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Email / No Telepon',
                      hintStyle: GoogleFonts.alexandria(
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
                  style: GoogleFonts.alexandria(
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
                    style: GoogleFonts.alexandria(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: GoogleFonts.alexandria(
                        color: Colors.black.withOpacity(0.3),
                        fontSize: 15,
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
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const LupaPasswordPage(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(position: offsetAnimation, child: child);
                        },
                        transitionDuration: const Duration(milliseconds: 300),
                      ),
                    );
                  },
                  child: Text(
                    'Lupa Password ?',
                    style: GoogleFonts.alexandria(
                      color: const Color(0xFFD05122),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: const Color(0xFFD05122),
                    ),
                  ),
                ),
              ),

              /// Tombol Masuk Sekarang
              Positioned(
                left: screenWidth * 0.226,
                top: screenHeight * 0.763,
                child: GestureDetector(
                  onTap: _isLoading ? null : _handleLogin,
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
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Masuk Sekarang',
                              style: GoogleFonts.alexandria(
                                color: Colors.white,
                                fontSize: 18,
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