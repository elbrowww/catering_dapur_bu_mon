import 'package:catering_dapur_bu_mon/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/features/auth/daftar.dart';
import 'package:catering_dapur_bu_mon/features/auth/lupa_password.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';

// ⚠️ Sesuaikan import halaman admin kamu di sini
import 'package:catering_dapur_bu_mon/admin/dashboard/dashboard_admin.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Animasi controller untuk efek shake saat error
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  // =============================================
  // FUNGSI LOGIN — AUTO DETECT ROLE
  // =============================================
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // --- Validasi input ---
    if (email.isEmpty) {
      _showSnackbar('Email/No Telepon harus diisi');
      _shakeController.forward(from: 0);
      return;
    }
    if (password.isEmpty) {
      _showSnackbar('Password harus diisi');
      _shakeController.forward(from: 0);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      // --- Ambil data user dari response ---
      final Map<String, dynamic> user = result['user'];
      final String nama = user['nama'] ?? 'Pengguna';

      // ⚠️ Sesuaikan nama field role dari API kamu
      // Contoh: 'role', 'tipe', 'jabatan', 'level', dsb.
      final String role = (user['role'] ?? 'customer').toString().toLowerCase();

      _showSnackbar(
        'Selamat datang, $nama! 👋',
        isError: false,
      );

      // --- Tentukan halaman tujuan berdasarkan role ---
      Widget destination;
      Offset slideDirection;

      // Role yang dianggap sebagai ADMIN/OWNER
      // Tambahkan role lain sesuai kebutuhan
      const List<String> adminRoles = ['admin', 'owner', 'superadmin'];

      if (adminRoles.contains(role)) {
        // → Halaman Admin
        destination = const MainOwner();
        slideDirection = const Offset(0.0, -1.0); // slide dari atas (beda arah, biar berasa beda)
      } else {
        // → Halaman Customer (default)
        destination = const MainScreen();
        slideDirection = const Offset(1.0, 0.0); // slide dari kanan
      }

      // --- Navigasi dengan transisi smooth ---
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => destination,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(begin: slideDirection, end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeInOut));
            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 450),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackbar(e.message);
      _shakeController.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackbar('Terjadi kesalahan. Coba lagi.');
      _shakeController.forward(from: 0);
    }
  }

  void _showSnackbar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.alexandria(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFD05122) : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // =============================================
  // BUILD
  // =============================================
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: SizedBox(
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

                // ── Background putih bawah ──
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

                // ── Logo ──
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

                // ── Tab Masuk & Daftar ──
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

                        // Tab Masuk (aktif)
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

                        // Tab Daftar (tidak aktif)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) =>
                                      const Daftar(),
                                  transitionsBuilder:
                                      (context, animation, secondaryAnimation, child) {
                                    const begin = Offset(-1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;
                                    final tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));
                                    return SlideTransition(
                                      position: animation.drive(tween),
                                      child: child,
                                    );
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

                // ── Label Email / No Telp ──
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

                // ── Input Email / No Telp ──
                Positioned(
                  left: screenWidth * 0.142,
                  top: screenHeight * 0.524,
                  child: AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      final shake = _shakeAnimation.value == 0
                          ? 0.0
                          : ((_shakeAnimation.value * 4).round().isEven ? 6.0 : -6.0);
                      return Transform.translate(
                        offset: Offset(shake, 0),
                        child: child,
                      );
                    },
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
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Label Password ──
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

                // ── Input Password ──
                Positioned(
                  left: screenWidth * 0.142,
                  top: screenHeight * 0.608,
                  child: AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      final shake = _shakeAnimation.value == 0
                          ? 0.0
                          : ((_shakeAnimation.value * 4).round().isEven ? 6.0 : -6.0);
                      return Transform.translate(
                        offset: Offset(shake, 0),
                        child: child,
                      );
                    },
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
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                ),

                // ── Lupa Password ──
                Positioned(
                  right: screenWidth * 0.142,
                  top: screenHeight * 0.673,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              const LupaPasswordPage(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            final tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: Curves.easeInOut));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
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

                // ── Tombol Masuk Sekarang ──
                Positioned(
                  left: screenWidth * 0.226,
                  top: screenHeight * 0.763,
                  child: GestureDetector(
                    onTap: _isLoading ? null : _handleLogin,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: screenWidth * 0.547,
                      height: 45.54,
                      decoration: ShapeDecoration(
                        gradient: LinearGradient(
                          begin: const Alignment(0.45, 1.25),
                          end: const Alignment(0.45, -0.64),
                          colors: _isLoading
                              ? [
                                  const Color(0xFFD05122).withOpacity(0.6),
                                  const Color(0xFFEE8B2E).withOpacity(0.6),
                                  const Color(0xFFFBA839).withOpacity(0.6),
                                ]
                              : const [
                                  Color(0xFFD05122),
                                  Color(0xFFEE8B2E),
                                  Color(0xFFFBA839),
                                ],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x4FD05122),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
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
      ),
    );
  }
}