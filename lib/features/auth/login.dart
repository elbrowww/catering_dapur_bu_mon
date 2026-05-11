import 'package:catering_dapur_bu_mon/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/features/auth/daftar.dart';
import 'package:catering_dapur_bu_mon/features/auth/lupa_password.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';
import 'package:catering_dapur_bu_mon/admin/dashboard/dashboard_admin.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController   = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading       = false;

  static const _gradientColors = [
    Color(0xFFD05122),
    Color(0xFFEE8B2E),
    Color(0xFFFBA839),
  ];
  static const _gradientStops = [0.17, 0.47, 0.60];

  late AnimationController _shakeController;
  late Animation<double>   _shakeAnimation;

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
    _identifierController.dispose();
    _passwordController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  // Deteksi otomatis: no_telp (hanya angka) atau nama
  bool _isPhone(String input) => RegExp(r'^[0-9+]+$').hasMatch(input);

  Future<void> _handleLogin() async {
    final identifier = _identifierController.text.trim();
    final password   = _passwordController.text.trim();

    if (identifier.isEmpty) {
      _showSnackbar('Nama atau No Telepon harus diisi');
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
        nama:    !_isPhone(identifier) ? identifier : null,
        noTelp:  _isPhone(identifier)  ? identifier : null,
        password: password,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      final Map<String, dynamic> user = result['user'];
      final String nama = user['nama'] ?? 'Pengguna';
      final String role = (user['role'] ?? 'customer').toString().toLowerCase();

      _showSnackbar('Selamat datang, $nama! 👋', isError: false);

      const List<String> adminRoles = ['admin', 'owner', 'superadmin'];
      final Widget destination = adminRoles.contains(role)
          ? const MainOwner()
          : const MainScreen();
      final Offset slideDirection = adminRoles.contains(role)
          ? const Offset(0.0, -1.0)
          : const Offset(1.0, 0.0);

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => destination,
          transitionsBuilder: (_, animation, __, child) {
            final tween = Tween(begin: slideDirection, end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeInOut));
            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(opacity: animation, child: child),
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
                    color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFD05122)
            : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: SizedBox(
          width: sw,
          height: sh,
          child: Container(
            width: sw,
            height: sh,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: _gradientColors,
                stops: _gradientStops,
              ),
            ),
            child: Stack(
              children: [
                // Panel putih bawah
                Positioned(
                  left: 0,
                  top: sh * 0.372,
                  child: Container(
                    width: sw,
                    height: sh,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(46),
                      ),
                    ),
                  ),
                ),

                // Logo
                Positioned(
                  left: sw * 0.276,
                  top: sh * 0.080,
                  child: Image.asset(
                    "assets/icons/icons.png",
                    width: sw * 0.448,
                    height: sw * 0.448,
                    fit: BoxFit.cover,
                  ),
                ),

                // Tab Masuk & Daftar
                Positioned(
                  left: sw * 0.087,
                  top: sh * 0.397,
                  child: Container(
                    width: sw * 0.826,
                    height: 53,
                    padding: const EdgeInsets.only(
                        top: 4, left: 3, right: 3, bottom: 3),
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
                                colors: _gradientColors,
                                stops: _gradientStops,
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
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const Daftar()),
                            ),
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

                // Label
                Positioned(
                  left: sw * 0.142,
                  top: sh * 0.500,
                  child: Text(
                    'Nama / No Telepon',
                    style: GoogleFonts.alexandria(
                        color: Colors.black, fontSize: 14),
                  ),
                ),

                // Input Nama / No Telepon
                Positioned(
                  left: sw * 0.142,
                  top: sh * 0.524,
                  child: AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      final shake = _shakeAnimation.value == 0
                          ? 0.0
                          : ((_shakeAnimation.value * 4).round().isEven
                              ? 6.0
                              : -6.0);
                      return Transform.translate(
                          offset: Offset(shake, 0), child: child);
                    },
                    child: Container(
                      width: sw * 0.714,
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
                        controller: _identifierController,
                        keyboardType: TextInputType.text,
                        style: GoogleFonts.alexandria(
                            color: Colors.black, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Nama atau No Telepon',
                          hintStyle: GoogleFonts.alexandria(
                            color: Colors.black.withOpacity(0.3),
                            fontSize: 15,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),

                // Label Password
                Positioned(
                  left: sw * 0.142,
                  top: sh * 0.595,
                  child: Text(
                    'Masukkan Password',
                    style: GoogleFonts.alexandria(
                        color: Colors.black, fontSize: 14),
                  ),
                ),

                // Input Password
                Positioned(
                  left: sw * 0.142,
                  top: sh * 0.618,
                  child: AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      final shake = _shakeAnimation.value == 0
                          ? 0.0
                          : ((_shakeAnimation.value * 4).round().isEven
                              ? 6.0
                              : -6.0);
                      return Transform.translate(
                          offset: Offset(shake, 0), child: child);
                    },
                    child: Container(
                      width: sw * 0.714,
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
                            color: Colors.black, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: GoogleFonts.alexandria(
                            color: Colors.black.withOpacity(0.3),
                            fontSize: 15,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          border: InputBorder.none,
                          suffixIcon: GestureDetector(
                            onTap: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            child: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
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

                // Lupa Password
                Positioned(
                  right: sw * 0.142,
                  top: sh * 0.683,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LupaPasswordPage()),
                    ),
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

                // Tombol Masuk
                Positioned(
                  left: sw * 0.226,
                  top: sh * 0.763,
                  child: GestureDetector(
                    onTap: _isLoading ? null : _handleLogin,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: sw * 0.547,
                      height: 45.54,
                      decoration: ShapeDecoration(
                        gradient: LinearGradient(
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
                          stops: _isLoading ? null : _gradientStops,
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