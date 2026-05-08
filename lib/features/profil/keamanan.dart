import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/features/auth/lupa_password.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';

class KeamananPage extends StatefulWidget {
  const KeamananPage({super.key});

  @override
  State<KeamananPage> createState() => _KeamananPageState();
}

class _KeamananPageState extends State<KeamananPage> {
  bool _obscurePasswordLama       = true;
  bool _obscurePasswordBaru       = true;
  bool _obscureKonfirmasiPassword = true;
  bool _isLoading                 = false;

  final _controllerLama       = TextEditingController();
  final _controllerBaru       = TextEditingController();
  final _controllerKonfirmasi = TextEditingController();

  @override
  void dispose() {
    _controllerLama.dispose();
    _controllerBaru.dispose();
    _controllerKonfirmasi.dispose();
    super.dispose();
  }

  Future<void> _konfirmasi() async {
    final passwordLama       = _controllerLama.text.trim();
    final passwordBaru       = _controllerBaru.text.trim();
    final konfirmasiPassword = _controllerKonfirmasi.text.trim();

    // Validasi kosong
    if (passwordLama.isEmpty || passwordBaru.isEmpty || konfirmasiPassword.isEmpty) {
      _showSnackBar('Semua kolom harus diisi.', isError: true);
      return;
    }

    // Validasi password baru minimal 6 karakter
    if (passwordBaru.length < 6) {
      _showSnackBar('Password baru minimal 6 karakter.', isError: true);
      return;
    }

    // Validasi konfirmasi cocok
    if (passwordBaru != konfirmasiPassword) {
      _showSnackBar('Konfirmasi password tidak cocok.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService.changePassword(
        passwordLama: passwordLama,
        passwordBaru: passwordBaru,
      );
      if (!mounted) return;
      _showSnackBar('Password berhasil diubah!');
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      _showSnackBar(e.message, isError: true);
    } catch (_) {
      _showSnackBar('Terjadi kesalahan. Coba lagi.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.alexandria(color: Colors.white)),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double screenWidth     = MediaQuery.of(context).size.width;
    final double screenHeight    = MediaQuery.of(context).size.height;

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
                  style: GoogleFonts.alexandria(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              /// ─── Password Saat Ini ───
              Positioned(
                left: screenWidth * 0.139,
                top: statusBarHeight + 290,
                child: Text(
                  'Masukkan Password Saat ini',
                  style: GoogleFonts.alexandria(color: Colors.black, fontSize: 14),
                ),
              ),
              Positioned(
                left: screenWidth * 0.142,
                top: statusBarHeight + 314,
                child: _buildPasswordField(
                  screenWidth: screenWidth,
                  controller: _controllerLama,
                  obscure: _obscurePasswordLama,
                  onToggle: () => setState(() => _obscurePasswordLama = !_obscurePasswordLama),
                ),
              ),

              /// ─── Password Baru ───
              Positioned(
                left: screenWidth * 0.139,
                top: statusBarHeight + 378,
                child: Text(
                  'Masukkan Password Baru',
                  style: GoogleFonts.alexandria(color: Colors.black, fontSize: 14),
                ),
              ),
              Positioned(
                left: screenWidth * 0.142,
                top: statusBarHeight + 402,
                child: _buildPasswordField(
                  screenWidth: screenWidth,
                  controller: _controllerBaru,
                  obscure: _obscurePasswordBaru,
                  onToggle: () => setState(() => _obscurePasswordBaru = !_obscurePasswordBaru),
                ),
              ),

              /// ─── Konfirmasi Password Baru ───
              Positioned(
                left: screenWidth * 0.139,
                top: statusBarHeight + 466,
                child: Text(
                  'Konfirmasi Password Baru',
                  style: GoogleFonts.alexandria(color: Colors.black, fontSize: 14),
                ),
              ),
              Positioned(
                left: screenWidth * 0.142,
                top: statusBarHeight + 490,
                child: _buildPasswordField(
                  screenWidth: screenWidth,
                  controller: _controllerKonfirmasi,
                  obscure: _obscureKonfirmasiPassword,
                  onToggle: () => setState(
                      () => _obscureKonfirmasiPassword = !_obscureKonfirmasiPassword),
                ),
              ),

              /// Lupa Password
              Positioned(
                right: screenWidth * 0.139,
                top: statusBarHeight + 550,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LupaPasswordPage()),
                  ),
                  child: Text(
                    'Lupa Password ?',
                    style: GoogleFonts.alexandria(
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
                top: statusBarHeight + 660,
                child: GestureDetector(
                  onTap: _isLoading ? null : _konfirmasi,
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
                        colors: [Color(0xFFD05122), Color(0xFFEE8B2E), Color(0xFFFBA839)],
                        stops: [0.17, 0.47, 0.60],
                      ),
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
                              'Konfirmasi',
                              style: GoogleFonts.alexandria(
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
                top: statusBarHeight + 721,
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
                        colors: [Color(0xFFAC3715), Color(0xFFD05122), Color(0xFFAC3715)],
                        stops: [0.17, 0.43, 0.61],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Batal',
                        style: GoogleFonts.alexandria(color: Colors.black, fontSize: 20),
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

  Widget _buildPasswordField({
    required double screenWidth,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Container(
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
        controller: controller,
        obscureText: obscure,
        textAlignVertical: TextAlignVertical.center,
        style: GoogleFonts.alexandria(color: Colors.black, fontSize: 15),
        decoration: InputDecoration(
          hintText: '********',
          hintStyle: GoogleFonts.alexandria(color: Colors.black38, fontSize: 15),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: InputBorder.none,
          isDense: false,
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Icon(
              obscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.black26,
              size: 16,
            ),
          ),
          suffixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 35),
        ),
      ),
    );
  }
}