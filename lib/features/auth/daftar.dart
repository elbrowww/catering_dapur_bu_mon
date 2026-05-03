import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/features/auth/login.dart';
import 'package:catering_dapur_bu_mon/features/auth/verifikasi_otp_register.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';

class Daftar extends StatefulWidget {
  const Daftar({super.key});

  @override
  State<Daftar> createState() => _DaftarState();
}

class _DaftarState extends State<Daftar> {
  final TextEditingController _namaController       = TextEditingController();
  final TextEditingController _emailController      = TextEditingController();
  final TextEditingController _noTelpController     = TextEditingController();
  final TextEditingController _alamatController     = TextEditingController();
  final TextEditingController _passwordController   = TextEditingController();
  final TextEditingController _konfirmasiController = TextEditingController();

  bool _obscurePassword   = true;
  bool _obscureKonfirmasi = true;
  bool _isLoading         = false;

  static const _gradientColors = [
    Color(0xFFD05122),
    Color(0xFFEE8B2E),
    Color(0xFFFBA839),
  ];
  static const _gradientStops = [0.17, 0.47, 0.60];

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

  Future<void> _handleRegister() async {
    final nama       = _namaController.text.trim();
    final email      = _emailController.text.trim();
    final noTelp     = _noTelpController.text.trim();
    final alamat     = _alamatController.text.trim();
    final password   = _passwordController.text.trim();
    final konfirmasi = _konfirmasiController.text.trim();

    if (nama.isEmpty)   { _showSnackbar('Nama lengkap harus diisi'); return; }
    if (email.isEmpty)  { _showSnackbar('Email harus diisi'); return; }
    if (!email.contains('@') || !email.contains('.')) {
      _showSnackbar('Format email tidak valid'); return;
    }
    if (noTelp.isEmpty) { _showSnackbar('No Telepon harus diisi'); return; }
    if (alamat.isEmpty) { _showSnackbar('Alamat harus diisi'); return; }
    if (password.isEmpty) { _showSnackbar('Password harus diisi'); return; }
    if (password.length < 6) { _showSnackbar('Password minimal 6 karakter'); return; }
    if (password != konfirmasi) { _showSnackbar('Password tidak sama'); return; }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.sendOtpRegister(noTelp: noTelp);
      final phone  = result['phone'] as String?;

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifikasiOtpRegister(
              nama:     nama,
              email:    email,
              phone:    phone ?? noTelp,
              alamat:   alamat,
              password: password,
            ),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackbar(e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackbar('Terjadi kesalahan: $e');
      }
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
    );
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.alexandria(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    bool showToggle = false,
  }) {
    return Container(
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
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: GoogleFonts.alexandria(color: Colors.black, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.alexandria(
            color: Colors.black.withOpacity(0.3),
            fontSize: 15,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: InputBorder.none,
          suffixIcon: showToggle
              ? GestureDetector(
                  onTap: onToggleObscure,
                  child: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black26,
                    size: 18,
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 48,
          ),
        ),
      ),
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String hint,
    int maxLines = 2,
  }) {
    return Container(
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
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.alexandria(color: Colors.black, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.alexandria(
            color: Colors.black.withOpacity(0.3),
            fontSize: 15,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: InputBorder.none,
        ),
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
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  top: sh * 0.372,
                  child: Container(
                    width: sw,
                    height: sh,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(46),
                    ),
                  ),
                ),
                Positioned(
                  left: sw * 0.276,
                  top: sh * 0.080,
                  child: Image.asset(
                    'assets/icons/icons.png',
                    width: sw * 0.448,
                    height: sw * 0.448,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  left: sw * 0.087,
                  top: sh * 0.397,
                  child: Container(
                    width: sw * 0.826,
                    height: 53,
                    padding: const EdgeInsets.only(
                        top: 4, left: 3, right: 3, bottom: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0D8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
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
                        Expanded(
                          child: GestureDetector(
                            onTap: _navigateToLogin,
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
                        Expanded(
                          child: Container(
                            height: 45.54,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: _gradientColors,
                                stops: _gradientStops,
                              ),
                              borderRadius: BorderRadius.circular(18),
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
                Positioned(
                  left: sw * 0.087,
                  top: sh * 0.470,
                  right: sw * 0.087,
                  bottom: 16,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.055),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Nama Lengkap'),
                        const SizedBox(height: 5),
                        _buildTextField(
                          controller: _namaController,
                          hint: 'Nama Lengkap',
                          keyboardType: TextInputType.name,
                        ),
                        const SizedBox(height: 12),
                        _buildLabel('Email'),
                        const SizedBox(height: 5),
                        _buildTextField(
                          controller: _emailController,
                          hint: 'Email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        _buildLabel('No Telepon'),
                        const SizedBox(height: 5),
                        _buildTextField(
                          controller: _noTelpController,
                          hint: 'No Telepon (08xx / 628xx)',
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        _buildLabel('Alamat'),
                        const SizedBox(height: 5),
                        _buildTextArea(
                          controller: _alamatController,
                          hint: 'Alamat Lengkap',
                        ),
                        const SizedBox(height: 12),
                        _buildLabel('Masukkan Password'),
                        const SizedBox(height: 5),
                        _buildTextField(
                          controller: _passwordController,
                          hint: 'Password (min 6 karakter)',
                          obscure: _obscurePassword,
                          showToggle: true,
                          onToggleObscure: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        const SizedBox(height: 12),
                        _buildLabel('Masukkan Ulang Password'),
                        const SizedBox(height: 5),
                        _buildTextField(
                          controller: _konfirmasiController,
                          hint: 'Konfirmasi Password',
                          obscure: _obscureKonfirmasi,
                          showToggle: true,
                          onToggleObscure: () => setState(
                              () => _obscureKonfirmasi = !_obscureKonfirmasi),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: GestureDetector(
                            onTap: _isLoading ? null : _handleRegister,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: sw * 0.547,
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
                                        'Lanjut',
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
                        const SizedBox(height: 24),
                      ],
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