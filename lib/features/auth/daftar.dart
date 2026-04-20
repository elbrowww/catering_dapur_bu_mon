import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/features/auth/login.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';

class Daftar extends StatefulWidget {
  const Daftar({super.key});

  @override
  State<Daftar> createState() => _DaftarState();
}

class _DaftarState extends State<Daftar> {
  // CONTROLLERS untuk semua field yang dibutuhkan backend
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _noTelpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _konfirmasiController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureKonfirmasi = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noTelpController.dispose();
    _alamatController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  // FUNGSI REGISTER
  Future<void> _handleRegister() async {
    final nama = _namaController.text.trim();
    final email = _emailController.text.trim();
    final noTelp = _noTelpController.text.trim();
    final alamat = _alamatController.text.trim();
    final password = _passwordController.text.trim();
    final konfirmasi = _konfirmasiController.text.trim();

    // Validasi
    if (nama.isEmpty) {
      _showSnackbar('Nama lengkap harus diisi');
      return;
    }
    if (email.isEmpty) {
      _showSnackbar('Email harus diisi');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _showSnackbar('Email tidak valid');
      return;
    }
    if (noTelp.isEmpty) {
      _showSnackbar('No telepon harus diisi');
      return;
    }
    if (alamat.isEmpty) {
      _showSnackbar('Alamat harus diisi');
      return;
    }
    if (password.isEmpty) {
      _showSnackbar('Password harus diisi');
      return;
    }
    if (password.length < 6) {
      _showSnackbar('Password minimal 6 karakter');
      return;
    }
    if (password != konfirmasi) {
      _showSnackbar('Password dan konfirmasi password tidak sama');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.register(
        nama: nama,
        email: email,
        noTelp: noTelp,
        alamat: alamat,
        password: password,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        _showSnackbar('Registrasi berhasil! Silakan login.', isError: false);
        
        // Transisi smooth ke halaman Login dengan efek geser
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const Login(),
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
              /// Background putih bawah (diperpanjang karena form lebih banyak)
              Positioned(
                left: 0,
                top: screenHeight * 0.25,
                child: Container(
                  width: screenWidth,
                  height: screenHeight * 0.85,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(46),
                    ),
                  ),
                ),
              ),

              /// Logo (diperkecil dan diposisikan lebih atas)
              Positioned(
                left: screenWidth * 0.35,
                top: screenHeight * 0.04,
                child: Image.asset(
                  "assets/icons/icons.png",
                  width: screenWidth * 0.3,
                  height: screenWidth * 0.3,
                  fit: BoxFit.cover,
                ),
              ),

              /// Tab Masuk & Daftar (SEJAJAR dengan transisi geser)
              Positioned(
                left: screenWidth * 0.087,
                top: screenHeight * 0.20,
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
                      /// Tab Masuk (tidak aktif) - dengan transisi geser ke kiri
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => const Login(),
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
                                'Masuk',
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
                              style: GoogleFonts.alexandria(
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

              /// FORM REGISTRASI (SingleChildScrollView agar bisa scroll)
              Positioned(
                left: screenWidth * 0.142,
                top: screenHeight * 0.28,
                right: screenWidth * 0.142,
                bottom: 20,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Nama Lengkap
                      Text(
                        'Nama Lengkap',
                        style: GoogleFonts.alexandria(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: double.infinity,
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
                          controller: _namaController,
                          style: GoogleFonts.alexandria(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Nama Lengkap',
                            hintStyle: GoogleFonts.alexandria(
                              color: Colors.black.withOpacity(0.3),
                              fontSize: 15,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// Email
                      Text(
                        'Email',
                        style: GoogleFonts.alexandria(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: double.infinity,
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
                            hintText: 'Email',
                            hintStyle: GoogleFonts.alexandria(
                              color: Colors.black.withOpacity(0.3),
                              fontSize: 15,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// No Telepon
                      Text(
                        'No Telepon',
                        style: GoogleFonts.alexandria(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: double.infinity,
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
                          controller: _noTelpController,
                          keyboardType: TextInputType.phone,
                          style: GoogleFonts.alexandria(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: 'No Telepon',
                            hintStyle: GoogleFonts.alexandria(
                              color: Colors.black.withOpacity(0.3),
                              fontSize: 15,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// Alamat
                      Text(
                        'Alamat',
                        style: GoogleFonts.alexandria(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: double.infinity,
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
                          controller: _alamatController,
                          maxLines: 2,
                          style: GoogleFonts.alexandria(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Alamat Lengkap',
                            hintStyle: GoogleFonts.alexandria(
                              color: Colors.black.withOpacity(0.3),
                              fontSize: 15,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// Password
                      Text(
                        'Masukkan Password',
                        style: GoogleFonts.alexandria(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: double.infinity,
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
                          style: GoogleFonts.alexandria(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Password (min 6 karakter)',
                            hintStyle: GoogleFonts.alexandria(
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
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// Konfirmasi Password
                      Text(
                        'Masukkan Ulang Password',
                        style: GoogleFonts.alexandria(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: double.infinity,
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
                          style: GoogleFonts.alexandria(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Konfirmasi Password',
                            hintStyle: GoogleFonts.alexandria(
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
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// Tombol Konfirmasi
                      GestureDetector(
                        onTap: _isLoading ? null : _handleRegister,
                        child: Container(
                          width: double.infinity,
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
                                    'Konfirmasi',
                                    style: GoogleFonts.alexandria(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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